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

/// Image resource based on a UIImage that can be used in a photo book

import UIKit

@objc public class ImageAsset: NSObject, NSCoding, Asset {
    
    /// Image representation of the asset
    @objc internal(set) public var image: UIImage
    
    /// Date associated with this asset
    @objc internal(set) public var date: Date? = nil
    
    public var identifier = UUID().uuidString
    public var albumIdentifier: String? = nil
    public var size: CGSize { return image.size }

    /// Init
    ///
    /// - Parameters:
    ///   - image: Image representation of the asset
    ///   - date: Associated date
    @objc public init(image: UIImage, date: Date? = nil) {
        self.image = image
        self.date = date
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        
        let imageData = NSKeyedArchiver.archivedData(withRootObject: image)
        aCoder.encode(imageData, forKey: "image")
        aCoder.encode(date, forKey: "date")
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        guard let imageData = aDecoder.decodeObject(of: NSData.self, forKey: "image") as Data?,
              let image = NSKeyedUnarchiver.unarchiveObject(with: imageData) as? UIImage else {
            return nil
        }
        
        self.init(image: image)
        self.identifier = aDecoder.decodeObject(of: NSString.self, forKey: "identifier")! as String
        self.date = aDecoder.decodeObject(of: NSDate.self, forKey: "date") as Date?
        
    }

    public func image(size: CGSize, loadThumbnailFirst: Bool, progressHandler: ((Int64, Int64) -> Void)?, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        completionHandler(image, nil)
    }
    
    public func imageData(progressHandler: ((Int64, Int64) -> Void)?, completionHandler: @escaping (Data?, AssetDataFileExtension, Error?) -> Void) {
        let data = UIImageJPEGRepresentation(image, 0.8)
        completionHandler(data, .jpg, nil)
    }
}
