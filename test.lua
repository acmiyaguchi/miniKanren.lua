package.path = './?.lua;' .. package.path
local MK = require("mk")

local run = MK.run
local run_all = MK.run_all
local eq = MK.eq
local not_eq = MK.not_eq
local all = MK.all
local alli = MK.alli
local condi = MK.condi
local cond = MK.cond
local fresh_vars = MK.fresh_vars
local succeed = MK.succeed
local fail = MK.fail

local list = MK.list
local car = MK.car
local cdr = MK.cdr
local equal = MK.equal

local build_bit = MK.build_bit
local build_num = MK.build_num

local NUM = require("num")
local poso = NUM.poso
local gt1o = NUM.gt1o
local plus_1o = NUM.plus_1o
local pluso = NUM.pluso
local minuso = NUM.minuso
local odd_multo = NUM.odd_multo
local multo = NUM.multo
local lto = NUM.lto
local leo = NUM.leo
local divo = NUM.divo
local counto = NUM.counto


local E = require("extend")
local mergeo = E.mergeo
local nullo = E.nullo
local conso = E.conso

r, a, b, c, d, e, f, g, a1, q, x = fresh_vars(11)

describe("eq", function()
   setup(function()
      a, b, c = fresh_vars(3)
   end)
   it("should not be equal", function()
      res = run(false, a, all(eq(a, b), not_eq(b, 2), not_eq(b, 3)))
      assert.same({ "_.0 not eq: 3,2" }, res)
   end)
   it("should not be equal triplet", function()
      res = run(false, a, all(eq(a, b), eq(b, c), not_eq(b, 2), not_eq(b, 3), not_eq(c, 4)))
      assert.same({ "_.0 not eq: 4,3,2" }, res)
   end)
   it("does not unify", function()
      res = run(false, a, all(eq(a, b), not_eq(b, 2), not_eq(b, 3), not_eq(1, 1)))
      assert.same({}, res)
   end)
end)

describe("numbers", function()
   setup(function()
      a, b, c, d, e = fresh_vars(5)
      function do_op3(op, x, y, expect)
         local res = run(false, c, all(
            eq(a, build_bit(x)),
            eq(b, build_bit(y)),
            op(a, b, c)
         ))
         assert.same(#res, 1)
         assert.same(build_bit(expect), res[1])
      end
      function do_op4(op, x, y, expect1, expect2)
         local res = run(false, e, all(
            eq(a, build_bit(x)),
            eq(b, build_bit(y)),
            op(a, b, c, d),
            eq({c, d}, e)
         ))
         assert.same(#res, 1)
         assert.same(build_bit(expect1), res[1][1])
         assert.same(build_bit(expect2), res[1][2])
      end
   end)
   it("build_bit for the first 5 numbers", function()
      -- little endian
      assert.same({}, build_bit(0))
      assert.same(list(1), build_bit(1))
      assert.same(list(0, 1), build_bit(2))
      assert.same(list(1, 1), build_bit(3))
      assert.same(list(0, 0, 1), build_bit(4))
      assert.same(list(1, 0, 1), build_bit(5))
   end)
   it("build_num is the inverse of build_bit", function()
      for i=1,32 do
         assert.same(i, build_num(build_bit(i)))
      end
   end)
   it("pluso behaves correctly", function()
      local function add(x, y, expect) do_op3(pluso, x, y, expect) end
      add(0, 0, 0)
      add(0, 1, 1)
      add(1, 0, 1)
      add(1, 1, 2)
      add(0, 2, 2)
      add(1, 2, 3)
      add(2, 1, 3)
   end)
   it("pluso enumerates all possible combinations", function()
      res = run(false, c, all(
         pluso(a, b, build_bit(4)),
         eq({a, b}, c)
      ))
      -- 0-4, 1-3, 2-2, 3-1, 4-0
      assert.same(#res, 5)
   end)
   it("plus_1o adds 1 to null", function()
      res = run(false, a, plus_1o({}, a))
      assert.same(#res, 1)
      assert.same(build_bit(1), res[1])
   end)
   it("plus_1o add 1 to 1", function()
      res = run(false, a, plus_1o(build_bit(1), a))
      assert.same(#res, 1)
      assert.same(build_bit(2), res[1])
   end)
   it("minuso behaves correctly", function()
      local function sub(x, y, expect) do_op3(minuso, x, y, expect) end
      sub(0, 0, 0)
      sub(1, 0, 1)
      sub(1, 1, 0)
      sub(2, 0, 2)
      sub(2, 1, 1)
   end)
   it("minuso does not return results for negative numbers", function()
      res = run(false, c, all(
         minuso(build_bit(0), build_bit(1), c)
      ))
      assert.same(#res, 0)
   end)
   it("multo behaves correctly", function()
      local function mult(x, y, expect) do_op3(multo, x, y, expect) end
      mult(0, 1, 0)
      mult(1, 0, 0)
      mult(1, 1, 1)
      mult(1, 2, 2)
      mult(2, 1, 2)
      mult(2, 2, 4)
   end)
   it("divo behaves correctly", function()
      local function div(x, y, e1, e2) do_op4(divo, x, y, e1, e2) end
      div(0, 1, 0, 0)
      div(0, 2, 0, 0)
      div(1, 1, 1, 0)
      div(1, 2, 0, 1)
      div(2, 1, 2, 0)
      div(5, 2, 2, 1)
      div(4, 2, 2, 0)
   end)
   it("divo does not divide by 0", function()
      for i=1,3 do
         res = run(false, c, all(
            divo(build_bit(i), build_bit(0), a, b),
            eq({a, b}, c)
         ))
         assert.same(#res, 0)
      end
   end)
end)

assert(equal(run(20, a,
       cond(
          all(eq(0, 1), eq(a, 1)),
          all(eq(0, 1), eq(a, 2))
       )), {}))

assert(equal(run(1, x, eq(x, 5)), {5}))
assert(equal(run(1, list(a, b, x), eq(x, 5)), {list("_.1", "_.0", 5)}))

assert(equal(run_all(x, all(eq(x, 5))), {5}))
assert(equal(run_all(x, all(eq(x, 5), eq(6, 6))), {5}))
assert(equal(run_all(x, all(eq(x, 5), eq(x, 6))), {}))

assert(equal(run_all(x, cond(eq(x, 5), eq(x, 6))), {5, 6}))
assert(equal(run(1, x, cond(eq(x, 5), eq(x, 6))), {5}))
assert(equal(run(2, x, cond(eq(x, 5), eq(x, 6))), {5, 6}))
assert(equal(run(10, x, cond(eq(x, 5), eq(x, 6))), {5, 6}))

assert(equal(run(1, x, cond(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5}))
assert(equal(run(2, x, cond(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5, 6}))
assert(equal(run(3, x, cond(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5, 6, 7}))

assert(equal(run_all(x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))
assert(equal(run(1, x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5}))
assert(equal(run(2, x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0"}))
assert(equal(run(3, x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))
assert(equal(run(100, x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))

assert(equal(run_all(list(a, b, c), cond(eq(a, 5), eq(b, 6), eq(c, 7))),
                {list(5, "_.1", "_.0"), list("_.1", 6, "_.0"), list("_.1", "_.0", 7)}))

assert(equal(run_all(x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5, 6, 7, 8}))

assert(equal(run(1, x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5}))
assert(equal(run(2, x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5, 6}))
assert(equal(run(3, x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5, 6, 7}))
assert(equal(run(4, x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5, 6, 7, 8}))

assert(equal(run_all(x, cond(eq(x, 5), eq(x, 6), all(eq(x, 7), eq(x, 8)))),
                {5, 6}))

assert(equal(run_all({x, 5}, cond(eq(x, 5), eq(x, 6), all(eq(x, 7), eq(x, 8)))),
                {{5, 5}, {6, 5}}))

assert(equal(run_all(x, cond(eq({x, 1}, {2, 1}), eq({x, x}, {3, 3}))), {2, 3}))

assert(equal(run(3, x, cond(
                        eq(x, 2),
                        eq(x, 3),
                        function(s) return eq(x, 4)(s) end
                               )), {2, 3, 4}))


assert(equal(run(false, {a, b, c}, all(eq(a, 2), eq(a, b), not_eq(b, 3))), {{2, 2, "_.0"}}))
assert(equal(run(false, {a, b, c}, all(eq(c, 2), eq(a, b), not_eq(b, 3))), { { "_.0 not eq: 3", "_.0 not eq: 3", 2 } }))
assert(equal(run(false, {a, b}, all(eq(a, b), not_eq(a, 3))), { { "_.0 not eq: 3", "_.0 not eq: 3" } }))

assert(equal(run(1, a, mergeo({1, {2, {3}}}, {4, {5, {6, {}}}}, a)), { list(1, 2, 3, 4, 5, 6) }))

assert(equal(run(1, a, mergeo({1}, {2}, a)), { {1, {2}} }))
assert(equal(run(1, a, mergeo({}, {1}, a)), { {1} }))
assert(equal(run(1, a, mergeo({1}, {}, a)), { {1, {}} }))

assert(equal(
          run(false, a, all(
                 eq(a, b),
                 eq(b, c),
                 not_eq(a, 1),
                 not_eq(b, 2),
                 not_eq(c, 3)))
          , { "_.0 not eq: 3,2,1" }))
