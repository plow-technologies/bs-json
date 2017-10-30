(** Provides a set of low level combinator primitives to decode Js.Json.t data
structures
A decoder combinator will return the decoded value if successful, or raise a 
[DecodeError of string] if unsuccessful, where the string argument contains the
error message.
Decoders are designed to be combined to produce more complex decoders that can
decode arbitrary data structures, though the emphasis for this library is for
it to be {i possible} to decode any given data structure, not necessarily for
it to be {i convenient}. For convenience you should look towards opinionated
third-party libraries.
*)

type 'a decoder = Js.Json.t -> 'a
(** The type of a decoder combinator *)

type 'a safeDecoder = Js.Json.t -> ('a, string) Js_result.t
(** The type of a safe decoder combinator **)

exception DecodeError of string

val boolean : Js.boolean decoder
(** Decodes a JSON value into a [Js.boolean]
    
{b Returns} a [Js.boolean] if the JSON value is a number.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns Js.true_ *)
  let _ = Js.Json.parseExn "true" |> Decode.boolean
  (* returns Js.false_ *)
  let _ = Js.Json.parseExn "false" |> Decode.boolean
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "123" |> Decode.boolean
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "null" |> Decode.boolean
]}
*)

val bool : bool decoder
(** Decodes a JSON value into a [bool]
    
{b Returns} a [bool] if the JSON value is a number.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns true *)
  let _ = Js.Json.parseExn "true" |> Decode.bool
  (* returns false *)
  let _ = Js.Json.parseExn "false" |> Decode.bool
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "123" |> Decode.bool
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "null" |> Decode.bool
]}
*)

val float : float decoder
(** Decodes a JSON value into a [float]
    
{b Returns} a [float] if the JSON value is a number.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns 1.23 *)
  let _ = Js.Json.parseExn "1.23" |> Decode.float
  (* returns 23. *)
  let _ = Js.Json.parseExn "23" |> Decode.float
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "true" |> Decode.float
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "null" |> Decode.float
]}
*)

val int : int decoder
(** Decodes a JSON value into an [int]
    
{b Returns} an [int] if the JSON value is a number.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns 23 *)
  let _ = Js.Json.parseExn "23" |> Decode.int
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "1.23" |> Decode.int
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "true" |> Decode.int
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "null" |> Decode.int
]}
*)

val string : string decoder
(** Decodes a JSON value into a [string]
    
{b Returns} a [string] if the JSON value is a number.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns "foo" *)
  let _ = Js.Json.parseExn "\"foo\"" |> Decode.string
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "1.23" |> Decode.string
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "null" |> Decode.string
]}
*)

val date : Js_date.t decoder

  
val nullable : 'a decoder -> 'a Js.null decoder
(** Decodes a JSON value into an ['a Js.null]
    
{b Returns} [Js.null] if the JSON value is [null], or an ['a Js.null] if the
given decoder succeeds,

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns (Js.Null.return 23) *)
  let _ = Js.Json.parseExn "23" |> Decode.(nullable int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "1.23" |> Decode.(nullable int)
  (* returns Js.null *)
  let _ = Js.Json.parseExn "null" |> Decode.(nullable int)
]}
*)

val nullAs : 'a -> 'a decoder
(** Returns the given value if the JSON value is [null]
    
{b Returns} an ['a] if the JSON value is [null].

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "\"x\"" |> Decode.nullAs "x"
  (* returns "x" *)
  let _ = Js.Json.parseExn "null" |> Decode.nullAs "x"
  (* returns None *)
  let _ = Js.Json.parseExn "null" |> Decode.nullAs None
]}
*)

val array : 'a decoder -> 'a array decoder
(** Decodes a JSON array into an ['a array] using the given decoder on each element
    
{b Returns} an ['a array] if the JSON value is a JSON array and all its
elements are successfully decoded.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns [| 1; 2; 3 |] *)
  let _ = Js.Json.parseExn "[1, 2, 3]" |> Decode.(array int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "[1, 2, "c"]" |> Decode.(array int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "123" |> Decode.(array int)
  (* returns None *)
  let _ = Js.Json.parseExn "null" |> Decode.(array int)
]}
*)

val list : 'a decoder -> 'a list decoder
(** Decodes a JSON array into an ['a list] using the given decoder on each element
    
{b Returns} an ['a list] if the JSON value is a JSON array and all its
elements are successfully decoded.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns [1; 2; 3] *)
  let _ = Js.Json.parseExn "[1, 2, 3]" |> Decode.(list int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "[1, 2, "c"]" |> Decode.(list int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "123" |> Decode.(list int)
  (* returns None *)
  let _ = Js.Json.parseExn "null" |> Decode.(list int)
]}
*)

val pair : 'a decoder -> 'b decoder -> ('a * 'b) decoder
(** Decodes a JSON array with two elements into an ['a * 'b] tuple using the
    first decoder on the left element and the second decoder on the right

{b Returns} an ['a * 'b] if the JSON value is a JSON array of length 2 and both
    its elements are successfully decoded.

@raise [DecodeError] if unsuccessful

@example {[
  open Json
  (* returns (1, "bar") *)
  let _ = Js.Json.parseExn "[1, \"bar\"]" |> Decode.(pair int string)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "[1, 2]" |> Decode.(pair int string)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "[1, 2, 3]" |> Decode.(pair int int)
]}
*)

val tuple2 : 'a decoder -> 'b decoder -> ('a * 'b) decoder

val tuple3 : 'a decoder -> 'b decoder -> 'c decoder -> ('a * 'b * 'c) decoder

val tuple4 : 'a decoder -> 'b decoder -> 'c decoder -> 'd decoder -> ('a * 'b * 'c * 'd) decoder

val tuple5 : 'a decoder -> 'b decoder -> 'c decoder -> 'd decoder -> 'e decoder -> ('a * 'b * 'c * 'd * 'e) decoder

val tuple6 : 'a decoder -> 'b decoder -> 'c decoder -> 'd decoder -> 'e decoder -> 'f decoder -> ('a * 'b * 'c * 'd * 'e * 'f) decoder

val dict : 'a decoder -> 'a Js.Dict.t decoder
(** Decodes a JSON object into a dict using the given decoder on each of its values
    
{b Returns} an ['a Js.Dict.t] if the JSON value is a JSON object and all its
values are successfully decoded.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns (Js.Dict.fromList [("x", 23); ("y", 42)]) *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": 42 } |} |> Decode.(dict int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(dict int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "123" |> Decode.(dict int)
  (* returns None *)
  let _ = Js.Json.parseExn "null" |> Decode.(dict int)
]}
*)

val field : string -> 'a decoder -> 'a decoder
(** Decodes a JSON object with a specific field into the value of that field
    
{b Returns} an ['a] if the JSON value is a JSON object with the given field
and a value that is successfully decoded with the given decoder.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns 23 *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": 42 } |} |> Decode.(field "x" int)
  (* returns 23 *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(field "x" int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(field "y" int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "123" |> Decode.(field "x" int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "null" |> Decode.(field "x" int)
]}
*)

val at : string list -> 'a decoder -> 'a decoder
(** Same as [field] but takes a top level field and a list of nested fields for decoding nested values.
    
{b Returns} an ['a] if the JSON value is a JSON object with the given field
and a value that is successfully decoded with the given decoder.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns 23 *)
  let _ = Js.Json.parseExn {| { "x": {"foo": 23}, "y": 42 } |} |> Decode.(at ["x"; "foo"] int)
  (* raises DecodeError *)
  let _ = Js.Json.parseExn {| { "x": null, "y": "b" } |} |> Decode.(at ["x"; "foo"] int)
]}
*)

val optional : 'a decoder -> 'a option decoder
(** Maps a decoder [result] to an option
    
{b Returns} [Some of 'a] if the given decoder is successful, [None] if
it is not.

This decoder will never raise a [DecodeError]. Its purpose is to catch and
transform [DecodeError]'s of a given decoder into [None]s by mapping its
[result] into an [option]. This prevents a decoder error from terminating
a composite decoder, and is useful to decode optional JSON object fields.

@example {[
  open Json
  (* returns (Some 23) *)
  let _ = Js.Json.parseExn "23" |> Decode.(optional int)
  (* returns None *)
  let _ = Js.Json.parseExn 1.23 |> Decode.(optional int)
  (* returns None *)
  let _ = Js.Json.parseExn "null" |> Decode.(optional int)
  (* returns (Some 23) *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(optional (field "x" int))
  (* returns None *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(optional (field "y" int))
  (* returns None *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(optional (field "z" int))
  (* returns (Some 23) *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(field "x" (optional int))
  (* returns None *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(field "y" (optional int))
  (* raises DecodeError *)
  let _ = Js.Json.parseExn {| { "x": 23, "y": "b" } |} |> Decode.(field "z" (optional int))
]}
*)

val oneOf : 'a decoder list -> 'a decoder
(** Tries each [decoder] in order, retunring the result of the first that succeeds

{b Returns} an ['a] if one of the decoders succeed.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns 23 *)
  let _ = Js.Json.parseExn "23" |> Decode.(oneOf [int; field "x" int])
  (* returns 42 *)
  let _ = Js.Json.parseExn {| { "x": 42 } |}  |> Decode.(oneOf [int; field "x" int])
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "null" |> Decode.(oneOf [int; field "x" int]
]}
*)

val either : 'a decoder -> 'a decoder -> 'a decoder
(** Tries each [decoder] in order, retunring the result of the first that succeeds

{b Returns} an ['a] if one of the decoders succeed.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns 23 *)
  let _ = Js.Json.parseExn "23" |> Decode.(either int (field "x" int))
  (* returns 42 *)
  let _ = Js.Json.parseExn {| { "x": 42 } |}  |> Decode.(either int (field "x" int))
  (* raises DecodeError *)
  let _ = Js.Json.parseExn "null" |> Decode.(either int (field "x" int))
]}
*)

val withDefault : 'a -> 'a decoder -> 'a decoder
(** Tries each [decoder] in order, retunring the result of the first that succeeds

{b Returns} an ['a] if one of the decoders succeed.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns 23 *)
  let _ = Js.Json.parseExn "23" |> Decode.withDefault 0 int
  (* returns 0 *)
  let _ = Js.Json.parseExn "\"x\"" |> Decode.withDefault 0 int
  (* returns 0 *)
  let _ = Js.Json.parseExn "null" |> Decode.withDefault 0 int
]}
*)

val map : ('a -> 'b) -> 'a decoder -> 'b decoder
(** Returns a decoder that maps the result of the given decoder if successful

{b Returns} a ['b] if the given decoder succeeds.

@raise [DecodeError] if unsuccessful 

@example {[
  open Json
  (* returns 46 *)
  let _ = Js.Json.parseExn "23" |> Decode.map (fun x -> x * x) int
]}
*)

val andThen : ('a -> 'b decoder) -> 'a decoder -> 'b decoder
(** Returns a decoder that maps the result of the given decoder if successful

{b Returns} an ['a] if both decoders succeed.

@raise [DecodeError] if unsuccessful 

@example {[
  (* Deoce a JSON tree structure *)
  type 'a tree =
  | Node of 'a * 'a tree list
  | Leaf of 'a

  let decodeTree decodeValue =
  |> Decode.(
      field "type" string
      |> andThen (fun
      | "node" -> Node (field "value" decodeValue) (field "children" (array decodeTree |> map Array.to_list))
      | "leaf" -> Leaf (field "value" decodeValue)
      )
    )

  let json =
    {| {
      "type": "node",
      "value": 9
      "children": [{
        "type": "leaf",
        "value": 5,
        "children": [{
          "type": "leaf",
          "value": 3
        }, {
          "type": "leaf",
          "value": 2
        }]
      }, {
          "type": "leaf",
          "value": 4
      }]
    } |}

  let myTree =
    json
    |> Js.Json.parseExn 
    |> decodeTree int
]}
*)

val unwrapResult : ('a, string) Js_result.t -> 'a
