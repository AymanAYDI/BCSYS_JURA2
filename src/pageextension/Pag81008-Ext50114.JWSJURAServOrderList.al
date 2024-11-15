namespace BCSYS.Jura;

pageextension 50114 "JWS JURA Serv. Order List" extends "JWS JURA Serv. Order List" //81008
{
    layout
    {
        addlast(Control1)
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
}