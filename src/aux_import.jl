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

# ne, types, connect and tags are obtained using ReadMesh. Element
# numbers are ours, not internal gmsh numbers. 
# 
# nodesgroup is obtained by using Readnodesgroup
#
#
# Example:
#
# nn,ne,coord,etypes,connect,etags = Readmesh(filename,[3])
# nodesgroup = Readnodesgroup(filename,gname)
# eles,edges = FindElementsEdges(3, ne, etypes, connect, nodesgroup)
#
function FindElementsEdges(etype, ne, types, connect, nodesgroup)

    # For all elements of type - etype -
    # check if the element has nodes in nodesgroup

    # List of elements
    list_elements = Int[]

    # List of edges
    list_edges = Int[]

    # Number of nodes per edge of - etype - 
    nE = Lgmsh_nodesedges()[etype]

    # Nodes at each edge (in order)
    nodes = Lgmsh_listnodesedges()[etype]
    nnodes = size(nodes,1)
    
    # Loop over all elements
    for i in LinearIndices(types)
        
        # Check if element is of type - etype - 
        if types[i]==etype

            # Check if nodesgroup contains nface
            # nodes of this element
            positions = Vector_match(connect[i,:],nodesgroup)

            # sort it
            sort!(positions) 

            # Check if it is compatible with nE
            if length(positions)==nE

                # Store element
                push!(list_elements,i)

                # Find the edge
                for k=1:nnodes
                    no = sort(nodes[k,:])
                    if all(positions.==no)
                       push!(list_edges,k)
                       break
                    end
                end #k
            
            end #if

        end # if 

    end # i
    
    return list_elements, list_edges

end




# ne, types, connect and tags are obtained using ReadMesh. Element
# numbers are ours, not internal gmsh numbers. 
# 
# nodesgroup is obtained using Readnodesgroup
#
# 
# Example:
#
# nn,ne,coord,etypes,connect,etags = Readmesh(filename,[3])
# nodesgroup = Readnodesgroup(filename,gname)
# eles,faces = FindElementsFaces(3, ne, etypes, connect, nodesgroup)
#
#
#
function FindElementsFaces(etype, ne, types, connect, nodesgroup)

    # For all elements of type - etype -
    # check if the element has nodes in nodesgroup

    # List of elements
    list_elements = Int[]

    # List of faces
    list_faces = Int[]

    # Number of nodes per face of - etype - 
    nE = Lgmsh_nodesfaces()[etype]

    # Nodes at each face (in order)
    nodes = Lgmsh_listnodesfaces()[etype]
    nnodes = size(nodes,1)
    
    # Loop over all elements
    for i in LinearIndices(types)
        
        # Check if element is of type - etype - 
        if types[i]==etype

            # Check if nodesgroup contains nface
            # nodes of this element
            positions = Vector_match(connect[i,:],nodesgroup)

            # sort it
            sort!(positions) 

            # Check if it is compatible with nE
            if length(positions)>=nE

                # Store element
                push!(list_elements,i)

                # Find the edge
                for k=1:nnodes
                    no = sort(nodes[k,:])
                    if all(positions.==no)
                       push!(list_faces,k)
                       break
                    end
                end #k

            end #if

        end # if 

    end # i
    
    return list_elements, list_faces

end


function Test_()

        nn, coord, ne, types, connect, centroids, tags = Readmesh("geo/daniele.msh",[3])

        nodes = Readnodesgroup("geo/daniele.msh","Open")

        elefaces,faces = FindElementsFaces(3,ne,types,connect,nodes)

        eleedges,edges = FindElementsEdges(3,ne,types,connect,nodes)

    return elefaces, faces, eleedges, edges

end

