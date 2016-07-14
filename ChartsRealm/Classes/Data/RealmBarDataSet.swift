//
//  RealmBarDataSet.swift
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

public class RealmBarDataSet: RealmBarLineScatterCandleBubbleDataSet, IBarChartDataSet
{
    public override func initialize()
    {
        self.highlightColor = NSUIColor.blackColor()
    }
    
    public required init()
    {
        super.init()
    }
    
    public override init(results: RLMResults?, yValueField: String, xValueField: String?, label: String?)
    {
        super.init(results: results, yValueField: yValueField, xValueField: xValueField, label: label)
    }
    
    public init(results: RLMResults?, yValueField: String, xValueField: String?, stackValueField: String, label: String?)
    {
        _stackValueField = stackValueField
        
        super.init(results: results, yValueField: yValueField, xValueField: xValueField, label: label)
    }
    
    public convenience init(results: RLMResults?, yValueField: String, xValueField: String?, stackValueField: String)
    {
        self.init(results: results, yValueField: yValueField, xValueField: xValueField, stackValueField: stackValueField, label: "DataSet")
    }
    
    public convenience init(results: RLMResults?, yValueField: String, stackValueField: String, label: String)
    {
        self.init(results: results, yValueField: yValueField, xValueField: nil, stackValueField: stackValueField, label: label)
    }
    
    public convenience init(results: RLMResults?, yValueField: String, stackValueField: String)
    {
        self.init(results: results, yValueField: yValueField, xValueField: nil, stackValueField: stackValueField)
    }
    
    public override init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xValueField: String?, label: String?)
    {
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xValueField: xValueField, label: label)
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xValueField: String?, stackValueField: String, label: String?)
    {
        _stackValueField = stackValueField
        
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xValueField: xValueField, label: label)
    }
    
    public convenience init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xValueField: String?, stackValueField: String)
    {
        self.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xValueField: nil, stackValueField: stackValueField)
    }
    
    public convenience init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, stackValueField: String, label: String?)
    {
        self.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xValueField: nil, stackValueField: stackValueField, label: label)
    }
    
    public convenience init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, stackValueField: String)
    {
        self.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xValueField: nil, stackValueField: stackValueField, label: nil)
    }
    
    public override func notifyDataSetChanged()
    {
        super.calcMinMax()
        self.calcStackSize(_cache as! [BarChartDataEntry])
    }
    
    // MARK: - Data functions and accessors
    
    internal var _stackValueField: String?
    
    /// the maximum number of bars that are stacked upon each other, this value
    /// is calculated from the Entries that are added to the DataSet
    private var _stackSize = 1
    
    internal override func buildEntryFromResultObject(object: RLMObject, x: Double) -> ChartDataEntry
    {
        let value = object[_yValueField!]
        let entry: BarChartDataEntry
        
        if value is RLMArray
        {
            var values = [Double]()
            for val in value as! RLMArray
            {
                values.append((val as! RLMObject)[_stackValueField!] as! Double)
            }
            entry = BarChartDataEntry(x: _xValueField == nil ? x : object[_xValueField!] as! Double, yValues: values)
        }
        else
        {
            entry = BarChartDataEntry(x: _xValueField == nil ? x : object[_xValueField!] as! Double, y: value as! Double)
        }
        
        return entry
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    private func calcStackSize(yVals: [BarChartDataEntry]!)
    {
        for i in 0 ..< yVals.count
        {
            if let vals = yVals[i].ys
            {
                if vals.count > _stackSize
                {
                    _stackSize = vals.count
                }
            }
        }
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
        
        for e in _cache as [BarChartDataEntry]
        {
            if !e.y.isNaN
            {
                if e.ys == nil
                {
                    if e.y < _yMin
                    {
                        _yMin = e.y
                    }
                    
                    if e.y > _yMax
                    {
                        _yMax = e.y
                    }
                }
                else
                {
                    if -e.negativeSum < _yMin
                    {
                        _yMin = -e.negativeSum
                    }
                    
                    if e.positiveSum > _yMax
                    {
                        _yMax = e.positiveSum
                    }
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
    
    /// - returns: the maximum number of bars that can be stacked upon another in this DataSet.
    public var stackSize: Int
    {
        return _stackSize
    }
    
    /// - returns: true if this DataSet is stacked (stacksize > 1) or not.
    public var isStacked: Bool
    {
        return _stackSize > 1 ? true : false
    }
    
    /// array of labels used to describe the different values of the stacked bars
    public var stackLabels: [String] = ["Stack"]
    
    // MARK: - Styling functions and accessors
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    public var barShadowColor = NSUIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)

    /// the width used for drawing borders around the bars. If borderWidth == 0, no border will be drawn.
    public var barBorderWidth : CGFloat = 0.0

    /// the color drawing borders around the bars.
    public var barBorderColor = NSUIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)

    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    public var highlightAlpha = CGFloat(120.0 / 255.0)
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmBarDataSet
        copy._stackSize = _stackSize
        copy.stackLabels = stackLabels
        copy.barShadowColor = barShadowColor
        copy.highlightAlpha = highlightAlpha
        return copy
    }
}