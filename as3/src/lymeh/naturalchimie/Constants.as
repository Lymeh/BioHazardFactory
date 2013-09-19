package lymeh.naturalchimie
{
	import starling.errors.AbstractClassError;

	public class Constants
	{		
		public function Constants(){throw new AbstractClassError(); }
		
		// We chose this stage size because it is used by many mobile devices; 
		// it's e.g. the resolution of the iPhone (non-retina), which means that your game
		// will be displayed without any black bars on all iPhone models up to 4S.
		// 
		// To use landscape mode, exchange the values of width and height, and 
		// set the "aspectRatio" element in the config XML to "portrait".
		
		public static var STAGE_WIDTH:int  = 320;
		public static var STAGE_HEIGHT:int = 480;
			
	}
}