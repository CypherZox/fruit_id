import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit_example/features/object_detector/domain/enum/fruit_selector_enum.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/helpers/camera_image_to_input_image_helper.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/states/image_bounding_size_state.dart';
import 'package:google_ml_kit_example/core/utils.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class ObjectDetectorProvider extends ChangeNotifier {
  FruitSelectorEnum? _selectedFruit;
  ObjectDetector? _objectDetector;
  bool _canProcess = false;
  bool _isImageProcessing = false;
  CameraLensDirection _cameraLensDirection = CameraLensDirection.back;
  ImageBoundingSizeState _imageBoundingSizeState = IdleImageBoundingSizeState();
  XFile? _file;
  DateTime? _timeOfCapture;
  String? _accuracy;

  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  bool _changingCameraLens = false;

  FruitSelectorEnum? get selectedFruit => _selectedFruit;
  ObjectDetector? get objectDetector => _objectDetector;
  bool get canProcess => _canProcess;
  bool get isImageProcessing => _isImageProcessing;
  CameraLensDirection get cameraLensDirection => _cameraLensDirection;
  ImageBoundingSizeState get imageBoundingSizeState => _imageBoundingSizeState;
  XFile? get image => _file;
  DateTime? get timeOfCapture => _timeOfCapture;
  String? get accuracy => _accuracy;

  Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  bool _hasTakenPicture = false;

  bool get isCameraReady =>
      _cameras.isNotEmpty &&
      _controller != null &&
      (_controller?.value.isInitialized ?? false);

  List<CameraDescription> get cameras => _cameras;
  CameraController? get controller => _controller;
  int get cameraIndex => _cameraIndex;
  bool get changingCameraLens => _changingCameraLens;
  bool get hasTakenPicture => _hasTakenPicture;

  void setAccuracy(String value) {
    _accuracy = value;
    notifyListeners();
  }

  void setHasTakenPicture(bool value) {
    _hasTakenPicture = value;
    notifyListeners();
  }

  setCameras(List<CameraDescription> cameras) {
    _cameras = cameras;
    notifyListeners();
  }

  setController(CameraController controller) {
    _controller = controller;
    notifyListeners();
  }

  setCameraIndex(int index) {
    _cameraIndex = index;
    notifyListeners();
  }

  setChangingCameraLens(bool value) {
    _changingCameraLens = value;
    notifyListeners();
  }

  setImage(Future<XFile>? value, String accuracy) async {
    if (value == null) return;
    setHasTakenPicture(true);
    _timeOfCapture = DateTime.now();
    _accuracy = accuracy;
    final result = await value;
    _file = result;
    setImageBoundingSizeState(ShowingResultState());
    notifyListeners();
  }

  void setImageBoundingSizeState(ImageBoundingSizeState state) {
    if (state.runtimeType == _imageBoundingSizeState.runtimeType) return;
    _imageBoundingSizeState = state;
    if (state is IdleImageBoundingSizeState) {
      _file = null;
      _hasTakenPicture = false;
    }
    if (state is ShowingResultState) {
      stopLiveFeed();
    }
    notifyListeners();
  }

  void setCameraLensDirection(CameraLensDirection value) {
    _cameraLensDirection = value;
    notifyListeners();
  }

  void setIsImageProcessing(bool value) {
    _isImageProcessing = value;
    notifyListeners();
  }

  void setCanProcess(bool value) {
    _canProcess = value;
    notifyListeners();
  }

  void setObjectDetector(ObjectDetector objectDetector) {
    _objectDetector = objectDetector;
    notifyListeners();
  }

  void selectFruit(FruitSelectorEnum fruit) {
    _selectedFruit = fruit;
    notifyListeners();
  }

  /// method to initialize the camera and camera controller
  void initializeCamera() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == _cameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      startLiveFeed();
    }
  }

  ///
  startLiveFeed() {
    if (_cameraIndex == -1) return;
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      _controller?.startImageStream(_processCameraImage).then((value) {
        initializeDetector();
        setCameraLensDirection(camera.lensDirection);
      });
    });
  }

  /// method to process the image for detections
  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    processImage(inputImage);
  }

  /// converts CameraImage into InputImage for processing
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    return CameraImageToInputImageHelper.call(
        image: image,
        controller: _controller!,
        camera: camera,
        sensorOrientation: sensorOrientation,
        orientations: _orientations);
  }

  Future<void> processImage(
    InputImage inputImage,
  ) async {
    if (_objectDetector == null) return;
    if (!_canProcess) return;
    if (_isImageProcessing) return;

    if (selectedFruit == null) return;

    setIsImageProcessing(true);

    final objects = await _objectDetector!.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      List<DetectedObject> filteredObjects = [];
      print(objects
          .map((detectedObject) => detectedObject.labels.map((e) => e.text))
          .toList());
      for (final detectedObject in objects) {
        final filteredLabels = detectedObject.labels
            .where((e) =>
                e.text.toLowerCase() == selectedFruit!.name.toLowerCase())
            .toList();
        if (filteredLabels.isEmpty) continue;

        filteredObjects.add(detectedObject);

        if (detectedObject.boundingBox.width > 375 - 20 &&
            detectedObject.boundingBox.width < 375) {
          await Future.delayed(Duration(milliseconds: 60));
          if (!_hasTakenPicture && filteredLabels.isNotEmpty) {
            final image = _controller?.takePicture();
            setImage(image, detectedObject.labels.first.confidence.toString());
            setImageBoundingSizeState(MatchingSizeState());
          }
        } else if (filteredLabels.isNotEmpty &&
            detectedObject.boundingBox.width < 375 - 20) {
          if (!_hasTakenPicture) {
            setImageBoundingSizeState(MoveCloserSizeState());
          }
        } else if (filteredLabels.isNotEmpty) {
          if (!_hasTakenPicture) {
            setImageBoundingSizeState(MoveFartherSizeState());
          }
        }
      }
    } else {}
    setIsImageProcessing(false);
  }

  Future stopLiveFeed() async {
    await _controller?.stopImageStream();
    Future.delayed((Duration(seconds: 2))).then((_) async {
      await _controller?.dispose();
      await _objectDetector?.close();
      _objectDetector = null;
      _controller = null;
      notifyListeners();
    });
  }

  Future switchLiveCamera() async {
    setChangingCameraLens(true);
    setCameraIndex(_cameraIndex + 1) % _cameras.length;

    await stopLiveFeed();
    await startLiveFeed();
    setChangingCameraLens(false);
  }

  Future<void> initializeDetector() async {
    _objectDetector?.close();
    _objectDetector = null;
    notifyListeners();
    final modelPath =
        await getAssetPath('assets/ml/object_labeler_fruits.tflite');
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);

    setCanProcess(true);
  }

  disposeObjectDetector() {
    _objectDetector?.close();
    notifyListeners();
  }

  @override
  void dispose() {
    disposeObjectDetector();
    super.dispose();
  }
}
