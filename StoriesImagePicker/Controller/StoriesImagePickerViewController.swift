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

public protocol StoriesImagePickerViewControllerDelegate {
    func storiesImagePickerDidFinish(_ picker: StoriesImagePickerViewController, selectedAssets: [Asset])
}

public class StoriesImagePickerViewController: UITabBarController {
    
    private enum Tab: Int {
        case stories
        case browse
        case instagram
        case facebook
    }
    
    public static var maximumAllowedAssets: Int = Int.max
    public static var minimumRequiredAssets: Int = 0
    
    private var isFacebookEnabled = false
    private var isInstagramEnabled: Bool {
        return InstagramClient.isInstagramEnabled()
    }
    
    var pickerDelegate: StoriesImagePickerViewControllerDelegate?
    
    
    /// Use this method to create a StoriesImagePickerViewController instance
    ///
    /// - Parameter delegate: A delete object to respond to events
    /// - Returns: An instance of StoriesImagePickerViewController that you can present from your ViewController
    public static func instance(delegate: StoriesImagePickerViewControllerDelegate) -> StoriesImagePickerViewController {
        let picker = storiesImagePickerMainStoryboard.instantiateViewController(withIdentifier: "StoriesImagePickerViewController") as! StoriesImagePickerViewController
        picker.pickerDelegate = delegate
        return picker
    }
    
    
    /// Set to enable Facebook in the image picker. Make sure it is set up properly and you have supplied the Facebook app id. Please look at Facebook's documentation for further details.
    ///
    /// - Parameter enabled: Set to true to enable
    public func setFacebookEnabled(_ enabled: Bool) {
        isFacebookEnabled = enabled
    }
    
    
    /// Set to enable Instagram in the image picker. Please look at Instagram's documentation for further details.
    ///
    /// - Parameters:
    ///   - clientId: Your Instagram app's clientId
    ///   - secret: Your Instagram app's secret
    ///   - redirectUri: Your Instagram app's redirectUri
    public func setInstagramEnabled(clientId: String?, secret: String?, redirectUri: String?) {
        InstagramClient.Constants.clientId = clientId
        InstagramClient.Constants.secret = secret
        InstagramClient.Constants.redirectUri = redirectUri
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ status in
                DispatchQueue.main.async {
                    self.configureTabBarController()
                }
            })
            return
        }
        
        configureTabBarController()
    }
    
    private func configureTabBarController() {
        
        // Browse
        // Set the albumManager to the AlbumsCollectionViewController
        let albumViewController = (viewControllers?[Tab.browse.rawValue] as? UINavigationController)?.topViewController as? AlbumsCollectionViewController
        albumViewController?.albumManager = PhotosAlbumManager()
        
        // Stories
        // If there are no stories, remove the stories tab
        StoriesManager.shared.loadTopStories(completionHandler: {
            if StoriesManager.shared.stories.isEmpty {
                self.viewControllers?.remove(at: Tab.stories.rawValue)
            }
        })
        
        // Facebook
        if !isFacebookEnabled {
            self.viewControllers?.remove(at: Tab.facebook.rawValue)
        }
        
        // Instagram
        if !isInstagramEnabled {
            self.viewControllers?.remove(at: Tab.instagram.rawValue)
        }
    }
    
}
