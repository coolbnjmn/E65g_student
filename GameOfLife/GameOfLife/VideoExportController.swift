//
//  VideoExportController.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/6/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit
import AVFoundation

extension UIView {
    func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class VideoExportController: NSObject {
    static func makeVideoFromGrid(_ inputGrid: Grid, withDesiredLength videoLength: Double = 10, andRefreshRate hzRate: Double = 1, _ completion: @escaping ((UIActivityViewController?) -> Void)) {
        let gridView: GridView = GridView(frame: CGRect(x: 0, y: 0, width: Constants.Defaults.defaultVideoOutputSize, height: Constants.Defaults.defaultVideoOutputSize))
        gridView.origin = .videoGeneration
        GridEditorEngine.videoEngine.grid = inputGrid
        var outputFrames = [UIImage]()
        // refreshRate == hz = (1/s)
        // videoLength == s
        // if FPS == refreshRate, hz == FPS
        // frameCount = FPS * length = refreshRate * videoLength
        let rate = hzRate == 0 ? 1 : hzRate
        for _ in 0..<(Int(rate * videoLength)) {
            gridView.setNeedsDisplay()
            gridView.layoutSubviews()
            if let image = gridView.capture() {
                outputFrames.append(image)
            }
            GridEditorEngine.videoEngine.grid = gridView.grid.next()
            gridView.invalidateIntrinsicContentSize()
        }
        
        VideoExportController.buildVideoFromFrames(outputFrames, outputSize: CGSize(width: Constants.Defaults.defaultVideoOutputSize, height: Constants.Defaults.defaultVideoOutputSize), fps: Int(rate), {
            success, filePath in
            if let fileURL = filePath, success {
                completion(UIActivityViewController(activityItems: [fileURL], applicationActivities: nil))
            } else {
                completion(nil)
            }
        })
    }
    
    /**
     Function heavily derived from:
     http://stackoverflow.com/questions/28968322/how-would-i-put-together-a-video-using-the-avassetwriter-in-swift
     */
    static func buildVideoFromFrames(_ frames: [UIImage], outputSize: CGSize, fps: Int, _ completion: @escaping ((_ success: Bool, _ filePath: URL?) -> Void)) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let outputSettings: [String: Any] = [AVVideoCodecKey : AVVideoCodecH264,
                                             AVVideoWidthKey : NSNumber(value: Float(outputSize.width)),
                                             AVVideoHeightKey : NSNumber(value: Float(outputSize.height))]

        guard let documentDirectory: URL = urls.first else {
            fatalError("documentDir Error")
        }
        
        var fileID: Int = 0
        let gridVideoSubfolder = documentDirectory.appendingPathComponent("gameOfLifeVideos", isDirectory: true)
        var videoOutputURL = gridVideoSubfolder.appendingPathComponent("gridVideo-\(fileID).mp4")
        while FileManager.default.fileExists(atPath: videoOutputURL.path) {
            fileID += 1
            videoOutputURL = gridVideoSubfolder.appendingPathComponent("gridVideo-\(fileID).mp4")
        }
        
        guard let videoWriter = try? AVAssetWriter(outputURL: videoOutputURL, fileType: AVFileTypeMPEG4),
            videoWriter.canApply(outputSettings: outputSettings, forMediaType: AVMediaTypeVideo) else {
            fatalError("AVAssetWriter error")
        }
        
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
        let sourcePixelBufferAttributesDictionary = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32ARGB), kCVPixelBufferWidthKey as String: NSNumber(value: Float(outputSize.width)), kCVPixelBufferHeightKey as String: NSNumber(value: Float(outputSize.height))]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        
        var mutableFrames = frames
        
        if videoWriter.startWriting() {
            videoWriter.startSession(atSourceTime: kCMTimeZero)
            assert(pixelBufferAdaptor.pixelBufferPool != nil)
            
            let media_queue = DispatchQueue.global(qos: .background)
            
            videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: { () -> Void in
                let frameDuration = CMTimeMake(1, Int32(fps))
                
                var frameCount: Int64 = 0
                var appendSucceeded = true
                
                while (!mutableFrames.isEmpty) {
                    if (videoWriterInput.isReadyForMoreMediaData) {
                        let nextPhoto = mutableFrames.remove(at: 0)
                        let lastFrameTime = CMTimeMake(frameCount, Int32(fps))
                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                        
                        var pixelBuffer: CVPixelBuffer? = nil
                        let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferAdaptor.pixelBufferPool!, &pixelBuffer)
                        
                        if let pixelBuffer = pixelBuffer, status == 0 {
                            let managedPixelBuffer = pixelBuffer
                            
                            CVPixelBufferLockBaseAddress(managedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
                            
                            let data = CVPixelBufferGetBaseAddress(managedPixelBuffer)
                            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
                            let context = CGContext(data: data, width: Int(outputSize.width), height: Int(outputSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(managedPixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
                            
                            context?.clear(CGRect(x: 0, y: 0, width: CGFloat(outputSize.width), height: CGFloat(outputSize.height)))
                            
                            let horizontalRatio = CGFloat(outputSize.width) / nextPhoto.size.width
                            let verticalRatio = CGFloat(outputSize.height) / nextPhoto.size.height
                            //aspectRatio = max(horizontalRatio, verticalRatio) // ScaleAspectFill
                            let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
                            
                            let newSize: CGSize = CGSize(width: nextPhoto.size.width * aspectRatio, height: nextPhoto.size.height * aspectRatio)
                            
                            let x = newSize.width < outputSize.width ? (outputSize.width - newSize.width) / 2 : 0
                            let y = newSize.height < outputSize.height ? (outputSize.height - newSize.height) / 2 : 0
                            
                            if let cgImage = nextPhoto.cgImage {
                                context?.draw(cgImage, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
                            }
                            CVPixelBufferUnlockBaseAddress(managedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
                            
                            appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                        } else {
                            print("Failed to allocate pixel buffer")
                            appendSucceeded = false
                        }
                    }
                    if !appendSucceeded {
                        break
                    }
                    frameCount += 1
                }
                videoWriterInput.markAsFinished()
                videoWriter.finishWriting { () -> Void in
                    completion(true, videoOutputURL)
                }
            })
        }
    }

}
