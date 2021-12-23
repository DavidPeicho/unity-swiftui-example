//
//  UnityPassthrough.swift
//
//  Created by David Peicho on 22/12/2021.
//

import SwiftUI

/// This view is used as a pass-through to see and interact with Unity.
///
/// - Note:
/// This view isn't really a **Unity** view. It's just a transparent view
/// that lets the background window be visible and interactable.
struct PassthroughView: UIViewRepresentable {


    public static let Tag: Int = 9999
        
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.tag = PassthroughView.Tag
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }

}
