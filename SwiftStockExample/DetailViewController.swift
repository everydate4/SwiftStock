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
        
        chartView = ChartView.create()
        chartView.delegate = self
        chartView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(chartView)
        
        // Programmatically set chartView Auto Layout constraints
        
        collectionView.addConstraint(NSLayoutConstraint(item: chartView, attribute: .height, relatedBy: .equal, toItem:collectionView, attribute: .height, multiplier: 1.0, constant: -(collectionView.bounds.size.height - 230)))
        collectionView.addConstraint(NSLayoutConstraint(item: chartView, attribute: .width, relatedBy: .equal, toItem:collectionView, attribute: .width, multiplier: 1.0, constant: 0))
        collectionView.addConstraint(NSLayoutConstraint(item: chartView, attribute: .top, relatedBy: .equal, toItem:collectionView, attribute: .top, multiplier: 1.0, constant: -250))
        collectionView.addConstraint(NSLayoutConstraint(item: chartView, attribute: .left, relatedBy: .equal, toItem:collectionView, attribute: .left, multiplier: 1.0, constant: 0))
        collectionView.contentInset = UIEdgeInsetsMake(250, 0, 0, 0)

        
        chart = SwiftStockChart(frame: CGRect(x: 10, y: 10, width: chartView.frame.size.width - 20, height: chartView.frame.size.height - 50))
        chart.fillColor = UIColor.clear
        chart.verticalGridStep = 3
        chartView.addSubview(chart)
        loadChartWithRange(range: .oneDay)

        
        // *** Here's the important bit *** //
        SwiftStockKit.fetchStockForSymbol(symbol: stockSymbol) { (stock) -> () in
            self.stock = stock
            self.collectionView.reloadData()
        }

        
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
