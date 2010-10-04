//==============================================================================
//
//   Copyright (c) 2010 Huyen Tue Dao 
// 
//   Permission is hereby granted, free of charge, to any person obtaining a
//   copy of this software and associated documentation files (the "Software"),
//   to deal in the Software without restriction, including without limitation
//   the rights to use, copy, modify, merge, publish, distribute, sublicense,
//   and/or sell copies of the Software, and to permit persons to whom the
//   Software is furnished to do so. 
// 
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
//   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
//   THE SOFTWARE. 
//
//==============================================================================
package com.queencodemonkey.tttlf.textLayout.edit
{
	import com.queencodemonkey.tttlf.textLayout.operations.BlockQuoteOperation;
	
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.IUndoManager;
	
	use namespace tlf_internal;
	
	public class TTTLFEditManager extends EditManager
	{
		public function TTTLFEditManager( undoManager:IUndoManager = null )
		{
			super( undoManager );
		}
		
		public function applyBlockQuoteFormat( operationState:SelectionState = null ):void
		{
			operationState = defaultOperationState( operationState );
			
			if ( !operationState )
				return;
			doOperation( new BlockQuoteOperation( operationState ) );
		}
		
		public function searchText( searchString:String = null, operationState:SelectionState = null ):void
		{
			operationState = defaultOperationState( operationState );
			
			if ( !searchString && operationState && operationState.absoluteStart != operationState.absoluteEnd )
			{
				searchString = textFlow.getText( operationState.absoluteStart, operationState.absoluteEnd ); 
			}
			if ( searchString )
			{
				
			}
		}
	}
}