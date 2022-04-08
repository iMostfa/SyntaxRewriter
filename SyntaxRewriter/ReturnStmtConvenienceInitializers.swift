//
//  ReturnStmtConvenienceInitializers.swift
//  SyntaxRewriter
//
//  Created by Mostfa on 08/04/2022.
//

import Foundation
import SwiftSyntaxBuilder
import SwiftSyntax

extension ReturnStmt {
    init(_ expression:  () -> (ExpressibleAsExprBuildable?)) {
        self.init(returnKeyword: .return, expression: expression())
    }
}
