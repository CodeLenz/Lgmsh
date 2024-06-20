@testset "Lgmsh_export_vector" begin

    # Basic testing 
    # One triangle (type 2)
    # One quad (type 3)
    #
    #
    filename = "test1.pos"

    # Number of nodes
    nn = 5

    # Dimension
    dim = 2

    # Two dimensional vector for each node
    vector = rand(dim*nn) 

    # Create view
    @test Lgmsh_export_nodal_vector(filename,vector,dim,"Nodal vector 2D")           

    # Same view, 3D

    # Dimension
    dim = 3

    # Three dimensional vector for each node
    vector = rand(dim*nn) 

    # Create view
    @test Lgmsh_export_nodal_vector(filename,vector,dim,"Nodal vector 3D")           
end
