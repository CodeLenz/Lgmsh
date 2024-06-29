#
# Read a .msh file and export to the YAML format
#
# Daniele (Acoustics)
#
function YAML_Daniele(meshfile::String, yamfile::String)

    # Element types
    et = [3]

    # Read mesh
    nn, coord, ne, etypes, connect, etags = Readmesh(meshfile,et)

    #
    # Expected Physical groups
    #
    # Material,nome,id,dens,c,Z [ surfaces (and volumes) ]
    #
    # Open [ lines and/or nodes]
    #
    #
    pgroups, pgnames = Lgmsh_import_physical_groups(meshfile)

    # Vector with Dicts of materials
    materials = Dict{String,Float64}[]

    # Loop over groups
    for g=1:length(pgnamess)

       # Name
       name = pgnames[g]

       # Check if Material
       if occursin("Material",name)

          # Local dictionary
          locald = Dict{String,Float64}()

          # Split the string by ","
          st = split(name,",")
          
          # We expect the following data
          # name, id, dens, c, Z
          id   = parse(Float64,st[2])
          dens = parse(Float64,st[3])
          c    = parse(Float64,st[4])
          Z    = parse(Float64,st[5])
  
          # Create the local dict
          locald["id"]   = id
          locald["dens"] = dens
          locald["c"]    = c
          locald["Z"]    = Z

       end

       # Store
       push!(materials,locald)

    end 

    return nn, coord, ne, connect

end