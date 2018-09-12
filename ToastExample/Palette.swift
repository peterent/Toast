//
//  Palette.swift
//  ToastExample
//
//  Created by Peter Ent on 9/7/18.
//  Copyright © 2018 Keaura. All rights reserved.
//

import UIKit

enum PaletteSwitchType {
    case temporary, sizeToFit, centered, swipeToDismiss
}

protocol PaletteDelegate: class {
    func initialValues() -> [PaletteSwitchType:Bool]
    func switchThrown(type: PaletteSwitchType, isOn: Bool) -> Void
    func closePalette() -> Void
}

class Palette: UIView {
    
    @IBOutlet var temporarySwitch: UISwitch!
    @IBOutlet var sizeSwitch: UISwitch!
    @IBOutlet var centeredSwitch: UISwitch!
    @IBOutlet var swipeToDismissSwitch: UISwitch!
    
    public weak var delegate: PaletteDelegate?
    
    deinit {
        print("Palette deinit")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let values = delegate?.initialValues() {
            for (key,value) in values {
                if key == .centered {
                    centeredSwitch.isOn = value
                } else if key == .sizeToFit {
                    sizeSwitch.isOn = value
                } else if key == .temporary {
                    temporarySwitch.isOn = value
                } else if key == .swipeToDismiss {
                    swipeToDismissSwitch.isOn = value
                }
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func switchThrown(_ sender: UISwitch) {
        switch sender.tag {
        case 2:
            delegate?.switchThrown(type: .sizeToFit, isOn: sender.isOn)
        case 3:
            delegate?.switchThrown(type: .centered, isOn: sender.isOn)
        case 4:
            delegate?.switchThrown(type: .swipeToDismiss, isOn: sender.isOn)
        default:
            delegate?.switchThrown(type: .temporary, isOn: sender.isOn)
        }
    }
    
    @IBAction func close(_ sender:Any) {
        delegate?.closePalette()
    }

}
