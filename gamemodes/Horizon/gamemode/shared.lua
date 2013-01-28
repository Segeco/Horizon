GM.Name		= "Horizon"
GM.Author	= "Bynari"
GM.Email	= ""
GM.Website  = ""

DeriveGamemode( "sandbox" )

function commas(num)

  assert (type (num) == "number" or type (num) == "string")
  
  local result = ""
  local sign, before, after =
    string.match (tostring (num), "^([%+%-]?)(%d*)(%.?.*)$")

  while string.len (before) > 3 do
    result = "," .. string.sub (before, -3, -1) .. result
    before = string.sub (before, 1, -4)
  end

  return sign .. before .. result .. after

end

function ActiveB2S(bool)
	if (bool ~= 1) then
		return "Stopped"
	else
		return "Running..."
	end
end