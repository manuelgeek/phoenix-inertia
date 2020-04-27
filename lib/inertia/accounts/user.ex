defmodule Inertia.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Inertia.Sessions.Session

  @type t :: %__MODULE__{
          id: integer,
          email: String.t(),
          password_hash: String.t(),
          sessions: [Session.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "users" do
    field :email, :string
    field :name, :string
    field :avatar, :string
    field :img_file, :any, virtual: true
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :sessions, Session, on_delete: :delete_all

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> unique_email
  end

  def create_changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name])
    |> validate_required([:email, :password, :name])
    |> unique_email
    |> validate_password(:password)
    |> validate_confirmation(:password)
    |> put_pass_hash
  end

  defp unique_email(changeset) do
    changeset
    |> validate_format(
      :email,
      ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}$/
    )
    |> validate_length(:email, max: 255)
    |> unique_constraint(:email)
  end

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Bcrypt or Pbkdf2, change Argon2 to Bcrypt or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) >= 6 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}

  def img_changeset(user, attrs) do
    user
    |> cast(attrs, [:img_file])
    |> validate_required([:img_file])
    |> validate_image(:img_file)
    |> add_image
  end

  defp add_image(%Ecto.Changeset{valid?: true, changes: %{img_file: image}} = changeset) do
    image = upload_image(image)
    changeset = put_change(changeset, :avatar, image)
    changeset
  end

  defp add_image(changeset), do: changeset

  defp upload_image(image) do
    File.mkdir_p!(Path.dirname("priv/static/media/"))
    # extension = Path.extname(image.filename)
    # img_name = "/media/#{slug}-post#{extension}"
    img_name = "/media/#{image.filename}"
    img_path = "priv/static#{img_name}"
    File.cp(image.path, img_path)
    img_name
  end

  defp validate_image(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, img_file ->
      case valid_image(img_file) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  defp valid_image(image) do
    %{size: size} = File.stat!(image.path)
    IO.inspect(size)

    cond do
      size > 150_0000 ->
        {:error, "Image larger that 1.5Mb"}

      !validate(image) ->
        {:error, "File is not valid Image"}

      true ->
        {:ok, image}
    end
  end

  def validate(file) do
    ~w(.jpg .jpeg .gif .png .JPG) |> Enum.member?(Path.extname(file.filename))
  end
end
