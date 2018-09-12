//
//  ProgressViewController.swift
//  Toast
//
//  Created by Peter Ent on 9/12/18.
//  Copyright © 2018 Keaura. All rights reserved.
//

import UIKit

protocol ProgressViewDelegate: class {
    func progressComplete() -> Void
}

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
