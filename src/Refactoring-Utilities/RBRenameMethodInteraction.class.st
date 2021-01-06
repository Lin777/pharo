Class {
	#name : #RBRenameMethodInteraction,
	#superclass : #RBChangeMessageInteraction,
	#instVars : [
		'newSignature'
	],
	#category : #'Refactoring-Utilities'
}

{ #category : #actions }
RBRenameMethodInteraction >> applyResult [
	context showMessage: originalMessage renamedTo: newSignature selector asSymbol
]

{ #category : #creating }
RBRenameMethodInteraction >> asRefactorings [
	^ { RBRenameMethodRefactoring
		renameMethod: self originalMessage selector 
		in: (SycMessageOriginHack of: self originalMessage) "look at SycMessageOriginHack comment"
		to: self newSignature selector 
		permutation: (self originalMessage computeArgumentPermutationsFor: self newSignature) }
]

{ #category : #testing }
RBRenameMethodInteraction >> isComplexRefactoring [ 
	^ true
]

{ #category : #accesing }
RBRenameMethodInteraction >> newSignature [
	^ newSignature ifNil: [ newSignature := originalMessage requestNewSignature ]
]

{ #category : #actions }
RBRenameMethodInteraction >> prepareFullExecution [
	super prepareFullExecution.
	self newSignature
]
