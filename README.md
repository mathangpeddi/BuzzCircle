# BuzzCircle

Flutter Firebase Project for social media platform

## Getting Started
1) Installation:
git clone https://github.com/keerthi-kalluri/BuzzCircle.git
cd your-repository
2) Install dependencies:
flutter pub get
3) Set up Firebase:
Go to the Firebase Console and create a new project.
Add an Android app and download the google-services.json file. Place this file in the android/app directory.
Add an iOS app and download the GoogleService-Info.plist file. Place this file in the ios/Runner directory.
Enable the necessary Firebase services (Authentication, Firestore, Storage, AppCheck) in the Firebase Console.
4) Configure Firebase in your Flutter project:
Ensure the necessary packages are added in your pubspec.yaml file
5) Run flutter application:
flutter run


## Firebase Services Used
Authentication: For user sign-up and sign-in.
Firestore: As the real-time database.
Storage: For uploading and retrieving files.
AppCheck: For protecting backend resources from abuse, by ensuring that incoming traffic is from our app.

