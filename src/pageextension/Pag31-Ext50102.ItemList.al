namespace BCSYS.Jura;

using Microsoft.Inventory.Item;
pageextension 50102 "Item List" extends "Item List" //31
{
    layout
    {
        addafter(Description)
        {
            field("No. Local Shelf"; Rec."No. Local Shelf")
            {
                ApplicationArea = All;
            }
        }
        addafter(InventoryField)
        {
            field("BC6 Stock magasin SAV"; Rec."BC6 Stock magasin SAV")
            {
                Editable = false;
                ApplicationArea = All;
            }
            field("BC6 Stock magasin SCHNEIDER"; Rec."BC6 Stock magasin SCHNEIDER")
            {
                Editable = false;
                ApplicationArea = All;
            }
            field("BC6 Stock magasin WEBSHOP"; Rec."BC6 Stock magasin WEBSHOP")
            {
                Editable = false;
                ApplicationArea = All;
            }
            field("Qty. on Sales Order"; Rec."Qty. on Sales Order")
            {
                ApplicationArea = All;
            }
            field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
            {
                ApplicationArea = All;
            }
        }
    }
}
