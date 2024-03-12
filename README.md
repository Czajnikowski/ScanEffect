# ScanEffect

Everybody knows how a scanner works, right? Right... 😳?

It's a bit complicated, but in the essence the process is:
1. You put content on the scan area
2. Scan sensor scans the area line by line
3. Each scanned line gets stored in the image output

That's it. Simple 🤓

## How does this effect work?

Fun things can happen when you move the content while the scan is in progress. The [`scanEffect` extension](https://github.com/Czajnikowski/ScanEffect/blob/main/Sources/ScanEffect/ScanEffect.swift#L11-L41) allows you to create such effects.

Here's [one possible implementation](https://github.com/Czajnikowski/ScanEffect/blob/main/Sources/ScanEffect/ScanEffectContentDisplacementCalculator%2BFunctions.swift#L67-L77):

<img src="https://raw.githubusercontent.com/Czajnikowski/ScanEffect/main/scan-effect.gif" width="250"/>

Normally, image processing is handled by the GPU. The shader function gets tasked with the processing of `scanArea.height * scanArea.width` pixels. It's more than normal to implement the entire effect inside the shader, however if you want to inject some interactivity or in any way influence the output of the shader from the outside, you have to be able to do some work on the CPU as well. `scanEffect` does this by exposing the [`ScanEffectContentDisplacementCalculator`](https://github.com/Czajnikowski/ScanEffect/blob/main/Sources/ScanEffect/ScanEffectContentDisplacementCalculator.swift#L11-L32) that allows you to calculate a displacement of content for each line of scan area per frame. So the process is:

1. You add `sceneEffect` modifier to your `View`
2. For each line of the scan area the effect calculates content displacement based on supplied [`ScanEffectContentDisplacementCalculator`](https://github.com/Czajnikowski/ScanEffect/blob/main/Sources/ScanEffect/ScanEffectContentDisplacementCalculator.swift#L11-L32)
3. The content gets displaced in the scan area and gets used to provide a line of content in the output image.

As a consequence a [`scanArea.height` number of calls to `displacedContentPosition.calculate` happens on the CPU](https://github.com/Czajnikowski/ScanEffect/blob/main/Sources/ScanEffect/ScanEffect.swift#L115-L128) to render a frame. Much? Not so much? Depends. It can become quite heavy if you want to render an animation, so be careful!

## How do I integrate it?

Use as a Swift Package.

## Why?

I made it mostly for myself as an exercise in my recent `SwiftUI` + `Metal` research.

Feel free to use it (well, it's not necessarily production-ready - it depends on a use case), feel free to contribute (fix issues, share ideas), feel free to hit me up [@czajnikowski](https://twitter.com/czajnikowski) 👋
