let
    // Passo 1: Criar Tabela A
    TabelaA = Table.FromRecords({
        [ID_A = 1, Nome = "Ana"],
        [ID_A = 2, Nome = "Bruno"]
    }),
    
    // Passo 2: Criar Tabela B
    TabelaB = Table.FromRecords({
        [ID_B = 1, Cidade = "São Paulo"],
        [ID_B = 2, Cidade = "Rio de Janeiro"]
    }),
    
    // Passo 3: Adicionar Coluna Personalizada com TabelaB
    AdicionarColuna = Table.AddColumn(TabelaA, "TabelaB", each TabelaB),
    
    // Passo 4: Expandir a TabelaB
    ProdutoCartesiano = Table.ExpandTableColumn(AdicionarColuna, "TabelaB", {"ID_B", "Cidade"})
in
    ProdutoCartesiano
