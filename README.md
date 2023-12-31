This package lets you generate getter and setter procs for object types. For situations where you only want the outside world to be able to do one of those, so exporting the field doesnt do the trick.

There are two options:

## setable, getable macros

```nim
type Obj* = object
  a, b: int
  c: bool
  d: string

Obj.getable(a, b)
Obj.setable(d)
```

## customAccess pragma

**Note**: this doens't work with mutual recursive types.

```nim
type Obj* {.customAccess.} = object
  a {.getable.}, b {.getable.}: int
  c: bool
  d {.setable.}: string
```
