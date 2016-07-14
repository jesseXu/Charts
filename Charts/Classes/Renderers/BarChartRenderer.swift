//
//  BarChartRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

public class BarChartRenderer: ChartDataRendererBase
{
    public weak var dataProvider: BarChartDataProvider?
    
    public init(dataProvider: BarChartDataProvider?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let dataProvider = dataProvider, barData = dataProvider.barData else { return }
        
        for i in 0 ..< barData.dataSetCount
        {
            guard let set = barData.getDataSetByIndex(i) else { continue }
            
            if set.isVisible && set.entryCount > 0
            {
                if !(set is IBarChartDataSet)
                {
                    fatalError("Datasets for BarChartRenderer must conform to IBarChartDataset")
                }
                
                drawDataSet(context: context, dataSet: set as! IBarChartDataSet, index: i)
            }
        }
    }
    
    public func drawDataSet(context context: CGContext, dataSet: IBarChartDataSet, index: Int)
    {
        guard let
            dataProvider = dataProvider,
            barData = dataProvider.barData,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        let trans = dataProvider.getTransformer(dataSet.axisDependency)
        
        let drawBarShadowEnabled: Bool = dataProvider.isDrawBarShadowEnabled

        let barWidthHalf = barData.barWidth / 2.0
        
        let containsStacks = dataSet.isStacked
        let isInverted = dataProvider.isInverted(dataSet.axisDependency)
        let phaseY = animator.phaseY
        var barRect = CGRect()
        var barShadow = CGRect()
        let borderWidth = dataSet.barBorderWidth
        let borderColor = dataSet.barBorderColor
        let drawBorder = borderWidth > 0.0
        var x: Double
        var y: Double
        
        // do the drawing
        for j in 0 ..< Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
        {
            guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }
            
            var vals = e.yValues
            
            x = e.x
            y = e.y
            
            if !containsStacks || vals == nil
            {
                let left = CGFloat(x - barWidthHalf)
                let right = CGFloat(x + barWidthHalf)
                var top = isInverted
                    ? (y <= 0.0 ? CGFloat(y) : 0)
                    : (y >= 0.0 ? CGFloat(y) : 0)
                var bottom = isInverted
                    ? (y >= 0.0 ? CGFloat(y) : 0)
                    : (y <= 0.0 ? CGFloat(y) : 0)
                
                // multiply the height of the rect with the phase
                if (top > 0)
                {
                    top *= phaseY
                }
                else
                {
                    bottom *= phaseY
                }
                
                barRect.origin.x = left
                barRect.size.width = right - left
                barRect.origin.y = top
                barRect.size.height = bottom - top
                
                trans.rectValueToPixel(&barRect)
                
                if (!viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                {
                    continue
                }
                
                if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                {
                    break
                }
                
                // if drawing the bar shadow is enabled
                if drawBarShadowEnabled
                {
                    barShadow.origin.x = barRect.origin.x
                    barShadow.origin.y = viewPortHandler.contentTop
                    barShadow.size.width = barRect.size.width
                    barShadow.size.height = viewPortHandler.contentHeight
                    
                    CGContextSetFillColorWithColor(context, dataSet.barShadowColor.CGColor)
                    CGContextFillRect(context, barShadow)
                }
                
                // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
                CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor)
                CGContextFillRect(context, barRect)
                
                if drawBorder
                {
                    CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
                    CGContextSetLineWidth(context, borderWidth)
                    CGContextStrokeRect(context, barRect)
                }
            }
            else
            {
                var posY = 0.0
                var negY = -e.negativeSum
                var yStart = 0.0
                
                // if drawing the bar shadow is enabled
                if drawBarShadowEnabled
                {
                    y = e.y
                    
                    let left = CGFloat(x - barWidthHalf)
                    let right = CGFloat(x + barWidthHalf)
                    var top = isInverted
                        ? (y <= 0.0 ? CGFloat(y) : 0)
                        : (y >= 0.0 ? CGFloat(y) : 0)
                    var bottom = isInverted
                        ? (y >= 0.0 ? CGFloat(y) : 0)
                        : (y <= 0.0 ? CGFloat(y) : 0)
                    
                    // multiply the height of the rect with the phase
                    if (top > 0)
                    {
                        top *= phaseY
                    }
                    else
                    {
                        bottom *= phaseY
                    }
                    
                    barRect.origin.x = left
                    barRect.size.width = right - left
                    barRect.origin.y = top
                    barRect.size.height = bottom - top
                    
                    trans.rectValueToPixel(&barRect)
                    
                    barShadow.origin.x = barRect.origin.x
                    barShadow.origin.y = viewPortHandler.contentTop
                    barShadow.size.width = barRect.size.width
                    barShadow.size.height = viewPortHandler.contentHeight
                    
                    CGContextSetFillColorWithColor(context, dataSet.barShadowColor.CGColor)
                    CGContextFillRect(context, barShadow)
                }
                
                // fill the stack
                for k in 0 ..< vals!.count
                {
                    let value = vals![k]
                    
                    if value >= 0.0
                    {
                        y = posY
                        yStart = posY + value
                        posY = yStart
                    }
                    else
                    {
                        y = negY
                        yStart = negY + abs(value)
                        negY += abs(value)
                    }
                    
                    let left = CGFloat(x - barWidthHalf)
                    let right = CGFloat(x + barWidthHalf)
                    var top = isInverted
                        ? (y <= yStart ? CGFloat(y) : CGFloat(yStart))
                        : (y >= yStart ? CGFloat(y) : CGFloat(yStart))
                    var bottom = isInverted
                        ? (y >= yStart ? CGFloat(y) : CGFloat(yStart))
                        : (y <= yStart ? CGFloat(y) : CGFloat(yStart))
                    
                    // multiply the height of the rect with the phase
                    top *= phaseY
                    bottom *= phaseY
                    
                    barRect.origin.x = left
                    barRect.size.width = right - left
                    barRect.origin.y = top
                    barRect.size.height = bottom - top
                    
                    trans.rectValueToPixel(&barRect)
                    
                    if (k == 0 && !viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                    {
                        // Skip to next bar
                        break
                    }
                    
                    // avoid drawing outofbounds values
                    if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                    {
                        break
                    }
                    
                    // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
                    CGContextSetFillColorWithColor(context, dataSet.colorAt(k).CGColor)
                    CGContextFillRect(context, barRect)
                    
                    if drawBorder
                    {
                        CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
                        CGContextSetLineWidth(context, borderWidth)
                        CGContextStrokeRect(context, barRect)
                    }
                }
            }
        }
        
        CGContextRestoreGState(context)
    }

    /// Prepares a bar for being highlighted.
    public func prepareBarHighlight(y1 y1: Double, y2: Double, interval: CGFloat,
                                       entryIndex: Int, dataSetIndex: Int, dataSetCount: Int,
                                       barSpace: CGFloat, groupSpace: CGFloat, trans: ChartTransformer, inout rect: CGRect)
    {
        let barWidth = interval / CGFloat(dataSetCount)
            
        let groupSpaceWidth = dataSetCount <= 1 ? 0.0 : barWidth + groupSpace
        let newInterval = interval - groupSpaceWidth
        let newBarWidth = newInterval / CGFloat(dataSetCount)
        
        let barSpaceWidth = newBarWidth * barSpace
        let barSpaceWidthHalf = barSpaceWidth / 2.0
                
        let groupSpaceWidthHalf = groupSpaceWidth / 2.0
        let dataSetSpace = dataSetCount <= 1
            ? 0.0
            : ((newInterval / CGFloat(dataSetCount)) * CGFloat(dataSetIndex))
            
        let x = interval * CGFloat(entryIndex) * dataSetSpace
        
        let left = x + groupSpaceWidthHalf + barSpaceWidthHalf
        let right = left + newBarWidth - barSpaceWidth
        let top = CGFloat(y1)
        let bottom = CGFloat(y2)
        
        rect.origin.x = left
        rect.origin.y = top
        rect.size.width = right - left
        rect.size.height = bottom - top
        
        trans.rectValueToPixel(&rect, phaseY: animator?.phaseY ?? 1.0)
    }
    
    private func prepareBarHighlight(x x: Double, y1: Double, y2: Double, barWidthHalf: Double, trans: ChartTransformer, inout rect: CGRect)
    {
        let left = x - barWidthHalf
        let right = x + barWidthHalf
        let top = y1
        let bottom = y2
        
        rect.origin.x = CGFloat(left)
        rect.origin.y = CGFloat(top)
        rect.size.width = CGFloat(right - left)
        rect.size.height = CGFloat(bottom - top)
        
        trans.rectValueToPixel(&rect, phaseY: animator?.phaseY ?? 1.0)
    }

    public override func drawValues(context context: CGContext)
    {
        // if values are drawn
        if (passesCheck())
        {
            guard let
                dataProvider = dataProvider,
                barData = dataProvider.barData,
                animator = animator
                else { return }
            
            var dataSets = barData.dataSets
            
            let drawValueAboveBar = dataProvider.isDrawValueAboveBarEnabled

            var posOffset: CGFloat
            var negOffset: CGFloat
            
            for dataSetIndex in 0 ..< barData.dataSetCount
            {
                guard let dataSet = dataSets[dataSetIndex] as? IBarChartDataSet else { continue }
                
                if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
                {
                    continue
                }
                
                let isInverted = dataProvider.isInverted(dataSet.axisDependency)
                
                // calculate the correct offset depending on the draw position of the value
                let valueOffsetPlus: CGFloat = 4.5
                let valueFont = dataSet.valueFont
                let valueTextHeight = valueFont.lineHeight
                posOffset = (drawValueAboveBar ? -(valueTextHeight + valueOffsetPlus) : valueOffsetPlus)
                negOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextHeight + valueOffsetPlus))
                
                if (isInverted)
                {
                    posOffset = -posOffset - valueTextHeight
                    negOffset = -negOffset - valueTextHeight
                }
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                
                let phaseY = animator.phaseY
                let dataSetCount = barData.dataSetCount
                let groupSpace = barData.groupSpace
                
                // if only single values are drawn (sum)
                if (!dataSet.isStacked)
                {
                    for j in 0 ..< Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
                    {
                        guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }
                        
                        let valuePoint = trans.getTransformedValueBarChart(
                            entry: e,
                            dataSetIndex: dataSetIndex,
                            phaseY: phaseY,
                            dataSetCount: dataSetCount,
                            groupSpace: groupSpace
                        )
                        
                        if (!viewPortHandler.isInBoundsRight(valuePoint.x))
                        {
                            break
                        }
                        
                        if (!viewPortHandler.isInBoundsY(valuePoint.y)
                            || !viewPortHandler.isInBoundsLeft(valuePoint.x))
                        {
                            continue
                        }
                        
                        let val = e.y

                        drawValue(context: context,
                            value: formatter.stringFromNumber(val)!,
                            xPos: valuePoint.x,
                            yPos: valuePoint.y + (val >= 0.0 ? posOffset : negOffset),
                            font: valueFont,
                            align: .Center,
                            color: dataSet.valueTextColorAt(j))
                    }
                }
                else
                {
                    // if we have stacks
                    
                    for index in 0 ..< Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
                    {
                        guard let e = dataSet.entryForIndex(index) as? BarChartDataEntry else { continue }
                        
                        let values = e.yValues
                        
                        let valuePoint = trans.getTransformedValueBarChart(entry: e, dataSetIndex: dataSetIndex, phaseY: phaseY, dataSetCount: dataSetCount, groupSpace: groupSpace)
                        
                        // we still draw stacked bars, but there is one non-stacked in between
                        if (values == nil)
                        {
                            if (!viewPortHandler.isInBoundsRight(valuePoint.x))
                            {
                                break
                            }
                            
                            if (!viewPortHandler.isInBoundsY(valuePoint.y)
                                || !viewPortHandler.isInBoundsLeft(valuePoint.x))
                            {
                                continue
                            }
                            
                            drawValue(context: context,
                                value: formatter.stringFromNumber(e.y)!,
                                xPos: valuePoint.x,
                                yPos: valuePoint.y + (e.y >= 0.0 ? posOffset : negOffset),
                                font: valueFont,
                                align: .Center,
                                color: dataSet.valueTextColorAt(index))
                        }
                        else
                        {
                            // draw stack values
                            
                            let vals = values!
                            var transformed = [CGPoint]()
                            
                            var posY = 0.0
                            var negY = -e.negativeSum
                            
                            for k in 0 ..< vals.count
                            {
                                let value = vals[k]
                                var y: Double
                                
                                if value >= 0.0
                                {
                                    posY += value
                                    y = posY
                                }
                                else
                                {
                                    y = negY
                                    negY -= value
                                }
                                
                                transformed.append(CGPoint(x: 0.0, y: CGFloat(y) * animator.phaseY))
                            }
                            
                            trans.pointValuesToPixel(&transformed)
                            
                            for k in 0 ..< transformed.count
                            {
                                let x = valuePoint.x
                                let y = transformed[k].y + (vals[k] >= 0 ? posOffset : negOffset)
                                
                                if (!viewPortHandler.isInBoundsRight(x))
                                {
                                    break
                                }
                                
                                if (!viewPortHandler.isInBoundsY(y) || !viewPortHandler.isInBoundsLeft(x))
                                {
                                    continue
                                }
                                
                                drawValue(context: context,
                                    value: formatter.stringFromNumber(vals[k])!,
                                    xPos: x,
                                    yPos: y,
                                    font: valueFont,
                                    align: .Center,
                                    color: dataSet.valueTextColorAt(index))
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Draws a value at the specified x and y position.
    public func drawValue(context context: CGContext, value: String, xPos: CGFloat, yPos: CGFloat, font: NSUIFont, align: NSTextAlignment, color: NSUIColor)
    {
        ChartUtils.drawText(context: context, text: value, point: CGPoint(x: xPos, y: yPos), align: align, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color])
    }
    
    public override func drawExtras(context context: CGContext)
    {
        
    }
    
    private var _highlightArrowPtsBuffer = [CGPoint](count: 3, repeatedValue: CGPoint())
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        guard let
            dataProvider = dataProvider,
            barData = dataProvider.barData,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        let setCount = barData.dataSetCount
        let drawHighlightArrowEnabled = dataProvider.isDrawHighlightArrowEnabled
        var barRect = CGRect()
        
        for high in indices
        {
            let minDataSetIndex = high.dataSetIndex == -1 ? 0 : high.dataSetIndex
            let maxDataSetIndex = high.dataSetIndex == -1 ? barData.dataSetCount : (high.dataSetIndex + 1)
            if maxDataSetIndex - minDataSetIndex < 1 { continue }
            
            for dataSetIndex in minDataSetIndex..<maxDataSetIndex
            {
                guard let set = barData.getDataSetByIndex(dataSetIndex) as? IBarChartDataSet else { continue }
                
                if (!set.isHighlightEnabled)
                {
                    continue
                }
                
                let trans = dataProvider.getTransformer(set.axisDependency)
                
                CGContextSetFillColorWithColor(context, set.highlightColor.CGColor)
                CGContextSetAlpha(context, set.highlightAlpha)
                
                let x = high.x
                
                if let e = set.entryForXPos(x) as? BarChartDataEntry
                {
                    let entryIndex = set.entryIndex(entry: e)
                    
                    let isStack = high.stackIndex < 0 ? false : true
                    
                    let y1: Double
                    let y2: Double
                    
                    if (isStack)
                    {
                        y1 = high.range?.from ?? 0.0
                        y2 = high.range?.to ?? 0.0
                    }
                    else
                    {
                        y1 = e.y
                        y2 = 0.0
                    }
                    
                    prepareBarHighlight(x: e.x, y1: y1, y2: y2, barWidthHalf: barData.barWidth / 2.0, trans: trans, rect: &barRect)

                    // prepareBarHighlight(y1: y1, y2: y2, interval: interval, entryIndex: entryIndex, dataSetIndex: dataSetIndex, dataSetCount: setCount, barSpace: barSpace, groupSpace: groupSpace, trans: trans, rect: &barRect)
                    
                    CGContextFillRect(context, barRect)
                    
                    /*if (drawHighlightArrowEnabled)
                    {
                        CGContextSetAlpha(context, 1.0)
                        
                        // distance between highlight arrow and bar
                        let offsetY = animator.phaseY * 0.07
                        
                        CGContextSaveGState(context)
                        
                        let pixelToValueMatrix = trans.pixelToValueMatrix
                        let xToYRel = abs(sqrt(pixelToValueMatrix.b * pixelToValueMatrix.b + pixelToValueMatrix.d * pixelToValueMatrix.d) / sqrt(pixelToValueMatrix.a * pixelToValueMatrix.a + pixelToValueMatrix.c * pixelToValueMatrix.c))
                        
                        let arrowWidth = set.barSpace / 2.0
                        let arrowHeight = arrowWidth * xToYRel
                        
                        let yArrow = (y1 > -y2 ? y1 : y1) * Double(animator.phaseY)
                        
                        _highlightArrowPtsBuffer[0].x = CGFloat(x) + 0.4
                        _highlightArrowPtsBuffer[0].y = CGFloat(yArrow) + offsetY
                        _highlightArrowPtsBuffer[1].x = CGFloat(x) + 0.4 + arrowWidth
                        _highlightArrowPtsBuffer[1].y = CGFloat(yArrow) + offsetY - arrowHeight
                        _highlightArrowPtsBuffer[2].x = CGFloat(x) + 0.4 + arrowWidth
                        _highlightArrowPtsBuffer[2].y = CGFloat(yArrow) + offsetY + arrowHeight
                        
                        trans.pointValuesToPixel(&_highlightArrowPtsBuffer)
                        
                        CGContextBeginPath(context)
                        CGContextMoveToPoint(context, _highlightArrowPtsBuffer[0].x, _highlightArrowPtsBuffer[0].y)
                        CGContextAddLineToPoint(context, _highlightArrowPtsBuffer[1].x, _highlightArrowPtsBuffer[1].y)
                        CGContextAddLineToPoint(context, _highlightArrowPtsBuffer[2].x, _highlightArrowPtsBuffer[2].y)
                        CGContextClosePath(context)
                        
                        CGContextFillPath(context)
                        
                        CGContextRestoreGState(context)
                    }*/
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    internal func passesCheck() -> Bool
    {
        guard let dataProvider = dataProvider, barData = dataProvider.barData else { return false }
        
        return CGFloat(barData.yValCount) < CGFloat(dataProvider.maxVisibleValueCount) * viewPortHandler.scaleX
    }
}