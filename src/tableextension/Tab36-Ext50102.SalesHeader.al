namespace BCSYS.Jura;

using Microsoft.Sales.Document;

tableextension 50102 "Sales Header" extends "Sales Header" //36
{
    fields
    {
        modify("Sell-to Customer Name")
        {
            trigger OnAfterValidate()
            begin
                Rec."Salesperson Code" := Customer."Salesperson Code";
            end;
        }
        field(50100; "Order Status"; Enum "Order Status")
        {
            caption = 'Order Status', Comment = 'FRA="Statut commande"';
        }
        field(50101; "Shipment Comment"; Text[80])
        {
            caption = 'Shipment Comment', Comment = 'FRA="Commentaire Livraison"';
        }
        field(50102; "BC6 PreEDI"; Boolean)
        {
            caption = 'PreEDI', Comment = 'FRA="PreEDI"';
        }
        field(50103; "Print Serial No."; Boolean)
        {
            caption = 'Print Serial No.', Comment = 'FRA="Imprimer n° de série"';
        }
        field(50104; "BC6 No. of Shipment Labels"; Integer)
        {
            Caption = 'No. of Shipment Labels', Comment = 'FRA="N° étiquettes"';
        }
        field(50105; "BC6 ID Import"; Integer)
        {
            Caption = 'ID Import', Comment = 'FRA="ID de la table d''import"';
        }
    }

    procedure CheckBeforeSchneiderSend()
    var
        ErrorSending: Label 'Error - sending impossible', Comment = 'FRA="Erreur - envoi impossible"';
        ErrorSendingHasAlreadySent: Label 'The order has already been sent', Comment = 'FRA="La commande a déjà été envoyée"';
    begin
        if Customer.GET(Rec."Bill-to Customer No.") then
            Customer.TESTFIELD(Blocked, Customer.Blocked::" ");
        case Rec."Order Status" of
            "Order Status"::"Blocked - authorized credit exceeded":
                ERROR(ErrorSending);
            "Order Status"::"Blocked - unpaid invoices":
                ERROR(ErrorSending);
            "Order Status"::"Blocked - unpaid invoices and authorized credit exceeded":
                ERROR(ErrorSending);
            "Order Status"::Verified:
                ERROR(ErrorSending);
            "Order Status"::Sent:
                ERROR(ErrorSendingHasAlreadySent);
        end;
    end;

}
