//
//  RealmCandleDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

import Charts
import Realm
import Realm.Dynamic

public class RealmCandleDataSet: RealmLineScatterCandleRadarDataSet, ICandleChartDataSet
{
    public override func initialize()
    {

    }
    
    public required init()
    {
        super.init()
    }

    public init(results: RLMResults?, highField: String, lowField: String, openField: String, closeField: String, xValueField: String, label: String?)
    {
        _highField = highField
        _lowField = lowField
        _openField = openField
        _closeField = closeField
        
        super.init(results: results, yValueField: "", xValueField: xValueField, label: label)
    }
    
    public convenience init(results: RLMResults?, highField: String, lowField: String, openField: String, closeField: String, xValueField: String)
    {
        self.init(results: results, highField: highField, lowField: lowField, openField: openField, closeField: closeField, xValueField: xValueField, label: "DataSet")
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, highField: String, lowField: String, openField: String, closeField: String, xValueField: String, label: String?)
    {
        _highField = highField
        _lowField = lowField
        _openField = openField
        _closeField = closeField
        
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: "", xValueField: xValueField, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    internal var _highField: String?
    internal var _lowField: String?
    internal var _openField: String?
    internal var _closeField: String?
    
    internal override func buildEntryFromResultObject(object: RLMObject, x: Double) -> ChartDataEntry
    {
        let entry = CandleChartDataEntry(
            x: _xValueField == nil ? x : object[_xValueField!] as! Double,
            shadowH: object[_highField!] as! Double,
            shadowL: object[_lowField!] as! Double,
            open: object[_openField!] as! Double,
            close: object[_closeField!] as! Double)
        
        return entry
    }
    
    public override func calcMinMax()
    {
        if _cache.count == 0
        {
            return
        }
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        _xMin = DBL_MAX
        _xMax = -DBL_MAX
        
        for e in _cache as [CandleChartDataEntry]
        {
            if (e.low < _yMin)
            {
                _yMin = e.low
            }
            
            if (e.high > _yMax)
            {
                _yMax = e.high
            }
            
            if e.x < _xMin
            {
                _xMin = e.y
            }
            if e.x > _xMax
            {
                _xMax = e.y
            }
        }
        
        if (_yMin == DBL_MAX)
        {
            _yMin = 0.0
            _yMax = 0.0
        }
        
        if (_xMin == DBL_MAX)
        {
            _xMin = 0.0
            _xMax = 0.0
        }
    }
    
    // MARK: - Styling functions and accessors
    
    /// the space between the candle entries
    ///
    /// **default**: 0.1 (10%)
    private var _barSpace = CGFloat(0.1)
    
    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    public var barSpace: CGFloat
    {
        set
        {
            if (newValue < 0.0)
            {
                _barSpace = 0.0
            }
            else if (newValue > 0.45)
            {
                _barSpace = 0.45
            }
            else
            {
                _barSpace = newValue
            }
        }
        get
        {
            return _barSpace
        }
    }
    
    /// should the candle bars show?
    /// when false, only "ticks" will show
    ///
    /// **default**: true
    public var showCandleBar: Bool = true
    
    /// the width of the candle-shadow-line in pixels.
    ///
    /// **default**: 3.0
    public var shadowWidth = CGFloat(1.5)
    
    /// the color of the shadow line
    public var shadowColor: NSUIColor?
    
    /// use candle color for the shadow
    public var shadowColorSameAsCandle = false
    
    /// Is the shadow color same as the candle color?
    public var isShadowColorSameAsCandle: Bool { return shadowColorSameAsCandle }
    
    /// color for open == close
    public var neutralColor: NSUIColor?
    
    /// color for open > close
    public var increasingColor: NSUIColor?
    
    /// color for open < close
    public var decreasingColor: NSUIColor?
    
    /// Are increasing values drawn as filled?
    /// increasing candlesticks are traditionally hollow
    public var increasingFilled = false
    
    /// Are increasing values drawn as filled?
    public var isIncreasingFilled: Bool { return increasingFilled }
    
    /// Are decreasing values drawn as filled?
    /// descreasing candlesticks are traditionally filled
    public var decreasingFilled = true
    
    /// Are decreasing values drawn as filled?
    public var isDecreasingFilled: Bool { return decreasingFilled }
}