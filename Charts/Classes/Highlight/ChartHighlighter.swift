//
//  ChartHighlighter.swift
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

public class ChartHighlighter : NSObject
{
    /// instance of the data-provider
    public weak var chart: BarLineChartViewBase?
    
    public init(chart: BarLineChartViewBase)
    {
        self.chart = chart
    }
    
    /// Returns a Highlight object corresponding to the given x- and y- touch positions in pixels.
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    public func getHighlight(x x: CGFloat, y: CGFloat) -> ChartHighlight?
    {
        let xVal = Double(getValsForTouch(x: x, y: y).x)
        
        guard let
            selectionDetail = getSelectionDetail(xValue: xVal, x: x, y: y)
            else { return nil }
        
        return ChartHighlight(
            x: selectionDetail.xValue,
            y: selectionDetail.yValue,
            dataIndex: selectionDetail.dataIndex,
            dataSetIndex: selectionDetail.dataSetIndex,
            stackIndex: -1)
    }
    
    /// Returns the corresponding x-pos for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    public func getValsForTouch(x x: CGFloat, y: CGFloat) -> CGPoint
    {
        guard let chart = self.chart
            else { return CGPointZero }
        
        // take any transformer to determine the values
        return chart.getTransformer(ChartYAxis.AxisDependency.Left).getValueByTouchPoint(x: x, y: y)
    }
    
    /// Returns the corresponding ChartSelectionDetail for a given x-value and xy-touch position in pixels.
    /// - parameter xValue:
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    public func getSelectionDetail(xValue xVal: Double, x: CGFloat, y: CGFloat) -> ChartSelectionDetail?
    {
        let valsAtIndex = getSelectionDetailsAtIndex(xVal)
        
        let leftdist = ChartUtils.getMinimumDistance(valsAtIndex, y: y, axis: ChartYAxis.AxisDependency.Left)
        let rightdist = ChartUtils.getMinimumDistance(valsAtIndex, y: y, axis: ChartYAxis.AxisDependency.Right)
        
        let axis = leftdist < rightdist ? ChartYAxis.AxisDependency.Left : ChartYAxis.AxisDependency.Right
        
        let detail = ChartUtils.closestSelectionDetailByPixel(valsAtIndex: valsAtIndex, x: x, y: y, axis: axis)
        
        return detail
    }
    
    /// Returns a list of SelectionDetail object corresponding to the given x-value.
    /// - parameter xValue:
    /// - returns:
    public func getSelectionDetailsAtIndex(xValue: Double) -> [ChartSelectionDetail]
    {
        var vals = [ChartSelectionDetail]()
        
        guard let
            data = self.chart?.data
            else { return vals }
        
        for i in 0 ..< data.dataSetCount
        {
            let dataSet = data.getDataSetByIndex(i)
            
            // dont include datasets that cannot be highlighted
            if !dataSet.isHighlightEnabled
            {
                continue
            }
            
            // extract all y-values from all DataSets at the given x-value.
            // some datasets (i.e bubble charts) make sense to have multiple values for an x-value.
            // FIXME: Update in Android
            vals.appendContentsOf(getDetails(dataSet, dataSetIndex: i, xValue: xValue))
        }
        
        return vals
    }
    
    private func getDetails(set: IChartDataSet, dataSetIndex: Int, xValue: Double) -> [ChartSelectionDetail]
    {
        var details = [ChartSelectionDetail]()
        
        guard let chart = self.chart
            else { return details }
        
        let entries = set.entriesForXPos(xValue)
        
        for e in entries
        {
            let px = chart.getTransformer(set.axisDependency).pixelForValue(x: e.x, y: e.y)
            
            details.append(ChartSelectionDetail(x: px.x, y: px.y, xValue: e.x, yValue: e.y, dataSetIndex: dataSetIndex, dataSet: set))
        }
        
        return details;
    }

}
