package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Item extends MovieClip {
		
		private var _isAlive:Boolean = true;
		private var _number:int;
		private var _nCount:int;
		private var color:int;
		 
		public function get isAlive():Boolean{
			return _isAlive;
		}
		
		public function set isAlive( state:Boolean ):void{
			_isAlive = state;
			draw();
		}

		public function Item() {
			flip();
		}
		
		public function flip():void{
			
			_isAlive = !_isAlive;
			draw();
		}
		
		private function draw():void{
			
			color = ( _isAlive ) ? 0x666666 : 0xeeeeee;
			
			graphics.clear();
			graphics.beginFill( color, 1 );
			graphics.drawRect( 0, 0, 12, 12 );
			
		}

	}
	
}
