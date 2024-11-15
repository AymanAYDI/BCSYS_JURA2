namespace BCSYS.Jura;

tableextension 50110 "JWC Packing Track No." extends "JWC Packing Track No." //80013
{
    fields
    {
        field(50100; "BC6 Shipment Label"; Blob)
        {
            Caption = 'Shipment Label';
        }
    }
}