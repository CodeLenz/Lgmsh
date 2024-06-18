@testset "Lgmsh_import" begin

    # mesh
    filename = "testmesh1.msh"

    # Number of nodes, node order and coordinates
    nn, norder, coord = Lgmsh_import_coordinates(filename)

    # Element types
    etypes = Lgmsh_import_etypes(filename)

    # Elements of each type
    for type in etypes
        ne_type, number, connect =  Lgmsh_import_element_by_type(filename,type)
    end

    # Physical groups
    pgroups, pgnames = Lgmsh_import_physical_groups(filename)

    # Entities associated to each physical group
    for name in pgnames
       entities = Lgmsh_import_entities_physical_group(filename,name)
    end

end

 