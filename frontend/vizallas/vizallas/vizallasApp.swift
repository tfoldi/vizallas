//
//  vizallasApp.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import SwiftUI
import Supabase


@main
struct vizallasApp: App {
    var body: some Scene {
        WindowGroup {
            GaugingStationView()
        }
    }
}



let supabase = SupabaseClient(
    supabaseURL: Secrets.supabaseURL,
    supabaseKey: Secrets.supabaseAnonKey
)
