namespace BCSYS.Jura;

using System.IO;
using System.Utilities;
report 50003 "BC6 Print Shipment Label"
{
    Caption = 'Print Shipment Label';
    ProcessingOnly = true;
    UseRequestPage = false;
    ApplicationArea = All;

    dataset
    {
        dataitem("JWC Packing Track No."; "JWC Packing Track No.")
        {

            trigger OnAfterGetRecord()
            var
                FileManagement: Codeunit "File Management";
                RecRef: RecordRef;
                Txt001: Label '%1%2_%3.pdf', Comment = 'FRA="%1%2_%3.pdf"';
            begin
                if "BC6 Shipment Label".HASVALUE then begin
                    CALCFIELDS("BC6 Shipment Label");
                    // CLEAR(TempBlob);
                    // TempBlob.INIT();
                    // TempBlob.Blob := "BC6 Shipment Label";
                    TempBlob.FromRecord("JWC Packing Track No.", "JWC Packing Track No.".FieldNo("BC6 Shipment Label"));
                    CurrentPath := STRSUBSTNO(Txt001, TEMPORARYPATH, FIELDCAPTION("BC6 Shipment Label"), "Line No.");
                    if EXISTS(CurrentPath) then
                        ERASE(CurrentPath);
                    LabelFullPath := CopyStr(FileManagement.BLOBExport(TempBlob, CurrentPath, true), 1, MaxStrLen(LabelFullPath));
                    if LabelFullPath <> '' then begin
                        RecRef.Open(Database::"JWC Packing Track No.");
                        if not WebClientServices.TrySendReportToPrinter(RecRef, 50003) then // TODO: : Verify
                            ERROR(DocumentNotPrintedError);
                    end;
                end;
            end;
        }
    }

    var
        WebClientServices: Codeunit "JWC Web Client Services";
        TempBlob: Codeunit "Temp Blob";
        CurrentPath: Text[1024];
        LabelFullPath: Text[1024];
        DocumentNotPrintedError: Label 'An error occured when the file was sent to the printer. Contact your administrator.', Comment = 'FRA="Une erreur est survenue lors de l''envoi du fichier à l''imprimante. Contactez votre administrateur."';
}

