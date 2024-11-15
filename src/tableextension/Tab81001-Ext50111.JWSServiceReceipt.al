namespace BCSYS.Jura;

tableextension 50111 "JWS Service Receipt" extends "JWS Service Receipt" //81001
{
    fields
    {
        field(50100; "BC6 No. of Shipment Labels"; Integer)
        {
            Caption = 'No. of Shipment Labels', Comment = 'FRA="N° étiquettes"';
        }
        field(50101; "Payment Text"; Text[80])
        {
            Caption = 'Service Payment Status', Comment = 'FRA="Texte Paiement"';
        }
        field(50102; "Transaction No."; Text[30])
        {
            Caption = 'Service Payment Status', Comment = 'FRA="No Transaction"';
        }
        field(50103; "Service Payment Status"; Enum Payment)
        {
            Caption = 'Service Payment Status', Comment = 'FRA="Statut Paiement GR"';
        }
    }
}