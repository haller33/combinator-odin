package tuples

import "core:fmt"

// Values :: union #no_nil {string, int, f32, bool} // for now, compile assertion error problem :: https://github.com/odin-lang/Odin/issues/1918

Poly :: struct {

    data : union { string, int, bool, f32 },
}

TupleP :: struct($a: typeid) {

    fst : a,
    rest : string,
}

Tuple :: struct ($a: typeid) {
    input : string,
    ret : [dynamic]TupleP(a),
}

main :: proc () {

    {
	a : Tuple ( Poly )
	
	append( &(a.ret), TupleP (Poly) { fst = Poly { data = 42 }, rest = ""} )
	append( &(a.ret), TupleP (Poly) { fst = Poly { data = 93.93 }, rest = ""} )
	append( &(a.ret), TupleP (Poly) { fst = Poly { data = "Hi 5" }, rest = ""} )
	append( &(a.ret), TupleP (Poly) { fst = Poly { data = true }, rest = ""} )

	n := 
	
	fmt.println ( a )
    }
}
