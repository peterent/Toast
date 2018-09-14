//
//  Palette.swift
//  ToastExample
//
//  Created by Peter Ent on 9/7/18.
//  Copyright © 2018 Keaura. All rights reserved.
//

import UIKit

/*
 * The type of switch shown in the palette.
 */
enum PaletteSwitchType {
    case temporary, sizeToFit, centered, swipeToDismiss
}

/*
 * The delegate will be called when switches are thrown or when other
 * changes occur.
 */
protocol PaletteDelegate: class {
    func initialValues() -> [PaletteSwitchType:Bool]
    func switchThrown(type: PaletteSwitchType, isOn: Bool) -> Void
    func closePalette() -> Void
}

/*
 * The Palette is an example of using a UIView that's loaded from a XIB as
 * a Toast. This class manages the UIView and uses a delegate to keep the
 * main controller informed.
 */
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
