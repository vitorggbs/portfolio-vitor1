require "sinatra"
require "json"
require "mail"
require "dotenv/load"

set :public_folder, __dir__
set :static, true
set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 4567)

get "/" do
  send_file File.join(settings.public_folder, "index.html")
end

post "/contato" do
  content_type :json

  dados = JSON.parse(request.body.read)

  nome = dados["nome"].to_s.strip
  numero = dados["numero"].to_s.strip
  email = dados["email"].to_s.strip
  motivo = dados["motivo"].to_s.strip

  if dados["website"].to_s != ""
    return { mensagem: "Mensagem enviada." }.to_json
  end

  if nome.empty? || numero.empty? || email.empty? || motivo.empty?
    status 422
    return { erro: "Preencha todos os campos." }.to_json
  end

  unless email.match?(/\A[^\s@]+@[^\s@]+\.[^\s@]+\z/)
    status 422
    return { erro: "Informe um e-mail válido." }.to_json
  end

  if nome.length > 80 || numero.length > 20 || email.length > 120 || motivo.length > 1500
    status 422
    return { erro: "Um dos campos ficou grande demais." }.to_json
  end

  Mail.defaults do
    delivery_method :smtp,
      address: ENV["SMTP_ADDRESS"],
      port: ENV.fetch("SMTP_PORT", 587).to_i,
      domain: ENV["SMTP_DOMAIN"],
      user_name: ENV["SMTP_USERNAME"],
      password: ENV["SMTP_PASSWORD"],
      authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain"),
      enable_starttls_auto: ENV.fetch("SMTP_ENABLE_STARTTLS", "true") == "true"
  end

  Mail.deliver do
    from ENV["SMTP_USERNAME"]
    to ENV["CONTACT_DESTINATION"]
    reply_to email
    subject "Novo contato do portfólio - #{nome.gsub(/[\r\n]/, " ")}"
    body "Nome: #{nome}\nNúmero: #{numero}\nE-mail: #{email}\n\nMotivo:\n#{motivo}"
  end

  { mensagem: "Mensagem enviada com sucesso." }.to_json
rescue JSON::ParserError
  status 400
  { erro: "Os dados enviados são inválidos." }.to_json
rescue StandardError => erro
  warn erro.message
  status 500
  { erro: "Não foi possível enviar agora. Tente novamente." }.to_json
end
