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

  @IBInspectable var _numberOfSegments      : Int = 5
  @IBInspectable var _min                   : CGFloat = 0
  @IBInspectable var _max                   : CGFloat = 100
  @IBInspectable var _frameColor            : NSColor = NSColor(red: 0.2, green: 0.2, blue: 0.8, alpha: 1.0)
  @IBInspectable var _backgroundColor       : NSColor = NSColor(red: 0.1, green: 1.0, blue: 0.1, alpha: 0.5)
  @IBInspectable var _normalColor           : NSColor = NSColor.systemGreen
  @IBInspectable var _warningColor          : NSColor = NSColor.systemYellow
  @IBInspectable var _criticalColor         : NSColor = NSColor.systemRed
  @IBInspectable var _warningLevel          : CGFloat = 80
  @IBInspectable var _criticalLevel         : CGFloat = 90
  @IBInspectable var _type                  : Int = 0       // kStandard or kSMeter
  @IBInspectable var _isFlipped             : Bool = false

  private var _zeroPoint                    : CGFloat = 0.0
  private var _barInset                     : CGFloat = 0.0
  private var _barHeight                    : CGFloat = 0.0
  private var _lineWidth                    : CGFloat = 3.0
  private var _range                        : CGFloat = 0.0
  private var _criticalPercent              : CGFloat = 0.0
  private var _warningPercent               : CGFloat = 0.0

  private let kPeakWidth                    : CGFloat = 0.03
  private let kStandard                     : Int = 0
  private let kSMeter                       : Int = 1
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)

    assert(frame.size.height >= 5.0, "Frame height \(frame.size.height) < 5.0")
  }
  
  override func viewWillDraw() {
    
    // determine the appropriate sizes
    if _type == kSMeter {
      
      // S-Meter type
      _lineWidth = 0
      _barInset = 0
      _barHeight = frame.size.height
      
    } else {
      
      // standard bar type
      _lineWidth = frame.size.height * 0.1
      _barInset = 2 * _lineWidth
      _barHeight = frame.size.height - (2 * _barInset)
    }
    _range = _max - _min
    _criticalPercent = (_criticalLevel - _min) / _range
    _warningPercent = (_warningLevel - _min) / _range

    // choose the bar's zero point
    _zeroPoint = _isFlipped ? frame.size.width : 0.0
  }

  // ----------------------------------------------------------------------------
  // MARK: - Overridden Methods
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // draw the frame
    if _type == kStandard {
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
    }

    // normalize level to 0 - 100
    let levelPercent = (level - _min) / _range
    var peakPercent = (peak - _min) / _range
    
    // create the bar
    var remainingPercent = levelPercent
    switch remainingPercent {
    case _criticalPercent...:
      
      let percent = _isFlipped ? 1.0 - _criticalPercent : _criticalPercent

      // draw the critical section
      var width = (remainingPercent - _criticalPercent) * dirtyRect.size.width
      width = _isFlipped ? -width : width
      let rect = NSRect(origin: CGPoint(x: percent * dirtyRect.size.width, y: _barInset), size: CGSize(width: width, height: _barHeight))
      // append the critical bar
      _path.append( createBar(at: rect, color: _criticalColor) )

      remainingPercent = _criticalPercent
      fallthrough

    case _warningPercent..<_criticalPercent:
      
      let percent = _isFlipped ? 1.0 - _warningPercent : _warningPercent

      // draw the warning section
      var width = (remainingPercent - _warningPercent) * dirtyRect.size.width
      width = _isFlipped ? -width : width
      let rect = NSRect(origin: CGPoint(x: percent * dirtyRect.size.width, y: _barInset), size: CGSize(width: width, height: _barHeight))
      // append the warning bar
      _path.append( createBar(at: rect, color: _warningColor) )

      remainingPercent = _warningPercent
      fallthrough

    case 0..<_warningPercent:
      
      // draw the normal section
      var width = remainingPercent * dirtyRect.size.width
      width = _isFlipped ? -width : width
      let rect = NSRect(origin: CGPoint(x: _zeroPoint, y: _barInset), size: CGSize(width: width, height: _barHeight))
      // append the normal bar
      _path.append( createBar(at: rect, color: _normalColor) )

    default:  // should never occur
      break
    }
    
    // only draw the peak if non-zero
    if peakPercent > 0.0 {

      peakPercent = min(peakPercent, 0.99)
      let percent = _isFlipped ? 1.0 - peakPercent : peakPercent
      
      // calculate the peak location & size
      var width = dirtyRect.size.width * kPeakWidth
      width = _isFlipped ? -width : width
      let rect = NSRect(origin: CGPoint(x: (percent * dirtyRect.size.width) - kPeakWidth, y: _barInset), size: CGSize(width: width, height: _barHeight))

      // determine the peak color
      var peakColor: NSColor
      switch peakPercent {
      case _criticalPercent...:
        peakColor = _criticalColor
      case _warningPercent..<_criticalPercent:
        peakColor = _warningColor
      default:
        peakColor = _normalColor
      }
      // append the peak bar
      _path.append( createBar(at: rect, color: peakColor) )
    }
    // draw & clear
    _path.stroke()
    _path.removeAllPoints()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Methods
  
//  /// Update the Level & Peak values
//  ///
//  /// - Parameters:
//  ///   - level:            average level
//  ///   - peak:             peak level
//  ///
//  public func updateLevel(_ level: CGFloat, peak: CGFloat) {
//  
//    _level = level
//    _peak = peak
//    
//    // force a redraw
//    needsDisplay = true
//  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Methods
  
  /// Create a filled rect area
  ///
  /// - Parameters:
  ///   - rect:             the area
  ///   - color:            an NSColor
  /// - Returns:            the filled NSBezierPath
  ///
  private func createBar(at rect: NSRect, color: NSColor) -> NSBezierPath {
  
    // create a path with the specified rect
    let path = NSBezierPath(rect: rect)
    
    // fill it with color
    color.setFill()
    path.fill()
    
    return path
  }
}




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
  /// Fill a Rectangle
  ///
  /// - Parameters:
  ///   - rect:           the rect
  ///   - color:          the fill color
  ///
//  func fillRect( _ rect: NSRect, withColor color: NSColor, andAlpha alpha: CGFloat = 1) {
//
//    // fill the rectangle with the requested color and alpha
//    color.setFill()
//    self.fill(rect)
//  }
  
}
