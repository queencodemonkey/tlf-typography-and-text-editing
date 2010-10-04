//==============================================================================
//
//   Copyright (c) 2010 Huyen Tue Dao 
// 
//   Permission is hereby granted, free of charge, to any person obtaining a 
//   copy of this software and associated documentation files (the "Software"), 
//   to deal in the Software without restriction, including without limitation 
//   the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//   and/or sell copies of the Software, and to permit persons to whom the 
//   Software is furnished to do so, subject to the following conditions: 
// 
//   The above copyright notice and this permission notice shall be included 
//   in all copies or substantial portions of the Software. 
// 
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//   DEALINGS IN THE SOFTWARE. 
//
//==============================================================================
package com.queencodemonkey.tttlf.components.layout
{
	import com.queencodemonkey.tttlf.skins.layout.PageSkin;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.MoveEvent;
	import mx.events.ResizeEvent;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.RichText;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.primitives.Rect;

	/**
	 * The Page class is a component that represents and displays a page worth
	 * of text.
	 *
	 * @author Huyen Tue Dao
	 */
	public class Page extends SkinnableComponent
	{
		private static var classConstructed:Boolean = setDefaultStyles(); 
		
		/**
		 * @private
		 * Sets default values for style properties.
		 */
		private static function setDefaultStyles():Boolean
		{
			var pageStyles:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration( "com.hmhpub.txla.nettext.views.ContentView" );
			if ( !pageStyles )
			{
				pageStyles = new CSSStyleDeclaration();
			}
			pageStyles.defaultFactory = function():void
			{
				this.skinClass = PageSkin;
			};
			FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration( "com.queencodemonkey.tttlf.components.layout.Page", pageStyles, true );
			
			return true;
		}
		
		[SkinPart( required="true" )]
		/**
		 * The sprite that actually holds rendered text.
		 */
		public var container:Sprite = null;
		
		/**
		 * The length of text contained in the page. 
		 */		
		public function get textLength():int
		{
			return containerController? containerController.textLength : NaN;
		}

		/**
		 * The controller that links this page to a TextFlow.
		 */
		protected var containerController:ContainerController = null;

		/**
		 * Constructor.
		 */
		public function Page()
		{
			super();
		}
		
		/**
		 * Whether the page is the first page displayed for a text flow. 
		 */		
		public function isFirstPage():Boolean
		{
			return containerController && containerController.absoluteStart == 0;
		}
		
		/**
		 * Whether the page is the last page display for a text flow.
		 */		
		public function isLastPage():Boolean
		{
			return containerController.textFlow && ( containerController.absoluteStart + containerController.textLength ) >= containerController.textFlow.textLength;
		}

		/**
		 * Links the page to a text flow and sets up the page to display
		 * content.
		 * @param textFlow A TextFlow instance to connect to the page.
		 */
		public function linkToTextFlow( textFlow:TextFlow ):void
		{
			if ( !containerController || containerController.textFlow != textFlow )
			{
				containerController = new ContainerController( container, container.width, container.height );
				// Need to set verticalScrollPolicy to off so that no partial
				// lines are laid out in a container: a page should only be
				// assigned as many text lines as it can display.
				containerController.verticalScrollPolicy = ScrollPolicy.OFF;
				textFlow.flowComposer.addController( containerController );
				textFlow.flowComposer.updateAllControllers();
			}
		}
		
		/**
		 * Unlinks the page from a text flow, clearing out content from that
		 * text flow.
		 * 
		 * First checks whether the page is actually linked to the given
		 * text flow.
		 * 
		 * @param textFlow A TextFlow instance from which to unlink the page.
		 */		
		public function unlinkFromTextFlow( textFlow:TextFlow = null ):void
		{
			if ( containerController && ( !textFlow || containerController.textFlow == textFlow ) )
			{
				for ( var i:int = container.numChildren - 1; i >= 0; i-- )
				{
					container.removeChildAt( i );
				}
				if ( !textFlow )
					textFlow = containerController.textFlow;
				textFlow.flowComposer.removeController( containerController );
				textFlow.flowComposer.updateAllControllers();
				containerController = null;
			}
		}
		
		/**
		 * @inheritDoc
		 */		
		override protected function partAdded( partName:String, instance:Object ):void
		{
			super.partAdded( partName, instance );
			if ( instance == container )
			{
				container.addEventListener( ResizeEvent.RESIZE, container_resizeHandler );
				container.addEventListener( MoveEvent.MOVE, container_moveHandler );
			}
		}
		
		/**
		 * @inheritDoc
		 */	
		override protected function partRemoved( partName:String, instance:Object ):void
		{
			super.partRemoved( partName, instance );
			if ( instance == container )
			{
				container.removeEventListener( ResizeEvent.RESIZE, container_resizeHandler );
				container.removeEventListener( MoveEvent.MOVE, container_moveHandler );
			}
		}
		
		/**
		 * @private
		 * Resets the composition size when the container has resized. 
		 */
		private function container_resizeHandler( event:ResizeEvent ):void
		{
			if ( containerController )
			{
				resetControllerDimensions();
			}
		}
		
		/**
		 * @private
		 * Resets the composition size when the container has moved.
		 */
		private function container_moveHandler( event:MoveEvent ):void
		{
			if ( containerController )
			{
				resetControllerDimensions();
			}
		}
		
		/**
		 * @private
		 * Resets the composition size and initiates a rendering update. 
		 */		
		private function resetControllerDimensions():void
		{
			containerController.setCompositionSize( container.width, container.height );
			containerController.textFlow.flowComposer.updateAllControllers();	
		}
	}
}