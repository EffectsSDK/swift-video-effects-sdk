# Video Effects SDK - iOS Swift Package

Add real-time AI video enhancement that makes video meeting experience more effective and comfortable to your application in a few hours.

This repository contains the Swift Package version of Objective-C iOS xcframeworks versions of Video Effects SDK that you can integrate into your project/product. This package and xcframework can be included in Swift iOS project.

Also, there is [the Sample Xcode project with Video Effects SDK integration](https://github.com/EffectsSDK/ios-swift-integration-sample), so you can just build and run it to see SDK in action.

## Obtaining Effects SDK License

To receive a Effects SDK license please fill in the contact form on [effectssdk.ai](https://effectssdk.ai/contacts) website.

## Documentation

[Documentation Website](https://effectssdk.ai/sdk/ios/documentation/tsvb/)

## Technical Details

- SDK available for iOS 13 and newer.
- Frames are processed on the [GPU](https://effectssdk.ai/sdk/ios/documentation/tsvb/backend/gpu) with Metal (the [CPU](https://effectssdk.ai/sdk/ios/documentation/tsvb/backend/cpu) backend is an obsolete path).
- ML inference runs through Core ML and by default tries to use the Apple Neural Engine; Core ML may also use the GPU and the CPU. See [isSegmentationOnNeuralEngineEnabled](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipelineconfiguration/issegmentationonneuralengineenabled) and [isSegmentationOnGPUEnabled](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipelineconfiguration/issegmentationongpuenabled).
- 2 segmentation presets: [Quality](https://effectssdk.ai/sdk/ios/documentation/tsvb/segmentationpreset/quality) and [Balanced](https://effectssdk.ai/sdk/ios/documentation/tsvb/segmentationpreset/balanced). See [segmentationPreset](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipelineconfiguration/segmentationpreset).

## Features

- **Virtual Backgrounds**: Replace your background with any image for a polished, professional look.
- **Background Removal**: Make your background transparent and place yourself over any content.
- **Background Blur**: Keep the focus on you by blurring out distracting surroundings.
- **Beautification & Touch-Up**: Enhance your appearance with real-time skin smoothing and touch-up effects.
- **Auto Framing**: Stay perfectly centered in the frame with smart, automatic cropping.
- **Auto Color Correction**: Achieve balanced, professional-grade colors in any lighting condition, and fine-tune white balance, exposure, temperature, tint, vibrance and contrast by hand.
- **Color Grading**: Match the colors of your video to any reference image.
- **Color Filters (LUT-Based)**: Apply cinematic color grading with customizable LUT filters.
- **Low-Light Mode**: Brighten and clarify videos in dimly lit environments.
- **Video Clarity & Sharpness**: Enhance details and sharpness for crystal-clear video quality.
- **Noise Suppression**: Reduce grainy noise and keep the picture calm from frame to frame.
- **Portrait Lighting**: Light yourself up and dim the background, with separate control of each.

## Usage details

The entrypoint of the SDK is the instance of [SDKFactory](https://effectssdk.ai/sdk/ios/documentation/tsvb/sdkfactory).
Using an **SDKFactory** instance you will be able to prepare frames for processing and configure the pipeline of processing (enable transparency, blur, replace background etc).

### Usage

Add package dependency into your project. See [Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

Import Video Effects SDK into your code.
```swift
import TSVB
```

Preparation:
- Create an instance of [SDKFactory](https://effectssdk.ai/sdk/ios/documentation/tsvb/sdkfactory).
- Authorize the instance of **SDKFactory** by using [auth(customerID:)](https://effectssdk.ai/sdk/ios/documentation/tsvb/sdkfactory/auth(customerid:completionhandler:)) method, or without internet connection by using [auth(key:)](https://effectssdk.ai/sdk/ios/documentation/tsvb/sdkfactory/auth(key:)).
- Create an instance of [FrameFactory](https://effectssdk.ai/sdk/ios/documentation/tsvb/framefactory) by using [newFrameFactory()](https://effectssdk.ai/sdk/ios/documentation/tsvb/sdkfactory/newframefactory()) method of **SDKFactory**.
- Create an instance of [Pipeline](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline) by using [newPipeline()](https://effectssdk.ai/sdk/ios/documentation/tsvb/sdkfactory/newpipeline()) method of **SDKFactory**.
- Enable background blur using [enableBlurBackground(power:)](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enableblurbackground(power:)) method or background replacement using [enableReplaceBackground(_:)](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enablereplacebackground(_:)) method of **Pipeline**.
- When the background replacement is enabled you can pass image which will be used as a background: [ReplacementController.background](https://effectssdk.ai/sdk/ios/documentation/tsvb/replacementcontroller/background)

Frame processing:
- Put your frame to [Frame](https://effectssdk.ai/sdk/ios/documentation/tsvb/frame) using [newFrame(format:data:bytesPerLine:width:height:makeCopy:)](https://effectssdk.ai/sdk/ios/documentation/tsvb/framefactory/newframe(format:data:bytesperline:width:height:makecopy:)) method of [FrameFactory](https://effectssdk.ai/sdk/ios/documentation/tsvb/framefactory).
- Process it through [process(_:error:)](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/process(_:error:)) method of **Pipeline**.
- If your frame is [CVPixelBuffer](https://developer.apple.com/documentation/corevideo/cvpixelbuffer-q2e), you just can use [process(pixelBuffer:metalCompatible:error:)](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/process(pixelbuffer:metalcompatible:error:)) method of **Pipeline**.

Performance tip: Prefer [process(pixelBuffer:metalCompatible:error:)](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/process(pixelbuffer:metalcompatible:error:)) method and pass metal compatible CVPixelBuffer for better performance when Metal pipeline is active.

Use separate **Pipeline** instances per video stream. A **Pipeline** may be used from any thread without locks; enabling an effect may load a model and take a while, so call the `enable` methods off the main thread.

```swift
import TSVB

func setUp(backgroundPath: String) async throws -> Bool {
    let sdkFactory = SDKFactory()
    let authResult = try await sdkFactory.auth(customerID: "CUSTOMER_ID")
    guard authResult.status == .active,
        let frameFactory = sdkFactory.newFrameFactory(),
        let pipeline = sdkFactory.newPipeline() else {
        return false
    }

    pipeline.enableNoiseSuppression()

    var backgroundController: ReplacementController?
    guard pipeline.enableReplaceBackground(&backgroundController) == .ok else {
        return false
    }
    backgroundController?.background = frameFactory.image(withContentOfFile: backgroundPath)

    self.frameFactory = frameFactory
    self.pipeline = pipeline
    self.backgroundController = backgroundController
    return true
}

// For each frame of the stream, for example from AVCaptureVideoDataOutput:
func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
    var error = PipelineError.ok
    let processed = pipeline?.process(pixelBuffer: pixelBuffer, metalCompatible: true, error: &error)
    return processed?.toCVPixelBuffer()
}
```
