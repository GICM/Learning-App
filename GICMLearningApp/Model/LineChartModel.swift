//
//  LineChartModel.swift
//  GICM
//
//  Created by Rafi on 04/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import Charts


class ChartModel {
    class func plotSingleLineChart(_ chart: LineChartView, xAxisValuesString: [String], xAxisValuesDouble: [Double],yAxisValue: [Double],legendName: String) {
        var dataEntries: [ChartDataEntry] = []
        
        
        
        if xAxisValuesString.count == 1 { //handle single value issues temp
            for i in 0..<xAxisValuesString.count {
                let dataEntry = ChartDataEntry(x: Double(i), y: yAxisValue[i])
                dataEntries.append(dataEntry)
            }
            chart.xAxis.labelCount = 1
            chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisValuesString)
            chart.xAxis.axisMinimum = 0
            
        } else {
            for i in 0..<xAxisValuesDouble.count {
                let dataEntry = ChartDataEntry(x: xAxisValuesDouble[i], y: yAxisValue[i])
                dataEntries.append(dataEntry)
            }
            chart.xAxis.labelCount = 4
            chart.xAxis.valueFormatter = XaxisFormatterDate()
        }
        
        
        let sleepDataSet = LineChartDataSet(values: dataEntries, label: "\(legendName)")
        sleepDataSet.setColor(UIColor.purple)
        sleepDataSet.mode = .linear
        sleepDataSet.drawCirclesEnabled = true
        sleepDataSet.lineWidth = 2.0
        sleepDataSet.circleRadius = 5.0
        sleepDataSet.circleColors = [UIColor.purple]
        sleepDataSet.highlightColor = UIColor.purple
        sleepDataSet.drawHorizontalHighlightIndicatorEnabled = true
        sleepDataSet.drawValuesEnabled = true
        
        var dataSets = [IChartDataSet]()
        dataSets.append(sleepDataSet)
        
        let lineChartData = LineChartData(dataSets: dataSets)
        chart.data = lineChartData
        
        
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = true
//        chart.rightAxis.axisMinimum = 0
//        chart.leftAxis.axisMinimum = 0
        
        
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = .bottom
        
        
        
        chart.drawGridBackgroundEnabled = false
        chart.chartDescription?.text = ""
        chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        chart.xAxis.axisLineColor = UIColor.black
        chart.xAxis.axisLineWidth = 0.8
        
        
        /// Marker
        chart.drawMarkers = true
        let marker : BalloonMarker     = BalloonMarker.init(color: UIColor.blue, font: UIFont.systemFont(ofSize: 12), textColor: UIColor.white
            , insets: UIEdgeInsetsMake(8, 8, 20, 8),setBarChart:true)
        marker.minimumSize = CGSize(width: 80, height: 40)
        marker.chartView = chart
        chart.marker = marker
    }
}


