defmodule FgHttpWeb.SessionController do
  @moduledoc """
  Implements the CRUD for a Session
  """

  alias FgHttp.{Sessions, Users.Session}
  use FgHttpWeb, :controller

  plug FgHttpWeb.Plugs.RedirectAuthenticated when action in [:new]
  plug FgHttpWeb.Plugs.SessionLoader when action in [:delete]

  # GET /sessions/new
  def new(conn, _params) do
    changeset = Session.changeset(%Session{})

    render(conn, "new.html", changeset: changeset)
  end

  # Sign In
  # POST /sessions
  def create(conn, %{"session" => session_params}) do
    case Sessions.create_session(session_params) do
      {:ok, session} ->
        conn
        # Prevent session fixation
        |> clear_session()
        |> put_session(:session_id, session.id)
        |> assign(:current_session, session)
        |> put_flash(:info, "Session created successfully")
        |> redirect(to: Routes.device_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Error creating session.")
        |> render("new.html", changeset: changeset, user_signed_in?: false)
    end
  end

  # Sign Out
  # DELETE /session
  def delete(conn, _params) do
    session = conn.assigns.current_session

    case Sessions.delete_session(session) do
      {:ok, _session} ->
        conn
        |> clear_session
        |> put_flash(:info, "Signed out successfully.")
        |> redirect(to: "/")
    end
  end
end
