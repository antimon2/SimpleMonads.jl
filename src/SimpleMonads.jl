module SimpleMonads

import Base.bind

export Monad, pure, bind, @do

abstract type Monad end

function pure(::Type{M}, a) where {M<:Monad}
    M(a)
end

function _monad_task(::Type{T}, _inner_task::Task) where {T <: Monad}
    _current_task = current_task()
    _inner_task.parent = _current_task
    @async begin
        wait(_inner_task)
        yield(_current_task)
    end
    function _rec(arg)
        ma = yieldto(_inner_task, arg)
        istaskdone(_inner_task) && return pure(T, _inner_task.result)
        bind(ma, _rec)
    end
    _rec(nothing)
end

function _desugar_line(line::Expr)
    if line.head === :call && line.args[1] === :(←)
        :(local $(esc(line.args[2])) = yieldto(current_task().parent, $(esc(line.args[3]))))
    else
        esc(line)
    end
end
_desugar_line(line) = esc(line)

function _monad_do(MonadType, ex)
    block = ex
    if Base.is_expr(ex, :block)
        block = Expr(:block, (_desugar_line(line) for line in ex.args)...)
    end
    quote
        _inner_task = @task $block
        fetch(@async _monad_task($(esc(MonadType)), _inner_task))
    end
end

@eval begin
    """
    @do MonadType block
    """
    macro $(:do)(MonadType, ex)
        _monad_do(MonadType, ex)
    end
end

# MaybeMonad
include("MaybeMonad.jl")
export MaybeMonad

end # module
