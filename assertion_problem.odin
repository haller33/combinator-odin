package tuples

import "core:fmt"

// Values :: union #no_nil {string, int, f32, bool} // for now, compile assertion error problem :: https://github.com/odin-lang/Odin/issues/1918

Poly :: struct {

    data : union { string, int, bool, f32 },
}

TupleP :: struct($a: typeid) {

    fst : a,
    rest : Text,
}
Text :: struct {

    line : int,
    str : string,
}

Tuple :: struct ($a: typeid) {
    input : Text,
    ret : [dynamic]TupleP(a),
}

main :: proc () {

    {
	a : Tuple ( Poly )
	
	append( &(a.ret), TupleP (Poly) { fst = Poly { data = 42 }, rest = Text{}} )
	append( &(a.ret), TupleP (Poly) { fst = Poly { data = 93.93 }, rest = Text{}} )
	append( &(a.ret), TupleP (Poly) { fst = Poly { data = "Hi 5" }, rest = Text{}} )
	append( &(a.ret), TupleP (Poly) { fst = Poly { data = true }, rest = Text{}} )

	n := 
	
	fmt.println ( a )
    }
}
