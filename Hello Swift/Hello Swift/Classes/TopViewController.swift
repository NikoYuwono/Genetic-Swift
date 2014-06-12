//
//  TopViewController.swift
//  Hello Swift
//
//  Created by Niko Yuwono on 6/4/14.
//  Copyright (c) 2014 niko. All rights reserved.
//

import Foundation
import UIKit

class TopViewController: UIViewController {
    let POPULATION_SIZE = 2048
    let MAXIMUM_ITERATION = 4000
    let ELITISM_RATE = 0.10
     @IBOutlet var lblHello: UILabel
    
    struct chromosome {
        var text = ""
        var fitness = 0
    }
    
    var population = chromosome[]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblHello.text = "Hello, Swift"
        var population = Population(targetGene: "Swift")
        for var i=0;i<MAXIMUM_ITERATION;i++ {
            println("Generation \(i) Best String \(population.getBestChromosome().gene) Best Fitness \(population.getBestChromosome().fitness)")
            population.evolve();
            if(population.getBestChromosome().fitness == 0) {
                println("Finished ! Best String is : \(population.getBestChromosome().gene)");
                break;
            }
        }
    }
}