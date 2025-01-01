# Produto Cartesiano
O produto cartesiano é uma operação fundamental em banco de dados e matemática relacional. Ele é usado para combinar cada linha de uma tabela com todas as linhas de outra tabela. Aqui estão os principais pontos sobre o produto cartesiano em bancos de dados:

### Definição:
Se você tem duas tabelas A e B:
A tem m linhas e n colunas.
B tem p linhas e q colunas.
O produto cartesiano de A e B terá m x p linhas e n + q colunas.
Cada linha da tabela A será combinada com cada linha da tabela B.

### Exemplo:
Suponha que temos as tabelas A e B:

Tabela A

|ID|Nome|
|--|---|
|1|Ana|
|2|Bruno|
Tabela B

ID	Cidade
1	São Paulo
2	Rio de Janeiro
O produto cartesiano 
𝐴
×
𝐵
A×B será:

ID_A	Nome	ID_B	Cidade
1	Ana	1	São Paulo
1	Ana	2	Rio de Janeiro
2	Bruno	1	São Paulo
2	Bruno	2	Rio de Janeiro
Considerações:
Tamanho dos resultados: O produto cartesiano pode gerar tabelas muito grandes se as tabelas originais tiverem muitas linhas. É importante usá-lo com cuidado.
