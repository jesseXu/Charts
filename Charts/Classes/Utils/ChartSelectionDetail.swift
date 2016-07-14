//
//  ChartSelectionDetail.swift
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

public class ChartSelectionDetail: NSObject
{
    private var _x = CGFloat.NaN
    private var _y = CGFloat.NaN
    private var _xValue = Double(0)
    private var _yValue = Double(0)
    private var _dataIndex = Int(0)
    private var _dataSetIndex = Int(0)
    private var _dataSet: IChartDataSet!
    
    public override init()
    {
        super.init()
    }
    
    public init(x: CGFloat, y: CGFloat, xValue: Double, yValue: Double, dataIndex: Int, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        super.init()
        
        _x = x
        _y = y
        _xValue = xValue
        _yValue = yValue
        _dataIndex = dataIndex
        _dataSetIndex = dataSetIndex
        _dataSet = dataSet
    }
    
    public convenience init(x: CGFloat, y: CGFloat, xValue: Double, yValue: Double, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        self.init(x: x, y: y, xValue: xValue, yValue: yValue, dataIndex: 0, dataSetIndex: dataSetIndex, dataSet: dataSet)
    }
    
    public convenience init(xValue: Double, yValue: Double, dataSetIndex: Int, dataSet: IChartDataSet)
    {
        self.init(x: CGFloat.NaN, y: CGFloat.NaN, xValue: xValue, yValue: yValue, dataIndex: 0, dataSetIndex: dataSetIndex, dataSet: dataSet)
    }
    
    public var x: CGFloat
    {
        return _x
    }
    
    public var y: CGFloat
    {
        return _y
    }
    
    public var xValue: Double
    {
        return _xValue
    }
    
    public var yValue: Double
    {
        return _yValue
    }
    
    public var dataIndex: Int
    {
        return _dataIndex
    }
    
    public var dataSetIndex: Int
    {
        return _dataSetIndex
    }
    
    public var dataSet: IChartDataSet?
    {
        return _dataSet
    }
    
    // MARK: NSObject
    
    public override func isEqual(object: AnyObject?) -> Bool
    {
        if (object === nil)
        {
            return false
        }
        
        if (!object!.isKindOfClass(self.dynamicType))
        {
            return false
        }
        
        if (object!.xValue != _xValue)
        {
            return false
        }
        
        if (object!.yValue != _yValue)
        {
            return false
        }
        
        if (object!.dataSetIndex != _dataSetIndex)
        {
            return false
        }
        
        if (object!.dataSet !== _dataSet)
        {
            return false
        }
        
        return true
    }
}

public func ==(lhs: ChartSelectionDetail, rhs: ChartSelectionDetail) -> Bool
{
    if (lhs === rhs)
    {
        return true
    }
    
    if (!lhs.isKindOfClass(rhs.dynamicType))
    {
        return false
    }
    
    if (lhs.xValue != rhs.xValue)
    {
        return false
    }
    
    if (lhs.yValue != rhs.yValue)
    {
        return false
    }
    
    if (lhs.dataSetIndex != rhs.dataSetIndex)
    {
        return false
    }
    
    if (lhs.dataSet !== rhs.dataSet)
    {
        return false
    }
    
    return true
}
