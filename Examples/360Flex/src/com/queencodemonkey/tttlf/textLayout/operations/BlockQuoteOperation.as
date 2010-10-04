package com.queencodemonkey.tttlf.textLayout.operations
{
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.operations.ApplyFormatOperation;
	import flashx.textLayout.operations.FlowTextOperation;
	import flashx.textLayout.operations.InsertTextOperation;
	
	public class BlockQuoteOperation extends FlowTextOperation
	{
		private var formatOperation:ApplyFormatOperation = null;
		
		private var insertStartQuoteOperation:InsertTextOperation = null;
		
		private var insertEndQuoteOperation:InsertTextOperation = null;
		
		public function BlockQuoteOperation( operationState:SelectionState )
		{
			super( operationState );
		}
		
		override public function doOperation():Boolean
		{
			insertStartQuoteOperation = new InsertTextOperation( new SelectionState( textFlow, originalSelectionState.absoluteStart, originalSelectionState.absoluteStart ), "\"" );
			
			insertEndQuoteOperation = new InsertTextOperation( new SelectionState( textFlow, originalSelectionState.absoluteEnd + 1, originalSelectionState.absoluteEnd + 1 ), "\"" );
			
			var blockQuoteParagraphFormat:TextLayoutFormat = new TextLayoutFormat();
			
			blockQuoteParagraphFormat.paragraphStartIndent = 100;
			blockQuoteParagraphFormat.paragraphEndIndent = 100;
			
			formatOperation = new ApplyFormatOperation( new SelectionState( textFlow, originalSelectionState.absoluteStart, originalSelectionState.absoluteEnd + 2 ), null, blockQuoteParagraphFormat );
			
			insertStartQuoteOperation.doOperation();
			insertEndQuoteOperation.doOperation();
			formatOperation.doOperation();
			
			return true;
		}
		
		override public function undo():SelectionState
		{
			formatOperation.undo();
			insertEndQuoteOperation.undo();
			insertStartQuoteOperation.undo();
			return originalSelectionState;
		}
	}
}