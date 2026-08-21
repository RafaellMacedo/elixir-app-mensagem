defmodule Mensagem.Repo do
  use Ecto.Repo,
    otp_app: :mensagem,
    adapter: Ecto.Adapters.Postgres
end
