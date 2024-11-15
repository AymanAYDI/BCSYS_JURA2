namespace BCSYS.Jura;

using System.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
xmlport 50101 "BC6 Import Sales Order CH"
{
    Caption = 'Import Sales Order CH';
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
                AutoUpdate = false;
                XmlName = 'GInteger';
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
                begin
                    if not BooGCreated then begin
                        SalesSetup.GET();

                        SalesHeader.INIT();
                        SalesHeader.VALIDATE("Document Type", SalesHeader."Document Type"::Invoice);
                        SalesHeader."No." := '';

                        SalesHeader.INSERT(true);
                        SalesHeader."Posting Description" := 'ETW Order JURA CH';
                        SalesHeader.VALIDATE("Posting Date", TODAY);
                        SalesHeader."Order Class" := 'WEBBUSINES';
                        SalesHeader.VALIDATE("Location Code", 'SAV CH');
                        SalesHeader.VALIDATE("Sell-to Customer No.", _tCustNo);
                        SalesHeader."External Document No." := _tLS;
                        SalesHeader."Reason Code" := _tCustNo;
                        SalesHeader.MODIFY(true);
                        BooGCreated := true;
                    end;
                    FillSalesLine();
                end;
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        SalesSetup.GET();
        Dateiname := SalesSetup."BC6 Import Sales Order CH";
    end;

    trigger OnPreXmlPort()
    begin
        LineNumber := 0;
    end;

    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        tMenge: Decimal;
        LineNumber: Integer;
        Dateiname: Text[80];
        BooGCreated: Boolean;

    local procedure FillSalesLine()
    begin
        if tMenge <> 0 then begin
            LineNumber := LineNumber + 10000;
            SalesLine.INIT();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := LineNumber;
            SalesLine.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
            SalesLine.VALIDATE(SalesLine.Type, SalesLine.Type::Item);
            SalesLine.VALIDATE("No.", _tItem);
            SalesLine.VALIDATE(Quantity, tMenge);
            SalesLine."Unit of Measure" := 'PCS';
            SalesLine.VALIDATE("Location Code", 'SAV CH');
            SalesLine.INSERT();
        end;
    end;
}
