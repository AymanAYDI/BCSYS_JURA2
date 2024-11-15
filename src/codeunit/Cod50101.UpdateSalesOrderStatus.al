namespace BCSYS.Jura;

using System.Threading;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
codeunit 50101 "Update Sales Order Status"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        RecLSalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        RecLSalesReceivablesSetup.GET();
        if RecLSalesReceivablesSetup."Enable SO Status" then
            GetAndUpdateOrder();
    end;

    var
        CustCheckCreditLimit: Page "Check Credit Limit";

    procedure UpdateOrderStatus(var SalesOrder: Record "Sales Header")
    var
        UnpaiedInvoice: Boolean;
        AuthorizedCredit: Boolean;
    begin
        case SalesOrder."Order Status" of
            SalesOrder."Order Status"::"Not verified":
                begin
                    UnpaiedInvoice := CheckUnpaidInvoices(SalesOrder);
                    AuthorizedCredit := CheckAuthorizedCredit(SalesOrder);

                    if UnpaiedInvoice and AuthorizedCredit then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::"Blocked - unpaid invoices and authorized credit exceeded";
                        SalesOrder.MODIFY();
                        exit;
                    end;

                    if UnpaiedInvoice and not AuthorizedCredit then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::"Blocked - unpaid invoices";
                        SalesOrder.MODIFY();
                        exit;
                    end;

                    if not UnpaiedInvoice and AuthorizedCredit then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::"Blocked - authorized credit exceeded";
                        SalesOrder.MODIFY();
                        exit;
                    end;

                    if not UnpaiedInvoice and not AuthorizedCredit then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::Verified;
                        SalesOrder.MODIFY();
                        exit;
                    end;
                end;

            SalesOrder."Order Status"::"Blocked - unpaid invoices":
                begin
                    UnpaiedInvoice := CheckUnpaidInvoices(SalesOrder);

                    if not UnpaiedInvoice then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::Verified;
                        SalesOrder.MODIFY();
                        exit;
                    end;
                end;

            SalesOrder."Order Status"::"Blocked - authorized credit exceeded":
                begin
                    UnpaiedInvoice := CheckUnpaidInvoices(SalesOrder);
                    AuthorizedCredit := CheckAuthorizedCredit(SalesOrder);

                    if UnpaiedInvoice and AuthorizedCredit then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::"Blocked - unpaid invoices and authorized credit exceeded";
                        SalesOrder.MODIFY();
                        exit;
                    end else
                        if not UnpaiedInvoice and not AuthorizedCredit then begin
                            SalesOrder."Order Status" := SalesOrder."Order Status"::Verified;
                            SalesOrder.MODIFY();
                            exit;
                        end;
                end;

            SalesOrder."Order Status"::"Blocked - unpaid invoices and authorized credit exceeded":
                begin
                    UnpaiedInvoice := CheckUnpaidInvoices(SalesOrder);
                    AuthorizedCredit := CheckAuthorizedCredit(SalesOrder);

                    if UnpaiedInvoice and not AuthorizedCredit then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::"Blocked - unpaid invoices";
                        SalesOrder.MODIFY();
                        exit;
                    end;

                    if not UnpaiedInvoice and AuthorizedCredit then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::"Blocked - authorized credit exceeded";
                        SalesOrder.MODIFY();
                        exit;
                    end;

                    if not UnpaiedInvoice and not AuthorizedCredit then begin
                        SalesOrder."Order Status" := SalesOrder."Order Status"::Verified;
                        SalesOrder.MODIFY();
                        exit;
                    end;
                end;
        end;
    end;

    local procedure GetAndUpdateOrder()
    var
        RecLSalesHeader: Record "Sales Header";
    begin
        RecLSalesHeader.SETRANGE("Document Type", RecLSalesHeader."Document Type"::Order);
        RecLSalesHeader.SETFILTER("Order Status", '<> %1 & <> %2 & <> %3', RecLSalesHeader."Order Status"::Sent, RecLSalesHeader."Order Status"::Verified, RecLSalesHeader."Order Status"::"To send");
        RecLSalesHeader.SETFILTER("Sell-to Customer No.", '<>%1', '');
        if RecLSalesHeader.FINDSET(true) then
            repeat
                UpdateOrderStatus(RecLSalesHeader);
                COMMIT();
            until RecLSalesHeader.NEXT() = 0;
    end;

    local procedure CheckAuthorizedCredit(RecPSalesHeader: Record "Sales Header"): Boolean
    begin
        if not SalesHeaderCheck(RecPSalesHeader) then
            exit(false)
        else
            exit(true);
    end;

    local procedure CheckUnpaidInvoices(RecPSalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.GET(RecPSalesHeader."Bill-to Customer No.");
        Customer.CALCFIELDS("Balance Due (LCY)");
        if Customer."Balance Due (LCY)" <> 0 then
            exit(true)
        else
            exit(false);
    end;

    local procedure SalesHeaderCheck(var SalesHeader: Record "Sales Header") CreditLimitExceeded: Boolean
    var
        AdditionalContextId: Guid;
    begin
        if not CustCheckCreditLimit.SalesHeaderShowWarningAndGetCause(SalesHeader, AdditionalContextId) then
            exit(false)
        else
            exit(true);
    end;
}

