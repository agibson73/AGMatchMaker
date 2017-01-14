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
        
        for vw in view.subviews.reversed(){
            views.append(contentsOf: self.retrieveAllViews(view: vw))
            if vw.transitionID.isEmpty == false{
                views.append(vw)
            }
        }
        return views
    }
    
    
    func processTargetViews(fromTarget:UIView,toTarget:UIView,targets:[UIView])->(fromCopy:UIView,toCopy:UIView){
        let fromRadius = fromTarget.layer.cornerRadius

        let targetIDS = targets.map({$0.transitionID})
        let fromTargetViews = self.retrieveAllViews(view: fromTarget)
        let toTargetsSubViews = self.retrieveAllViews(view: toTarget)
        
        let fromHolding =  fromTargetViews.filter({targetIDS.contains($0.transitionID) && $0.transitionID.isEmpty == false})
        let _ = fromHolding.map({$0.alpha = 0})
        
        
        
        let fromCopy = fromTarget.snapshotViewWithLayers()
        let _ = fromHolding.map({$0.alpha = 1})
        fromCopy.frame = fromTarget.frame
        
        let toHolding =  toTargetsSubViews.filter({targetIDS.contains($0.transitionID) && $0.transitionID.isEmpty == false})
        let _ = toHolding.map({$0.alpha = 0})
        // unhide the subviews target from view but result is unused
        let _ = toTargetsSubViews.filter({if $0.transitionID.isEmpty {
            $0.alpha = 1
            return true
            }
            return false
        })
        
        
        let toCopy = toTarget.snapshotViewWithLayers()
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
    
    func animateKeypathsAlongSide(keypaths:[String],copyFrom:UIView,copyTo:UIView,duration:Double)->CAAnimationGroup{

        
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

    func animateAlongSide(animateViewAlongSide:UIView, viewToMatch:UIView){
        print("we are animating a match")
        guard let animationKeys = viewToMatch.layer.animationKeys() else{return}
        print("keys are a go")
        for key in animationKeys{
            let anim = viewToMatch.layer.animation(forKey: key)
            if anim is CAPropertyAnimation{
                let propertyAnim = anim as! CAPropertyAnimation
                if propertyAnim.keyPath! == "bounds.size" || propertyAnim.keyPath! == "cornerRadius"{
                    print("add this animation")
                    animateViewAlongSide.layer.add(propertyAnim, forKey: key)
                }
            }
        }
        
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
