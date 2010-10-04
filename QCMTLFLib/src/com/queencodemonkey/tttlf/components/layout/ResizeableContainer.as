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
	import com.queencodemonkey.tttlf.skins.layout.ResizeButtonSkin;
	import com.queencodemonkey.tttlf.skins.layout.ResizeableContainerSkin;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flashx.textLayout.container.ContainerController;
	
	import mx.core.FlexGlobals;
	import mx.events.ResizeEvent;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.Button;
	import spark.components.SkinnableContainer;
	/**
	 * The ResizeableContainer class is a skinnable, resizeable container.
	 *  
	 * @author Huyen Tue Dao
	 */
	public class ResizeableContainer extends SkinnableContainer
	{
		/**
		 * Static variable that initiates setting of default styles. 
		 */		
		private static var classConstructed:Boolean = setDefaultStyles();
		
		/**
		 * @private
		 * Sets default values for style properties.
		 */
		private static function setDefaultStyles():Boolean
		{
			var resizeableStyles:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration( "com.queencodemonkey.tttlf.components.layout.ResizeableContainer" );
			if ( !resizeableStyles )
			{
				resizeableStyles = new CSSStyleDeclaration();
			}
			resizeableStyles.defaultFactory = function():void
			{
				this.skinClass = ResizeableContainerSkin;
			};
			FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration( "com.queencodemonkey.tttlf.components.layout.ResizeableContainer", resizeableStyles, true );
			
			return true;
		}
		
		/**
		 * Constructor. 
		 */		
		public function ResizeableContainer()
		{
			super();

			construct();
		}

		[SkinPart( required="true" )]
		/**
		 *  The sprite used to hold rendered text content.
		 */
		public var container:Sprite;

		/**
		 * The container controller that manages the text rendering in the
		 * container. 
		 */		
		public var containerController:ContainerController;
		
		[SkinPart( required="true" )]
		/**
		 * The button used for resizing the container. 
		 */		
		public var resizeButton:Button;

		/**
		 * @private
		 * The difference between the last mouse down x-position and the
		 * x-position of the container. 
		 */		
		private var diffX:Number = NaN;
		
		/**
		 * @private
		 * The difference between the last mouse down y-position and the
		 * y-position for the container. 
		 */
		private var diffY:Number = NaN;
		
		/**
		 * @inheritDoc
		 */	
		override protected function partAdded( partName:String, instance:Object ):void
		{
			super.partAdded( partName, instance );

			if ( instance == resizeButton )
			{
				resizeButton.addEventListener( MouseEvent.MOUSE_DOWN, resizeButton_mouseDownHandler );
				resizeButton.setStyle( "skinClass", ResizeButtonSkin );
			}
			else if ( instance == container )
			{
				container.addEventListener( ResizeEvent.RESIZE, container_resizeHandler );
			}
		}
		
		/**
		 * @inheritDoc
		 */	
		override protected function partRemoved( partName:String, instance:Object ):void
		{
			super.partRemoved( partName, instance );

			if ( instance == resizeButton )
			{
				resizeButton.removeEventListener( MouseEvent.MOUSE_DOWN, resizeButton_mouseDownHandler );
			}
			else if ( instance == container )
			{
				container.removeEventListener( ResizeEvent.RESIZE, container_resizeHandler );
			}
		}
		
		/**
		 * @private 
		 * Initializer function for the constructor for taking advantage of 
		 * JIT compilation.
		 */
		private function construct():void
		{
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
		}
		
		/**
		 * @private
		 * Handles resizing of the text container by resetting the composition
		 * size of the container controller and initiating a text rendering
		 * update.
		 */		
		private function container_resizeHandler( event:ResizeEvent ):void
		{
			if ( containerController && containerController.textFlow.flowComposer )
			{
				containerController.setCompositionSize( container.width, container.height );
				containerController.textFlow.flowComposer.updateAllControllers();
			}
		}
		
		/**
		 * @private
		 * Handles mouse down events on the container which initiates moving of
		 * the container. 
		 */
		private function mouseDownHandler( event:MouseEvent ):void
		{
			stage.addEventListener( MouseEvent.MOUSE_MOVE, stage_moveMouseMoveHandler )
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_moveMouseUpHandler );
			var currentStagePosition:Point = parent.localToGlobal( new Point( x, y ) );
			diffX = stage.mouseX - currentStagePosition.x;
			diffY = stage.mouseY - currentStagePosition.y;
		}
		
		/**
		 * @private
		 * Handles interaction with the resize button.  When the user mouses
		 * down on the resize button, adds handlers for changing size of
		 * container as user moves mouse.  Also removes mouse down handler for
		 * container so that no move logic is executed while the container is
		 * resized.
		 */
		private function resizeButton_mouseDownHandler( event:MouseEvent ):void
		{
			stage.addEventListener( MouseEvent.MOUSE_MOVE, stage_resizeMouseMoveHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_resizeMouseUpHandler );
			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
		}
		
		/**
		 * @private 
		 * Handles move events while the container is in move mode and
		 * repositions the container as the user moves the mouse. 
		 */		
		private function stage_moveMouseMoveHandler( event:MouseEvent ):void
		{
			var currentPosition:Point = parent.globalToLocal( new Point( stage.mouseX - diffX, stage.mouseY - diffY ) );
			x = currentPosition.x;
			y = currentPosition.y;
		}
		
		/**
		 * @private
		 * Handles the mouse up event when the container is in move mode and
		 * ends move mode, removing move-specific handlers. 
		 */
		private function stage_moveMouseUpHandler( event:MouseEvent ):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, stage_moveMouseMoveHandler )
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_moveMouseUpHandler );
		}
		
		/**
		 * @private
		 * Handles mouse move events in resize mode by resizing the container
		 * in accordance to the user moving the mouse. 
		 */
		private function stage_resizeMouseMoveHandler( event:MouseEvent ):void
		{
			var position:Point = new Point( x, y );
			var globalPosition:Point = parent.localToGlobal( position );
			width = event.stageX - globalPosition.x;
			height = event.stageY - globalPosition.y;
			container.width = width - 3;
			container.height = height - 3;
			x = position.x;
			y = position.y;
		}
		
		/**
		 * @private
		 * Handles mouse up event in resize mode and ends resize mode, removing
		 * resize-specific handlers and adds back the mouse down handler. 
		 */		
		private function stage_resizeMouseUpHandler( event:MouseEvent ):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, stage_resizeMouseMoveHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_resizeMouseUpHandler );
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
		}
	}
}