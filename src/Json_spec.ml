let roundtrip file decode encode = begin
  let f = Js.Json.parseExn (Node.Fs.readFileAsUtf8Sync file) in
  let rDecoded = decode f in
  match rDecoded with
  | Js_result.Ok(decoded) -> let encoded = encode decoded in assert (encoded = f);
  | Js_result.Error(message) -> Js.log message; assert ("" = message);
end;
