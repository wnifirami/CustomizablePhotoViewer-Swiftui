# CustomizablePhotoViewer

A full-screen SwiftUI photo viewer with hero expand/collapse animation, pinch-to-zoom, and pan-to-dismiss.

---

## Preview

<p align="center">
  <img src="https://github.com/user-attachments/assets/aabdc1fe-96cc-4355-a6d7-9c754afc210f" width="30%" alt="Gallery view" />
</p>

---

## Features

- **Hero animation** — thumbnail expands into the full-screen viewer and collapses back with a spring transition
- **Pinch-to-zoom** — smooth UIScrollView-backed zoom up to a configurable maximum scale
- **Pan-to-dismiss** — drag the image down to fly it back to the thumbnail
- **Caption overlay** — gradient bar with title, summary, and credit fields via NSAttributedString
- **Custom views** — inject your own caption, loading indicator, or title via configuration closures
- **Zero dependencies** — pure SwiftUI + UIKit, no third-party packages

---

## Requirements

| | Minimum |
|---|---|
| iOS | 17.0 |
| Swift | 5.9 |
| Xcode | 15.0 |

---

## Installation

### Swift Package Manager

**Xcode:** File → Add Package Dependencies, paste the URL below, select *Up to Next Major Version* from `1.0.0`.

```
https://github.com/wnifirami/CustomizablePhotoViewer-Swiftui.git
```

**Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/wnifirami/CustomizablePhotoViewer-Swiftui.git", from: "1.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: ["CustomizablePhotoViewer"])
]
```

---

## Quick start

```swift
import SwiftUI
import CustomizablePhotoViewer

// 1. Conform your photo model to PhotoViewerPhoto
final class MyPhoto: PhotoViewerPhoto {
    let image: UIImage?
    init(_ image: UIImage?) { self.image = image }
}

// 2. Drop PhotoViewerView into a ZStack
struct ContentView: View {
    @State private var openIndex: Int? = nil
    @State private var currentIndex: Int = 0
    private let photos = [MyPhoto(UIImage(named: "photo1"))]

    var body: some View {
        ZStack {
            galleryView
            if openIndex != nil {
                PhotoViewerView(
                    photos:              photos,
                    openIndex:           $openIndex,
                    sourceFrameProvider: { _ in thumbnailFrame },
                    currentVisibleIndex: $currentIndex
                )
            }
        }
    }
}
```

---

## Configuration

Every visual and behavioural property comes from `PhotoViewerConfiguration`. All properties are optional — leave any of them nil to use the built-in default.

```swift
var configuration = PhotoViewerConfiguration()
configuration.titleProvider         = { _, index, total in "\(index + 1) / \(total)" }
configuration.maximumZoomScaleProvider = { _ in 5.0 }
configuration.onDidDismiss          = { print("viewer closed") }

PhotoViewerView(
    photos:              photos,
    openIndex:           $openIndex,
    sourceFrameProvider: { _ in frame },
    configuration:       configuration,
    currentVisibleIndex: $currentIndex
)
```

### View modifier (no hero animation)

```swift
myView.photoViewer(isPresented: $isPresented, photos: photos)
```

---

## PhotoViewerConfiguration reference

### Lifecycle

| Property | Signature | Description |
|---|---|---|
| `onWillDismiss` | `() -> Void` | Called just before the dismiss animation starts |
| `onDidDismiss` | `() -> Void` | Called after the viewer is fully removed |
| `onNavigate` | `(PhotoViewerPhoto, Int) -> Void` | Called each time the viewer pages to a new photo |

### Customisation

| Property | Signature | Description |
|---|---|---|
| `titleProvider` | `(PhotoViewerPhoto, Int, Int) -> String?` | Override the nav-bar title. Nil → "X of Y" |
| `captionViewProvider` | `(PhotoViewerPhoto) -> AnyView?` | Replace the built-in gradient caption |
| `loadingViewProvider` | `(PhotoViewerPhoto) -> AnyView?` | Replace the built-in spinner |
| `maximumZoomScaleProvider` | `(PhotoViewerPhoto) -> CGFloat` | Per-photo zoom limit. Nil → 3.0 |
| `longPressHandler` | `(PhotoViewerPhoto) -> Bool` | Custom long-press action. Return true to suppress the copy-to-pasteboard fallback |

---

## PhotoViewerPhoto protocol

```swift
public protocol PhotoViewerPhoto: AnyObject {
    var imageData: Data? { get }              // animated GIFs — takes priority over image
    var image: UIImage? { get }
    var placeholderImage: UIImage? { get }
    var attributedCaptionTitle:   NSAttributedString? { get }
    var attributedCaptionSummary: NSAttributedString? { get }
    var attributedCaptionCredit:  NSAttributedString? { get }
}
```

All properties have default implementations returning `nil` — only implement what you need.

---

## Project structure

```
CustomizablePhotoViewer/
├── CustomizablePhotoViewer.xcodeproj/
├── Sources/PhotoViewer/
│   ├── PhotoViewerView.swift              ← public entry point
│   ├── PhotoViewerModel.swift             ← internal state
│   ├── PhotoViewerModifier.swift          ← .photoViewer() View extension
│   ├── Configuration/
│   │   └── PhotoViewerConfiguration.swift
│   ├── Models/
│   │   ├── PhotoViewerPhoto.swift
│   │   └── PhotoViewerDataSource.swift
│   ├── Views/
│   │   ├── ZoomableScrollView.swift
│   │   ├── ZoomScrollView.swift
│   │   ├── HeroOverlayView.swift
│   │   ├── PhotoOverlayView.swift
│   │   ├── PhotoCaptionView.swift
│   │   ├── AttributedLabel.swift
│   │   └── PhotoPageView.swift
│   └── Helpers/
│       └── Array+SafeSubscript.swift
├── Example/
│   ├── ExampleApp.swift
│   ├── ContentView.swift
│   ├── DemoPhoto.swift
│   ├── PhotoViewerDemoView.swift
│   └── Assets.xcassets/
└── Screenshots/
```

---

## Running the example

Open `CustomizedPhotoViewer.xcodeproj` in Xcode 15+, select the **CustomizedPhotoViewer** scheme, and run on an iOS 17+ simulator.

---

## License

MIT — see [LICENSE](LICENSE).

© 2026 Rami Ounifi
