@testset "Parsemsh_FEM_Solid" begin
    
  # Le a malha 
  redirect_stdout(open(tempname(), "w")) do
      malha = Lgmsh.Parsemsh_FEM_Solid("interfaces/viga_longa.msh",false)
  
  
    # Testa se as dimensões foram lidas corretamente
    @test malha.nn  == 1111
    @test malha.ne  == 1000
    @test malha.nfc == 1
    @test malha.nfb == 1000
    @test malha.nft == 10
    @test malha.nap == 22 


    # Distributed load
    @test all(malha.FT .== [124.0 1.0 10.0 0.0 0.0; 
                            154.0 2.0 10.0 0.0 0.0;
                            437.0 3.0 10.0 0.0 0.0;
                            440.0 4.0 10.0 0.0 0.0;
                            479.0 2.0 10.0 0.0 0.0; 
                            539.0 1.0 10.0 0.0 0.0;
                            614.0 2.0 10.0 0.0 0.0;
                            915.0 2.0 10.0 0.0 0.0; 
                            936.0 3.0 10.0 0.0 0.0; 
                            970.0 1.0 10.0 0.0 0.0])

    # Supports
    @test all(malha.AP .== [212.0 1.0 0.0; 
                            213.0 1.0 0.0;
                            214.0 1.0 0.0;
                            215.0 1.0 0.0; 
                            216.0 1.0 0.0; 
                            217.0 1.0 0.0; 
                            218.0 1.0 0.0;
                            219.0 1.0 0.0; 
                            220.0 1.0 0.0; 
                            4.0 1.0 0.0;
                            1.0 1.0 0.0;
                            212.0 2.0 0.0; 
                            213.0 2.0 0.0; 
                            214.0 2.0 0.0;
                            215.0 2.0 0.0; 
                            216.0 2.0 0.0; 
                            217.0 2.0 0.0; 
                            218.0 2.0 0.0;
                            219.0 2.0 0.0; 
                            220.0 2.0 0.0;
                            4.0 2.0 0.0;
                            1.0 2.0 0.0])

  end
end