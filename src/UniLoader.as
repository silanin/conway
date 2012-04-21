package {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	
	public class UniLoader {
		
		/*
		========================================================
		| Public methods
		========================================================
		*/
		
		/** Load xml */
		
		public static function loadXML( reqXmlUrl:String, completeFun:Function, errorFun:Function = null ){
			
			var loadXml:URLLoader = new URLLoader();
			loadXml.addEventListener( Event.COMPLETE, completeFun );
			errorFun == null ? null : loadXml.addEventListener( IOErrorEvent.IO_ERROR, errorFun );
			loadXml.load( new URLRequest( reqXmlUrl ) );
			
		}
		
		/** Load Image */
		
		public static function loadImage( reqImgUrl:String, completeFun:Function, errorFun:Function = null ){
			
			var imageLoader:Loader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeFun );
			errorFun == null ? null : imageLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, errorFun );
			imageLoader.load( new URLRequest( reqImgUrl ) );
			
		}
		
		

	}

}