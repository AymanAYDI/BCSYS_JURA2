namespace BCSYS.Jura;

using Microsoft.Bank.BankAccount;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Reporting;
using Microsoft.Bank.Payment;
codeunit 50105 "BC6 Event_Mgt"
{
    var
        RecGPaymentMethod: Record "Payment Method";
        Customer: Record Customer;
        Vendor: Record Vendor;

    [EventSubscriber(ObjectType::Table, Database::"Payment Line", OnAfterUpdateEntry, '', false, false)]
    local procedure OnAfterUpdateEntry(var PaymentLine: Record "Payment Line")
    begin
        if PaymentLine."Account Type" = PaymentLine."Account Type"::Customer then begin
            Customer.Get(PaymentLine."Account No.");
            if RecGPaymentMethod.Get(Customer."Payment Method Code") then
                PaymentLine."Acceptation Code" := RecGPaymentMethod."Acceptation Code".AsInteger();
        end;
        if PaymentLine."Account Type" = PaymentLine."Account Type"::Vendor then begin
            Vendor.Get(PaymentLine."Account No.");
            if RecGPaymentMethod.Get(Vendor."Payment Method Code") then
                PaymentLine."Acceptation Code" := RecGPaymentMethod."Acceptation Code".AsInteger();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, OnAfterSubstituteReport, '', false, false)]
    local procedure OnAfterSubstituteReport(ReportId: Integer; RunMode: Option Normal,ParametersOnly,Execute,Print,SaveAs,RunModal; RequestPageXml: Text; RecordRef: RecordRef; var NewReportId: Integer)
    begin
        if ReportId = Report::"JWC Sales Quote" then
            NewReportId := Report::"BC6 JWC Sales Quote";
        if ReportId = Report::"JWC Sales Order" then
            NewReportId := Report::"BC6 JWC Sales Order";
        if ReportId = Report::"JWC Shipment Picking List" then
            NewReportId := Report::"BC6 JWC Shipment Picking List";
        if ReportId = Report::"JWC Sales Pro-Forma Invoice" then
            NewReportId := Report::"BC6 Sales Pro-Forma Invoice";
        if ReportId = Report::"JWC Sales Invoice" then
            NewReportId := Report::"BC6 JWC Sales Invoice";
        if ReportId = Report::"JWC Sales Credit Memo" then
            NewReportId := Report::"BC6 JWC Sales Credit Memo";
    end;
}