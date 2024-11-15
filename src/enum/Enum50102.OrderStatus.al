namespace BCSYS.Jura;

enum 50102 "Order Status"
{
    Extensible = true;
    value(0; "Not verified")
    {
        Caption = 'Not verified', Comment = 'FRA="Non vérifiée"';
    }
    value(1; "Blocked - unpaid invoices")
    {
        Caption = 'Blocked - unpaid invoices', Comment = 'FRA="Bloquée - factures impayées"';
    }
    value(2; "Blocked - authorized credit exceeded")
    {
        Caption = 'Blocked - authorized credit exceeded', Comment = 'FRA="Bloquée - crédit autorisé dépassé"';
    }
    value(3; "Blocked - unpaid invoices and authorized credit exceeded")
    {
        Caption = 'Blocked - unpaid invoices and authorized credit exceeded', Comment = 'FRA="Bloquée - factures impayées et crédit autorisé dépassé"';
    }
    value(4; Verified)
    {
        Caption = 'Verified', Comment = 'FRA="Vérifiée"';
    }
    value(5; "To send")
    {
        Caption = 'To send', Comment = 'FRA="A envoye"';
    }
    value(6; Sent)
    {
        Caption = 'Sent', Comment = 'FRA="Envoyée"';
    }
}