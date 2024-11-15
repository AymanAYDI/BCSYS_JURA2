namespace BCSYS.Jura;

using Microsoft.Sales.History;

pageextension 50108 "Posted Sales Shipment" extends "Posted Sales Shipment" //130
{
    layout
    {
        addlast(General)
        {
            field("No. of Shipment Labels"; Rec."BC6 No. of Shipment Labels")
            {
                ApplicationArea = All;
            }
        }
    }
}