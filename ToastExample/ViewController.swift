//
//  ViewController.swift
//  ToastExample
//
//  Created by Peter Ent on 9/2/18.
//  Copyright © 2018 Keaura. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ToastDelegate, PaletteDelegate, ProgressViewDelegate {
    
    var makeTemporaryToast = true
    var sizeToastToFit = true
    var centerToast = true
    var allowsSwipeToDismiss = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // This holds the currently visible Toast. This app is designed to show only 1
    // Toast at time and will not show a new one while this is visible. This UIViewController
    // implements ToastDelegate.toastDidDisappear() which is called whenever a Toast is removed.
    // There, activeToast is reset to nil.
    var activeToast: Toast?
    
    @IBAction func hideToast(_ sender:Any?) {
        guard let toast = activeToast else {
            return
        }
        toast.dismiss()
    }
    
    // MARK: - ToastDelegate
    
    func toastDidDisppear(toast: Toast) {
        activeToast = nil
    }
    
    // MARK: - Edge Toasts
    
    @IBAction func showBottomToast(_ sender:Any?) {
        toggleToast(side: .bottom)
    }
    
    @IBAction func showTopToast(_ sender:Any?) {
        toggleToast(side: .top)
    }
    
    @IBAction func showRightToast(_ sender:Any?) {
        toggleToast(side: .right)
    }
    
    @IBAction func showLeftToast(_ sender:Any?) {
        toggleToast(side: .left)
    }
    
    // MARK: - A user input blocking Toast. Use hideToast() to dismiss this.
    
    @IBAction func showBlockingToast(_ sender:Any?) {
        guard activeToast == nil else {
            return
        }
        
        activeToast = Toast.blocking(self, message:"Please wait... content loading...", isBlurry:true)
        activeToast?.delegate = self
    }
    
    // MARK: - A custom UIView Toast. Uses ToastViewDelegate.
    
    @IBAction func makeBurntToast(_ sender:Any?) {
        guard activeToast == nil else {
            return
        }
        
        let toast = Toast(viewDelegate: self, options: [.isCentered: false, .allowsSwipeToDismiss: allowsSwipeToDismiss, .isTemporary: makeTemporaryToast])
        toast.delegate = self
        toast.tag = 2000
        toast.present(self)
        
        activeToast = toast
    }
    
    // MARK: - A custom UIView Toast built from an XIB file
    
    @IBAction func makePaletteToast(_ sender:Any?) {
        guard activeToast == nil else {
            return
        }
        
        let toast = Toast(viewDelegate: self, options: [.side: ToastSide.left, .isCentered: true, .allowsSwipeToDismiss: allowsSwipeToDismiss, .isTemporary: false])
        toast.delegate = self
        toast.tag = 1000
        toast.present(self)
        
        activeToast = toast
    }
    
    // MARK: - A custom UIView Toast built from a UIViewController (such as one loaded from a Storyboard).
    // In this example, the Toast is monitored by a ProgressViewController. It allows interaction with the
    // application (but you could add .isBlockingUserInput to the options to prevent that) and dismisses when
    // the progress bar completes. If you do make it block user input, consider making the background blurry
    // for a better experience.
    
    @IBAction func makeVCToast(_ sender:Any?) {
        guard activeToast == nil else {
            return
        }
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ProgressViewController") as? ProgressViewController {
            vc.delegate = self
            
            // Tip: unless you do your constraints just right, the content size of the view might not be as you
            // expect, so use maximumContentDimension to put a limit on how large the Toast will be.
            let toast = Toast(viewController: vc, options: [.maximumContentDimension: 100.0,
                                                            .isTemporary: false,
                                                            .isCentered: centerToast,
                                                            //.isBlockingUserInput: true, .isBlockingInputBlurry: true,
                                                            .allowsSwipeToDismiss: false])
            toast.delegate = self
            toast.present(self)

            activeToast = toast
        }
    }
    
    // MARK: - ProgressViewDelegate
    
    func progressComplete() {
        activeToast?.dismiss()
    }
    
    // MARK: - Supporting Functions
    
    func initialValues() -> [PaletteSwitchType:Bool] {
        return [PaletteSwitchType.centered: centerToast,
                PaletteSwitchType.sizeToFit: sizeToastToFit,
                PaletteSwitchType.temporary: makeTemporaryToast,
                PaletteSwitchType.swipeToDismiss: allowsSwipeToDismiss]
    }
    
    func switchThrown(type: PaletteSwitchType, isOn: Bool) {
        switch type {
        case .centered:
            centerToast = isOn
        case .sizeToFit:
            sizeToastToFit = isOn
        case .swipeToDismiss:
            allowsSwipeToDismiss = isOn
        default:
            makeTemporaryToast = isOn
        }
        
        activeToast?.dismiss()
        
        Toast.quick(self, message: "Setting changed", options: [ToastOptions.messageBackgroundColor: UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)])
    }
    
    func closePalette() {
        activeToast?.dismiss()
    }
    
    func toggleToast(side: ToastSide) {
        guard activeToast == nil else {
            return
        }
        
        let toast = Toast(message: "This is a piece of Toast",
                          options: [.side: side, .sizeMessageToFit: sizeToastToFit,
                                    .allowsSwipeToDismiss: allowsSwipeToDismiss,
                                    .isCentered: centerToast,
                                    .isTemporary: makeTemporaryToast])
        toast.delegate = self
        toast.present(self)
        
        activeToast = toast
    }
}

// MARK: - ToastViewDelegate

extension ViewController: ToastViewDelegate {
    
    func contentView(toast: Toast) -> UIView? {
        if toast.tag == 1000 {
            let items = Bundle.main.loadNibNamed("PaletteToast", owner: nil, options: nil)
            if let palette = items?.first as? Palette {
                palette.delegate = self
                return palette
            }
        }
        else if toast.tag == 2000 {
            let myToastChild = UIView()
            let label = UILabel()
            label.text = "My Burnt Toast\n(never centered)"
            label.numberOfLines = 2
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.white
            myToastChild.addSubview(label)
            
            label.topAnchor.constraint(equalTo: myToastChild.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: myToastChild.bottomAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: myToastChild.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: myToastChild.trailingAnchor).isActive = true
            myToastChild.backgroundColor = UIColor.brown
            
            return myToastChild
        }
        
        return nil
    }
    
    func preferredContentDimension(toast: Toast) -> CGFloat? {
        return toast.tag == 2000 ? 60.0 : nil
    }
}

