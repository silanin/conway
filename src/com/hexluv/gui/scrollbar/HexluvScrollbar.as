/*
VERSION: 2.1
DATE: 4/25/2009
ACTIONSCRIPT VERSION: 3.0 
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.hexluv.com
DESCRIPTION:
		A lightweight, no-nonsense scrollbar for a textField. This class does not require the importing of any
		graphical elements and gives you several customization options. The minimalist look fits nicely into 
		almost any project. It's simple and easy to use.
		
ARGUEMENTS: 
	1) Display Object 	- $do - 				can be a movieclip, sprite, textfield, etc. (Required)
	2) Width       		- $wide -  				this is the desired width of the scroll bar (Required)
	3) Height 			- $height - 			the height of the mask. I.e. the only part that will be visible (Required)
	4) Arrows 			- $arrows:Boolean - 	determines whether your scroll bar shows arrows at the top and bottom (Required)
	5) Stage 			- $stage - 				gives the subsequent classes access to the stage (Required)
	6) Vars - All the customizable attributes such as:
		- alpha1 : the alpha of the foreground elements (arrows scroll button)
		- alpha2 : the alpha of the scroll bar background
		- fTint : the tint of the arrows and scroll button
		- bTint : the tint of the scrollbar background
		- corner : the radius of the corners
		- gradient : boolean 
		
EXAMPLE USAGE:
import com.hexluv.gui.scrollbar.HexluvScrollbar;

var _scrollBar = new HexluvScrollbar(_yourDisplayObject, 15, 300, arrows:boolean, stage, {gradient:true, alpha1:1, alpha2:.5, fTint:0xCC0000, bTint:0x000000, corner:10});
addChild(_scrollBar);

*/


package com.hexluv.gui.scrollbar {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.Timer;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import com.hexluv.gui.scrollbar.filters.DropShadowDown;
	import com.hexluv.gui.scrollbar.options.*;
	
	public class HexluvScrollbar extends MovieClip {
		
		private static var _xPos:Number;
		private static var _yPos:Number;
		private static var _scrubberArea:Shape;
		private static var _scrubber:Sprite;
		private static var _scrubberShape:Shape;
		private static var _scrubberHeight:Number;
		private static var _dsd:DropShadowDown;
		private static var _startingY:Number;
		private static var _do:DisplayObject;
		private static var _w:Number;
		private static var _h:Number;
		private static var _arrows:Boolean;
		private static var _vars:Object;
		private static var _setupArrows:Arrows;
		private static var _maskee:MovieClip;
		private static var _mask:Sprite;
		private static var _maskShape:Shape;
		private static var _stage:Stage;
		private static var _dTimer:Timer;
		private static var _yOffset:Number;
		private static var _yMin:Number;
		private static var _yMax:Number;
		private var vars:Object;
		private var sp:Number = 0;
		
		
		public function HexluvScrollbar($do:DisplayObject, $wide:Number, $height:Number, $arrows:Boolean, $stage:Stage, $vars:Object) {
			
			if ($height > $do.height) {
				//Gracefully exit, because the user has defined a mask height that is greater than the content
			} else {
			
				//Set variables for later use
				_do = $do;
				_w = $wide;
				_h = $height;
				_arrows = $arrows;
				_stage = $stage;
				_vars = $vars;
				
				//Apply vars - alpha, color, gradient
				this.vars = $vars;
							
				//Determine the coords of the scrollbar
				_xPos = _do.x + _do.width + ($wide >> 1) + 5;
				_yPos = _do.y;
				
				//Set corners to 0, if the user doesn't specify
				if (_vars.corner == null) {
					_vars.corner = 0;
				}
				
				//Draw the scrollbar background and apply customization
				drawBG();
				
				//Determine whether the user wants up and down arrows
				if (_arrows) {
					
					_setupArrows = new Arrows(_xPos, _yPos, _w, _h, _vars);
					addChild(_setupArrows);
					
					//Apply listeners
					_setupArrows._upArrow.addEventListener(MouseEvent.MOUSE_DOWN, onUpPress, false, 0, true);
					_setupArrows._downArrow.addEventListener(MouseEvent.MOUSE_DOWN, onDownPress, false, 0, true);
					
				}
				
				//Setup mask
				maskProcess();
				
				//Setup scrubber
				drawScrubber();
			}
				
		}
		
	//-------------------------------------------------------------------------------------------
	//			Places display object into container and applies mask
	//-------------------------------------------------------------------------------------------
	
	private function maskProcess():void {
		
		//place the desired display object inside a movielip (maskee)
		_maskee = new MovieClip();
		_maskee.addChild(_do);
		addChild(_maskee);
		_maskee.addEventListener(Event.ENTER_FRAME, checkY);
		
		//Draw out the mask
		_maskShape = new Shape();
		_maskShape.graphics.beginFill(0xCC0000);
		_maskShape.graphics.drawRect(_do.x, _do.y, _do.width, _h);
		_maskShape.graphics.endFill();
		_mask = new Sprite();
		_mask.addChild(_maskShape);
		this.addChild(_mask);
		_maskee.mask = _mask;
				
		_mask.cacheAsBitmap = true;
	}
	
	private function checkY(e:Event):void {
		_maskShape.graphics.moveTo(_do.x, _do.y);
		//_mask.graphics.drawRect(_do.x, _do.y, _do.width, _h);
	}
	
	//-------------------------------------------------------------------------------------------
	//			Draws out and places the scrubber
	//-------------------------------------------------------------------------------------------
	
	private function drawScrubber():void {
		
		//Instantiate scrubber
		_scrubber = new Sprite();
		
		//Set coords and determine height
		if (_arrows) {
			_scrubber.x = _xPos;
			_scrubber.y = _yMin = _yPos + 22; //Set the scroll tab under the top arrow
			_startingY = _scrubber.y;
			_scrubberHeight = (_h - 44) * (_maskShape.height/_maskee.height);
			_yMax = ((_h - _scrubberHeight) - 44) + _scrubber.y;
		} else {
			_scrubber.x = _xPos;
			_scrubber.y = _yMin = _yPos;
			_startingY = _scrubber.y;
			_scrubberHeight = _h * (_maskShape.height/_maskee.height);
			_yMax = (_h - _scrubberHeight) + _startingY;
		}
		
		//Instantiate the scrubber shape (Add to container sprites)
		_scrubberShape = new Shape();
		_scrubber.addChild(_scrubberShape);
		//_dsd = new DropShadowDown(_scrubber);
		//addChild(_dsd);
		
		//Begin the fills for the shapes
		_scrubberShape.graphics.beginFill(_vars.fTint);
		_scrubberShape.graphics.drawRoundRect(0, 0, _w, _scrubberHeight, _vars.corner);
		
		//Apply gradient if necessary
		if (_vars.gradient) {
			var _sG:Gradient = new Gradient(_scrubberShape, _vars.fTint, _vars.corner);
			_scrubber.addChild(_sG._gShape);
		}
		
		//Apply alpha if necessary
		if (_vars.alpha1 != null) {
			var _scrubberShapeAlpha:Alpha = new Alpha(_scrubberShape, _vars.alpha1);
		}
		
		//Add to display list
		addChild(_scrubber);
		
		//Add the event listeners for the drag
		_scrubber.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
		_stage.addEventListener(MouseEvent.MOUSE_UP, thumbUp);
		
		//Treat as a button
		_scrubber.useHandCursor = true;
		_scrubber.buttonMode = true;
		
	}
		
		
	//-------------------------------------------------------------------------------------------
	//			Draws out the background for the scroll bar and runs appropriate functions
	//-------------------------------------------------------------------------------------------
	
	private function drawBG():void {
		
		//Instantiate the shape for the background of the scrollbar
		_scrubberArea = new Shape();
		
		//Either apply the correct tint or the default black. Also run an alpha check.
		if (_vars.bTint != null) {
			_scrubberArea.graphics.beginFill(_vars.bTint); // Sets the color of the scroll bar background
		} else {
			_scrubberArea.graphics.beginFill(0x000000); // The Default is black if not user specified
		}
		
		//Draw the darn thing out
		_scrubberArea.graphics.drawRoundRect(_xPos, _yPos, _w, _h, _vars.corner);
		
		//Add to display list
		addChild(_scrubberArea);
		
		//Apply alpha if necessary
		if (_vars.alpha2 != null) {
			var _scrubberAreaTint:Alpha = new Alpha(_scrubberArea, _vars.alpha2);
		}
		
	}
	
	
	//-------------------------------------------------------------------------------------------
	//		Event Listerns for the scrubber
	//-------------------------------------------------------------------------------------------
		
	//Commands for when the scrollbar is clicked
	private function startMove(evt:MouseEvent):void {
		_stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbMove);
		_yOffset = mouseY - evt.target.y;
	}
	
	//Comands for when the scrollbar is released
	private function thumbUp(evt:MouseEvent):void {
		_stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbMove);
	}
	
	//scrolls the text
	private function thumbMove(evt:MouseEvent):void {
		
		_scrubber.y = mouseY - _yOffset;
		
		if(_scrubber.y <= _yMin)
			_scrubber.y = _yMin;
		
		if(_scrubber.y >= _yMax)
			_scrubber.y = _yMax;
		
		sp = (_scrubber.y - _startingY) / (_yMax - _startingY);
		
		if (_arrows) {
			TweenLite.to(_maskee, 1, {y:int(-sp * (_maskee.height - _maskShape.height)), ease:Expo.easeOut});
		} else {
			TweenLite.to(_maskee, 1, {y:int(-sp * (_maskee.height - _maskShape.height)), ease:Expo.easeOut});
		}
		
		evt.updateAfterEvent();
		
	}
	
	//-------------------------------------------------------------------------------------------
	//		Event Listerns for the arrows
	//-------------------------------------------------------------------------------------------
	
	private function onDownPress(evt:MouseEvent):void {
		
		
		if (sp > .995) {
			
			//Do nothing because we are all done going down
			
		} else {
			
			//Scroll the text
			sp = sp + .05;
			TweenLite.to(_maskee, 1, {y:-sp * (_maskee.height - _maskShape.height), ease:Expo.easeOut});
			
			//Move the bar up
			TweenLite.to(_scrubber, .5, {y:(sp * (_yMax - _startingY)) + _startingY, ease:Expo.easeOut});
		}
		
		//Need to run a timer to move everything while the button is being held down.
		_dTimer = new Timer(80);
		_dTimer.addEventListener(TimerEvent.TIMER, onDTimer);
		_dTimer.start();
		_setupArrows._downArrow.addEventListener(MouseEvent.MOUSE_UP, stopDownScroll);
		_setupArrows._downArrow.addEventListener(MouseEvent.MOUSE_OUT, stopDownScroll);
		
		
	
	}
	
	
	
	
	private function onUpPress(evt:MouseEvent):void {
		
		if (sp < .05) {
			
			//We don't do anything here because there is no more text to scroll
			
		} else {
			
			//Scroll the text			
			sp = sp - .05;
			TweenLite.to(_maskee, 1, {y:-sp * (_maskee.height - _maskShape.height), ease:Expo.easeOut});
			
			//Move the bar up
			if (_scrubber.y > (_startingY + 1)) {
				TweenLite.to(_scrubber, .5, {y:int((sp * (_yMax - _startingY)) + _startingY), ease:Expo.easeOut});
			}
		}
		
		//Need to run a timer to move everything while the button is being held down.
		_dTimer = new Timer(60);
		_dTimer.addEventListener(TimerEvent.TIMER, onUTimer);
		_dTimer.start();
		_setupArrows._upArrow.addEventListener(MouseEvent.MOUSE_UP, stopUpScroll);
		_setupArrows._upArrow.addEventListener(MouseEvent.MOUSE_OUT, stopUpScroll);
		
	}
	
	private function onDTimer(evt:TimerEvent):void {
		
		if (sp > .995) {
			
			//Do nothing because we are all done going down
			
		} else {
			
			//Scroll the text
			sp = sp + .05;
			TweenLite.to(_maskee, 1, {y:int(-sp * (_maskee.height - _maskShape.height)), ease:Expo.easeOut});
			
			//Move the bar up
			TweenLite.to(_scrubber, .5, {y:int((sp * (_yMax - _startingY)) + _startingY), ease:Expo.easeOut});
		}
		
	}
	
	private function onUTimer(evt:TimerEvent):void {
		
		if (sp < .005) {
			
			//We don't do anything here because there is no more text to scroll 
			
		} else {
			
			//Scroll the text
			sp = sp - .05;
			TweenLite.to(_maskee, 1, {y:-sp * (_maskee.height - _maskShape.height), ease:Expo.easeOut});
			
			//Move the bar up
			if (_scrubber.y > (_startingY + 3)) {
				TweenLite.to(_scrubber, .5, {y:(sp * (_yMax - _startingY)) + _startingY, ease:Expo.easeOut});
			}
		}
	}
	
	private function stopDownScroll(evt:MouseEvent):void {
		_dTimer.removeEventListener(TimerEvent.TIMER, onDTimer);
		_setupArrows._downArrow.removeEventListener(MouseEvent.MOUSE_UP, stopDownScroll);
	}
	
	private function stopUpScroll(evt:MouseEvent):void {
		_dTimer.removeEventListener(TimerEvent.TIMER, onUTimer);
		_setupArrows._upArrow.removeEventListener(MouseEvent.MOUSE_UP, stopUpScroll);
	}
		
	}
}