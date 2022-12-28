
package combinator_test_context

import "core:fmt"
import "core:mem"
import "core:strings"
import qu "core:container/queue"

SHOW_LEAK :: true
TEST_MODE :: true

Poly :: struct {
    data : union { int, f32, string, bool, rune },
}

Slack :: struct {
    
    stack : qu.Queue ( Poly ),
}

multplo_context :: proc ( base_of : int, m := context.user_ptr ) -> proc ( int, rawptr ) -> int {

    qu.push_front ( &(cast (^Slack) m).stack, Poly { data = base_of } )
    
    return proc ( num_test : int, mi := context.user_ptr ) -> int {

	actual_value : Poly = qu.pop_front ( &(cast (^Slack) mi).stack )

	in_return : int = actual_value.data.(int)
	
	return in_return * num_test
    }
}

test :: proc () {

    {
	data : Slack
	qu.init ( &data.stack )
	defer qu.destroy ( &data.stack )
	
	multTwo : proc ( int, rawptr ) -> ( int )

	context.user_ptr = (cast(rawptr) &data)
	
	multTwo = multplo_context ( 2 )

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
