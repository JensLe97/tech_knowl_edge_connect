# tech_knowl_edge_connect

Education app for learning and exchanging with others.

Available at https://tech-knowl-edge-connect.jenslemke.com.

# GitHub Actions

Each commit will run flutter tests and build an android appbundle to validate the build process.

## Web

Each commit will upload the web application to firebase hosting.

## Android

Each tag will create a new release and deploy an appbundle to the internal testers track in the Google Play Console.

1. Update the version number in `pubspec.yaml`
2. Create and publish a new tag with:

```
git tag vX.Y.Z
git push origin vX.Y.Z
```

### Upload Screenshots in Google Play Console

Pixel 9 Emulator: 1080 x 2424px
Pixel Tablet Emulator: 1600 x 2560px

Select the release from the GitHub Actions builds and upload to Google Play Console.

## iOS

Each tag will trigger an XCode build in Xcode Cloud with the version number from `pubspec.yaml`.

### Upload Screenshots in App Store Connect

iPhone 14 Plus iOS Simulator: 1284 × 2778px 
iPad Pro 13-inch (M4) iPadOS Simulator: 2064 × 2752px

Select the release from the Xcode Cloud builds and upload to App Store Connect.
