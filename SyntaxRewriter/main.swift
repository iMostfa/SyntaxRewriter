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

    //For each node, generate the following
    for node in commonNodes {
        //starting a declaration of a function called visit
        FunctionDecl(identifier: .identifier("visit"),
                     //function is generated using a helper function, signature would be like this '(_ node: DeclSyntax)-> DeclSyntax'
                     signature: functionSignature(nodeType: node.name, output: node.baseType)) {
        } modifiersBuilder: {
            //adding public modifier to the function declaration so it become 'public func visit' instead of 'func visit', multiple modifiers could be added
            TokenSyntax.public
        } bodyBuilder: {
            //body of function, is just a one line, which is a return statement
            ReturnStmt {
                FunctionCallExpr(calledExpression: IdentifierExpr(node.baseType)) {
                    TupleExprElement(expression:
                                        FunctionCallExpr(calledExpression: IdentifierExpr("visitChildren")) {
                        TupleExprElement(expression: IdentifierExpr.init("node"))
                    }

                    )
                }
            }

        }

    }
}
let syntax = source.buildSyntax(format: Format())

var text = ""
syntax.write(to: &text)

print(text)
