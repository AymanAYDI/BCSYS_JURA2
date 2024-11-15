namespace BCSYS.Jura;

pageextension 50116 "JWS JURA Serv. Activities" extends "JWS JURA Serv. Activities" //81039
{
    layout
    {
        addafter(Control9)
        {
            cuegroup(Sales)
            {
                field(Customer; Rec."BC6 - Customer")
                {
                    ApplicationArea = All;
                }
                field(Items; Rec."BC6 - Items")
                {
                    ApplicationArea = All;
                }
                field("Sales Quotes"; Rec."BC6 - Sales Quotes")
                {
                    ApplicationArea = All;
                }
                field("Sales Orders"; Rec."BC6 - Sales Orders")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Invoices"; Rec."BC6 - Posted Sales Invoices")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Cr Memo"; Rec."BC6 - Posted Sales Cr Memo")
                {
                    ApplicationArea = All;
                }
                field("Sales Invoices"; Rec."BC6 - Sales Invoices")
                {
                    ApplicationArea = All;
                }
                field("Sales Cr Memo"; Rec."BC6 - Sales Cr Memo")
                {
                    ApplicationArea = All;
                }
                field("Ediag New"; Rec."Service Orders - Ediag New")
                {
                    ApplicationArea = All;
                }
                field("Ediag Finish"; Rec."Service Orders - Ediag Finish")
                {
                    ApplicationArea = All;
                }
            }
        }
        addafter(Sales)
        {
            cuegroup("Serviceaufträge Singen")
            {
                Caption = 'Service Orders Singen';
                field("Service Orders WA"; Rec."Service Orders WA")
                {
                    ApplicationArea = All;
                }
                field("Service Orders - Jura Singen"; Rec."Service Orders - Jura Singen")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}