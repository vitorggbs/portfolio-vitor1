require "sinatra"
require "json"
require "resend"
require "dotenv/load"

set :host_authorization, {
  permitted_hosts: [
    "vitorgabriel.up.railway.app",
    "web-production-d4805b.up.railway.app"
  ]
}

set :public_folder, __dir__
set :static, false
set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 4567)

before do
  headers "Cache-Control" => "no-store"
end

get "/" do
  send_file File.join(settings.public_folder, "index.html")
end

get "/:arquivo" do
  arquivos = %w[
    style.css
    loader-style.css
    animations.css
    contact.css
    script.js
  ]

  halt 404 unless arquivos.include?(params[:arquivo])

  send_file File.join(settings.public_folder, params[:arquivo])
end

get "/assets/:arquivo" do
  imagens = %w[
    foto-vitor.jpg
    farmacerta.png
    site-namorados.png
  ]

  halt 404 unless imagens.include?(params[:arquivo])

  send_file File.join(settings.public_folder, "assets", params[:arquivo])
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

  Resend.api_key = ENV.fetch("RESEND_API_KEY")

  Resend::Emails.send({
    "from" => "Portfólio Vitor <onboarding@resend.dev>",
    "to" => [ENV.fetch("CONTACT_DESTINATION")],
    "reply_to" => email,
    "subject" => "Novo contato do portfólio - #{nome.gsub(/[\r\n]/, " ")}",
    "text" => "Nome: #{nome}\nNúmero: #{numero}\nE-mail: #{email}\n\nMotivo:\n#{motivo}"
  })

  { mensagem: "Mensagem enviada com sucesso." }.to_json
rescue JSON::ParserError
  status 400
  { erro: "Os dados enviados são inválidos." }.to_json
rescue StandardError => erro
  warn "Erro ao enviar contato: #{erro.class} - #{erro.message}"
  status 500
  { erro: "Não foi possível enviar agora. Tente novamente." }.to_json
end
