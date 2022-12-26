package combinator_chainber

import "core:io"
import "core:fmt"
import "core:mem"
import "core:strings"
import strc "core:strconv"
import qu "core:container/queue"

DEBUG :: true
Monadic_Context :: struct($T: typeid) {
	
	last : [dynamic]T,
	m : qu.Queue(T),
}

// M :: union ($T : typeid) { [dynamic]T }

/*
Monad :: proc ( $Monad : typeid ) -> proc ( a, m : Monad ) {

	return
}
*/

ContainerM :: struct ( $INPUT: typeid, $RET: typeid ) {

    input : INPUT,
    swap  : INPUT,
    chain : RET,
    ret   : RET,
    fun   : rawptr,
}

// Values :: union #no_nil {string, int, f32} // not working 

Poly :: struct {

    data : union { string, int, bool, f32 },
}

Tuple :: struct($F: typeid, $S : typeid) {

    fst : F,
    snd : S,
}

TupleU :: struct($T: typeid) {

    fst : T,
    snd : T,
}

TupleP :: struct($T: typeid) {

    fst : T,
    rest : string,
}

Parser :: struct($a: typeid) {
    input : string,
    ret : [dynamic]TupleP(a),
}


Id :: proc ( id : $T ) -> T {

	return id
}

Just :: Id
Right :: Id


lazy :: proc ( a : int ) -> (int, proc ( int ) -> int) {
	
	return a, proc ( mci : int ) -> int {

		return mci
	}
}
/*
// compose ( m, n, n2 )
compose :: proc ( m : int, n : proc ( int ) -> int, n2 : proc ( int ) -> int ) {

	m2 := n ( m )
	return  proc ( )  n2 ( m2 )
} */



Left_Err :: struct { ok : bool, msg : string, line : int, procedure_name : string, value : union {string, int, bool} }

// Either :: union($Right: typeid) #no_nil {Right, Left_Err}

Either :: union($Right: typeid) {Right, Left_Err} // nil be the no correct return

Either_Struct :: struct ( $R : typeid, $L : typeid ) {

	Right : R,
	Left  : L,
}

EitherU :: struct($R: typeid, $L: typeid) {
    data: union { L, R },
}


// safe division
dive :: proc ( num : int, base : int ) -> Either ( int ) {

    if base == 0 do return Left_Err {
		msg = "some division problem" }
	// if num == 42 do return Left_Err { msg = "some error using the answer of everything" }
    return Right ( num / base )
}

/*

sat :: proc ( mc : Monadic_Context, fun : proc ( rune ) -> bool ) -> Either ( bool ) { // -> Parser ( rune ) {

	return proc ( mc : Monadic_Context, on_input : string ) {
		if fun ( mc, on_input ) {
			return true
		} return false
	}
}

*/

main_test :: proc () {

    when !DEBUG {
	n := EitherU ( int, string ) { data = 42 }
	
	a : Either ( Parser ( string ) )

	a = nil

	a = Parser ( string ) { input = "hello world" }

	fmt.println ( a )
	// fmt.println ( b )
	
	fmt.println ( dive ( 1, 1 ) )
	fmt.println ( dive ( 1, 0 ) )
	fmt.println ( dive ( 42, 1 ) )
	
    }
    
    when !DEBUG {
	fmt.println ( "tuple" )
	a : TupleP ( int ) 

	fmt.println ( a )

    }
    {
	a : Parser ( Poly )
	// a : Parser ( int )

	b : Parser ( string )
	
	// append( &(a.ret), TupleP ( int ) { fst = 1, rest = ""} )
	// append( &(a.ret), TupleP ( int ) { fst = 3445, rest = ""} )
	append( &(a.ret), TupleP ( Poly ) { fst = Poly { data = 42 }, rest = ""} )
	append( &(a.ret), TupleP ( Poly ) { fst = Poly { data = 93.93 }, rest = ""} )
	append( &(a.ret), TupleP ( Poly ) { fst = Poly { data = "Hi 5" }, rest = ""} )
	

	fmt.println ( a )
	fmt.println ( b )
    }
    return
}

/*
curry_sum :: proc ( m : ^ContainerM ( int, int ), one : int ) -> (proc ( ^Container ( int, int ) ) -> ( proc ( ^ContainerM ( int, int ) ) -> int ) ) {

    lazyM ( m^, one )
    return proc ( m2 : ^ContainerM ( int, int ), two : int ) -> proc ( ^ContainerM ( int, int ) -> int {

	lazyM ( m2^, two, SWAP )
	return proc ( m3 : ^ContainerM ) -> int {
	    return (m3^).chain + (m3^).swap
	}
    }
}
*/
MODES :: enum {

    CHAIN,
    PASS,
    TWO_SWAP_PASS,
    SWAP,
}

lazyM :: proc ( m : ^ContainerM (int, int), a : int, mode : MODES = MODES.CHAIN ) -> proc ( ^ContainerM (int, int) ) -> int {

    if  mode == MODES.SWAP {
	(m^).swap = a
	fn :: proc ( mi : ^ContainerM (int, int) ) -> int {
	    (mi^).ret = (mi^).swap
	    return (mi^).ret
	}
	(m^).fun = cast(rawptr) fn
	return fn
    }
    // if mode == MODES.CHAIN || true {
    	(m^).chain = a
	return proc ( mi : ^ContainerM (int, int) ) -> int {
	    (mi^).ret = (mi^).chain
	    return (mi^).ret
	}
    // } 
}

main_lazy_stuff :: proc () {

    {

	m, n := lazy ( 42 )
	m2, n2 := lazy ( 44 )

	// fmt.println ( compose ( m, n, n2 ) )
    }

    when !DEBUG {
	main_test()
    }

    {
	m : ContainerM ( int, int )
	fun := lazyM ( &m, 5 )

	n := 42
	fmt.println ( fun ( &m ) )
    }
}
