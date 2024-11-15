namespace BCSYS.Jura;
table 50100 "BC6 Webservice Partner"
{
    Caption = 'Webservice Partner';
    DrillDownPageID = "BC6 Webservice Partner";
    LookupPageID = "BC6 Webservice Partner";

    fields
    {
        field(1; "No."; Enum Service)
        {
            Caption = 'No.', Comment = 'FRA="N°"';
        }
        field(2; URL; Text[250])
        {
            Caption = 'URL', Comment = 'FRA="URL"';
        }
        field(3; "SOAP Action"; Text[50])
        {
            Caption = 'SOAP Action', Comment = 'FRA="SOAP Action"';
        }
        field(4; Namespace; Text[250])
        {
            Caption = 'Namespace', Comment = 'FRA="Namespace"';
        }
        field(5; "Our Customer No."; Text[30])
        {
            Caption = 'Our Customer No.', Comment = 'FRA="Our Customer No."';
        }
        field(6; "Login Name"; Text[50])
        {
            Caption = 'Login Name', Comment = 'FRA="Login Name"';
        }
        field(7; Password; Text[50])
        {
            Caption = 'Password', Comment = 'FRA="Mot de passe"';
            ExtendedDatatype = Masked;
        }
        field(8; "Application ID"; Text[50])
        {
            Caption = 'Application ID', Comment = 'FRA="ID application"';
        }
        field(9; "Application Token"; Text[50])
        {
            Caption = 'Application Token', Comment = 'FRA="Application Token"';
            ExtendedDatatype = Masked;
        }
        field(10; "Package Weight"; Decimal)
        {
            Caption = 'Package Weight', Comment = 'FRA="Poids Colis"';
        }
        field(11; "Package Length"; Decimal)
        {
            Caption = 'Package Length', Comment = 'FRA="Longueur Colis"';
        }
        field(12; "Package Width"; Decimal)
        {
            Caption = 'Package Width', Comment = 'FRA="Largeur Colis"';
        }
        field(13; "Package Height"; Decimal)
        {
            Caption = 'Package Height', Comment = 'FRA="Hauteur Colis"';
        }
        field(14; "Our Import Customer No."; Text[30])
        {
            Caption = 'Our Import Customer No.', Comment = 'FRA="Our Import Customer No."';
        }
        field(15; "E-Mail Recipient Retoure"; Text[80])
        {
            Caption = 'E-Mail Recipient Retoure', Comment = 'FRA="E-Mail Recipient Retoure"';
        }
        field(16; "Responsible Service Receipt"; Text[100])
        {
            Caption = 'Responsible Service Receipt', Comment = 'FRA="Responsible Service Receipt"';
        }
        field(100; "DL DHL Label Instead of Print"; Boolean)
        {
            Caption = 'DL DHL Label Instead of Print', Comment = 'FRA="Télécharger étiquette DHL au lieu d''imprimer"';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}
