
package combinator_test_context

import "core:fmt"
import "core:mem"
import "core:strings"
import qu "core:container/queue"

SHOW_LEAK :: true
TEST_MODE :: true

Any :: union { int, f32, string, bool, rune }

Poly :: struct {
    data : Any,
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
    
    return ret.data
}

front :: proc ( m : ^Slack ) -> Poly {
    
    return qu.front ( &m.stack )
}

front_raw :: proc ( m : rawptr ) -> Poly {

    return front ( cast (^Slack) m )
}

front_poly :: proc ( m : rawptr ) -> Any {

    ret := front_raw ( m )
    
    return ret.data
}



multplo_context :: proc ( base_of : int, m := context.user_ptr ) -> proc ( int ) -> int {

    push_raw ( m, Poly { data = base_of } )
    
    return proc ( num_test : int ) -> int { // inplicit context on this case, can have problems.

	mi := context.user_ptr
	
	actual_value := front_poly ( mi )

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

test :: proc () {

    {
	
	// startup
	
	data : Slack
	qu.init ( &data.stack )
	context.user_ptr = &data
	defer qu.destroy ( &data.stack )

	// actual handle of data
	multTwo := multplo_context ( 3 )
	
	tmp := multTwo ( 11 )
	
	tmp2 := multTwo ( 22 )

	fmt.println ( tmp )
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
