// LIMPEZA DO BANCO
MATCH (n) DETACH DELETE n;

// CONSTRAINTS
CREATE CONSTRAINT usuario_id IF NOT EXISTS FOR (u:Usuario) REQUIRE u.id IS UNIQUE;
CREATE CONSTRAINT video_id IF NOT EXISTS FOR (v:Video) REQUIRE v.id IS UNIQUE;
CREATE CONSTRAINT hashtag_nome IF NOT EXISTS FOR (h:Hashtag) REQUIRE h.nome IS UNIQUE;

// CARGA: USUÁRIOS
LOAD CSV WITH HEADERS FROM 'file:///usuarios.csv' AS row
CREATE (:Usuario {
  id: toInteger(row.id),
  nome: row.nome,
  username: row.username,
  seguidores: toInteger(row.seguidores),
  seguindo: toInteger(row.seguindo),
  bio: row.bio,
  verificado: row.verificado = 'true'
});

// CARGA: VÍDEOS
LOAD CSV WITH HEADERS FROM 'file:///videos.csv' AS row
CREATE (:Video {
  id: row.id,
  titulo: row.titulo,
  likes: toInteger(row.likes),
  comentarios: toInteger(row.comentarios),
  compartilhamentos: toInteger(row.compartilhamentos),
  duracao_seg: toInteger(row.duracao_seg)
});

// CARGA: HASHTAGS
LOAD CSV WITH HEADERS FROM 'file:///videos.csv' AS row
WITH row, split(row.hashtags, ',') AS tags
UNWIND tags AS tag
MERGE (:Hashtag {nome: trim(tag)});

// RELACIONAMENTO: Usuario POSTOU Video
LOAD CSV WITH HEADERS FROM 'file:///videos.csv' AS row
MATCH (u:Usuario {id: toInteger(row.autor_id)})
MATCH (v:Video {id: row.id})
CREATE (u)-[:POSTOU]->(v);

// RELACIONAMENTO: Video TEM_HASHTAG
LOAD CSV WITH HEADERS FROM 'file:///videos.csv' AS row
MATCH (v:Video {id: row.id})
WITH v, split(row.hashtags, ',') AS tags
UNWIND tags AS tag
MATCH (h:Hashtag {nome: trim(tag)})
CREATE (v)-[:TEM_HASHTAG]->(h);

// RELACIONAMENTO: Usuario SEGUE Usuario
LOAD CSV WITH HEADERS FROM 'file:///seguidores.csv' AS row
MATCH (a:Usuario {id: toInteger(row.seguidor_id)})
MATCH (b:Usuario {id: toInteger(row.seguido_id)})
CREATE (a)-[:SEGUE {desde: date(row.data_inicio)}]->(b);

// RELACIONAMENTO: Usuario INTERAGIU Video
LOAD CSV WITH HEADERS FROM 'file:///interacoes.csv' AS row
MATCH (u:Usuario {id: toInteger(row.usuario_id)})
MATCH (v:Video {id: row.video_id})
CREATE (u)-[:INTERAGIU {tipo: row.tipo, data: date(row.data)}]->(v);

// Q1: Top 5 influenciadores
MATCH (u:Usuario)
RETURN u.nome AS influenciador, u.seguidores AS seguidores
ORDER BY u.seguidores DESC LIMIT 5;

// Q2: Vídeos mais virais
MATCH (u:Usuario)-[:POSTOU]->(v:Video)
RETURN v.titulo AS video, u.nome AS criador, v.compartilhamentos AS compartilhamentos
ORDER BY v.compartilhamentos DESC LIMIT 5;

// Q3: Seguidores dos maiores influenciadores
MATCH (seguidor:Usuario)-[:SEGUE]->(influenciador:Usuario)
WHERE influenciador.seguidores > 1000000
RETURN influenciador.nome AS influenciador,
       collect(seguidor.nome) AS seguidores_na_plataforma,
       count(seguidor) AS total
ORDER BY total DESC;

// Q4: Influenciadores que se seguem mutuamente
MATCH (a:Usuario)-[:SEGUE]->(b:Usuario)-[:SEGUE]->(a)
RETURN a.nome AS usuario_a, b.nome AS usuario_b;

// Q5: Hashtags mais usadas
MATCH (v:Video)-[:TEM_HASHTAG]->(h:Hashtag)
RETURN h.nome AS hashtag, count(v) AS total_videos
ORDER BY total_videos DESC LIMIT 10;

// Q6: Fãs ativos de verificados
MATCH (u:Usuario)-[:INTERAGIU]->(v:Video)<-[:POSTOU]-(inf:Usuario {verificado: true})
RETURN inf.nome AS influenciador, collect(DISTINCT u.nome) AS fas, count(u) AS total
ORDER BY total DESC;

// Q7: Caminho mais curto entre usuários
MATCH p = shortestPath(
  (a:Usuario {username: '@analima'})-[:SEGUE*]-(b:Usuario {username: '@joaopedro'})
)
RETURN p, length(p) AS graus;

// Q8: Criadores com hashtag #viral
MATCH (u:Usuario)-[:POSTOU]->(v:Video)-[:TEM_HASHTAG]->(h:Hashtag {nome: '#viral'})
RETURN u.nome AS criador, v.titulo AS video, v.likes AS likes
ORDER BY v.likes DESC;

// Q9: Score de engajamento
MATCH (u:Usuario)-[:POSTOU]->(v:Video)
WITH u, sum(v.likes + v.comentarios + v.compartilhamentos) AS engajamento, count(v) AS total
RETURN u.nome AS influenciador, total,
       round(toFloat(engajamento) / total) AS media_engajamento
ORDER BY media_engajamento DESC;

// Q10: Rede de influência indireta
MATCH (a:Usuario)-[:SEGUE]->(b:Usuario)-[:SEGUE]->(c:Usuario)
WHERE a <> c
RETURN a.nome AS origem, b.nome AS intermediario, c.nome AS destino
LIMIT 20;