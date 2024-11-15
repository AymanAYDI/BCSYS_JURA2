namespace BCSYS.Jura;

using Microsoft.Sales.History;
tableextension 50106 "Sales Shipment Header" extends "Sales Shipment Header" //110
{
    fields
    {
        field(50100; "BC6 No. of Shipment Labels"; Integer)
        {
            Caption = 'No. of Shipment Labels', Comment = 'FRA="N° étiquettes"';
        }
    }
}