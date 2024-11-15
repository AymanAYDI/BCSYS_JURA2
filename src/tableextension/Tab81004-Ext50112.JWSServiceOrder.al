namespace BCSYS.Jura;

tableextension 50112 "JWS Service Order" extends "JWS Service Order" //81004
{
    fields
    {
        field(50100; Plant; Enum Plant)
        {
            Caption = 'Plant', Comment = 'FRA="Usine"';
        }
        field(50101; "Service Payment Status"; Enum Payment)
        {
            Caption = 'Service Payment Status', Comment = 'FRA="Statut Paiement GR"';
        }
        field(50102; "Payment Text"; Text[80])
        {
            Caption = 'Service Payment Status', Comment = 'FRA="Texte Paiement"';
        }
        field(50103; "Transaction No."; Text[30])
        {
            Caption = 'Service Payment Status', Comment = 'FRA="No Transaction"';
        }
    }
}