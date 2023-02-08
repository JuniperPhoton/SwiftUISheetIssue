//
//  ContentView.swift
//  SwiftUISheetIssue
//
//  Created by Photon Juniper on 2023/2/8.
//

import SwiftUI

struct ContentView: View {
    @State var showSheet = false
    
    var body: some View {
        VStack {
            Button {
                showSheet = true
                print("on tap button")
            } label: {
                HStack {
                    Text("Hello, world!")
                }
            }
            
            ScrollView {
                LazyVStack {
                    ForEach(0...20, id: \.self) { item in
                        Text(String(item))
                            .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            Text("Sheet content")
        }
    }
}
