# SwiftyRouter

SwiftyRouter is a lightweight Swift package designed exclusively for SwiftUI applications. It simplifies navigation, alert handling, and content sharing, enabling developers to write clean, reusable, and maintainable code.

## Requirements
- Swift 5.8+
- iOS 15


## Features

- Effortless Navigation: Push, pop, present, and dismiss views in a SwiftUI-friendly way.
- Alert Support: Quickly display alerts and action sheets with customizable content.
- Activity Sharing: Easily share text, images, or URLs with an intuitive API.
- Environment-based Access: Access the router seamlessly through SwiftUI’s @Environment.

## Installation

Swift Package Manager (SPM)

1. Open your Xcode project.
2. Go to File > Add Packages.
3. Add the package repository URL:

```https://github.com/YevhenBiiak/SwiftyRouter.git```

4. Select the latest version and integrate it into your project.

## Usage

Wrap your root view in a RouterView, much like you would with a NavigationView.

```swift
import SwiftyRouter

struct ContentView: View {
    var body: some View {
        RouterView { router in
            VStack {
                Text("Welcome to SwiftyRouter!")
                Button("Go to Next View") {
                    router.push(NextView())
                }
            }
        }
    }
}
```

And then, use the router through the SwiftUI environment:

```swift
struct NextView: View {
    @Environment(\.router) private var router
    var body: some View {
        VStack {
            Button("Go Back") {
                router.pop()
            }
            Button("Show Alert") {
                router.alert("Alert", message: "Alert Message") {
                    Button("Request Review") {
                         router.requestReview()
                    }
                    Button("Open Settings") {
                         router.openSettings()
                    }
                }
            }    
            Button("Share Content") {
                router.activity(items: ["Check out SwiftyRouter!"])
            }
        }
    }
}
```

License

This project is licensed under the MIT License. See the LICENSE file for more details.