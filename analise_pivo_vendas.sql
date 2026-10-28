-- =====================================================================
-- Projeto: Análise de Desempenho de Vendas (SQLite)
-- Descrição: Transforma linhas de meses e anos em uma tabela pivô (pivot) 
-- para comparar o volume de vendas lado a lado de 2020 a 2023.
-- =====================================================================
--Verificação de quantidade de dados em tabelas--
SELECT * FROM produtos;
SELECT COUNT(*) AS Vendas_Totais FROM vendas;
SELECT COUNT(*) as QNT_de_Vendas FROM itens_venda;

--Descobri que os Valores dos produtos estava fora do padrão do mercado--
SELECT nome_produto, preco FROM produtos
WHERE nome_produto = 'Chocolate';

SELECT nome_produto, preco FROM produtos
WHERE nome_produto = 'Bola de Futebol';

SELECT nome_produto, preco FROM produtos
WHERE nome_produto = 'Livro de Ficção';

SELECT nome_produto, preco FROM produtos
WHERE nome_produto = 'Camisa';

SELECT nome_produto, preco FROM produtos
WHERE nome_produto = 'Celular';

--Atualizando os valores que esta fora do mercado
UPDATE produtos 
SET preco = ROUND(ABS(RANDOM() % 30) + 5.90, 2) 
WHERE nome_produto = 'Chocolate';

UPDATE produtos 
SET preco = ROUND(ABS(RANDOM() % 30) + 15.8, 2) 
WHERE nome_produto = 'Bola de Futebol';

UPDATE produtos 
SET preco = ROUND(ABS(RANDOM() % 30) + 55.9, 2) 
WHERE nome_produto = 'Livro de Ficção';

--Consulta Ano de Venda
SELECT strftime('%Y',data_venda) FROM vendas;

--Tirando os anos repetidos retornando sem duplicidade 
SELECT DISTINCT(strftime('%Y',data_venda)) as Ano FROM vendas
ORDER by Ano;

--Consulta por Ano e Total de Vendas
SELECT strftime('%Y',data_venda) as Ano, strftime('%m',data_venda) as Mes, COUNT(id_venda) as Total_Vendas
FROM vendas
GROUP BY Ano, Mes
ORDER by Ano;

--Consulta por Ano e Faturamento Total 
SELECT strftime('%Y',data_venda) as Ano, strftime('%m',data_venda) as Mes, SUM(total_venda) AS Faturamento_Total
FROM vendas 
GROUP BY Ano, Mes
ORDER BY Ano;

-- Consulta dos Meses que mais venderam
SELECT     strftime('%Y', data_venda) as Ano, strftime('%m', data_venda) as Mes, COUNT(id_venda) as Total_Vendas 
FROM vendas 
WHERE strftime('%m', data_venda) IN ('01', '11', '12') 
GROUP BY Ano, Mes 
ORDER by Ano;

-- Calcula o total de vendas de cada fornecedor na Black Friday
SELECT SUM(Qtd_Vendas)
FROM(
    SELECT strftime('%Y/%m', v.data_venda) AS 'Ano/Mes', f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
    FROM itens_venda iv
    JOIN vendas v ON v.id_venda = iv.venda_id
    JOIN produtos p ON p.id_produto = iv.produto_id
    JOIN fornecedores f ON f.id_fornecedor = p.fornecedor_id
    GROUP BY Nome_Fornecedor, 'Ano/Mes'
    ORDER BY 'Ano/Mes', Qtd_Vendas
);

-- Analisa as vendas por categoria de produtos na Black Friday
SELECT strftime('%Y', v.data_venda) AS 'Ano', c.nome_categoria AS Nome_Categoria, COUNT(iv.produto_id) AS Qtd_Vendas
FROM itens_venda iv
JOIN vendas v ON v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN categorias c ON c.id_categoria = p.categoria_id
WHERE strftime('%m', v.data_venda) = '11'
GROUP BY Nome_Categoria, 'Ano'
ORDER BY 'Ano', Qtd_Vendas DESC;

-- Validação da consistência das vendas registradas
SELECT SUM(Qtd_Vendas)
FROM(
    SELECT strftime('%Y/%m', v.data_venda) AS 'Ano/Mes', f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
    FROM itens_venda iv
    JOIN vendas v ON v.id_venda = iv.venda_id
    JOIN produtos p ON p.id_produto = iv.produto_id
    JOIN fornecedores f ON f.id_fornecedor = p.fornecedor_id
    GROUP BY Nome_Fornecedor, 'Ano/Mes'
    ORDER BY 'Ano/Mes', Qtd_Vendas
);

-- Análise da performance de vendas do fornecedor "NebulaNetworks" ao longo do tempo
SELECT 
    strftime('%Y/%m', v.data_venda) AS Ano_Mes, 
    COUNT(iv.produto_id) AS Qtd_Vendas 
FROM itens_venda iv 
JOIN vendas v ON v.id_venda = iv.venda_id 
JOIN produtos p ON p.id_produto = iv.produto_id 
JOIN fornecedores f ON f.id_fornecedor = p.fornecedor_id 
WHERE f.nome = 'NebulaNetworks' 
GROUP BY Ano_Mes 
ORDER BY Ano_Mes;


--Quadro Geral
SELECT strftime('%Y/%m',data_venda) AS Ano_Mes, COUNT(*) as Qntd_vendas
FROM vendas
GROUP by Ano_Mes
ORDER By Ano_Mes;

--Quadro Geral Mês (Sub Consulta)
SELECT strftime('%m',data_venda) AS Mes, strftime('%Y', data_venda) as Ano, COUNT(*) as Qntd_vendas
FROM vendas
GROUP by Mes
ORDER By Mes
;

SELECT Mes,
SUM(case WHEN Ano='2020' THEN Qntd_vendas else 0 end) as '2020',
SUM(case WHEN Ano='2021' THEN Qntd_vendas else 0 end) as '2021',
SUM(case WHEN Ano='2022' THEN Qntd_vendas else 0 end) as '2022',
SUM(case WHEN Ano='2023' THEN Qntd_vendas else 0 end) as '2023'
FROM(
SELECT strftime('%m',data_venda) AS Mes, 
       strftime('%Y', data_venda) as Ano, 
  COUNT(*) as Qntd_vendas
FROM vendas
GROUP by Mes, Ano
)
GROUP by Mes
ORDER by Mes;

-- Métrica - Analisando o Número de vendas da Black F. Agrupando por ano anterior (2020 e 2021)

SELECT COUNT(*) AS Qtd_Vendas, strftime('%Y', v.data_venda) as Ano
FROM vendas v
WHERE strftime('%m', v.data_venda) = '11' and Ano !='2022'
GROUP by Ano;

--Métrica com Subconsulta da média de vendas Atual 

SELECT AVG(Qtd_Vendas) as Media_Qtd_Vendas_Atual
FROM (
    SELECT COUNT(*) AS Qtd_Vendas, strftime('%Y', v.data_venda) AS Ano
    FROM vendas v
    WHERE strftime('%m', v.data_venda) = '11' AND Ano = '2022'
    GROUP BY Ano
)
;

--Usando o WITH Tabela temporaria 
-- Colocando em Porcentagem 
WITH Media_Vendas_Anteriores AS (SELECT AVG(Qtd_Vendas) AS Media_Qtd_Vendas
FROM (
    SELECT COUNT(*) AS Qtd_Vendas, strftime('%Y', v.data_venda) AS Ano
    FROM vendas v
    WHERE strftime('%m', v.data_venda) = '11' AND Ano != '2022'
    GROUP BY Ano
)), Vendas_Atual AS (SELECT Qtd_Vendas AS Qtd_Vendas_Atual
FROM(
    SELECT COUNT(*) AS Qtd_Vendas, strftime('%Y', v.data_venda) AS Ano
    FROM vendas v
    WHERE strftime('%m', v.data_venda) = '11' AND Ano = '2022'
    GROUP BY Ano
    ))
    SELECT
    mva.Media_Qtd_Vendas,
    va.Qtd_Vendas_Atual,
    ROUND((va.Qtd_Vendas_Atual - mva.Media_Qtd_Vendas)/mva.Media_Qtd_Vendas *100.0, 2) || '%' AS Porcentagem
    FROM Vendas_Atual va, Media_Vendas_Anteriores mva
