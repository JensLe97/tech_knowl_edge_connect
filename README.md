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

## iOS

Each commit will trigger an XCode build in Xcode Cloud with the version number from `pubspec.yaml`.
