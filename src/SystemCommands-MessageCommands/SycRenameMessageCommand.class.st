"
I am a command to rename message selector.
In addition I allow to swap arguments in signature.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	newSignature:		<SycMessageDescription>
"
Class {
	#name : #SycRenameMessageCommand,
	#superclass : #SycChangeMessageSignatureCommand,
	#instVars : [
		'interaction'
	],
	#category : #'SystemCommands-MessageCommands'
}

{ #category : #execution }
SycRenameMessageCommand >> applyResultInContext: aToolContext [
	self interaction applyResult 
]

{ #category : #execution }
SycRenameMessageCommand >> confirmRefactoringInContext: aToolContext by: aCommandActivator [
	self interaction confirmRefactoringInContext
]

{ #category : #accessing }
SycRenameMessageCommand >> defaultMenuIconName [
	^#edit

]

{ #category : #accessing }
SycRenameMessageCommand >> defaultMenuItemName [
	^'Rename'
]

{ #category : #execution }
SycRenameMessageCommand >> execute [
	self interaction executeRefactoring 
]

{ #category : #accessing }
SycRenameMessageCommand >> interaction [
	^ interaction ifNil: [ interaction := RBRenameMethodInteraction new ]
]

{ #category : #execution }
SycRenameMessageCommand >> isComplexRefactoring [
	^ self interaction isComplexRefactoring
]

{ #category : #execution }
SycRenameMessageCommand >> prepareFullExecutionInContext: aToolContext [
	self interaction context: aToolContext
]

{ #category : #execution }
SycRenameMessageCommand >> resultMessageSelector [
]
