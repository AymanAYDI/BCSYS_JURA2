namespace BCSYS.Jura;

using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;
tableextension 50103 "Sales Line" extends "Sales Line" //37
{
    fields
    {
        field(50100; "BC6 Ecotax"; Boolean)
        {
            Caption = 'Ecotax', Comment = 'FRA="Ecotax"';
        }
        field(50101; "ECOTAX Attached to Line No."; Integer)
        {
            Caption = 'ECOTAX Attached to Line No.', Comment = 'FRA="ECOTAX Attaché à la ligne n°"';
            TableRelation = "Sales Line"."Line No." where("Document Type" = field("Document Type"), "Document No." = field("Document No."));
        }
        field(50102; "BC6 Related Ecotax item"; Code[20])
        {
            Caption = 'Related Ecotax item', Comment = 'FRA="Article lié à l''eco taxe"';
        }
    }

    trigger OnAfterModify()
    begin
        if Type = Type::Item then
            UpdateEcotaxeLine();
    end;

    trigger OnAfterDelete()
    begin
        DeleteEcotaxeLine();
    end;

    var
        RecGItem: Record Item;
        RecGSalesLine: Record "Sales Line";

    procedure AddEcotaxe()
    var
        RecLNextSalesLine: Record "Sales Line";
        IntLLineSpacing: Integer;
    begin
        RecGItem.INIT();
        if RecGItem.GET("No.") then
            if RecGItem."BC6 Item Eco Taxe" <> '' then begin
                RecGSalesLine.INIT();
                RecGSalesLine := Rec;
                //AB
                IntLLineSpacing := 1;  //GetLineSpacing;
                RecGSalesLine."Line No." := "Line No." + IntLLineSpacing;
                RecGSalesLine.VALIDATE("No.", RecGItem."BC6 Item Eco Taxe");
                RecGSalesLine."ECOTAX Attached to Line No." := "Line No.";
                RecGSalesLine."BC6 Ecotax" := true;
                RecGSalesLine."BC6 Related Ecotax item" := "No.";
                RecGSalesLine.INSERT();
                COMMIT();
            end;
    end;

    procedure UpdateEcotaxeLine()
    var
        RecLSalesLine: Record "Sales Line";
    begin
        if not "BC6 Ecotax" then begin
            RecLSalesLine.RESET(); //Lookup for an existing ECOTAX line for this item
            RecLSalesLine.SETFILTER("Document Type", '%1', "Document Type");
            RecLSalesLine.SETFILTER("Document No.", '%1', "Document No.");
            RecLSalesLine.SETFILTER("ECOTAX Attached to Line No.", '%1', "Line No.");
            if RecLSalesLine.FINDFIRST() then begin
                //Update quantity
                if Rec.Quantity <> xRec.Quantity then
                    RecLSalesLine.VALIDATE(Quantity, Quantity);
                //BCSYS 24112023
                //Update quantity to Ship
                //IF Rec."Quantity Shipped" <> xRec."Quantity Shipped" THEN BEGIN
                //    RecLSalesLine.VALIDATE("Quantity Shipped", "Quantity Shipped");
                //END;
                //Update quantity to Ship
                if Rec."Qty. to Ship" <> xRec."Qty. to Ship" then
                    RecLSalesLine.VALIDATE("Qty. to Ship", "Qty. to Ship");
                //Update quantity to Invoice
                if Rec."Qty. to Invoice" <> xRec."Qty. to Invoice" then
                    RecLSalesLine.VALIDATE("Qty. to Invoice", "Qty. to Invoice");
                //FIN BCSYS 24112023
                RecLSalesLine.MODIFY(true);
            end;
        end;
    end;

    local procedure GetLineSpacing() LineSpacing: Integer
    var
        ToSalesLine: Record "Sales Line";
        ErrLineSpacing: Label 'There is not enough space to insert extended text lines.', Comment = 'FRA="Il n''y a pas suffisamment de place pour insérer des lignes texte étendu."';
    begin
        ToSalesLine.RESET();
        ToSalesLine.SETRANGE("Document Type", Rec."Document Type");
        ToSalesLine.SETRANGE("Document No.", Rec."Document No.");
        ToSalesLine := Rec;
        if ToSalesLine.FIND('>') then begin
            LineSpacing := (ToSalesLine."Line No." - Rec."Line No.") div 2;
            if LineSpacing = 0 then
                ERROR(ErrLineSpacing);
        end else
            LineSpacing := (Rec."Line No." + Rec."Line No." + 10000) / 2;
        exit(LineSpacing);
    end;

    local procedure DeleteEcotaxeLine()
    var
        RecLSalesLine: Record "Sales Line";
    begin
        if not "BC6 Ecotax" then begin
            RecLSalesLine.RESET(); //Lookup for an existing ECOTAX line for this item
            RecLSalesLine.SETFILTER("Document Type", '%1', "Document Type");
            RecLSalesLine.SETFILTER("Document No.", '%1', "Document No.");
            RecLSalesLine.SETFILTER("ECOTAX Attached to Line No.", '%1', "Line No.");
            if RecLSalesLine.FINDFIRST() then begin
                RecLSalesLine.DELETE();
                COMMIT();
            end;
        end;
    end;
}