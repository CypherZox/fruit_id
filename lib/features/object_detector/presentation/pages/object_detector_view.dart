import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_ml_kit_example/core/di/di.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/pages/detection_result.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/providers/object_detector_provider.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/states/image_bounding_size_state.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/pages/camera_view.dart';
import 'package:provider/provider.dart';

class ObjectDetectorView extends StatefulWidget {
  const ObjectDetectorView();
  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  String? _text;
  final provider = getIt<ObjectDetectorProvider>();

  @override
  void dispose() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      provider.disposeObjectDetector();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: provider,
        child: Selector<ObjectDetectorProvider,
            (CameraLensDirection, ImageBoundingSizeState)>(
          selector: (_, provider) =>
              (provider.cameraLensDirection, provider.imageBoundingSizeState),
          builder: (context, state, _) {
            print('kkk: ${state.$2}');
            if (state.$2 is MatchingSizeState ||
                state.$2 is ShowingResultState) {
              return DetectionResult();
            } else {
              return CameraView();
            }
          },
        ),
      ),
    );
  }
}
