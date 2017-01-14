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
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
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
            v.layer.masksToBounds = true
            return v
        } else {
            return nil
        }
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
