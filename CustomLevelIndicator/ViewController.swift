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
    
    // format, value, adjust
    //    where: adjust is the number of legend widths to move +/-
    //
    //    last entry, if any, is a legend to be centered
    //
    _levelIndicator2.legends = [            // to skip a legend pass "" as the format
      (0, "%1d", 0, 0),
      (4, "%2d", 40, -0.5),
      (8, "%2d", 80, -0.5),
      (10, "%3d", 100, -0.5),
      (12, "%3d", 120, -1),
      (nil, "RF Power", 0, 0)
    ]
    _levelIndicator.legends = [
      (0, "%2d", -25, 0),
      (1, "%2d", -20, -0.5),
      (4, "%2d", -5, -0.5),
      (5, "%3d", 0, -1),
      (nil, "Compression", 0, 0)
    ]
  }

  @IBAction func sliderChanged(_ sender: NSSlider) {
    
    _levelLabel.integerValue = Int(_level.floatValue)
    _peakLabel.integerValue = Int(_peak.floatValue)
    _levelIndicator?.level = CGFloat(_level.floatValue)
    _levelIndicator?.peak = CGFloat(_peak.floatValue)
  }

  @IBAction func peakSliderChanged(_ sender: NSSlider) {
    _levelLabel.integerValue = Int(_level.floatValue)
    _peakLabel.integerValue = Int(_peak.floatValue)
    _levelIndicator?.level = CGFloat(_level.floatValue)
    _levelIndicator?.peak = CGFloat(_peak.floatValue)
  }
  
  @IBAction func sliderChanged2(_ sender: NSSlider) {
    
    _levelLabel2.integerValue = Int(_level2.floatValue)
    _peakLabel2.integerValue = Int(_peak2.floatValue)
    _levelIndicator2?.level = CGFloat(_level2.floatValue)
    _levelIndicator2?.peak = CGFloat(_peak2.floatValue)
  }
  
  @IBAction func peakSliderChanged2(_ sender: NSSlider) {
    _levelLabel2.integerValue = Int(_level2.floatValue)
    _peakLabel2.integerValue = Int(_peak2.floatValue)
    _levelIndicator2?.level = CGFloat(_level2.floatValue)
    _levelIndicator2?.peak = CGFloat(_peak2.floatValue)
  }  
}


