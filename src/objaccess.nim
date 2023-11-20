import std/[macros, strutils]


macro getable*(ObjType: untyped, fields: varargs[untyped]): untyped =
  result = newStmtList()
  for field in fields:
    field.expectKind nnkIdent
    result.add: quote do:
      func `field`*(self: `ObjType`): typeof(`ObjType`().`field`) =
        self.`field`

macro setable*(ObjType: untyped, fields: varargs[untyped]): untyped =
  result = newStmtList()
  for field in fields:
    field.expectKind nnkIdent
    let funcName = nnkAccQuoted.newTree(field, ident"=")
    result.add: quote do:
      func `funcName`*(self: var `ObjType`, v: typeof(`ObjType`().`field`)) =
        self.`field` = v


func `~=`(a, b: string): bool {.inline.} =
  cmpIgnoreStyle(a, b) == 0

macro customAccess*(typeDef) =
  typeDef.expectKind nnkTypeDef
  typeDef[2].expectKind nnkObjectTy

  let innerType = genSym(nskType, "inner")

  result = newStmtList(nnkTypeSection.newTree(typeDef))
  for defs in typeDef[2][2]:
    for i, field in defs[0 ..< ^2]:
      if field.kind == nnkPragmaExpr:
        let fieldName = field[0]
        let pragmas = field[1]
        var i = 0
        while i < len(pragmas):
          let pragma = pragmas[i]
          if pragma.kind == nnkIdent and (pragma.strVal ~= "getable" or pragma.strVal ~= "setable"):
            result.add: quote do:
              `innerType`.`pragma`(`fieldName`)
            if fieldName.kind == nnkPostfix:
              error "setable/getable fields should not be exported", fieldName
            pragmas.del(i)
          else: inc i
      defs[i] = field

  result.add innerType
  result = nnkTypeDef.newTree(copy(typeDef[0][0]), newEmptyNode(), result)
  typeDef[0][0] = innerType