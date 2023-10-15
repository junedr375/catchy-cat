# Cat Facts App

This is a Flutter app that displays random cat facts.

## Getting Started

To run this app, you will need to have Flutter installed on your machine. You can download Flutter from the official website: https://flutter.dev/docs/get-started/install

Once you have Flutter installed, follow these steps to run the app:

1. Clone this repository to your local machine.
2. Open the project in your preferred code editor (such as Visual Studio Code).
3. Open a terminal window in the project directory.
4. Run the following command to download the required packages:

   ```
   flutter pub get
   ```

5. Run the app using the following command:

   ```
   flutter run
   ```

   This will launch the app in a simulator or on a connected device.

## Packages Used

This app uses the following packages:

- `cupertino_icons: ^1.0.2`: Provides the Cupertino icons used in the app.
- `bloc: ^8.1.2`: Provides the BLoC state management library.
- `flutter_bloc: ^8.1.3`: Provides the Flutter-specific implementation of the BLoC library.
- `hive: ^2.2.3`: Provides a lightweight and fast key-value database for storing cat facts.
- `http: ^0.13.3`: Provides a client for making HTTP requests to the cat facts API.
- `path_provider: ^2.1.1`: Provides a platform-independent way to access the device's file system for storing cached cat facts.
- `sqflite: ^2.2.6`: Provides a SQLite database for storing visibility data.
- `visibility_detector: ^0.4.0+2`: Provides a widget that detects when a tile is visible on the screen and sends visibility data to the BLoC.