@testset "Parsemsh_FEM_Solid" begin
    
  # Le a malha 
  malha = Lgmsh.Parsemsh_FEM_Solid("interfaces/viga_longa.msh",false)


  @show malha
  
  # Testa se as dimensões foram lidas corretamente
  @test malha.nn  == 1111
  @test malha.ne  == 1000
  @test malha.nfc == 1
  @test malha.nfb == 1000
  @test malha.nft == 10
  @test malha.nap == 22 

end