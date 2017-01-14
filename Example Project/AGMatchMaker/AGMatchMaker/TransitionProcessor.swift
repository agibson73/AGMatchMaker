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

class TransitionProcessor: NSObject {
    
    func retrieveAllViewsForAnimation(view:UIView)->[UIView]{
        return self.retrieveAllViews(view: view)
    }
    
    func retrieveAllViews(view:UIView) ->[UIView] {
        if view.subviews.count == 0{
            return []
        }
        var views = [UIView]()
        
        for vw in view.subviews{
            if vw.transitionID.isEmpty == false{
                views.append(vw)
            }
            
            views.append(contentsOf: self.retrieveAllViews(view: vw))
        }
        return views
    }
    
    
    func processTargetViews(fromTarget:UIView,toTarget:UIView,targets:[UIView])->(fromCopy:UIView,toCopy:UIView){
        
        
        let toRadius = toTarget.layer.cornerRadius
        let fromRadius = fromTarget.layer.cornerRadius

        toTarget.alpha = 1
        
        
        let fromBW = fromTarget.layer.borderWidth
        fromTarget.layer.cornerRadius = 0
        fromTarget.layer.borderWidth = 0
        let targetIDS = targets.map({$0.transitionID})
        let fromHolding =  self.retrieveAllViews(view: fromTarget).filter({targetIDS.contains($0.transitionID) && $0.transitionID.isEmpty == false})
        let _ = fromHolding.map({$0.alpha = 0})
        let fromCopy = fromTarget.snapshotView()!
        let _ = fromHolding.map({$0.alpha = 1})
        fromCopy.frame = fromTarget.frame
        fromTarget.layer.borderWidth = fromBW
        
        fromTarget.layer.cornerRadius = fromRadius
        fromCopy.layer.cornerRadius = fromRadius
        
        
        
        toTarget.layer.cornerRadius = 0
        let toBorderWidth = toTarget.layer.borderWidth
        toTarget.layer.borderWidth = 0
        
        let toHolding =  self.retrieveAllViews(view: toTarget).filter({targetIDS.contains($0.transitionID) && $0.transitionID.isEmpty == false})
        let _ = toHolding.map({$0.alpha = 0})
        let toCopy = toTarget.snapshotView()!
        toTarget.layer.cornerRadius = toRadius
        toTarget.layer.borderWidth = toBorderWidth
        toCopy.frame = fromTarget.frame
        toCopy.layer.cornerRadius = fromRadius
       
        
        
        fromTarget.alpha = 0
        toTarget.alpha = 0
        toCopy.alpha = 0.5
        
        return(fromCopy:fromCopy,toCopy:toCopy)
        
    }
    
    func createBasicAnimations(copyFrom:UIView,copyTo:UIView,duration:Double)->CAAnimationGroup{
        let keypaths = ["cornerRadius","borderColor","borderWidth","transform","shadowRadius","shadowColor","shadowOpacity","shadowOffset","backgroundColor","zIndex"]
        
        let animationGroup = CAAnimationGroup()
        var caAnimations = [CABasicAnimation]()
        for keypath in keypaths{
            if copyFrom.layer.value(forKeyPath: keypath) != nil && copyTo.layer.value(forKeyPath: keypath) != nil{
                caAnimations.append(createBasicAnimationForKeyPath(keypath:keypath,copyFrom: copyFrom, copyTo: copyTo,duration:duration))
            }
            
        }
        
        animationGroup.animations = caAnimations
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.duration = duration
        animationGroup.beginTime = CACurrentMediaTime()
        return animationGroup
        
    }
    
    func createBasicAnimationForKeyPath(keypath:String,copyFrom:UIView,copyTo:UIView,duration:Double)->CABasicAnimation{
        let animation = CABasicAnimation(keyPath: keypath)
        animation.fromValue = copyFrom.layer.value(forKeyPath: keypath)
        animation.toValue = copyTo.layer.value(forKeyPath: keypath)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        return animation
    }
    
    //MARK: Helpers (some may be unused at this point)
    func cleanUpTargets(targets:[UIView]){
        
        for target in targets{
            //get all subs of the target and clean up items in cells
            if self.isInsideCell(view: target){
                target.transitionID = ""
            }
            
        }
    }
    
    func isInsideCell(view:UIView?)->Bool{
        if view is UITableViewCell{
            return true
        }
        var vw = view
        while vw != nil{
            vw = getSuperView(view: vw)
            if vw is UITableViewCell{
                return true
            }
        }
        return false
    }
    
    func isInsideInTarget(view:UIView?,targets:[UIView])->Bool{
        if view is UITableViewCell{
            return true
        }
        var vw = view
        while vw != nil{
            vw = getSuperView(view: vw)
            if targets.contains(view!){
                return true
            }
        }
        return false
    }
    
    func getSuperView(view:UIView?)->UIView?{
        if view != nil{
            return view?.superview
        }
        
        return nil
    }
    
 
}
