package com.hexluv.gui.scrollbar.filters {
	
	import flash.display.*;
	import flash.filters.DropShadowFilter;
	
	public class DropShadowDown1 extends Sprite {
		
		private var _dsDown:DropShadowFilter;
		
		public function DropShadowDown1($s:Sprite):void {
			
			//Drop shadow properties
			
			_dsDown = new DropShadowFilter();
			_dsDown.distance = 1;
			_dsDown.angle = 90;
			_dsDown.blurY = 1;
			_dsDown.alpha = .2;
			
			//Apply filter
			$s.filters = [_dsDown];
			
			
		}
		
	}
	
}