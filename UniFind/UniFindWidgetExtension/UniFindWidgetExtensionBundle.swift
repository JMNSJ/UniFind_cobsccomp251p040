//
//  UniFindWidgetExtensionBundle.swift
//  UniFindWidgetExtension
//
//  Created by cobsccomp251p-040 on 2026-10-27.
//

import WidgetKit
import SwiftUI

@main
struct UniFindWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        UniFindWidgetExtension()
        UniFindWidgetExtensionControl()
        UniFindWidgetExtensionLiveActivity()
    }
}
