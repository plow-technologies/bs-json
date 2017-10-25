'use strict';

var List            = require("bs-platform/lib/js/list.js");
var $$Array         = require("bs-platform/lib/js/array.js");
var Block           = require("bs-platform/lib/js/block.js");
var Curry           = require("bs-platform/lib/js/curry.js");
var Js_math         = require("bs-platform/lib/js/js_math.js");
var Pervasives      = require("bs-platform/lib/js/pervasives.js");
var Caml_exceptions = require("bs-platform/lib/js/caml_exceptions.js");

function _isInteger(value) {
  if (isFinite(value)) {
    return +(Js_math.floor(value) === value);
  } else {
    return /* false */0;
  }
}

var DecodeError = Caml_exceptions.create("Json_decode.DecodeError");

function $$boolean(json) {
  if (typeof json === "boolean") {
    return /* Ok */Block.__(0, [json]);
  } else {
    return /* Error */Block.__(1, ["Expected boolean, got " + JSON.stringify(json)]);
  }
}

function bool(json) {
  var match = $$boolean(json);
  if (match.tag) {
    return /* Error */Block.__(1, [match[0]]);
  } else {
    return /* Ok */Block.__(0, [+match[0]]);
  }
}

function $$float(json) {
  if (typeof json === "number") {
    return /* Ok */Block.__(0, [json]);
  } else {
    return /* Error */Block.__(1, ["Expected number, got " + JSON.stringify(json)]);
  }
}

function $$int(json) {
  var match = $$float(json);
  if (match.tag) {
    return /* Error */Block.__(1, [match[0]]);
  } else {
    var f = match[0];
    if (_isInteger(f)) {
      return /* Ok */Block.__(0, [f]);
    } else {
      return /* Error */Block.__(1, ["Expected integer, got " + JSON.stringify(json)]);
    }
  }
}

function string(json) {
  if (typeof json === "string") {
    return /* Ok */Block.__(0, [json]);
  } else {
    return /* Error */Block.__(1, ["Expected string, got " + JSON.stringify(json)]);
  }
}

function nullable(decode, json) {
  if (json === null) {
    return /* Ok */Block.__(0, [null]);
  } else {
    var match = Curry._1(decode, json);
    if (match.tag) {
      return /* Error */Block.__(1, [match[0]]);
    } else {
      return /* Ok */Block.__(0, [match[0]]);
    }
  }
}

function array(decode, json) {
  if (Array.isArray(json)) {
    var length = json.length;
    var target = new Array(length);
    var errors = /* array */[];
    for(var i = 0 ,i_finish = length - 1 | 0; i <= i_finish; ++i){
      var match = Curry._1(decode, json[i]);
      if (match.tag) {
        errors.concat(match[0]);
      } else {
        target[i] = match[0];
      }
    }
    if (errors.length > 0) {
      return /* Error */Block.__(1, ["Decode errors in array: " + errors.join(", ")]);
    } else {
      return /* Ok */Block.__(0, [target]);
    }
  } else {
    return /* Error */Block.__(1, ["Expected array, got " + JSON.stringify(json)]);
  }
}

function list(decode, json) {
  var match = array(decode, json);
  if (match.tag) {
    return /* Error */Block.__(1, [match[0]]);
  } else {
    return /* Ok */Block.__(0, [$$Array.to_list(match[0])]);
  }
}

function pair(left, right, json) {
  if (Array.isArray(json)) {
    var length = json.length;
    if (length === 2) {
      var match = Curry._1(left, json[0]);
      if (match.tag) {
        return /* Error */Block.__(1, ["Decoder for the first element of the tuple failed, got " + match[0]]);
      } else {
        var match$1 = Curry._1(right, json[1]);
        if (match$1.tag) {
          return /* Error */Block.__(1, ["Decoder for the second element of the tuple failed, got " + match$1[0]]);
        } else {
          return /* Ok */Block.__(0, [/* tuple */[
                      match[0],
                      match$1[0]
                    ]]);
        }
      }
    } else {
      return /* Error */Block.__(1, ["Expected array of length 2, got array of length" + Pervasives.string_of_int(length)]);
    }
  } else {
    return /* Error */Block.__(1, ["Expected array, got " + JSON.stringify(json)]);
  }
}

var tuple2 = pair;

function tuple3(first, second, third, json) {
  if (Array.isArray(json)) {
    var length = json.length;
    if (length === 3) {
      var match = Curry._1(first, json[0]);
      if (match.tag) {
        return /* Error */Block.__(1, ["Decoder for the first element of the tuple failed, got " + match[0]]);
      } else {
        var match$1 = Curry._1(second, json[1]);
        if (match$1.tag) {
          return /* Error */Block.__(1, ["Decoder for the second element of the tuple failed, got " + match$1[0]]);
        } else {
          var match$2 = Curry._1(third, json[2]);
          if (match$2.tag) {
            return /* Error */Block.__(1, ["Decoder for the third element of the tuple failed, got " + match$2[0]]);
          } else {
            return /* Ok */Block.__(0, [/* tuple */[
                        match[0],
                        match$1[0],
                        match$2[0]
                      ]]);
          }
        }
      }
    } else {
      return /* Error */Block.__(1, ["Expected array of length 3, got array of length" + Pervasives.string_of_int(length)]);
    }
  } else {
    return /* Error */Block.__(1, ["Expected array, got " + JSON.stringify(json)]);
  }
}

function dict(decode, json) {
  if (typeof json === "object" && !Array.isArray(json) && json !== null) {
    var keys = Object.keys(json);
    var l = keys.length;
    var target = { };
    var errors = /* array */[];
    for(var i = 0 ,i_finish = l - 1 | 0; i <= i_finish; ++i){
      var key = keys[i];
      var match = Curry._1(decode, json[key]);
      if (match.tag) {
        errors.concat(match[0]);
      } else {
        target[key] = match[0];
      }
    }
    return /* Ok */Block.__(0, [target]);
  } else {
    return /* Error */Block.__(1, ["Expected object, got " + JSON.stringify(json)]);
  }
}

function field(key, decode, json) {
  if (typeof json === "object" && !Array.isArray(json) && json !== null) {
    var match = json[key];
    if (match !== undefined) {
      return Curry._1(decode, match);
    } else {
      return /* Error */Block.__(1, ["Expected field \'" + (String(key) + "\'")]);
    }
  } else {
    return /* Error */Block.__(1, ["Expected object, got " + JSON.stringify(json)]);
  }
}

function unsafeField(key, decode, json) {
  if (typeof json === "object" && !Array.isArray(json) && json !== null) {
    var match = json[key];
    if (match !== undefined) {
      var match$1 = Curry._1(decode, match);
      if (match$1.tag) {
        throw [
              DecodeError,
              "Expected field \'" + (String(key) + "\'")
            ];
      } else {
        return match$1[0];
      }
    } else {
      throw [
            DecodeError,
            "Expected field \'" + (String(key) + "\'")
          ];
    }
  } else {
    throw [
          DecodeError,
          "Expected object, got " + JSON.stringify(json)
        ];
  }
}

function optional(decode, json) {
  var exit = 0;
  var val;
  try {
    val = Curry._1(decode, json);
    exit = 1;
  }
  catch (exn){
    return /* None */0;
  }
  if (exit === 1) {
    if (val.tag) {
      return /* None */0;
    } else {
      return /* Some */[val[0]];
    }
  }
  
}

function oneOf(_decoders, json) {
  while(true) {
    var decoders = _decoders;
    if (decoders) {
      var rest = decoders[1];
      var exit = 0;
      var val;
      try {
        val = Curry._1(decoders[0], json);
        exit = 1;
      }
      catch (exn){
        _decoders = rest;
        continue ;
        
      }
      if (exit === 1) {
        if (val.tag) {
          _decoders = rest;
          continue ;
          
        } else {
          return /* Ok */Block.__(0, [val[0]]);
        }
      }
      
    } else {
      var length = List.length(decoders);
      return /* Error */Block.__(1, ["Expected oneOf " + (Pervasives.string_of_int(length) + (", got " + JSON.stringify(json)))]);
    }
  };
}

function either(a, b) {
  var partial_arg_001 = /* :: */[
    b,
    /* [] */0
  ];
  var partial_arg = /* :: */[
    a,
    partial_arg_001
  ];
  return (function (param) {
      return oneOf(partial_arg, param);
    });
}

function withDefault($$default, decode, json) {
  var exit = 0;
  var val;
  try {
    val = Curry._1(decode, json);
    exit = 1;
  }
  catch (exn){
    return $$default;
  }
  if (exit === 1) {
    if (val.tag) {
      return $$default;
    } else {
      return val[0];
    }
  }
  
}

function map(f, decode, json) {
  var match = Curry._1(decode, json);
  if (match.tag) {
    return /* Error */Block.__(1, [match[0]]);
  } else {
    return /* Ok */Block.__(0, [Curry._1(f, match[0])]);
  }
}

function andThen(b, a, json) {
  var match = Curry._1(a, json);
  if (match.tag) {
    return /* Error */Block.__(1, [match[0]]);
  } else {
    return Curry._2(b, match[0], json);
  }
}

exports.DecodeError = DecodeError;
exports.$$boolean   = $$boolean;
exports.bool        = bool;
exports.$$float     = $$float;
exports.$$int       = $$int;
exports.string      = string;
exports.nullable    = nullable;
exports.array       = array;
exports.list        = list;
exports.pair        = pair;
exports.tuple2      = tuple2;
exports.tuple3      = tuple3;
exports.dict        = dict;
exports.field       = field;
exports.unsafeField = unsafeField;
exports.optional    = optional;
exports.oneOf       = oneOf;
exports.either      = either;
exports.withDefault = withDefault;
exports.map         = map;
exports.andThen     = andThen;
/* No side effect */
