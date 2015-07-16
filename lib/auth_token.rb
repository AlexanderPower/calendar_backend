module AuthToken
  SECRET = 'my_secret'
  
  def AuthToken.issue_token(payload)
    JWT.encode(payload, SECRET)
  end

  def AuthToken.valid?(token)
    begin
      decoded_token= JWT.decode(token, SECRET)
      #p decoded_token
      decoded_token
    rescue
      false
    end
  end
end
