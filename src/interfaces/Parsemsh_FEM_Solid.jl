#
# Lê um arquivo .msh, gerado pelo gmsh e devolve as informações da malha em uma estrutura de dados 
#
#
struct Mesh_FEM_Solid

    # Número de nós
    nn::Int64

    # Número de elementos
    ne::Int64

    # Número de forças concentradas
    nfc::Int64

    # Número de forças de corpo 
    nfb::Int64

    # Número de forças de contorno
    nft::Int64

    # Número de apoios 
    nap::Int64

    # coordenadas dos nós [X1 Y1 Z1 
    #                       .... ]
    coord::Matrix{Float64}

    # conectividades  [tipo  material  no1, no2 .... non ;
    #                                ....                       ]
    connect::Matrix{Int64}

    # Propriedades dos materiais 
    #
    #  materials -> [ E ν ρ ;        (id do material é a linha desta matriz...)
    #                  ....  ]
    materials::Matrix{Float64} 

    # Forças concentradas
    #   
    #  FC -> [no dir valor ; 
    #           ....  ] 
    #
    FC::Matrix{Float64}

    # Forças de corpo 
    #
    # FB -> [ele dir valor ;
    #             ....   ]
    #
    FB::Matrix{Float64}

    # Forças distribuídas no contorno 
    #
    # FT -> [ele face vn vt1 vt2 ;
    #            ....   ] 
    #
    FT::Matrix{Float64}

    #
    #  AP -> [no dir valor ;
    #              ...    ]
    #
    AP::Matrix{Float64}

end

#
# Lê um arquivo .msh gerado pelo Gmsh e devolve a estrutura Mesh_FEM_Solid 
# com os dados processados da malha.
#
# Eduardo Lenz 
#
# Physical groups que esta rotina consegue processar
#
# Definição de material 
#
#         Material,nome,id,E,ν,ρ
#
# Forças concentradas
#
#         Fc, dir, valor  
#
# Definição de forças de corpo 
#
#          Fb, dir , valor
# 
# Forças de contorno 
#
#          Ft, valor_n, valor_t1, valor_t2 (N/m^2) 
#
# Apoios
#
#          U, gl, valor 
#
# 
# Dados/Formato de saída
#

#
 
function Parsemsh_FEM_Solid(meshfile::String,verbose=false)
 
    # Primeiro precisamos definir se a malha é 2D ou 3D
    elist = Lgmsh_import_etypes(meshfile)

    # Se tivermos elementos do 4/5/7, então é 3D. Do contrário,
    # é 2D. Observe que ter 2/3 não é uma indicação direta de 
    # que a malha é 2D, pois o gmsh também gera esses elementos
    # para malhas 3D.
    dimensao = 2
    et = [2,3]
    if (4 in elist) || (5 in elist) || (7 in elist)
        dimensao = 3
        et = [4,5,7]
    end

    if verbose
        println("Solucionando um problema de dimensão $dimensao")
    end

    # Maior número de nós entre todos os elementos da malha 
    nmax_nodes = maximum(Lgmsh_nodemap()[et])

    # Leitura da malha
    nn, coord, ne, etypes, connect, etags = Readmesh(meshfile,et)

    # Le todos os grupos físicos do arquivo 
    pgroups, pgnames = Lgmsh_import_physical_groups(meshfile)

    #
    # Definições que dependem dos tipos lidos e das saídas
    #

    # Vetor com dicionários de materiais 
    materiais = Dict{String,Union{String,Float64,Int64,Vector{Int64}}}[]

    # Dicionário local para utilizar dento do loop 
    localD_m = Dict{String,Union{String,Float64,Int64,Vector{Int64}}}()

    # Vetor de dicionários para as forças concentradas
    forcas_concentradas = Dict{String,Union{Float64,Int64,Vector{Int64}}}[]

    # Dicionário local para utilizar dentro do loop
    localD_forcas_concentradas = Dict{String,Union{Float64,Int64,Vector{Int64}}}()

    # Vetor de dicionários para as forças de corpo
    forcas_corpo = Dict{String,Union{Float64,Int64,Vector{Int64}}}[]

    # Dicionário local para utilizar dentro do loop
    localD_forcas_corpo = Dict{String,Union{Float64,Int64,Vector{Int64}}}()

    # Vetor de dicionários para as forças de contorno
    forcas_contorno = Dict{String,Union{Float64,Int64,Matrix{Int64}}}[]

    # Dicionário local para utilizar dentro do loop
    localD_forcas_contorno = Dict{String,Union{Float64,Int64,Matrix{Int64}}}()

    # Vetor de dicionários para os apoios
    apoios = Dict{String,Union{Float64,Int64,Vector{Int64}}}[]

    # Dicionário local para utilizar dentro do loop
    localD_apoios = Dict{String,Union{Float64,Int64,Vector{Int64}}}()

     
    # Máximo id de um material 
    max_id = 0

    #
    # FIM DAS DEFINIÇÕES
    #
    

    #
    # Loop por todos os grupos físicos da malha
    #
    for g in LinearIndices(pgnames)

      # Nome do grupo
      name = pgnames[g]

      # Separa a string por  ","
      st = split(name,",")

      # Verifica se é material 
      #
      # MATERIAL,nome,id,E,ν -> mapeia para elementos
      #
      if occursin("Material",st[1])

            # Limpa o dicionário local 
            empty!(localD_m)

            # O nome do material é a segunda entrada, mas não vamos usar para nada...
            nome = String(st[2])

            # Dados esperados
            # nome, id, E, ν
            id   = parse(Int64,st[3])
            E    = parse(Float64,st[4])
            ν    = parse(Float64,st[5])
            ρ    = parse(Float64,st[6])

            # Monta o vetor local 
            localD_m["name"] = nome
            localD_m["id"]   = id
            localD_m["E"]    = E
            localD_m["ν"]    = ν
            localD_m["ρ"]    = ρ
          
            # Armazena o id máximo 
            max_id = max(max_id,id) 

            # Agora vamos encontrar quais elementos estão associados e este grupo 
            elems_domain = Lgmsh.Readelementsgroup(meshfile,name,etags)

            # E armazenar no dicionário em ordem crescente
            localD_m["elements"] = sort(elems_domain)

            # Copia o dicionário local para o vetor de dicionários
            push!(materiais,copy(localD_m))

       #
       # Forças concentradas 
       #
       # FORCA,dir,valor -> mapeia para nós
       #
       elseif  occursin("Fc",st[1])

            # Limpa o dicionário local 
            empty!(localD_forcas_concentradas)

            # dir e valor
            localD_forcas_concentradas["dir"]    = parse(Float64,st[2])
            localD_forcas_concentradas["val"]  = parse(Float64,st[3])
            
            # Encontra os nós
            nodes_forcas_local = Lgmsh.Readnodesgroup(meshfile,name)

            # Adiciona o vetor de nós no dicionário
            localD_forcas_concentradas["nodes"] = nodes_forcas_local

            # Copia o dicionário para o vetor de forças concentradas
            push!(forcas_concentradas,copy(localD_forcas_concentradas))


      #
      # Forças de corpo
      #
      # Fb,dir,valor -> mapeia para elementos 
      #
      #
      elseif  occursin("Fb",st[1])

            # Limpa o dicionário local 
            empty!(localD_forcas_corpo)

            # dir e valor
            localD_forcas_corpo["dir"]    = parse(Float64,st[2])
            localD_forcas_corpo["val"]  = parse(Float64,st[3])
            
            # Agora vamos encontrar quais elementos estão associados e este grupo 
            elems_domain = Lgmsh.Readelementsgroup(meshfile,name,etags)

            # E armazenar no dicionário em ordem crescente
            localD_forcas_corpo["elements"] = sort(elems_domain)

            # Copia o dicionário local para o vetor de dicionários
            push!(forcas_corpo,copy(localD_forcas_corpo))


      #
      #  Ft, valor_n, valor_t1, valor_t2 (N/m^2)  -> mapeia para faces/arestas de elementos
      #
      elseif  occursin("Ft",st[1])

            # Limpa o dicionário local 
            empty!(localD_forcas_contorno)

            # Valor
            localD_forcas_contorno["normal"] = parse(Float64,st[2])
            localD_forcas_contorno["tan1"] = parse(Float64,st[3])
            localD_forcas_contorno["tan2"] = parse(Float64,st[4])
            
            # Encontra os nós 
            nodes_forcas_contorno = Lgmsh.Readnodesgroup(meshfile,name)

            # Encontra elementos e arestas/faces
            eleedges = Int64[]
            edges = Int64[]
            for tt in et
                if dimensao==2
                   eleedges_,edges_ = FindElementsEdges(tt,ne,etypes,connect,nodes_forcas_contorno)
                else
                   eleedges_,edges_ = FindElementsFaces(tt,ne,etypes,connect,nodes_forcas_contorno)
                end
                push!(eleedges,eleedges_...)
                push!(edges,edges_...)
            end
            
            # Adiciona elementos e faces
            localD_forcas_contorno["elements"] = [eleedges edges]

            # Copy the dict to the vector of dampings
            push!(forcas_contorno,copy(localD_forcas_contorno))

       #
       # Apoios
       #
       # U,dir,valor -> mapeia para nós
       #
       elseif  occursin("U",st[1])

        # Limpa o dicionário local 
        empty!(localD_apoios)

        # dir e valor
        localD_apoios["dir"]    = parse(Float64,st[2])
        localD_apoios["val"]  = parse(Float64,st[3])
        
        # Encontra os nós
        nodes_apoios = Lgmsh.Readnodesgroup(meshfile,name)

        # Adiciona o vetor de nós no dicionário
        localD_apoios["nodes"] = nodes_apoios

        # Copia o dicionário para o vetor de apoios
        push!(apoios,copy(localD_apoios))


      end #if

    end  # Loop principal

    
    ################################################################################
    #                     Pós-processa para o formato de saída 
    ################################################################################

     
    #
    # Vamos processar os dados que extraimos do arquico
    #
    # Cada linha é um elemento. Primeira coluna tem o tipo de elemento 
    # a segunda coluna o id do material e daí para frente, os nós do elemento
    #
    # Como podemos ter elementos diferentes, alocamos pelo número máximo de nós
    # dos elementos da malha
    #
    connect2 = zeros(Int64,ne,nmax_nodes+2)

    # Algumas informações nós já temos
    connect2[:,1]     .= etypes
    connect2[:,3:end] .= connect

    # Vamos processar os materiais como uma matriz
    # cada linha de materials2 é um material com id com E, ν, ρ
    #
    # A segunda coluna de conect2 vai ter o id do material do elemento 
    #
    materiais2 = zeros(max_id,3)
   
    # Loop sobre os materiais que foram informados
    for mat in materiais

        # id do material 
        id = mat["id"]

        # elementos com este material 
        elements = mat["elements"]
        
        # Copy
        connect2[elements,2] .= id

        # Copia os valores 
        v = [mat["E"] mat["ν"] mat["ρ"]]

        # preenche a linha de materiais2
        materiais2[id,:] = v
         
    end

    #
    #                              Processa forças concentradas
    #
    # Começa calculando o número de informações (nós) somando todas as entradas
    # em forcas_concentradas
    nfc = 0
    for f in forcas_concentradas
        nfc += length(f["nodes"])
    end #f 

    # Com isso, podemos alocar a matriz de saída 
    # nó dir valor
    FC = zeros(nfc,3)

    # Novo loop pelas informações de f
    ini = 1
    for f in forcas_concentradas

        # Nós 
        nos = f["nodes"]

        # Número de nós 
        nn_f = length(nos)

        # Linha final da informação
        fim = ini+nn_f-1

        # Direção 
        dir = f["dir"]

        # valor 
        val = f["val"]

        # Posiciona na matriz FC
        FC[ini:fim,1] .= nos
        FC[ini:fim,2] .= dir
        FC[ini:fim,3] .= val

        # Realoca a posição inicial
        ini = ini + fim

    end #f
   
    #
    #                                 Processa forças de corpo
    #
    # Começa calculando o número de informações (nós) somando todas as entradas
    # em forcas_corpo
    nfb = 0
    for f in forcas_corpo
        nfb += length(f["elements"])
    end #f 

    # Com isso, podemos alocar a matriz de saída 
    # ele dir valor
    FB = zeros(nfb,3)

    # Novo loop pelas informações de f
    ini = 1
    for f in forcas_corpo

        # Elementos
        elementos = f["elements"]

        # Número de elementos 
        ne_b = length(elementos)

        # Linha final da informação
        fim = ini+ne_b-1

        # Direção 
        dir = f["dir"]

        # valor 
        val = f["val"]

        # Posiciona na matriz FB
        FB[ini:fim,1] .= elementos
        FB[ini:fim,2] .= dir
        FB[ini:fim,3] .= val

        # Realoca a posição inicial
        ini = ini + fim

    end #f
   
    #
    #                                 Processa carregamento no contorno
    #
    # Começa calculando o número de informações (elementos) somando todas as entradas
    # em forcas_contorno
    nft = 0
    for f in forcas_contorno
        nft += size(f["elements"],1)
    end #f 

    # Com isso, podemos alocar a matriz de saída 
    # ele face vn vt1 vt2
    FT = zeros(nft,5)

    # Novo loop pelas informações de f
    ini = 1
    for f in forcas_contorno

        # Elementos 
        elementos = f["elements"][:,1]

        # arestas/faces
        arestas = f["elements"][:,2]

        # Número de elementos 
        ne_t = length(elementos)

        # Linha final da informação
        fim = ini+ne_t-1

        # valor na direção normal
        valn = f["normal"]

        # valor na direção tangencial1
        valt1 = f["tan1"]

        # valor na direção tangencial2
        valt2 = f["tan2"]


        # Posiciona na matriz FT
        FT[ini:fim,1] .= elementos
        FT[ini:fim,2] .= arestas
        FT[ini:fim,3] .= valn
        FT[ini:fim,4] .= valt1
        FT[ini:fim,5] .= valt2
        

        # Realoca a posição inicial
        ini = ini + fim

    end #f

    #
    #                              Processa apoios
    #
    # Começa calculando o número de informações (nós) somando todas as entradas
    # em apoios
    nap = 0
    for f in apoios
        nap += length(f["nodes"])
    end #f 

    # Com isso, podemos alocar a matriz de saída 
    # nó dir valor
    AP = zeros(nap,3)

    # Novo loop pelas informações de f
    ini = 1
    for f in apoios

        # Nós 
        nos = f["nodes"]

        # Número de nós 
        nn_ap = length(nos)

        # Linha final da informação
        fim = ini+nn_ap-1

        # Direção 
        dir = f["dir"]

        # valor 
        val = f["val"]

        # Posiciona na matriz AP
        AP[ini:fim,1] .= nos
        AP[ini:fim,2] .= dir
        AP[ini:fim,3] .= val

        # Realoca a posição inicial
        ini = ini + fim

    end #f


    # Retorna os dados 
    return Mesh_FEM_Solid(nn, ne, nfc, nfb, nft, nap, coord,  connect2, materiais2,  FC,  FB,  FT,  AP)

end