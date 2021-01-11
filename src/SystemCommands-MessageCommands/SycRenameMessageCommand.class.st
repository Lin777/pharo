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
		'driverRefactoring'
	],
	#category : #'SystemCommands-MessageCommands'
}

{ #category : #execution }
SycRenameMessageCommand >> applyResultInContext: aToolContext [
	self driverRefactoring applyResult 
]

{ #category : #execution }
SycRenameMessageCommand >> confirmRefactoringInContext: aToolContext by: aCommandActivator [
	self driverRefactoring confirmRefactoringInContext
]

{ #category : #accessing }
SycRenameMessageCommand >> defaultDriver [

	^ RBRenameMethodDriver
]

{ #category : #accessing }
SycRenameMessageCommand >> defaultMenuIconName [
	^#edit

]

{ #category : #accessing }
SycRenameMessageCommand >> defaultMenuItemName [
	^'Rename'
]

{ #category : #accessing }
SycRenameMessageCommand >> driverRefactoring [
	^ driverRefactoring" ifNil: [ interaction := self defaultDriver new ]"
]

{ #category : #execution }
SycRenameMessageCommand >> execute [
	self driverRefactoring executeRefactoring 
]

{ #category : #execution }
SycRenameMessageCommand >> isComplexRefactoring [
	^ self driverRefactoring isComplexRefactoring
]

{ #category : #execution }
SycRenameMessageCommand >> readParametersFromContext: aToolContext [
	driverRefactoring := self defaultDriver context: aToolContext.
]

{ #category : #execution }
SycRenameMessageCommand >> resultMessageSelector [
]
