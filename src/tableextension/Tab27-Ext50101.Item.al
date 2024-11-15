namespace BCSYS.Jura;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
tableextension 50101 Item extends Item //27
{
    fields
    {
        field(50100; "BC6 Item Eco Taxe"; Code[10])
        {
            Caption = 'Item Eco Taxe', Comment = 'FRA="Code Article pour Eco Taxe"';
            TableRelation = Item."No." where("BC6 Item for Eco Taxe" = const(true), Blocked = const(false));
        }
        field(50101; "BC6 Item for Eco Taxe"; Boolean)
        {
            Caption = 'Item for Eco Taxe', Comment = 'FRA="Article Eco Taxe"';
        }
        field(50102; "No. Local Shelf"; Code[10])
        {
            Caption = 'Local Shelf No.', Comment = 'FRA="N° étagère locale"';
        }
        field(50103; "BC6 Stock magasin SAV"; Decimal)
        {
            Caption = 'Location Inventory SAV', Comment = 'FRA="Stock magasin SAV"';
            FieldClass = FlowField;
            CalcFormula = sum("Item Ledger Entry".Quantity where("Item No." = field("No."),
                          "Global Dimension 1 Code" = field("Global Dimension 1 Filter")
                          , "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                          "Location Code" = const('SAV'), "Drop Shipment" = field("Drop Shipment Filter"),
                          "Variant Code" = field("Variant Filter")));
            DecimalPlaces = 0 : 5;
        }
        field(50104; "BC6 Stock magasin SCHNEIDER"; Decimal)
        {
            Caption = 'Location Inventory SCHNEIDER', Comment = 'FRA="Stock magasin SCHNEIDER"';
            FieldClass = FlowField;
            CalcFormula = sum("Item Ledger Entry".Quantity where("Item No." = field("No."),
            "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
            "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
            "Location Code" = const('SCHNEIDER'), "Drop Shipment" = field("Drop Shipment Filter"),
            "Variant Code" = field("Variant Filter")));
            DecimalPlaces = 0 : 5;
        }
        field(50105; "BC6 Stock magasin WEBSHOP"; Decimal)
        {
            Caption = 'Location Inventory WEBSHOP', Comment = 'FRA = "Stock magasin WEBSHOP"';
            FieldClass = FlowField;
            CalcFormula = sum("Item Ledger Entry".Quantity where("Item No." = field("No."),
            "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
            "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
            "Location Code" = const('WEBSHOP'), "Drop Shipment" = field("Drop Shipment Filter"),
            "Variant Code" = field("Variant Filter")));
            DecimalPlaces = 0 : 5;
        }
    }
}
