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

class StoriesImagePickerNavigationBar: UINavigationBar {
    
    private static let contentHeight: CGFloat = 44.0
    private static let promptHeight: CGFloat = 34.0
    
    private var hasAddedBlur = false
    private var effectView: UIVisualEffectView!
    private(set) var barType: StoriesImagePickerNavigationBarType = .white
    
    var willShowPrompt = false {
        didSet {
            if #available(iOS 11.0, *) {
                prefersLargeTitles = !willShowPrompt
            }
        }
    }
    
    var barHeight: CGFloat {
        return willShowPrompt ? StoriesImagePickerNavigationBar.contentHeight + StoriesImagePickerNavigationBar.promptHeight : StoriesImagePickerNavigationBar.contentHeight + UIApplication.shared.statusBarFrame.height
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !hasAddedBlur {
            hasAddedBlur = true
            
            let effectViewY = willShowPrompt ? 0.0 : -UIApplication.shared.statusBarFrame.height
            effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            effectView.frame = CGRect(x: 0.0, y: effectViewY, width: bounds.width, height: barHeight)
            effectView.backgroundColor = UIColor(white: 1.0, alpha: 0.75)
            effectView.isUserInteractionEnabled = false
            insertSubview(effectView, at: 0)
        }
        sendSubview(toBack: effectView)
    }
    
    private func setup() {
        barTintColor = .white
        
        if #available(iOS 11.0, *) {
            prefersLargeTitles = true
        }
        
        setBackgroundImage(UIImage(color: .clear), for: .default)
        shadowImage = UIImage()
    }
    
    func setBarType(_ type: StoriesImagePickerNavigationBarType) {
        barType = type
        
        switch barType {
        case .clear:
            barTintColor = .clear
            effectView.alpha = 0.0
        case .white:
            barTintColor = .white
            effectView.alpha = 1.0
        }
    }    
}

/// Navigation bar configurations
///
/// - clear: A transparent bar
/// - white: A semi-transparent white tinted bar with a blur effect
enum StoriesImagePickerNavigationBarType {
    case clear, white
}

/// Protocol view controllers should conform to in order to choose an appearance from application defaults when presented
protocol StoriesImagePickerNavigationBarDelegate {
    var storiesImagePickerNavigationBarType: StoriesImagePickerNavigationBarType { get }
}

extension StoriesImagePickerNavigationBar: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool){
        
        if let viewController = viewController as? StoriesImagePickerNavigationBarDelegate {
            setBarType(viewController.storiesImagePickerNavigationBarType)
            return
        }
        setBarType(.white)
    }
}
