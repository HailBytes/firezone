defmodule Web.Actors.ServiceAccounts.New do
  use Web, :live_view
  import Web.Actors.Components
  alias Domain.Actors

  def mount(_params, _session, socket) do
    changeset = Actors.new_actor(%{type: :service_account})

    socket =
      assign(socket,
        form: to_form(changeset),
        page_title: "New Service Account"
      )

    {:ok, socket, temporary_assigns: [form: %Phoenix.HTML.Form{}]}
  end

  def render(assigns) do
    ~H"""
    <.breadcrumbs account={@account}>
      <.breadcrumb path={~p"/#{@account}/actors"}>Actors</.breadcrumb>
      <.breadcrumb path={~p"/#{@account}/actors/new"}>Add</.breadcrumb>
      <.breadcrumb path={~p"/#{@account}/actors/service_accounts/new"}>Service Account</.breadcrumb>
    </.breadcrumbs>

    <.section>
      <:title>{@page_title}</:title>
      <:content>
        <div class="max-w-2xl px-4 py-8 mx-auto lg:py-16">
          <.flash kind={:error} flash={@flash} />
          <.form for={@form} phx-change={:change} phx-submit={:submit}>
            <div class="grid gap-4 mb-4 sm:grid-cols-1 sm:gap-6 sm:mb-6">
              <.actor_form form={@form} type={:service_account} subject={@subject} />
            </div>
            <.submit_button>
              Next: Create Token
            </.submit_button>
          </.form>
        </div>
      </:content>
    </.section>
    """
  end

  def handle_event("change", %{"actor" => attrs}, socket) do
    changeset =
      attrs
      |> Map.put("type", :service_account)
      |> Actors.new_actor()
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("submit", %{"actor" => attrs}, socket) do
    attrs =
      attrs
      |> Map.put("type", :service_account)

    with {:ok, actor} <-
           Actors.create_actor(
             socket.assigns.account,
             attrs,
             socket.assigns.subject
           ) do
      socket =
        push_navigate(socket,
          to: ~p"/#{socket.assigns.account}/actors/service_accounts/#{actor}/new_identity"
        )

      {:noreply, socket}
    else
      {:error, :service_accounts_limit_reached} ->
        changeset =
          attrs
          |> Actors.new_actor()
          |> Map.put(:action, :insert)

        socket =
          socket
          |> put_flash(
            :error,
            "You have reached the maximum number of service accounts allowed by your subscription plan."
          )
          |> assign(form: to_form(changeset))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
