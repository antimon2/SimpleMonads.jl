module MaybeMonadTest

using SimpleMonads
using SimpleMonads.MaybeMonad
using Test

@testset "MaybeMonad" begin

@test Just(2) isa Maybe{Int}
@test Just(2) isa Just{Int}
@test None(Int) isa Maybe{Int}
@test None(Int) isa None{Int}

res1 = @do Maybe begin
    a ← Just(2)
    b ← Just(3)
    a + b
end
@test res1 == Just(5)

res2 = @do Maybe begin
    a ← Just(2)
    b ← None(Int)
    a + b
end
@test res2 == None(Int)

res3 = @do Maybe begin
    a ← Just("Hello,")
    b ← Just("World!")
    a * b
end
@test res3 == Just("Hello,World!")

function getmaybe(dic::AbstractDict{K,V}, key::K) where {K,V}
    haskey(dic, key) ? Just(dic[key]) : None(V)
end

dic1 = Dict(:a=>1, :b=>2, :c=>3)
@test getmaybe(dic1, :a) == Just(1)
@test getmaybe(dic1, :b) == Just(2)
@test getmaybe(dic1, :c) == Just(3)
@test getmaybe(dic1, :d) == None(Int)

function getx2maybe(dic::AbstractDict{K,V}, key::K) where {K,V}
    @do Maybe begin
        v ← getmaybe(dic, key)
        2v
    end
end

@test getx2maybe(dic1, :a) == Just(2)
@test getx2maybe(dic1, :b) == Just(4)
@test getx2maybe(dic1, :c) == Just(6)
@test getx2maybe(dic1, :d) == None(Int)

# end

end

end  # module
