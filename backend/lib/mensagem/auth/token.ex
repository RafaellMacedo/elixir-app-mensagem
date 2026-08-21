defmodule Mensagem.Auth.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims()
  end

  def generate(user) do
    extra_claims = %{
      "user_id" => user.id,
      "email" => user.email
    }

    generate_and_sign(extra_claims, signer())
  end

  def signer do
    Joken.Signer.create(
      "HS256",
      System.get_env("JWT_SECRET")
    )
  end
end