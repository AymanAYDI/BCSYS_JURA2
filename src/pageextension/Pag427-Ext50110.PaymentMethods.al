namespace BCSYS.Jura;

using Microsoft.Bank.BankAccount;
pageextension 50110 "Payment Methods" extends "Payment Methods" //427
{
    layout
    {
        addafter(Description)
        {
            field("Acceptation Code"; Rec."Acceptation Code")
            {
                ApplicationArea = All;
            }
        }
    }
}