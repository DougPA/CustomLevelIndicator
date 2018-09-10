//
//  ViewController.swift
//  CustomLevelIndicator
//
//  Created by Douglas Adams on 9/8/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Cocoa

class ViewController                        : NSViewController {

  @IBOutlet weak var box                    : NSBox!
  @IBOutlet weak var _level                 : NSSlider!
  @IBOutlet weak var _levelIndicator        : LevelIndicator!
  @IBOutlet weak var _levelLabel            : NSTextField!
  @IBOutlet weak var _peakLabel             : NSTextField!
  
  @IBOutlet weak var _peak                  : NSSlider!
  
  private let kNumberOfSegments             = 5
  private let kFrameColor                   = NSColor.blue
  private let kBackgroundColor              = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // set the background color
    view.layer?.backgroundColor = NSColor.lightGray.cgColor
    
    box.fillColor = NSColor.black
  }

  @IBAction func sliderChanged(_ sender: NSSlider) {
    
    _levelLabel.integerValue = Int(sender.floatValue)
    _peakLabel.integerValue = Int(_peak.floatValue)
    draw(self)
  }
  
  @IBAction func draw(_ sender: Any) {
    
    _levelIndicator?.updateLevel(CGFloat(_level.floatValue/100.0), peak: CGFloat(_peak.floatValue/100.0))
  }
}


