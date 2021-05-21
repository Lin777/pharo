Class {
	#name : #SpMorphicDialogAsModalWindowAdapter,
	#superclass : #SpMorphicDialogWindowAdapter,
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #api }
SpMorphicDialogAsModalWindowAdapter >> closeOnBackdropClick [

	^ self model closeOnBackdropClick
]

{ #category : #'event handling' }
SpMorphicDialogAsModalWindowAdapter >> mouseClick: evt onBackdrop: aMorph [

	self closeOnBackdropClick ifFalse: [ ^ self ].

	self model triggerCancelAction.
	self model close. "Ensure the modal is closed"
	aMorph delete
]

{ #category : #'instance creation' }
SpMorphicDialogAsModalWindowAdapter >> open [ 
	self widget beSticky.
	self presenter windowIsOpening.
	"I am copying here what is defined in SystemWindow>>#openModal (but introducing the centered 
	 check inbetween because #openInWorld will use the RealEstateAgent to position the window 
	 and we want to (maybe) center it before showing it."
	self widget openInWorld.
	self presenter isCentered 
		ifTrue: [ self centered ].
	MorphicRenderLoop new doOneCycleWhile: [ self widget isInWorld ]
]
