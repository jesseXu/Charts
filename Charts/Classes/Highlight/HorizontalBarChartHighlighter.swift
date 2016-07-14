//
//  HorizontalBarChartHighlighter.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/7/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class HorizontalBarChartHighlighter: BarChartHighlighter
{
    public override func getHighlight(x x: CGFloat, y: CGFloat) -> ChartHighlight?
    {
        if let barData = self.chart?.data as? BarChartData
        {
            let xVal = Double(getValsForTouch(x: x, y: y).x)
            let baseNoSpace = getBase(x)
            let setCount = barData.dataSetCount
            var dataSetIndex = Int(baseNoSpace) % setCount
            
            if dataSetIndex < 0
            {
                dataSetIndex = 0
            }
            else if dataSetIndex >= setCount
            {
                dataSetIndex = setCount - 1
            }
            
            guard let selectionDetail = getSelectionDetail(xValue: xVal, x: x, y: y)
                else { return nil }
            
            if let set = barData.getDataSetByIndex(dataSetIndex) as? IBarChartDataSet
                where set.isStacked
            {
                var pt = CGPoint(x: y, y: 0.0)
                
                // take any transformer to determine the x-axis value
                self.chart?.getTransformer(set.axisDependency).pixelToValue(&pt)
                
                return getStackedHighlight(selectionDetail: selectionDetail,
                                           set: set,
                                           xValue: xVal,
                                           yValue: Double(pt.x))
            }
            
            return ChartHighlight(x: xVal,
                                  y: selectionDetail.yValue,
                                  dataIndex: selectionDetail.dataIndex,
                                  dataSetIndex: selectionDetail.dataSetIndex,
                                  stackIndex: -1)
        }
        return nil
    }
    
    /*public override func getXForTouch(x: CGFloat) -> Double
    {
        if let barData = self.chart?.data as? BarChartData
            where !barData.isGrouped
        {
            // create an array of the touch-point
            var pt = CGPoint(x: 0.0, y: x)
            
            // take any transformer to determine the x-axis value
            self.chart?.getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
            
            return Double(round(pt.y))
        }
        else
        {
            return super.getXForTouch(x)
        }
    }*/
    
    /// Returns the base y-value to the corresponding x-touch value in pixels.
    /// - parameter y:
    /// - returns:
    public func getBase(y: CGFloat) -> Double
    {
        if let barData = self.chart?.data as? BarChartData
        {
            // create an array of the touch-point
            var pt = CGPoint()
            pt.y = CGFloat(y)
            
            // take any transformer to determine the x-axis value
            self.chart?.getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
            let yVal = Double(pt.y)
            
            let setCount = barData.dataSetCount ?? 0
            
            // calculate how often the group-space appears
            let steps = Int(yVal / (Double(setCount) + Double(barData.groupSpace)))
            
            let groupSpaceSum = Double(barData.groupSpace) * Double(steps)
            
            let baseNoSpace = yVal - groupSpaceSum
            
            return baseNoSpace
        }
        else
        {
            return 0.0
        }
    }
}
