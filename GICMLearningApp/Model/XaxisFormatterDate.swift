//
//  xAxisFormatter.swift
//  GICM
//
//  Created by Rafi on 03/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import Charts
class XaxisFormatterDate: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
