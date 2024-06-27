#
# Convert array to string, to be used in YAML export
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

#
# Hack to account for Nothing
#
function Stringtoarray(dado::Nothing,ncol::Int64,T::Type)
    return T[]
end

#
# Convert a string to an Array of type T, with  ncol columns.
# dado is a  string with the data, separated by spaces. 
# The order is line by line, separated by \n.
#
function Stringtoarray(dado::String,ncol::Int64,T::Type)

  # Split string by " "
  sep = split(dado)

  # Check dimension
  if !(rem(length(sep),ncol)==0)
      error("Stringtoarray:: string does not have the proper dimension (must be multiple of  $col)")
  end

  # Number of lines
  nrow = div(length(sep),ncol)

  # Alloc the output array
  outp = Array{T}(undef,nrow,ncol)

  # Iterate on sep and convert to the given type.
  cont = 1
  for i=1:nwor
    for j=1:ncol

      # Information
      info = sep[cont]

      # Se T não for String, converte a informação para o tipo de dado desejado
      if T===String
        value = info
      else
        try
          value  = parse(T,info)
        catch
          error("Cannot convert $(info) to type  $T")
        end
      end
    
      # Store
      outp[i,j] = value

      # update cont
      cont += 1

    end #j
  end #i  
    
  # Return the output array
  return outp

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