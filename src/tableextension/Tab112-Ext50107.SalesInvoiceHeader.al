namespace BCSYS.Jura;

using Microsoft.Sales.History;

tableextension 50107 "Sales Invoice Header" extends "Sales Invoice Header" //112
{
    fields
    {
        field(50100; "Print Serial No."; Boolean)
        {
            caption = 'Print Serial No.', Comment = 'FRA="Imprimer n° de série"';
        }
        field(50101; "BC6 No. of Shipment Labels"; Integer)
        {
            Caption = 'No. of Shipment Labels', Comment = 'FRA="N° étiquettes"';
        }
        field(50102; "BC6 ID Import"; Integer)
        {
            Caption = 'ID Import', Comment = 'FRA="ID de la table d''import"';
        }
    }
}