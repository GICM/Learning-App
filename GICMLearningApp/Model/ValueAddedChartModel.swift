//
//  ValueAddedChartModel.swift
//  GICM
//
//  Created by Rafi on 02/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import Charts

class ValueAddedChartModel {
    class func plotVerticalBarChart(xAxisValue:[String],yAxisValue:[Double],chart:BarChartView) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<yAxisValue.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: yAxisValue[i])
            dataEntries.append(dataEntry)
        }
        
        let barChartSet = BarChartDataSet(values: dataEntries, label: "Value Added")
        barChartSet.axisDependency = .left
        let data = BarChartData(dataSet: barChartSet)
        chart.data = data
        
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisValue)
        chart.xAxis.labelPosition = .bottom
        
        chart.xAxis.granularityEnabled = true
        chart.xAxis.granularity = 1
        chart.xAxis.avoidFirstLastClippingEnabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        
        chart.xAxis.drawLabelsEnabled = true
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelCount = 4
       // chart.xAxis.axisMinimum = -0.1
        
        chart.leftAxis.axisMinimum = 0
        chart.rightAxis.axisMinimum = 0
        chart.leftAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        

        chart.drawGridBackgroundEnabled = false
        chart.layer.masksToBounds = true
        chart.layer.cornerRadius = 5
        chart.legend.enabled = true
        chart.chartDescription?.text = ""
        chart.setExtraOffsets(left: 0, top: 35, right: 10, bottom: 40)
        
        chart.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        chart.leftAxis.labelFont = .boldSystemFont(ofSize:12)
        
        data.barWidth = 0.2
        barChartSet.valueFont = .boldSystemFont(ofSize:0)
        
        
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = true
        //chart.drawValueAboveBarEnabled = false
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

