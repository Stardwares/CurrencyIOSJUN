//
//  ConverterController.swift
//  CoursesVal
//
//  Created by Вадим Пустовойтов on 13.09.2018.
//  Copyright © 2018 Вадим Пустовойтов. All rights reserved.
//

import UIKit

class ConverterController: UIViewController, UIScrollViewDelegate/*, UITextFieldDelegate */ {
    
    
    @IBOutlet weak var updateCurrencyLast: UITextView!
    @IBOutlet weak var buttonValOne: UIButton!
    @IBOutlet weak var buttonValTwo: UIButton!
    @IBOutlet weak var textValueValOne: UITextField!
    @IBOutlet weak var textValueValTwo: UITextField!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var colors: [UIColor] = [UIColor.red, UIColor.yellow, UIColor.green]
    var newNews: [String] = ["Новость 1","Новость 2","Новость 3"]
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var isEdit: Bool = true
    
    @IBAction func clearButton(_ sender: Any) {
        textValueValOne.text = "0.00"
        textValueValTwo.text = "0.00"
    }
    @IBAction func buttonActionInsert(_ sender: UIButton) {
        if isEdit == true {
            textValueValOne.text = Model.shared.addTextNumberFormat(textBefore: textValueValOne.text!, textButton: sender.title(for: UIControlState.normal)!)
            textValOneEditingChange(textValueValOne)
        } else {
            textValueValTwo.text = Model.shared.addTextNumberFormat(textBefore: textValueValTwo.text!, textButton: sender.title(for: UIControlState.normal)!)
            textValTwoEditingChange(textValueValTwo)
        }
        
    }
    
    @IBAction func pushActionValOne(_ sender: Any) {
        let nc = storyboard?.instantiateViewController(withIdentifier: "selectedCurrencyNSID") as! UINavigationController
        (nc.viewControllers[0] as! SelectCurrencyController).flagCurrency = .oneCurrency
        present(nc, animated: true, completion: nil)
    }
    
    @IBAction func pushActionValTwo(_ sender: Any) {
        let nc = storyboard?.instantiateViewController(withIdentifier: "selectedCurrencyNSID") as! UINavigationController
        (nc.viewControllers[0] as! SelectCurrencyController).flagCurrency = .twoCurrency
        present(nc, animated: true, completion: nil)
    }
    
    @IBOutlet weak var buttonDone: UIBarButtonItem!
    
    @IBAction func pushButtonAction(_ sender: Any) {
        textValueValOne.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func textValTwoEditingChange(_ sender: Any) {
        let amount = Double(textValueValTwo.text!)
        textValueValOne.text = String(format: "%.2f", Model.shared.convert(amount: amount, flagFrom: false))
    }
    
    @IBAction func textValOneEditingChange(_ sender: Any) {
        let amount = Double(textValueValOne.text!)
        textValueValTwo.text = String(format: "%.2f", Model.shared.convert(amount: amount, flagFrom: true))
    }
    
    @IBAction func TextOneValEdit(_ sender: Any) {
        isEdit = true
    }
    
    @IBAction func TextTwoValEdit(_ sender: Any) {
        isEdit = false
    }
    
    @IBAction func buttonUpdateCurrency(_ sender: Any) {
        Model.shared.loadXMLFile()
        
        updateDateCurrency()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDateCurrency()
        updateCurrencyLast.isEditable = false
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        self.view.addSubview(scrollView)
        for index in 0..<colors.count {
            
            frame.origin.x = (UIScreen.main.bounds.width - 35) * CGFloat(index)
            self.scrollView.frame.size.width = (UIScreen.main.bounds.width - 35)
            frame.size = self.scrollView.frame.size
            
            let subView =  UITextView(frame: frame)
            subView.backgroundColor = colors[index]
            subView.text = newNews[index]
            subView.isEditable = false
            self.scrollView.addSubview(subView)
        }
        
        self.scrollView.contentSize = CGSize(width: (UIScreen.main.bounds.width - 35) * 3, height: self.scrollView.frame.size.height)
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        
        
        textValueValOne.delegate = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "startLoadingXML"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                activityIndicator.startAnimating()
                self.navigationItem.rightBarButtonItem?.customView = activityIndicator
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "dataRefreshed"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.navigationItem.title = Model.shared.currentDate
            }
        }
        
        navigationItem.title = Model.shared.currentDate
        
        //    Model.shared.loadXMLFile()
        // Do any additional setup after loading the view.
    }
    
  
    
    override func viewDidAppear(_ animated: Bool) {
        Model.shared.loadXMLFile()
        Model.shared.addCoreDate()
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func updateDateCurrency() {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        updateCurrencyLast.text = "Последнее обновление курсов:" + "\n" + df.string(from: NSDate() as Date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshButtons()
        textValOneEditingChange(self)
        navigationItem.rightBarButtonItem = nil
    }
    
    
    func refreshButtons(){
        buttonValOne.setTitle(Model.shared.oneCurrency.CharCode, for: UIControlState.normal)
        buttonValTwo.setTitle(Model.shared.twoCurrency.CharCode, for: UIControlState.normal)
    }
    
    
}

extension ConverterController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
}
