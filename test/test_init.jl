@testset "Lgmsh_export_init" begin

    # Basic testing 
    # One triangle (type 2)
    # One quad (type 3)
    #
    #
    filename = "test1.pos"

    # Number of nodes
    nn = 5

    # Coordinates
    coord = [0.0 0.0 ;
             1.0 0.0 ;
             1.0 1.0 ;
             0.0 1.0 ;
             0.5 2.0 ]

    # Number of elements
    ne = 2

    # Element types
    etype = [3 ; 2]

    #  connectivities
    connect = [1 2 3 4 ;
               4 3 5 0]

    # Create file
    @test Lgmsh_export_init(filename,nn,ne,coord,etype,connect)           
    
end
