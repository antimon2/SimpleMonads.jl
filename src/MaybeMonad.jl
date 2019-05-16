module MaybeMonad

import ..Monad, ..bind, ..pure

export Maybe, Just, None

abstract type Maybe{T} <: Monad end

struct Just{T} <: Maybe{T}
    val::T
end

(::Type{Maybe})(a::T) where {T} = Just{T}(a)
(::Type{Maybe{T}})(a::T) where {T} = Just{T}(a)

struct None{T} <: Maybe{T} end
None(::Type{T}) where {T} = None{T}()

(::Type{Maybe{T}})() where {T} = None{T}()

bind(ma::Just{T}, cont) where {T} = cont(ma.val)
bind(::None{T}, _cont) where {T} = None(T)

end  # module
