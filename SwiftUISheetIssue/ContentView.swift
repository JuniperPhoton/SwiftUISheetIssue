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
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Button {
                showSheet = true
                print("on tap button")
            } label: {
                Text("Tap me to present a sheet")
            }
            
            // By default, a scroll view uses .ignoresSafeArea() inside
            // which causes this issue.
            ScrollView {
                LazyVStack {
                    ForEach(0...20, id: \.self) { item in
                        Text(String(item)).padding()
                    }
                }
            }
            
            // This can also help reproducing the issue, the key line is .ignoresSafeArea()
            // Text("Ignored")
            //     .ignoresSafeArea()
            //     .frame(maxHeight: .infinity)
        }
        .sheetCompat(isPresented: $showSheet) {
            Text("Sheet content")
        }
    }
}

/// Use this modifier to present a sheet without encountering the following issue:
/// - First present a sheet using .sheet(item:_:_)
/// - Then go back to the home screen of iPhone or iPad
/// - Return to the app, dismiss the presented sheet
/// - The views at the top of the root view, can't response to hit test even thought it looks right
public extension View {
    func sheetCompat<ViewContent: View, Item: Identifiable>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> ViewContent
    ) -> some View {
        self.sheet(item: item, onDismiss: {
            onDismiss?()
            fixContentViewTransformIssue()
        }, content: content)
    }
    
    func sheetCompat<ViewContent: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> ViewContent
    ) -> some View {
        self.sheet(isPresented: isPresented, onDismiss: {
            onDismiss?()
            fixContentViewTransformIssue()
        }, content: content)
    }
}

private func fixContentViewTransformIssue() {
#if os(iOS)
    // In case someone is not using Scene based lifecycle, we still use this deprecated
    // method to get the window
    UIApplication.shared.windows.forEach { window in
        guard let view = window.rootViewController?.view else {
            return
        }
        
        // This is the weird way to fix.
        // We know setting the transform property multiply times will still result
        // in one drawing cycle.
        // But it just fixes.
        view.transform = CGAffineTransform(translationX: 0, y: 100)
        view.transform = CGAffineTransform(translationX: 0, y: 0)
    }
#endif
}
