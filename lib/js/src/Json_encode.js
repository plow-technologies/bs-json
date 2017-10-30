'use strict';

var List    = require("bs-platform/lib/js/list.js");
var $$Array = require("bs-platform/lib/js/array.js");
var Js_dict = require("bs-platform/lib/js/js_dict.js");

function dateFloat(f) {
  return f.toISOString();
}

var object_ = Js_dict.fromList;

function list(encode, l) {
  return $$Array.of_list(List.map(encode, l));
}

exports.object_   = object_;
exports.dateFloat = dateFloat;
exports.list      = list;
/* Js_dict Not a pure module */
