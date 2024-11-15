namespace BCSYS.Jura;

page 50105 "BC6 Webservice Partner Card"
{
    Caption = 'Webservice Partner Card';
    PageType = Card;
    SourceTable = "BC6 Webservice Partner";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                }
                field(URL; Rec.URL)
                {
                }
                field("SOAP Action"; Rec."SOAP Action")
                {
                }
                field(Namespace; Rec.Namespace)
                {
                    Caption = 'Namespace', Comment = 'FRA="Espace de noms"';
                }
                field("Package Height"; Rec."Package Height")
                {
                }
                field("Package Length"; Rec."Package Length")
                {
                }
                field("Package Width"; Rec."Package Width")
                {
                }
                field("Package Weight"; Rec."Package Weight")
                {
                }
                field("E-Mail Recipient Retoure"; Rec."E-Mail Recipient Retoure")
                {
                }
                field("Responsible Service Receipt"; Rec."Responsible Service Receipt")
                {
                }
                field("DL DHL Label Instead of Print"; Rec."DL DHL Label Instead of Print")
                {
                }
            }
            group(AcountIno)
            {
                Caption = 'Account Information', Comment = 'FRA="Informations sur le compte"';
                field("Our Customer No."; Rec."Our Customer No.")
                {
                }
                field("Our Import Customer No."; Rec."Our Import Customer No.")
                {
                }
                field("Login Name"; Rec."Login Name")
                {
                }
                field(Password; Rec.Password)
                {
                }
                field("Application ID"; Rec."Application ID")
                {
                }
                field("Application Token"; Rec."Application Token")
                {
                }
            }
        }
    }
}

