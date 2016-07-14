//
//  ChartAxisRendererBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


public class ChartAxisRendererBase: ChartRendererBase
{
    public var transformer: ChartTransformer!
    
    public override init()
    {
        super.init()
    }
    
    public init(viewPortHandler: ChartViewPortHandler, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        self.transformer = transformer
    }
    
    /// Draws the axis labels on the specified context
    public func renderAxisLabels(context context: CGContext)
    {
        fatalError("renderAxisLabels() cannot be called on ChartAxisRendererBase")
    }
    
    /// Draws the grid lines belonging to the axis.
    public func renderGridLines(context context: CGContext)
    {
        fatalError("renderGridLines() cannot be called on ChartAxisRendererBase")
    }
    
    /// Draws the line that goes alongside the axis.
    public func renderAxisLine(context context: CGContext)
    {
        fatalError("renderAxisLine() cannot be called on ChartAxisRendererBase")
    }
    
    /// Draws the LimitLines associated with this axis to the screen.
    public func renderLimitLines(context context: CGContext)
    {
        fatalError("renderLimitLines() cannot be called on ChartAxisRendererBase")
    }
    
    /// Computes the axis values.
    /// - parameter min: the minimum value in the data object for this axis
    /// - parameter max: the maximum value in the data object for this axis
    public func computeAxis(min min: Double, max: Double, inverted: Bool)
    {
        var min = min, max = max
        
        // calculate the starting and entry point of the y-labels (depending on
        // zoom / contentrect bounds)
        if viewPortHandler.contentWidth > 10.0 && !viewPortHandler.isFullyZoomedOutY
        {
            let p1 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            
            if !inverted
            {
                min = Double(p2.y)
                max = Double(p1.y)
            }
            else
            {
                min = Double(p1.y)
                max = Double(p2.y)
            }
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    /// Sets up the axis values. Computes the desired number of labels between the two given extremes.
    public func computeAxisValues(min min: Double, max: Double)
    {
        fatalError("computeAxisValues(min, max) cannot be called on ChartAxisRendererBase")
    }
}