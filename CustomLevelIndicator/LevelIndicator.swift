//
//  LevelIndicator.swift
//  CustomLevelIndicator
//
//  Created by Douglas Adams on 9/8/18.
//  Copyright © 2018 Douglas Adams. All rights reserved.
//

import Cocoa

public typealias LegendTuple = (tick: Int?, format: String, value: Int, fudge: CGFloat)

class LevelIndicator: NSView {
  
  public var level                          : CGFloat = 0.0 {
    didSet { needsDisplay = true } }        // force a redraw
  public var peak                           : CGFloat = 0.0 {
    didSet { needsDisplay = true } }        // force a redraw
  
  public var legends: [LegendTuple] = [
    (0, "%1d", 0, 0),
    (1, "%2d", 20, -0.5),
    (2, "%2d", 20, -0.5),
    (3, "%2d", 60, -0.50),
    (4, "%2d", 80, -0.5),
    (5, "%3d", 100, -1),
    (nil, "RF Pwr", 0, 0)
  ]
  

  private var _path                         = NSBezierPath()
  private var _framePath                    = NSBezierPath()

  // layout
  @IBInspectable var _numberOfSegments      : Int = 4
  @IBInspectable var _leftValue             : CGFloat = 0
  @IBInspectable var _rightValue            : CGFloat = 100
  @IBInspectable var _warningLevel          : CGFloat = 80
  @IBInspectable var _criticalLevel         : CGFloat = 90
  @IBInspectable var _isFlipped             : Bool = false

  // colors
  @IBInspectable var _frameColor            : NSColor = NSColor(red: 0.2, green: 0.2, blue: 0.8, alpha: 1.0)
  @IBInspectable var _backgroundColor       : NSColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
  @IBInspectable var _normalColor           : NSColor = NSColor.systemGreen
  @IBInspectable var _warningColor          : NSColor = NSColor.systemYellow
  @IBInspectable var _criticalColor         : NSColor = NSColor.systemRed

  // internal
  private var _range                        : CGFloat = 0.0
  private var _warningPercent               : CGFloat = 0.0
  private var _warningPosition              : CGFloat = 0.0
  private var _criticalPercent              : CGFloat = 0.0
  private var _criticalPosition             : CGFloat = 0.0
  private var _transform                    : AffineTransform!

  // font related
  private var _attributes                   = [NSAttributedStringKey:AnyObject]()
  
  // calculated sizes
  private var _heightGraph                  : CGFloat = 0
  private var _heightTopSpace               : CGFloat = 0
  private var _heightFont                   : CGFloat = 0
  private var _heightLine                   : CGFloat = 3.0
  private var _heightInset                  : CGFloat = 0
  private var _heightBar                    : CGFloat = 0
  private var _topLineY                     : CGFloat = 0
  private var _bottomLineY                  : CGFloat = 0
  private var _fontY                        : CGFloat = 0
  private var _barTopY                      : CGFloat = 0
  private var _barBottomY                   : CGFloat = 0

  // constants
  private let kPeakWidth                    : CGFloat = 5
  
//  private let kStandard                     : Int = 0
//  private let kSMeter                       : Int = 1
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)

    assert(frame.size.height >= 15.0, "Frame height \(frame.size.height) < 15.0")
  }
  
  override func viewWillDraw() {
    
    // setup the Legend font & size
    _attributes[NSAttributedStringKey.font] = NSFont(name: "Monaco", size: 14.0)
    
    // setup the Legend color
    _attributes[NSAttributedStringKey.foregroundColor] = NSColor.systemYellow
    
    // calculate a typical font height
    _heightFont = "-000".size(withAttributes: _attributes).height

    // calculate sizes
    _heightTopSpace = frame.size.height * 0.1
    _heightGraph = frame.size.height - _heightFont - _heightTopSpace
    _heightLine = _heightGraph * 0.1
    _heightInset = _heightLine
    _heightBar = _heightGraph - _heightLine - _heightInset - (2 * _heightLine)
    _barBottomY = _heightInset + _heightLine
    _barTopY = _barBottomY + _heightBar
    
    _fontY = frame.size.height - _heightFont - _heightTopSpace
    _topLineY = frame.size.height - _heightFont - _heightTopSpace
    _bottomLineY = 0

    _range = _rightValue - _leftValue
    _warningPercent = ((_warningLevel - _leftValue) / _range)
    _warningPosition = _warningPercent * frame.size.width
    _criticalPercent = ((_criticalLevel - _leftValue) / _range)
    _criticalPosition = _criticalPercent * frame.size.width
    
    if _isFlipped {
      // create a transform
      _transform = AffineTransform(translationByX: frame.size.width, byY: frame.size.height - _heightFont - _heightTopSpace)
      _transform.rotate(byDegrees: 180)
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Overridden Methods
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    // ----- create the frame -----
    
    // set Line Width & Color
    _framePath.lineWidth = _heightLine
    
    // create the top & bottom line
    _criticalColor.set()
    _framePath.hLine(at: _topLineY, fromX: _criticalPosition, toX: dirtyRect.size.width)
    _framePath.hLine(at: _bottomLineY, fromX: _criticalPosition, toX: dirtyRect.size.width)
    
    // Flip if required
    if _isFlipped { _framePath.transform(using: _transform) }
    
    _framePath.stroke()
    _framePath.removeAllPoints()
    
    // create the top & bottom line
    _frameColor.set()
    _framePath.hLine(at: _topLineY, fromX: 0, toX: _criticalPosition)
    _framePath.hLine(at: _bottomLineY, fromX: 0, toX: _criticalPosition)
    
    // Flip if required
    if _isFlipped { _framePath.transform(using: _transform) }
    
    _framePath.stroke()
    _framePath.removeAllPoints()

    // create the vertical hash marks
    let segmentWidth = dirtyRect.size.width / CGFloat(_numberOfSegments)
    var lineColor : NSColor
    for i in 0..._numberOfSegments {
      let xPosition = segmentWidth * CGFloat(i)
      // determine the line color
      switch xPosition {

      case _criticalPosition...:
        lineColor = _criticalColor

      default:
        lineColor = _frameColor
      }
      // create line with the required color
      lineColor.set()
      
      if xPosition == 0 || xPosition == frame.size.width { _framePath.lineWidth = 3 * _heightLine } else { _framePath.lineWidth = _heightLine }
      _framePath.vLine(at: xPosition, fromY: _barTopY, toY: _barBottomY)
      
      // Flip if required
      if _isFlipped { _framePath.transform(using: _transform) }
      
      _framePath.stroke()
      _framePath.removeAllPoints()
    }

    // ----- create the bar -----
    let levelPercent = ((level - _leftValue) / _range)
    
    _backgroundColor.set()
    
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

    // ----- create the peak -----
    
    let peakPercent = ((peak - _leftValue) / _range)
    
    var peakColor: NSColor
    
    // determine the peak color
    switch peakPercent {
    
    case _criticalPercent...:
      peakColor = _criticalColor
    
    case _warningPercent..._criticalPercent:
      peakColor = _warningColor
      
    default:
      peakColor = _normalColor
    }
    
    // append the peak section
    appendSection(at: peakPercent * dirtyRect.size.width, width: kPeakWidth, color: peakColor)

    // ----- draw the frame, bar & peak -----
    
    _path.stroke()
    _path.removeAllPoints()

    // ----- draw the legend -----
    
    drawLegends(legends)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Methods
  
  /// Create a section & append it
  ///
  /// - Parameters:
  ///   - position:               position of the level
  ///   - width:                  width of the bar
  ///   - color:                  color of the bar
  ///
  private func appendSection(at position: CGFloat, width: CGFloat, color: NSColor) {
    
    // construct its rect
    let rect = NSRect(origin: CGPoint(x: position, y: _barBottomY),
                      size: CGSize(width: width, height: _heightBar))
    // create & append the section
    _path.append( createBar(at: rect, color: color) )
  }
  /// Create a filled rect area
  ///
  /// - Parameters:
  ///   - rect:                   the area
  ///   - color:                  an NSColor
  /// - Returns:                  the filled NSBezierPath
  ///
  private func createBar(at rect: NSRect, color: NSColor) -> NSBezierPath {
    
    // create a path with the specified rect
    let path = NSBezierPath(rect: rect)

    // Flip if required
    if _isFlipped {
      path.transform(using: _transform)
    }
    // fill it with color
    color.setFill()
    path.fill()
    
    return path
  }
  /// Draw a legend at each vertical bar
  ///
  /// - Parameter legends:        an array of LegendTuple
  ///
  private func drawLegends(_ legends: [LegendTuple]) {

    let segmentWidth = frame.size.width / CGFloat(_numberOfSegments)
    
    // draw the legends
    for legend in legends {
      // is it a nrmal legend?
      if let tick = legend.tick {
        // YES, calculate the x coordinate of the legend
        let xPosition = CGFloat(tick) * segmentWidth
        
        // format & draw the legend
        let lineLabel = String(format: legend.format, legend.value )
        let width = lineLabel.size(withAttributes: _attributes).width
        lineLabel.draw(at: NSMakePoint(xPosition + (width * legend.fudge), _fontY), withAttributes: _attributes)
        
      } else {
        
        // NO, draw a centered legend
        let lineLabel = legend.format
        let width = lineLabel.size(withAttributes: _attributes).width
        let xPosition = (frame.size.width / 2.0) - (width / 2.0)
        lineLabel.draw(at: NSMakePoint(xPosition, _fontY), withAttributes: _attributes)
      }
    }
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
}
