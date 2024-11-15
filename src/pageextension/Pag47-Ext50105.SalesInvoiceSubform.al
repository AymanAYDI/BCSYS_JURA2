namespace BCSYS.Jura;

using Microsoft.Sales.Document;
pageextension 50105 "Sales Invoice Subform" extends "Sales Invoice Subform" //47
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