#
# Use the Gmsh library (direct link to the C library)  to extract data in a 'friendly' manner to be used 
# elsewere
#
# https://gitlab.onelab.info/gmsh/gmsh/blob/master/api/gmsh.jl
#

#
#   nn, node_numbers, coord = Lgmsh_import_coordinates(filename::String)
# 
#   element_types = Lgmsh_import_etypes(filename::String) 
#
#   ne, tags, connect = Lgmsh_import_element_by_type(filename::String,type)
#
#   pgroups, names =  Lgmsh_import_physical_groups(filename::String)
#
#   entities = Lgmsh_import_entities_physical_group(filename::String,group::String)
#
#   elementTypes, elementTags = Lgmsh_import_elements_tuple(filename::String,dim,tag)
#
#   nodes = Lgmsh_import_nodes_tuple(filename::String,dim,tag)
#
#   nodes = Lgmsh_import_nodes_elem_physical_group(filename::String, dim, tag)
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



#gmsh.model.mesh.getElementsByType(elementType, tag = -1, task = 0, numTasks = 1)
#
#Get the elements of type `elementType` classified on the entity of tag `tag`. If
#`tag` < 0, get the elements for all entities. `elementTags` is a vector
#containing the tags (unique, strictly positive identifiers) of the elements of
#the corresponding type. `nodeTags` is a vector of length equal to the number of
#elements of the given type times the number N of nodes for this type of element,
#that contains the node tags of all the elements of the given type, concatenated:
#[e1n1, e1n2, ..., e1nN, e2n1, ...]. If `numTasks` > 1, only compute and return
#the part of the data indexed by `task` (for C++ only; output vectors must be
#preallocated).
#Return `elementTags`, `nodeTags`.
#Types:
# - `elementType`: integer
# - `elementTags`: vector of sizes
# - `nodeTags`: vector of sizes
# - `tag`: integer
# - `task`: size
# - `numTasks`: size
#"""

########### EU DEVERIA USAR O MÉTODO ACIMA ###############

#
# Return number of elements, numbers and connectivities for 
# all elements of a given type
#
function Lgmsh_import_element_by_type(filename::String,type,flag_error=true)

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
    if !isnothing(pos) 
        
        # Finalize gmsh
        gmsh.finalize()

        if flag_error
           # Error
           error("Lgmsh_import_element_by_type:there are no elements of type $type in this file")
        else
           # Return empty arrays
           return 0, [], []
        end 

    end

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

    # Finalize gmsh
    gmsh.finalize()

    # Return entities
    return entities

end


#
# Return elements for (dim,tag)
#
# Get the elements classified on the entity of dimension `dim` and tag `tag`. If
# `tag` < 0, get the elements for all entities of dimension `dim`. If `dim` and
# `tag` are negative, get all the elements in the mesh. `elementTypes` contains
# the MSH types of the elements (e.g. `2` for 3-node triangles: see
# `getElementProperties` to obtain the properties for a given element type).
# `elementTags` is a vector of the same length as `elementTypes`; each entry is a
# vector containing the tags (unique, strictly positive identifiers) of the
# elements of the corresponding type. `nodeTags` is also a vector of the same
# length as `elementTypes`; each entry is a vector of length equal to the number
# of elements of the given type times the number N of nodes for this type of
# element, that contains the node tags of all the elements of the given type,
# concatenated: [e1n1, e1n2, ..., e1nN, e2n1, ...].
#
function Lgmsh_import_elements_tuple(filename::String,dim,tag)

    # Initialize gmsh (C library)
    gmsh.initialize()

    # Open file
    gmsh.open(filename)

    # Recover a list of element types and a vector of vectors with element
    # tags
    elementTypes, elementTags, _ = gmsh.model.mesh.getElements(dim, tag)

    # Finalize gmsh
    gmsh.finalize()

    return elementTypes, elementTags

end

#
# Return nodes for (dim,tag)
#
# Get the nodes classified on the entity of dimension `dim` and tag `tag`. If
# `tag` < 0, get the nodes for all entities of dimension `dim`. If `dim` and `tag`
# are negative, get all the nodes in the mesh. `nodeTags` contains the node tags
# (their unique, strictly positive identification numbers). `coord` is a vector of
# length 3 times the length of `nodeTags` that contains the x, y, z coordinates of
# the nodes, concatenated: [n1x, n1y, n1z, n2x, ...]. If `dim` >= 0 and
# `returnParamtricCoord` is set, `parametricCoord` contains the parametric
# coordinates ([u1, u2, ...] or [u1, v1, u2, ...]) of the nodes, if available. The
# length of `parametricCoord` can be 0 or `dim` times the length of `nodeTags`. If
# `includeBoundary` is set, also return the nodes classified on the boundary of
# the entity (which will be reparametrized on the entity if `dim` >= 0 in order to
# compute their parametric coordinates).

function Lgmsh_import_nodes_tuple(filename::String,dim,tag)

        # Initialize gmsh (C library)
        gmsh.initialize()
    
        # Open file
        gmsh.open(filename)
    
        # Nodes
        nodes = gmsh.model.mesh.getNodes(dim, tag)
    
        # Finalize gmsh
        gmsh.finalize()
    
        return nodes
    
end


#
# Get the nodes from all the elements belonging to the physical group of dimension
#`dim` and tag `tag`. `nodeTags` contains the node tags; `coord` is a vector of
#length 3 times the length of `nodeTags` that contains the x, y, z coordinates of
#the nodes, concatenated: [n1x, n1y, n1z, n2x, ...].
#Return `nodeTags`, `coord`.
#Types:
# - `dim`: integer
# - `tag`: integer
# - `nodeTags`: vector of sizes
# - `coord`: vector of doubles
#
function Lgmsh_import_nodes_elems_physical_group(filename::String, dim, tag)

    # Initialize gmsh (C library)
    gmsh.initialize()
    
    # Open file
    gmsh.open(filename)
     
    # Node tags
    tags, _ =  gmsh.model.mesh.getNodesForPhysicalGroup(dim, tag)
     
    # Finalize gmsh
    gmsh.finalize()
     
    return Int.(tags)
     
end
  
