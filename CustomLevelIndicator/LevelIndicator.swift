//
//  LevelIndicator.swift
//  CustomLevelIndicator
//
//  Created by Douglas Adams on 9/8/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Cocoa

class LevelIndicator: NSView {
  
  private var _path                         = NSBezierPath()

  @IBInspectable var _numberOfSegments      : Int = 0
  @IBInspectable var _frameColor            : NSColor = NSColor(red: 0.2, green: 0.2, blue: 0.8, alpha: 1.0)
  @IBInspectable var _backgroundColor       : NSColor = NSColor(red: 0.1, green: 1.0, blue: 0.1, alpha: 0.5)
  @IBInspectable var _barColor              : NSColor = NSColor.systemGreen
  @IBInspectable var _warningColor          : NSColor = NSColor.systemYellow
  @IBInspectable var _criticalColor         : NSColor = NSColor.systemRed
  @IBInspectable var _warningLevel          : CGFloat = 0.8
  @IBInspectable var _criticalLevel         : CGFloat = 0.9

  private var _barInset                     : CGFloat = 0.0
  private var _barHeight                    : CGFloat = 0.0
  private var _lineWidth                    : CGFloat = 3.0
  private var _level                        : CGFloat = 0.0
  private var _peak                         : CGFloat = 0.0

  private let kPeakWidth                    : CGFloat = 0.02

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)

    assert(frame.size.height >= 5.0, "Frame height \(frame.size.height) < 5.0")
    
    // determine the appropriate sizes
    if frame.size.height < 10.00 {
      
      _lineWidth = 0
      _barInset = 0
      _barHeight = frame.size.height
      
    } else {
      
      _lineWidth = frame.size.height * 0.1
      _barInset = 2 * _lineWidth
      _barHeight = frame.size.height - (2 * _barInset)
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    if _lineWidth > 0.0 {
      // set Line Width & Color
      _path.lineWidth = _lineWidth
      _frameColor.set()
      
      // create the top & bottom line
      _path.hLine(at: dirtyRect.size.height, fromX: 0, toX: dirtyRect.size.width)
      _path.hLine(at: 0, fromX: 0, toX: dirtyRect.size.width)
      
      // create the vertical hash marks
      let segmentWidth = dirtyRect.size.width/CGFloat(_numberOfSegments)
      _path.vLine(at: 0, fromY: dirtyRect.size.height - _barInset , toY: _barInset)
      for i in 1..._numberOfSegments {
        _path.vLine(at: segmentWidth * CGFloat(i), fromY: dirtyRect.size.height - _barInset, toY: _barInset)
      }
      // draw outline
      _path.stroke()
    }
    
    // create the bar
    var remainingLevel = _level
    
    switch remainingLevel {
    case _criticalLevel...:
      // draw the critical section
      let width = (remainingLevel - _criticalLevel) * dirtyRect.size.width
      let rect = NSRect(origin: CGPoint(x: _criticalLevel * dirtyRect.size.width, y: _barInset), size: CGSize(width: width, height: _barHeight))
      _path.fillRect(rect, withColor: _criticalColor, andAlpha: 0.9)

      remainingLevel = _criticalLevel
      fallthrough

    case _warningLevel..<_criticalLevel:
      // draw the warning section
      let width = (remainingLevel - _warningLevel) * dirtyRect.size.width
      let rect = NSRect(origin: CGPoint(x: _warningLevel * dirtyRect.size.width, y: _barInset), size: CGSize(width: width, height: _barHeight))
      _path.fillRect(rect, withColor: _warningColor, andAlpha: 0.6)

      remainingLevel = _warningLevel
      fallthrough

    case 0..<_warningLevel:
      // draw the normal section
      let width = remainingLevel * dirtyRect.size.width
      let rect = NSRect(origin: CGPoint(x: 0.0, y: _barInset), size: CGSize(width: width, height: _barHeight))
      _path.fillRect(rect, withColor: _barColor, andAlpha: 0.3)

    default:
      break
    }
    
    if _peak > 0.0 {
      // draw the peak
      let width = dirtyRect.size.width * kPeakWidth
      let rect = NSRect(origin: CGPoint(x: (_peak * dirtyRect.size.width) - kPeakWidth, y: _barInset), size: CGSize(width: width, height: _barHeight))
      var peakColor: NSColor
      switch _peak {
        case _criticalLevel...:
        peakColor = _criticalColor
        case _warningLevel..<_criticalLevel:
        peakColor = _warningColor
      default:
        peakColor = _barColor
      }
      _path.fillRect(rect, withColor: peakColor, andAlpha: 0.9)
    }
    
    // clear the path
    _path.removeAllPoints()
  }
  
  /// e the Level & Peak
  ///
  /// - Parameters:
  ///   - level:            average level
  ///   - peak:             peak level
  ///
  public func updateLevel(_ level: CGFloat, peak: CGFloat) {
  
      _level = level
      _peak = peak
      needsDisplay = true
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
  func fillRect( _ rect: NSRect, withColor color: NSColor, andAlpha alpha: CGFloat = 1) {
    
    // fill the rectangle with the requested color and alpha
    color.withAlphaComponent(alpha).setFill()
    NSBezierPath.fill(rect)
  }
  
}
