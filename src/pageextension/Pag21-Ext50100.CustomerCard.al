namespace BCSYS.Jura;

using Microsoft.Sales.Customer;
pageextension 50100 "Customer Card" extends "Customer Card" //21
{
    layout
    {
        addafter(Blocked)
        {
            field("BC6 Objectif CA"; Rec."BC6 Objectif CA")
            {
                ApplicationArea = All;
            }
        }
    }
}

