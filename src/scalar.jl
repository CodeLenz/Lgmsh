"""
Export a nodal scalar view to gmsh post processing

    Lgmsh_export_nodal_scalar(filename::String,scalars::Vector,
                      viewname::String,time=0.0)

"""
function Lgmsh_export_nodal_scalar(filename::String,scalars::Vector,
                            viewname::String,time=0.0)

    # Vector length
    nn = length(scalars)

    # Try to open file for append
    outp = try
         open(filename,"a")
    catch
        error("ERROR::Lgmsh_export_nodal_scalar:: cannot open  $filename. Try to create such file using Lgmsh_export_init")
    end

    #
    # Header
    #
    println(outp,"\$NodeData")
    println(outp,"1")
    println(outp,"\" $viewname \"")
    println(outp,"1")
    println(outp,time)
    println(outp,"3")
    println(outp,"0")
    println(outp,"1")
    println(outp,nn)

    # 
    # Data
    #
    for i=1:nn
        println(outp,i," ",scalars[i])
    end
    println(outp,"\$EndNodeData")

    # Close by now
    close(outp)

    # return true for testing
    return true

end

"""
Export an element (centroidal) scalar view to gmsh post processing

    Lgmsh_export_element_scalar(filename::String,scalars::Vector,
                         viewname::String,time=0.0)


"""
function Lgmsh_export_element_scalar(filename::String,scalars::Vector,
                                     viewname::String,time=0.0)


    # Length
    ne = length(scalars)

    # Try to open file for append
    outp = try
                open(filename,"a")
    catch
        error("ERROR::Lgmsh_export_element_scalar:: Cannot open file $filename. Try to create such file using Lgmsh_export_init")
    end


    #
    # Header
    #
    println(outp,"\$ElementData")
    println(outp,"1")
    println(outp,"\" $viewname\"")
    println(outp,"1")
    println(outp,time)
    println(outp,"3")
    println(outp,"0")
    println(outp,"1")
    println(outp,ne)

    #
    # Data
    #
    for i=1:ne
        println(outp,i," ",scalars[i])#,digits=15))
    end
    println(outp,"\$EndElementData")

    # Close the file
    close(outp)

    # return true for testing
    return true

end