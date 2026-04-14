# 📊 Análise de Influenciadores TikTok com Neo4j

> Projeto prático da trilha DIO — Analisando Dados de Redes Sociais com Base em Consultas de Grafos

## 📌 Sobre o Projeto

Este projeto modela a rede social TikTok como um banco de dados em grafos utilizando o Neo4j, com foco na análise de influenciadores, seguidores e propagação de conteúdo viral.

### Por que Grafos?

Com Neo4j, perguntas como "quem influencia quem?", "qual o caminho entre dois usuários?" e "quais hashtags conectam comunidades?" são respondidas de forma natural e performática.

## 🗂️ Estrutura do Repositório

tiktok-neo4j/
├── data/
│   ├── usuarios.csv
│   ├── videos.csv
│   ├── seguidores.csv
│   └── interacoes.csv
├── cypher/
│   └── scripts.cypher
└── README.md

## 🧩 Modelo do Grafo

### Nodes
- Usuario: id, nome, username, seguidores, seguindo, bio, verificado
- Video: id, titulo, likes, comentarios, compartilhamentos, duracao_seg
- Hashtag: nome

### Relacionamentos
- (Usuario)-[:SEGUE]->(Usuario)
- (Usuario)-[:POSTOU]->(Video)
- (Usuario)-[:INTERAGIU]->(Video)
- (Video)-[:TEM_HASHTAG]->(Hashtag)

## ⚙️ Como Executar

1. Instale o Neo4j Desktop: https://neo4j.com/download/
2. Copie os CSVs para a pasta Import do Neo4j
3. Execute o arquivo scripts.cypher no Neo4j Browser

## 🔍 Queries de Negócio

- Q1: Top 5 influenciadores com mais seguidores
- Q2: Vídeos mais virais
- Q3: Rede de seguidores dos maiores influenciadores
- Q4: Influenciadores que se seguem mutuamente
- Q5: Hashtags mais usadas
- Q6: Usuários que interagem com verificados
- Q7: Caminho mais curto entre usuários
- Q8: Criadores com hashtags virais
- Q9: Score de engajamento por influenciador
- Q10: Rede de influência indireta

## 🛠️ Tecnologias
- Neo4j, Cypher, Neo4j Browser, CSV

## 📚 Referências
- https://neo4j.com/docs/
- https://github.com/neo4j-graph-examples
- https://arrows.app