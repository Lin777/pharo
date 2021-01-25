Class {
	#name : #RBRenameMethodDriver,
	#superclass : #RBChangeMessageDriver,
	#instVars : [
		'newSignature'
	],
	#category : #'SystemCommands-Utilities'
}

{ #category : #actions }
RBRenameMethodDriver >> applyResult [
	context showMessage: originalMessage renamedTo: newSignature selector asSymbol
]

{ #category : #creating }
RBRenameMethodDriver >> asRefactorings [
	^ { RBRenameMethodRefactoring
		renameMethod: self originalMessage selector 
		in: (SycMessageOriginHack of: self originalMessage) "look at SycMessageOriginHack comment"
		to: self newSignature selector 
		permutation: (self originalMessage computeArgumentPermutationsFor: self newSignature) }
]

{ #category : #testing }
RBRenameMethodDriver >> isComplexRefactoring [ 
	^ true
]

{ #category : #accesing }
RBRenameMethodDriver >> newSignature [
	^ newSignature ifNil: [ newSignature := originalMessage requestNewSignature ]
]

{ #category : #actions }
RBRenameMethodDriver >> prepareFullExecution [
	super prepareFullExecution.
	self newSignature
]
