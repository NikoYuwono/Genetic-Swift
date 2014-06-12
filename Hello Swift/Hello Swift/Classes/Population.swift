//
//  Population.swift
//  Hello Swift
//
//  Created by Niko Yuwono on 6/8/14.
//  Copyright (c) 2014 niko. All rights reserved.
//

import Foundation

class Population {
    let POPULATION_SIZE = 2048
    let MAX_GENERATIONS = 16384
    let TOURNAMENT_SIZE = 5
    let CROSSOVER_RATE = 80
    let MUTATION_RATE = 8
    let ELITISM_RATE = 0.1
    
    var targetGene:String
    var targetLength:Int
    
    var populationMember:Array<Chromosome?>
    
    struct Chromosome {

        var gene:String
        var fitness:Int
        init(gene:String = "") {
            self.gene = gene
            fitness = 0
        }
        
        mutating func mutate() {
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
            self.gene = newGene
        }
        
        mutating func generate(length:Int) {
            var newGene = ""
            for var i=0; i<length; i++ {
                var newChar = String(UnicodeScalar((arc4random_uniform(26) + 65)))
                var willLower = arc4random_uniform(2)
                if willLower == 1 {
                    newChar.lowercaseString
                }
                newGene += newChar
            }
            self.gene = newGene
        }
        
        mutating func isBetterThan(chromosome:Chromosome) -> Bool {
            if (fitness < chromosome.fitness) {
                return false;
            } else if (fitness > chromosome.fitness) {
                return true;
            }
            
            return false;
        }
    }
    
    init(targetGene:String) {
        self.targetGene = targetGene
        targetLength = Int(countElements(targetGene))
        populationMember = Array<Chromosome?>(count: POPULATION_SIZE, repeatedValue: nil)
        for var i=0; i<POPULATION_SIZE; i++ {
            var newChild = Chromosome()
            newChild.generate(targetLength)
            newChild.fitness = calculateFitness(newChild.gene)
            populationMember[i] = newChild
        }
    }
    
    func evolve() {
        var elitismLength = Double(populationMember.capacity) * ELITISM_RATE
        var elitismIndex = Int(arc4random_uniform(UInt32(elitismLength)))
        
        var newPopulationMember = Array<Chromosome?>(count: POPULATION_SIZE, repeatedValue: nil)
        for var i=0;i<elitismIndex;i++ {
            newPopulationMember[i] = populationMember[i]!
        }
        
        while (elitismIndex < POPULATION_SIZE) {
            if (Int(arc4random_uniform(100)+1) <= CROSSOVER_RATE) {
                
                var parents = selectParents()
                var childrens = mate(parents.firstParent, secondParent: parents.secondParent)
                
                if (Int(arc4random_uniform(100)+1) <= MUTATION_RATE) {
                    childrens.firstChild.mutate()
                }
                newPopulationMember[elitismIndex++] = childrens.firstChild
                
                if ((elitismIndex + 1) < POPULATION_SIZE) {
                    if (Int(arc4random_uniform(100)+1) <= MUTATION_RATE) {
                        childrens.secondChild.mutate()
                    }
                    newPopulationMember[elitismIndex] = childrens.secondChild
                }
            } else {
                var tempContainer = populationMember[elitismIndex]!
                if (Int(arc4random_uniform(100)+1) <= MUTATION_RATE) {
                    tempContainer.mutate()
                }
                newPopulationMember[elitismIndex++] = tempContainer
            }
        }
        sortPopulation(&newPopulationMember, start: 0, end: 2048)
        populationMember = newPopulationMember
    }
    
    func sortPopulation(inout a:Array<Chromosome?>, start:Int, end:Int) {
        if (end - start < 2){
            return
        }
        var p = a[start + (end - start)/2]!
        var l = start
        var r = end - 1
        while (l <= r){
            var firstChromosome = a[l]!
            var secondChromosome = a[r]!
            if (firstChromosome.fitness < p.fitness){
                l += 1
                continue
            }
            if (secondChromosome.fitness > p.fitness){
                r -= 1
                continue
            }
            var t = a[l]
            a[l] = a[r]
            a[r] = t
            l += 1
            r -= 1
        }
        sortPopulation(&a, start: start, end: r + 1)
        sortPopulation(&a, start: r + 1, end: end)
    }
    
    func calculateFitness(gene:String) -> Int {
        var fitness = 0;
        var targetGeneValue = Int[]()
        
        for targetCharacter in targetGene.utf8 {
            targetGeneValue.append(Int(targetCharacter))
        }
        var index = 0
        for character in gene.utf8 {
            fitness += abs(Int(character) - targetGeneValue[index])
            index++
        }
        
        return fitness;
    }
    
    func mate(firstParent:Chromosome, secondParent:Chromosome) -> (firstChild:Chromosome, secondChild:Chromosome) {
        var length = countElements(firstParent.gene)
        var pivot = Int(arc4random_uniform(UInt32(length)))
        
        var firstChildGene = firstParent.gene.substringFromIndex(0).substringToIndex(pivot) + secondParent.gene.substringFromIndex(pivot).substringToIndex(length-pivot);
        var secondChildGene = secondParent.gene.substringFromIndex(0).substringToIndex(pivot) + firstParent.gene.substringFromIndex(pivot).substringToIndex(length-pivot);
        
        var firstChild = Chromosome(gene: firstChildGene)
        var secondChild = Chromosome(gene: secondChildGene)
        
        firstChild.fitness = calculateFitness(firstChild.gene)
        secondChild.fitness = calculateFitness(secondChild.gene)
        
        return (firstChild, secondChild)
    }
    
    func selectParents() -> (firstParent:Chromosome, secondParent:Chromosome) {
        var parents = Array<Chromosome?>(count: 2, repeatedValue: nil)
        
        for var i=0; i<2; i++ {
            parents[i] = populationMember[Int(arc4random_uniform(UInt32(targetLength)))]
            for var j=0; j<TOURNAMENT_SIZE; j++ {
                var competitor = populationMember[Int(arc4random_uniform(UInt32(targetLength)))]!
                if competitor.isBetterThan(parents[i]!) {
                    parents[i] = competitor
                }
            }
        }
        
        return (parents[0]!,parents[1]!);
    }
    
    func getBestChromosome() -> Chromosome {
        return populationMember[0]!
    }
}