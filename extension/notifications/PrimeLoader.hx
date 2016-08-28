package extension.notifications;

#if macro
import haxe.macro.Expr;
#end

// Helper class for setting up bindings using CFFI PRIME
// See https://github.com/HaxeFoundation/hxcpp/blob/master/test/cffi/src/Loader.hx
// See https://github.com/snowkit/hxcpp-guide/issues/1#issue-133283091
class PrimeLoader {
	#if cpp
	public static function __init__() {
		cpp.Lib.pushDllSearchPath("project/ndll/" + cpp.Lib.getBinDirectory());
	}
	#end
	
	public static inline macro function load(inName2:Expr, inSig:Expr) {
		return macro cpp.Prime.load("samcodesnotifications", $inName2, $inSig, false);
	}
}