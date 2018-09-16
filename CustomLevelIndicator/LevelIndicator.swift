//
//  LevelIndicator.swift
//  CustomLevelIndicator
//
//  Created by Douglas Adams on 9/8/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Cocoa

class LevelIndicator: NSView {
  
  public var level                          : CGFloat = 0.0 {
    didSet { needsDisplay = true } }        // force a redraw
  public var peak                           : CGFloat = 0.0 {
    didSet { needsDisplay = true } }        // force a redraw

  private var _path                         = NSBezierPath()
  private var _framePath                    = NSBezierPath()

  @IBInspectable var _numberOfSegments      : Int = 4
  @IBInspectable var _leftValue             : CGFloat = 0
  @IBInspectable var _rightValue            : CGFloat = 100
  
  @IBInspectable var _frameColor            : NSColor = NSColor(red: 0.2, green: 0.2, blue: 0.8, alpha: 1.0)
  @IBInspectable var _backgroundColor       : NSColor = NSColor(red: 0.1, green: 1.0, blue: 0.1, alpha: 0.5)
  @IBInspectable var _normalColor           : NSColor = NSColor.systemGreen
  @IBInspectable var _warningColor          : NSColor = NSColor.systemYellow
  @IBInspectable var _criticalColor         : NSColor = NSColor.systemRed
  @IBInspectable var _warningLevel          : CGFloat = 80
  @IBInspectable var _criticalLevel         : CGFloat = 90
  @IBInspectable var _isFlipped             : Bool = false

  private var _barInset                     : CGFloat = 0.0
  private var _barHeight                    : CGFloat = 0.0
  private var _lineWidth                    : CGFloat = 3.0
  private var _range                        : CGFloat = 0.0
  private var _criticalPercent              : CGFloat = 0.0
  private var _warningPercent               : CGFloat = 0.0
  private var _criticalPosition             : CGFloat = 0.0
  private var _warningPosition              : CGFloat = 0.0

  private let kPeakWidth                    : CGFloat = 5
  private let kStandard                     : Int = 0
  private let kSMeter                       : Int = 1
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)

    assert(frame.size.height >= 5.0, "Frame height \(frame.size.height) < 5.0")
  }
  
  override func viewWillDraw() {
    
    // standard bar type
    _lineWidth = frame.size.height * 0.1
    _barInset = 2 * _lineWidth
    _barHeight = frame.size.height - (2 * _barInset)

    _range = _rightValue - _leftValue
    _warningPercent = ((_warningLevel - _leftValue) / _range)
    _warningPosition = _warningPercent * frame.size.width
    _criticalPercent = ((_criticalLevel - _leftValue) / _range)
    _criticalPosition = _criticalPercent * frame.size.width
  }

  // ----------------------------------------------------------------------------
  // MARK: - Overridden Methods
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    // draw the frame
    // set Line Width & Color
    _framePath.lineWidth = _lineWidth
    _frameColor.set()
    
    // create the top & bottom line
    _framePath.hLine(at: dirtyRect.size.height, fromX: 0, toX: dirtyRect.size.width)
    _framePath.hLine(at: 0, fromX: 0, toX: dirtyRect.size.width)
    
    // create the vertical hash marks
    let segmentWidth = dirtyRect.size.width/CGFloat(_numberOfSegments)
    _framePath.vLine(at: 0, fromY: dirtyRect.size.height - _barInset , toY: _barInset)
    for i in 1..._numberOfSegments {
      _framePath.vLine(at: segmentWidth * CGFloat(i), fromY: dirtyRect.size.height - _barInset, toY: _barInset)
    }
    _path.append(_framePath)

    
    
    
    let levelPercent = ((level - _leftValue) / _range)
    
    
    Swift.print("level = \(level), leftValue = \(_leftValue), range = \(_range), levelPercent = \(levelPercent), criticalPercent = \(_criticalPercent), warningPercent = \(_warningPercent)")
    
    
    // create the bar
    var remainingPercent = levelPercent
    switch remainingPercent {
      
    case _criticalPercent...:
      
      // append the critical section
      let width = ((remainingPercent - _criticalPercent) * dirtyRect.size.width)
      appendSection(at: _criticalPosition, width: width, color: _criticalColor)
      
      remainingPercent = _criticalPercent
      fallthrough
      
    case _warningPercent..._criticalPercent:
      
      // append the warning section
      let width = (remainingPercent - _warningPercent) * dirtyRect.size.width
      appendSection(at: _warningPosition, width: width, color: _warningColor)
      
      remainingPercent = _warningPercent
      fallthrough
      
    default:
      
      // append the normal section
      let width = remainingPercent * dirtyRect.size.width
      appendSection(at: 0, width: width, color: _normalColor)
    }

//    // flip (if needed)
//    if _isFlipped {
//      var transform = AffineTransform(translationByX: frame.size.width, byY: frame.size.height)
//      transform.rotate(byDegrees: 180)
//
//      _path.transform(using: transform)
//    }

    // draw & clear
    _path.stroke()
    _path.removeAllPoints()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Methods
  
  /// Create a section & append it
  ///
  /// - Parameters:
  ///   - position:         position of the level
  ///   - width:            width of the bar
  ///   - color:            color of the bar
  ///
  private func appendSection(at position: CGFloat, width: CGFloat, color: NSColor) {
    
    // construct its rect
    let rect = NSRect(origin: CGPoint(x: position, y: _barInset),
                      size: CGSize(width: width, height: _barHeight))
    // create & append the section
    _path.append( createBar(at: rect, color: color) )
  }
  /// Create a filled rect area
  ///
  /// - Parameters:
  ///   - rect:             the area
  ///   - color:            an NSColor
  /// - Returns:            the filled NSBezierPath
  ///
  private func createBar(at rect: NSRect, color: NSColor) -> NSBezierPath {
    
    // create a path with the specified rect
    var path = NSBezierPath(rect: rect)

    if _isFlipped {
      var transform = AffineTransform(translationByX: frame.size.width, byY: frame.size.height)
      transform.rotate(byDegrees: 180)
      
      path.transform(using: transform)
    }

    // fill it with color
    color.setFill()
    path.fill()
    
    return path
  }}




extension NSBezierPath {

  /// Draw a Horizontal line
  ///
  /// - Parameters:
  ///   - y:            y-position of the line
  ///   - x1:           starting x-position
  ///   - x2:           ending x-position
  ///
  func hLine(at y: CGFloat, fromX x1: CGFloat, toX x2: CGFloat) {
    
    move( to: NSMakePoint( x1, y ) )
    line( to: NSMakePoint( x2, y ) )
  }
  /// Draw a Vertical line
  ///
  /// - Parameters:
  ///   - x:            x-position of the line
  ///   - y1:           starting y-position
  ///   - y2:           ending y-position
  ///
  func vLine(at x: CGFloat, fromY y1: CGFloat, toY y2: CGFloat) {
    
    move( to: NSMakePoint( x, y1) )
    line( to: NSMakePoint( x, y2 ) )
  }
}
