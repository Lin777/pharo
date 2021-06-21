Class {
	#name : #RBChildrenToSiblingsTransformation,
	#superclass : #RBCompositeTransformation,
	#instVars : [
		'className',
		'parent',
		'subclasses'
	],
	#category : #'Refactoring2-Transformations-Model'
}

{ #category : #'instance creation' }
RBChildrenToSiblingsTransformation class >> model: aRBSmalltalk name: aClassName class: aClass subclasses: subclassCollection [ 
	^ self new
		model: aRBSmalltalk;
		name: aClassName
			class: aClass
			subclasses: subclassCollection;
		yourself
]

{ #category : #'instance creation' }
RBChildrenToSiblingsTransformation class >> name: aClassName class: aClass subclasses: subclassCollection [ 
	^ self new 
		name: aClassName
			class: aClass
			subclasses: subclassCollection;
		yourself
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> abstractSuperclass [

	^ self model classNamed: className asSymbol
]

{ #category : #'instance creation' }
RBChildrenToSiblingsTransformation >> addSuperclass [

	^ { (RBAddClassTransformation
		   model: self model
		   addClass: className
		   superclass: parent superclass name
		   subclasses: (Array with: parent)
		   category: parent category) }
]

{ #category : #converting }
RBChildrenToSiblingsTransformation >> asRefactoring [

	^ super asRefactoring
		  delegatesPreconditions: false;
		  yourself
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> buildTransformations [

	^ OrderedCollection new 
		addAll: self addSuperclass;
		addAll: self pushUpVariables;
		addAll: self pullUpMethods;
		addAll: self changeIsKindOfReferences;
		addAll: self reparentSubclasses;
		yourself
]

{ #category : #transforming }
RBChildrenToSiblingsTransformation >> changeIsKindOfReferences [

	^ { (RBCustomTransformation model: self model with: [ :aModel | 
		   | replacer |
		   replacer := self parseTreeRewriter.
		   replacer
			   replace: '``@object isKindOf: ' , parent name
			   with: '``@object isKindOf: ' , className.
		   aModel allReferencesToClass: parent do: [ :method | 
			   self
				   convertMethod: method selector
				   for: method modelClass
				   using: replacer ] ]) }
]

{ #category : #'private - methods' }
RBChildrenToSiblingsTransformation >> computeSubclassSupersOf: aClass [

	| selectors |
	selectors := Set new.
	aClass subclasses do: [ :each | 
		each selectors do: [ :sel | 
			selectors addAll: (each parseTreeFor: sel) superMessages ] ].
	^ selectors
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> createSubclassResponsibilityFor: aSelector in: aClass [

	| source |
	(aClass superclass definesMethod: aSelector) ifTrue: [ ^ nil ].
	source := self subclassResponsibilityFor: aSelector in: aClass.
	source ifNil: [ ^ nil ].
	^ RBAddMethodTransformation
		  model: self model
		  sourceCode: source
		  in: aClass superclass
		  withProtocol: (aClass protocolsFor: aSelector) first
]

{ #category : #'instance creation' }
RBChildrenToSiblingsTransformation >> name: aClassName class: aClass subclasses: subclassCollection [ 
	className := aClassName asSymbol.
	parent := self model classFor: aClass.
	subclasses := subclassCollection 
				collect: [:each | self model classFor: each]
]

{ #category : #preconditions }
RBChildrenToSiblingsTransformation >> preconditions [
	^subclasses 
		inject: ((RBCondition isMetaclass: parent) 
				errorMacro: 'Superclass must not be a metaclass') not 
				& (RBCondition isValidClassName: className) 
					& (RBCondition isGlobal: className in: self model) not
		into: 
			[:sub :each | 
			sub 
				& ((RBCondition isMetaclass: each) 
						errorMacro: 'Subclass must <1?not :>be a metaclass') not 
					& (RBCondition isImmediateSubclass: each of: parent)]
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> pullUpClassInstanceVariables [

	^ parent classSide instanceVariableNames collect: [ :each | 
		  RBPullUpVariableTransformation
			  model: self model
			  instanceVariable: each
			  class: className asSymbol , ' class' ]
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> pullUpClassVariables [

	^ parent classVariableNames collect: [ :each | 
		  RBPullUpVariableTransformation
			  model: self model
			  classVariable: each
			  class: className asSymbol ]
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> pullUpInstanceVariables [

	^ parent instanceVariableNames collect: [ :each | 
		  RBPullUpVariableTransformation
			  model: self model
			  instanceVariable: each
			  class: className asSymbol ]
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> pullUpMethods [
	^ (self pushUpMethodsFrom: parent),
	(self pushUpMethodsFrom: parent classSide)
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> pullUpPoolVariables [

	"Don't remove the pool variables from the subclass since they might be referenced there."

	| newSuperclass |
	newSuperclass := self abstractSuperclass.
	^ parent sharedPoolNames collect: [ :each | 
		RBCustomTransformation model: self model with: [ :aModel |
		newSuperclass addPoolDictionary: each ]]
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> pushUp: aSelector in: aClass [

	| source |
	source := aClass sourceCodeFor: aSelector.
	source ifNotNil: [ 
		^ RBAddMethodTransformation
			  model: self model
			  sourceCode: source
			  in: aClass superclass
			  withProtocol: (aClass protocolsFor: aSelector) first ].
	^ nil
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> pushUpMethodsFrom: aClass [

	| selectorsToPushUp |
	selectorsToPushUp := self selectorsToPushUpFrom: aClass.
	^ (aClass selectors
		   collect: [ :each | 
			   (selectorsToPushUp includes: each)
				   ifTrue: [ self pushUp: each in: aClass ]
				   ifFalse: [ 
				   self createSubclassResponsibilityFor: each in: aClass ] ]
		   thenSelect: [ :e | e isNotNil ])
	  , (selectorsToPushUp collect: [ :symbol | 
			   RBRemoveMethodTransformation
				   model: self model
				   selector: symbol
				   from: aClass ])
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> pushUpVariables [

	^ (self pullUpInstanceVariables , self pullUpClassInstanceVariables
	   , self pullUpClassVariables , self pullUpPoolVariables) flattened
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> reparentSubclasses [

	^ { RBCustomTransformation model: self model with: [ :aModel | 
		   aModel reparentClasses: subclasses to: self abstractSuperclass ] }
]

{ #category : #'private - methods' }
RBChildrenToSiblingsTransformation >> selectorsToPushUpFrom: aClass [ 
	| superSelectors |
	superSelectors := self computeSubclassSupersOf: aClass.
	^aClass selectors select: 
			[:each | 
			(superSelectors includes: each) or: [self shouldPushUp: each from: aClass]]
]

{ #category : #'private - methods' }
RBChildrenToSiblingsTransformation >> shouldPushUp: aSelector from: aClass [

	^ (aClass isMeta
		   ifTrue: [ subclasses collect: [ :each | each classSide ] ]
		   ifFalse: [ subclasses ]) anySatisfy: [ :each | 
		  (each directlyDefinesMethod: aSelector) not ]
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' name: #';
		nextPutAll: className;
		nextPutAll: ' class: '.
	parent storeOn: aStream.
	aStream nextPutAll: ' subclasses: '.
	subclasses asArray storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #executing }
RBChildrenToSiblingsTransformation >> subclassResponsibilityFor: aSelector in: aClass [
	| methodNode position source |
	source := aClass sourceCodeFor: aSelector.
	methodNode := self parserClass
		parseMethod: source
		onError: [ :err :pos | ^ nil ].
	position := methodNode arguments isEmpty
		ifTrue: [ methodNode keywordsIntervals last last ]
		ifFalse: [ methodNode arguments last stop ].
	^ '<1s><n><t>self subclassResponsibility'
		expandMacrosWith: (source copyFrom: 1 to: position)
]
