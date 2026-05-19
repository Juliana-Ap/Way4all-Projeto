const API_URL = window.location.origin;
const DEFAULT_IMAGE = "img/destino_ex.jpg";

const getUser = () => JSON.parse(localStorage.getItem("way4all_user") || "null");
const setUser = (user) => localStorage.setItem("way4all_user", JSON.stringify(user));

const request = async (path, options = {}) => {
  const response = await fetch(`${API_URL}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {})
    },
    ...options
  });

  const contentType = response.headers.get("content-type") || "";
  const data = contentType.includes("application/json")
    ? await response.json()
    : { mensagem: await response.text() };

  if (!response.ok) {
    throw new Error(data.mensagem || "Erro ao conectar com o servidor");
  }

  return data;
};

const message = (text, type = "info") => {
  const box = document.querySelector("[data-message]");

  if (!box) {
    alert(text);
    return;
  }

  box.textContent = text;
  box.dataset.type = type;
};

const ratingText = (rating) => {
  if (!rating) return "Sem avaliacoes";
  return `Avaliacao: ${Number(rating).toFixed(1)}/5`;
};

const createDestinationCard = (destino, showFavorite = true) => {
  const card = document.createElement("div");
  card.className = "destino";
  card.innerHTML = `
    <a href="destino.html?id=${destino.id}">
      <img src="${DEFAULT_IMAGE}" alt="${destino.nome}">
    </a>
    <h3>${destino.nome}</h3>
    <p>${destino.cidade || ""}${destino.estado ? ` - ${destino.estado}` : ""}</p>
    <p>${destino.descricao || ""}</p>
    <p>${ratingText(destino.avaliacao)}</p>
    <a href="destino.html?id=${destino.id}">Ver detalhes</a>
  `;

  if (showFavorite) {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = "Favoritar";
    button.addEventListener("click", () => addFavorite(destino.id));
    card.appendChild(button);
  }

  return card;
};

const addFavorite = async (destinoId) => {
  const user = getUser();

  if (!user) {
    message("Faca login para salvar favoritos.", "error");
    return;
  }

  try {
    await request(`/usuarios/${user.id}/favoritos`, {
      method: "POST",
      body: JSON.stringify({ destino_id: destinoId })
    });
    message("Destino salvo nos favoritos!", "success");
  } catch (err) {
    message(err.message, "error");
  }
};

const setupRegister = () => {
  const form = document.querySelector("[data-register-form]");
  if (!form) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const senha = form.password.value;
    const confirmarSenha = form["confirm-password"].value;

    if (senha !== confirmarSenha) {
      message("As senhas precisam ser iguais.", "error");
      return;
    }

    try {
      await request("/usuarios", {
        method: "POST",
        body: JSON.stringify({
          nome: form.name.value,
          email: form.email.value,
          senha,
          tipo_deficiencia: form.pcd.value
        })
      });

      message("Cadastro realizado! Voce ja pode fazer login.", "success");
      setTimeout(() => {
        window.location.href = "login.html";
      }, 900);
    } catch (err) {
      message(err.message, "error");
    }
  });
};

const setupLogin = () => {
  const form = document.querySelector("[data-login-form]");
  if (!form) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    try {
      const data = await request("/login", {
        method: "POST",
        body: JSON.stringify({
          email: form.email.value,
          senha: form.password.value
        })
      });

      setUser(data.usuario);
      message(data.mensagem, "success");
      setTimeout(() => {
        window.location.href = "index.html";
      }, 700);
    } catch (err) {
      message(err.message, "error");
    }
  });
};

const setupDestinations = () => {
  const list = document.querySelector("[data-destinations]");
  if (!list) return;

  const searchForm = document.querySelector("[data-search-form]");

  const load = async (query = "") => {
    list.innerHTML = "<p>Carregando destinos...</p>";

    try {
      const destinos = await request(`/destinos${query ? `?busca=${encodeURIComponent(query)}` : ""}`);
      list.innerHTML = "";

      if (!destinos.length) {
        list.innerHTML = "<p>Nenhum destino encontrado.</p>";
        return;
      }

      destinos.forEach((destino) => list.appendChild(createDestinationCard(destino)));
    } catch (err) {
      list.innerHTML = `<p>${err.message}</p>`;
    }
  };

  searchForm?.addEventListener("submit", (event) => {
    event.preventDefault();
    load(searchForm.busca.value);
  });

  load();
};

const setupDestinationDetails = async () => {
  const container = document.querySelector("[data-destination-detail]");
  if (!container) return;

  const params = new URLSearchParams(window.location.search);
  const id = params.get("id") || "1";

  try {
    const destino = await request(`/destinos/${id}`);

    document.title = `${destino.nome} - Way4all`;
    container.innerHTML = `
      <h2>${destino.nome}</h2>
      <img src="${DEFAULT_IMAGE}" alt="${destino.nome}">
      <p>${destino.cidade || ""}${destino.estado ? ` - ${destino.estado}` : ""}</p>
      <p>${destino.descricao || ""}</p>
      <p>${ratingText(destino.avaliacao)}</p>
      <h3>Recursos de acessibilidade</h3>
      <ul>
        ${destino.recursos.map((recurso) => `
          <li>
            <strong>${recurso.tipo}</strong>: ${recurso.descricao}
          </li>
        `).join("")}
      </ul>
      <button type="button" data-favorite-button>Favoritar</button>
    `;

    container.querySelector("[data-favorite-button]").addEventListener("click", () => addFavorite(destino.id));
  } catch (err) {
    container.innerHTML = `<p>${err.message}</p>`;
  }
};

const setupFavorites = async () => {
  const list = document.querySelector("[data-favorites]");
  if (!list) return;

  const user = getUser();
  if (!user) {
    list.innerHTML = '<p>Faca login para ver seus favoritos.</p><a href="login.html">Ir para login</a>';
    return;
  }

  try {
    const favoritos = await request(`/usuarios/${user.id}/favoritos`);
    list.innerHTML = "";

    if (!favoritos.length) {
      list.innerHTML = "<p>Voce ainda nao tem favoritos.</p>";
      return;
    }

    favoritos.forEach((destino) => list.appendChild(createDestinationCard(destino, false)));
  } catch (err) {
    list.innerHTML = `<p>${err.message}</p>`;
  }
};

document.addEventListener("DOMContentLoaded", () => {
  setupRegister();
  setupLogin();
  setupDestinations();
  setupDestinationDetails();
  setupFavorites();
});
