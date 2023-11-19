import std/unittest
import ./externModule

test "getter/setter macros":
  var obj = newTestObj1(1, 2, 3, "foo")
  check obj.b == 2
  check not compiles(obj.b = 4)
  obj.a = 4  # check with `compiles` doenst work for whatever reason
  check not compiles(obj.a)
  check obj.d == "foo"

test "{.customAccess.} pragma":
  var obj = newTestObj2(1, 2, 3)
  check obj.b == 2
  check not compiles(obj.b = 4)
  obj.a = 4  # check with `compiles` doenst work for whatever reason
  check not compiles(obj.a)