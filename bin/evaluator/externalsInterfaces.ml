open Common.TypesCommon

let e_print_string = {m_body = Either.Left None; m_proto={pos= Lexing.dummy_pos;name="print_string"; generics=[];params=[("x", (false,String))];rtype=None; variadic=false}}
let e_print_int = {m_body = Either.Left None; m_proto={pos= Lexing.dummy_pos;name="print_int"; generics=[];params=[("x", (false,Int))];rtype=None; variadic=false}}

let e_print_new_line = {m_body = Either.Left None; m_proto={pos= Lexing.dummy_pos;name="print_newline"; generics=[];params=[];rtype=None; variadic=false}}

let drop = {m_body = Either.Left None; m_proto={pos= Lexing.dummy_pos;name="drop"; generics=["A"]; params=[("x",(false,Box (GenericType "A")))];rtype=None; variadic=false}}
let exSig = {
  name = "_External"; 
  structs = [];
  enums =[];
  methods = [e_print_string ; e_print_new_line; e_print_new_line];
  processes = [];
}