#  Projeto de Análise de Dados com SQL (SQLite)

## Objetivo do Projeto
Este repositório documenta o meu aprendizado prático e a aplicação de consultas avançadas em SQL utilizando o **SQLite**. O foco é resolver problemas reais de negócio extraindo insights de um banco de dados de vendas (vendas, clientes, produtos e fornecedores), calculando métricas de desempenho e criando comparações temporais.

## Tecnologias Utilizadas
* **SQL (SQLite)** para manipulação, filtragem, agregações e criação de CTEs.
* **SQL Online IDE** para prototipagem e execução das queries.
* **Git e GitHub** para versionamento e portfólio.

---

## Principais Consultas e Métricas Desenvolvidas

### 1. Análise de Sazonalidade e Comparativo Histórico
Esta query calcula a quantidade de vendas do mês de novembro (Black Friday) do ano atual (2022) e compara com a média dos anos anteriores (2020 e 2021) utilizando **Common Table Expressions (CTEs)** e cálculo de variação percentual:

```sql
WITH Media_Vendas_Anteriores AS ( 
    SELECT AVG(Qtd_Vendas) AS Media_Qtd_Vendas
    FROM (
        SELECT COUNT(*) AS Qtd_Vendas, strftime('%Y', v.data_venda) AS Ano
        FROM vendas v 
        WHERE strftime('%m', v.data_venda) = '11' AND Ano != '2022' 
        GROUP BY Ano
    )
), 
Vendas_Atual AS ( 
    SELECT Qtd_Vendas AS Qtd_Vendas_Atual
    FROM (
        SELECT COUNT(*) AS Qtd_Vendas, strftime('%Y', v.data_venda) AS Ano
        FROM vendas v 
        WHERE strftime('%m', v.data_venda) = '11' AND Ano = '2022' 
        GROUP BY Ano
    )
)
SELECT 
    mva.Media_Qtd_Vendas, 
    va.Qtd_Vendas_Atual, 
    ROUND(((va.Qtd_Vendas_Atual - mva.Media_Qtd_Vendas) / mva.Media_Qtd_Vendas) * 100.0, 2) || '%' AS Porcentagem 
FROM Vendas_Atual va, Media_Vendas_Anteriores mva;
