"""
Export a nodal vectorial view to gmsh

    Lgmsh_nodal_vector(filename::String,vector::Vector,  
                       dim::Int, viewname::String,time=0.0)

    vector should be dim*nn where dim = 2 or 3 and nn is the
    number of nodes.

"""
function Lgmsh_nodal_vector(filename::String,vector::Vector,dim::Int,
                            viewname::String,time=0.0)

  
    # Try to open the file
    outp = try
                open(filename,"a")
    catch
        error("ERROR::Lgmsh_nodal_vector:: Cannot open file $filename")
    end

    # Number of nodes
    nn = try
        Int(length(vector)/dim)
    catch
        error("ERROR::Lgmsh_nodal_vector:: there is something wrong with the dimensions")
    end

    #
    #
    println(outp,"\$NodeData")
    println(outp,"1")
    println(outp,"\" $viewname\"")
    println(outp,"1")
    println(outp,time)
    println(outp,"3")
    println(outp,"0")
    println(outp,"3")
    println(outp,nn)
    for no=1:nn
        pos1 = dim*(no-1)+1; val1 = vector[pos1]
        pos2 = dim*(no-1)+2; val2 = vector[pos2]
        val3 = 0.0
        if dim==3
            pos3 = dim*(no-1)+3; val3 = vector[pos3]
        end 
        println(outp,no," ",val1," ",val2," ",val3 )
    end
    println(outp,"\$EndNodeData")

    # close the file
    close(outp)

    # return true for testing
    return true

end
