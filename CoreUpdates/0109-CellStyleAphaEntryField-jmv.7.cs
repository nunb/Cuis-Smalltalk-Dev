'From Squeak3.7 of ''4 September 2004'' [latest update: #5989] on 27 January 2009 at 12:34:20 pm'!
	"Install an editor for my contents.  This constitutes 'hasFocus'.
	If priorEditor is not nil, then initialize the new editor from its state.
	We may want to rework this so it actually uses the prior editor."

	| stateArray |
	priorEditor ifNotNil: [stateArray := priorEditor stateArray].
	editor := self editorClass new morph: self.
	editor changeString: contents.
	priorEditor ifNotNil: [editor stateArrayPut: stateArray].
	self changed.
	^editor! !