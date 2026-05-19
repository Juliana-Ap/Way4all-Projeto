CREATE DATABASE way4all_db;
USE way4all_db;
CREATE TABLE usuarios (id INT AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL UNIQUE, senha VARCHAR(255) NOT NULL, tipo_deficiencia VARCHAR(50), data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE perfis (id INT AUTO_INCREMENT PRIMARY KEY, usuario_id INT NOT NULL, foto VARCHAR(255), bio TEXT, preferencias TEXT, FOREIGN KEY (usuario_id) REFERENCES usuarios(id));

CREATE TABLE destinos (id INT AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(150) NOT NULL, cidade VARCHAR(100), estado VARCHAR(50), latitude DECIMAL(10,8), longitude DECIMAL(11,8), descricao TEXT);

CREATE TABLE recursos_acessibilidade (id INT AUTO_INCREMENT PRIMARY KEY, destino_id INT NOT NULL, tipo VARCHAR(100), descricao TEXT, verificado BOOLEAN DEFAULT FALSE, FOREIGN KEY (destino_id) REFERENCES destinos(id));

CREATE TABLE avaliacoes (id INT AUTO_INCREMENT PRIMARY KEY, usuario_id INT NOT NULL, destino_id INT NOT NULL, nota INT CHECK (nota BETWEEN 1 AND 5), comentario TEXT, data TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (usuario_id) REFERENCES usuarios(id), FOREIGN KEY (destino_id) REFERENCES destinos(id));

CREATE TABLE favoritos (id INT AUTO_INCREMENT PRIMARY KEY, usuario_id INT NOT NULL, destino_id INT NOT NULL, data_adicao TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (usuario_id) REFERENCES usuarios(id), FOREIGN KEY (destino_id) REFERENCES destinos(id));

SELECT * FROM usuarios;

SELECT d.nome, r.tipo FROM destinos d JOIN recursos_acessibilidade r ON d.id = r.destino_id;

-- Usuario de teste
INSERT INTO usuarios (nome, email, senha) VALUES ('Ana Lima', 'ana@email.com', '123456');

-- Destino de teste
INSERT INTO destinos (nome, cidade, estado) VALUES ('Bonito', 'Bonito', 'MS');

-- Inserir um recurso de acessibilidade
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao) VALUES (1, 'Rampa', 'Rampa na entrada principal');

-- Ver se funcionou
SELECT * FROM usuarios;
SELECT d.nome, r.tipo FROM destinos d JOIN recursos_acessibilidade r ON d.id = r.destino_id;