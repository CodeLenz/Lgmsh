#
# Read a .msh file and look for  elements of a given list
#
function Readmesh(filename::String, elist::Vector{Int})

    # To avoid printing gmsh output
    redirect_stdout(open(tempname(), "w")) do

        # Nodes and coordinates
        nn, norder, coord = Lgmsh_import_coordinates(filename)

        # Nodes per element
        npe = Lgmsh_nodemap()

        # Maximum number of nodes per element in this mesh
        nnmax = 0 #maximum(npe[elist])

        # Something very, very stupid
        ne = 0
        for e in elist

            # Number of elements of this type in the mesh
            ne_e, _ = Lgmsh_import_element_by_type(filename,e,false)

            # If there are elements of this type in the mesh, we add
            # to the total number 
            ne += ne_e

            # and also set the maximum number of 
            # nodes for all elements in this mesh
            if ne_e > 0 
               nnmax = max(nnmax,npe[e])
            end
            
            
        end

        # basic test
        if ne==0
            error("There are no elements of types $(elist) in this mesh")
        end

        # Allocate the array of connectivities
        connect = zeros(Int64,ne,nnmax)

        # Allocate the array of types
        types = zeros(Int64,ne)

        # Allocate the array of centroids
        centroids = zeros(ne,3)

        #
        # Dictionary with the original tag and the new
        # element number
        #
        tags = Dict{Int,Int}()
       
        # Loop over elist AGAIN 
        offset = 0
        cont = 1
        for e in elist

            # Recover data from each type of element
            ne_e, tags_e, connect_e = Lgmsh_import_element_by_type(filename,e,false)

            # Recover the centroids for this element type
            cent =  Lgmsh_import_centroids(filename,e)

            # Skip if ne_e is zero (no element of this type)
            if ne_e > 0 

                # Number of nodes per element in this particular type
                nne = npe[e]

                # Append connectivities
                connect[offset+1:offset+ne_e,1:nne] .= connect_e

                # Append types
                types[offset+1:offset+ne_e] .= e 

                # Centroids
                centroids[offset+1:offset+ne_e,:] .= cent

                # Silly dict build
                for i=1:ne_e
                    tags[tags_e[i]] = cont
                    cont += 1
                end

                # Adjust the offset
                offset += ne_e

            else
                println("Warning: No elements of type $e in this file.")
            end
                
        end

        # Return mesh data
        return nn, coord, ne, types, connect, centroids, tags

    end

   
end

#
# Recover all nodes from a given NAME of Physical Groups
# 
function Readnodesgroup(filename::String,group::String)

    # To avoid printing gmsh output
    redirect_stdout(open(tempname(), "w")) do

        # Find tuples associated to this guy
        V  = Lgmsh_import_entities_physical_group(filename,group)

        # For each pair, get the nodes and add to list
        list = Int[]

        # Loop over pairs
        for pair in V

        # Get the nodes
        nodes = Lgmsh_import_nodes_tuple(filename,pair[1],pair[2])
        
        # Append to the list
        list = vcat(list,nodes)

        end

        # Return the list
        return list

    end 

end


#
# Recover all elements from a given NAME of Physical Groups
# 
function Readelementsgroup(filename::String,group::String,tags::Dict{Int,Int})

    # To avoid printing gmsh output
    redirect_stdout(open(tempname(), "w")) do

        # Find tuples associated to this guy
        V  = Lgmsh_import_entities_physical_group(filename,group)

        # For each pair, get the elements and add to list
        list = Int[]

        # Loop over pairs
        for pair in V

            # Get the nodes
            etypes,etags = Lgmsh_import_elements_tuple(filename,pair[1],pair[2])

            # We do not care with the element type 
            for i=1:length(etypes) 

                # Element tags
                inttags = Int.(etags[i])

                # Convert tags using the dictionary
                conv = [tags[i] for i in inttags]

                # Append
                list = vcat(list,conv)

            end #i

        end

        # Return the list
        return list
        
    end
end

