import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_ml_kit_example/core/di/di.dart';
import 'package:google_ml_kit_example/core/ui/ui_constants.dart';
import 'package:google_ml_kit_example/features/object_detector/domain/enum/fruit_selector_enum.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/providers/object_detector_provider.dart';
import 'package:google_ml_kit_example/features/object_detector/presentation/pages/object_detector_view.dart';
import 'package:provider/provider.dart';

class FruitSelectorPage extends StatefulWidget {
  const FruitSelectorPage({Key? key}) : super(key: key);

  @override
  State<FruitSelectorPage> createState() => _FruitSelectorPageState();
}

class _FruitSelectorPageState extends State<FruitSelectorPage> {
  final provider = getIt<ObjectDetectorProvider>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  //this
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Choose the fruit you want to find!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Space Gortex',
                          ),
                        ),
                        Expanded(
                          child: Selector<ObjectDetectorProvider,
                                  FruitSelectorEnum?>(
                              selector: (context, provider) =>
                                  provider.selectedFruit,
                              builder: (context, selectedFruit, _) {
                                return ListView.builder(
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      provider.selectFruit(
                                          FruitSelectorEnum.values[index]);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 24),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 20),
                                      decoration: BoxDecoration(
                                          border: selectedFruit ==
                                                  FruitSelectorEnum
                                                      .values[index]
                                              ? Border.all(
                                                  color: AppColors.primaryColor,
                                                  width: 1)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(32),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryShadow
                                                  .withOpacity(0.15),
                                              offset: Offset(7, 7),
                                              blurRadius: 30,
                                            )
                                          ]),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            child: SvgPicture.asset(
                                              FruitSelectorEnum
                                                  .values[index].icon,
                                              width: 32,
                                              height: 32,
                                            ),
                                          ),
                                          Text(
                                            FruitSelectorEnum
                                                .values[index].title,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Space Gortex',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  itemCount: FruitSelectorEnum.values.length,
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Selector<ObjectDetectorProvider, bool>(
                selector: (p0, p1) => p1.selectedFruit != null,
                builder: (context, isSelectedFruit, _) {
                  return AnimatedOpacity(
                    opacity: isSelectedFruit ? 1 : 0.4,
                    duration: Duration(milliseconds: 200),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16, right: 8),
                        child: InkWell(
                          radius: 40,
                          onTap: () {
                            if (isSelectedFruit) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ObjectDetectorView()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8),
                                      child: Text(
                                        'Ops! you need to select a fruit first!',
                                        maxLines: 4,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Space Gortex',
                                        ),
                                      )),
                                  backgroundColor:
                                      AppColors.primaryColor.withOpacity(0.6),
                                ),
                              );
                            }
                          },
                          child: Image.asset(
                            'assets/images/let_s_start.png',
                            height: 100,
                            width: 100,
                          ),
                        ),
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
