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

class ViewController: UIViewController {

    let animationDel = AGMatchMaker()
    let borderColor : UIColor = #colorLiteral(red: 0.9584442973, green: 0.3839759827, blue: 0.3574679196, alpha: 1)
    @IBOutlet weak var internalBlueView: UIView!
    @IBOutlet weak var fromContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //just showing a shadow can be animated
        fromContainerView.layoutIfNeeded()
        fromContainerView.layer.cornerRadius = fromContainerView.bounds.width/2
        fromContainerView.layer.borderColor = borderColor.cgColor
        fromContainerView.layer.borderWidth = 3
        fromContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        fromContainerView.layer.shadowOpacity = 0.5
        fromContainerView.layer.shadowRadius = 4
        
        
        internalBlueView.layer.cornerRadius = internalBlueView.bounds.width/2
        internalBlueView.layer.masksToBounds = true
        
        //modals are supported
        //to set a view id you can use this in view did load or set it in transitionID in storyboard
        //someView.transitionID = "someViewID"
        
        // if we want to stop this just set to nil
        self.navigationController?.delegate = animationDel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startAnimation()
    }
    
    func startAnimation(){
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "test", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "test"{
            let dvc = segue.destination as! DestinationViewController
            dvc.transitioningDelegate = animationDel
        }
        if self.navigationController != nil{
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
    }

}
