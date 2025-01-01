### Tabelas de entrada:

1. A tabela Faturas contém os dados de faturas.
A tabela Faixas contém as faixas de atraso que são usadas para classificação.

2. Cálculo de dias de atraso:

O cálculo verifica se data_vencimento_prorrogado está preenchido.
Se estiver, usa essa data para o cálculo; caso contrário, utiliza data_vencimento.

3. Classificação nas faixas de atraso:

Para cada fatura, verifica-se qual faixa de atraso corresponde ao número de dias calculado.
As condições lidam com faixas específicas (max_dia) e a faixa final (>210).

4. Data Base como Parâmetro:

A variável DataBase pode ser alterada para a data que você deseja como base para o cálculo.
