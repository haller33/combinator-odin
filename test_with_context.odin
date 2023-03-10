
package combinator_test_context

import "core:fmt"
import "core:mem"
import "core:strings"
import qu "core:container/queue"

SHOW_LEAK :: false
TEST_MODE :: false
STRESS_TEST :: true

Any :: union { int, f32, string, bool, rune }

Poly :: struct {
    value : Any,
}

Slack :: struct {
    
    stack : qu.Queue ( Poly ),
}

push_raw :: proc ( m : rawptr, value : Poly ) {

    push ( cast (^Slack) m, value )
}

push :: proc ( m : ^Slack, value : Poly ) {

    qu.push_front ( &m.stack, value )
}

pop_raw :: proc ( m : rawptr ) -> Poly {

    return pop ( cast (^Slack) m )
}

pop :: proc ( m : ^Slack ) -> Poly {
    
    return qu.pop_front ( &m.stack )
}

pop_poly :: proc ( m : rawptr ) -> Any {

    ret := pop_raw ( m )
    
    return ret.value
}

front_slack :: proc ( m : ^Slack ) -> Poly {
    
    return qu.front ( &m.stack )
}

front_raw :: proc ( m : rawptr ) -> Poly {

    return front_slack ( cast (^Slack) m )
}

front_poly :: proc ( m : rawptr ) -> Any {

    ret := front_raw ( m )
    
    return ret.value
}

front :: proc () -> Any {
    
    mi := context.user_ptr
    return front_poly ( mi )
}

v :: proc ( a : Any ) -> Poly {

    return Poly { value = a }
}

multplo_context :: proc ( base_of : int, m := context.user_ptr ) -> proc ( int ) -> int {

    push_raw ( m, v ( base_of ) )
    
    return proc ( num_test : int ) -> int { // inplicit context on this case, can have problems.

	actual_value := front ( )

	in_return : int = actual_value.(int)
	
	return in_return * num_test
    }
}

/*
begin_container :: proc ( ) -> (^Slack, ^qu.Queue(Poly)) {

    data := new(Slack)
    qu.init ( &data^.stack )
    // defer qu.destroy ( &data.stack )

    return data, &((data^).stack)
}
*/

procedural_mult :: proc ( num : int, base : int ) -> int {

    return num * base
}

MAX_LIMIT :: 100000000

test :: proc () {
    
    /// with this approuch (abstract stack) i have a slow down of about 89% of a call of this same function,
    /// procedural. NOICE.
    /// with atual MAX_LIMIT = 100000000, we have (705 milliseconds) / (6.71 seconds) = 0.105067064 // on a i7-8650U CPU
    /// (1-0.105) * 100 == 89.4% of slow down.
    
    {
	// startup
	data : Slack
	qu.init ( &data.stack )
	context.user_ptr = &data
	defer qu.destroy ( &data.stack )

	// actual handle of data
	multTwo := multplo_context ( 2 )
	
	tmp := multTwo ( 11 )

	tmp2 : int
	when STRESS_TEST { 
	    for i in 0..<(MAX_LIMIT + 1) {
		tmp2 = multTwo ( i )

		// fmt.print ( tmp2, " " )
	    }
	}
	
	// fmt.println ( tmp )
	fmt.println ( tmp2 )
	
    }
}

test_proc :: proc () {

    {
	
	tmp2 : int
	when STRESS_TEST {
	    
	    for i in 0..<(MAX_LIMIT + 1) {
	
		tmp2 = procedural_mult ( 2, i )
	
	    }
	}
	
	fmt.println ( tmp2 )
    }
}


main :: proc () {

    when SHOW_LEAK {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)
    }
    
    when TEST_MODE {
	test ( )
    } else {
	test_proc ()
    }

    when SHOW_LEAK {
	for _, leak in track.allocation_map {
	    fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
	    fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
    }
    return
}
