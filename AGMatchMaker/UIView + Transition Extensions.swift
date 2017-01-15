////  AGMatchMakerTransition
// The MIT License (MIT)
//
// Copyright © 2017 Alex Gibson.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public extension UIView {

    public func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else{ return nil}
        context.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
        self.layoutIfNeeded()
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public func snapshotView() -> UIView? {


        if let snapshotImage = snapshotImage() {
            let v = UIImageView(image: snapshotImage)
            v.bounds = self.bounds
            v.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            v.layer.masksToBounds = true
            return v
        } else {
            return nil
        }
    }
    
    /**
     - Returns: a snapshot view for animation
     */
    public func snapshotViewWithLayers() -> UIView {
        
        self.alpha = 1
        // capture a snapshot without cornerRadius
        let oldCornerRadius = self.layer.cornerRadius
        self.layer.cornerRadius = 0
        let oldBorderWidth = self.layer.borderWidth
        self.layer.borderWidth = 0
        
        
        let CV = self.snapshotView()!
        CV.translatesAutoresizingMaskIntoConstraints = true
        let snapshot = UIView(frame: self.frame)
        snapshot.bounds = self.bounds
        snapshot.addSubview(CV)
        self.layer.cornerRadius = oldCornerRadius
        self.layer.borderWidth = oldBorderWidth
        // the Snapshot's contentView must have hold the cornerRadius value,
        // since the snapshot might not have maskToBounds set
        let contentView = snapshot.subviews[0]
        contentView.layer.cornerRadius = self.layer.cornerRadius
        contentView.layer.masksToBounds = true
        
        snapshot.layer.cornerRadius = self.layer.cornerRadius
        snapshot.layer.zPosition = self.layer.zPosition
        snapshot.layer.opacity = layer.opacity
        snapshot.layer.isOpaque = layer.isOpaque
        snapshot.layer.anchorPoint = layer.anchorPoint
        snapshot.layer.masksToBounds = layer.masksToBounds
        snapshot.layer.borderColor = layer.borderColor
        snapshot.layer.borderWidth = layer.borderWidth
        snapshot.layer.transform = layer.transform
        snapshot.layer.shadowRadius = layer.shadowRadius
        snapshot.layer.shadowOpacity = layer.shadowOpacity
        snapshot.layer.shadowColor = layer.shadowColor
        snapshot.layer.shadowOffset = layer.shadowOffset
        
        return snapshot
    }

    
}

// this is to allow identifiers in storyboard
import ObjectiveC
private var transitionIdentifierAssociationKey:String = "TransitionIdentifier"

public extension UIView{
    
    private struct AssociatedKeys {
        static var transitionID = "TransitionIdentifier"
    }

    //this lets us check to see if the item is supposed to be displayed or not
    @IBInspectable var transitionID : String {
        get {
            guard let identifier = objc_getAssociatedObject(self, &AssociatedKeys.transitionID) as? String else {
                return ""
            }
            return identifier
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.transitionID,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

internal extension CALayer{
    // return all animations running by this layer.
    // the returned value is mutable
    var animations:[(String, CAAnimation)]{
        if let keys = animationKeys(){
            return keys.map{ return ($0, self.animation(forKey: $0)!.copy() as! CAAnimation) }
        }
        return []
    }
}
