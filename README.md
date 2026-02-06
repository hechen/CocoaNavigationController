# CocoaNavigationController

A UINavigationController-like container view controller for macOS.

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![macOS 12+](https://img.shields.io/badge/macOS-12+-blue.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

- **Push & Pop** - Familiar iOS-style navigation API
- **Animated Transitions** - Smooth horizontal slide animations
- **View Controller Stack** - Full stack management (push, pop, popToRoot, setViewControllers)
- **Delegate Support** - willShow/didShow callbacks
- **Modern Swift** - Swift 5.9+ with @MainActor safety

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/hechen/CocoaNavigationController.git", from: "2.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → Enter the repository URL.

## Usage

### Basic Setup

```swift
import CocoaNavigationController

// Create navigation controller with a root view controller
let rootVC = MyViewController()
let navController = CocoaNavigationController(rootViewController: rootVC)

// Set as window's content view controller
window.contentViewController = navController
```

### Push

```swift
let detailVC = DetailViewController()
navigationController?.push(detailVC, animated: true)
```

### Pop

```swift
// Pop one level
navigationController?.pop(animated: true)

// Pop to specific view controller
navigationController?.popToViewController(targetVC, animated: true)

// Pop to root
navigationController?.popToRootViewController(animated: true)
```

### Set Stack

```swift
// Replace entire stack
let newStack = [rootVC, vc1, vc2, vc3]
navigationController?.setViewControllers(newStack, animated: true)
```

### Access Navigation Controller

```swift
// From any view controller in the stack
class MyViewController: NSViewController {
    func goBack() {
        navigationController?.pop(animated: true)
    }
}
```

### Delegate

```swift
class MyClass: CocoaNavigationControllerDelegate {
    func navigationController(_ navController: CocoaNavigationController, 
                              willShow viewController: NSViewController, 
                              animated: Bool) {
        print("Will show: \(viewController)")
    }
    
    func navigationController(_ navController: CocoaNavigationController, 
                              didShow viewController: NSViewController, 
                              animated: Bool) {
        print("Did show: \(viewController)")
    }
}

navController.delegate = myDelegate
```

## How It Works

The navigation controller uses snapshot-based animations for smooth transitions:

```
                    Push →
    ┌─────────────┐ ┌─────────────┐
    │             │ │             │
    │    From     │ │     To      │
    │             │ │             │
    └─────────────┘ └─────────────┘
                    ← Pop
```

1. Before animation: Create snapshots of both views
2. During animation: Slide snapshots horizontally
3. After animation: Replace snapshot with real view

This ensures smooth 60fps animations regardless of view complexity.

## Requirements

- macOS 12.0+
- Swift 5.9+
- Xcode 15+

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Originally created by [Chen He](https://github.com/hechen) in 2019.
Updated in 2026 with modern Swift patterns and Swift Package Manager support.
