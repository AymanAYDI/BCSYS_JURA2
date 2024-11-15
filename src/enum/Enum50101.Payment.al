namespace BCSYS.Jura;
enum 50101 Payment
{
    Extensible = true;

    value(50100; " ")
    {
        Caption = ' ';
    }
    value(50101; Pending)
    {
        Caption = 'Pending';
    }
    value(50102; Paid)
    {
        Caption = 'Paid';
    }
    value(50103; Returned)
    {
        Caption = 'Returned';
    }
    value(50104; Rejected)
    {
        Caption = 'Rejected';
    }
    value(50105; Prepaid)
    {
        Caption = 'Prepaid';
    }
}