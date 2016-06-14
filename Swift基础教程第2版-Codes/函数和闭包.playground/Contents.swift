//: Playground - noun: a place where people can play

import UIKit

//4 使用swift编写函数 
// func funcName(paramName : type, ...) -> returnType

func fahrenheitToCelsius(fahrenheitValue : Double) -> Double {
    var result : Double
    
    result = (((fahrenheitValue - 32) * 5) / 9)
    
    return result
}

var outdoorTemperatureInFahrenheit = 88.2
var outdoorTemperatureInCelsius = fahrenheitToCelsius(outdoorTemperatureInFahrenheit)


// 可变参数

func addMyAccountBalances(balances : Double...) -> Double {
    var result : Double = 0
    
    for balance in balances {
        result += balance
    }
    
    return result
}

addMyAccountBalances(77.87)
addMyAccountBalances(10.52, 11.30, 100.60)
addMyAccountBalances(345.12, 1000.80, 233.10, 104.80, 99.90)


// 函数是一级对象

var account1 = ("State Bank Personal", 1011.10)
var account2 = ("State Bank Business", 24309.63)

func deposit(amount : Double, account : (name : String, balance : Double)) -> (String, Double) {
    let newBalance : Double = account.balance + amount
    return (account.name, newBalance)
}
func withdraw(amount : Double, account : (name : String, balance : Double)) -> (String, Double) {
    let newBalance : Double = account.balance - amount
    return (account.name, newBalance)
}

let mondayTransaction = deposit
let fridayTransaction = withdraw

let mondayBalance = mondayTransaction(300.0, account: account1)
let fridayBalance = fridayTransaction(1200, account: account2)


// 从函数返回函数

func chooseTransaction(transaction: String) -> (Double, (String, Double)) -> (String, Double) {
    if transaction == "Deposit" {
        return deposit
    }
    
    return withdraw
}


//使用

// 方式1：将返回的函数赋给一个常量，再调用这个常量
let myTransaction = chooseTransaction("Deposit")
myTransaction(225.33, account2)

// 方式2：直接调用返回的函数
chooseTransaction("Withdraw")(63.17, account1)

// 嵌套函数 -- 在一个函数中声明另一个函数呢？确实可以这样做，这被称为嵌套函数
// 在需要隔离（隐藏）不需要向外部暴露的功能时，嵌套函数很有用

func bankVault(passcode : String) -> String {
    func openBankVault(_: Void) -> String {
        return "Vault opened"
    }
    func closeBankVault() -> String {
        return "Vault closed"
    }
    if passcode == "secret" {
        return openBankVault()
    }
    else {
        return closeBankVault()
    }
}

print(bankVault("wrongsecret"))
print(bankVault("secret"))

// 默认参数

func writeCheckTo(payee : String = "Unknown", amount : String = "10.00") -> String {
    return "Check payable to " + payee + " for $" + amount
}

writeCheckTo()
writeCheckTo("Donna Soileau")
writeCheckTo("John Miller", amount : "45.00")


// 默认情况下，Swift要求指定参数名, 但是 函数名前面加 _ 代表隐式参数，调用的时候不需要加参数名

func writeCheckFrom(payer : String, _ payee : String, _ amount : Double) -> String {
    return "Check payable from \(payer) to \(payee) for $\(amount)"
}

//writeCheckFrom("lixuefeng", payee: "lxf", amount: 100)

writeCheckFrom("Dave Johnson", "Coz Fontenot", 1_000.0)
//writeCheckFrom("lixuefeng", "lxf", 100)


// 使用外部参数名

func writeBestCheck(from payer : String, to payee : String, total amount : Double) -> String {
    return "Check payable from \(payer) to \(payee) for $\(amount)"
}

writeBestCheck(from: "Bart Stewart", to: "Alan Lafleur", total: 101.0)


//// 变量参数
//
//func cashBetterCheck(from : String, var to : String, total : Double) -> String {
//    if to == "Cash" {
//        to = from
//    }
//    return "Check payable from \(from) to \(to) for $\(total) has been cashed"
//}
//
//cashBetterCheck("Ray Daigle", to: "Cash", total: 103.00)

// inout 参数 

func cashBestCheck(from : String, inout to : String, total : Double) -> String {
    if to == "Cash" {
        to = from
    }
    return "Check payable from \(from) to \(to) for $\(total) has been cashed"
}

var payer = "James Perry"
var payee = "Cash"
print(payee)
cashBestCheck(payer, to: &payee, total: 103.00)

print(payee)
