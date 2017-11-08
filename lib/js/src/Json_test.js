'use strict';

var Fs                      = require("fs");
var Curry                   = require("bs-platform/lib/js/curry.js");
var Caml_obj                = require("bs-platform/lib/js/caml_obj.js");
var Caml_builtin_exceptions = require("bs-platform/lib/js/caml_builtin_exceptions.js");

function roundtrip(file, decode, encode) {
  var f = JSON.parse(Fs.readFileSync(file, "utf8"));
  var rDecoded = Curry._1(decode, f);
  if (rDecoded.tag) {
    var message = rDecoded[0];
    console.log(message);
    if ("" === message) {
      return 0;
    } else {
      throw [
            Caml_builtin_exceptions.assert_failure,
            [
              "Json_test.ml",
              6,
              48
            ]
          ];
    }
  } else {
    var encoded = Curry._1(encode, rDecoded[0]);
    if (Caml_obj.caml_equal(encoded, f)) {
      return 0;
    } else {
      throw [
            Caml_builtin_exceptions.assert_failure,
            [
              "Json_test.ml",
              5,
              61
            ]
          ];
    }
  }
}

exports.roundtrip = roundtrip;
/* fs Not a pure module */
