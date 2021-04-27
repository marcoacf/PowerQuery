/*
#  Criar uma tabela usando o anexo estatístico
  
##  preencher céluas vazias da 1ª linha com "x"
  
##  Usar 
  * Base - Pós - Puro - Voz
  * Base - Pós - Controle - Voz
*/
```
let
    Source = Excel.CurrentWorkbook(){[Name="Table1"]}[Content],
    Filtro = Table.SelectRows(Source, each ([x] = "Base - Pós - Controle - Voz" or [x] = "Base - Pós - Puro - Voz")),
    ExclCol = Table.RemoveColumns(Filtro,{"x3", "YTD-19", "x4", "x5", "YTD-20"}), /* editar essa linha */
    TipoFat = Table.AddColumn(ExclCol, "Tipo_Fatura", 
        each if Text.Contains(Text.Upper([x2]), "EXPRESS") then "Express" else "Fatura", type text),
    Despivotar = Table.UnpivotOtherColumns(TipoFat, {"x", "x2", "Tipo_Fatura"}, "Mes", "Valor"),
    Renomear = Table.RenameColumns(Despivotar,{{"x", "Indicador"}, {"x2", "Plano"}}),
    AlterTipo = Table.TransformColumnTypes(Renomear,{{"Valor", type number},{"Mes", type date}})
in
    AlterTipo
```
