// Playground - noun: a place where people can play

import UIKit

var gene = "Holla"

var mutatedIndex = arc4random_uniform(UInt32(countElements(gene)))
var newGene = ""
var index = 0
for oldCharacter in gene {
    var newCharacter = oldCharacter
    if index == Int(mutatedIndex) {
        newCharacter = Character(UnicodeScalar((arc4random_uniform(26) + 65)))
    }
    var willLower = arc4random_uniform(2)
    if willLower == 1 {
        newCharacter = Character(String(newCharacter).lowercaseString)
    }
    newGene += newCharacter
    index++
}

newGene