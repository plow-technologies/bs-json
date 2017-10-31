'use strict';

var List    = require("bs-platform/lib/js/list.js");
var $$Array = require("bs-platform/lib/js/array.js");
var Curry   = require("bs-platform/lib/js/curry.js");
var Js_dict = require("bs-platform/lib/js/js_dict.js");

function optional(encode, optionalValue) {
  if (optionalValue) {
    return Curry._1(encode, optionalValue[0]);
  } else {
    return null;
  }
}

function date(d) {
  return d.toISOString();
}

var object_ = Js_dict.fromList;

function list(encode, l) {
  return $$Array.of_list(List.map(encode, l));
}

function pair(encodeT0, encodeT1, tuple) {
  return /* array */[
          Curry._1(encodeT0, tuple[0]),
          Curry._1(encodeT1, tuple[1])
        ];
}

function tuple3(encodeT0, encodeT1, encodeT2, tuple) {
  return /* array */[
          Curry._1(encodeT0, tuple[0]),
          Curry._1(encodeT1, tuple[1]),
          Curry._1(encodeT2, tuple[2])
        ];
}

function tuple4(encodeT0, encodeT1, encodeT2, encodeT3, tuple) {
  return /* array */[
          Curry._1(encodeT0, tuple[0]),
          Curry._1(encodeT1, tuple[1]),
          Curry._1(encodeT2, tuple[2]),
          Curry._1(encodeT3, tuple[3])
        ];
}

function tuple5(encodeT0, encodeT1, encodeT2, encodeT3, encodeT4, tuple) {
  return /* array */[
          Curry._1(encodeT0, tuple[0]),
          Curry._1(encodeT1, tuple[1]),
          Curry._1(encodeT2, tuple[2]),
          Curry._1(encodeT3, tuple[3]),
          Curry._1(encodeT4, tuple[4])
        ];
}

function tuple6(encodeT0, encodeT1, encodeT2, encodeT3, encodeT4, encodeT5, tuple) {
  return /* array */[
          Curry._1(encodeT0, tuple[0]),
          Curry._1(encodeT1, tuple[1]),
          Curry._1(encodeT2, tuple[2]),
          Curry._1(encodeT3, tuple[3]),
          Curry._1(encodeT4, tuple[4]),
          Curry._1(encodeT5, tuple[5])
        ];
}

var tuple2 = pair;

exports.object_  = object_;
exports.optional = optional;
exports.date     = date;
exports.list     = list;
exports.pair     = pair;
exports.tuple2   = tuple2;
exports.tuple3   = tuple3;
exports.tuple4   = tuple4;
exports.tuple5   = tuple5;
exports.tuple6   = tuple6;
/* Js_dict Not a pure module */
