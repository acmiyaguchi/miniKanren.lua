--- Extended predicates for lists.
local MK = require("mk")
local eq = MK.eq
local all = MK.all
local cond = MK.cond
local fresh_vars = MK.fresh_vars

--- Determine if a list is empty.
-- @param l A list.
-- @return Whether the predicate unifies.
local function nullo(l)
   return eq(l, {})
end

--- Perform cons on two variables.
-- @param a The variable at the head.
-- @param d The variable at the tail.
-- @param p The cons pair.
-- @return Whether the predicate unifies.
local function conso(a, d, p)
   return eq({a, d}, p)
end

--- Unify a variable with a pair.
-- @param p A pair.
-- @return Whether the predicate unifies.
local function pairo(p)
   local a, d = fresh_vars(2)
   return eq({a, d}, p)
end

--- Perform car on a list.
-- @param p A list.
-- @param a The head of the list.
-- @return Whether the predicate unifies.
local function caro(p, a)
   local d = fresh_vars(1)
   return conso(a, d, p)
end

--- Perform cdr on a list.
-- @param p A list.
-- @param d The rest of the list.
-- @return Whether the predicate unifies.
local function cdro(p, d)
   local a = fresh_vars(1)
   return conso(a, d, p)
end

local function append_heado(p1, e, p2)
   return conso(e, p1, p2)
end

--- Merge two lists.
-- @param p1 A list
-- @param p2 Another list
-- @param p The merged list
-- @return Whether the predicate unifies.
local function mergeo(p1, p2, p)
   local a, d, pp = fresh_vars(3)
   return cond(
      all(nullo(p1), eq(p2, p)),
      all(
         conso(a, d, p1),
         function(s) return mergeo(d, p2, pp)(s) end,
         append_heado(pp, a, p)
      ))
end

--- @export
return {
   nullo=nullo,
   conso=conso,
   pairo=pairo,
   caro=caro,
   cdro=cdro,
   mergeo=mergeo,
}
