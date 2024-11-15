namespace BCSYS.Jura;

using Microsoft.Sales.Setup;

tableextension 50109 "Sales & Receivables Setup" extends "Sales & Receivables Setup" //311
{
    fields
    {
        field(50100; "Enable SO Status"; boolean)
        {
            Caption = 'Enable Sales Order Status', Comment = 'FRA="Activer MAJ statut commande vente"';
        }
        field(50101; "BC6 Mandant Code"; Code[10])
        {
            Caption = 'Mandant Code';
        }
        field(50102; "BC6 Mandant Name"; Text[30])
        {
            Caption = 'Mandant Name', Comment = 'FRA="Mandant Name"';
        }
        field(50103; "BC6 Site"; Text[30])
        {
            Caption = 'Site', Comment = 'FRA="Site"';
        }
        field(50104; "BC6 Filename LS Export"; Text[50])
        {
            Caption = 'Filename LS Export', Comment = 'FRA="Filename LS Export"';
        }
        field(50105; "BC6 No. Fournisseur Spareparts"; Code[20])
        {
            Caption = 'No. Fournisseur Spareparts';
        }
        field(50106; "BC6 Import Purch. Order CH"; Text[80])
        {
            Caption = 'Import Purch. Order CH';
        }
        field(50107; "BC6 Import Sales Order CH"; Text[80])
        {
            Caption = 'Import Sales Order CH';
        }
    }
}
