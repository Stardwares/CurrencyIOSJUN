//
//  Model.swift
//  CoursesVal
//
//  Created by Вадим Пустовойтов on 06.09.2018.
//  Copyright © 2018 Вадим Пустовойтов. All rights reserved.
//

import UIKit
import CoreData

class Currency {
    var NumCode: String?
    var CharCode: String?
    
    var Nominal: String?
    var nominalDouble: Double?
    var Name: String?
    var Value: String?
    var valueDouble: Double?
    
    class func rouble() -> Currency {
        let r = Currency()
        r.CharCode = "RUR"
        r.Name = "Российский рубль"
        r.Nominal = "1"
        r.nominalDouble = 1
        r.NumCode = "810"
        r.Value = "1"
        r.valueDouble = 1
        
        return r
    }
}

class Model: NSObject, XMLParserDelegate,UITableViewDelegate {
    static let shared = Model()
    
    var currencyCoreData = [CurrencyData]()
    
    var currencies: [Currency] = []
    var currentDate: String = ""
    
    var oneCurrency: Currency = Currency.rouble()
    var twoCurrency: Currency = Currency.rouble()
    
    func convert(amount: Double?, flagFrom: Bool) -> Double{
        var d: Double = 0
        if amount == nil {
            return 0
        }
        if flagFrom == true {
            d = ((oneCurrency.valueDouble! / oneCurrency.nominalDouble!) / (twoCurrency.valueDouble! / twoCurrency.nominalDouble!)) * amount!
        } else {
            d = ((twoCurrency.valueDouble! / twoCurrency.nominalDouble!) / (oneCurrency.valueDouble! / oneCurrency.nominalDouble!)) * amount!
        }
        
        return d
    }
    
    func addTextNumberFormat(textBefore: String, textButton: String) -> String{
        let stringAfter = String(format: "%.2f", Double(String(Int(Double(textBefore)! * 100)) + textButton)! / 100)
        return stringAfter
    }
    
    var pathForXML: String{
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]+"/data.xml"
        
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
        
        return Bundle.main.path(forResource: "data", ofType: "xml")!
    }
    
    var urlForXML: URL? {
        return URL(fileURLWithPath: pathForXML)
    }
    
    //загрузка XML с CBR.RU и сохранение его в каталоге приложения
    //http://www.cbr.ru/scripts/XML_daily.asp?date_req=02/03/2002
    func loadXMLFile() {
        let strUrl = "http://www.cbr.ru/scripts/XML_daily.asp"
        
        let url = URL(string: strUrl)
        let task = URLSession.shared.dataTask(with: url!) { (data, responce, error) in
            var errorGlobal: String?
            if error == nil {
                let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]+"/data.xml"
                let urlForSave = URL(fileURLWithPath: path)
                
                do {
                    try data?.write(to: urlForSave)
                    print("Файл загружен!")
                    self.parseXML()
                } catch {
                    print("Error when save data:\(error.localizedDescription)")
                    errorGlobal = error.localizedDescription
                }
                
                
            } else {
                print("error when loadXMLFile:"+error!.localizedDescription)
                errorGlobal = error?.localizedDescription
            }
            
            if let errorGlobal = errorGlobal {
                NotificationCenter.default.post(name: NSNotification.Name("ErrorXMLloading"), object: self, userInfo: ["ErrorName":errorGlobal])
            }
            
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startLoadingXML"), object: self)
        task.resume()
    }
    
    // распарсить XML  и положить его в currencies: [Currencies], отправить уведомление приложению о том что данные обновились
    func parseXML() {
        
        currencies = [Currency.rouble()]
        let parser = XMLParser(contentsOf: urlForXML!)
        parser?.delegate = self
        parser?.parse()
        
        deleteAllInCoreDate()
        saveCurrecyInCoreData()
        
        print("Данные обновлены!")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataRefreshed"), object: self)
        
        for c in currencies {
            if c.CharCode == oneCurrency.CharCode{
                oneCurrency = c
            }
            if c.CharCode == twoCurrency.CharCode{
                twoCurrency = c
            }
        }
        
    }
    
    var currentCurrency: Currency?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]){
        
        if elementName == "ValCurs" {
            if let currentDateString = attributeDict["Date"] {
                currentDate = currentDateString
            }
            
        }
        
        if elementName == "Valute" {
            currentCurrency = Currency()
        }
    }
    
    var currentCharacters: String = ""
    func parser(_ parser: XMLParser, foundCharacters string: String){
        currentCharacters = string
    }
    /*
     <NumCode>036</NumCode>
     <CharCode>AUD</CharCode>
     <Nominal>1</Nominal>
     <Name>¿‚ÒÚ‡ÎËÈÒÍËÈ ‰ÓÎÎ‡</Name>
     <Value>16,0102</Value></Valute>
     */
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        
        if elementName == "NumCode"{
            currentCurrency?.NumCode = currentCharacters
        }
        if elementName == "CharCode"{
            currentCurrency?.CharCode = currentCharacters
        }
        if elementName == "Nominal"{
            currentCurrency?.Nominal = currentCharacters
            currentCurrency?.nominalDouble = Double(currentCharacters.replacingOccurrences(of: ",", with: "."))
        }
        if elementName == "Name"{
            currentCurrency?.Name = currentCharacters
        }
        if elementName == "Value"{
            currentCurrency?.Value = currentCharacters
            currentCurrency?.valueDouble = Double(currentCharacters.replacingOccurrences(of: ",", with: "."))
        }
        
        if elementName == "Valute" {
            currencies.append(currentCurrency!)
        }
    }
    
    func saveCurrecyInCoreData(){
        for index in currencies{
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let curr = CurrencyData(entity: CurrencyData.entity(), insertInto: context)
            
            curr.setValue(index.CharCode, forKey: "charCode")
            curr.setValue(index.Name, forKey: "name")
            curr.setValue(index.Nominal, forKey: "nominal")
            curr.setValue(index.nominalDouble, forKey: "nominalDouble")
            curr.setValue(index.NumCode, forKey: "numCode")
            curr.setValue(index.Value, forKey: "value")
            curr.setValue(index.valueDouble, forKey: "valueDouble")
            
            do { try context.save()
               currencyCoreData.append(curr)
            } catch let error as NSError {
                print("Could not save \(error)")
            }
        }
    }
    
    func deleteAllInCoreDate(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for index in currencyCoreData{
            context.delete(index)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do { currencyCoreData = try context.fetch(CurrencyData.fetchRequest())
                
            } catch let error as NSError {
                print("Could not delete \(error) ")
            }
            
        }
    }
    
    func addCoreDate(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
           let result = try context.fetch(CurrencyData.fetchRequest())
            currencyCoreData = result as! [CurrencyData]
        } catch let error as NSError {
            print("Could not add \(error)")
        }
    }
    
}
