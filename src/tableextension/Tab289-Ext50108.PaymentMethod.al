namespace BCSYS.Jura;

using Microsoft.Bank.BankAccount;
tableextension 50108 "Payment Method" extends "Payment Method" //289
{
    fields
    {
        field(50100; "Acceptation Code"; Enum Code)
        {
            Caption = 'Acceptation Code';
        }
    }
}