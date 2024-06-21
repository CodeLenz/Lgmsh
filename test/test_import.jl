@testset "Lgmsh_import" begin

    # mesh
    filename = joinpath(pathof(Lgmsh)[1:end-12],"geo/cantilever.msh")

    # Avoid printing gmsh output
    redirect_stdout(open(tempname(), "w")) do

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

        # Readmesh
        nn,ne,coord,etypes,connect,tags = Readmesh(filename,[3])

    end
end

 