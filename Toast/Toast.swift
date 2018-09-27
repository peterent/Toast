//
//  Toast.swift
//  Snacks
//
//  Created by Peter Ent on 8/29/18.
//  Copyright © 2018 Peter Ent. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------------
// MARK: - Types

/*
 * The side of the parent UIViewController where the Toast will pop-up. The default is
 * .bottom.
 */
public enum ToastSide {
    case bottom // default
    case top, left, right
}

/*
 * All of the options that can be set on a Toast.
 */
public enum ToastOptions {
    // ToastSide: sets the side of the parent view controller where the Toast will appear.
    case side
    
    // Bool: if true (default), Toast is presented on its side, centered. If false, Toast fills the space from edge to edge.
    case isCentered
    
    // Bool: if true, Toast lingers for a bit then disappears automatically. If false (default), Toast must be dismissed.
    case isTemporary
    
    // UIColor: the color of the Toast message background (default: darkGray).
    case messageBackgroundColor
    
    // UIColor: the color the Toast message text (default: white).
    case messageTextColor
    
    // Bool: if true (default) the Toast is message determines its size rather than a default (see minimumContentDimension) size.
    case sizeMessageToFit
    
    // TimeInterval: the time (default: 0.5) it takes for the Toast to appear.
    case presentInterval
    
    // TimeInterval: the time (default: 3.0) a temporary (see isTemporary) Toast hangs around before disappearing.
    case lingerInterval
    
    // TimeInterval: the time (default: 0.25) it takes for the Toast to disappear.
    case dismissInterval
    
    // Bool: if true, the Toast will block any user input to the parent view controller. If false (default), user input is allowed.
    case isBlockingUserInput
    
    // Bool: if true, an isBlockingInput=true Toast will blur its background will being presented.
    case isBlockingInputBlurry
    
    // Bool: if true (default), swiping will dismiss a Toast. Swipe in the direction of the Toast's side (eg, down for a bottom Toast).
    case allowsSwipeToDismiss
    
    // Bool: if true (default), a, isCentered=true Toast will have a drop shadow.
    case showShadow
    
    // UIColor: the color of the overlay when isBlockingUserInput is true and isBlockingInputBlurry is false (default: translucent black).
    case blockInteractionBackgroundColor
    
    // Double or CGFloat: the minimum size a Toast can be in its secondary axis. For top and bottom Toasts this is its height (default: 40).
    case minimumContentDimension
    
    // Double or CGFloat: the maximum size a Toast can be in its secondary axis. For top and bottom Toasts this is its height (default: CGFloat.greatestFiniteMagnitude)
    case maximumContentDimension
}

// ----------------------------------------------------------------------------------
// MARK: - Delegate Protocols

public protocol ToastDelegate: class {
    /*
     * Invoked when the Toast has been removed from the scene.
     */
    func toastDidDisppear(toast: Toast) -> Void
}

public protocol ToastViewDelegate: class {
    /*
     * Supply a custom view to be shown as the Toast. This UIView should not have a predefined size as may
     * cause the Toast to appear in the wrong location. Return nil to use the default UILabel Toast.
     */
    func contentView(toast: Toast) -> UIView?
    
    /*
     * Return a specific size (eg, height when Toast's side is bottom or top) for the Toast or return
     * nil to use the contentView's intrinsic size or the minimumContentDimension (whichever is larger).
     */
    func preferredContentDimension(toast: Toast) -> CGFloat?
}

// ----------------------------------------------------------------------------------
// MARK: - Toast

/**
 * Toast displays information overlaid on the active UIViewController. The Toast "pops up" from one of the sides
 * of the UIViewController (the bottom, by default). The Toast can be any UIView and comes ready to use UILabel
 * when you supply a String. There are a variety of options to control its appearance and whether or not remain
 * on the screen for a short period of time (the default) or to sit permanently until dismissed (either by the
 * user with a swipe gesture or programmatically). You can also summon a Toast to block the user's input which is
 * handy when loading content.
 *
 * In addition to a UILabel, a you can also supply your own UIView - either directly or from a UIViewController
 * (such as one loaded from a Storyboard). You might, for example, have a tool palette to display as a result of
 * a user action or a progress bar to display while content is being downloaded.
 *
 * For a quick, temporary notice to the user (such as when saving a record), use the Toast.quick() class method
 * and supply the message you want them to see:
 *
 *      Toast.quick(self, message: "Record Saved")
 *
 * This Toast will display for approximately 1/2 second and then disappear (you can change the interval).
 *
 *      let toast = Toast.blocking(self, message: "Content Loading...", isBlurry: true)
 *      ... load your content ...
 *      toast.dismiss()
 *
 * This Toast will blur the screen and display the message. It remains visible until removed using the
 * dismiss() function.
 */
public final class Toast: NSObject {
    
    private var options: [ToastOptions: Any] = [
        .side: ToastSide.bottom,
        .isCentered: true,
        .isTemporary: false,
        .isBlockingUserInput: false,
        .messageBackgroundColor: UIColor.darkGray,
        .messageTextColor: UIColor.white,
        .sizeMessageToFit: true,
        .presentInterval: 0.5,
        .lingerInterval: 2.0,
        .dismissInterval: 0.25,
        .isBlockingInputBlurry: false,
        .allowsSwipeToDismiss: true,
        .showShadow: true,
        .blockInteractionBackgroundColor: UIColor(red:0, green:0, blue:0, alpha: 0.20),
        .minimumContentDimension: CGFloat(40.0),
        .maximumContentDimension: CGFloat.greatestFiniteMagnitude
    ]
    
    // MARK: - Public Properties
    
    public weak var delegate: ToastDelegate?
    public weak var viewDelegate: ToastViewDelegate?
    
    /*
     * The message to display if not supplying the Toast view. This will be turned into a UILabel.
     */
    public var message: String?
    
    /*
     * A value for your own use, perhaps to distinguish between Toasts.
     */
    public var tag: Int = 0
    
    // MARK: - Private Properties
    
    private var side: ToastSide {
        get {
            return options[.side] as! ToastSide
        }
    }
    private var isTemporary: Bool {
        get {
            return options[.isTemporary] as! Bool
        }
    }
    private var isBlockingUserInput: Bool {
        get {
            return options[.isBlockingUserInput] as! Bool
        }
    }
    private var messageBackgroundColor: UIColor {
        get {
            return options[.messageBackgroundColor] as! UIColor
        }
    }
    private var messageTextColor: UIColor {
        get {
            return options[.messageTextColor] as! UIColor
        }
    }
    private var sizeMessageToFit: Bool {
        get {
            return options[.sizeMessageToFit] as! Bool
        }
    }
    private var presentInterval: TimeInterval {
        get {
            return options[.presentInterval] as! TimeInterval
        }
    }
    private var lingerInterval: TimeInterval {
        get {
            return options[.lingerInterval] as! TimeInterval
        }
    }
    private var dismissInterval: TimeInterval {
        get {
            return options[.dismissInterval] as! TimeInterval
        }
    }
    private var isBlockingUserInputBlurry: Bool {
        get {
            return options[.isBlockingInputBlurry] as! Bool
        }
    }
    private var allowsSwipeToDismiss: Bool {
        get {
            return options[.allowsSwipeToDismiss] as! Bool
        }
    }
    private var showShadow: Bool {
        get {
            return options[.showShadow] as! Bool
        }
    }
    private var blockInteractionBackgroundColor: UIColor {
        get {
            return options[.blockInteractionBackgroundColor] as! UIColor
        }
    }
    private var isCentered: Bool {
        get {
            return options[.isCentered] as! Bool
        }
    }
    private var minimumContentDimension: CGFloat {
        get {
            if let value = options[.minimumContentDimension] as? Double {
                return CGFloat(value)
            } else if let value = options[.minimumContentDimension] as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    private var maximumContentDimension: CGFloat {
        get {
            if let value = options[.maximumContentDimension] as? Double {
                return CGFloat(value)
            } else if let value = options[.maximumContentDimension] as? CGFloat {
                return value
            } else {
                return CGFloat.greatestFiniteMagnitude
            }
        }
    }
    private var offset: CGFloat {
        get {
            guard isCentered else { return 0 }
            if side == .bottom || side == .right {
                return 8
            } else {
                return -8
            }
        }
    }
    
    private var screen: ToastScreen!
    private var view: UIView!
    private var actualViewSize: CGFloat = 0
    private var parentViewController: UIViewController!
    private var childViewController: UIViewController?
    private var adjustmentConstraint: NSLayoutConstraint!
    private var viewAppearanceAmount: CGFloat = 0
    
    // MARK: - Initializers
    
    /**
     * Creates a Toast with an initial message with some options.
     */
    public init(message: String, options: [ToastOptions: Any]? = nil) {
        super.init()
        
        self.message = message
        mergeOptions(options)
    }
    
    /**
     * Creates a Toast with a ToastViewDelegate that will supply the Toast view.
     */
    public init(viewDelegate: ToastViewDelegate, options: [ToastOptions: Any]? = nil) {
        super.init()
        
        self.viewDelegate = viewDelegate
        mergeOptions(options)
    }
    
    /**
     * Creates a Toast with a UIView and some options.
     */
    public init(view: UIView, options: [ToastOptions: Any]? = nil) {
        super.init()
        
        self.view = view
        mergeOptions(options)
    }
    
    /**
     * Creates a Toast with the view stored inside a UIViewController.
     */
    public init(viewController: UIViewController, options: [ToastOptions: Any]? = nil) {
        super.init()
        self.childViewController = viewController
        mergeOptions(options)
    }
    
    // Merges options from init functions.
    private func mergeOptions(_ newOptions: [ToastOptions: Any]?) {
        if let setupOptions = newOptions {
            for (key,value) in setupOptions {
                self.options[key] = value
            }
        }
    }
    
    // MARK: - Public Functions
    
    /**
     * Presents the Toast, animated, against the given UIViewController. The Toast is always attached to the SafeArea.
     * If you want the Toast to cover the navigation or tool bars, use a UINavigationController.
     */
    public func present(_ parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        createSubviews()
        layoutSubviews()
        
        CATransaction.flush()
        performShowAnimation()
    }
    
    /**
     * Dismisses the Toast. If a ToastDelegate has been set, the toastDidDisappear function is called.
     */
    public func dismiss() {
        performHideAnimation()
    }
    
    // MARK: - Private animations
    
    @objc private func performShowAnimation() {
        adjustmentConstraint.constant = viewAppearanceAmount - offset
        
        UIView.animate(withDuration: presentInterval, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.parentViewController.view.layoutIfNeeded()
        }, completion: {(success) in
            if self.isTemporary {
                self.perform(#selector(self.performHideAnimation), with: nil, afterDelay: self.lingerInterval)
            }
        })
    }
    
    @objc private func performHideAnimation() {
        adjustmentConstraint.constant = 0
        
        UIView.animate(withDuration: dismissInterval, delay: 0, options: .curveEaseIn, animations: {
            self.screen.alpha = 0
            self.parentViewController.view.layoutIfNeeded()
        }) { (_) in
            if self.screen.superview != nil {
                self.screen.removeFromSuperview()
            }
            if self.view.superview != nil {
                self.view.removeFromSuperview()
                self.delegate?.toastDidDisppear(toast: self)
                
                if self.childViewController != nil {
                    self.childViewController?.removeFromParentViewController()
                }
            }
        }
    }
    
    // MARK: - Convenience Class Functions
    
    /**
     * Presents a temporary Toast with the given message. The default side is .bottom and it shows only briefly for
     * 0.5 seconds. To make this particular Toast remain longer, include ToastOptions:lingerInterval in the options.
     */
    public class func quick(_ parentViewController: UIViewController, message: String, options: [ToastOptions: Any]? = nil) {
        let toast = Toast(message: message, options: options)
        toast.options[.isTemporary] = true
        if options?[.lingerInterval] == nil {
            toast.options[.lingerInterval] = 0.5
        }
        toast.present(parentViewController)
    }
    
    /**
     * Presents a blocking, permanent, Toast along the bottom with the given message.
     */
    public class func blocking(_ parentViewController: UIViewController, message: String, isBlurry: Bool = false) -> Toast {
        let toast = Toast(message: message, options: [.isBlockingInputBlurry: isBlurry, .isTemporary: false, .isBlockingUserInput: true])
        toast.present(parentViewController)
        return toast
    }
    
    // MARK - Private Layout
    
    private func createSubviews() {
        if viewDelegate != nil {
            // see if there's a custom content view - this can return nil
            view = viewDelegate?.contentView(toast: self)
        }
        else if let vc = childViewController {
            parentViewController.addChildViewController(vc)
            view = vc.view
            vc.didMove(toParentViewController: parentViewController)
        }
        
        // if a view was not supplied, use UILabel
        if view == nil {
            let labelView = ToastLabel()
            labelView.text = message
            labelView.textAlignment = .center
            labelView.layer.backgroundColor = messageBackgroundColor.cgColor
            labelView.textColor = messageTextColor
            labelView.numberOfLines = 0
            labelView.minimumScaleFactor = 0.5
            labelView.adjustsFontSizeToFitWidth = true
            if sizeMessageToFit { labelView.sizeToFit() }
            view = labelView
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = isCentered ? 10.0 : 0.0
        if showShadow {
            view.layer.shadowOffset = isCentered ? CGSize(width: 4.0, height: 4.0) : CGSize.zero
            view.layer.shadowColor = isCentered ? UIColor.black.cgColor : UIColor.clear.cgColor
            view.layer.shadowOpacity = isCentered ? 0.25 : 0
        }
        
        // the toast view sits in front of the screen which may also block the user from interacting
        // with the app, depending on the value of blockInteraction
        if screen == nil  {
            screen = ToastScreen()
            screen.isUserInteractionEnabled = !isBlockingUserInput
            screen.translatesAutoresizingMaskIntoConstraints = false
    
            view.isUserInteractionEnabled = true
            
            if isBlockingUserInputBlurry {
                let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
                visualEffect.translatesAutoresizingMaskIntoConstraints = false
                screen.addSubview(visualEffect)
                screen.sendSubview(toBack: visualEffect)
                
                visualEffect.topAnchor.constraint(equalTo: screen.topAnchor).isActive = true
                visualEffect.bottomAnchor.constraint(equalTo: screen.bottomAnchor).isActive = true
                visualEffect.leadingAnchor.constraint(equalTo: screen.leadingAnchor).isActive = true
                visualEffect.trailingAnchor.constraint(equalTo: screen.trailingAnchor).isActive = true
            } else {
                screen.backgroundColor = isBlockingUserInput ? blockInteractionBackgroundColor : UIColor.clear
            }
        }
        
        parentViewController.view.addSubview(screen)
        parentViewController.view.addSubview(view)
        parentViewController.view.setNeedsLayout()
    }
    
    private func layoutSubviews() {
        guard screen != nil, let parentView = parentViewController.view else { return }
        
        let addGesture = {(direction:UISwipeGestureRecognizerDirection) in
            guard self.allowsSwipeToDismiss else { return }
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
            gesture.direction = direction
            self.screen.addGestureRecognizer(gesture)
        }
        
        // the screen, is attached to the parentViewController's view on all 4 sides, edge to edge.
        // the childView is attached on three sides, depending the value of the .side property.
        
        screen.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        screen.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        screen.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        screen.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        
        let guide = parentView.safeAreaLayoutGuide
        
        switch side {
        case .left:
            anchorTBSidesAndFixWidth(guide)
            adjustmentConstraint = view.trailingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0)
            adjustmentConstraint.isActive = true
            viewAppearanceAmount = actualViewSize
            addGesture(.left)

        case .right:
            anchorTBSidesAndFixWidth(guide)
            adjustmentConstraint = view.leadingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 0)
            adjustmentConstraint.isActive = true
            viewAppearanceAmount = 0 - actualViewSize
            addGesture(.right)
 
        case .top:
            anchorLRSidesAndFixHeight(guide)
            adjustmentConstraint = view.bottomAnchor.constraint(equalTo: guide.topAnchor, constant: 0)
            adjustmentConstraint.isActive = true
            viewAppearanceAmount = actualViewSize
            addGesture(.up)
            
        default: // aka, bottom
            anchorLRSidesAndFixHeight(guide)
            adjustmentConstraint = view.topAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0)
            adjustmentConstraint.isActive = true
            viewAppearanceAmount = 0 - actualViewSize
            addGesture(.down)
        }
    }
    
    private func anchorLRSidesAndFixHeight(_ guide: UILayoutGuide) -> Void {
        var frameHeight: CGFloat = viewDelegate?.preferredContentDimension(toast: self) ?? view.frame.height
        if frameHeight < minimumContentDimension {
            frameHeight = minimumContentDimension
        }
        if frameHeight > maximumContentDimension {
            frameHeight = maximumContentDimension
        }
        
        if isCentered {
            view.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        } else {
            view.leadingAnchor.constraint(equalTo: screen.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: screen.trailingAnchor).isActive = true
        }
        
        view.heightAnchor.constraint(equalToConstant: frameHeight).isActive = true
        actualViewSize = frameHeight
    }
    
    private func anchorTBSidesAndFixWidth(_ guide: UILayoutGuide) -> Void {
        var frameWidth: CGFloat = viewDelegate?.preferredContentDimension(toast: self) ?? view.frame.width
        if frameWidth < minimumContentDimension {
            frameWidth = minimumContentDimension
        }
        if frameWidth > maximumContentDimension {
            frameWidth = maximumContentDimension
        }
        
        if isCentered {
            view.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        } else {
            view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        }
        
        view.widthAnchor.constraint(equalToConstant: frameWidth).isActive = true
        actualViewSize = frameWidth
    }
    
    @objc private func handleSwipe(_ gesture:UISwipeGestureRecognizer) {
        dismiss()
    }
}

// ----------------------------------------------------------------------------------
// MARK: - Internal ToastLabel

fileprivate final class ToastLabel: UILabel {
    
    var topInset: CGFloat = 8.0
    var leftInset: CGFloat = 8.0
    var bottomInset: CGFloat = 8.0
    var rightInset: CGFloat = 8.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}

// ----------------------------------------------------------------------------------
// MARK: - Internal ToastScreen

fileprivate final class ToastScreen: UIView {
    // This is empty and is used to allow for custom styling via UIAppearance if needed
    // in the future.
}
