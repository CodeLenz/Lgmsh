#
# Read a .msh file and look for 2D (plane) elements of a given list
#
function Convert_2D(filename::String, elist::Vector{Int})

    # Nodes and coordinates
    nn, norder, coord = Lgmsh_import_coordinates(filename)

    # Nodes per element
    npe = Lgmsh_nodemap()

    # Maximum number of nodes per element in this mesh
    nnmax = maximum(npe[elist])

    # Something very, very stupid
    ne = 0
    for e in elist
        ne_e, _ = Lgmsh_import_element_by_type(filename,e)
        ne += ne_e
    end

    # Allocate the array of connectivities
    connect = zeros(Int64,ne,nnmax)

    # Allocate an auxiliary vector with the 
    # original tags
    tags = zeros(Int64,ne) 

    # Loop over elist AGAIN 
    offset = 0
    for e in elist

        # Recover data from each type of element
        ne_e, tags_e, connect_e = Lgmsh_import_element_by_type(filename,e)

        # Number of nodes per element in this particular type
        nne = npe[e]

        # Append connectivities
        connect[offset+1:offset+ne_e,1:nne] .= connect_e

        # Append tags
        tags[offset+1:offset+ne_e] .= tags_e

        # Adjust the offset
        offset += ne_e
        
    end

    return nn, coord, ne, connect, tags

end