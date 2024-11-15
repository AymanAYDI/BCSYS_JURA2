namespace BCSYS.Jura;

using Microsoft.Sales.History;
pageextension 50109 "Posted Sales Invoice" extends "Posted Sales Invoice" //132
{
    layout
    {
        addlast("Work Description")
        {
            field("BC6_Print Serial No."; Rec."Print Serial No.")
            {
                ApplicationArea = all;
            }
            field("BC6 ID Import"; Rec."BC6 ID Import")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter(ActivityLog)
        {
            action(DHL_Express)
            {
                Caption = 'DHL Express', Comment = 'FRA="DHL Express"';
                Image = Shipment;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ServOrder: Record "JWS Service Order";
                    WebservicePartnerMgt: Codeunit "BC6 WS Partner Management";
                begin
                    //>>BC6 SBE 23/12/2021
                    if Rec."JWS Service Order No." <> '' then
                        if ServOrder.GET(Rec."JWS Service Order No.") then
                            if ServOrder."Type of Dispatch" = ServOrder."Type of Dispatch"::Store then
                                ERROR(text68000);

                    CurrPage.SETSELECTIONFILTER(Rec);
                    WebservicePartnerMgt.ConsumeMyDHLFromPostedSalesInv(Rec, false);
                    Rec.SETFILTER("No.", '');
                    //<<BC6 SBE 23/12/2021
                end;
            }
        }
        addlast(Category_Category4)
        {
            actionref("Promoted_DHL_Express"; "DHL_Express")
            {
            }
        }
    }

    var
        text68000: Label 'No Post Label if Customer picks up at shop.', Comment = 'FRA="Aucune étiquette de poste si le client récupère au magasin."';
}