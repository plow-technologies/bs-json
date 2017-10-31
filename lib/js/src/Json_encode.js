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

exports.object_  = object_;
exports.optional = optional;
exports.date     = date;
exports.list     = list;
/* Js_dict Not a pure module */
