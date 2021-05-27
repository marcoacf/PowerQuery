// fx_MesesEntreDatas
let MesesEntreDatas = 
        (StartDate as datetime,EndDate as datetime) => 
        let
            ListDates = {Number.From(#date(Date.Year(StartDate),Date.Month(StartDate),Date.Day(StartDate)))..Number.From(#date(Date.Year(EndDate),Date.Month(EndDate),Date.Day(EndDate)))},
            ConvertTable = Table.FromList(ListDates, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
            AlterType = Table.TransformColumnTypes(ConvertTable,{{"Column1", type date}}),
            AddCol = Table.AddColumn(AlterType, "Month Year", each Date.ToText([Column1],"MMM-yyyy")),
            GroupMonths = Table.Group(AddCol, {"Month Year"}, {{"Count", each Table.RowCount(_), Int64.Type}}),
            CountRows = Table.RowCount(GroupMonths)
    in
        CountRows
in
    MesesEntreDatas

// fx_DefineMes
let
    fx_DefineMes = (input) => let
        values = {
        {1, "Jan"},
        {2, "Fev"},
        {3, "Mar"},
        {4, "Abr"},
        {5, "Mai"},
        {6, "Jun"},
        {7, "Jul"},
        {8, "Ago"},
        {9, "Set"},
        {10, "Out"},
        {11, "Nov"},
        {12, "Dez"},
        {input, "indefinido"}
        },
        Result = List.First(List.Select(values, each _{0}=input)){1}
    in
        Result
in
    fx_DefineMes

// fx_CalendarioMensal
/*
Dependências:
    fx_DefineMes - https://github.com/marcoacf/PowerQuery/blob/main/fx_DefineMes.txt
*/
let dCalendarioMensal =
    (AnoInicial, AnoFinal) 
    as table =>

    let
        ListaAnos = Table.FromList({AnoInicial..AnoFinal}, Splitter.SplitByNothing(), null,null, ExtraValues.Error),
        RenomColAno = Table.RenameColumns(ListaAnos,{{"Column1", "Ano"}}),
        AddMeses = Table.AddColumn(RenomColAno, "MesNr", each {1..12}),
        MostrarMeses = Table.ExpandListColumn(AddMeses, "MesNr"),
        CriarDataMes = Table.AddColumn(MostrarMeses, "Mes_Ref", each #date([Ano],[MesNr],1)),
        TipoDataMesRef = Table.TransformColumnTypes(CriarDataMes,{{"Mes_Ref", type date}}),

        UltiDiaMes = Table.AddColumn(TipoDataMesRef , "Ulti_Dia_Mes", each Date.EndOfMonth([Mes_Ref])  ),
        
        //Criando Trimestre
        Trimestre = Table.AddColumn(UltiDiaMes , "Trimestre", 
        each "Q" & Number.ToText(Date.QuarterOfYear([Mes_Ref])), type text),
        //Numero Mês
        DataINT = Table.AddColumn(Trimestre, "DateInt", each [Ano]*100 + [MesNr], Int64.Type),
        NomeMes = Table.AddColumn(DataINT , "Mes", 
        each fx_DefineMes(Date.Month([Mes_Ref])), type text),

        MesMaiusculo = Table.TransformColumns(NomeMes,{{"Mes", Text.Proper, type text}}),
        //Mês-Ano
        MesAno= Table.AddColumn(MesMaiusculo, "MesNr_Ano", 
        each Text.Combine({Text.PadStart(Text.From([MesNr], "pt-BR"),2,"0"), Text.From([Ano], "pt-BR")}, "-"), type text),

        MesAno2= Table.AddColumn(MesAno, "Mes_Ano", 
        each Text.Combine({[Mes], Text.End(Text.From([Ano], "pt-BR"),2)}, "/"), type text),

        /* Reordenar Colunas */
        ReordenarCols = Table.ReorderColumns(MesAno2,{"Mes_Ref", "Ulti_Dia_Mes", "Ano", "MesNr", "Trimestre", "DateInt", "Mes", "MesNr_Ano", "Mes_Ano"}),

        Pronto=ReordenarCols

    in
        Pronto
in
    dCalendarioMensal

// fx_Calendario
//DI = Data Início
//DF = Data Fim
// fonte: https://www.minhasplanilhas.com.br/criar-tabela-calandario-em-m-no-power-bi/

let dCalendario =(DI as date, DF as date) as table =>

let
//Contar número de dias entre a data de início e fim
 Dias = Duration.Days(DF - DI) +1,
//Criando uma lista de datas
 Datas = List.Dates(DI, Dias, 
 #duration(1,0,0,0)),
//Converter Lista em Tabela
 ListaparaTabela = Table.FromList(Datas, 
 Splitter.SplitByNothing(), {"Data"}, null, ExtraValues.Error ),
AlterarTipo = Table.TransformColumnTypes(ListaparaTabela,{{"Data", type date}}),
//Criando Colunas adicionais
// Primeiro dia do Mês
PrimDiaMes = Table.AddColumn(AlterarTipo, "Prim_Dia_Mes", each Date.StartOfMonth([Data])),
UltiDiaMes = Table.AddColumn(PrimDiaMes , "Ulti_Dia_Mes", each Date.EndOfMonth([Data])  ),
 //Coluna Ano
 Ano = Table.AddColumn(UltiDiaMes, "Ano", 
 each Date.Year([Data]), Int64.Type),
//Criando Trimestre
 Trimestre = Table.AddColumn(Ano , "Trimestre", 
 each "Q" & Number.ToText(Date.QuarterOfYear([Data])), type text),
//Número da Semana
 NumeroSemana = Table.AddColumn(Trimestre , "Numero_Semana", 
 each Date.WeekOfYear([Data]), Int64.Type),
//Numero Mês
 MesNumero = Table.AddColumn(NumeroSemana, "Numero_Mes", 
 each Date.Month([Data]), Int64.Type),
 DiaNumero = Table.AddColumn(MesNumero, "Numero_Dia", 
 each Date.Day([Data]), Int64.Type),
 DataINT = Table.AddColumn(DiaNumero, "DateInt", each [Ano]*100 + [Numero_Mes], Int64.Type),
//Nome do Mes
/* NomeMes = Table.AddColumn(DataINT , "Mes", 
 each Date.ToText([Data],"MMM"), type text),
*/
NomeMes = Table.AddColumn(DataINT , "Mes", 
 each fx_DefineMes(Date.Month([Data])), type text),

 MesMaiusculo = Table.TransformColumns(NomeMes,{{"Mes", Text.Proper, type text}}),
//Dia da Semana
 DiaDaSemana = Table.AddColumn(MesMaiusculo , "Dia_Semana", 
 each Date.ToText([Data],"dddd"), type text),
 // Dia do Ano
 DiaAno = Table.AddColumn(DiaDaSemana, "Dia_Ano",
 each Number.RoundDown(Duration.Days([Data]-#date([Ano],1,1))+1)),

//

SemanaMes = Table.AddColumn(DiaDaSemana, "Semana_Mes",
 each Date.WeekOfMonth([Data])), 

/* Number.RoundDown(Duration.Days([Data]-#date([Ano],1,1))+1)),
weekinmonth = 1 + WEEKNUM ( 'Calenda'[Date] )-WEEKNUM( STARTOFMONTH ('Calenda'[Date]))*/

//Mês-Ano
MesAno= Table.AddColumn(SemanaMes, "MesNr_Ano", 
 each Text.Combine({Text.PadStart(Text.From([Numero_Mes], "pt-BR"),2,"0"), Text.From([Ano], "pt-BR")}, "-"), type text),

 MesAno2= Table.AddColumn(MesAno, "Mes_Ano", 
 each Text.Combine({[Mes], Text.End(Text.From([Ano], "pt-BR"),2)}, "/"), type text),




Pronto = Table.Sort(MesAno2,{{"Data", Order.Ascending}})
in
 Pronto

in dCalendario

// fx_ConverteBinarioXLS
let
    Fonte = (Aba, ConteudoBinario) => let
        Fonte = Excel.Workbook(ConteudoBinario, null, true),
        Planilha = Fonte{[Item=Aba,Kind="Sheet"]}[Data],
        Pronto = Table.PromoteHeaders(Planilha, [PromoteAllScalars=true])
    in
        Pronto
in
    Fonte

// ArquivoCarga
"C:\Users\F8050751\OneDrive - TIM\Planning_Business_Churn\demandas\Net Adds\PowerBI\Insumos\arquivo_de_carga.xlsx" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

// dpTransporColunas
let
    Fonte = Excel.Workbook(File.Contents(ArquivoCarga), null, true),
    TransporColunas_Sheet = Fonte{[Item="TransporColunas",Kind="Sheet"]}[Data],
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(TransporColunas_Sheet, [PromoteAllScalars=true]),
    #"Linhas Filtradas" = Table.SelectRows(#"Cabeçalhos Promovidos", each ([TituloColuna] <> null)),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Linhas Filtradas",{{"Numero", Int64.Type}, {"TituloColuna", type text}, {"Mes_Ref", type date}, {"Versao", type text}, {"VersaoGrupo", type text}, {"Analise_Hist_Flag", type text}, {"Analise_Hist_Label", type text}, {"UltimaPrevTend", type text}})
in
    #"Tipo Alterado"

// insumo_voicelines
let
    /*  etapa 1 - Contrói a tabela "fato do Net Adds" "despivotando" o arquivo de carga...   ******************  */
        DefineAba = "voicelines",
        Fonte = Excel.Workbook(File.Contents(ArquivoCarga), null, true),
        Dados = Fonte{[Item=DefineAba,Kind="Sheet"]}[Data],
        SetHeader = Table.PromoteHeaders(Dados, [PromoteAllScalars=true]),
        FiltLines = Table.SelectRows(SetHeader, each ([Visao] <> null)),
        AlterType = Table.TransformColumnTypes(FiltLines,{
                                                            {"Visao", type text}, 
                                                            {"Ordem", Int64.Type}, 
                                                            {"KPI", type text}, 
                                                            {"Produto", type text}, 
                                                            {"Drill_N1", type text}, 
                                                            {"Drill_N2", type text}, 
                                                            {"Drill_N3", type text},
                                                            {"SomaHierarquia", type text} ,
                                                            {"Fonte_Realizado", type text}, 
                                                            {"Fonte_Previa", type text}, 
                                                            {"Fonte_Tendencia", type text}, 
                                                            {"Fonte_Orcamento", type text}, 
                                                            {"Versao", type text}
                                                        }),    
        Despivotar = Table.UnpivotOtherColumns(AlterType, {"Visao", 
                                                                "Ordem", 
                                                                "KPI", 
                                                                "Produto", 
                                                                "Drill_N1", 
                                                                "Drill_N2", 
                                                                "Drill_N3", 
                                                                "SomaHierarquia",
                                                                "Fonte_Realizado", 
                                                                "Fonte_Previa", 
                                                                "Fonte_Tendencia", 
                                                                "Fonte_Orcamento", 
                                                                "Versao"}, "Atributo", "Valor"),
        /* ATENÇÃO: Garantir adevida manutenção da tabela 'dpTransporColunas' no excel de carga, por favor! */
        JuncaoDP = Table.NestedJoin(Despivotar, {"Atributo"}, dpTransporColunas, {"TituloColuna"}, "dpTransporColunas", JoinKind.LeftOuter),
        ExpandirJuncao = Table.ExpandTableColumn(JuncaoDP, "dpTransporColunas", 
                                                    {"Mes_Ref", "Versao", "OrcamentoApelido", "VersaoGrupo"}, 
                                                    {"Mes_Ref", "Versao_Orcamento", "OrcamentoApelido", "Versao_Orcamento_Grupo"}),
        DadosOK= ExpandirJuncao,
        AlterType2 = Table.TransformColumnTypes(DadosOK,{{"Valor", type number}}),
        SubstError = Table.ReplaceErrorValues(AlterType2, {{"Valor", 0}}),
        AjusteValor = 
            Table.AddColumn(SubstError, "Valor_novo", 
                each if ([KPI] = "Churn Rate" or [KPI] = "Saída") then -[Valor] 
                    else [Valor], type number),
        RenomCols = Table.RenameColumns(AjusteValor,{{"Valor", "Valor_Orig"}, {"Valor_novo", "Valor"}}),
        #"Colunas Removidas" = Table.RemoveColumns(RenomCols,{"Valor_Orig"}),
        
        /* Aqui os dados são "congelados" em memória RAM (para evitar lentidão por reprocessamento desnecessário) */
        BufferRAM = Table.Buffer(#"Colunas Removidas"),        
        FiltroOutros = Table.SelectRows(BufferRAM, each  ([KPI] <> "Base Média" and [KPI] <> "Churn Rate") ),
    /* etapa 2 - incluir a base média e o volume de churn no "fato churn"  *************************************** */
        FiltroKPI = Table.SelectRows(BufferRAM, each ([KPI] = "Base Média" or [KPI] = "Churn Rate") ),

        TabA =FiltroKPI,
        FiltroChurnRate = Table.SelectRows(TabA, each ([KPI] = "Churn Rate")),

        TabB =FiltroKPI,
        FiltroBaseMedia = Table.SelectRows(TabB, each ([KPI] = "Base Média")),

        Juncao = Table.NestedJoin(FiltroChurnRate, 
            {"Visao", "Ordem", "Produto", "Drill_N1", "Drill_N2", "Drill_N3", "Mes_Ref", "Versao_Orcamento"}, 
            FiltroBaseMedia, 
            {"Visao", "Ordem", "Produto", "Drill_N1", "Drill_N2", "Drill_N3", "Mes_Ref", "Versao_Orcamento"}, 
            "BaseMedia", JoinKind.LeftOuter),
            
        Expandir = Table.ExpandTableColumn(Juncao, "BaseMedia", {"Valor"}, {"BaseMedia"}),
        CalcularChurn = Table.AddColumn(Expandir, "Churn", each [Valor] * [BaseMedia] / 100, type number),
    /* etapa 2 - fim da etapa ************************************************************************************* */

    /* etapa final juntar etapas ********************************************************************************** */
    AddColBaseM = Table.AddColumn(FiltroOutros, "BaseMedia", each null, type number),
    AddColChurn = Table.AddColumn(AddColBaseM , "Churn"    , each null, type number),
    /* Inserir a lista de Insumos */
    Final = Table.Combine({AddColChurn,CalcularChurn})
in
    Final

// insumo_pre
let
    /*  etapa 1 - Contrói a tabela "fato do Net Adds" "despivotando" o arquivo de carga...   ******************  */
        DefineAba = "pre",
        Fonte = Excel.Workbook(File.Contents(ArquivoCarga), null, true),
        Dados = Fonte{[Item=DefineAba,Kind="Sheet"]}[Data],
        SetHeader = Table.PromoteHeaders(Dados, [PromoteAllScalars=true]),
        FiltLines = Table.SelectRows(SetHeader, each ([Visao] <> null)),
        AlterType = Table.TransformColumnTypes(FiltLines,{
                                                            {"Visao", type text}, 
                                                            {"Ordem", Int64.Type}, 
                                                            {"KPI", type text}, 
                                                            {"Produto", type text}, 
                                                            {"Drill_N1", type text}, 
                                                            {"Drill_N2", type text}, 
                                                            {"Drill_N3", type text},
                                                            {"SomaHierarquia", type text} ,
                                                            {"Fonte_Realizado", type text}, 
                                                            {"Fonte_Previa", type text}, 
                                                            {"Fonte_Tendencia", type text}, 
                                                            {"Fonte_Orcamento", type text}, 
                                                            {"Versao", type text}
                                                        }),    
        Despivotar = Table.UnpivotOtherColumns(AlterType, {"Visao", 
                                                                "Ordem", 
                                                                "KPI", 
                                                                "Produto", 
                                                                "Drill_N1", 
                                                                "Drill_N2", 
                                                                "Drill_N3", 
                                                                "SomaHierarquia",
                                                                "Fonte_Realizado", 
                                                                "Fonte_Previa", 
                                                                "Fonte_Tendencia", 
                                                                "Fonte_Orcamento", 
                                                                "Versao"}, "Atributo", "Valor"),
        /* ATENÇÃO: Garantir adevida manutenção da tabela 'dpTransporColunas' no excel de carga, por favor! */
        JuncaoDP = Table.NestedJoin(Despivotar, {"Atributo"}, dpTransporColunas, {"TituloColuna"}, "dpTransporColunas", JoinKind.LeftOuter),
        ExpandirJuncao = Table.ExpandTableColumn(JuncaoDP, "dpTransporColunas", 
                                                    {"Mes_Ref", "Versao", "OrcamentoApelido", "VersaoGrupo"}, 
                                                    {"Mes_Ref", "Versao_Orcamento", "OrcamentoApelido", "Versao_Orcamento_Grupo"}),
        DadosOK= ExpandirJuncao,
        AlterType2 = Table.TransformColumnTypes(DadosOK,{{"Valor", type number}}),
        SubstError = Table.ReplaceErrorValues(AlterType2, {{"Valor", 0}}),
        AjusteValor = 
            Table.AddColumn(SubstError, "Valor_novo", 
                each if ([KPI] = "Churn Rate" or [KPI] = "Saída") then -[Valor] 
                    else [Valor], type number),
        RenomCols = Table.RenameColumns(AjusteValor,{{"Valor", "Valor_Orig"}, {"Valor_novo", "Valor"}}),
        #"Colunas Removidas" = Table.RemoveColumns(RenomCols,{"Valor_Orig"}),
        
        /* Aqui os dados são "congelados" em memória RAM (para evitar lentidão por reprocessamento desnecessário) */
        BufferRAM = Table.Buffer(#"Colunas Removidas"),        
        FiltroOutros = Table.SelectRows(BufferRAM, each  ([KPI] <> "Base Média" and [KPI] <> "Churn Rate") ),
    /* etapa 2 - incluir a base média e o volume de churn no "fato churn"  *************************************** */
        FiltroKPI = Table.SelectRows(BufferRAM, each ([KPI] = "Base Média" or [KPI] = "Churn Rate") ),

        TabA =FiltroKPI,
        FiltroChurnRate = Table.SelectRows(TabA, each ([KPI] = "Churn Rate")),

        TabB =FiltroKPI,
        FiltroBaseMedia = Table.SelectRows(TabB, each ([KPI] = "Base Média")),

        Juncao = Table.NestedJoin(FiltroChurnRate, 
            {"Visao", "Ordem", "Produto", "Drill_N1", "Drill_N2", "Drill_N3", "Mes_Ref", "Versao_Orcamento"}, 
            FiltroBaseMedia, 
            {"Visao", "Ordem", "Produto", "Drill_N1", "Drill_N2", "Drill_N3", "Mes_Ref", "Versao_Orcamento"}, 
            "BaseMedia", JoinKind.LeftOuter),
            
        Expandir = Table.ExpandTableColumn(Juncao, "BaseMedia", {"Valor"}, {"BaseMedia"}),
        CalcularChurn = Table.AddColumn(Expandir, "Churn", each [Valor] * [BaseMedia] / 100, type number),
    /* etapa 2 - fim da etapa ************************************************************************************* */

    /* etapa final juntar etapas ********************************************************************************** */
    AddColBaseM = Table.AddColumn(FiltroOutros, "BaseMedia", each null, type number),
    AddColChurn = Table.AddColumn(AddColBaseM , "Churn"    , each null, type number),
    /* Inserir a lista de Insumos */
    Final = Table.Combine({AddColChurn,CalcularChurn})
in
    Final

// insumo_web
let
    /*  etapa 1 - Contrói a tabela "fato do Net Adds" "despivotando" o arquivo de carga...   ******************  */
        DefineAba = "web",
        Fonte = Excel.Workbook(File.Contents(ArquivoCarga), null, true),
        Dados = Fonte{[Item=DefineAba,Kind="Sheet"]}[Data],
        SetHeader = Table.PromoteHeaders(Dados, [PromoteAllScalars=true]),
        FiltLines = Table.SelectRows(SetHeader, each ([Visao] <> null)),
        AlterType = Table.TransformColumnTypes(FiltLines,{
                                                            {"Visao", type text}, 
                                                            {"Ordem", Int64.Type}, 
                                                            {"KPI", type text}, 
                                                            {"Produto", type text}, 
                                                            {"Drill_N1", type text}, 
                                                            {"Drill_N2", type text}, 
                                                            {"Drill_N3", type text},
                                                            {"SomaHierarquia", type text} ,
                                                            {"Fonte_Realizado", type text}, 
                                                            {"Fonte_Previa", type text}, 
                                                            {"Fonte_Tendencia", type text}, 
                                                            {"Fonte_Orcamento", type text}, 
                                                            {"Versao", type text}
                                                        }),    
        Despivotar = Table.UnpivotOtherColumns(AlterType, {"Visao", 
                                                                "Ordem", 
                                                                "KPI", 
                                                                "Produto", 
                                                                "Drill_N1", 
                                                                "Drill_N2", 
                                                                "Drill_N3", 
                                                                "SomaHierarquia",
                                                                "Fonte_Realizado", 
                                                                "Fonte_Previa", 
                                                                "Fonte_Tendencia", 
                                                                "Fonte_Orcamento", 
                                                                "Versao"}, "Atributo", "Valor"),
        /* ATENÇÃO: Garantir adevida manutenção da tabela 'dpTransporColunas' no excel de carga, por favor! */
        JuncaoDP = Table.NestedJoin(Despivotar, {"Atributo"}, dpTransporColunas, {"TituloColuna"}, "dpTransporColunas", JoinKind.LeftOuter),
        ExpandirJuncao = Table.ExpandTableColumn(JuncaoDP, "dpTransporColunas", 
                                                    {"Mes_Ref", "Versao", "OrcamentoApelido", "VersaoGrupo"}, 
                                                    {"Mes_Ref", "Versao_Orcamento", "OrcamentoApelido", "Versao_Orcamento_Grupo"}),
        DadosOK= ExpandirJuncao,
        AlterType2 = Table.TransformColumnTypes(DadosOK,{{"Valor", type number}}),
        SubstError = Table.ReplaceErrorValues(AlterType2, {{"Valor", 0}}),
        AjusteValor = 
            Table.AddColumn(SubstError, "Valor_novo", 
                each if ([KPI] = "Churn Rate" or [KPI] = "Saída") then -[Valor] 
                    else [Valor], type number),
        RenomCols = Table.RenameColumns(AjusteValor,{{"Valor", "Valor_Orig"}, {"Valor_novo", "Valor"}}),
        #"Colunas Removidas" = Table.RemoveColumns(RenomCols,{"Valor_Orig"}),
        
        /* Aqui os dados são "congelados" em memória RAM (para evitar lentidão por reprocessamento desnecessário) */
        BufferRAM = Table.Buffer(#"Colunas Removidas"),        
        FiltroOutros = Table.SelectRows(BufferRAM, each  ([KPI] <> "Base Média" and [KPI] <> "Churn Rate") ),
    /* etapa 2 - incluir a base média e o volume de churn no "fato churn"  *************************************** */
        FiltroKPI = Table.SelectRows(BufferRAM, each ([KPI] = "Base Média" or [KPI] = "Churn Rate") ),

        TabA =FiltroKPI,
        FiltroChurnRate = Table.SelectRows(TabA, each ([KPI] = "Churn Rate")),

        TabB =FiltroKPI,
        FiltroBaseMedia = Table.SelectRows(TabB, each ([KPI] = "Base Média")),

        Juncao = Table.NestedJoin(FiltroChurnRate, 
            {"Visao", "Ordem", "Produto", "Drill_N1", "Drill_N2", "Drill_N3", "Mes_Ref", "Versao_Orcamento"}, 
            FiltroBaseMedia, 
            {"Visao", "Ordem", "Produto", "Drill_N1", "Drill_N2", "Drill_N3", "Mes_Ref", "Versao_Orcamento"}, 
            "BaseMedia", JoinKind.LeftOuter),
            
        Expandir = Table.ExpandTableColumn(Juncao, "BaseMedia", {"Valor"}, {"BaseMedia"}),
        CalcularChurn = Table.AddColumn(Expandir, "Churn", each [Valor] * [BaseMedia] / 100, type number),
    /* etapa 2 - fim da etapa ************************************************************************************* */

    /* etapa final juntar etapas ********************************************************************************** */
    AddColBaseM = Table.AddColumn(FiltroOutros, "BaseMedia", each null, type number),
    AddColChurn = Table.AddColumn(AddColBaseM , "Churn"    , each null, type number),
    /* Inserir a lista de Insumos */
    Final = Table.Combine({AddColChurn,CalcularChurn})
in
    Final

// insumo_total
let
    /* Inserir a lista de Insumos */
    Fonte = Table.Combine({insumo_voicelines, insumo_pre, insumo_web}),

    MesAno = Table.AddColumn(Fonte, "Mes_Ano", 
                each Text.Combine({fx_DefineMes(Date.Month([Mes_Ref])), 
                                   Text.End(Text.From(Date.Year([Mes_Ref]), "pt-BR"),2)}, "/"), type text),
    separador = 
    "
    ",
    MesOrcRef = Table.AddColumn(MesAno, "OrcamentoMes", each Text.Combine({[OrcamentoApelido], separador,[Mes_Ano]},"")),
    AlterTyp = Table.TransformColumnTypes(MesOrcRef,{{"OrcamentoMes", type text}, {"Mes_Ano", type text}}),
    FiltKPI = Table.SelectRows(AlterTyp, each [KPI] <> "xChrun Ratex" and [KPI] <> "xCHURN RATEx"),
    #"Colunas Removidas" = Table.RemoveColumns(FiltKPI,{"Ordem", "Fonte_Realizado", "Fonte_Previa", "Fonte_Tendencia", "Fonte_Orcamento", "Versao",  "OrcamentoApelido", "Versao_Orcamento_Grupo", "Mes_Ano", "OrcamentoMes"}),
    #"Colunas Reordenadas" = Table.ReorderColumns(#"Colunas Removidas",{"Visao", "KPI", "Produto", "Drill_N1", "Drill_N2", "Drill_N3", "Versao_Orcamento", "Mes_Ref", "Valor"})
    /*,
    #"Valor absoluto inserido" = 
        Table.AddColumn(#"Colunas Reordenadas", 
            "Valor_novo", 
            each (if ([KPI] = "Churn Rate" or [KPI] = "Saída") then [Valor]*-1
                  else [Valor]*1), type number),
    #"Colunas Renomeadas" = Table.RenameColumns(#"Valor absoluto inserido",{{"Valor", "Valor_old"}, {"Valor_novo", "Valor"}})*/
in
    #"Colunas Reordenadas"

// MesesAux
let
    Fonte = Table.FromList(
    {
        [MesID = "Jan", MesNumero = 1],
        [MesID = "Fev", MesNumero = 2],
        [MesID = "Mar", MesNumero = 3],
        [MesID = "Abr", MesNumero = 4],
        [MesID = "Mai", MesNumero = 5],
        [MesID = "Jun", MesNumero = 6],
        [MesID = "Jul", MesNumero = 7],
        [MesID = "Ago", MesNumero = 8],
        [MesID = "Set", MesNumero = 9],
        [MesID = "Out", MesNumero = 10],
        [MesID = "Nov", MesNumero = 11],
        [MesID = "Dez", MesNumero = 12]
    },
    Record.FieldValues,
    {"MesID", "MesNumero"}
)
in
    Fonte

// OrcamentoAux
let
    Fonte = Table.FromList(
    {
        [OrcamentoID = "ACT", OrcamentoNome = "Actual", OrcamentoApelido="Act", OrcamentoTipo="Realizado"],
        [OrcamentoID = "PC", OrcamentoNome = "PreClosing", OrcamentoApelido="PC", OrcamentoTipo="Realizado"],

        /* Orçamentos */
        [OrcamentoID = "BDGT", OrcamentoNome = "Budget", OrcamentoApelido="Bdgt", OrcamentoTipo="Orçamento"],

        [OrcamentoID = "F0.12", OrcamentoNome = "Forecast", OrcamentoApelido="0+12", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F1.11", OrcamentoNome = "Forecast", OrcamentoApelido="1+11", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F2.10", OrcamentoNome = "Forecast", OrcamentoApelido="2+10", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F3.9",  OrcamentoNome = "Forecast", OrcamentoApelido="3+9", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F4.8",  OrcamentoNome = "Forecast", OrcamentoApelido="4+8", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F5.7",  OrcamentoNome = "Forecast", OrcamentoApelido="5+7", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F6.6",  OrcamentoNome = "Forecast", OrcamentoApelido="6+6", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F7.5",  OrcamentoNome = "Forecast", OrcamentoApelido="7+5", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F8.4",  OrcamentoNome = "Forecast", OrcamentoApelido="8+4", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F9.3",  OrcamentoNome = "Forecast", OrcamentoApelido="9+3", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F10.2", OrcamentoNome = "Forecast", OrcamentoApelido="10+2", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F11.1", OrcamentoNome = "Forecast", OrcamentoApelido="11+1", OrcamentoTipo="Orçamento"],
        [OrcamentoID = "F12.0", OrcamentoNome = "Forecast", OrcamentoApelido="12+0", OrcamentoTipo="Orçamento"],



        /* Prévias */
        [OrcamentoID = "P01", OrcamentoNome = "Preview", OrcamentoApelido="P1", OrcamentoTipo="Previsão"],
        [OrcamentoID = "P02", OrcamentoNome = "Preview", OrcamentoApelido="P2", OrcamentoTipo="Previsão"],
        [OrcamentoID = "P03", OrcamentoNome = "Preview", OrcamentoApelido="P3", OrcamentoTipo="Previsão"],
        [OrcamentoID = "P04", OrcamentoNome = "Preview", OrcamentoApelido="P4", OrcamentoTipo="Previsão"],
        [OrcamentoID = "P05", OrcamentoNome = "Preview", OrcamentoApelido="P5", OrcamentoTipo="Previsão"],
        
        /* Tendencias */
        [OrcamentoID = "T01", OrcamentoNome = "Trend", OrcamentoApelido="T1", OrcamentoTipo="Tendência"],
        [OrcamentoID = "T02", OrcamentoNome = "Trend", OrcamentoApelido="T2", OrcamentoTipo="Tendência"],
        [OrcamentoID = "T03", OrcamentoNome = "Trend", OrcamentoApelido="T3", OrcamentoTipo="Tendência"],
        [OrcamentoID = "T04", OrcamentoNome = "Trend", OrcamentoApelido="T4", OrcamentoTipo="Tendência"],
        [OrcamentoID = "T05", OrcamentoNome = "Trend", OrcamentoApelido="T5", OrcamentoTipo="Tendência"]
               
    },
    Record.FieldValues,
    {"OrcamentoID", "OrcamentoNome", "OrcamentoApelido","OrcamentoTipo"}
),
    #"Tipo Alterado" = Table.TransformColumnTypes(Fonte,{{"OrcamentoApelido", type text}, {"OrcamentoNome", type text}, {"OrcamentoID", type text}, {"OrcamentoTipo", type text}})
in
    #"Tipo Alterado"

// Data_Inicio_Calendario
#date(2020, 1, 1) meta [IsParameterQuery=true, Type="Date", IsParameterQueryRequired=true]

// Data_Final_Calendario
#date(2021, 12, 31) meta [IsParameterQuery=true, Type="Date", IsParameterQueryRequired=true]

// Hist_Mes_OrcamentoAux
let

    CalFonte = fx_CalendarioMensal(Date.Year(Data_Inicio_Calendario), Date.Year(Data_Final_Calendario)),
    Fonte = OrcamentoAux,
    ProdCartesiano = Table.AddColumn(Fonte,"dExercicio", each CalFonte),
    #"dExercicio Expandido" = Table.ExpandTableColumn(ProdCartesiano, "dExercicio", {"Mes_Ref", "Mes_Ano"}, {"Mes_Ref", "Mes_Ano"}),
    #"Tipo Alterado1" = Table.TransformColumnTypes(#"dExercicio Expandido",{{"Mes_Ref", type date}}),
    Separador = "
    ",
    DefAct = Table.AddColumn(#"Tipo Alterado1", "Show", each
        if [OrcamentoApelido] ="Act" and [Mes_Ref]<=Data_Ultimo_Real
            then Text.Combine({[OrcamentoApelido], Separador,[Mes_Ano]},"")        
        else if [OrcamentoID] =OrcamentoVigente and Date.Year([Mes_Ref])=OrcamentoAno
            then Text.Combine({[OrcamentoApelido], Separador,[Mes_Ano]},"")
        else if Text.Start([OrcamentoID],2) ="P0" and [Mes_Ref]=Data_Mes_Atual
            then Text.Combine({[OrcamentoApelido], Separador,[Mes_Ano]},"")
        else if Text.Start([OrcamentoID],2) ="T0" and [Mes_Ref]=Data_Mes_Atual
            then Text.Combine({[OrcamentoApelido], Separador,[Mes_Ano]},"")
        else null
    ),
    #"Linhas Filtradas" = Table.SelectRows(DefAct, each ([Show] <> null)),
    #"Tipo Alterado2" = Table.TransformColumnTypes(#"Linhas Filtradas",{{"Mes_Ano", type text}, {"Show", type text}})
in
    #"Tipo Alterado2"

// Data_Ultimo_Real
#date(2021, 1, 1) meta [IsParameterQuery=true, Type="Date", IsParameterQueryRequired=true]

// OrcamentoVigente
"F4.8" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

// OrcamentoAno
2021 meta [IsParameterQuery=true, Type="Number", IsParameterQueryRequired=true]

// Data_Mes_Atual
#date(2021, 2, 1) meta [IsParameterQuery=true, Type="Date", IsParameterQueryRequired=true]

// diretorio_de_insumos
"C:\Users\F8050751\OneDrive - TIM\Planning_Business_Churn\demandas\Net Adds\PowerBI\InsumosTT" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

// dCalendario
let
    Fonte = fx_CalendarioMensal(Date.Year(Data_Inicio_Calendario), Date.Year(Data_Final_Calendario)),
    #"Tipo Alterado" = Table.TransformColumnTypes(Fonte,{{"Mes_Ref", type date}, {"Ulti_Dia_Mes", type date}, {"Ano", type text},  {"DateInt", type text}}),
    UltimoMes = Table.AddColumn(#"Tipo Alterado", "Ultimo_Mes_Actual", each if [Mes_Ref]=Data_Ultimo_Real then 1 else 0),
    MesPrevia = Table.AddColumn(UltimoMes, "Mes_Corrente", each if [Mes_Ref]=Data_Mes_Atual then 1 else 0) /*,
    #"Consultas Mescladas" = Table.NestedJoin(MesPrevia, {"Mes_Ref"}, Hist_Mes_OrcamentoAux, {"Mes_Ref"}, "Hist_Mes_OrcamentoAux", JoinKind.LeftOuter),
    #"Hist_Mes_OrcamentoAux Expandido" = Table.ExpandTableColumn(#"Consultas Mescladas", "Hist_Mes_OrcamentoAux", {"OrcamentoID", "Show"}, {"OrcamentoID", "Show"}),
    #"Colunas Reordenadas" = Table.ReorderColumns(#"Hist_Mes_OrcamentoAux Expandido",{"Show", "Mes_Ref", "Ulti_Dia_Mes", "Ano", "Trimestre", "MesNr", "DateInt", "Mes", "Mes_Ano", "Ultimo_Mes_Actual", "Mes_Corrente", "OrcamentoID"}),
    #"Colunas Renomeadas1" = Table.RenameColumns(#"Colunas Reordenadas",{{"Show", "OrcamentoMes"}})*/
in
    MesPrevia

// dVisaoSegmentacao
let
    Fonte = insumo_total,
    #"Outras Colunas Removidas" = Table.SelectColumns(Fonte,{"Visao"}),
    #"Duplicatas Removidas" = Table.Distinct(#"Outras Colunas Removidas"),
    OrdemVisao = Table.AddColumn(#"Duplicatas Removidas", "OrdemVisao", 
        each 
            if      [Visao] = "Voice lines"    then 1 
            else if [Visao] = "Web"            then 2 
            else if [Visao] = "Pré-pago"       then 3 
            else                               null, 
            type number)
in
    OrdemVisao

// dCenarioPlanejamento
let
    Fonte = OrcamentoAux,
    RenomCol = Table.RenameColumns(Fonte,{ {"OrcamentoID", "CenarioID"}, 
                                           {"OrcamentoNome", "CenarioNome"}, 
                                           {"OrcamentoApelido", "CenarioApelido"}
                                         }),
    Vigencia = Table.AddColumn(RenomCol, "Vigente", each
        if      [CenarioID] ="ACT"                                                          then 1
        else if [CenarioID] ="PC"                                                           then 2
        else if [CenarioID] =OrcamentoVigente                                               then 3
        else if Text.Start([CenarioID],2) ="P0"                                             then 4
        else if Text.Start([CenarioID],2) ="T0"                                             then 5
        else                                                                                    99
    ),
    #"Tipo Alterado" = Table.TransformColumnTypes(Vigencia,{{"Vigente", type number}})
in
    #"Tipo Alterado"

// dKPI
let
    Fonte = insumo_total,
    #"Outras Colunas Removidas" = Table.SelectColumns(Fonte,{ "KPI"}),
    
    #"Linhas Agrupadas" = Table.Group(#"Outras Colunas Removidas", {"KPI"}, {{"Contagem", each Table.RowCount(_), Int64.Type}}),

    OrdemKPI = Table.AddColumn(#"Linhas Agrupadas", "OrdemKPI", 
        each 
            if      [KPI] = "Entrada"           then 1 
            else if [KPI] = "Saída"             then 2 
            else if [KPI] = "Net Adds"          then 3 
            else if [KPI] = "Base EoP"          then 4 
            else if [KPI] = "Saldo Migração"    then 5 
            else if [KPI] = "Churn Rate"        then 6 
            else if [KPI] = "Base Média"        then 7 
            else                                    null, 
            type number),
    #"Colunas Removidas" = Table.RemoveColumns(OrdemKPI,{"Contagem"}),
    #"Linhas Filtradas" = Table.SelectRows(#"Colunas Removidas", each ([KPI] <> null))
in
    #"Linhas Filtradas"

// dProduto
let
    Fonte = insumo_total,
    #"Outras Colunas Removidas" = Table.SelectColumns(Fonte,{ "Produto"}),
    #"Linhas Agrupadas" = Table.Group(#"Outras Colunas Removidas", {"Produto"}, {{"Contagem", each Table.RowCount(_), Int64.Type}}),
    #"Coluna Condicional Adicionada" = Table.AddColumn(#"Linhas Agrupadas", "OrdemProduto", 
        each 
            if      [Produto] = "Puro"              then 1 
            else if [Produto] = "Controle"          then 2 
            else if [Produto] = "Boleto"            then 3 
            else if [Produto] = "Outros Consumer"   then 70 
            else if [Produto] = "Corporate"         then 5 
            else if [Produto] = "Controle > Puro"   then 6 
            else if [Produto] = "Puro > Controle"   then 7

            /* inicio web */
            else if [Produto] = "Web"   then 25
            else if [Produto] = "M2M"   then 26

            /* inicio pre */
            else if [Produto] = "Gross"   then 30
            else if [Produto] = "Mig. Puro"   then 32
            else if [Produto] = "Mig. Controle"   then 33
            else if [Produto] = "Mig. Boleto"   then 34
            else if [Produto] = "Mig. Outros Consumer"   then 35
            else if [Produto] = "Mig. Corp"   then 36
            else if [Produto] = "Churn"   then 31
            else if [Produto] = "Net Adds"   then 38
            else if [Produto] = "Base EoP"   then 39
            else if [Produto] = "Saldo Migração"   then 40
            else if [Produto] = "Churn Rate"   then 99
            else null, 
            type number),
    #"Colunas Removidas" = Table.RemoveColumns(#"Coluna Condicional Adicionada",{"Contagem"}),
    #"Linhas Filtradas" = Table.SelectRows(#"Colunas Removidas", each ([Produto] <> null))
in
    #"Linhas Filtradas"

// dDrill_N1____
let
    Fonte = insumo_total,
    #"Outras Colunas Removidas" = Table.SelectColumns(Fonte,{ "Drill_N1"}),
    #"Linhas Agrupadas" = Table.Group(#"Outras Colunas Removidas", {"Drill_N1"}, {{"Contagem", each Table.RowCount(_), Int64.Type}}),
    #"Coluna Condicional Adicionada" = Table.AddColumn(#"Linhas Agrupadas", "OrdemDN1", each if [Drill_N1] = "Consumer" then 1 else if [Drill_N1] = "Digital" then 2 else if [Drill_N1] = "CR" then 3 else if [Drill_N1] = "Outros Consumer" then 4 else if [Drill_N1] = "Top" then 5 else if [Drill_N1] = "SEAC" then 6 else if [Drill_N1] = "SMB" then 7 else if [Drill_N1] = "Puro" then 8 else if [Drill_N1] = "Controle" then 9 else if [Drill_N1] = "Boleto" then 10 else if [Drill_N1] = "Controle > Puro" then 11 else if [Drill_N1] = "Puro > Controle" then 12 else null, type number),
    #"Linhas Filtradas" = Table.SelectRows(#"Coluna Condicional Adicionada", each ([Drill_N1] <> null))
in
    #"Linhas Filtradas"

// dDrill_N2____
let
    Fonte = insumo_total,
    #"Outras Colunas Removidas" = Table.SelectColumns(Fonte,{ "Drill_N2"}),
    #"Linhas Agrupadas" = Table.Group(#"Outras Colunas Removidas", {"Drill_N2"}, {{"Contagem", each Table.RowCount(_), Int64.Type}}),
    #"Coluna Condicional Adicionada" = Table.AddColumn(#"Linhas Agrupadas", "OrdemDN2", each if [Drill_N2] = "Consumer" then 10 else if [Drill_N2] = "Digital" then 11 else if [Drill_N2] = "CR" then 12 else if [Drill_N2] = "Outros Consumer" then 13 else if [Drill_N2] = "Top" then 14 else if [Drill_N2] = "SEAC" then 15 else if [Drill_N2] = "SMB" then 16 else if [Drill_N2] = "Voluntário" then 1 else if [Drill_N2] = "Involuntário" then 2 else if [Drill_N2] = "Puro" then 17 else if [Drill_N2] = "Controle" then 18 else if [Drill_N2] = "Boleto" then 19 else if [Drill_N2] = "Controle > Puro" then 20 else if [Drill_N2] = "Puro > Controle" then 21 else null, type number),
    #"Linhas Filtradas" = Table.SelectRows(#"Coluna Condicional Adicionada", each ([Drill_N2] <> null))
in
    #"Linhas Filtradas"

// dDrill_N3____
let
    Fonte = insumo_total,
    #"Outras Colunas Removidas" = Table.SelectColumns(Fonte,{ "Drill_N3"}),
    #"Linhas Agrupadas" = Table.Group(#"Outras Colunas Removidas", {"Drill_N3"}, {{"Contagem", each Table.RowCount(_), Int64.Type}}),
    #"Coluna Condicional Adicionada" = Table.AddColumn(#"Linhas Agrupadas", "OrdemDN3", each if [Drill_N3] = "Consumer" then 20 else if [Drill_N3] = "Digital" then 21 else if [Drill_N3] = "CR" then 22 else if [Drill_N3] = "Outros Consumer" then 23 else if [Drill_N3] = "Top" then 24 else if [Drill_N3] = "SEAC" then 25 else if [Drill_N3] = "SMB" then 26 else if [Drill_N3] = "Voluntário" then 1 else if [Drill_N3] = "Involuntário - Inad Fatura" then 10 else if [Drill_N3] = "Involuntário - Fraude Fatura" then 11 else if [Drill_N3] = "Involuntário - Outros Fatura" then 12 else if [Drill_N3] = "Involuntário - Express" then 13 else if [Drill_N3] = "Involuntário" then 19 else if [Drill_N3] = "Puro" then 27 else if [Drill_N3] = "Controle" then 28 else if [Drill_N3] = "Boleto" then 29 else if [Drill_N3] = "Controle > Puro" then 30 else if [Drill_N3] = "Puro > Controle" then 31 else null, type number),
    #"Linhas Filtradas" = Table.SelectRows(#"Coluna Condicional Adicionada", each ([Drill_N3] <> null))
in
    #"Linhas Filtradas"

// fIndicadores
let
    Fonte = insumo_total,
    LinhaTemp = Table.AddColumn(Fonte, "LinhaTemp", 
            each
                if      [Versao_Orcamento] ="ACT" 
                        and [Mes_Ref]<=Data_Ultimo_Real         then "Sim"
                else if [Versao_Orcamento] ="PC"  
                        and [Mes_Ref]=Data_Ultimo_Real          then "Sim"
                else if [Versao_Orcamento] = OrcamentoVigente 
                         and Date.Year([Mes_Ref])= OrcamentoAno
                         and [Mes_Ref] >= Data_Mes_Atual        then "Sim"                    
                else if Text.Start([Versao_Orcamento],2) ="P0" 
                        and [Mes_Ref]=Data_Mes_Atual            then "Sim"
                else if Text.Start([Versao_Orcamento],2) ="T0" 
                        and [Mes_Ref]=Data_Mes_Atual            then "Sim"                    
                else "Não"
    ),
    juncaoCenario = Table.NestedJoin(LinhaTemp, {"Versao_Orcamento"}, dCenarioPlanejamento, {"CenarioID"}, "dCenarioPlanejamento", JoinKind.LeftOuter),
    ExpandirCenario = Table.ExpandTableColumn(juncaoCenario, "dCenarioPlanejamento", {"CenarioApelido", "Vigente"}, {"CenarioApelido", "Vigente"}),

    Separador = "
    ",

    DefAct = Table.AddColumn(ExpandirCenario, "Mes_Ref_Versao", each
        if [LinhaTemp] ="Sim" 
            then Text.Combine({
                                [CenarioApelido], 
                                Separador,
                                Text.From(fx_DefineMes(Date.Month([Mes_Ref])), "pt-BR"), 
                                "/",
                                Text.From(Date.Year([Mes_Ref]), "pt-BR")
                                },"")
        else null
    ),
    #"Linhas Filtradas" = Table.SelectRows(DefAct, each ([KPI] <> null))
in
    #"Linhas Filtradas"

// dAnalise_Hist
let
    Fonte = dpTransporColunas,
    #"Linhas Filtradas" = Table.SelectRows(Fonte, each ([Analise_Hist_Flag] = "Sim"))
in
    #"Linhas Filtradas"

// OrcamentoAuxOficial
let
    Fonte = OrcamentoAux,
    #"Linhas Filtradas" = Table.SelectRows(Fonte, each ([OrcamentoNome] = "Budget" or [OrcamentoNome] = "Forecast"))
in
    #"Linhas Filtradas"

// versionamento
let
    Fonte = Excel.Workbook(File.Contents("C:\Users\F8050751\OneDrive - TIM\Planning_Business_Churn\demandas\Net Adds\PowerBI\Net_Adds_Versionamento.xlsx"), null, true),
    versionamento_Sheet = Fonte{[Item="versionamento",Kind="Sheet"]}[Data],
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(versionamento_Sheet, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"Data", type date}, {"Versao", type text}, {"OrdemRecurso", Int64.Type}, {"OrdemVersao", Int64.Type}, {"Recurso", type text}}),
    #"Linhas Filtradas" = Table.SelectRows(#"Tipo Alterado", each ([Data] <> null))
in
    #"Linhas Filtradas"

// Plan_01_Real
let
    Fonte = OrcamentoAux,
    #"Linhas Filtradas" = Table.SelectRows(Fonte, each ([OrcamentoTipo] = "Realizado")),
    #"Índice Adicionado" = Table.AddIndexColumn(#"Linhas Filtradas", "Id", 1, 1, Int64.Type)
in
    #"Índice Adicionado"

// Plan_02_Orçado
let
    Fonte = OrcamentoAux,
    #"Linhas Filtradas" = Table.SelectRows(Fonte, each ([OrcamentoTipo] = "Orçamento")),
    #"Índice Adicionado" = Table.AddIndexColumn(#"Linhas Filtradas", "Id", 1, 1, Int64.Type)
in
    #"Índice Adicionado"

// Plan_03_Previsão
let
    Fonte = OrcamentoAux,
    #"Linhas Filtradas" = Table.SelectRows(Fonte, each ([OrcamentoTipo] = "Previsão")),
    #"Índice Adicionado" = Table.AddIndexColumn(#"Linhas Filtradas", "Id", 1, 1, Int64.Type)
in
    #"Índice Adicionado"

// Plan_04_Tendencia
let
    Fonte = OrcamentoAux,
    FiltroTrend = Table.SelectRows(Fonte, each [OrcamentoTipo] = "Tendência"),
    FiltroPreClosing= Table.SelectRows(Fonte, each [OrcamentoApelido] = "PC"),
    Uniao = Table.Combine({FiltroTrend,FiltroPreClosing}),
    Indice = Table.AddIndexColumn(Uniao, "Id", 1, 1, Int64.Type)
in
    Indice

// Config
let
    Fonte = Excel.Workbook(File.Contents("C:\Users\F8050751\OneDrive - TIM\Planning_Business_Churn\demandas\Net Adds\PowerBI\Insumos\arquivo_de_carga.xlsx"), null, true),
    Config_Sheet = Fonte{[Item="Config",Kind="Sheet"]}[Data],
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Config_Sheet, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"Parametro", type text}, {"Valor_Parametro", type any}})
in
    #"Tipo Alterado"
