Class {
	#name : #RBCreateCascadeRefactoringTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBCreateCascadeRefactoringTest >> testBadInterval [ 
	self shouldFail: 
		(RBCreateCascadeRefactoring 
			combine: (54 to: 62) 
			from: #demoRenameMethod:PermuteArgs:
			in: RBRefactoryTestDataApp)
]

{ #category : #'failure tests' }
RBCreateCascadeRefactoringTest >> testBadMethodName [
	self shouldFail: 
		(RBCreateCascadeRefactoring 
			combine: (54 to: 62) 
			from: #demoRenameMethod:PermuteArgs1:
			in: RBRefactoryTestDataApp)
]

{ #category : #tests }
RBCreateCascadeRefactoringTest >> testCreateCascade1 [
	| ref class | 
	ref := RBCreateCascadeRefactoring 
			combine: (43 to: 73) 
			from: #demoRenameMethod:PermuteArgs:
			in: RBRefactoryTestDataApp.
	model := ref model.
	self executeRefactoring: ref.
	class := model classNamed: #RBRefactoryTestDataApp.
	self assert: (class parseTreeFor: #demoRenameMethod:PermuteArgs:) equals: (self parseMethod: 'demoRenameMethod: arg1 PermuteArgs: arg2
	self do: arg1;
		do: arg2.
	^ arg1 > arg2').
	
]

{ #category : #tests }
RBCreateCascadeRefactoringTest >> testCreateCascade2 [
	| ref class | 
	ref := RBCreateCascadeRefactoring 
			combine: (37 to: 150) 
			from: #modifiesCollection
			in: RBRefactoryTestDataApp.
	model := ref model.
	self proceedThroughWarning: [ self executeRefactoring: ref ].
	class := model classNamed: #RBRefactoryTestDataApp.
	self flag: #TODO 
	"self assert: (class parseTreeFor: #modifiesCollection) equals: 
		(self parseMethod: 'modifiesCollection
	| collection |
	collection := (1 to: 10) asOrderedCollection;
		do: [:each | each > 5 ifTrue: [collection remove: each]].
	^collection')."
	
]
