namespace BCSYS.Jura;

using System.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Assembly.Document;
using Microsoft.Utilities;
using Microsoft.CRM.Segment;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Shipping;
using System.Globalization;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Sales.History;
report 50006 "BC6 JWC Shipment Picking List"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/rdl/ShipmentPickingList.rdl';

    Caption = 'Shipment Picking List';
    PreviewMode = PrintLayout;
    ApplicationArea = All;

    dataset
    {
        dataitem(Static; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(Picture_CompanyInfo; CompanyInformation.Picture)
            {
            }
            column(PicturePadLeft; PicturePadLeft)
            {
            }
            column(PicturePadTop; PicturePadTop)
            {
            }

            trigger OnAfterGetRecord()
            begin
                // Briefpapier
                if not UseStationeryG then
                    CompanyInformation.CalcFields(Picture);
            end;
        }
        dataitem(Header; "Sales Header")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.";
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);
                column(DocumentTitle; DocumentTitle)
                {
                }
                column(DocumentNo; Header."No.")
                {
                }
                column(CityDate; CityDate)
                {
                }
                column(OutputNo; OutputNo)
                {
                }
                column(PageLbl; PageLbl)
                {
                }
                column(FooterArray_1_1; FooterArray[1] [1])
                {
                }
                column(FooterArray_1_2; FooterArray[1] [2])
                {
                }
                column(FooterArray_1_3; FooterArray[1] [3])
                {
                }
                column(FooterArray_1_4; FooterArray[1] [4])
                {
                }
                column(FooterArray_2_1; FooterArray[2] [1])
                {
                }
                column(FooterArray_2_2; FooterArray[2] [2])
                {
                }
                column(FooterArray_2_3; FooterArray[2] [3])
                {
                }
                column(FooterArray_2_4; FooterArray[2] [4])
                {
                }
                column(FooterArray_3_1; FooterArray[3] [1])
                {
                }
                column(FooterArray_3_2; FooterArray[3] [2])
                {
                }
                column(FooterArray_3_3; FooterArray[3] [3])
                {
                }
                column(FooterArray_3_4; FooterArray[3] [4])
                {
                }
                column(FooterArray_4_1; FooterArray[4] [1])
                {
                }
                column(FooterArray_4_2; FooterArray[4] [2])
                {
                }
                column(FooterArray_4_3; FooterArray[4] [3])
                {
                }
                column(FooterArray_4_4; FooterArray[4] [4])
                {
                }
                column(ReturnText; ReturnText)
                {
                }
                column(JurisdictionText; StrSubstNo(JurisdictionText, CompanyInformation."JWC Place of Jurisdiction"))
                {
                }
                column(JuraManualMailItemText; AdditionalMailText)
                {
                }
                column(JuraHasAdditionalMailText; HasAddMailText)
                {
                }
                column(ShipAgentName; ShipAgentName)
                {
                }
                column(ShipAgentServName; ShipAgentServName)
                {
                }
                column(PackageTrackingNo; Header."Package Tracking No.")
                {
                }
                dataitem(HeaderInfoD; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(HeaderInfo; 1)
                    {
                    }
                    column(ReturnAddress; ReturnAddress)
                    {
                    }
                    column(PostAddr_1; ShipAddr[1])
                    {
                    }
                    column(PostAddr_2; ShipAddr[2])
                    {
                    }
                    column(PostAddr_3; ShipAddr[3])
                    {
                    }
                    column(PostAddr_4; ShipAddr[4])
                    {
                    }
                    column(PostAddr_5; ShipAddr[5])
                    {
                    }
                    column(PostAddr_6; ShipAddr[6])
                    {
                    }
                    column(PostAddr_7; ShipAddr[7])
                    {
                    }
                    column(PostAddr_8; ShipAddr[8])
                    {
                    }
                    column(CompAddr_1; CompAddr[1])
                    {
                    }
                    column(CompAddr_2; CompAddr[2])
                    {
                    }
                    column(CompAddr_3; CompAddr[3])
                    {
                    }
                    column(CompAddr_4; CompAddr[4])
                    {
                    }
                    column(CompAddr_5; CompAddr[5])
                    {
                    }
                    column(CompAddr_6; CompAddr[6])
                    {
                    }
                    column(CompAddr_7; CompAddr[7])
                    {
                    }
                    column(CompAddr_8; CompAddr[8])
                    {
                    }
                    column(CompInfo_1_1; CompInfo[1] [1])
                    {
                    }
                    column(CompInfo_1_2; CompInfo[1] [2])
                    {
                    }
                    column(CompInfo_1_3; CompInfo[1] [3])
                    {
                    }
                    column(CompInfo_1_4; CompInfo[1] [4])
                    {
                    }
                    column(CompInfo_1_5; CompInfo[1] [5])
                    {
                    }
                    column(CompInfo_1_6; CompInfo[1] [6])
                    {
                    }
                    column(CompInfo_1_7; CompInfo[1] [7])
                    {
                    }
                    column(CompInfo_1_8; CompInfo[1] [8])
                    {
                    }
                    column(CompInfo_2_1; CompInfo[2] [1])
                    {
                    }
                    column(CompInfo_2_2; CompInfo[2] [2])
                    {
                    }
                    column(CompInfo_2_3; CompInfo[2] [3])
                    {
                    }
                    column(CompInfo_2_4; CompInfo[2] [4])
                    {
                    }
                    column(CompInfo_2_5; CompInfo[2] [5])
                    {
                    }
                    column(CompInfo_2_6; CompInfo[2] [6])
                    {
                    }
                    column(CompInfo_2_7; CompInfo[2] [7])
                    {
                    }
                    column(CompInfo_2_8; CompInfo[2] [8])
                    {
                    }
                    column(SalespersPurchaserInfo_1_1; SalespersPurchaserInfo[1] [1])
                    {
                    }
                    column(SalespersPurchaserInfo_1_2; SalespersPurchaserInfo[1] [2])
                    {
                    }
                    column(SalespersPurchaserInfo_1_3; SalespersPurchaserInfo[1] [3])
                    {
                    }
                    column(SalespersPurchaserInfo_1_4; SalespersPurchaserInfo[1] [4])
                    {
                    }
                    column(SalespersPurchaserInfo_1_5; SalespersPurchaserInfo[1] [5])
                    {
                    }
                    column(SalespersPurchaserInfo_1_6; SalespersPurchaserInfo[1] [6])
                    {
                    }
                    column(SalespersPurchaserInfo_1_7; SalespersPurchaserInfo[1] [7])
                    {
                    }
                    column(SalespersPurchaserInfo_1_8; SalespersPurchaserInfo[1] [8])
                    {
                    }
                    column(SalespersPurchaserInfo_2_1; SalespersPurchaserInfo[2] [1])
                    {
                    }
                    column(SalespersPurchaserInfo_2_2; SalespersPurchaserInfo[2] [2])
                    {
                    }
                    column(SalespersPurchaserInfo_2_3; SalespersPurchaserInfo[2] [3])
                    {
                    }
                    column(SalespersPurchaserInfo_2_4; SalespersPurchaserInfo[2] [4])
                    {
                    }
                    column(SalespersPurchaserInfo_2_5; SalespersPurchaserInfo[2] [5])
                    {
                    }
                    column(SalespersPurchaserInfo_2_6; SalespersPurchaserInfo[2] [6])
                    {
                    }
                    column(SalespersPurchaserInfo_2_7; SalespersPurchaserInfo[2] [7])
                    {
                    }
                    column(SalespersPurchaserInfo_2_8; SalespersPurchaserInfo[2] [8])
                    {
                    }
                    column(DocInfo_1_1; DocInfo[1] [1])
                    {
                    }
                    column(DocInfo_1_2; DocInfo[1] [2])
                    {
                    }
                    column(DocInfo_1_3; DocInfo[1] [3])
                    {
                    }
                    column(DocInfo_1_4; DocInfo[1] [4])
                    {
                    }
                    column(DocInfo_1_5; DocInfo[1] [5])
                    {
                    }
                    column(DocInfo_1_6; DocInfo[1] [6])
                    {
                    }
                    column(DocInfo_1_7; DocInfo[1] [7])
                    {
                    }
                    column(DocInfo_1_8; DocInfo[1] [8])
                    {
                    }
                    column(DocInfo_2_1; DocInfo[2] [1])
                    {
                    }
                    column(DocInfo_2_2; DocInfo[2] [2])
                    {
                    }
                    column(DocInfo_2_3; DocInfo[2] [3])
                    {
                    }
                    column(DocInfo_2_4; DocInfo[2] [4])
                    {
                    }
                    column(DocInfo_2_5; DocInfo[2] [5])
                    {
                    }
                    column(DocInfo_2_6; DocInfo[2] [6])
                    {
                    }
                    column(DocInfo_2_7; DocInfo[2] [7])
                    {
                    }
                    column(DocInfo_2_8; DocInfo[2] [8])
                    {
                    }
                    trigger OnAfterGetRecord()
                    var
                        BilltoCountry: Text[50];
                    begin
                        // Adress Block
                        DocumentMgt.FormatReturnAddress(ReturnAddress, UseStationeryG);
                        DocumentMgt.JURAFormatCityDate(CityDate, Header."Document Date", UseStationeryG);
                        FormatAddress.SalesHeaderShipTo(ShipAddr, PostAddr, Header);

                        // Dynamische Kopftexte
                        DocumentMgt.JURAFormatCompInfo(CompInfo, UseStationeryG);
                        DocumentMgt.JURAFormatDocInfo(DocInfo, Header);
                        DocumentMgt.FormatSalespersPurchaserInfo(SalespersPurchaserInfo, Header);

                        // Firmendaten
                        if ResponsibilityCenter.Get(Header."Responsibility Center") then begin
                            FormatAddress.RespCenter(CompAddr, ResponsibilityCenter);
                            CompanyInformation."Phone No." := ResponsibilityCenter."Phone No.";
                            CompanyInformation."Fax No." := ResponsibilityCenter."Fax No.";
                        end else begin
                            CompanyInformation.Get();
                            DocumentMgt.JURAFormatCompanyAddr(CompAddr, CompanyInformation);
                        end;

                        // Lieferbedingungen
                        if ShipmentMethod.Get(Header."Shipment Method Code") then
                            ShipmentMethod.TranslateDescription(ShipmentMethod, Header."Language Code")
                        else
                            Clear(ShipmentMethod);

                        // Rechnungsadresse
                        if CountryRegion.Get(Header."Bill-to Country/Region Code") then
                            BilltoCountry := CountryRegion.Name;
                        FormatAddress.SalesHeaderBillTo(BillAddr, Header);

                        DocumentMgt.FormatBankingInfo(BankingInfoText);
                        DocumentMgt.FormatShippingAddress(BillingAddressText, BillAddr);
                    end;
                }
                dataitem(LabelsInt; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(Labels; 1)
                    {
                    }
                    column(LineNo_Line_Lbl; TempLine.FieldCaption("Line No."))
                    {
                    }
                    column(No_Line_Lbl; TempLine.FieldCaption("No."))
                    {
                    }
                    column(Description_Line_Lbl; TempLine.FieldCaption(Description))
                    {
                    }
                    column(Qty_Line_Lbl; QtyLbl)
                    {
                    }
                    column(UoM_Line_Lbl; UoMLbl)
                    {
                    }
                    column(ContinuedLbl; ContinuedLbl)
                    {
                    }
                    column(No_TrackingSpecBuf_Lbl; TempLine.FieldCaption("No."))
                    {
                    }
                    column(Quantity_TrackingSpecBuf_Lbl; QtyLbl)
                    {
                    }
                    column(PosLbl; PosLbl)
                    {
                    }
                    column(MCLbl; MCText)
                    {
                    }
                    column(LocationCodeLbl; LocationCodeLbl)
                    {
                    }
                    column(BinCodeLbl; BinCodeLbl)
                    {
                    }
                    column(ShelfNoLbl; ShelfNoLbl)
                    {
                    }
                    column(ShipmentDateLbl; ShipmentDateLbl)
                    {
                    }
                    column(QtyToShipLbl; QtyToShipLbl)
                    {
                    }
                    column(QtyPickedLbl; QtyPickedLbl)
                    {
                    }
                    column(QtyShippedLbl; QtyShippedLbl)
                    {
                    }
                }
                dataitem(PreText; "JWC Temp. Text Buffer")
                {
                    DataItemTableView = sorting("Line No.");
                    UseTemporary = true;
                    column(LineNo_PreText; PreText."Line No.")
                    {
                    }
                    column(Text_PreText; PreText.Text)
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        // Vortexte
                        PreText.Reset();
                        PreText.DeleteAll();

                        DocumentMgt.GetPreText(Header, PreText);
                    end;
                }
                dataitem(TempLine; "Sales Line")
                {
                    DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                    UseTemporary = true;
                    column(Type_Line; LineType)
                    {
                    }
                    column(LineNo_Line; TempLine."Line No.")
                    {
                    }
                    column(No_Line; TempLine."No.")
                    {
                    }
                    column(Description_Line; TempLine.Description)
                    {
                    }
                    column(LocationCode_Line; "Location Code")
                    {
                    }
                    column(BinCode_Line; "Bin Code")
                    {
                    }
                    column(ShelfNo_Line; "JWC Shelf No.")
                    {
                    }
                    column(ShipmentDate_Line; "Shipment Date")
                    {
                    }
                    column(Qty_Line; TempLine.Quantity)
                    {
                    }
                    column(UoM_Line; TempLine."Unit of Measure")
                    {
                    }
                    column(QtyToShip_Line; "Qty. to Ship")
                    {
                    }
                    column(QuantityShipped_Line; "Quantity Shipped")
                    {
                    }
                    dataitem(AddTextLine; "JWC Temp. Text Buffer")
                    {
                        DataItemTableView = sorting("Line No.");
                        UseTemporary = true;
                        column(LineNo_AddTextLine; AddTextLine."Line No.")
                        {
                        }
                        column(Text_AddTextLine; AddTextLine.Text)
                        {
                        }
                    }
                    dataitem(AsmLine; "Assembly Line")
                    {
                        DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                        UseTemporary = true;
                        column(LineNo_AsmLine; AsmLine."Line No.")
                        {
                        }
                        column(No_AsmLine; BlanksForIndent() + AsmLine."No.")
                        {
                        }
                        column(Description_AsmLine; BlanksForIndent() + AsmLine.Description)
                        {
                        }
                        column(Qty_AsmLine; AsmLine.Quantity)
                        {
                        }
                        column(QuantityPer_AsmLine; "Quantity per")
                        {
                        }
                        column(UoM_AsmLine; GetUOMText(AsmLine."Unit of Measure Code"))
                        {
                        }
                        column(LocationCode_AsmLine; "Location Code")
                        {
                        }
                        column(BinCode_AsmLine; "Bin Code")
                        {
                        }
                        column(QuantityToConsume_AsmLine; "Quantity to Consume")
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            ItemTranslation: Record "Item Translation";
                        begin
                            if ItemTranslation.Get(AsmLine."No.",
                                 AsmLine."Variant Code",
                                 Header."Language Code")
                            then
                                AsmLine.Description := ItemTranslation.Description;
                        end;

                        trigger OnPreDataItem()
                        begin
                            Clear(AsmLine);
                            if not DisplayAssemblyInfo then
                                CurrReport.Break();
                            if not AsmHeaderExists then
                                CurrReport.Break();

                            Clear(AsmLine);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        LineType := TempLine.Type.AsInteger();
                        if "No." = '' then
                            LineType := 0;

                        // Entfernen Sachkontonr.
                        if TempLine.Type = TempLine.Type::"G/L Account" then
                            Clear(TempLine."No.");

                        // Nr. + Beschreibung aus Referenzen, falls vorhanden
                        if Type = Type::Item then begin
                            ItemReference.Reset();
                            ItemReference.SetRange("Item No.", TempLine."No.");
                            ItemReference.SetRange("Variant Code", TempLine."Variant Code");
                            ItemReference.SetRange("Unit of Measure", TempLine."Unit of Measure Code");
                            ItemReference.SetRange("Reference Type", TempLine."Item Reference Type"::Customer);
                            ItemReference.SetRange("Reference Type No.", TempLine."Sell-to Customer No.");
                            if ItemReference.FindFirst() then
                                Found := true
                            else begin
                                ItemReference.SetRange("Reference Type No.", '');
                                Found := ItemReference.FindFirst();
                            end;

                            if Found then begin
                                TempLine."No." := CopyStr(ItemReference."Reference No.", 1, 20);
                                if ItemReference.Description <> '' then begin
                                    TempLine.Description := ItemReference.Description;
                                    TempLine."Description 2" := ItemReference."Description 2";
                                end;
                                Modify();
                            end;
                        end;
                        // Zusatztexte holen
                        CreateAddTextLines();
                    end;

                    trigger OnPreDataItem()
                    begin
                        // Textbausteinzeilen werden im Zusatztext bereitgestellt
                        TempLine.SetFilter("Attached to Line No.", '<>0');
                        TempLine.DeleteAll();
                        TempLine.Reset();

                        if not TempLine.FindSet() then
                            CurrReport.Break();
                    end;
                }
                dataitem(PostText; "JWC Temp. Text Buffer")
                {
                    DataItemTableView = sorting("Line No.");
                    UseTemporary = true;
                    column(LineNo_PostText; PostText."Line No.")
                    {
                    }
                    column(Text_PostText; PostText.Text)
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        // Belegzusatztexte
                        PostText.Reset();
                        PostText.DeleteAll();

                        DocumentMgt.GetPostText(Header, PostText);
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    DocumentTitleLbl: Label '%1 %2', Comment = '%1=Document Caption, %2=Document No.';
                begin
                    DocumentTitle := StrSubstNo(DocumentTitleLbl, DocCaption, Header."No.");
                    OutputNo += 1;
                    if Number > 1 then
                        DocumentTitle += FormatDocument.GetCOPYText();
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopiesG) + 1;
                    SetRange(Number, 1, NoOfLoops);

                    Clear(DocumentTitle);
                    Clear(OutputNo);
                end;
            }

            trigger OnAfterGetRecord()
            var
                SegManagement: Codeunit SegManagement;
            begin
                if ("Language Code" <> '') then
                    CurrReport.Language := LanguageG.GetLanguageId("Language Code");

                if LogInteraction then
                    if not CurrReport.Preview() then
                        SegManagement.LogDocument(
                          5, "No.", 0, 0, Database::Customer, "Sell-to Customer No.", "Salesperson Code",
                          "Campaign No.", "Posting Description", '');

                Clear(TempLine);
                TempLine.DeleteAll();
                GetLines();

                // 4x4 Array für Fußzeile
                Clear(FooterArray);
                if not UseStationeryG then
                    DocumentMgt.FormatFooter(FooterArray);

                if Header."Shipping Agent Code" <> '' then
                    ShippingAgent.Get(Header."Shipping Agent Code");
                ShipAgentName := ShippingAgent.Name;

                if Header."Shipping Agent Service Code" <> '' then
                    ShippingAgentServices.Get(Header."Shipping Agent Code", Header."Shipping Agent Service Code");
                ShipAgentServName := ShippingAgentServices.Description;
            end;

            trigger OnPostDataItem()
            begin
                CurrReport.Language := GlobalLanguage;
            end;

            trigger OnPreDataItem()
            begin
                NoOfRecords := Count();
                Print := Print or not CurrReport.Preview();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Optionen)
                {
                    Caption = 'Options';
                    field(NoOfCopies; NoOfCopiesG)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ShowAssemblyComponents; DisplayAssemblyInfo)
                    {
                        Caption = 'Show Assembly Components';
                        ToolTip = 'Specifies the value of the Show Assembly Components field.';
                        ApplicationArea = All;
                    }
                    field(UseStationery; UseStationeryG)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Stationary';
                        ToolTip = 'Specifies if header & footer should be printed or the document is printed on a stationary paper.';
                    }
                }
            }
        }

        actions
        {
        }

    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ItemReference: Record "Item Reference";
        ResponsibilityCenter: Record "Responsibility Center";
        ShipmentMethod: Record "Shipment Method";
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentServices: Record "Shipping Agent Services";
        DocumentMgt: Codeunit "JWC Document Mgt.";
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        LanguageG: Codeunit Language;
        AsmHeaderExists: Boolean;
        DisplayAssemblyInfo: Boolean;
        Found: Boolean;
        LogInteraction: Boolean;

        Print: Boolean;
        UseStationeryG: Boolean;
        LineType: Integer;
        NoOfCopiesG: Integer;
        NoOfLoops: Integer;
        NoOfRecords: Integer;
        OutputNo: Integer;
        PicturePadLeft: Integer;
        PicturePadTop: Integer;
        ContinuedLbl: Label 'Continued';
        DocCaption: Label 'Picking List';
        JurisdictionText: Label 'Jurisdiction for both parties: %1.';
        PageLbl: Label 'Page';
        PosLbl: Label 'Pos.';
        QtyLbl: Label 'Qty. ';
        ReturnText: Label 'Complaints can only be considered within 8 days after receipt of the goods.';
        LocationCodeLbl: Label 'Location Code';
        BinCodeLbl: Label 'Bin Code';
        ShipmentDateLbl: Label 'Shipment Date';
        ShelfNoLbl: Label 'Shelf No.';
        QtyToShipLbl: Label 'Qty. to Ship';
        UoMLbl: Label '';
        QtyPickedLbl: Label 'Qty. Picked';
        QtyShippedLbl: Label 'Qty. Shipped';
        AdditionalMailText: Text;
        BankingInfoText: Text;
        BillingAddressText: Text;
        CityDate: Text;
        CompInfo: array[2, 8] of Text;
        DocInfo: array[2, 8] of Text;
        DocumentTitle: Text;
        FooterArray: array[4, 4] of Text;
        HasAddMailText: Text;
        MCText: Text;
        ReturnAddress: Text;
        SalespersPurchaserInfo: array[2, 8] of Text;
        BillAddr: array[8] of Text[50];
        CompAddr: array[8] of Text[50];
        PostAddr: array[8] of Text[50];
        ShipAddr: array[8] of Text[50];
        ShipAgentName: Text[50];
        ShipAgentServName: Text[100];

    procedure InitializeRequest(NewNoOfCopies: Integer; NewLogInteraction: Boolean; NewPrint: Boolean; NewShowCorrectionLines: Boolean; NewShowLotSN: Boolean; NewDisplayAssemblyInfo: Boolean; NewUseStationery: Boolean)
    begin
        // Für Automatisierungen
        NoOfCopiesG := NewNoOfCopies;
        LogInteraction := NewLogInteraction;
        Print := NewPrint;
        DisplayAssemblyInfo := NewDisplayAssemblyInfo;
        UseStationeryG := NewUseStationery;
    end;

    local procedure GetLines()
    var
        Line: Record "Sales Line";
    begin
        Line.SetRange("Document Type", Header."Document Type");
        Line.SetRange("Document No.", Header."No.");
        if Line.FindSet() then
            repeat
                TempLine.Init();
                TempLine.Copy(Line);
                TempLine.Insert();
            until Line.Next() = 0;
    end;

    procedure TreatAsmLineBuffer(AssemblyLine: Record "Assembly Line")
    begin
        Clear(AsmLine);
        AsmLine.SetRange(Type, AssemblyLine.Type);
        AsmLine.SetRange("No.", AssemblyLine."No.");
        AsmLine.SetRange("Variant Code", AssemblyLine."Variant Code");
        AsmLine.SetRange(Description, AssemblyLine.Description);
        AsmLine.SetRange("Unit of Measure Code", AssemblyLine."Unit of Measure Code");
        if AsmLine.FindFirst() then begin
            AsmLine.Quantity += AssemblyLine.Quantity;
            AsmLine.Modify();
        end else begin
            Clear(AsmLine);
            AsmLine := AssemblyLine;
            AsmLine.Insert();
        end;
    end;

    procedure BlanksForIndent(): Text[10]
    begin
        exit(PadStr('', 2, ' '));
    end;

    procedure GetUOMText(UOMCode: Code[10]): Text[50]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit(UOMCode);
        exit(UnitOfMeasure.Description);
    end;

    local procedure CreateAddTextLines()
    var
        Line: Record "Sales Shipment Line";
    begin
        AddTextLine.Reset();
        AddTextLine.DeleteAll();

        // Beschreibung 2
        if TempLine."Description 2" <> '' then
            DocumentMgt.InsertTempTextLine(AddTextLine, TempLine."Description 2");

        // Textbausteine
        Line.SetRange("Document No.", TempLine."Document No.");
        Line.SetRange("Attached to Line No.", TempLine."Line No.");
        if Line.FindSet() then
            repeat
                DocumentMgt.InsertTempTextLine(AddTextLine, Line.Description);
                if Line."Description 2" <> '' then
                    DocumentMgt.InsertTempTextLine(AddTextLine, Line."Description 2");
            until Line.Next() = 0;
        OnAfterCreateAddTextLines(Header, TempLine, AddTextLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAddTextLines(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var AddTextLine: Record "JWC Temp. Text Buffer")
    begin
    end;
}

