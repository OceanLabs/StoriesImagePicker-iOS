//
//  MIT License
//
//  Copyright (c) 2010-2018 Kite Tech Ltd. https://www.kite.ly
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import Photos

protocol AssetManager {
    func fetchAsset(withLocalIdentifier identifier: String, options: PHFetchOptions?) -> PHAsset?
    func fetchAssets(in: PHAssetCollection, options: PHFetchOptions) -> PHFetchResult<PHAsset>
}

class DefaultAssetManager: AssetManager {
    func fetchAsset(withLocalIdentifier identifier: String, options: PHFetchOptions?) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: options).firstObject
    }
    
    func fetchAssets(in assetCollection: PHAssetCollection, options: PHFetchOptions) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: assetCollection, options: options)
    }
}

/// Photo library resource that can be used in a Photobook
@objc public class PhotosAsset: NSObject, NSCoding, Asset {
    
    /// Photo library asset
    @objc internal(set) public var photosAsset: PHAsset {
        didSet {
            identifier = photosAsset.localIdentifier
        }
    }
    
    /// Identifier for the album where the asset is included
    @objc internal(set) public var albumIdentifier: String?
    
    var imageManager = PHImageManager.default()
    static var assetManager: AssetManager = DefaultAssetManager()
    
    internal(set) public var identifier: String! {
        didSet {
            if photosAsset.localIdentifier != identifier,
               let asset = PhotosAsset.assetManager.fetchAsset(withLocalIdentifier: identifier, options: PHFetchOptions()) {
                    photosAsset = asset
            }
        }
    }
    
    public var date: Date? {
        return photosAsset.creationDate
    }

    public var size: CGSize { return CGSize(width: photosAsset.pixelWidth, height: photosAsset.pixelHeight) }
    
    /// Init
    ///
    /// - Parameters:
    ///   - photosAsset: Photo library asset
    ///   - albumIdentifier: Identifier for the album where the asset is included
    @objc public init(_ photosAsset: PHAsset, albumIdentifier: String?) {
        self.photosAsset = photosAsset
        self.albumIdentifier = albumIdentifier
        identifier = photosAsset.localIdentifier
    }
    
    public func image(size: CGSize, loadThumbnailFirst: Bool = true, progressHandler: ((Int64, Int64) -> Void)?, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        
        // Request the image at the correct aspect ratio
        var imageSize = self.size.resizeAspectFill(size)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = loadThumbnailFirst ? .opportunistic : .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        
        // Convert points to pixels
        imageSize = CGSize(width: imageSize.width * UIScreen.main.usableScreenScale(), height: imageSize.height * UIScreen.main.usableScreenScale())
        DispatchQueue.global(qos: .background).async {
            self.imageManager.requestImage(for: self.photosAsset, targetSize: imageSize, contentMode: .aspectFill, options: options) { (image, _) in
                DispatchQueue.main.async {
                    completionHandler(image, nil)
                }
            }
        }
    }
    
    public func imageData(progressHandler: ((Int64, Int64) -> Void)?, completionHandler: @escaping (Data?, AssetDataFileExtension, Error?) -> Void) {
        
        if photosAsset.mediaType != .image {
            completionHandler(nil, .unsupported, AssetLoadingException.notFound)
            return
        }
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        self.imageManager.requestImageData(for: photosAsset, options: options, resultHandler: { imageData, dataUti, _, _ in
            guard let data = imageData, let dataUti = dataUti else {
                completionHandler(nil, .unsupported, AssetLoadingException.notFound)
                return
            }
            
            let fileExtension: AssetDataFileExtension
            if dataUti.contains(".png") {
                fileExtension = .png
            } else if dataUti.contains(".jpeg") {
                fileExtension = .jpg
            } else if dataUti.contains(".gif") {
                fileExtension = .gif
            } else {
                fileExtension = .unsupported
            }
            
            // Check that the image is either jpg, png or gif otherwise convert it to jpg. So no HEICs, TIFFs or RAWs get uploaded to the back end.
            if fileExtension == .unsupported {
                guard let ciImage = CIImage(data: data),
                    let jpegData = CIContext().jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [kCGImageDestinationLossyCompressionQuality : 0.8])
                else {
                    completionHandler(nil, .unsupported, AssetLoadingException.unsupported)
                    return
                }
                completionHandler(jpegData, .jpg, nil)
            } else {
                completionHandler(imageData, fileExtension, nil)
            }
        })
    }
        
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(albumIdentifier, forKey: "albumIdentifier")
        aCoder.encode(identifier, forKey: "identifier")
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        guard let assetId = aDecoder.decodeObject(of: NSString.self, forKey: "identifier") as String?,
              let albumIdentifier = aDecoder.decodeObject(of: NSString.self, forKey: "albumIdentifier") as String?,
              let asset = PhotosAsset.assetManager.fetchAsset(withLocalIdentifier: assetId, options: nil) else
            { return nil }
            
        self.init(asset, albumIdentifier: albumIdentifier)
    }
    
    static func photosAssets(from assets:[Asset]) -> [PHAsset] {
        var photosAssets = [PHAsset]()
        for asset in assets{
            guard let photosAsset = asset as? PhotosAsset else { continue }
            photosAssets.append(photosAsset.photosAsset)
        }
        
        return photosAssets
    }
    
    static func assets(from photosAssets: [PHAsset], albumId: String) -> [Asset] {
        var assets = [Asset]()
        for photosAsset in photosAssets {
            assets.append(PhotosAsset(photosAsset, albumIdentifier: albumId))
        }
        
        return assets
    }
    
    @objc public func wasRemoved(in changeInstance: PHChange) -> Bool {
        if let changeDetails = changeInstance.changeDetails(for: photosAsset),
            changeDetails.objectWasDeleted {
            return true
        }
        return false
    }
}
