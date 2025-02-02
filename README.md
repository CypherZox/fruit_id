# Fruit identifier app, built with Google ML Kit
## App Preview


https://github.com/user-attachments/assets/da956779-a034-43ec-b8c8-99b168a530b8



# Google ML Kit:
The reason behind using the [Google ML kit](https://pub.dev/packages/google_ml_kit) is that it's the most recently maintained flutter package for ML Object detection, other options like TFlite_v2 and flutter_tflite were less likely
to be well-maintained. 
# Fruit tflite model:
I used the fruits model cause I find it fun, also reachable, and on everyone's home if someone wants to test the app, in addition to that I noticed the classifier there is pretty good, 
compared to other models I tried (plants and general object labeler).
# App Architecture:
- Used the clean architecture, but since the app has a very small usecase, and didn't require a data layer, we only have domain and presentation layers. 
- The domain layer mainly contained `enums` since I also did not use `usecases`. 
- The presentation layer contained:
  - Pages: the ui views for the application.
  - Providers: State management classes extending ChangeNotifier.
  - States: States classes that are updated through the provider, and listened to from the UI.
 
## The ObjectDetectionProvider
This is the one and only provider in this application, it contains all the logic of initializing and disposing of the controllers of camera and object detectors.
- Why only one provider?
  The app is very simple and the three screens have logic that is tied together, spreading this logic into multiple providers will be an overkill, especially since this application 
is already performance-heavy (every camera frame gets processed and each object detected has to be filtered according to the selected fruit by the user). 
## Dependency Injection
- Why use Dependency injection?
  I used GetIt to inject the instance of **ObjectDetectionProvider** as a lazy singleton.
- Why a lazy singleton?
  Since the three screens are using one provider(**ObjectDetectionProvider**) it's better to have one instance of it throughout the app's lifecycle to avoid re-initializing it every 
time it's called (again performance optimization). Also if we will add new features for example this will be a good start for a scalable app.
## ImageBoundingSizeState:
This is a sealed class that extends the states of the image being detected, it will emit:
-  **MoveCloserSizeState** when the object identifier finds the object but does not fit the bounding box frame.
- **MatchingSizeState** when the object identifier finds the selected object and it fits in the boundaries of the specified frame, and this triggers the image capture and navigation 
to the result page.
- For performance optimization reasons we don't update the state unless it's different from the one already there (for example when the user should move closer, the **MoveCloserSizeState** 
will be triggered with every frame) to solve this I put a condition guarding from double emits:
``  void setImageBoundingSizeState(ImageBoundingSizeState state) {
    if (state.runtimeType == _imageBoundingSizeState.runtimeType) return;
``

### Packages used:
- Camera.
- Provider.
- google_mlkit_object_detection

## How to run the app:
- Clone the repository.
- Run:
`flutter clean`
`flutter pub get`
`flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs`
And good luck 🎉
