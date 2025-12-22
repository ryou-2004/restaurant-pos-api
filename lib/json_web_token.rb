class JsonWebToken
  # JWTトークンの有効期限（24時間）
  TOKEN_EXPIRATION = 24.hours

  class << self
    # JWTトークンをエンコード
    def encode(payload, exp = TOKEN_EXPIRATION.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret_key, 'HS256')
    end

    # JWTトークンをデコード
    def decode(token)
      decoded = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })[0]
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      nil
    end

    private

    def secret_key
      ENV['JWT_SECRET'] || Rails.application.credentials.secret_key_base
    end
  end
end
