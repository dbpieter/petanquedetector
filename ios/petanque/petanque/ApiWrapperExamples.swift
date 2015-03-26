//
//  ApiWrapperExamples.swift
//  petanque
//
//  Created by Hans Ott on 2/12/14.
//  Copyright (c) 2014 Hans Ott. All rights reserved.
//

import Foundation

class ApiWrapperExamples {
    
    var api = ApiWrapper()
    
    // How to create a game
    func createGame() {
        
        let teams : Array<Team> = [
            Team(name: "Alex", playersInTeam: 1),
            Team(name: "Hans", playersInTeam: 1)
        ]
        
        api.createGame(teams, finished: { (game) in
            println(game)
        })
        
    }
    
}