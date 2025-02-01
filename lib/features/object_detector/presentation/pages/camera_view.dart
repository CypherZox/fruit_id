import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_ml_kit_example/core/di/di.dart';
import 'package:google_ml_kit_example/core/ui/ui_constants.dart';
import 'package:google_ml_kit_example/features/object_detector/domain/enum/fruit_selector_enum.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/providers/object_detector_provider.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/states/image_bounding_size_state.dart';
import 'package:provider/provider.dart';

class CameraView extends StatefulWidget {
  CameraView({
    Key? key,
  }) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final provider = getIt<ObjectDetectorProvider>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        provider.initializeCamera();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        provider.stopLiveFeed();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, s) {
        if (didPop) {
          provider.stopLiveFeed();
        }
      },
      child: ChangeNotifierProvider.value(
        value: provider,
        child: Selector<ObjectDetectorProvider, (bool, bool)>(
            selector: (context, provider) =>
                (provider.isCameraReady, provider.changingCameraLens),
            builder: (context, cameraState, _) {
              if (!cameraState.$1) {
                return SizedBox();
              }
              return Scaffold(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                  body: Stack(
                    children: <Widget>[
                      cameraState.$2
                          ? Center(
                              child: const Text('Changing camera lens'),
                            )
                          : Center(
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.2),
                                ),
                                child: CameraPreview(
                                  provider.controller!,
                                ),
                              ),
                            ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 120),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.grey.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Selector<ObjectDetectorProvider,
                                        ImageBoundingSizeState>(
                                    selector: (_, p) =>
                                        p.imageBoundingSizeState,
                                    builder:
                                        (context, imageBoundingBoxState, _) {
                                      return Text(
                                        imageBoundingBoxState
                                                is MoveCloserSizeState
                                            ? 'Move closer to'
                                            : imageBoundingBoxState
                                                    is MoveFartherSizeState
                                                ? 'Move farther from '
                                                : 'Looking for ',
                                        style: TextStyle(
                                          fontFamily: 'Space Gortex',
                                          fontSize: 14,
                                        ),
                                      );
                                    }),
                                SvgPicture.asset(
                                  provider.selectedFruit!.icon,
                                  height: 16,
                                  width: 16,
                                ),
                                Text(
                                  ' ...',
                                  style: TextStyle(
                                    fontFamily: 'Space Gortex',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 375,
                          height: MediaQuery.of(context).size.height * 0.5,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.grey, width: 3),
                              borderRadius: BorderRadius.circular(32)),
                        ),
                      )
                      // _backButton(),
                      // _switchLiveCameraToggle(),
                    ],
                  ));
            }),
      ),
    );
  }
}
