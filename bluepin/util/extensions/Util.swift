//
//  Util.swift
//  bluepin
//
//  Created by Alex A on 3/10/19.
//  Copyright © 2019 Alex Alimov. All rights reserved.
//

import Foundation

extension String {
    func iterateIdentifier() -> String{
        guard let index = (self.range(of: "_", options: .backwards)?.upperBound) else { return self }
        guard let afterUnderScore = Int(String(self.suffix(from: index))) else { return self }
        let beforeUnderScore = String(self.prefix(upTo: index))
        
        return "\(beforeUnderScore)_\(afterUnderScore + 1)"
    }
}
