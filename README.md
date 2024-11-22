# Video Effects SDK - iOS Swift Package

Add real-time AI video enhancement that makes video meeting experience more effective and comfortable to your application in a few hours.

This repository contains the Swift Package version of Objective-C iOS xcframeworks versions of Video Effects SDK that you can integrate into your project/product. This package and xcframework can be included in Swift iOS project.

Also, there is [the Sample Xcode project with Video Effects SDK integration](https://github.com/EffectsSDK/ios-swift-integration-sample), so you can just build and run it to see SDK in action.

## Obtaining Effects SDK License

To receive a Effects SDK license please fill in the contact form on [effectssdk.com](https://effectssdk.com/contacts) website.

## Technical Details

- SDK available for iOS 13 and newer.
- Frames preprocessing/postprocessing could be run on CPU or GPU.
- ML inference could be run only on CPU.
- 4 Virtual Background presets (Quality, Balanced, Speed and Lightning). See [pipeline configuration](#pipelineconfiguration).

## Features

- Virtual backgrounds (put image as a background) - **implemented**
- Background blur - **implemented**
- Beautification/Touch up my appearance - **implemented**
- Auto framing/Smart Zoom - **implemented**
- Auto color correction - **implemented**
- Color grading - **implemented**

## Usage  details

The entrypoint of the SDK is the instance of [SDKFactory](#sdkfactory). 
Using an **SDKFactory** instance you will be able to prepare frames for processing and configure the pipeline of processing (enable transparency, blur, replace background etc).

### Usage

Add package dependency into your project. See [Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#)

Import Video Effects SDK into your code.
```swift
import TSVB
```

Preparation:
- Create an instance of [SDKFactory](#sdkfactory).
- Authorize the instance of **SDKFactory** by using [auth(customerID:)](#sdkfactory-auth) method.
- Create an instance of [FrameFactory](#framefactory) by using [newFrameFactory()](#sdkfactory-newframefactory) method of **SDKFactory**.
- Create an instance of [Pipeline](#pipeline) by using [newPipeline()](#sdkfactory-newpipeline) method of **SDKFactory**.
- Enable background blur using [enableBlurBackground(power:)](#pipeline-enableblurbackground) method or background replacement using [enableReplaceBackground(controller:)](#pipeline-enableblurbackground) method of **Pipeline**.
- When the background replacement is enabled you can pass image which will be used as a background: [ReplacementController.background](#replacementcontroller-background)

Frame processing:
- Put your frame to [Frame](#frame) using [newFrame(format:data:bytesPerLine:width:height:makeCopy:)](#framefactory-newframe) method of [FrameFactory](#framefactory).
- Process it through [process(frame:error:)](#pipeline-process-frame) method of **Pipeline**.
- If your frame is [CVPixelBuffer](https://developer.apple.com/documentation/corevideo/cvpixelbuffer-q2e), you just can use [process(pixelBuffer:metalCompatible:error:)](#pipeline-process-pixelbuffer) method of **Pipeline**.

Performance tip: Prefer [process(pixelBuffer:metalCompatible:error:)](#pipeline-process-pixelbuffer) method and pass metal compatible CVPixelBuffer for better performance when Metal pipeline is active.


Use separate **Pipeline** instances per video stream.

```swift
init()
{
    super.init()
    
    let sdkFactory = SDKFactory()
    let authResult = try await sdkFactory.auth(customerID: "CUSTOMER_ID")
    if (authResult.status == .active) { 
        frameFactory = sdkFactory.newFrameFactory();
        pipeline = sdkFactory.newPipeline();
        pipeline.enableReplaceBackground(&backgroundController);
    }
    
    return self;
}
```

## Class Reference

### SDKFactory

<a id="sdkfactory-auth"></a>
```swift
func auth(customerID:String) async throws -> AuthResult
```
Performs authorization of the instance. **SDKFactory** can not be used until it's authorized.
Method performs https request to obtain license for customerID. Required internet connection.
Returns [AuthResult](#authresult)

Parameters: 
- **customerID:String** - Your unique customer id. See [Obtaining Effects SDK License](#obtaining-effects-sdk-license)

Example:
```swift
let authResult = try await sdkFactory.auth(customerID:"CUSTOMER_ID")
if (authResult.status == .active) {
    startVideoProcessing()
}
```
\"CUSTOMER_ID\" should be replaced by your id.

<a id="sdkfactory-newframefactory"></a>
```swift
func newFrameFactory() -> FrameFactory?
```
Creates new instance of [FrameFactory](#framefactory).

<a id="sdkfactory-newpipeline"></a>
```swift
func newPipeline() -> Pipeline?
```
Creates new instance of [Pipeline](#pipeline).

### AuthResult

```swift
var status:AuthStatus { get }
```
Holds result of authorization. See [AuthStatus](#enum-authstatus).

### enum FrameFormat 

- **rba32** - RGBA format with 8 bits per channel (32 bits per pixel).
- **bgra32** - BGRA format with 8 bits per channel (32 bits per pixel).

### enum Lock - Determines access to locked memory

- **read** 
- **write** 
- **readWrite** 

### FrameFactory

<a id="framefactory-newframe"></a>
```swift
func newFrame(format:FrameFormat, data:UnsafeMutableRawPointer, bytesPerLine:Uint32, width:Uint32, height:Uint32, makeCopy:Bool) -> Frame?
```
Creates [Frame](#frame) from raw RGBA or BGRA data. 

Parameters:
- **format:(FrameFormat)** - format of raw data.
- **data:UnsafeMutableRawPointer** - pointer at raw data.
- **bytesPerLine:Uint32** - number of bytes per line of frame.
- **width:Uint32** - number of pixels in horizontal direction.
- **height:Uint32** - number of pixels in vertical direction.
- **makeCopy:Bool** - if set to true - data will be copied, otherwise **Frame** will keep the pointer to data (DON'T release the data while it's processing).

```swift
func image(withContentOfFile:String) -> Frame?;
```

### Frame

```swift
var width:Uint32 { get }
```
Returns number of pixels in horizontal direction.

```swift
var height:Uint32 { get }
```
Returns number of pixels in vertical direction.

```swift
var format:FrameFormat { get }
```
Returns format of frame.

```swift
func lock:(_ lock: Lock) -> LockedFrameData?
```
Parameters:
- **lock:Lock** - Determines access to the memory. See [Lock](#lock)
Gets access to memory of the frame. 
Returns [LockedFrameData](#lockedframedata) protocol which provides ability to get pointers to internal data of **Frame** (DON’T use the **Frame** until **LockedFrameData** wasn’t released). 

```swift
func toCVPixelBuffer() -> CVPixelBuffer?;
```
Converts internal storage to [CVPixelBuffer](https://developer.apple.com/documentation/corevideo/cvpixelbuffer-q2e) and returns that reference if successful, otherwise returns nil. 
If internal storage is **CVPixelBuffer** already then returns that reference. Frame must not be used after toCVPixelBuffer() called.
When Metal pipeline is active the result of **process(_ frame:error:)** and **process(pixelBuffer:metalCompatible:error:)** is metal compatible.


### LockedFrameData 

Keeps access to the data inside Frame and returns pointers to that data.
If it was obtained with **lock(.write)** or  **lock(.readWrite):** , then the changes will be applied after LockedFrameData will be released. 
If it was obtained with **lock(.read)** then data must not be changed.

```swift
func dataPointer(ofPlanar:Int32) -> UnsafeMutableRawPointer?
```
Returns pointer to planar data. If the **Frame** created by **newFrame(format:data:bytesPerLine:width:height:makeCopy:)** where makeCopy was false then returns same pointer that was passed 
Parameters:
- **ofPlanar:Int32** - depends on frame format. For FrameFormat.rgba32 or FrameFormat.bgra32 always should be used 0. For FrameFormat.nv12  - 0 returns pointer to Y component, 1 returns pointer to UV component. 

```swift
func bytesPerLine(ofPlanar:Int32) -> Uint32;
```
Returns number of bytes per line.
Parameters:
- **ofPlanar:Int32** - see **dataPointer(ofPlanar:)**.

### PipelineErrorCode - error codes

- **ok** - success
- **invalidArgument** - one or more arguments are incorrect.
- **noFeaturesEnabled** - processing pipeline is not configured.
- **engineInitializationError** - can’t initialize OpenVINO, the hardware/software is not supported.
- **resourceAllocationError** -  not enough memory, disc space etc.

### Pipeline 

Configuration of effects and frame processor. Use separate instances for each video stream.

<a id="pipeline-setconfiguration"></a>
```swift
func setConfiguration(_ configuration: PipelineConfiguration) -> PipelineError
```
Parameters:
- **configuration: PipelineConfiguration**
Configures pipeline, determines what to use for image processing (see [PipelineConfiguration](#pipelineconfiguration)). This method is optional.

```swift
func copyConfiguration() -> PipelineConfiguration?
```
Returns a copy of current configuration of pipeline. Can be used to get an instance of [PipelineConfiguration](#pipelineconfiguration).

```swift
func copyDefaultConfiguration() -> PipelineConfiguration?
```
Returns a copy of the default configuration. Can be used to get an instance of [PipelineConfiguration](#pipelineconfiguration).

```swift
func enableBlurBackground(power: Float) -> PipelineError
```
Enables background blur.
Parameters:
- **power:Float** - power of blur from 0 to 1.

```swift
func disableBlurBackground()
```
Disables background blur.

<a id="pipeline-enableblurbackground"></a>
```swift
func enableReplaceBackground(_ controller:UnsafeMutablePointer<ReplacementController?>?) -> PipelineError
```
Enables background replacement, default background is transparent\. The custom image for the background could be set using the property ReplacementController.background\.
Parameters:
- **controller:UnsafeMutablePointer<ReplacementController?>?** - Pointer at variable to store an instance of [ReplacementController](#replacementcontroller). Can be nil. 
Example
```swift
var controller : ReplacementController? = nil
pipeline.enableReplaceBackground(&controller)
```

```swift
func disableReplaceBackground()
```
Disables background replacement.

```swift
-func enableDenoiseBackground() -> PipelineError
```
Enables video denoising. By default, denoises the background only; to denoise the foreground, set denoiseWithFace to YES.

```swift
-func disableDenoiseBackground()
```
Disables denoising.

```swift
var denoiseLevel: Float { get set };
```
Power of denoising: higher number = more visible effect.
Value from 0 to 1.

```swift
var denoiseWithFace: Bool { get set }
```
If YES, the pipeline denoises the background and foreground of the video. Otherwise, background only.
Default is NO.

```swift
func enabledBeautification() -> PipelineError
```
Enables face beautification. 

```swift
func disableBeautification()
```
Disables face beautification.

```swift
var beautificationLevel: Float { get set }
```
Could be from 0 to 1. Higher number \-\> more visible effect of beautification.

```swift
func enabledColorCorrection() -> PipelineError
```
Enables color correction. Improves colors with the help of ML.
Disables another enabled color correction effect.
Note: Preparation starts asynchronously after a frame process, the effect may be delayed.

```swift
func enabledColorCorrection(withReference:Frame) -> PipelineError
```
Enables color grading. Generates a color palette from reference and apply it to the video.
Parameters:
- **withReference:Frame** - The reference to generate a color palette.
If enabled, generates a new color palette with referenceFrame.
Disables another enabled color correction effect.

```swift
func enableColorCorrection(withLutFile:String) -> PipelineError
```
Enables color filtering with a Lookup Table (Lut).
Parameters:
- **withLutFile:String** - path to .cube file. Supports only 3D Lut with maximum size 256 (256x256x256).
If enabled, switches Lut.
Disables another enabled color correction effect.

```swift
func disableColorCorrection()
```
 Disables color correction.
 
```swift
func enabledSmartZoom() -> PipelineError
```
Enables smart zoom.

Smart Zoom crops around the face.

```swift
func disableSmartZoom()
```
 Disables smart zoom.

```swift
var smartZoomLevel: Float { get set }
```
could be from 0 to 1. Defines how much area should be filled by a face. Higher number \-\> more area. 

```swift
func enableSharpening() -> PipelineError
```
Enables sharpening effect. Sharpening makes the video look better by enhancing its clarity. It reduces blurriness in the video.  

```swift
func disableSharpening()
```
Disables sharpening effect.   

```swift
var sharpeningPower: Float { get set }
```
Current power of the sharpening effect. Power could be from 0 to 1. Higher number -> sharper result.

<a id="pipeline-process-frame"></a>
```swift
func process(_ frame: Frame, error: UnsafeMutablePointer<PipelineError>?) -> Frame?;
```
Returns processed frame the same format with input (with all effects applied). In case of error, returns nil.
Parameters:
- **frame: Frame** - frame for processing.
- **error: UnsafeMutablePointer<PipelineError>?** - nil or pointer at variable to store error.

<a id="pipeline-process-pixelbuffer"></a>
```swift
func process(pixelBuffer: CVPixelBuffer, metalCompatible: bool, error: UnsafeMutablePointer<PipelineError>?) -> Frame?
```
 Same as **process:error:** but expects [CVPixelBuffer](https://developer.apple.com/documentation/corevideo/cvpixelbuffer-q2e) as an argument. 

Parameters:
- **pixelBuffer: CVPixelBuffer** - CVPixelBuffer for processing.
- **metalCompatible: bool** - Set true if CVPixelBuffer is compatible with metal. 
- **error: UnsafeMutablePointer<PipelineError>?** - nil or pointer at variable to store error.

Recommended to use metal compatible **CVPixelBuffer**. The argument has not effect if CPU pipeline.
If you does not know *pixelBuffer* is metal compatible or not then set *metalCompatible* to false.
**CVPixelBuffer** received within [AVCaptureVideoDataOutputSampleBufferDelegate.captureOutput(_:didOutput:from:)](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate/captureoutput(_:didoutput:from:)) from [AVCaptureSession](https://developer.apple.com/documentation/avfoundation/avcapturesession) is metal compatible.

For manual creating, to create metal compatible **CVPixelBuffer**, set [kCVPixelBufferMetalCompatibilityKey](https://developer.apple.com/documentation/corevideo/kcvpixelbuffermetalcompatibilitykey) attribute.

 Supported formats:
- kCVPixelFormatType_32BGRA 
- kCVPixelFormatType_32RGBA
- kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
- kCVPixelFormatType_420YpCbCr8BiPlanarFullRange

### ReplacementController 

<a id="replacementcontroller-background"></a>
```swift
var background: Frame? { get set }
```
Holds custom image for background replacement. If nil then processing replaces background by transparency. To reset the background set nil.


### PipelineConfiguration

```swift
var backend : Backend { get set }
```
Determines pipeline that performs image processing.

```swift
var segmentationPreset: SegmentationPreset { get set }
```
Set the segmentation mode. Segmentation mode allow to choose combination of quality and speed of segmentation. Balanced mode is enabled by default.

<a id="is-segmentation-on-neural-engine-enabled"></a>
```swift
var isSegmentationOnNeuralEngineEnabled: bool { get set }
```
Determines Apple Neural Engine acceleration is enabled.
Has effect on system with Apple Neural Engine support.
If host system does not support Neural Engine then the setting is ignored.
Supported on Mac with M1 chips and newer. And iPhones of 2018 and newer. 

### enum Backend 

- **CPU** - CPU-based pipeline.
- **GPU** - GPU-based pipeline.

### enum SegmentationPreset

- **quality** - Quality is preferred.
- **balanced** - Balanced quality and speed.
- **speed** - Speed is preferred.
- **lightning** - Speed is prioritized.

### enum AuthStatus

- **active** - Authorization is succeeded and the license is active. SDK can be used to enhance your video.
- **inactive** - Authorization is failed because the license is deactivated or no such license.
- **expired** - Authorization is failed because the license is expired. Contact us to update it.