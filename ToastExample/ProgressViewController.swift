//
//  ProgressViewController.swift
//  Toast
//
//  Created by Peter Ent on 9/12/18.
//  Copyright © 2018 Keaura. All rights reserved.
//

import UIKit

/*
 * Implement this delegate to be informed when the progress
 * has changed.
 */
protocol ProgressViewDelegate: class {
    func progressComplete() -> Void
}

/*
 * The ProgressViewController manages a progress indicator. This illustates how a
 * UIViewController can be used as a Toast. When an instance of this UIViewController
 * is attached to a Toast, the UIView it manages becomes the visible Toast that's
 * popped up. Because sizing a UIView like this can be tricky, you can use the Toast's
 * maximumContentSize property to help. If, for example, this UIViewController is to
 * be a bottom-side Toast, then maximumContentSize determine's the UIView's height.
 *
 * All this example does is start a timer to change the progress bar and notify the
 * delegate when progress has reached 1.0. It is up to the delegate to dismiss the Toast.
 *
 */
class ProgressViewController: UIViewController {
    
    @IBOutlet var progressBar: UIProgressView!
    
    weak var delegate: ProgressViewDelegate?
    
    var currentProgress: Float = 0
    
    deinit {
        print("ProgressViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        progressBar.progress = currentProgress
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            if self.currentProgress >= 1.0 {
                timer.invalidate()
                self.delegate?.progressComplete()
            } else {
                self.currentProgress = self.currentProgress + 0.1
            }
            DispatchQueue.main.async {
                self.progressBar.progress = self.currentProgress
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
