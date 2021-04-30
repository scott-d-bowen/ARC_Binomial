//
//  main.swift
//  ARC_Binomial
//  (Hint: This does *not* result in compression)
//  (MemoryLayout<[(nzbc: UInt8, rank: UInt16)]>.stride is an inefficient method!)
//  Created by Scotty B on 30-Apr-2021.
//

import Foundation

print("Hello, World!")

// First we create seventeen 'empty' arrays within a singular array for easy access
var binomialMatrix: [[UInt16]] = Array(repeating:
                                 Array(),
                                 count: 17)

// Then we initialize those arrays to use as a 'look-up table'
func initialise() {
    for index in 0...UInt16.max {
        let nzbc = UInt8(index.nonzeroBitCount)
        binomialMatrix[Int(nzbc)].append(index)
    }
    for lookWithin in 0..<binomialMatrix.count {
        print(binomialMatrix[lookWithin].count, terminator: ", ")
    }
    print(binomialMatrix.count)
}
initialise()

// Then we generate 4MB of random test data (it is /2 for the width of a UInt16)
var randomPairs: [UInt16] = Array(repeating: 0x0000, count: 1*2*1024*/2)
func generateRandomData() {
    for index in 0..<randomPairs.count {
        randomPairs[index] = UInt16.random(in: 0...0xFFFF)
    }
}
generateRandomData()

// Utility function that returns a tuple containing the Non-Zero-Bit-Count and rank within the above 'look-up table'
func restructureRandomUnit(unit: UInt16) -> (nzbc: UInt8, rank: UInt16) {
    
    let nzbc: UInt8 = UInt8(unit.nonzeroBitCount)
    var rank: UInt16 = 0
    
    for index in 0..<binomialMatrix[Int(nzbc)].count {
        if (binomialMatrix[Int(nzbc)][index] == unit) {
            rank = UInt16(index)
            break
        }
    }
    
    return (nzbc, rank)
}

// Preparation of the Final (Output) Matrix
var finalMatrix: [(nzbc: UInt8, rank: UInt16)] = []
for index in 0..<randomPairs.count {
    let ret = restructureRandomUnit(unit: randomPairs[index] )
    finalMatrix.append(ret)
    // OK: print(ret, terminator: ", ")
    if (index % 4096 == 0) { print(".", terminator: "")}
}
print()
print(finalMatrix.count)

// Then we capture the data from the above Matrix to a file on disk, for further analysis and compression with command line tools
func saveDataToFile(dataToSave: [(nzbc: UInt8, rank: UInt16)], filename: String) {
    print("Saving Data to File...")
    let outputFile = URL(fileURLWithPath: "/Users/sdb/TEST DATA/ProjectSDBX/" + filename)
    // let dataToWrite = Data(bytes: &dataToSave, count: dataToSave.count)
    let dataToWrite = Data(bytes: dataToSave, count: dataToSave.count * MemoryLayout<[(nzbc: UInt8, rank: UInt16)]>.stride)
    try! dataToWrite.write(to: outputFile)
    print(" - Saved to: " + filename)
}
saveDataToFile(dataToSave: finalMatrix, filename: "BinomialIntermediateTest.sdbx")

// Good Day!
print("Goodbye.")
