//
//  Team.swift
//  petanque
//
//  Created by Hans Ott on 1/12/14.
//  Copyright (c) 2014 Hans Ott. All rights reserved.
//

class Team : Printable {
    
    var id : Int!
    var name : String!
    var playersInTeam : Int!
    var score : Int = 0
    
    init(name : String, playersInTeam : Int) {
        self.name = name
        self.playersInTeam = playersInTeam
    }
    
    func increaseScore() -> Int {
        // TODO: Increment score
        return score
    }
    
    // https://gist.github.com/hansott/887b1561999e95532f9e
    var description : String {
        return "id=\(id), name=\(name), players in team=\(playersInTeam)"
    }
    
}
