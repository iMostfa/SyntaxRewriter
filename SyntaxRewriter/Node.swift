//
//  Node.swift
//  SyntaxRewriter
//
//  Created by Mostfa on 07/04/2022.
//

import Foundation

let commonNodes: [Node] = [
    Node("UnknownDecl", kind: .base(.Decl)),
    Node("UnknownExpr", kind: .base(.Expr)),
    Node("UnknownStmt", kind: .base(.Stmt)),
    Node("UnknownType", kind: .base(.Type)),
    Node("UnknownPattern", kind: .base(.Pattren)),
]

/// A Syntax node, possibly with children.
/// If the kind is "SyntaxCollection", then this node is considered a Syntax
struct Node {
    
    var name: String
    
    var baseKind: SyntaxKind

    var baseType: String {
       if baseKind == SyntaxKind.base(.SyntaxCollection) {
           return "syntax"
           
       }
        
        return baseKind.type
    }
    var isVisitable: Bool {
        return baseKind.isBase
    }
    
    
    init(_ name: String, kind: SyntaxKind) {
        self.name = typeOf(name)
        self.baseKind = kind
    }
}
