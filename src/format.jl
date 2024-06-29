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
function Stringtoarray(data::Nothing,ncol::Int64,T::Type)
    return T[]
end

#
# Convert a string to an Array of type T, with  ncol columns.
# data is a  string with the data, separated by spaces. 
# The order is line by line, separated by \n.
#
function Stringtoarray(data::String,ncol::Int64,T::Type) 

  # T must be subtype of Number
  T<:Number || error("Stringtoarray:: T must be some numeric type and not $T")

  # Split string by " "
  sep = split(data)

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
  for i=1:nrow
    for j=1:ncol

      # Information
      info = sep[cont]

      # Parse information to T
      value = try
        parse(T,info)
      catch
        error("Cannot convert $(info) to type  $T")
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
 
