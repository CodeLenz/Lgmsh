module Lgmsh

    #https://gitlab.onelab.info/gmsh/gmsh/blob/master/api/gmsh.jl
    using Gmsh

    include("definitions.jl")

    # Post-processing
    include("init.jl")
    include("scalar.jl")
    include("vector.jl")

    # Pre-processing
    include("import.jl")

    # Post-processing
    export Lgmsh_init
    export Lgmsh_nodal_scalar, Lgmsh_element_scalar
    export Lgmsh_nodal_vector
    
    # Pre-processing
    export Lgmsh_import_coordinates, Lgmsh_import_etypes
    export Lgmsh_import_element_by_type
    export Lgmsh_import_physical_groups
    export Lgmsh_import_entities_physical_group

end
