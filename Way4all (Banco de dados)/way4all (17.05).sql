-- ============================================================
-- Way4All — Banco de dados completo com dados de exemplo
-- ============================================================

CREATE DATABASE IF NOT EXISTS way4all_db;
USE way4all_db;

-- ── TABELAS ──────────────────────────────────────────────

CREATE TABLE usuarios (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  nome             VARCHAR(100) NOT NULL,
  email            VARCHAR(100) NOT NULL UNIQUE,
  senha            VARCHAR(255) NOT NULL,
  tipo_deficiencia VARCHAR(50),
  data_cadastro    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE perfis (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id  INT NOT NULL,
  foto        VARCHAR(255),
  bio         TEXT,
  preferencias TEXT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE destinos (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nome      VARCHAR(150) NOT NULL,
  cidade    VARCHAR(100),
  estado    VARCHAR(50),
  latitude  DECIMAL(10,8),
  longitude DECIMAL(11,8),
  descricao TEXT
);

CREATE TABLE recursos_acessibilidade (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  destino_id INT NOT NULL,
  tipo       VARCHAR(100),
  descricao  TEXT,
  verificado BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (destino_id) REFERENCES destinos(id)
);

CREATE TABLE avaliacoes (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  destino_id INT NOT NULL,
  nota       INT CHECK (nota BETWEEN 1 AND 5),
  comentario TEXT,
  data       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY (destino_id) REFERENCES destinos(id)
);

CREATE TABLE favoritos (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id  INT NOT NULL,
  destino_id  INT NOT NULL,
  data_adicao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY (destino_id) REFERENCES destinos(id)
);

CREATE TABLE sugestoes (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id  INT NOT NULL,
  destino_id  INT,
  descricao   TEXT NOT NULL,
  status      ENUM('pendente', 'aprovada', 'reprovada') DEFAULT 'pendente',
  data_envio  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- ── USUARIOS FICTÍCIOS ────────────────────────────────────
-- Senhas estao como texto simples para teste.
-- No sistema real o backend vai salvar criptografado.

INSERT INTO usuarios (nome, email, senha, tipo_deficiencia) VALUES
  ('Ana Lima',        'ana@email.com',     '123456', 'Mobilidade reduzida'),
  ('Carlos Souza',    'carlos@email.com',  '123456', 'Deficiencia visual'),
  ('Mariana Rocha',   'mariana@email.com', '123456', 'Deficiencia auditiva'),
  ('Pedro Alves',     'pedro@email.com',   '123456', 'Mobilidade reduzida'),
  ('Fernanda Costa',  'fernanda@email.com','123456', 'Deficiencia cognitiva'),
  ('Roberto Nunes',   'roberto@email.com', '123456', 'Mobilidade reduzida');

-- ── PERFIS DOS USUARIOS ───────────────────────────────────

INSERT INTO perfis (usuario_id, bio, preferencias) VALUES
  (1, 'Amo viajar e descobrir novos lugares acessiveis.', 'Rampa, Elevador, Estacionamento'),
  (2, 'Apaixonado por cultura e historia do Brasil.',     'Audioguia, Piso tatil'),
  (3, 'Viajante frequente, sempre em busca de aventuras.','Interprete de Libras, Legenda'),
  (4, 'Fotografo e viajante apaixonado pela natureza.',   'Rampa, Banheiro adaptado'),
  (5, 'Adoro praias e destinos naturais.',                'Sinalização visual, Apoio cognitivo'),
  (6, 'Fã de ecoturismo e turismo rural.',                'Rampa, Estacionamento');

-- ── DESTINOS REAIS ACESSÍVEIS DO BRASIL ──────────────────

INSERT INTO destinos (nome, cidade, estado, latitude, longitude, descricao) VALUES
  ('Parque Ibirapuera',          'São Paulo',        'SP', -23.58720000, -46.65780000, 'Um dos maiores parques urbanos do Brasil, com infraestrutura de acessibilidade completa, trilhas adaptadas e museus acessiveis.'),
  ('Bonito Ecoturismo',          'Bonito',           'MS', -21.12590000, -56.48420000, 'Destino de ecoturismo reconhecido nacionalmente pela acessibilidade. Passeios adaptados para cadeirantes nas cachoeiras e rios de aguas cristalinas.'),
  ('Praia do Forte',             'Mata de São João', 'BA', -12.57800000, -38.00500000, 'Praia com esteiras de acessibilidade na areia, cadeiras anfibias para banho de mar e banheiros adaptados na orla.'),
  ('Gramado Centro Historico',   'Gramado',          'RS', -29.37430000, -50.87540000, 'Centro historico com calcamento acessivel, lojas e restaurantes adaptados e sinalizacao para pessoas com deficiencia visual.'),
  ('Ouro Preto Centro',          'Ouro Preto',       'MG', -20.38600000, -43.50360000, 'Cidade historica com mapa de rotas acessiveis, museus adaptados e estacionamento exclusivo para PCDs no centro.'),
  ('Parque Nacional da Tijuca',  'Rio de Janeiro',   'RJ', -22.93520000, -43.27870000, 'O maior parque urbano florestal do mundo, com trilhas adaptadas e mirantes com rampas de acesso.'),
  ('Pelourinho',                 'Salvador',         'BA', -12.97080000, -38.51060000, 'Centro historico de Salvador com elevadores publicos de acesso, calcamento adaptado e museus acessiveis.'),
  ('Parque das Aves',            'Foz do Iguacu',    'PR', -25.69090000, -54.44470000, 'Parque com trilhas totalmente adaptadas para cadeirantes, audioguia disponivel e banheiros acessiveis em todos os setores.'),
  ('Maragogi Praia',             'Maragogi',         'AL', -9.00490000,  -35.22420000, 'Praia com aguas cristalinas e infraestrutura de acessibilidade completa, com cadeiras anfibias e rampas de acesso ao mar.'),
  ('Cataratas do Iguacu',        'Foz do Iguacu',    'PR', -25.69580000, -54.43840000, 'Uma das maiores maravilhas naturais do mundo, com passarelas totalmente acessiveis para cadeirantes ao longo das cataratas.');

-- ── RECURSOS DE ACESSIBILIDADE POR DESTINO ───────────────

-- Parque Ibirapuera (id 1)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (1, 'Rampa de acesso',          'Rampas em todas as entradas e trilhas internas', TRUE),
  (1, 'Banheiro adaptado',        'Banheiros acessiveis em todos os setores do parque', TRUE),
  (1, 'Estacionamento exclusivo', 'Vagas para PCDs proximo a todas as entradas', TRUE),
  (1, 'Piso tatil',               'Piso tatil de alerta e direcional nos caminhos principais', TRUE),
  (1, 'Cadeira de rodas',         'Emprestimo gratuito de cadeiras de rodas na entrada', TRUE);

-- Bonito Ecoturismo (id 2)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (2, 'Rampa de acesso',          'Rampas de acesso nos principais atrativos', TRUE),
  (2, 'Banheiro adaptado',        'Banheiros adaptados nos pontos turisticos', TRUE),
  (2, 'Estacionamento exclusivo', 'Vagas para PCDs nos principais atrativos', TRUE),
  (2, 'Passeio adaptado',         'Passeios em flutuacao adaptados para cadeirantes', TRUE),
  (2, 'Guia especializado',       'Guias treinados para atender PCDs', TRUE);

-- Praia do Forte (id 3)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (3, 'Esteira de acessibilidade', 'Esteiras na areia facilitando o acesso ao mar', TRUE),
  (3, 'Cadeira anfibia',           'Cadeiras anfibias para banho de mar disponivel na orla', TRUE),
  (3, 'Banheiro adaptado',         'Banheiros acessiveis na orla da praia', TRUE),
  (3, 'Rampa de acesso',           'Rampas de acesso a orla e calçadao', TRUE);

-- Gramado (id 4)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (4, 'Calcamento acessivel',      'Ruas com piso regular e rampas nas calcadas', TRUE),
  (4, 'Banheiro adaptado',         'Banheiros acessiveis no centro e principais atracoes', TRUE),
  (4, 'Estacionamento exclusivo',  'Vagas para PCDs no centro da cidade', TRUE),
  (4, 'Sinalização visual',        'Placas e sinalizacao para deficientes visuais', FALSE);

-- Ouro Preto (id 5)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (5, 'Mapa de rotas acessiveis',  'Mapa com os caminhos mais acessiveis da cidade historica', TRUE),
  (5, 'Estacionamento exclusivo',  'Estacionamento gratuito para PCDs no centro', TRUE),
  (5, 'Museus adaptados',          'Principais museus com rampas e elevadores', TRUE);

-- Parque Nacional da Tijuca (id 6)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (6, 'Trilha adaptada',           'Trilha Transcarioca com trechos adaptados para cadeirantes', TRUE),
  (6, 'Mirante acessivel',         'Mirante do Almirao com rampa de acesso', TRUE),
  (6, 'Estacionamento exclusivo',  'Vagas para PCDs nas principais entradas do parque', TRUE);

-- Pelourinho (id 7)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (7, 'Elevador publico',          'Elevadores Lacerda e Plataforma interligando niveis da cidade', TRUE),
  (7, 'Banheiro adaptado',         'Banheiros acessiveis no centro historico', TRUE),
  (7, 'Museus adaptados',          'Museus com rampas e elevadores de acesso', TRUE);

-- Parque das Aves (id 8)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (8, 'Trilha adaptada',           'Todas as trilhas internas acessiveis para cadeirantes', TRUE),
  (8, 'Audioguia',                 'Audioguia em portugues e ingles disponivel na entrada', TRUE),
  (8, 'Banheiro adaptado',         'Banheiros acessiveis em todos os setores', TRUE),
  (8, 'Estacionamento exclusivo',  'Vagas para PCDs na entrada do parque', TRUE);

-- Maragogi (id 9)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (9, 'Cadeira anfibia',           'Cadeiras anfibias para acesso ao mar disponivel na praia', TRUE),
  (9, 'Rampa de acesso',           'Rampas de acesso a orla e as galeotas', TRUE),
  (9, 'Banheiro adaptado',         'Banheiros acessiveis na orla', TRUE),
  (9, 'Estacionamento exclusivo',  'Vagas para PCDs nos principais acessos a praia', TRUE);

-- Cataratas do Iguacu (id 10)
INSERT INTO recursos_acessibilidade (destino_id, tipo, descricao, verificado) VALUES
  (10, 'Passarela acessivel',      'Passarela principal totalmente acessivel para cadeirantes', TRUE),
  (10, 'Banheiro adaptado',        'Banheiros acessiveis ao longo de toda a passarela', TRUE),
  (10, 'Estacionamento exclusivo', 'Vagas para PCDs na entrada do parque', TRUE),
  (10, 'Cadeira de rodas',         'Emprestimo de cadeiras de rodas na entrada', TRUE),
  (10, 'Audioguia',                'Audioguia com descricao da paisagem para deficientes visuais', TRUE);

-- ── AVALIAÇÕES ────────────────────────────────────────────

INSERT INTO avaliacoes (usuario_id, destino_id, nota, comentario) VALUES
  (1, 2,  5, 'Experiencia incrivel! As rampas funcionam muito bem e os guias sao atenciosos com quem usa cadeira de rodas.'),
  (2, 8,  5, 'O audioguia foi fundamental para minha visita. Descricoes detalhadas de cada ave e do ambiente.'),
  (3, 7,  4, 'Os elevadores do Pelourinho facilitaram muito. Alguns trechos ainda sao dificeis mas o acesso principal e otimo.'),
  (4, 10, 5, 'As cataratas sao maravilhosas e a passarela acessivel permite ver tudo de perto sem dificuldade.'),
  (5, 3,  5, 'A esteira na areia e a cadeira anfibia me permitiram entrar no mar pela primeira vez. Inesquecivel!'),
  (6, 1,  4, 'O Ibirapuera e muito bem adaptado. Emprestei uma cadeira de rodas na entrada e passeei por todo o parque.'),
  (1, 9,  5, 'Maragogi e um paraiso. Toda a infraestrutura de acessibilidade funcionou perfeitamente.'),
  (2, 5,  3, 'Ouro Preto e linda mas o terreno historico e muito irregular. O mapa de rotas acessiveis ajuda muito.'),
  (3, 4,  5, 'Gramado e muito bem preparada. As calcadas sao excelentes para quem usa cadeira de rodas.'),
  (4, 6,  4, 'A trilha adaptada no Parque da Tijuca e excelente. Vale muito a visita.');

-- ── FAVORITOS ────────────────────────────────────────────

INSERT INTO favoritos (usuario_id, destino_id) VALUES
  (1, 2),  -- Ana: Bonito
  (1, 9),  -- Ana: Maragogi
  (1, 3),  -- Ana: Praia do Forte
  (2, 8),  -- Carlos: Parque das Aves
  (2, 10), -- Carlos: Cataratas
  (3, 4),  -- Mariana: Gramado
  (3, 7),  -- Mariana: Pelourinho
  (4, 6),  -- Pedro: Tijuca
  (4, 10), -- Pedro: Cataratas
  (5, 3),  -- Fernanda: Praia do Forte
  (5, 9),  -- Fernanda: Maragogi
  (6, 1);  -- Roberto: Ibirapuera

-- ── SUGESTOES ────────────────────────────────────────────

INSERT INTO sugestoes (usuario_id, descricao, status) VALUES
  (1, 'Sugestao de destino: Parque Estadual de Campos do Jordao tem excelente infraestrutura para PCDs.', 'pendente'),
  (2, 'Sugestao de destino: Museu do Ipiranga em Sao Paulo, recentemente reformado com total acessibilidade.', 'pendente'),
  (3, 'Sugestao de recurso: Adicionar informacao sobre interprete de Libras no Parque Ibirapuera aos finais de semana.', 'pendente');

-- ── CONSULTAS DE VERIFICAÇÃO ──────────────────────────────

-- Ver todos os usuarios cadastrados
SELECT id, nome, email, tipo_deficiencia FROM usuarios;

-- Ver todos os destinos com seus recursos
SELECT d.nome, d.cidade, d.estado, GROUP_CONCAT(r.tipo SEPARATOR ' | ') AS recursos
FROM destinos d
LEFT JOIN recursos_acessibilidade r ON d.id = r.destino_id
GROUP BY d.id;

-- Ver avaliacoes com nome do usuario e destino
SELECT u.nome AS usuario, d.nome AS destino, a.nota, a.comentario
FROM avaliacoes a
JOIN usuarios u ON a.usuario_id = u.id
JOIN destinos d ON a.destino_id = d.id
ORDER BY a.nota DESC;

-- Ver media de notas por destino
SELECT d.nome, ROUND(AVG(a.nota), 1) AS media, COUNT(*) AS total_avaliacoes
FROM avaliacoes a
JOIN destinos d ON a.destino_id = d.id
GROUP BY d.id
ORDER BY media DESC;
