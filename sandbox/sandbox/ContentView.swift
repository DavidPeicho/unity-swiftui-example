//
//  ContentView.swift
//  sandbox
//
//  Created by David Peicho on 1/21/21.
//

import SwiftUI

struct UnityView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()

        UnityBridge.getInstance().superview = vc.view
        UnityBridge.getInstance().onReady = {
            print("Unity is now ready!")
            UnityBridge.getInstance().api.test("This string travels far, far away toward Unity")
        }

        return vc
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {}
}

struct OtherUnityView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UnityBridge.getInstance().superview = vc.view
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            UnityBridge.getInstance().superview = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
            UnityBridge.getInstance().superview = vc.view
        }

        return vc
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {}
}

struct ContentView: View {
    
    var body: some View {
        ZStack {
            UnityView().ignoresSafeArea()

            // OtherUnityView().frame(width: 200, height: 200, alignment: .center).offset(x: 100, y: 0)
            /* Uncomment the above line to see that we can swap UnityBridge to another view
             and control its size and position. Unity's documentation says that "Unity as a
             Library only supports full-screen rendering, and doesn’t support rendering on
             part of the screen.", but we have overcome this limitation. */

            Button("This button overlaps Unity!", action: {
                UnityBridge.getInstance().api.test("Native button pressed!")
            }).buttonStyle(.borderedProminent).tint(.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
