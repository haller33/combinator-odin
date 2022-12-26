package tuples

import "core:fmt"

// Values :: union #no_nil {string, int, f32, bool} // for now, compile assertion error problem :: https://github.com/odin-lang/Odin/issues/1918

Poly :: struct {

    data : union { string, int, bool, f32 },
}

Tuple :: struct {
    ret : [dynamic]Poly,
}

main :: proc () {

    {
	a : Tuple
	
	append( &(a.ret), Poly { data = 42 } )
	append( &(a.ret), Poly { data = 93.93 } )
	append( &(a.ret), Poly { data = "Hi 5" } )
	append( &(a.ret), Poly { data = true } )

	fmt.println ( a )
    }
}
