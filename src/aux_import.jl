#
# Subroutines to process the somehow messy information provided
# by Gmsh
#

# First Problem. We define a PhysicalLine / PhysicalSurface  
# and we want to apply a Natural Boundary Condition (pressure, for example).
# We will need to know the edges or the faces of element -type-
# that are present in this Line / surface. The problem is: gmsh creates a 
# lower dimensional elements in this Line / surface and do not
# relates this element to the edges / faces of the higher dimensional 
# element. 
#
# Dirty solution: scan for all nodes in the Line/Surface. Look for them
# in the connectivities. If found, store them with face information to 
# a list of elements.
#

#
# Return the positions of elements of needle that are in haystack
#
function Vector_match(needle::Vector,haystack::Vector)

    # Positions
    positions = Int[]

    # Loop over needle
    p = 0
    for i in needle
        p+=1
        if i in haystack
           push!(positions,p)
        end
    end
    return positions

end


#
#                          EDGES
#
# Find elements / Edges of elements of type - etype - using 
# nodesgroup information.
# 
#
# ne, types, connect and tags are obtained using ReadMesh
# 
# nodesgroup is obtained using Readnodesgroup
#
function FindElementsEdges(etype, ne, types, connect, tags, nodesgroup)

    # For all elements of type - etype -
    # check if the element has nodes in nodesgroup

    # List of elements
    list_elements = Int[]

    # List of edges
    list_edges = Int[]

    # Number of nodes per edge of - etype - 
    nE = Lgmsh_nodesedges()[etype]

    # Loop over all elements
    for i in LinearIndices(types)
        
        # Check if element is of type - etype - 
        if types[i]==etype

            # Check if nodesgroup contains nface
            # nodes of this element
            positions = Vector_match(connect[i,:],nodesgroup)

            # Check if it is compatible with nE
            if length(positions)==nE

                # Store element
                push!(list_elements,i)

                # Find the edge
                

            end

        end # if 

    end # i
    

end