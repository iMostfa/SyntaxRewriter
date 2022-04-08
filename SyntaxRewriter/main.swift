//
//  main.swift
//  SyntaxRewriter
//
//  Created by Mostfa on 06/04/2022.
//


import SwiftSyntaxBuilder
import SwiftSyntax
import Foundation


let source = SourceFile {
    
    for node in commonNodes  {
        
        FunctionDecl(identifier: .identifier("visit"),
                     signature: functionSignature(nodeType: node.name, output: node.baseType)) {
        } modifiersBuilder: {
            TokenSyntax.public
        } bodyBuilder: {
            ReturnStmt {
                FunctionCallExpr(calledExpression: IdentifierExpr(node.baseType),
                                 argumentListBuilder: {
                    TupleExprElement(expression:
                                        FunctionCallExpr(calledExpression: IdentifierExpr("visitChildren"),
                                                         argumentListBuilder: {
                        TupleExprElement(expression: IdentifierExpr.init("node"))
                    })
                    )
                })
            }
            
            
            
        }
        
    }
}
let syntax = source.buildSyntax(format: Format())

var text = ""
syntax.write(to: &text)

print(text)


extension ReturnStmt {
    init(_ expression:  () -> (ExpressibleAsExprBuildable?)) {
        self.init(returnKeyword: .return, expression: expression())
    }
}
