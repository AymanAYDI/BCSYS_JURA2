namespace BCSYS.Jura;

using Microsoft.Purchases.Document;

tableextension 50104 "Purchase Line" extends "Purchase Line" //39
{
    fields
    {
        field(50100; "Shelf No."; Code[10])
        {
            Caption = 'Shelf No.', Comment = 'FRA="N° emplacement"';
        }
    }
}