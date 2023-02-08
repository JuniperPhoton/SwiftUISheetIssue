//
//  ContentView.swift
//  SwiftUISheetIssue
//
//  Created by Photon Juniper on 2023/2/8.
//

import SwiftUI

/// A demo to reproduce the sheet issue.
///
/// This issue can be reproduced by the following step.
///
/// 1. Construct a view content with a List or a ScrollView
/// 2. Put a button on top of the view hierarchy: the top position is is important
/// 3. Trigger a sheet by pressing a button, which will present a sheet view controller managed by UIKit
/// 4. While is in the sheet, Put the app in the background state, like going back to home screen or navigating to other apps
/// 5. Back in this app, dismiss the sheet
/// 6. Now you will find that the button is not tappable
///
/// Some tries:
/// - A List or a ScrollView is not necessary, any view with .ignoresSafeArea can cause the issue
/// - If you put the button at the bottom, the button is tappable after dismissing the sheet
///
/// So I think the issue is about .ignoresSafeArea (which is used inside the List or ScrollView)
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
            
// This can also help reproducing the issue, the key is .ignoresSafeArea()
//            Spacer()
//            Text("Ignored")
//                .ignoresSafeArea()
        }
        .sheet(isPresented: $showSheet) {
            Text("Sheet content")
        }
    }
}
