Extension { #name : #ClassVariable }

{ #category : #'*SystemCommands-VariableCommands' }
ClassVariable >> createRefactoring: variableRefactoringClass for: declarationClass [

	^ variableRefactoringClass
		  classVariable: self name
		  class: declarationClass
]
