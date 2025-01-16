
import macros

macro genFieldsFromEnum*(name: typed) =
  let impl = name.getImpl()
  let ename = $name
  # echo "GEN NAME: ", name.repr
  # echo "GEN NAME:ti: ", name.getImpl().treeRepr
  result = newStmtList()
  for fieldDef in impl[2][1..^1]:
    let sm =
      if fieldDef.kind == nnkEnumFieldDef:
        fieldDef[0]
      elif fieldDef.kind == nnkSym:
        fieldDef
      else:
        error("unable to parse symbol: " & $fieldDef.kind)
    let n = ident("k" & ename & $sm)
    # echo "FD: ", sm.repr, " n: ", n
    result.add quote do:
      const `n`* = {`sm`}
