# Vienna POI Explorer

This repository contains the initial SwiftUI project scaffold for a native iOS application to explore points of interest in Vienna.

The current milestone focuses on creating the project structure, app entry point, model and service separation, and a functional initial screen. The next stages will add the full data integration with the Vienna open-data source and the complete map experience.

## Project structure

- `ViennaPOIExplorer/` – application source code
- `ViennaPOIExplorer.xcodeproj` – Xcode project configuration for the app

## Requirements

- Xcode 15 or newer
- iOS 17.0 deployment target or newer
- Swift 5.9+

## Notes

This project is intentionally lightweight and resilient to missing network access or location permission. The initial screen remains usable even when the live data source is unavailable.
