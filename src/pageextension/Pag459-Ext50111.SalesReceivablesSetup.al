namespace BCSYS.Jura;

using Microsoft.Sales.Setup;
pageextension 50111 "Sales & Receivables Setup" extends "Sales & Receivables Setup" //459
{
    layout
    {
        addlast(General)
        {
            field("Enable SO Status"; Rec."Enable SO Status")
            {
                ApplicationArea = All;
            }
        }
        addlast("JWC JURA")
        {
            field("BC6 Import Purch. Order CH"; Rec."BC6 Import Purch. Order CH")
            {
                ApplicationArea = All;
            }
            field("BC6 Import Sales Order CH"; Rec."BC6 Import Sales Order CH")
            {
                ApplicationArea = All;
            }
            field("BC6 No. Fournisseur Spareparts"; Rec."BC6 No. Fournisseur Spareparts")
            {
                ApplicationArea = All;
            }
        }
        addafter("JWC JURA")
        {
            group(Schneider)
            {
                Caption = 'Schneider', Comment = 'FRA="Schneider"';
                field("BC6 Site"; Rec."BC6 Site")
                {
                    ApplicationArea = All;
                }
                field("BC6 Mandant Code"; Rec."BC6 Mandant Code")
                {
                    ApplicationArea = All;
                }
                field("Mandant Name"; Rec."BC6 Mandant Name")
                {
                    ApplicationArea = All;
                }
                field("Filename LS Export"; Rec."BC6 Filename LS Export")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}