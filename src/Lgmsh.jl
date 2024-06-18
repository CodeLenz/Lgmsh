module Lgmsh

    include("init.jl")
    include("scalar.jl")

    export Lgmsh_init
    export Lgmsh_nodal_scalar, Lgmsh_element_scalar

end
