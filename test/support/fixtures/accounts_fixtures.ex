defmodule PapaChallenge.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PapaChallenge.Accounts` context.
  """

  @doc """
  Generate a user.
  """

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> PapaChallenge.Accounts.register_user()

    user
  end

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      first_name: "Bob",
      last_name: "Robert",
      balance_in_minutes: 60,
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
