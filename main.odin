package combinator

import "core:os"
import "core:fmt"
import "core:mem"
import "core:strings"
import strc "core:strconv"
import qu "core:container/queue"

DEBUG :: true


Text :: struct {

    line : int,
    str : string,
}

Poly :: struct {

    data : union { string, int, bool, f32, rune },
}

Tuple :: struct($F: typeid, $S : typeid) {

    fst : F,
    snd : S,
}

TupleP :: struct($T: typeid) {

    fst : T,
    rest : []Text,
}

Parser :: struct($a: typeid) {
    input : []Text,
    ret : [dynamic]TupleP(a),
}


Id :: proc ( id : $T ) -> T {

	return id
}

Just :: Id
Right :: Id


Left_Err :: struct { ok : bool, msg : string, line : int, procedure_name : string, value : union {string, int, bool} }

Either :: union($Right: typeid) {Right, Left_Err} // nil be the no correct return

Either_Struct :: struct ( $R : typeid, $L : typeid ) {

	Right : R,
	Left  : L,
}

EitherU :: struct($R: typeid, $L: typeid) {
    
    data: union { L, R },
}

charIn :: proc ( input : string ) -> Either ( Parser ( Poly ) ) {

    return Parser ( Poly ) {}
}


read_entire_file_from_path :: proc (file_path_name : string) -> (string, bool) {

    data_text_digest, ok := os.read_entire_file(file_path_name, context.allocator)
    if !ok {
	// could not read file
	fmt.println("cannot read file")
	return "", false
    }
    // defer delete(data_text_digest, context.allocator)

    return string(data_text_digest), ok
}


string_to_texto_typo :: proc ( file_text : string ) -> []Text {
    
    split_string : []string = strings.split_after ( file_text, "\n" )
    
    // strings_values : []string = split_string[:len(split_string)-1]

    arr_values : [dynamic]Text
    // defer delete ( arr_values )
    // defer delete(arr_values)

    for idx in 0..<len ( split_string ) {

	append ( &arr_values, Text { str = split_string[idx], line = idx } )
    }

    return arr_values[:]
}

text_to_parser :: proc ( text : []Text ) -> Parser ( Poly ) {

    parse_data : Parser ( Poly )

    parse_data.input = text
    
    return parse_data
}

charIs :: proc ( psr : Parser ( Poly ), is_char : rune ) -> Either ( Parser ( Poly ) ) {

    if len ( psr.input ) == 0 {

	return Left_Err { msg = "input empty array", procedure_name = "charIs" }
    }
    
    if rune (psr.input [ 0 ].str[0]) == is_char {
 
	return psr // coorrect
    } else {
	return nil
    }
    
    return psr
}

main :: proc () {

    when !DEBUG {
	a : Parser ( Poly )
	// a : Parser ( int )

	b : Parser ( Text )
	
	append( &(a.ret), TupleP ( Poly ) { fst = Poly { data = 42 }, rest = Text{} } )
	append( &(a.ret), TupleP ( Poly ) { fst = Poly { data = 93.93 }, rest = Text{} } )
	append( &(a.ret), TupleP ( Poly ) { fst = Poly { data = "Hi 5" }, rest = Text{} } )

	fmt.println ( a )
	fmt.println ( b )
    }

    {
	file_string, ok := read_entire_file_from_path ( "test.ini" )
	if !ok {

	}
	defer delete ( file_string )

	/// for future review
	file_text_parser := string_to_texto_typo ( file_string )
	defer delete ( file_text_parser )

	parser := text_to_parser ( file_text_parser )
	
	fmt.println ( parser )
    }
}
