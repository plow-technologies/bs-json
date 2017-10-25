external _unsafeCreateUninitializedArray : int -> 'a array = "Array" [@@bs.new]

let _isInteger value =
  Js.Float.isFinite value && (float_of_int (Js.Math.floor value)) == value

type 'a decoder = Js.Json.t -> 'a

type 'a safeDecoder = Js.Json.t -> ('a, string) Js_result.t

exception DecodeError of string

open Js_result (* Ok and Error *)

let boolean json = 
  if Js.typeof json = "boolean" then
    Ok (Obj.magic (json : Js.Json.t) : Js.boolean)
  else
    Error ("Expected boolean, got " ^ Js.Json.stringify json)

let bool json = 
  match boolean json with
  | Ok v -> Js_result.Ok (Js.to_bool v)
  | Error err -> Js_result.Error err

let float json = 
  if Js.typeof json = "number" then
    Ok (Obj.magic (json : Js.Json.t) : float)
  else
    Error ("Expected number, got " ^ Js.Json.stringify json)

let int json =
  match float json with
  | Ok f ->
     (if _isInteger f then
       Ok (Obj.magic (f : float) : int)
     else
       Error ("Expected integer, got " ^ Js.Json.stringify json)
     )
  | Error err -> Error err

let string json = 
  if Js.typeof json = "string" then
    Ok (Obj.magic (json : Js.Json.t) : string)
  else
    Error ("Expected string, got " ^ Js.Json.stringify json)

let nullable decode json =
  if (Obj.magic json : 'a Js.null) == Js.null then
    Ok Js.null
  else
    match decode json with
    | Ok v -> Ok (Js.Null.return v)
    | Error err -> Error err

let array decode json = 
  if Js.Array.isArray json then begin
    let source = (Obj.magic (json : Js.Json.t) : Js.Json.t array) in
    let length = Js.Array.length source in
    let target = _unsafeCreateUninitializedArray length in
    let errors  = [||] in
    for i = 0 to length - 1 do
      match decode (Array.unsafe_get source i) with
      | Ok value -> Array.unsafe_set target i value;
      | Error err -> Js.Array.append err errors; ();
    done;
    if Js.Array.length errors > 0
    then Error ("Decode errors in array: " ^ (Js.Array.joinWith ", " errors))
    else Ok target
  end
  else
    Error ("Expected array, got " ^ Js.Json.stringify json)

let list decode json =
  match array decode json with
  | Ok value -> Ok (Array.to_list value)
  | Error err -> Error err

let pair left right json =
  if Js.Array.isArray json then begin
    let source = (Obj.magic (json : Js.Json.t) : Js.Json.t array) in
    let length = Js.Array.length source in
    if length = 2 then
      (match left (Array.unsafe_get source 0) with
       | Js_result.Ok a0 ->
         (match right (Array.unsafe_get source 1) with
          | Js_result.Ok a1 -> Js_result.Ok (a0,a1)
          | Js_result.Error err -> Js_result.Error ("Decoder for the second element of the tuple failed, got " ^ err)
         )
       | Js_result.Error err -> Js_result.Error ("Decoder for the first element of the tuple failed, got " ^ err)
      )
    else
      Js_result.Error ("Expected array of length 2, got array of length" ^ (string_of_int length))
  end
  else
    Js_result.Error ("Expected array, got " ^ Js.Json.stringify json)


let tuple2 first second json =
  pair first second json

let tuple3 first second third json =
  if Js.Array.isArray json then begin
    let source = (Obj.magic (json : Js.Json.t) : Js.Json.t array) in
    let length = Js.Array.length source in
    if length = 3 then
      (match first (Array.unsafe_get source 0) with
       | Js_result.Ok a0 ->
         (match second (Array.unsafe_get source 1) with
          | Js_result.Ok a1 ->
             (match third (Array.unsafe_get source 2) with
              | Js_result.Ok a2 -> Js_result.Ok (a0,a1,a2)
              | Js_result.Error err -> Js_result.Error ("Decoder for the third element of the tuple failed, got " ^ err)
             )
          | Js_result.Error err -> Js_result.Error ("Decoder for the second element of the tuple failed, got " ^ err)
         )
       | Js_result.Error err -> Js_result.Error ("Decoder for the first element of the tuple failed, got " ^ err)
      )
    else
      Js_result.Error ("Expected array of length 3, got array of length" ^ (string_of_int length))
  end
  else
    Js_result.Error ("Expected array, got " ^ Js.Json.stringify json)

(*
let tuple4 first second third fourth json =
  if Js.Array.isArray json then begin
    let source = (Obj.magic (json : Js.Json.t) : Js.Json.t array) in
    let length = Js.Array.length source in
    if length = 4 then
      Js_result.Ok (first (Array.unsafe_get source 0), second (Array.unsafe_get source 1), third (Array.unsafe_get source 2), fourth (Array.unsafe_get source 3))
    else
      Js_result.Error ("Expected array of length 4, got array of length" ^ (string_of_int length))
  end
  else
    Js_result.Error ("Expected array, got " ^ Js.Json.stringify json)

let tuple5 first second third fourth fifth json =
  if Js.Array.isArray json then begin
    let source = (Obj.magic (json : Js.Json.t) : Js.Json.t array) in
    let length = Js.Array.length source in
    if length = 4 then
      Js_result.Ok (first (Array.unsafe_get source 0), second (Array.unsafe_get source 1), third (Array.unsafe_get source 2), fourth (Array.unsafe_get source 3), fifth (Array.unsafe_get source 4))
    else
      Js_result.Error ("Expected array of length 5, got array of length" ^ (string_of_int length))
  end
  else
    Js_result.Error ("Expected array, got " ^ Js.Json.stringify json)

let tuple6 first second third fourth fifth sixth json =
  if Js.Array.isArray json then begin
    let source = (Obj.magic (json : Js.Json.t) : Js.Json.t array) in
    let length = Js.Array.length source in
    if length = 4 then
      Js_result.Ok (first (Array.unsafe_get source 0), second (Array.unsafe_get source 1), third (Array.unsafe_get source 2), fourth (Array.unsafe_get source 3), fifth (Array.unsafe_get source 4), sixth (Array.unsafe_get source 5))
    else
      Js_result.Error ("Expected array of length 6, got array of length" ^ (string_of_int length))
  end
  else
    Js_result.Error ("Expected array, got " ^ Js.Json.stringify json)
*)
  
let dict decode json = 
  if Js.typeof json = "object" && 
      not (Js.Array.isArray json) && 
      not ((Obj.magic json : 'a Js.null) == Js.null)
  then begin
    let source = (Obj.magic (json : Js.Json.t) : Js.Json.t Js.Dict.t) in
    let keys = Js.Dict.keys source in
    let l = Js.Array.length keys in
    let target = Js.Dict.empty () in
    let errors = [||] in
    for i = 0 to l - 1 do
      let key = (Array.unsafe_get keys i) in
      match decode (Js.Dict.unsafeGet source key) with
      | Ok value -> Js.Dict.set target key value;
      | Error err -> Js.Array.append err errors; ();
    done;
    Ok target
  end
  else
    Error ("Expected object, got " ^ Js.Json.stringify json)

let field key decode json =
  if Js.typeof json = "object" && 
      not (Js.Array.isArray json) && 
      not ((Obj.magic json : 'a Js.null) == Js.null)
  then begin
    let dict = (Obj.magic (json : Js.Json.t) : Js.Json.t Js.Dict.t) in
    match Js.Dict.get dict key with
    | Some value -> decode value
    | None -> Error ({j|Expected field '$(key)'|j})
  end
  else
    Error ("Expected object, got " ^ Js.Json.stringify json)

let unsafeField key decode json =
  if Js.typeof json = "object" && 
      not (Js.Array.isArray json) && 
      not ((Obj.magic json : 'a Js.null) == Js.null)
  then begin
    let dict = (Obj.magic (json : Js.Json.t) : Js.Json.t Js.Dict.t) in
    match Js.Dict.get dict key with
    | Some value ->
       (match decode value with
       | Ok v -> v
       | Error _ -> raise @@ DecodeError ({j|Expected field '$(key)'|j})
       )
    | None -> raise @@ DecodeError ({j|Expected field '$(key)'|j})
  end
  else
    raise @@ DecodeError ("Expected object, got " ^ Js.Json.stringify json)
(*
let rec at key_path decoder =
    match key_path with 
      | [key] -> field key decoder
      | first::rest -> field first (at rest decoder) 
      | [] -> raise @@ Invalid_argument ("Expected key_path to contain at least one element")
 *)
let optional decode json =
  match decode json with
  | exception _ -> None
  | Error _ -> None
  | Ok v -> Some v

let rec oneOf decoders json =
  match decoders with
  | [] ->
    let length = List.length decoders in
    Error ("Expected oneOf " ^ (string_of_int length) ^ ", got " ^ Js.Json.stringify json)
  | decode :: rest ->
    match decode json with
    | Ok v -> Ok v
    | Error _ -> oneOf rest json
    | exception _ -> oneOf rest json

let either a b =
  oneOf [a;b]

let withDefault default decode json =
  match decode json with
  | Ok v -> v
  | Error _ -> default
  | exception _ -> default

let map f decode json =
  match decode json with
  | Ok v -> Ok (f v)
  | Error err -> Error err

let andThen b a json =
  match a json with
  | Ok v -> b v json
  | Error err -> Error err
                       (*  b (a json) json *)
