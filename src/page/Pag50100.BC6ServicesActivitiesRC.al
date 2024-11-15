namespace BCSYS.Jura;

using Microsoft.EServices.EDocument;
using Microsoft.Sales.Customer;
page 50100 "BC6 Services Activities RC"
{
    Caption = 'Services Activities RC';
    PageType = RoleCenter;
    ApplicationArea = All;

    layout
    {
        area(rolecenter)
        {
            group(Group)
            {
                part("JWS JURA Serv. Activities"; "JWS JURA Serv. Activities")
                {
                }
                part("Services Activities"; "BC6 Services Activities")
                {
                }
                part("Report Inbox Part"; "Report Inbox Part")
                {
                }
                part("My Customers"; "My Customers")
                {
                    Visible = false;
                }
            }
        }
    }
}

