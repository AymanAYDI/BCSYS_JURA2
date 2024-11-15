namespace BCSYS.Jura;

pageextension 50112 "JWS Service Receipt Card" extends "JWS Service Receipt Card" //81002
{
    layout
    {
        modify("Use JURA Box")
        {
            Visible = false;
        }

        modify("Boxno. Out")
        {
            Visible = false;
        }

        addlast("JURA Transport Box")
        {
            field("BC6 No. of Shipment Labels"; Rec."BC6 No. of Shipment Labels")
            {
                ApplicationArea = All;
            }
        }
        addlast("Invoice Details")
        {
            group(SAFERPAY)
            {
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Service Payment Status"; Rec."Service Payment Status")
                {
                    ApplicationArea = All;
                }
                field("Payment Text"; Rec."Payment Text")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(DHL_Express)
            {
                Caption = 'DHL Express', Comment = 'FRA="DHL Express"';
                Image = Shipment;
                ApplicationArea = All;

                trigger OnAction()
                var
                    WebservicePartnerMgt: Codeunit "BC6 WS Partner Management";
                begin
                    //>>BC6 SBE 23/12/2021
                    if Rec."Type of Dispatch" = Rec."Type of Dispatch"::Store then
                        ERROR(text68000);

                    CurrPage.SETSELECTIONFILTER(Rec);
                    WebservicePartnerMgt.ConsumeMyDHLFromServiceReceipt(Rec, false);
                    Rec.SETFILTER("No.", '');
                    //<<BC6 SBE 23/12/2021
                end;
            }
        }
        addlast(reporting)
        {
            action(DHL_Express_Returns)
            {
                Caption = 'DHL Express Returns', Comment = 'FRA="DHL Express Returns"';
                Image = Shipment;
                ApplicationArea = All;

                trigger OnAction()
                var
                    WebservicePartnerMgt: Codeunit "BC6 WS Partner Management";
                begin
                    //>>BC6 SBE 23/12/2021
                    if Rec."Type of Dispatch" = Rec."Type of Dispatch"::Store then
                        ERROR(text68000);

                    CurrPage.SETSELECTIONFILTER(Rec);
                    WebservicePartnerMgt.ConsumeMyDHLFromServiceReceipt(Rec, true);
                    Rec.SETFILTER("No.", '');
                    //<<BC6 SBE 23/12/2021
                end;
            }
        }
    }

    var
        text68000: Label 'No Post Label if Customer picks up at shop.', Comment = 'FRA="Aucune étiquette de poste si le client récupère au magasin."';
}