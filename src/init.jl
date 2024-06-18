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
function Lgmsh_init(filename::String,nn::T,ne::T,coord::Array{F},
                    etype::Vector{T},connect::Array{T}) where {T,F}

    # If file exists, delete it
    if isfile(filename); rm(filename); end

    # Open for writing
    outp = open(filename,"a")

    # Node mapping
    nos = Lgmsh_nodemap()

    # length of previous list
    lnos = length(nos)

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
