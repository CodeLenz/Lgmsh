
# ATUALMENTE TENHO DEFINIDOS OS ELEMENTOS DE 1 até 7

# os etypes são os do gmsh (https://gmsh.info/dev/doc/texinfo/gmsh.pdf)
#
# 1  2-node line.
# 2  3-node triangle.
# 3  4-node quadrangle.
# 4  4-node tetrahedron.
# 5  8-node hexahedron.
# 6  6-node prism.
# 7  5-node pyramid.
#
#
# 8  3-node second order line (2 nodes associated with the vertices and 1 with the edge).
# 9  6-node second order triangle (3 nodes associated with the vertices and 3 with the edges).
# 10 9-node second order quadrangle (4 nodes associated with the vertices, 4 with the
#    edges and 1 with the face).
# 11 10-node second order tetrahedron (4 nodes associated with the vertices and 6 with
#    the edges).
# 12 27-node second order hexahedron (8 nodes associated with the vertices, 12 with the
#    edges, 6 with the faces and 1 with the volume).
# 13 18-node second order prism (6 nodes associated with the vertices, 9 with the edges
#    and 3 with the quadrangular faces).
# 14 14-node second order pyramid (5 nodes associated with the vertices, 8 with the
#    edges and 1 with the quadrangular face).
# 15 1-node point.
# 16 8-node second order quadrangle (4 nodes associated with the vertices and 4 with
#    the edges).
# 17 20-node second order hexahedron (8 nodes associated with the vertices and 12 with
#    the edges).
# 18 15-node second order prism (6 nodes associated with the vertices and 9 with the
#    edges).
# 19 13-node second order pyramid (5 nodes associated with the vertices and 8 with the
#    edges).
# 20 9-node third order incomplete triangle (3 nodes associated with the vertices, 6 with
#    the edges)
# 21 10-node third order triangle (3 nodes associated with the vertices, 6 with the edges,
#    1 with the face)
# 22 12-node fourth order incomplete triangle (3 nodes associated with the vertices, 9
#    with the edges)
# 23 15-node fourth order triangle (3 nodes associated with the vertices, 9 with the edges,
#    3 with the face)
# 24 15-node fifth order incomplete triangle (3 nodes associated with the vertices, 12 with
#    the edges)
# 25 21-node fifth order complete triangle (3 nodes associated with the vertices, 12 with
#    the edges, 6 with the face)
# 26 4-node third order edge (2 nodes associated with the vertices, 2 internal to the edge)
# 27 5-node fourth order edge (2 nodes associated with the vertices, 3 internal to the  edge)
# 28 6-node fifth order edge (2 nodes associated with the vertices, 4 internal to the edge)
# 29 20-node third order tetrahedron (4 nodes associated with the vertices, 12 with the
#    edges, 4 with the faces)
# 30 35-node fourth order tetrahedron (4 nodes associated with the vertices, 18 with the
#    edges, 12 with the faces, 1 in the volume)
# 31 56-node fifth order tetrahedron (4 nodes associated with the vertices, 24 with the
#    edges, 24 with the faces, 4 in the volume)
#
# Still not using (God bless)
#
# 92 64-node third order hexahedron (8 nodes associated with the vertices, 24 with the
#    edges, 24 with the faces, 8 in the volume)
# 93 125-node fourth order hexahedron (8 nodes associated with the vertices, 36 with the
#    edges, 54 with the faces, 27 in the volume)





# Map each element code to the number of nodes
# Not defining elements 92 and 93 ...
Lgmsh_nodemap() = [2;3;4;4;8;6;5;3;6;9;10;27;18;14;1;8;20;15;13;9;10;12;15;15;21;4;5;6;20;35;56]

############## TODO - IMPROVE THE FOLLOWING VECTORS/ARRAYS ##################

# Map number of nodes in the edges of each element
Lgmsh_nodesedges() = [1;2;2;2;2]

# Nodes of each edge of each element type
function Lgmsh_listnodesedges() 
    
    # Initialize the dictionary
    nodesedges = Dict{Int,Matrix{Int}}()

    # Type 1
    nodesedges[1] = [ 1 ; 2 ;;]

    # Type 2
    nodesedges[2] =  [1 2 ; 2  3 ; 3 1 ] 
    
    # Type 3
    nodesedges[3] =  [1 2 ; 2  3 ; 3 4 ; 1 4 ] 

    # Type 4
    nodesedges[4] = [1 2 ; 2 3 ; 3 4 ; 1 4 ; 2 4 ; 3 4]

    # Type 5
    nodesedges[5] = [1 2 ; 2 3 ; 3 4 ; 1 4 ;
                     5 6 ; 6 7 ; 7 8 ; 8 5 ; 
                     1 5 ; 2 6 ; 3 7 ; 4 8 ]

    # Type 6 
    nodesedges[6] = [1 2 ; 2 3 ; 1 3  ;
                     4 5 ; 5 6 ; 6 4  ; 
                     1 4 ; 2 5 ; 3 6]
                 

    # Type 7
    nodesedges[7] = [1 2 ; 2 3 ; 3 4 ; 1 4 ;
                     1 5 ; 2 5 ; 3 5 ; 4 5 ]
 
   
    # Return the dictionary
    return nodesedges

end


# Minimum number of nodes per face      #### 
Lgmsh_nodesfaces() = [1;3;4;3;4;3;3]

# Map number of nodes in faces of each element
function Lgmsh_listnodesfaces() 
    
    # Initialize the dictionary
    nodesfaces = Dict{Int,Matrix{Int}}()

    # Type 1
    nodesfaces[1] = [ 1 2 ]

    # Type 2
    nodesfaces[2] =  [1 2 3 ] 
    
    # Type 3
    nodesfaces[3] =  [1 2 3 4 ] 

    # Type 4
    nodesfaces[4] = [1 2 3 ;
                     1 2 4 ; 
                     2 3 4 ;
                     1 3 4 ]

    # Type 5
    nodesfaces[5] = [1 2 3 4 ;
                     5 6 7 8 ;
                     1 2 6 5 ;
                     2 3 7 6 ;
                     4 3 7 8 ;
                     1 4 8 5 ]


    # Type 6
    nodesfaces[6] = [1 2 3 0 ;
                     4 5 6 0 ;
                     1 2 5 4 ;
                     2 3 6 5 ;
                     1 3 6 4 ]
                
    # Type 7
    nodesfaces[7] = [1 2 3 4;
                     1 2 5 0;
                     2 3 5 0;
                     3 4 5 0;
                     4 1 4 0]

   
    # Return the dictionary
    return nodesfaces

end

