import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_ml_kit_example/core/di/di.dart';
import 'package:google_ml_kit_example/core/ui/ui_constants.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/pages/fruit_selector.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/providers/object_detector_provider.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/states/image_bounding_size_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetectionResult extends StatefulWidget {
  const DetectionResult({super.key});

  @override
  State<DetectionResult> createState() => _DetectionResultState();
}

class _DetectionResultState extends State<DetectionResult> {
  final provider = getIt<ObjectDetectorProvider>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.addPostFrameCallback((_) =>
        provider.setImageBoundingSizeState(IdleImageBoundingSizeState()));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: provider,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 46),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                provider.image != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.file(
                              File(
                                provider.image!.path,
                              ),
                              height: MediaQuery.of(context).size.height * 0.5,
                            )),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: SizedBox(
                          height: 45,
                          width: 45,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Found the ${provider.selectedFruit?.name}🎉! ',
                    style: TextStyle(
                      fontFamily: 'Space Gortex',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Date: ',
                            style: TextStyle(
                              fontFamily: 'Space Gortex',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                provider.timeOfCapture ?? DateTime.now()),
                            style: TextStyle(
                              fontFamily: 'Space Gortex',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Accuracy: ',
                          style: TextStyle(
                            fontFamily: 'Space Gortex',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: double.parse(provider.accuracy ?? '0.0')
                              .toStringAsFixed(4),
                          style: TextStyle(
                            fontFamily: 'Space Gortex',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.only(top: 24, bottom: 24),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FruitSelectorPage()),
                        (_) => false);
                  },
                  icon: SvgPicture.asset(
                    'assets/images/retry.svg',
                    height: 60,
                    width: 60,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
