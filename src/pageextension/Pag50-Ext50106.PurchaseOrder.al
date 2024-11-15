namespace BCSYS.Jura;

using Microsoft.Purchases.Document;

pageextension 50106 "Purchase Order" extends "Purchase Order" //50
{
    actions
    {
        addlast(Print)
        {
            action(PrintingReceipt)
            {
                ApplicationArea = All;
                Caption = 'Printing Receipt', Comment = 'FRA="Impression Réception"';
                ToolTip = 'Printing Receipt', Comment = 'FRA="Impression de la réception"';
                Image = Receipt;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                Ellipsis = true;
                trigger OnAction()
                var
                    PurchHeader: Record "Purchase Header";
                begin
                    PurchHeader.GET(Rec."Document Type", Rec."No.");
                    PurchHeader.SETRECFILTER();

                    REPORT.RUNMODAL(REPORT::"Whse. receipt (Jura)", true, false, PurchHeader);
                end;
            }
        }
    }
}