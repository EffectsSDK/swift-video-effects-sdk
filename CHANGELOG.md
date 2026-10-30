# Changelog

## 2.6.0 - 2026-10-29

### `Pipeline` and `ReplacementController` are thread-safe

Any method may be called from any thread without synchronization, except that only one of the [`process`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/process(_:error:)) methods of a [`Pipeline`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline) may run at a time. [`ReplacementController.background`](https://effectssdk.ai/sdk/ios/documentation/tsvb/replacementcontroller/background) may be set from any thread. Loading a model no longer holds up `process`.
Enabling an effect may take a while (it may load a model), so avoid calling `enable*` methods on the main thread. Parameter setters such as `colorCorrection.power` are cheap.

### Effects

- New feature `Noise Suppression`: improves video quality by reducing grainy noise in the video and keeps noisy regions stable instead of letting them shimmer from frame to frame. See [`enableNoiseSuppression`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enablenoisesuppression()).
- New feature `Portrait Lighting`: highlights the person in the video, with separate controls of the light strength and of the background darkening. See [`enablePortraitLighting`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enableportraitlighting()) and [`portraitLighting`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/portraitlighting) ([`PortraitLightingSettings`](https://effectssdk.ai/sdk/ios/documentation/tsvb/portraitlightingsettings)).
- Reworked `Background Blur`: faster and aligned with the Web SDK.
- Reworked `Beautification`.
- Reworked `Color Correction` for more natural results: automatic scene analysis adapts the image to the lighting and color balance, and manual controls of white balance, exposure, temperature, tint, vibrance and contrast fine-tune it. See [`colorCorrection`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/colorcorrection) ([`ColorCorrectionSettings`](https://effectssdk.ai/sdk/ios/documentation/tsvb/colorcorrectionsettings)).
- Reworked `Low Light`: brightens dark scenes without an ML model.

### Changes

- New segmentation models, better and faster.
- Added the ability to create a `Frame` with a `CVPixelBuffer`, see [`FrameFactory.newFrame(pixelBuffer:metalCompatible:)`](https://effectssdk.ai/sdk/ios/documentation/tsvb/framefactory/newframe(pixelbuffer:metalcompatible:)).
- Improved performance of [`ReplacementController.background`](https://effectssdk.ai/sdk/ios/documentation/tsvb/replacementcontroller/background): a `CVPixelBuffer` background is used by Metal directly, without a copy, when possible; other frames are converted once per change.
- The Metal pipeline supports RGBA frames created from memory; the processed frame is in memory too, its `toCVPixelBuffer` returns nil.
- The color range and the color matrix (BT.601, BT.709) of a frame are taken from its `CVPixelBuffer`.
- Core ML may run segmentation on the GPU too, enabled by default. To keep the CPU and the Neural Engine only, set [`isSegmentationOnGPUEnabled`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipelineconfiguration/issegmentationongpuenabled) to false.
- Frame memory is re-used now: the processed frames come from a `CVPixelBufferPool`.
- New error codes in `PipelineError`: `notSupportedByBackend`, `enabledUnsupportedFeatures` and `invalidUsage`.
- Added [`enableNoiseSuppression`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enablenoisesuppression()), [`enablePortraitLighting`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enableportraitlighting()), effect settings as typed properties [`colorCorrection`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/colorcorrection) ([`ColorCorrectionSettings`](https://effectssdk.ai/sdk/ios/documentation/tsvb/colorcorrectionsettings)) and [`portraitLighting`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/portraitlighting) ([`PortraitLightingSettings`](https://effectssdk.ai/sdk/ios/documentation/tsvb/portraitlightingsettings)), and [`isSegmentationOnGPUEnabled`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipelineconfiguration/issegmentationongpuenabled).
- Added read-only [`isBlurBackgroundEnabled`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/isblurbackgroundenabled), [`blurBackgroundPower`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/blurbackgroundpower) and [`isReplaceBackgroundEnabled`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/isreplacebackgroundenabled).
- The API reference is available at https://effectssdk.ai/sdk/ios/documentation/tsvb/.
- Removed excess dependencies and improved model packing: the framework is much smaller. `TSVB.framework` for devices (arm64): 14.2 MB to 2.9 MB; the package download: 36.6 MB to 7.3 MB.

### Breaking changes

- Misspelled [`enableColorCorrectionWithReferance`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enablecolorcorrection(withreferance:)) deprecated. Use [`enableColorCorrectionWithReference`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enablecolorcorrection(withreference:)).
- Removed the `speed` and `lightning` values of [`SegmentationPreset`](https://effectssdk.ai/sdk/ios/documentation/tsvb/segmentationpreset).
- Removed the old background denoise effect, replaced by `Noise Suppression`: `enableDenoiseBackground`, `disableDenoiseBackground`, `denoisePower` and `denoiseWithFace`.
- `Beautification`, `Color Correction`, `Low Light` do not work on CPU anymore: enabling them on the CPU backend returns `notSupportedByBackend`. Code that checked for `engineInitializationError` there has to check for `notSupportedByBackend` now.
- [`ReplacementController.background`](https://effectssdk.ai/sdk/ios/documentation/tsvb/replacementcontroller/background) does not copy the frame anymore: don't release a frame created with `makeCopy` false while it is the background.
- Obj-C, manual reference counting: `enableReplaceBackground:` releases the value its out-parameter held before, as a `__strong` out-parameter should: pass a variable set to nil, not an uninitialized one. ARC and Swift are not affected.
- The bundle identifier of `TSVB.framework` is `com.effectssdk.SDK` now: code that looks the framework up by its identifier has to use the new one.

### Fixes

- `enableReplaceBackground` and `disableReplaceBackground` called from several threads at once could crash or leak.
- Fixed a socket leak on each authorization request.
- `Color Filter` and `Color Grading`: wrong colors for a few frames after changing the LUT or switching from CPU to GPU backend.
- `Frame.lock` on the background image during `process` could get a cleared data pointer.
- [`await factory.auth(customerID:)`](https://effectssdk.ai/sdk/ios/documentation/tsvb/sdkfactory/auth(customerid:completionhandler:)) never returned when authorization failed before the web request.
- Fixed memory leaks in [`newPipeline`](https://effectssdk.ai/sdk/ios/documentation/tsvb/sdkfactory/newpipeline()), failed authorization and [`enableReplaceBackground`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/enablereplacebackground(_:)).
- [`colorCorrectionPower`](https://effectssdk.ai/sdk/ios/documentation/tsvb/pipeline/colorcorrectionpower) returns the actual value.
- [`newFrame(format:...)`](https://effectssdk.ai/sdk/ios/documentation/tsvb/framefactory/newframe(format:data:bytesperline:width:height:makecopy:)) with NV12 returns nil instead of reading invalid memory; pass NV12 as `CVPixelBuffer`.
- `toCVPixelBuffer` and processing a `CVPixelBuffer` return nil instead of crashing when memory runs out.

### Sample

The iOS Swift sample is updated: Portrait Lighting, Noise Suppression, Color Grading by a reference image and a LUT Color Filter, no locks around the pipeline, and metrics of the processing time and the CPU usage.

## 2.5.1 - 2025-05-28

- Fixed Color Grading.
- Added the ability to pass a custom server URL.

## 2.5.0 - 2025-05-27

- Added the ability to pass a frame with rotation (90°, 180°, 270°) and to load an image from an in-memory buffer.

## 2.4.2 - 2025-05-21

- Added the arm64 iOS Simulator.

## 2.4.1 - 2025-05-19

- Fixed creation of `TSVBFrame` with raw image data.

## 2.4.0 - 2025-04-28

- Added offline authorization.

## 2.3.0 - 2024-11-22

- Added support of the Neural Engine.
- New supported `CVPixelBuffer` formats.
- Faster Background Blur.
- Support of Metal-compatible `CVPixelBuffer`.
