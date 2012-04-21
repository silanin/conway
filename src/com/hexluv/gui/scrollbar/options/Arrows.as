package com.hexluv.gui.scrollbar.options {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import com.hexluv.gui.scrollbar.filters.DropShadowDown;
	import com.hexluv.gui.scrollbar.filters.DropShadowUp;
	import com.hexluv.gui.scrollbar.options.Alpha;
	import com.hexluv.gui.scrollbar.options.Gradient;

	
	public class Arrows extends MovieClip {
		
		public var _upArrow:Sprite;
		public var _downArrow:Sprite;
		
		private var _xPos:Number;
		private var _yPos:Number;
		private var _w:Number;
		private var _h:Number;
		private var _g:Boolean
		private var _c:uint;
		private var _upShape:Shape;
		private var _downShape:Shape;
		private var _dsd:DropShadowDown;
		private var _dsu:DropShadowUp;
		private var _fT:uint;
		private var _bT:uint;
		private var _alpha1:Number;
		
		
		public function Arrows($x:Number, $y:Number, $w:Number, $h:Number, $vars:Object):void {
			
			_xPos = $x;
			_yPos = $y;
			_w = $w;
			_h = $h;
			_g = $vars.gradient
			_fT = $vars.fTint;
			_bT = $vars.bTint;
			_c = $vars.corner;
			_alpha1 = $vars.alpha1;
			
			//Begin
			
			setupArrows();
			
		}
		
		private function setupArrows():void {
			
			//Create sprite containers so that we can apply event listeners to them
			_upArrow = new Sprite();
			_downArrow = new Sprite();
			
			//Setup their coords
				
			_upArrow.x = _xPos;
			_upArrow.y = _yPos;
			_downArrow.x = _xPos;
			_downArrow.y = _yPos + _h - _w;
			
			//Instantiate the top and bottom arrows (Add to container sprites)
				
			_upShape = new Shape();
			_downShape = new Shape();
			_upArrow.addChild(_upShape);
			_downArrow.addChild(_downShape);
			
			//Apply filters
			
			//_dsd = new DropShadowDown(_upArrow);
			//addChild(_dsd);
			//_dsu = new DropShadowUp(_downArrow);
			//addChild(_dsu);
			
			//Begin the fills for the shapes
			
			_upShape.graphics.beginFill(_fT);
			_downShape.graphics.beginFill(_fT);
			
			//Draw the rounded rectangle
			
			_upShape.graphics.drawRoundRect(0, 0, _w, _w, _c);
			_downShape.graphics.drawRoundRect(0, 0, _w, _w, _c);
			
			//Apply alpha if necessary
			
			if (_alpha1 <= 1 && _alpha1 >= 0) {
				var _upAreaTint:Alpha = new Alpha(_upShape, _alpha1);
				var _downAreaTint:Alpha = new Alpha(_downShape, _alpha1);
			}
			
			//Apply gradient if necessary
			
			if (_g) {
				var _uG:Gradient = new Gradient(_upShape, _fT, _c);
				_upArrow.addChild(_uG._gShape);
				var _lG:Gradient = new Gradient(_downShape, _fT, _c);
				_downArrow.addChild(_lG._gShape);
			}
			
			//Add to display list
			
			addChild(_upArrow);
			addChild(_downArrow);
			
			//Treat as buttons
			
			_upArrow.useHandCursor = _downArrow.useHandCursor = true;
			_upArrow.buttonMode = _downArrow.buttonMode = true;
			
		}
		
	}
	
}