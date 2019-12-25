//
//  Utility.swift
//  Interval Timer
//
//  Created by Hearst, Jacob on 12/6/19.
//  Copyright © 2019 Hearst, Jacob. All rights reserved.
//

import CoreData

func formatTime(_ time: Int16) -> String {
    let minutes = time / 60
    let seconds = time % 60
    
    // Turn 1:5 (One minute, five seconds) to 1:05
    return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
}

func toIntervalTypeEnum(_ type: Int16) -> IntervalType {
    return type == 0 ? .ACTIVE : .REST
}

enum IntervalType: Int16 {
    case ACTIVE = 0
    case REST = 1
}

func saveCoreData(_ context: NSManagedObjectContext) {
    do {
        try context.save()
    } catch let error {
      print("Could not save. \(error)")
    }
}
