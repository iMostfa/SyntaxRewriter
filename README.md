# SwiftRewriter
Generating Swift code using SwiftSyntaxBuilder instead of GYB
## Introduction

In this project i’m demonstrating generating code using SwiftSyntaxBuilder instead of GYB, 

the part i’m generating is taken from SwiftRewriter class, which is a class inside SwiftSyntax.

in SyntaxRewriter.swift.gyb we can see a usage of GYB

which access an array of Syntax_Nodes defined at Python side, and for each node, will generate the following if a node isVisitable, which is another function defined at python side on a Node class

```swift
//Assume somewhere at Python source code SYNTAX_NODES = [
		// Node('UnknownDecl', kind='Decl'),
    // Node('UnknownExpr', kind='Expr'),
    // Node('UnknownStmt', kind='Stmt'),
    // Node('UnknownType', kind='Type'),
    // Node('UnknownPattern', kind='Pattern'),
// ]

% for node in SYNTAX_NODES:
%   if is_visitable(node):
  /// Visit a `${node.name}`.
  ///   - Parameter node: the node that is being visited
  ///   - Returns: the rewritten node
  open func visit(_ node: ${node.name}) -> ${node.base_type} {
    return ${node.base_type}(visitChildren(node))
  }

%   end
% end
```

when executed, the following code is generated in SyntaxRewriter.swift file

```swift
open func visit(_ node: UnknownDeclSyntax) -> DeclSyntax {
    return DeclSyntax(visitChildren(node))
  }

  /// Visit a `UnknownExprSyntax`.
  ///   - Parameter node: the node that is being visited
  ///   - Returns: the rewritten node
  open func visit(_ node: UnknownExprSyntax) -> ExprSyntax {
    return ExprSyntax(visitChildren(node))
  }

  /// Visit a `UnknownStmtSyntax`.
  ///   - Parameter node: the node that is being visited
  ///   - Returns: the rewritten node
  open func visit(_ node: UnknownStmtSyntax) -> StmtSyntax {
    return StmtSyntax(visitChildren(node))
  }
```

## Importing Python classes

To regenerate the previously mentioned code we have to import Python classes and helpers into Swift, these classes can be found in the main Swift folder (under utils/gyb_syntax_support)

i’ve imported only needed classes and functions to make the generation possible, imported classes are

- Node: A Syntax node, possibly with children.
- SyntaxKind: [Kind.py](http://Kind.py) holds SYNTAX_BASE_KINDS and some helper functions, in swift side i’ve imported it to be an enum
- commonNodes: in [commonNodes.py](http://commonNodes.py) there’is COMMON_NODES which an array to some nodes, i’ve imported some of them to swift so we can test the generation

there’re a lot of classes to be used later, but this’s enough to use SwiftSyntaxBuilder in SyntaxRewriter.swift

### Usage of SwiftSyntaxBuilder

the following snippets re-generate swift code as the following

```swift
SourceFile {

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
                FunctionCallExpr(calledExpression: IdentifierExpr(node.baseType), leftParen: .leftParen, rightParen: .rightParen) {
                    TupleExprElement(expression:
                                        FunctionCallExpr(calledExpression: IdentifierExpr("visitChildren"), leftParen: .leftParen, rightParen: .rightParen){
                        TupleExprElement(expression: IdentifierExpr.init("node"))
                    }

                    )
                }
            }

        }

    }
}
```

where the output would be: 

```swift
public func visit(_ node: DeclSyntax)-> DeclSyntax{
    return DeclSyntax(visitChildren(node))
}
public func visit(_ node: ExprSyntax)-> ExprSyntax{
    return ExprSyntax(visitChildren(node))
}
public func visit(_ node: StmtSyntax)-> StmtSyntax{
    return StmtSyntax(visitChildren(node))
}
public func visit(_ node: TypeSyntax)-> TypeSyntax{
    return TypeSyntax(visitChildren(node))
}
public func visit(_ node: PattrenSyntax)-> PattrenSyntax{
    return PattrenSyntax(visitChildren(node))
}
```

and with some syntactic sugar, we can rewrite the ReturnStmt as the following: 

```swift
extension ReturnStmt {
    init(_ expression:  () -> (ExpressibleAsExprBuildable?)) {
        self.init(returnKeyword: .return, expression: expression())
    }
}

extension FunctionCallExpr {
    init(calledExpression: ExpressibleAsExprBuildable,
    trailingClosure: ExpressibleAsClosureExpr? = nil, 
    argumentListBuilder: () -> ExpressibleAsTupleExprElementList = { TupleExprElementList([]) },
    additionalTrailingClosuresBuilder: () -> ExpressibleAsMultipleTrailingClosureElementList? = { nil }) {
        
        self.init(calledExpression: calledExpression, 
        leftParen: .leftParen,
        rightParen: .rightParen,
        trailingClosure: trailingClosure,
        argumentListBuilder: argumentListBuilder,
        additionalTrailingClosuresBuilder: additionalTrailingClosuresBuilder)
    }
}

bodyBuilder: {
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
```

### Improvements and comments

- currently it seems like open modifier is not available [(yet)](https://github.com/apple/swift/pull/42260) so i’ve used public
- i’m still questioning and investigating how/where the linting should be applied, for example:

```swift
//GYB Generated function signature
) -> TypeSyntax {
//SwiftSyntaxBuilder signatures 
)-> StmtSyntax{

//while the generated code is alike, the spacing before the arrow
//and curly brace isn't generated
```

- Comments, it looks like that comments are not supported at AST level, which is something needed to replace GYB
- API Design: i’m still skeptical about the API design of SyntaxKind, should this be changed to something better ?
- Generation integration, how can we use SwiftSyntaxBuilder, should we introduce a result builder like this, which will be placed at any swift file, and get generated later ? (much like GYB) ?

```swift
GeneratedBlock { 
ImportDecl(path: "Foundation")
    ImportDecl(path: "UIKit")
  ClassDecl(classOrActorKeyword: .class, identifier: "SomeViewController", membersBuilder: {
    VariableDecl(.let, name: "tableView", type: "UITableView")
  })
}
```

### What’s next

this’s a demonstration about the usage of SwiftSynaxBuilder in SwiftSyntax, which is a part of my proposal at GSoC, i would love to continue working on this  integration and enhancing it
