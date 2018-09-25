//
//  CoursesCell.swift
//  CoursesVal
//
//  Created by Вадим Пустовойтов on 15.09.2018.
//  Copyright © 2018 Вадим Пустовойтов. All rights reserved.
//

import UIKit

class CoursesCell: UITableViewCell {
    
    @IBOutlet weak var labelCurrencyName: UILabel!
    @IBOutlet weak var labelCurrencyCourse: UILabel!
    @IBOutlet weak var labelCurrencyFullName: UILabel!
    
    func initCell(currency: CurrencyData){
        labelCurrencyName.text = currency.nominal! + " " + currency.charCode!
        labelCurrencyCourse.text = currency.value
        labelCurrencyFullName.text = currency.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
