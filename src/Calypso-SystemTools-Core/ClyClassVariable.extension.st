Extension { #name : #ClyClassVariable }

{ #category : #'*Calypso-SystemTools-Core' }
ClyClassVariable >> createRefactoring: variableRefactoringClass for: aClass [

	^ variableRefactoringClass
		  classVariable: actualVariable name
		  class: aClass
]
