#
# Cria o cabecalho com informacoes da malha para posterior adicao de vistas com saidas
#
# filename -> string com o nome do arquivo a ser criado. Se já existe, é deletado
# nn -> número de nós
# ne -> número de elementos
# coord -> array com nn linhas e 2 ou 3 colunas, com as coordenadas x, y e z (opcional)
# etypes -> vetor com ne linhas e com o tipo de cada elemento (mais detalhes abaixo)
# connect -> array de inteiros com ne linhas e um número de colunas equivalente ao 
#            tipo de elemento da malha atual com mais nós em sua conectividade
#
#
# os etypes são os do gmsh (https://gmsh.info/dev/doc/texinfo/gmsh.pdf)
#
# 1  2-node line.
# 2  3-node triangle.
# 3  4-node quadrangle.
# 4  4-node tetrahedron.
# 5  8-node hexahedron.
# 6  6-node prism.
# 7  5-node pyramid.
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
#
function Lgmsh_init(filename::String,nn::T,ne::T,coord::Array{F},
                    etype::Vector{T},connect::Array{T}) where {T,F}

    # If file exists, delete it
    if isfile(filename); rm(filename); end

    # Open for writing
    outp = open(filename,"a")

    # Map each element code to the number of nodes
    nos = [2;3;4;4;8;6;5;3;6;9;10;27;18;14;1;8;20;15;13;9;10;12;15;15;21;4;5;6;20;35;56]

    # length of previous list
    lnos = 31

    # If user provided just 2 columns in coord, we add a third row with zeros
    if size(coord,2)==2
        coord = [coord zeros(nn)] 
    end

    # Assert that no information in etype is outside the bounds 1 and length(nos)
    minimum(etype)>=1 && maximum(etype)<=lnos || throw("Lgmsh_init::etype must be in [1,$lnos]")

    #
    # Header
    #
    println(outp,"\$MeshFormat")
    println(outp,"2.2 0 8")
    println(outp,"\$EndMeshFormat")

    #
    # Nodes - coordinates
    #
    println(outp,"\$Nodes")
    println(outp,nn)
    for i=1:nn
        println(outp,i," ",coord[i,1]," ",coord[i,2]," ",coord[i,3])
    end
    println(outp,"\$EndNodes")

    #
    # Connectivities
    #
    println(outp,"\$Elements")
    println(outp,ne)
    for i=1:ne 
        tipo = etype[i]
        con = string(i)*" "*string(tipo)*" 0 "*string(connect[i,1])
        for j=2:nos[tipo]
            con = con * " " * string(connect[i,j])
        end
        println(outp,con)
    end
    println(outp,"\$EndElements")

    # Close the file
    close(outp)

    # Return true for testing purposes
    return true

end 
