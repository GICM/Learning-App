//
//  WorkLifeBalanceLineChartModel.swift
//  GICM
//
//  Created by Rafi on 03/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import Charts

class WorkLifeBalanceLineChartModel {
    class func plotLineChart(_ chart: LineChartView, xvaluesDouble: [Double],xvaluesString: [String], sleepValues: [Double],relaxValues: [Double],stressValues: [Double],workValues: [Double]) {
        var sleepDataEntries: [ChartDataEntry] = []
        var relaxDataEntries: [ChartDataEntry] = []
        var stressDataEntries: [ChartDataEntry] = []
        var workDataEntries: [ChartDataEntry] = []
        
        if xvaluesString.count == 1 {
            for i in 0..<xvaluesDouble.count { // Fixing single point error temp
                let sleepDataEntry = ChartDataEntry(x: Double(i), y: sleepValues[i])
                sleepDataEntries.append(sleepDataEntry)
                
                let relaxDataEntry = ChartDataEntry(x: Double(i), y: relaxValues[i])
                relaxDataEntries.append(relaxDataEntry)
                
                
                let stressDataEntry = ChartDataEntry(x: Double(i), y: stressValues[i])
                stressDataEntries.append(stressDataEntry)
                
                let workDataEntry = ChartDataEntry(x: Double(i), y: workValues[i])
                workDataEntries.append(workDataEntry)
            }
            chart.xAxis.labelCount = 1
            chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xvaluesString)
            chart.xAxis.axisMinimum = 0
            
            
        } else {
            for i in 0..<xvaluesDouble.count {
                let sleepDataEntry = ChartDataEntry(x: xvaluesDouble[i], y: sleepValues[i])
                sleepDataEntries.append(sleepDataEntry)
                
                let relaxDataEntry = ChartDataEntry(x: xvaluesDouble[i], y: relaxValues[i])
                relaxDataEntries.append(relaxDataEntry)
                
                
                let stressDataEntry = ChartDataEntry(x: xvaluesDouble[i], y: stressValues[i])
                stressDataEntries.append(stressDataEntry)
                
                let workDataEntry = ChartDataEntry(x: xvaluesDouble[i], y: workValues[i])
                workDataEntries.append(workDataEntry)
            }
            chart.xAxis.labelCount = 5
            chart.xAxis.valueFormatter = XaxisFormatterDate()
        }
        
        
        
        let sleepDataSet = LineChartDataSet(values: sleepDataEntries, label: "Sleep")
        sleepDataSet.setColor(UIColor.purple)
        sleepDataSet.mode = .linear
        sleepDataSet.drawCirclesEnabled = true
        sleepDataSet.lineWidth = 2.0
        sleepDataSet.circleRadius = 5.0
        sleepDataSet.circleColors = [UIColor.purple]
        sleepDataSet.highlightColor = UIColor.purple
        sleepDataSet.drawHorizontalHighlightIndicatorEnabled = true
        sleepDataSet.drawValuesEnabled = true
        
        
        let relaxDataSet = LineChartDataSet(values: relaxDataEntries, label: "Relax")
        relaxDataSet.setColor(UIColor.green)
        relaxDataSet.mode = .linear
        relaxDataSet.drawCirclesEnabled = true
        relaxDataSet.lineWidth = 2.0
        relaxDataSet.circleRadius = 5.0
        relaxDataSet.highlightColor = UIColor.green
        relaxDataSet.circleColors = [UIColor.green]
        relaxDataSet.drawHorizontalHighlightIndicatorEnabled = true
        relaxDataSet.drawValuesEnabled = false
        
        
        let stressDataSet = LineChartDataSet(values: stressDataEntries, label: "Stress")
        stressDataSet.setColor(UIColor.blue)
        stressDataSet.mode = .linear
        stressDataSet.drawCirclesEnabled = true
        stressDataSet.lineWidth = 2.0
        stressDataSet.circleRadius = 5.0
        stressDataSet.highlightColor = UIColor.blue
        stressDataSet.circleColors = [UIColor.blue]
        stressDataSet.drawHorizontalHighlightIndicatorEnabled = true
        stressDataSet.drawValuesEnabled = false
        
        let workDataSet = LineChartDataSet(values: workDataEntries, label: "Work")
        workDataSet.setColor(UIColor.red)
        workDataSet.mode = .linear
        workDataSet.drawCirclesEnabled = true
        workDataSet.lineWidth = 2.0
        workDataSet.circleRadius = 5.0
        workDataSet.highlightColor = UIColor.red
        workDataSet.circleColors = [UIColor.red]
        workDataSet.drawHorizontalHighlightIndicatorEnabled = true
        workDataSet.drawValuesEnabled = false
        
        var dataSets = [IChartDataSet]()
        dataSets.append(sleepDataSet)
        dataSets.append(relaxDataSet)
        dataSets.append(stressDataSet)
        dataSets.append(workDataSet)
        
        let lineChartData = LineChartData(dataSets: dataSets)
        chart.data = lineChartData
        
    
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = true
        chart.rightAxis.axisMinimum = 0
        chart.leftAxis.axisMinimum = 0
        
        //chart.xAxis.axisMinimum = 0
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = .bottom
        
        
        
        chart.drawGridBackgroundEnabled = false
        chart.chartDescription?.text = ""
        chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        
        /// Marker
        chart.drawMarkers = true
        let marker : BalloonMarker     = BalloonMarker.init(color: UIColor.blue, font: UIFont.systemFont(ofSize: 12), textColor: UIColor.white
            , insets: UIEdgeInsetsMake(8, 8, 20, 8),setBarChart:true)
        marker.minimumSize = CGSize(width: 80, height: 40)
        marker.chartView = chart
        chart.marker = marker
        
        
    }
}
