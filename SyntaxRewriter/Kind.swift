//
//  Kind.swift
//  SyntaxRewriter
//
//  Created by Mostfa on 07/04/2022.
//

import Foundation

enum SyntaxKind: Equatable {
    
    case base(_ baseKind: Base)
    case kind(_ identifier: String)
    
    /// Returns the crossponeding String of a SwiftKind, checking to see if the kind is
    /// Syntax or SyntaxCollection First.
    /// A type name is the same as the SyntaxKind name with the suffix "Syntax" added.
    var type: String {
        switch self {
            
        case .base(baseKind: let baseKind):
            return baseKind.type
      
        case .kind(let name):
            if name.hasSuffix("Token") {
                return "TokenSyntax"
            }
            
            return name + "Syntax"
        }
    }
    
    //TODO: - Imeplemnt lowercase_first_word from python.
    
}



extension SyntaxKind {
    enum Base: String {
        case Decl, Expr, Pattren, Stmt, Syntax, SyntaxCollection, `Type`
        
        var type: String {
            switch self {
                
            case .Decl, .`Type`, .Expr, .Stmt, .Pattren:
                return self.rawValue + "Syntax"
                
            case .Syntax, .SyntaxCollection:
                return self.rawValue
                
            }
        }
    }
    
    /// Returns true if SyntaxKind is base
    var isBase: Bool {
        if case SyntaxKind.base(_) = self  {
            return true
        }
        return false
    }
}


func typeOf(_ kind: String) -> String {
    if ["Syntax", "SyntaxCollection"].contains(kind) {
        return kind
    }
    if kind.hasSuffix("Token") { return "TokenSyntax" }
    
    return kind + "Syntax"
}
