
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

multplo_context :: proc ( base_of : int, m := context.user_ptr ) -> proc ( int, rawptr ) -> int {

    push_raw ( m, Poly { data = base_of } )
    
    return proc ( num_test : int, mi := context.user_ptr ) -> int {
	
	actual_value := pop_poly ( mi )

	in_return : int = actual_value.(int)
	
	return in_return * num_test
    }
}

test :: proc () {

    {
	// startup
	data : Slack
	qu.init ( &data.stack )
	defer qu.destroy ( &data.stack )
	
	context.user_ptr = (cast(rawptr) &data)

	// actual handle of data
	multTwo := multplo_context ( 2 )

	tmp := multTwo ( 10, context.user_ptr )

	fmt.println ( tmp )
	
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
