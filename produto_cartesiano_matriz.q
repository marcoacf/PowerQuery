let
/*
    Produto Cartesiano / Matriz resultante de junção de tabelas
    ====================================================================
    Adicionar uma coluna customizada e referenciar a tabela desejada
    Em seguida, basta expandir a tabela.
    Pronto!
    --------------------------------------------------------------------
*/
    Source = TB_ORCAMENTO,
    #"Added Custom" = Table.AddColumn(Source, "VERSAO", each TB_VERSAO),
    #"Expanded VERSAO" = Table.ExpandTableColumn(#"Added Custom", "VERSAO", {"VERSAO"}, {"VERSAO"}),
    #"Added Custom1" = Table.AddColumn(#"Expanded VERSAO", "PRODUTO", each TB_PRODUTO),
    #"Expanded PRODUTO" = Table.ExpandTableColumn(#"Added Custom1", "PRODUTO", {"PRODUTO"}, {"PRODUTO"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded PRODUTO", "TIPO_FATURA", each TB_TIPO_FATURA),
    #"Expanded TIPO_FATURA" = Table.ExpandTableColumn(#"Added Custom2", "TIPO_FATURA", {"TIPO_FATURA", "ABA"}, {"TIPO_FATURA", "ABA"}),
    #"Added Custom3" = Table.AddColumn(#"Expanded TIPO_FATURA", "MOTIVO", each TB_MOTIVO),
    #"Expanded MOTIVO" = Table.ExpandTableColumn(#"Added Custom3", "MOTIVO", {"MOTIVO"}, {"MOTIVO"}),
    #"Added Custom4" = Table.AddColumn(#"Expanded MOTIVO", "CANAIS", each TB_CANAIS),
    #"Expanded CANAIS" = Table.ExpandTableColumn(#"Added Custom4", "CANAIS", {"CANAL_N0", "CANAL_N2"}, {"CANAL_N0", "CANAL_N2"}),
    #"Added Custom5" = Table.AddColumn(#"Expanded CANAIS", "MOV", each TB_MOV_AGING),
    #"Expanded MOV" = Table.ExpandTableColumn(#"Added Custom5", "MOV", {"MOVIMENTACAO", "AGING"}, {"MOVIMENTACAO", "AGING"})
    matriz_pronta = #"Expanded MOV"
in
    matriz_pronta
