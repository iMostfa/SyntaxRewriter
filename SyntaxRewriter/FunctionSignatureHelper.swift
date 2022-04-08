//
//  FunctionSignatureHelper.swift
//  SyntaxRewriter
//
//  Created by Mostfa on 08/04/2022.
//

import SwiftSyntaxBuilder
import SwiftSyntax
import Foundation

func functionSignature(nodeType: String, output: String) -> FunctionSignature {
    
    let functionOutput = ReturnClause.init(returnType: SimpleTypeIdentifier(output))
    
    let functionInput = ParameterClause {
        FunctionParameter(firstName: .wildcard,
                          secondName: .identifier("node"),
                          colon: .colon,
                          type: SimpleTypeIdentifier.init(output),
                          attributesBuilder: { return nil })
    }
    
    return FunctionSignature.init(input: functionInput,
                                  output: functionOutput
                                  
    )
    
}

