////  AGMatchMaker
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

public class AGMatchMaker:  NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    //customizable
    var dampening : CGFloat = 0.85
    var springVelocity : CGFloat = 0.85
    var duration = 0.5
    var curveOptions : UIViewAnimationOptions = .curveEaseInOut
    

    let processor = TransitionProcessor()
    fileprivate var isPresenting = true

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        //hopefully this cannot happen
        guard let toViewController = toVC else{return}
        guard let fromViewController = fromVC else{return}
        //this is for rotation
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        
        //get our target views
        let targetedFromViews = processor.retrieveAllViews(view: fromViewController.view)
        let targetedToViews = processor.retrieveAllViews(view: toViewController.view)
        
        //hide the to view
        toViewController.view.alpha = 0
        
        //make sure orientation and scale is correct although we don't manipulate any real views other than alpha
        // and some layer animations
        //container.addSubview(fromVC.view)
        container.addSubview(toViewController.view)
        let transform = toViewController.view.transform
        toViewController.view.transform = CGAffineTransform.identity
        toViewController.view.bounds = container.bounds
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.transform = transform
        
        toViewController.view.layoutIfNeeded()
        toViewController.view.layoutSubviews()
        toViewController.view.setNeedsLayout()
        
        
        
        //our main container animation
        UIView.animate(withDuration: duration * 0.66 , animations: {
            toViewController.view.alpha = 1
            fromViewController.view.alpha = 0
            
        }, completion: nil)
        
        // check and trigger individual animations
        for target in targetedFromViews{
            self.performTransitionAnimation(container:container,target: target, targetedToViews: targetedToViews, targetedFromViews: targetedFromViews, transitionContext: transitionContext, toViewController: toViewController, fromViewController: fromViewController)
        }
        
        // complete the animation and clean up
        self.completeAnimation(fromController:fromViewController,toView: toViewController.view,fromView: fromViewController.view, targetedFromViews: targetedFromViews, targetedToViews: targetedToViews, transitionContext: transitionContext)

    }
    
    
    private func performTransitionAnimation(container:UIView,target:UIView,targetedToViews:[UIView],targetedFromViews:[UIView],transitionContext:UIViewControllerContextTransitioning,toViewController:UIViewController,fromViewController:UIViewController){
        
    
   
        // hide from view for snap shotting
        let _ = targetedFromViews.map({$0.alpha = 0})
        let filteredTargetedToViews = targetedToViews.filter({ $0.transitionID == target.transitionID })
        if filteredTargetedToViews.count > 0{
            // we are going with the horse that brought us here
            let toTarget = filteredTargetedToViews.first!
            // this is where we are sending this little subview
            let toTargetFrame = toTarget.convert(toTarget.bounds, to: UIApplication.shared.keyWindow)

            // we create animation group for cornerradius, shadow, and some other stuff.
            let animationGroup = processor.createBasicAnimations(copyFrom:target, copyTo: toTarget,duration:duration * 0.66 * Double(dampening))
            
            // unhide the target from view but result is unused
            let _ = targetedFromViews.filter({if $0.transitionID == target.transitionID{
                $0.alpha = 1
                return true
                }
                return false
            })
            
            // this is how we snapshot our targetfrom and create the best snapshot we can as we filter out other animating views
            let targets = processor.processTargetViews(fromTarget: target, toTarget: toTarget,targets: targetedToViews)
            //from snapshot
            let fromCopy = targets.0
            //to snapshot
            let toCopy = targets.1
            
            //set our frame based on the window
            fromCopy.frame = target.convert(target.bounds, to: UIApplication.shared.keyWindow)
            // this needs to be the same frame because we animate them together
            toCopy.frame = fromCopy.frame
            
            // add them to our views and not alter the originals
            // this is kind of a weird case and i don't know if this is the best way to handle but if we don't do this then the navbar or tabbbar could be behind a tableview/collectionview cell at the end of the animation
            if toViewController is UINavigationController{
                (toViewController as! UINavigationController).topViewController?.view.addSubview(toCopy)
            }else if toViewController is UITabBarController {
                (toViewController as! UITabBarController).selectedViewController?.view.addSubview(toCopy)
            }else{
                toViewController.view.addSubview(toCopy)
               
            }
            
            if fromViewController is UINavigationController{
                (fromViewController as! UINavigationController).topViewController?.view.addSubview(fromCopy)
            }else if fromViewController is UITabBarController{
                (fromViewController as! UITabBarController).selectedViewController?.view.addSubview(fromCopy)
            }else{
                fromViewController.view.addSubview(fromCopy)
            }
            
            // add our caanimations
            fromCopy.layer.add(animationGroup, forKey: nil)
            toCopy.layer.add(animationGroup, forKey: nil)
            
            
            //animate the copies alpha
            UIView.animate(withDuration: (duration * 0.66), delay: 0, options: curveOptions, animations: {
                fromCopy.alpha = 0
                toCopy.alpha = 1
                
            }, completion: nil)
            
            //animate the frames but only on the copies
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: dampening , initialSpringVelocity: springVelocity, options: curveOptions, animations: {
                fromCopy.frame = toTargetFrame
                toCopy.frame = toTargetFrame
                
            }, completion: { (finished) in
                toTarget.alpha = 1
                fromCopy.alpha = 0
                toCopy.alpha = 0
                fromCopy.removeFromSuperview()
                toCopy.removeFromSuperview()
             
            })

        }else{
            //unhide immediately
            target.alpha = 1
        }
    }
    
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func completeAnimation(fromController:UIViewController,toView:UIView,fromView:UIView,targetedFromViews:[UIView],targetedToViews:[UIView],transitionContext:UIViewControllerContextTransitioning){
        
        let when = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: when) {
            toView.alpha = 1
            transitionContext.completeTransition(true)
            fromView.transform = .identity
            let _ = targetedFromViews.map({$0.alpha = 1})
            if self.isPresenting == false{
                self.processor.cleanUpTargets(targets: targetedToViews)
                guard let nav = fromController.navigationController else{return}
                nav.delegate = nil
            }
            
        }
    }

}

extension AGMatchMaker: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = operation == .push
        return self
    }
}
