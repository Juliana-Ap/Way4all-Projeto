require("dotenv").config();

const express = require("express");
const cors = require("cors");
const path = require("path");
const db = require("./db");

const app = express();
const frontendDir = path.join(__dirname, "..", "Frontend (Way4all)");

app.use(cors());
app.use(express.json());
app.use(express.static(frontendDir));

const ok = (res, data) => res.json(data);

const fail = (res, err, message = "Erro no servidor") => {
  console.error(err);
  res.status(500).json({ mensagem: message });
};

app.get("/", (req, res) => {
  res.sendFile(path.join(frontendDir, "index.html"));
});

// Usuarios

app.get("/usuarios", (req, res) => {
  const sql = "SELECT id, nome, email, tipo_deficiencia, data_cadastro FROM usuarios";

  db.query(sql, (err, result) => {
    if (err) {
      fail(res, err);
    } else {
      ok(res, result);
    }
  });
});

app.post("/usuarios", (req, res) => {
  const { nome, email, senha, tipo_deficiencia } = req.body;

  if (!nome || !email || !senha) {
    return res.status(400).json({ mensagem: "Nome, email e senha sao obrigatorios" });
  }

  const sql = `
    INSERT INTO usuarios (nome, email, senha, tipo_deficiencia)
    VALUES (?, ?, ?, ?)
  `;

  db.query(sql, [nome, email, senha, tipo_deficiencia || null], (err, result) => {
    if (err) {
      if (err.code === "ER_DUP_ENTRY") {
        return res.status(409).json({ mensagem: "Este email ja esta cadastrado" });
      }

      fail(res, err, "Erro ao cadastrar");
    } else {
      res.status(201).json({
        mensagem: "Usuario cadastrado!",
        usuario: {
          id: result.insertId,
          nome,
          email,
          tipo_deficiencia: tipo_deficiencia || null
        }
      });
    }
  });
});

// Login

app.post("/login", (req, res) => {
  const { email, senha } = req.body;

  if (!email || !senha) {
    return res.status(400).json({ mensagem: "Email e senha sao obrigatorios" });
  }

  const sql = `
    SELECT id, nome, email, tipo_deficiencia, data_cadastro
    FROM usuarios
    WHERE email = ? AND senha = ?
  `;

  db.query(sql, [email, senha], (err, result) => {
    if (err) {
      fail(res, err);
    } else if (result.length > 0) {
      res.status(200).json({
        mensagem: "Login realizado com sucesso!",
        usuario: result[0]
      });
    } else {
      res.status(401).json({ mensagem: "Email ou senha invalidos" });
    }
  });
});

// Destinos

app.get("/destinos", (req, res) => {
  const busca = req.query.busca;
  const termo = busca && busca.trim() ? busca.trim() : null;

  const sql = `
    SELECT
      d.id,
      d.nome,
      d.cidade,
      d.estado,
      d.descricao,
      ROUND(AVG(a.nota), 1) AS avaliacao,
      COUNT(a.id) AS total_avaliacoes
    FROM destinos d
    LEFT JOIN avaliacoes a ON a.destino_id = d.id
    WHERE ? IS NULL
      OR d.nome LIKE CONCAT('%', ?, '%')
      OR d.cidade LIKE CONCAT('%', ?, '%')
      OR d.estado LIKE CONCAT('%', ?, '%')
      OR d.descricao LIKE CONCAT('%', ?, '%')
    GROUP BY d.id
    ORDER BY d.nome
  `;

  db.query(sql, [termo, termo, termo, termo, termo], (err, result) => {
    if (err) {
      fail(res, err);
    } else {
      ok(res, result);
    }
  });
});

app.get("/destinos/:id", (req, res) => {
  const sql = `
    SELECT
      d.id,
      d.nome,
      d.cidade,
      d.estado,
      d.latitude,
      d.longitude,
      d.descricao,
      ROUND(AVG(a.nota), 1) AS avaliacao,
      COUNT(a.id) AS total_avaliacoes
    FROM destinos d
    LEFT JOIN avaliacoes a ON a.destino_id = d.id
    WHERE d.id = ?
    GROUP BY d.id
  `;

  db.query(sql, [req.params.id], (err, result) => {
    if (err) {
      return fail(res, err);
    }

    if (!result.length) {
      return res.status(404).json({ mensagem: "Destino nao encontrado" });
    }

    const recursosSql = `
      SELECT tipo, descricao, verificado
      FROM recursos_acessibilidade
      WHERE destino_id = ?
      ORDER BY tipo
    `;

    db.query(recursosSql, [req.params.id], (recursosErr, recursos) => {
      if (recursosErr) {
        return fail(res, recursosErr);
      }

      ok(res, { ...result[0], recursos });
    });
  });
});

// Favoritos

app.get("/usuarios/:usuarioId/favoritos", (req, res) => {
  const sql = `
    SELECT
      f.id AS favorito_id,
      d.id,
      d.nome,
      d.cidade,
      d.estado,
      d.descricao,
      ROUND(AVG(a.nota), 1) AS avaliacao
    FROM favoritos f
    JOIN destinos d ON d.id = f.destino_id
    LEFT JOIN avaliacoes a ON a.destino_id = d.id
    WHERE f.usuario_id = ?
    GROUP BY f.id, d.id
    ORDER BY f.data_adicao DESC
  `;

  db.query(sql, [req.params.usuarioId], (err, result) => {
    if (err) {
      fail(res, err);
    } else {
      ok(res, result);
    }
  });
});

app.post("/usuarios/:usuarioId/favoritos", (req, res) => {
  const { destino_id } = req.body;

  if (!destino_id) {
    return res.status(400).json({ mensagem: "destino_id e obrigatorio" });
  }

  const sql = `
    INSERT INTO favoritos (usuario_id, destino_id)
    SELECT ?, ?
    WHERE NOT EXISTS (
      SELECT 1 FROM favoritos WHERE usuario_id = ? AND destino_id = ?
    )
  `;

  db.query(
    sql,
    [req.params.usuarioId, destino_id, req.params.usuarioId, destino_id],
    (err) => {
      if (err) {
        fail(res, err, "Erro ao favoritar destino");
      } else {
        res.status(201).json({ mensagem: "Destino favoritado!" });
      }
    }
  );
});

const port = process.env.PORT || 3000;

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Servidor rodando na porta ${port}`);
  });
}

module.exports = app;
