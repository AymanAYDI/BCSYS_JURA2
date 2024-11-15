namespace BCSYS.Jura;

using Microsoft.Sales.Document;
pageextension 50104 "Sales Order Subform" extends "Sales Order Subform" //46
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec.Type = Rec.Type::Item then
                    if (Rec."No." <> xRec."No.") and (xRec."No." = '') then
                        Rec.AddEcotaxe();
            end;
        }
    }
}