#
# Convert array to string
#
function Arraytostring(A::Array)

    # Initiate output string
    outp = ""
    
    # Dimensions
    nl,nc = size(A)
    
    # Loop over each line
    for l=1:nl
      for c=1:nc
          outp = outp*string(A[l,c])*" "
      end
      # newline
      outp = outp*"\n"
    end
    
    # Skip last \n
    return outp[1:end-2]

 end

 #=

 title String 

 version: String

 Data: String

 coordinates: 

   x  y  [z]

 connectivities: 

   type mat_id geo_id n1 n2 ... nn

 nodal bc: 

   node DOF value 
 
 mpc:

   node1 DOF node2 DOF value
 
 mat:
    -mat_id 
     model: value 
     Ex: value
     Ey: value
     Ez: value
     ....

 geo:
   
    -geo_id 
     model: value 
     thick: value
     A: value
     Iz: value
     ....

options:
  
   :IS_TOPO: 


 =#