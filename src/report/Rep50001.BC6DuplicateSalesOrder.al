namespace BCSYS.Jura;

using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Comment;
report 50001 "BC6 Duplicate Sales Order"
{
    Caption = 'Duplicate Sales Order';
    ProcessingOnly = true;
    UseRequestPage = false;
    ApplicationArea = All;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const(Order));
            RequestFilterFields = "Document Type", "No.";

            trigger OnAfterGetRecord()
            var
                RecLSalesSetup: Record "Sales & Receivables Setup";
                CodCopyDocumentMgt2: Codeunit "BC6 Copy Document Mgt2";
                DocType: Enum "Sales Document Type From";
            begin
                TESTFIELD(Status, Status::Open);
                SETRANGE("Document Type", "Document Type");
                SETRANGE("No.", "No.");
                RecGSalesLine.SETRANGE("Document Type", "Sales Header"."Document Type");
                RecGSalesLine.SETRANGE("Document No.", "Sales Header"."No.");

                RecGSalesCommentLine.SETRANGE("Document Type", "Sales Header"."Document Type");
                RecGSalesCommentLine.SETRANGE("No.", "Sales Header"."No.");
                RecGSalesCommentLine.SETRANGE("Document Line No.", 0);

                RecGSalesHeader.INIT();
                RecGSalesHeader."Document Type" := "Sales Header"."Document Type";

                RecLSalesSetup.GET();
                if RecLSalesSetup."Order Nos." <> '' then
                    RecGSalesHeader."No. Series" := RecLSalesSetup."Order Nos.";
                if (STRPOS("Sales Header"."No.", '/') < STRLEN("Sales Header"."No.")) and (STRPOS("Sales Header"."No.", '/') <> 0) then
                    RecGSalesHeader."No." := INCSTR("Sales Header"."No.")
                else
                    RecGSalesHeader."No." := STRSUBSTNO('%1/%2', "Sales Header"."No.", 1);

                RecGSalesHeader.SetHideValidationDialog(true);
                RecGSalesHeader.INSERT(true);

                RecGSalesLine2.SETRANGE("Document Type", "Sales Header"."Document Type");
                RecGSalesLine2.SETRANGE("Document No.", "Sales Header"."No.");
                RecGSalesLine2.SETFILTER("Outstanding Quantity", '<>0');
                if RecGSalesLine2.ISEMPTY then
                    ERROR(ErrTransfer);

                CodCopyDocumentMgt2.SetProperties(true, false, false, false, true, RecLSalesSetup."Exact Cost Reversing Mandatory", false);

                // Commit();
                DocType := DocType::Order;
                CodCopyDocumentMgt2.CopySalesDoc(DocType, "Sales Header"."No.", RecGSalesHeader);

                RecGSalesHeader."Order Status" := RecGSalesHeader."Order Status"::"Not verified";
                RecGSalesHeader.MODIFY(true);

                RecLSalesSetup.GET();
                if RecLSalesSetup."Enable SO Status" then
                    CduGUpdateSalesOrderStatus.UpdateOrderStatus(RecGSalesHeader);

                //Only comment header
                if RecGSalesCommentLine.FINDSET() then
                    repeat
                        RecGSalesCommentLine2.INIT();
                        RecGSalesCommentLine2.TRANSFERFIELDS(RecGSalesCommentLine);
                        RecGSalesCommentLine2."No." := RecGSalesHeader."No.";
                        RecGSalesCommentLine2.INSERT(true);
                    until RecGSalesCommentLine.NEXT() = 0;
            end;
        }
    }

    var
        RecGSalesHeader: Record "Sales Header";
        RecGSalesLine: Record "Sales Line";
        RecGSalesLine2: Record "Sales Line";
        RecGSalesCommentLine: Record "Sales Comment Line";
        RecGSalesCommentLine2: Record "Sales Comment Line";
        CduGUpdateSalesOrderStatus: Codeunit "Update Sales Order Status";
        ErrTransfer: Label 'There is nothing to transfer.', Comment = 'FRA="Il n''y a aucune ligne à transférer."';
}

