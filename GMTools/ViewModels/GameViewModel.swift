//
//  GameViewModel.swift
//  GMTools
//
//  Created by Bobby Walker on 3/12/25.
//

import Foundation
import Observation
import Supabase

@Observable
final class GameViewModel {
    var systems: [System] = []
    
    func loadSystems() async {
        do {
            let systemsResponse: [System] = try await supabase
                .from("systems")
                .select()
                .execute()
                .value
            
            for system in systemsResponse {
                print("System: \(system)")
                systems.append(System(id: system.id, name: system.name))
            }
            
            print("Systems Loaded: \(systems.count)")
        } catch {
            print(error)
        }
    }
    
    init() {
        Task {
            await loadSystems()
        }
    }
        
}
