import std/[macros, strutils]


macro getter*(ObjType: untyped, fields: varargs[untyped]): untyped =
  result = newStmtList()
  for field in fields:
    field.expectKind nnkIdent
    result.add: quote do:
      func `field`*(self: `ObjType`): typeof(`ObjType`().`field`) =
        self.`field`

macro setter*(ObjType: untyped, fields: varargs[untyped]): untyped =
  result = newStmtList()
  for field in fields:
    field.expectKind nnkIdent
    let funcName = nnkAccQuoted.newTree(field, ident"=")
    result.add: quote do:
      func `funcName`*(self: var `ObjType`, v: typeof(`ObjType`().`field`)) =
        self.`field` = v


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
          block:
            if pragma.kind == nnkIdent:
              if cmpIgnoreStyle(pragma.strVal, "getable") == 0:
                result.add: quote do:
                  `innerType`.getter(`fieldName`)
              elif cmpIgnoreStyle(pragma.strVal, "setable") == 0:
                let funcName = nnkAccQuoted.newTree(fieldName, ident"=")
                result.add: quote do:
                  `innerType`.setter(`fieldName`)
              else: break
              if fieldName.kind == nnkPostfix:
                error "setable/getable fields should not be exported", fieldName
              pragmas.del(i)
              continue
          inc i
      defs[i] = field

  result.add innerType
  result = nnkTypeDef.newTree(copy(typeDef[0][0]), newEmptyNode(), result)
  typeDef[0][0] = innerType