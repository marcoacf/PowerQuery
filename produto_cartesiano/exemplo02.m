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
    
    /* Inclui versão */
    #"Add_Versao" = Table.AddColumn(Source, "VERSAO", each TB_VERSAO),
    #"Expanded VERSAO" = Table.ExpandTableColumn(#"Add_Versao", "VERSAO", {"VERSAO"}, {"VERSAO"}),

    /* Inclui produto */
    #"Add_Produto" = Table.AddColumn(#"Expanded VERSAO", "PRODUTO", each TB_PRODUTO),
    #"Expanded PRODUTO" = Table.ExpandTableColumn(#"Add_Produto", "PRODUTO", {"PRODUTO"}, {"PRODUTO"}),

    /* Inclui tipo de fatura */
    #"Add_TipoFat" = Table.AddColumn(#"Expanded PRODUTO", "TIPO_FATURA", each TB_TIPO_FATURA),
    #"Expanded TIPO_FATURA" = Table.ExpandTableColumn(#"Add_TipoFat", "TIPO_FATURA", {"TIPO_FATURA", "ABA"}, {"TIPO_FATURA", "ABA"}),
    
    matriz_pronta = #"Expanded TIPO_FATURA"
in
    matriz_pronta
