namespace BCSYS.Jura;

using Microsoft.Sales.Document;
pageextension 50107 "Sales Quote Subform" extends "Sales Quote Subform" //95
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