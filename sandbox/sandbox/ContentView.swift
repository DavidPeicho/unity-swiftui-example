//
//  ContentView.swift
//  sandbox
//
//  Created by David Peicho on 1/21/21.
//

import SwiftUI

struct MyViewController: UIViewControllerRepresentable {

  func makeUIViewController(context: Context) -> UIViewController {
    let vc = UIViewController()
    
    UnityBridge.getInstance().onReady = {
        print("Unity is now ready!")
        UnityBridge.getInstance().show(controller: vc)
        let api = UnityBridge.getInstance().api
        api.test("This string travels far, far away toward Unity")
    }

    return vc
  }

  func updateUIViewController(_ viewController: UIViewController, context: Context) {}
}

struct ContentView: View {
    
    var body: some View {
        ZStack {
            MyViewController()
            Text("This text overlaps Unity!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
