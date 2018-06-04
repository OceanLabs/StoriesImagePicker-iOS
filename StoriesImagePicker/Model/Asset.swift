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

enum AssetLoadingException: Error {
    case notFound
    case unsupported
}

@objc public enum AssetDataFileExtension: Int {
    case unsupported
    case jpg
    case png
    case gif
}

/// Represents a photo used in the picker
@objc public protocol Asset {
    
    /// Identifier
    var identifier: String! { get }
    
    /// Album Identifier
    var albumIdentifier: String? { get }
    
    /// Size
    var size: CGSize { get }
    
    /// Date
    var date: Date? { get }
    
    /// Request the image that this asset represents.
    ///
    /// - Parameters:
    ///   - size: The requested image size in points. Depending on the asset type and source this size may just a guideline
    ///   - loadThumbnailFirst: Whether thumbnails get loaded first before the actual image. Setting this to true will result in the completion handler being executed multiple times
    ///   - progressHandler: Handler that returns the progress, for a example of a download
    ///   - completionHandler: The completion handler that returns the image
    func image(size: CGSize, loadThumbnailFirst: Bool, progressHandler: ((_ downloaded: Int64, _ total: Int64) -> Void)?, completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void)
    
    /// Request the data representation of this asset
    ///
    /// - Parameters:
    ///   - progressHandler: Handler that returns the progress, for a example of a download
    ///   - completionHandler: The completion handler that returns the data
    func imageData(progressHandler: ((_ downloaded: Int64, _ total: Int64) -> Void)?, completionHandler: @escaping (_ data: Data?, _ fileExtension: AssetDataFileExtension, _ error: Error?) -> Void)
}

func ==(lhs: Asset, rhs: Asset) -> Bool{
    return lhs.identifier == rhs.identifier && lhs.albumIdentifier == rhs.albumIdentifier
}
