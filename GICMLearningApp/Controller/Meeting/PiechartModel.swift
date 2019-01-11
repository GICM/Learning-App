//
//  PiechartModel.swift
//  Aconex
//
//  Created by Rafi on 15/06/17.
//  Copyright © 2017 Rafi. All rights reserved.
//

import UIKit
import Charts

class PiechartModel: NSObject,ChartViewDelegate
{
     func setPiechartData(yaxisValues: [String],chartNo: Int, pieChartViewArray:[PieChartView])
    {
        
        var yValues:[ChartDataEntry] = [ChartDataEntry]()
        print(yaxisValues)

        for i in 0..<(yaxisValues.count)
        {
            if Double(yaxisValues[i]) != 0.0 || Double(yaxisValues[i]) != 0  // Temporary Solution Need to Re-Struture Full(3 Array in 1 array) Array into separate
            {
                let dataEntry = PieChartDataEntry(value: Double(yaxisValues[i])!, label: "Meeting")
                yValues.append(dataEntry)
            }
            
        }
        
        var colors: [UIColor] = []
        
        for i in 0..<yaxisValues.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        
        let dataSet: PieChartDataSet = PieChartDataSet(values: yValues, label:"")
        dataSet.sliceSpace = 5
        dataSet.selectionShift = 7.0
        dataSet.colors = colors
        dataSet.yValuePosition = .insideSlice
        dataSet.entryLabelColor = .clear
        dataSet.axisDependency =  .left
        
        
        
        dataSet.drawValuesEnabled = true
        dataSet.valueLineVariableLength = true
        let data: PieChartData = PieChartData(dataSet: dataSet)
        data.setValueTextColor(UIColor.white)
        
        let chart = pieChartViewArray[chartNo]
        chart.data = data
        chart.rotationAngle = 175.0
        chart.drawHoleEnabled = false
        chart.chartDescription?.text="" //Chart Data
        chart.legend.enabled = true
        chart.noDataText="No data or Empty data provided"
        chart.data?.setDrawValues(true)
        chart.animate(xAxisDuration: 2, yAxisDuration: 2)
        chart.layer.cornerRadius = 12
        chart.rotationAngle = 270
        chart.delegate = PiechartModel()
        
        
        let  legent = chart.legend
        legent.textColor = .black
        
        legent.orientation = .horizontal
        legent.verticalAlignment = .bottom
        legent.horizontalAlignment = .left
        legent.yEntrySpace = 10
        legent.xEntrySpace = 10
        legent.yOffset = 15
        
        let format = NumberFormatter()
        format.numberStyle = .percent
        format.maximumFractionDigits = 1
        format.multiplier = 1
        format.zeroSymbol = ""
        chart.data?.setValueFormatter(DefaultValueFormatter(formatter: format))
    }
    
    // MARK: - Chart Delegates
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        print("Chart is Selected")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase)
    {
        print("Chart is unselected")
    }
    
}
