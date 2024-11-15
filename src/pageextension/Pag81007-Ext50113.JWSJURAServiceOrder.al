namespace BCSYS.Jura;

pageextension 50113 "JWS JURA Service Order" extends "JWS JURA Service Order" //81007
{
    layout
    {
        addlast("Invoice Details")
        {
            group(SAFERPAY)
            {
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Service Payment Status"; Rec."Service Payment Status")
                {
                    ApplicationArea = All;
                }
                field("Payment Text"; Rec."Payment Text")
                {
                    ApplicationArea = All;
                }
            }
        }
        addbefore(Status)
        {
            field(Plant; Rec.Plant)
            {
                ApplicationArea = All;
            }
        }
    }
}