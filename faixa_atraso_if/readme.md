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

```M
let
    // Passo 1: Definir a tabela de faturas
    Faturas = Table.FromRecords({
        [numero_fatura = "001", data_vencimento = #date(2025, 2, 15), data_vencimento_prorrogado = null, valor = 500.50],
        [numero_fatura = "002", data_vencimento = #date(2024, 11, 30), data_vencimento_prorrogado = #date(2024, 12, 31), valor = 1000.00],
        [numero_fatura = "003", data_vencimento = #date(2024, 10, 10), data_vencimento_prorrogado = null, valor = 750.00],
        [numero_fatura = "004", data_vencimento = #date(2022, 10, 10), data_vencimento_prorrogado = #date(2022, 12, 10), valor = 75000.00],
        [numero_fatura = "005", data_vencimento = #date(2024, 9, 10), data_vencimento_prorrogado = null, valor = 950.00],
        [numero_fatura = "006", data_vencimento = #date(2024, 8, 5), data_vencimento_prorrogado = null, valor = 750.00],
        [numero_fatura = "007", data_vencimento = #date(2024, 11, 10), data_vencimento_prorrogado = null, valor = 750.00],
        [numero_fatura = "008", data_vencimento = #date(2024, 7, 10), data_vencimento_prorrogado = null, valor = 750.00],
        [numero_fatura = "009", data_vencimento = #date(2024, 6, 10), data_vencimento_prorrogado = null, valor = 750.00],
        [numero_fatura = "010", data_vencimento = #date(2024, 5, 10), data_vencimento_prorrogado = null, valor = 750.00]
    }),

    // Passo 2: Ajustar tipos e valores iniciais
    FaturasTipadas = Table.TransformColumnTypes(Faturas, {
        {"numero_fatura", type text},
        {"data_vencimento", type date},
        {"data_vencimento_prorrogado", type nullable date},
        {"valor", type number}
    }),

    // Passo 3: Definir a tabela de faixas de atraso
    Faixas = Table.FromRecords({
        [id = 1, faixa = "a vencer", max_dia = 0],
        [id = 2, faixa = "1 a 30", max_dia = 30],
        [id = 3, faixa = "31 a 60", max_dia = 60],
        [id = 4, faixa = "61 a 90", max_dia = 90],
        [id = 5, faixa = "91 a 120", max_dia = 120],
        [id = 6, faixa = "121 a 150", max_dia = 150],
        [id = 7, faixa = "151 a 180", max_dia = 180],
        [id = 8, faixa = "181 a 210", max_dia = 210],
        [id = 9, faixa = ">210", max_dia = null]
    }),

    // Passo 4: Parâmetro de data base
    DataBase = #date(2025, 01, 01), // Substituir pela data desejada

    // Passo 5: Calcular dias de atraso
    FaturasComAtraso = Table.AddColumn(FaturasTipadas, "dias_atraso", each 
        let 
            vencimentoUsado = if [data_vencimento_prorrogado] <> null then [data_vencimento_prorrogado] else [data_vencimento],
            diasAtraso = Duration.Days(DataBase - vencimentoUsado)
        in 
            if diasAtraso < 0 then 0 else diasAtraso, // Garantir que valores negativos não ocorram
        Int64.Type
    ),

    // Passo 6: Classificar as faturas com base nas faixas
    FaturasClassificadas = Table.AddColumn(FaturasComAtraso, "faixa_atraso", each 
        let
            dias = [dias_atraso],
            faixaEncontrada = Table.SelectRows(Faixas, (faixa) => 
                if faixa[max_dia] = null then dias > 210 else dias <= faixa[max_dia]
            )
        in
            if Table.IsEmpty(faixaEncontrada) then null else faixaEncontrada{0}[faixa],
        type text
    ),

    // Passo 7: Ordenar por dias de atraso
    FaturasOrdenadas = Table.Sort(FaturasClassificadas, {{"dias_atraso", Order.Ascending}}),

    // Passo 8: Agrupar resultados
    ResultadoAgrupado = Table.Group(FaturasOrdenadas, {"faixa_atraso"}, {
        {"Qtde Faturas", each Table.RowCount(_), Int64.Type},
        {"Valor", each List.Sum([valor]), type nullable number}
    })
in
    ResultadoAgrupado

```
