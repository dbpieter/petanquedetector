//
//  Game.swift
//  petanque
//
//  Created by Hans Ott on 1/12/14.
//  Copyright (c) 2014 Hans Ott. All rights reserved.
//

class Game : Printable {
    
    var id : Int!
    
    // This value should not be changed
    var code : String!
    
    var api = ApiWrapper()
    
    var teams : Array<Team>!
    
    init(teams : Array<Team>, code : String) {
        self.teams = teams
        self.code = code
    }
    
    func getShareUrl() -> String {
        
        if id != nil && code != nil {
            return "\(api.baseUrl)/\(self.id)"
        }
        
        return "";
    }
    
    func getTeams() -> Array<Team> {
        return self.teams
    }
    
    var description : String {
        return "id=\(id), code=\(code)"
    }
    
}
