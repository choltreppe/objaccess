import objaccess

type TestObj1* = object
  a, b, c*: int
  d: string

func newTestObj1*(a, b, c: int, d: string): TestObj1 = TestObj1(a: a, b: b, c: c, d: d)

TestObj1.getable(b, d)
TestObj1.setable(a)


type TestObj2* {.customAccess.} = object
  a {.setable.}, b {.getable.}, c*: int

func newTestObj2*(a, b, c: int): TestObj2 = TestObj2(a: a, b: b, c: c)