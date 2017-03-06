//
//  ChartView.swift
//  SwiftStockExample
//
//  Created by Mike Ackley on 5/28/15.
//  Copyright (c) 2015 Michael Ackley. All rights reserved.
//

import UIKit

protocol ChartViewDelegate {

    func didChangeTimeRange(range: ChartTimeRange)
}

class SSRadioButtonStyler: SSRadioButtonControllerDelegate {
    func didSelectButton(_ aButton: UIButton?) {
        aButton?.backgroundColor = UIColor.white
        aButton?.setTitleColor(UIColor(red: (127/255), green: (50/255), blue: (198/255), alpha: 1), for: UIControlState())
        aButton?.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
    }
    func didUnselectButton(_ aButton: UIButton?) {
        aButton?.backgroundColor = UIColor.clear
        aButton?.setTitleColor(UIColor.white, for: UIControlState())
        aButton?.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
    }
}

class ChartView: UIView {
    
    var delegate: ChartViewDelegate!
    @IBOutlet weak var stackedButtonView: UIStackView!
    var dateRangeButtonsController: SSRadioButtonsController!
    var dateRangeButtons: [UIButton]!
    var defaultDateRangeButton: UIButton!
    
    class func create() -> ChartView {
        let chartView = UINib(nibName: "ChartView", bundle:nil).instantiate(withOwner: nil, options: nil)[0] as! ChartView
        
        // set up radio button controller
        chartView.dateRangeButtons = chartView.stackedButtonView.subviews.filter{$0 is UIButton} as! [UIButton]
        chartView.defaultDateRangeButton = chartView.dateRangeButtons[0]
        chartView.dateRangeButtonsController = SSRadioButtonsController(buttons: chartView.dateRangeButtons)
        
        // initial radio button styles
        for button in chartView.dateRangeButtons {
            button.layer.cornerRadius = 15
        }
        
        // the delegate that handles styling of radio buttons when they're selected/deselected
        let styler = SSRadioButtonStyler()
        chartView.dateRangeButtonsController.delegate = styler
        
        return chartView
    }
    
    @IBAction func timeRangeBtnTapped(_ sender: AnyObject) {
        
        let btn = sender as! UIButton
        

        var range: ChartTimeRange = .oneDay
        
        switch btn.tag {
        case 1:
            range = .oneDay
        case 2:
            range = .fiveDays
        case 3:
            range = .tenDays
        case 4:
            range = .oneMonth
        case 5:
            range = .threeMonths
        case 6:
            range = .oneYear
        case 7:
            range = .fiveYears
        default:
            range = .oneDay
        }
        delegate.didChangeTimeRange(range: range)
        
        
    }
    
    
}
