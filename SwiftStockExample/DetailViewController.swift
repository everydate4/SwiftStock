//
//  DetailViewController.swift
//  SwiftStockExample
//
//  Created by Mike Ackley on 5/5/15.
//  Copyright (c) 2015 Michael Ackley. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ChartViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var stockSymbol: String = String()
    var stock: Stock?
    var chartView: ChartView!
    var chart: SwiftStockChart!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.title = stockSymbol
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "StockDataCell", bundle: Bundle.main), forCellWithReuseIdentifier: "stockDataCell")
        automaticallyAdjustsScrollViewInsets = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.contentInset = UIEdgeInsetsMake(250, 0, 0, 0) // leaves space from top, so stats start N px below top of screen
        
        
        chartView = ChartView.create()
        // chartView.backgroundColor = UIColor.yellow // debug
        chartView.delegate = self
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        chartView.frame.size.width = collectionView.bounds.size.width // set chartView width responsively http://stackoverflow.com/questions/37725406/how-to-set-uiview-size-to-match-parrent-without-constraints-programmatically/37725903
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // added because of http://stackoverflow.com/questions/37725406/how-to-set-uiview-size-to-match-parrent-without-constraints-programmatically/37725903
        collectionView.addSubview(chartView)
        
        
        // Programmatic constraints for chartView
        // 0 use tricky negative top position to put chartView in the space left by UIEdgeInsetsMake
        // 1 leading edge of chartView is the same as the leading edge of collectionView
        // 2 trailing edge of chartView is the same as the trailing edge of collectionView
        // 3 width of chartView is same as width of collectionView (maybe not? should be width of device)
        // 4 height of chartview is constant, for now
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: chartView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1.0, constant: -250.0),
            NSLayoutConstraint(item: chartView, attribute: .leading, relatedBy: .equal, toItem: collectionView, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: chartView, attribute: .trailing, relatedBy: .equal, toItem: collectionView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: chartView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: chartView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 230)
            
            ])
        
        createPriceChart()
        
        // *** Here's the important bit *** //
        SwiftStockKit.fetchStockForSymbol(symbol: stockSymbol) { (stock) -> () in
            self.stock = stock
            self.collectionView.reloadData()
        }
        
    }
    
 
    override func viewDidLayoutSubviews() {
        
        chartView.frame.size.width = collectionView.bounds.size.width // set chartView width responsively http://stackoverflow.com/questions/37725406/how-to-set-uiview-size-to-match-parrent-without-constraints-programmatically/37725903
        
        // re-create chart (for responsiveness)
        if (chart.frame.size.width != chartView.frame.size.width) {
            chart.removeFromSuperview()

            createPriceChart()
            
        }
        
        loadChartWithRange(range: .oneDay) // re-draw chart
        
    }
    
    // *** Price Chart stuff *** //
    func createPriceChart() {
        let chartWidthBuffer: CGFloat = 20.0
        chart = SwiftStockChart(frame: CGRect(x: 0, y: 0, width: chartView.frame.size.width-chartWidthBuffer, height: chartView.frame.size.height-70)) // leave some space between bottom of chart DRAWING AREA, and bottom of chartView, for date select buttons
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.verticalGridStep = 3
        chartView.addSubview(chart)
        
        // price chart LAYOUT constraints
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: chart, attribute: .top, relatedBy: .equal, toItem: chartView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: chart, attribute: .leading, relatedBy: .equal, toItem: chartView, attribute: .leading, multiplier: 1.0, constant: chartWidthBuffer/2.0),
            NSLayoutConstraint(item: chart, attribute: .width, relatedBy: .equal, toItem: chartView, attribute: .width, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: chart, attribute: .height, relatedBy: .equal, toItem: chartView, attribute: .height, multiplier: 1.0, constant: -50),
            ])
    }
    
    // *** ChartView stuff *** //
    
    func loadChartWithRange(range: ChartTimeRange) {
    
        chart.timeRange = range
        
        let times = chart.timeLabelsForTimeFrame(range)
        chart.horizontalGridStep = times.count - 1
        
        chart.labelForIndex = {(index: NSInteger) -> String in
            return times[index]
        }
        
        chart.labelForValue = {(value: CGFloat) -> String in
            return String(format: "%.02f", value)
        }
        
        // *** Here's the important bit *** //
        SwiftStockKit.fetchChartPoints(symbol: stockSymbol, range: range) { (chartPoints) -> () in
            self.chart.clearChartData()
            self.chart.setChartPoints(points: chartPoints)
        }
    
    }
    
    func didChangeTimeRange(range: ChartTimeRange) {
        loadChartWithRange(range: range)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  stock != nil ? 18 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return section == 17 ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stockDataCell", for: indexPath) as! StockDataCell
        cell.setData(stock!.dataFields[(indexPath.section * 2) + indexPath.row])
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (UIScreen.main.bounds.size.width/2), height: 44)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
