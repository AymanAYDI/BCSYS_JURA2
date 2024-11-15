namespace BCSYS.Jura;

using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
report 50002 "BC6 Export LS Schneider Pre"
{
    Caption = 'Export LS Schneider Pre';
    ProcessingOnly = true;
    UseRequestPage = false;
    ApplicationArea = All;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = where("Location Code" = filter('SCHNEIDER'));
            RequestFilterFields = "No.", "Sell-to Customer No.", "Posting Date", "Shipment Date", "Responsibility Center";
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.")
                                    where(Type = filter(' ' | Item),
                                          "BC6 Ecotax" = const(false));

                trigger OnAfterGetRecord()
                begin
                    if (Type = Type::Item) and (Quantity <= 0) then
                        CurrReport.SKIP();
                    IntGPOS := IntGPOS + 1;

                    TxtGWriteline := 'AUPOS' + '|';
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + RecGSalesReceivablesSetup."BC6 Mandant Name" + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + RecGSalesReceivablesSetup."BC6 Mandant Name" + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + "Document No." + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + FORMAT(IntGPOS) + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + "No." + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := TxtGWriteline + DELCHR(FORMAT(Quantity), '=', TxtGApostrophe) + '|';
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));

                    TransferFile.WRITE(TxtGWriteline);
                end;

                trigger OnPostDataItem()
                begin
                    TxtGWriteline := 'AUEND' + '|';
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + RecGSalesReceivablesSetup."BC6 Mandant Name" + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + RecGSalesReceivablesSetup."BC6 Mandant Name" + '|', 1, MaxStrLen(TxtGWriteline));
                    TxtGWriteline := CopyStr(TxtGWriteline + "Document No." + '|', 1, MaxStrLen(TxtGWriteline));

                    TransferFile.WRITE(TxtGWriteline);
                end;

                trigger OnPreDataItem()
                begin
                    SETRANGE("No.", '00000', '99999');
                end;
            }

            trigger OnAfterGetRecord()
            var
                ErrLLocationCode: Label 'The Location code must be SCHNEIDER - %1', Comment = 'FRA="Le code du Lieu doit être SCHNEIDER - %1"';
            begin
                if "Location Code" <> 'SCHNEIDER' then
                    ERROR(ErrLLocationCode, "No.");
                if GUIALLOWED then
                    Indicateur.UPDATE(1, "No.");

                IntGi := 0;
                TxtGWriteline := 'AKOPF' + '|';
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + RecGSalesReceivablesSetup."BC6 Mandant Name" + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + RecGSalesReceivablesSetup."BC6 Mandant Name" + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + "No." + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + 'STANDARD' + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + FORMAT("Shipment Date", 0, '<Month,2>/<Day,2>/<Year,2>') + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("Sell-to Customer Name") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("Sell-to Address") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + 'FR' + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("Sell-to Post Code") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("Sell-to City") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("Ship-to Name") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("Ship-to Address") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + 'FR' + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + "Ship-to Post Code" + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("Ship-to City") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + "No." + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + "Bill-to Customer No." + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("Shipment Comment") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + Ascii2Ansi("External Document No.") + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));
                TxtGWriteline := CopyStr(TxtGWriteline + '|', 1, MaxStrLen(TxtGWriteline));

                TransferFile.WRITE(TxtGWriteline);

                "Sales Header"."BC6 PreEDI" := true;
                "Sales Header".MODIFY();
            end;

            trigger OnPostDataItem()
            begin
                TransferFile.CLOSE();
                COMMIT();
                SLEEP(500);
                if GUIALLOWED then
                    Indicateur.CLOSE();
            end;

            trigger OnPreDataItem()
            begin
                if GUIALLOWED then
                    Indicateur.OPEN('#1#############');
                TransferFile.TEXTMODE(true);
                TransferFile.WRITEMODE(true);

                TransferFile.CREATE(TxtGFileName);
            end;
        }
    }

    trigger OnPreReport()
    begin
        RecGSalesReceivablesSetup.GET();
        IntGPOS := 0;
        RecGSalesReceivablesSetup.TESTFIELD(RecGSalesReceivablesSetup."BC6 Site");
        TxtGFileName := RecGSalesReceivablesSetup."BC6 Filename LS Export" + 'AUFTR_' + //original value = \\Frsrvsql01\ftp edi\HOSTtoWMS\
            FORMAT(CURRENTDATETIME, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>') + '.txt';

        CodGShipFileCounter := PADSTR('', 6 - STRLEN(CodGShipFileCounter), '0') + CodGShipFileCounter;
        Character := 39;
        TxtGApostrophe := FORMAT(Character);
    end;

    var
        RecGSalesReceivablesSetup: Record "Sales & Receivables Setup";
        Indicateur: Dialog;
        TransferFile: File;
        TxtGFileName: Text[150];
        TxtGWriteline: Text[1000];
        TxtGApostrophe: Text[1];
        IntGi: Integer;
        IntGPOS: Integer;
        CodGShipFileCounter: Code[6];
        Character: Char;

    local procedure Ascii2Ansi(_String: Text[1024]): Text[1024]
    begin
        exit(CONVERTSTR(_String, 'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒáíóúñÑªº¿®ÁÂÀÊËÈÍÎÏÌÓßÔÒÚÛÙ',
                                        'Ã³ÚÔõÓÕþÛÙÞ´¯ý’µã¶÷ž¹¨ Íœ°úÏÎâßÝ¾·±Ð¬‡Š«Œ‹“”‘–—¤•ËÈÊš›™'));
    end;
}

