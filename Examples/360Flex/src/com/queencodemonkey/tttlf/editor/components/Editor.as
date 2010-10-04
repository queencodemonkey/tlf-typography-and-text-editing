//==============================================================================
//
//   Copyright (c) 2010 Huyen Tue Dao 
// 
//   Permission is hereby granted, free of charge, to any person obtaining a copy 
//   of this software and associated documentation files (the "Software"), to deal 
//   in the Software without restriction, including without limitation the rights 
//   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//   copies of the Software, and to permit persons to whom the Software is 
//   furnished to do so. 
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

package com.queencodemonkey.tttlf.editor.components
{
	import com.queencodemonkey.tttlf.editor.events.ToolbarEvent;
	import com.queencodemonkey.tttlf.textLayout.edit.TTTLFEditManager;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.ElementRange;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.undo.UndoManager;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import spark.components.SkinnableContainer;

	public class Editor extends SkinnableContainer
	{
		[SkinPart( required="true" )]
		public var container:UIComponent;

		[SkinPart( required="true" )]
		public var toolbar:Toolbar;

		public function get textFlow():TextFlow
		{
			return _textFlow;
		}

		public function set textFlow( value:TextFlow ):void
		{
			if ( value != _textFlow )
			{
				_textFlow = value;
				textFlowDirty = true;
				invalidateProperties();
			}
		}

		private var _textFlow:TextFlow;

		private var textFlowDirty:Boolean = false;

		private var editManager:EditManager = null;


		public function Editor()
		{
			super();

			construct();
		}

		override protected function partAdded( partName:String, instance:Object ):void
		{
			super.partAdded( partName, instance );

			if ( instance == toolbar )
			{
				toolbar.addEventListener( ToolbarEvent.FORMAT_CHANGE, toolbar_formatChangeHandler );
				toolbar.addEventListener( ToolbarEvent.BLOCK_QUOTE_FORMAT, toolbar_applyBlockFormat );
			}
			else if ( instance == container )
			{
				container.addEventListener( ResizeEvent.RESIZE, container_resizeHandler );
			}
		}
		override protected function partRemoved( partName:String, instance:Object ):void
		{
			super.partRemoved( partName, instance );

			if ( instance == toolbar )
			{
				toolbar.removeEventListener( ToolbarEvent.FORMAT_CHANGE, toolbar_formatChangeHandler );
			}
			else if ( instance == container )
			{
				container.removeEventListener( ResizeEvent.RESIZE, container_resizeHandler );
			}
		}

		override protected function commitProperties():void
		{
			super.commitProperties();

			if ( textFlowDirty )
			{
				if ( !textFlow )
				{
					textFlow = new TextFlow();
					toolbar.enabled = false;
				}
				else
				{
					toolbar.enabled = true;
				}
				clearContainer();
				
				textFlow.flowComposer.addController( new ContainerController( container, container.width, container.height ) );
				textFlow.flowComposer.updateAllControllers();
				textFlow.interactionManager = editManager;
				
				textFlow.addEventListener( SelectionEvent.SELECTION_CHANGE, textFlow_selectionChangeHandler );
				
				textFlowDirty = false;
			}
		}

		private function textFlow_selectionChangeHandler(event:SelectionEvent):void
		{
			var selectionState:SelectionState = event.selectionState;
			var compiledFormat:ITextLayoutFormat = null;
			var range:ElementRange = null;
			
			if ( selectionState && selectionState.absoluteStart == selectionState.absoluteEnd )
			{
				if ( selectionState.pointFormat )
				{
					compiledFormat = selectionState.pointFormat;
				}
				else
				{
					range = ElementRange.createElementRange( selectionState.textFlow, selectionState.absoluteStart, selectionState.absoluteEnd );
					compiledFormat = new TextLayoutFormat();
					( compiledFormat as TextLayoutFormat ).concat( range.characterFormat );
					( compiledFormat as TextLayoutFormat ).concat( range.paragraphFormat );
				}
			}
			else
			{
				range = selectionState ? ElementRange.createElementRange( selectionState.textFlow, selectionState.absoluteStart, selectionState.absoluteEnd ) : null;
				var leaf:FlowLeafElement = range.firstLeaf;
				compiledFormat = new TextLayoutFormat(); 
				( compiledFormat as TextLayoutFormat ).concat( leaf.computedFormat );
				while ( leaf )
				{
					( compiledFormat as TextLayoutFormat ).removeClashing( leaf.computedFormat );
					if ( leaf == range.lastLeaf )
						leaf = null;
					else
						leaf = leaf.getNextLeaf();
				}
			}
			if ( compiledFormat )
				toolbar.updateValues( compiledFormat );
		}

		private function construct():void
		{
//			editManager = new EditManager( new UndoManager() );
			editManager = new TTTLFEditManager( new UndoManager() );
		}

		private function clearContainer():void
		{
			while ( container.numChildren > 0 )
			{
				container.removeChildAt( 0 );
			}
		}

		private function container_resizeHandler( event:ResizeEvent ):void
		{
			if ( textFlow && textFlow.flowComposer && textFlow.flowComposer.numControllers > 0 )
			{
				textFlow.flowComposer.getControllerAt( 0 ).setCompositionSize( container.width, container.height );
				textFlow.flowComposer.updateAllControllers();
			}
		}

		private function toolbar_formatChangeHandler( event:ToolbarEvent ):void
		{
			var editManager:EditManager = textFlow.interactionManager as EditManager;
			var layoutFormat:TextLayoutFormat = new TextLayoutFormat();
			var formatProperty:String = event.formatProperty;
			
			layoutFormat[ formatProperty ] = event.value;
			
			switch ( formatProperty )
			{
				case "textAlign":
					editManager.applyParagraphFormat( layoutFormat );
					break;
				default:
					editManager.applyLeafFormat( layoutFormat );
					break;
			}
		}
		
		private function toolbar_applyBlockFormat( event:ToolbarEvent ):void
		{
			( editManager as TTTLFEditManager ).applyBlockQuoteFormat();
		}

	}
}