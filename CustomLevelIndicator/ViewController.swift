//
//  ViewController.swift
//  CustomLevelIndicator
//
//  Created by Douglas Adams on 9/8/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Cocoa

class ViewController                        : NSViewController {

  @IBOutlet weak var _box                   : NSBox!
  @IBOutlet weak var _levelIndicator        : LevelIndicator!
  
  @IBOutlet weak var _level                 : NSSlider!
  @IBOutlet weak var _levelLabel            : NSTextField!
  @IBOutlet weak var _peak                  : NSSlider!
  @IBOutlet weak var _peakLabel             : NSTextField!

  @IBOutlet weak var _box2                  : NSBox!
  @IBOutlet weak var _levelIndicator2       : LevelIndicator!

  @IBOutlet weak var _level2                : NSSlider!
  @IBOutlet weak var _levelLabel2           : NSTextField!
  @IBOutlet weak var _peak2                 : NSSlider!
  @IBOutlet weak var _peakLabel2            : NSTextField!

  private let kNumberOfSegments             = 5
  private let kFrameColor                   = NSColor.blue
  private let kBackgroundColor              = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // set the background color
    view.layer?.backgroundColor = NSColor.lightGray.cgColor
    
    _box.fillColor = NSColor.black
    _box2.fillColor = NSColor.black
    
    _levelLabel.integerValue = _level.integerValue
    _peakLabel.integerValue = _peak.integerValue
    _levelLabel2.integerValue = _level2.integerValue
    _peakLabel2.integerValue = _peak2.integerValue

  }

  @IBAction func sliderChanged(_ sender: NSSlider) {
    
    _levelLabel.integerValue = Int(_level.floatValue)
    _peakLabel.integerValue = Int(_peak.floatValue)
    draw(self)
  }

  @IBAction func peakSliderChanged(_ sender: NSSlider) {
    _levelLabel.integerValue = Int(_level.floatValue)
    _peakLabel.integerValue = Int(_peak.floatValue)
    draw(self)
  }
  
 
  @IBAction func sliderChanged2(_ sender: NSSlider) {
    
    _levelLabel2.integerValue = Int(_level2.floatValue)
    _peakLabel2.integerValue = Int(_peak2.floatValue)
    draw(self)
  }
  
  @IBAction func peakSliderChanged2(_ sender: NSSlider) {
    _levelLabel2.integerValue = Int(_level2.floatValue)
    _peakLabel2.integerValue = Int(_peak2.floatValue)
    draw(self)
  }

  
  @IBAction func draw(_ sender: Any) {
    
    _levelIndicator?.level = CGFloat(_level.floatValue)
    _levelIndicator?.peak = CGFloat(_peak.floatValue)
  }
}


