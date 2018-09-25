//
//  SelectCurrencyController.swift
//  CoursesVal
//
//  Created by Вадим Пустовойтов on 13.09.2018.
//  Copyright © 2018 Вадим Пустовойтов. All rights reserved.
//

import UIKit

enum FlagCurrencySelected {
    case oneCurrency
    case twoCurrency
}

class SelectCurrencyController: UITableViewController {
    
    var flagCurrency: FlagCurrencySelected = .oneCurrency
    
    @IBAction func pushCancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.shared.currencyCoreData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellCurrency", for: indexPath) as! CoursesCell

        let currencyCoreData: CurrencyData = Model.shared.currencyCoreData[indexPath.row]
        
        cell.initCell(currency: currencyCoreData)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCurrency: Currency = Model.shared.currencies[indexPath.row]
        
        if flagCurrency == .oneCurrency {
            Model.shared.oneCurrency = selectedCurrency
        }
        if flagCurrency == .twoCurrency {
            Model.shared.twoCurrency = selectedCurrency
        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
}
