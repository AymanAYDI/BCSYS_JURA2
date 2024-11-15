namespace BCSYS.Jura;

using Microsoft.Sales.History;
using Microsoft.Sales.Setup;
using System.IO;
codeunit 50107 "BC6 ETW-Management"
{
    Permissions = TableData "Sales Shipment Header" = rimd;

    trigger OnRun()
    begin
        CLEAR(ETWFileP); //To close reading, from the begining, if there is "Error I/O"
        CLEAR(ETWFileS);

        SalesSetup.GET();
        SalesSetup.TESTFIELD("BC6 Import Purch. Order CH");
        SalesSetup.TESTFIELD("BC6 Import Sales Order CH");

        if (COPYSTR(SalesSetup."BC6 Import Purch. Order CH", STRLEN(SalesSetup."BC6 Import Purch. Order CH")) <> '\') then
            PathPO := CopyStr(SalesSetup."BC6 Import Purch. Order CH" + '\', 1, MaxStrLen(PathPO))
        else
            PathPO := SalesSetup."BC6 Import Purch. Order CH";

        if (COPYSTR(SalesSetup."BC6 Import Sales Order CH", STRLEN(SalesSetup."BC6 Import Sales Order CH")) <> '\') then
            PathSO := CopyStr(SalesSetup."BC6 Import Sales Order CH" + '\', 1, MaxStrLen(PathSO))
        else
            PathSO := SalesSetup."BC6 Import Sales Order CH";

        //Purchase
        ImportFile.RESET();
        ImportFile.SETRANGE(Path, PathPO);

        ImportFile.SETFILTER(ImportFile.Name, 'ETW*');

        ImportFile.SETRANGE("Is a file", true);

        if ImportFile.FIND('-') then begin
            Window.OPEN(
              'ETW Import-Purch. #1####################################');

            repeat
                if EXISTS(PathPO + ImportFile.Name) then
                    if COPY(PathPO + ImportFile.Name, PathPO + 'Archiv\' + ImportFile.Name) then begin
                        Window.UPDATE(1, ImportFile.Name);
                        FromFile.OPEN(PathPO + ImportFile.Name);
                        FromFile.CREATEINSTREAM(IsGStream);
                        XMLPORT.IMPORT(XMLPORT::"BC6 Import Purchase Order CH", IsGStream);
                        FromFile.CLOSE();
                        CLEAR(ETWFileP);
                        ERASE(PathPO + ImportFile.Name);
                        COMMIT();
                    end;
            until ImportFile.NEXT(+1) = 0;

            Window.CLOSE();
        end;
        COMMIT();

        //Sales
        ImportFile.RESET();
        ImportFile.SETRANGE(Path, PathSO);

        ImportFile.SETFILTER(ImportFile.Name, 'ETW*');

        ImportFile.SETRANGE("Is a file", true);

        if ImportFile.FIND('-') then begin

            Window.OPEN(
              'ETW Import-Sales #1####################################');

            repeat
                if EXISTS(PathSO + ImportFile.Name) then
                    if COPY(PathSO + ImportFile.Name, PathSO + 'Archiv\' + ImportFile.Name) then begin
                        Window.UPDATE(1, ImportFile.Name);
                        CLEAR(ETWFileS);
                        FromFile.OPEN(PathSO + ImportFile.Name); //MB 22/07/2021 : Use InStream instead of File.RunModal
                        FromFile.CREATEINSTREAM(IsGStream);
                        CLEAR(XmlGImportSalesOrderCH);
                        XmlGImportSalesOrderCH.SETSOURCE(IsGStream);
                        XmlGImportSalesOrderCH.IMPORT();
                        FromFile.CLOSE();
                        ERASE(PathSO + ImportFile.Name);
                        COMMIT();
                    end;
            until ImportFile.NEXT(+1) = 0;

            Window.CLOSE();
        end;
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        ImportFile: Record File;
        ETWFileP: XMLport "BC6 Import Purchase Order CH";
        ETWFileS: XMLport "BC6 Import Sales Order CH";
        XmlGImportSalesOrderCH: XMLport "BC6 Import Sales Order CH";
        PathPO: Text[80];
        Window: Dialog;
        PathSO: Text[80];
        FromFile: File;
        IsGStream: InStream;
}
