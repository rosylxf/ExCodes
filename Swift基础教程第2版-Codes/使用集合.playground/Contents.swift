//: Playground - noun: a place where people can play

import UIKit

// 使用集合


let candyJarA = ["Peppermints", "Gooey Bears"]

let candyJarB = ["Happy Ranchers"]

var candyJarC = candyJarA + candyJarB

candyJarC.insert("pig", atIndex: 0)
candyJarC[0] = "god"

print(candyJarC)

candyJarC[0...1] = ["a", "b"]

print(candyJarC)

//candyJarC.removeLast()
candyJarC.removeLast(2)

print(candyJarC)


var arrayA = ["abc", 2, "cef", true]

print(arrayA)


// 字典


var profile = ["name": "lxf"]
profile["age"] = "18"

print(profile)

var dictA:[String: Int] = ["count": 18]

print(dictA)



//更新

profile["age"] = "100"

//删除

//profile.removeValueForKey("age")  //或下面
profile["age"] = nil

print(profile)










