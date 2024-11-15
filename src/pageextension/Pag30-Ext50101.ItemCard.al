namespace BCSYS.Jura;

using Microsoft.Inventory.Item;
pageextension 50101 "Item Card" extends "Item Card" //30
{
    layout
    {
        addafter(Description)
        {
            field("BC6 Item Eco Taxe"; Rec."BC6 Item Eco Taxe")
            {
                ApplicationArea = All;
            }
            field("BC6 Item for Eco Taxe"; Rec."BC6 Item for Eco Taxe")
            {
                ApplicationArea = All;
            }
        }
        addafter("Shelf No.")
        {
            field("No. Local Shelf"; Rec."No. Local Shelf")
            {
                ApplicationArea = All;
            }
        }
    }
}

