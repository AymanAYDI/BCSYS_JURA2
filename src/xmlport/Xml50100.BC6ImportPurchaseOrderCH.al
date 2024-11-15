namespace BCSYS.Jura;

using System.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Setup;
using Microsoft.Purchases.Posting;
xmlport 50100 "BC6 Import Purchase Order CH"
{
    Caption = 'Import Purchase Order CH';
    FieldSeparator = '|';
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                AutoSave = false;
                XmlName = 'Integer';
                SourceTableView = sorting(Number);
                textelement(_tCustNo)
                {
                }
                textelement(_tItem)
                {
                }
                textelement(_tMenge)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        EVALUATE(tMenge, _tMenge);
                    end;
                }
                textelement(_tLS)
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    RecLSalesReceivablesSetup: Record "Sales & Receivables Setup";
                begin
                    if not BooGCreated then begin
                        RecLSalesReceivablesSetup.GET();
                        SalesSetup.GET();

                        PurchHeader.INIT();
                        PurchHeader.VALIDATE("Document Type", PurchHeader."Document Type"::Invoice);
                        PurchHeader.INSERT(true);
                        PurchHeader.VALIDATE("Buy-from Vendor No.", RecLSalesReceivablesSetup."BC6 No. Fournisseur Spareparts");
                        PurchHeader."Posting Description" := 'ETW Order JURA CH';
                        PurchHeader.VALIDATE("Posting Date", TODAY);
                        PurchHeader.VALIDATE("Location Code", 'SAV CH');
                        PurchHeader.VALIDATE("VAT Country/Region Code", 'CH');
                        PurchHeader."Vendor Order No." := _tLS;
                        PurchHeader."Vendor Invoice No." := _tLS; //+ ' ' + FORMAT(TODAY); MB 06/10/2021
                        PurchHeader."Reason Code" := _tCustNo;
                        PurchHeader.MODIFY(true);
                        BooGCreated := true;
                    end;
                    FillPurchLine();
                end;
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        SalesSetup.GET();
        Dateiname := SalesSetup."BC6 Import Purch. Order CH";
    end;

    trigger OnPostXmlPort()
    begin
        PostPurch(PurchHeader, false);
    end;

    trigger OnPreXmlPort()
    begin
        LineNumber := 0;
    end;

    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesSetup: Record "Sales & Receivables Setup";
        LineNumber: Integer;
        tMenge: Decimal;
        Dateiname: Text[80];
        BooGCreated: Boolean;

    procedure FillPurchLine()
    begin
        if tMenge <> 0 then begin
            LineNumber := LineNumber + 10000;
            PurchLine.INIT();
            PurchLine."Document Type" := PurchHeader."Document Type";
            PurchLine."Document No." := PurchHeader."No.";
            PurchLine."Line No." := LineNumber;
            PurchLine.VALIDATE("Buy-from Vendor No.", PurchHeader."Buy-from Vendor No.");
            PurchLine.VALIDATE(PurchLine.Type, PurchLine.Type::Item);
            PurchLine.VALIDATE("No.", _tItem);
            PurchLine.VALIDATE(Quantity, tMenge);
            PurchLine."Unit of Measure" := 'PCS';
            PurchLine.VALIDATE("Location Code", 'SAV CH');
            PurchLine.INSERT();
        end;
    end;

    procedure PostPurch(var pPurchHeader: Record "Purchase Header"; pWithYesNoAtPosting: Boolean)
    var
        PurchPost: Codeunit "Purch.-Post";
    begin
        PurchPost.RUN(pPurchHeader);
    end;
}
