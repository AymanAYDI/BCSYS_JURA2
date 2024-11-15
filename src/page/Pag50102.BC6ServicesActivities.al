namespace BCSYS.Jura;
page 50102 "BC6 Services Activities"
{
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "JWS Jura Services Cue";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            grid(gridlayout)
            {
                GridLayout = Columns;
                ShowCaption = false;
                cuegroup(Cuegroup1)
                {
                    ShowCaption = false;
                    field("BC6 Boulanger"; Rec."BC6 Boulanger")
                    {
                        trigger OnDrillDown()
                        var
                            CduLFctMgt: Codeunit "BC6 Functions Mgt.";
                        begin
                            CduLFctMgt.FctDrillBoulangerServiceOrder();
                        end;
                    }
                    field("BC6 Status JURA"; Rec."BC6 Status JURA")
                    {
                        trigger OnDrillDown()
                        var
                            CduLFctMgt: Codeunit "BC6 Functions Mgt.";
                        begin
                            CduLFctMgt.FctDrillJURAStatutServiceOrder();
                        end;
                    }
                }
            }
            grid(gridlayout1)
            {
                GridLayout = Columns;
                ShowCaption = false;
                cuegroup(Cuegroup2)
                {
                    ShowCaption = false;
                    field("BC6 Under-Reparation Singen"; Rec."BC6 Under-Reparation Singen")
                    {
                        trigger OnDrillDown()
                        var
                            CduLFctMgt: Codeunit "BC6 Functions Mgt.";
                        begin
                            CduLFctMgt.FctDrillUnderReparSingentServiceOrder();
                        end;
                    }
                    field("BC6 Local Singen Reparation"; Rec."BC6 Local Singen Reparation")
                    {
                        trigger OnDrillDown()
                        var
                            CduLFctMgt: Codeunit "BC6 Functions Mgt.";
                        begin
                            CduLFctMgt.FctDrillLocalReparSingentServiceOrder();
                        end;
                    }
                }
            }
            grid(gridlayout2)
            {
                GridLayout = Columns;
                ShowCaption = false;
                cuegroup(Cuegroup3)
                {
                    ShowCaption = false;
                    field("BC6 SafePray to Post"; Rec."BC6 SafePray to Post")
                    {
                        trigger OnDrillDown()
                        var
                            CduLFctMgt: Codeunit "BC6 Functions Mgt.";
                        begin
                            CduLFctMgt.FctDrillSafePrayToPost();
                        end;
                    }
                    field("BC6 In-Transit"; Rec."BC6 In-Transit")
                    {
                        trigger OnDrillDown()
                        var
                            CduLFctMgt: Codeunit "BC6 Functions Mgt.";
                        begin
                            CduLFctMgt.FctDrillInTransitServiceReceipt();
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        CduLFctMgt: Codeunit "BC6 Functions Mgt.";
    begin
        Rec."BC6 In-Transit" := CduLFctMgt.FctCalcInTransitServiceReceipt();
        Rec."BC6 Under-Reparation Singen" := CduLFctMgt.FctCalcUnderReparSingentServiceOrder();
        Rec."BC6 Local Singen Reparation" := CduLFctMgt.FctCalcLocalReparSingentServiceOrder();
        Rec."BC6 Boulanger" := CduLFctMgt.FctCalcBoulangerServiceOrder();
        Rec."BC6 Status JURA" := CduLFctMgt.FctCalcJURAStatutServiceOrder();
        Rec."BC6 SafePray to Post" := CduLFctMgt.FctCalcSafePrayToPost();
    end;
}
