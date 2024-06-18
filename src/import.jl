
using Gmsh

#
# Use the Gmsh library (direct link to the C library)  to extract data in a 'friendly' manner to be used 
# elsewere
#

#
# Import nodes from mesh file
#
function Lgmsh_import_coordinates(filename::String)

    # Initialize gmsh (C library)
    gmsh.initialize()

    # Open file
    gmsh.open(filename)

    # Import node coordinates
    nodes = gmsh.model.mesh.getNodes()

    # Number of nodes
    nn = length(nodes[1])

    # Node numbers
    # This array is important, since the nodes are not
    # stored in an ordered manner
    node_numbers = Int.(nodes[1])

    # Coordinates
    coord = zeros(nn,3)

    # Loop over coordinates
    for n=1:nn

        # node
        node = node_numbers[n]

        # Positions
        p = 3*(node-1).+collect(1:3)
        
        # Coordinates
        coord[node,:] = nodes[2][p]

    end

    # Finalize gmsh
    gmsh.finalize()

    # Return nodal data
    return nn, node_numbers, coord

end


#
# Return a list with element types in the mesh
#
function Lgmsh_import_etypes(filename::String)

    # Initialize gmsh (C library)
    gmsh.initialize()

    # Open file
    gmsh.open(filename)

    # Import elements
    #
    # First entry is a list of element types
    elements = gmsh.model.mesh.getElements()

    # Element types
    element_types = elements[1]

    # Finalize gmsh
    gmsh.finalize()

    # Return it
    return element_types

end


#
# Return number of elements, numbers and connectivities for 
# all elements of a given type
#
function Lgmsh_import_element_by_type(filename::String,type::Int)

    # Initialize gmsh (C library)
    gmsh.initialize()

    # Open file
    gmsh.open(filename)

    # Import elements
    elements = gmsh.model.mesh.getElements()

    # Element types
    element_types = elements[1]

    # Position of type in element_types
    pos = findfirst(x->x==type,element_types)

    # Check if there are elements of the required type
    !isnothing(pos) || error("Lgmsh_import_element_by_type:there are no elements of type $type in this file")

    # Second entry is a vector of vectors, with a list with element tags for each element type
    tags = Int.(elements[2][pos])
 
    # Node mapping
    nos = Lgmsh_nodemap()

    # number of elements of this particular type
    ne_type = length(tags)

    # Array of connectivities 
    connect = zeros(Int64,ne_type,nos[type])

    # Array with element numbers
    number = zeros(Int64,ne_type)

    # Loop over element types
    for i=1:ne_type

        # Get number
        number[i] = tags[i]

        # Get element data
        # type, vector with nodes, dim and tag
        data = gmsh.model.mesh.getElement(tags[i])

        # Store nodes
        connect[i,:] .= Int.(data[2])

    end #i

    # Finalize gmsh
    gmsh.finalize()

    # Return information for this type of element
    return ne_type, number, connect

end


#
# Return Physical_groups dimensions, tags and names
#
function Lgmsh_import_physical_groups(filename::String)

    # Initialize gmsh (C library)
    gmsh.initialize()

    # Open file
    gmsh.open(filename)

    # Load PhysicalGroups
    pgroups = gmsh.model.getPhysicalGroups()

    # Number of physical groups
    npg = length(pgroups)

    # Load the names of each Physical Group
    names = String[]

    # Loop over pairs
    for p in pgroups
        push!(names,gmsh.model.getPhysicalName(p[1],p[2]))
    end
        
    # Finalize gmsh
    gmsh.finalize()

    # Return a vector with tuples (dim,tag)
    # and a vector with the strings associated
    # to each physical group
    return pgroups, names

end



#
# Return entities associated to a given NAME of a physical group
#
function Lgmsh_import_entities_physical_group(filename::String,group::String)

    # Initialize gmsh (C library)
    gmsh.initialize()

    # Open file
    gmsh.open(filename)

    # Get entities
    entities = gmsh.model.getEntitiesForPhysicalName(group)

    # Return entities
    return entities

end