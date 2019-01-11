//
//  main.swift
//  NavigationTask
//
//  Created by Rafi A on 31/05/17.
//  Copyright © 2017 Rafi A. All rights reserved.
//

import UIKit

//UIApplicationMain(Process.argc, Process.unsafeArgv, NSStringFromClass(InterractionUIApplication), NSStringFromClass(AppDelegate))

CommandLine.unsafeArgv.withMemoryRebound(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc)) {argv in
    _ = UIApplicationMain(CommandLine.argc, argv, NSStringFromClass(GICMUIApplication.self), NSStringFromClass(AppDelegate.self))
}
