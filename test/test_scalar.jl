@testset "Lgmsh_scalar" begin

    # Basic testing 
    # One triangle (type 2)
    # One quad (type 3)
    #
    #
    filename = "test1.pos"

    # Nodal scalar view for the 5 nodes
    nodal = rand(5)  

    # Create view
    @test Lgmsh_nodal_scalar(filename,nodal,"Nodal scalar")           

    # Element scalar view for the 2 elements
    element = rand(2)
    
    # Create view
    @test Lgmsh_element_scalar(filename,element,"Element scalar")           

end
