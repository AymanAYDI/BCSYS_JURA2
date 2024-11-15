namespace BCSYS.Jura;
page 50104 "BC6 Webservice Partner"
{
    Caption = 'Webservice Partner';
    CardPageID = "BC6 Webservice Partner Card";
    PageType = List;
    SourceTable = "BC6 Webservice Partner";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("No."; Rec."No.")
                {
                }
            }
        }
    }
}

