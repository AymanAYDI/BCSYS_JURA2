namespace BCSYS.Jura;

using System.Utilities;
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
using Microsoft.CRM.Contact;
using Microsoft.CRM.Interaction;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Reporting;
using Microsoft.Sales.History;
using Microsoft.Assembly.History;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Bank.Setup;
using Microsoft.Sales.Reminder;
using Microsoft.Inventory.Ledger;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Sales.Receivables;
report 50008 "BC6 JWC Sales Invoice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/rdl/SalesInvoice.rdl';

    Caption = 'Sales Invoice';
    EnableHyperlinks = true;
    PreviewMode = PrintLayout;
    ApplicationArea = All;

    dataset
    {
        dataitem(Static; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(Picture_CompanyInfo; CompanyInfo.Picture)
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
                    CompanyInfo.CalcFields(Picture);
            end;
        }
        dataitem(Header; "Sales Invoice Header")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.";
            column(TotalAmountInclVAT; Header."Amount Including VAT")
            {
            }
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
                column(TotalLineAmount; TotalLineAmount)
                {
                    AutoFormatExpression = Header."Currency Code";
                    AutoFormatType = 1;
                }
                column(PageLbl; PageLbl)
                {
                }
                column(ContinuedLbl; ContinuedLbl)
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
                column(ShowVATSpec; ShowVATSpec)
                {
                }
                column(ReturnText; ReturnText)
                {
                }
                column(JurisdictionText; StrSubstNo(JurisdictionText, CompanyInfo."JWC Place of Jurisdiction"))
                {
                }
                column(JuraManualMailItemText; AdditionalMailText)
                {
                }
                column(JuraHasAddMailText; HasAddMailText)
                {
                }
                dataitem(HeaderInfo; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(HeaderInfoNo; 1)
                    {
                    }
                    column(ReturnAddress; ReturnAddress)
                    {
                    }
                    column(PostAddr_1; PostAddr[1])
                    {
                    }
                    column(PostAddr_2; PostAddr[2])
                    {
                    }
                    column(PostAddr_3; PostAddr[3])
                    {
                    }
                    column(PostAddr_4; PostAddr[4])
                    {
                    }
                    column(PostAddr_5; PostAddr[5])
                    {
                    }
                    column(PostAddr_6; PostAddr[6])
                    {
                    }
                    column(PostAddr_7; PostAddr[7])
                    {
                    }
                    column(PostAddr_8; PostAddr[8])
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
                    column(ShipAddr_1; ShipAddr[1])
                    {
                    }
                    column(ShipAddr_2; ShipAddr[2])
                    {
                    }
                    column(ShipAddr_3; ShipAddr[3])
                    {
                    }
                    column(ShipAddr_4; ShipAddr[4])
                    {
                    }
                    column(ShipAddr_5; ShipAddr[5])
                    {
                    }
                    column(ShipAddr_6; ShipAddr[6])
                    {
                    }
                    column(ShipAddr_7; ShipAddr[7])
                    {
                    }
                    column(ShipAddr_8; ShipAddr[8])
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
                    column(ShippingAddrLbl; ShippingAddrLbl)
                    {
                    }
                    column(BankingInfoLbl; BankingInfoLbl)
                    {
                    }
                    column(PmtTermsText; PaymentTermsCaption)
                    {
                    }
                    column(Description_PmtTerms; PmtTerms.Description)
                    {
                    }
                    column(BankingInfoText; BankingInfoText)
                    {
                    }
                    column(ShippingAddressText; ShippingAddressText)
                    {
                    }
                    trigger OnAfterGetRecord()
                    var
                        SelltoCountry: Text[50];
                    begin
                        // Adress Block
                        DocMgt.FormatReturnAddress(ReturnAddress, UseStationeryG);
                        DocMgt.JURAFormatCityDate(CityDate, Header."Document Date", UseStationeryG);
                        FormatAddr.SalesInvBillTo(PostAddr, Header);

                        // Dynamische Kopftexte
                        DocMgt.JURAFormatCompInfo(CompInfo, UseStationeryG);
                        DocMgt.JURAFormatDocInfo(DocInfo, Header);
                        DocMgt.FormatSalespersPurchaserInfo(SalespersPurchaserInfo, Header);

                        // Firmendaten
                        if RespCenter.Get(Header."Responsibility Center") then begin
                            FormatAddr.RespCenter(CompAddr, RespCenter);
                            CompanyInfo."Phone No." := RespCenter."Phone No.";
                            CompanyInfo."Fax No." := RespCenter."Fax No.";
                        end else begin
                            CompanyInfo.Get();
                            DocMgt.JURAFormatCompanyAddr(CompAddr, CompanyInfo);
                        end;

                        // Währung
                        if Header."Currency Code" <> '' then
                            CurrencyCode := Header."Currency Code"
                        else
                            CurrencyCode := GLSetup."LCY Code";

                        // Zahlungsbedingungen
                        PaymentTermsCaption := PmtTermsLbl;
                        if PmtTerms.Get(Header."Payment Terms Code") then
                            PmtTerms.TranslateDescription(PmtTerms, Header."Language Code")
                        else
                            Clear(PmtTerms);

                        // Lieferbedingungen
                        if ShptMethod.Get(Header."Shipment Method Code") then
                            ShptMethod.TranslateDescription(ShptMethod, Header."Language Code")
                        else
                            Clear(ShptMethod);

                        // Lieferadresse
                        if Country.Get(Header."Sell-to Country/Region Code") then
                            SelltoCountry := Country.Name;
                        ShowShippingAddr := FormatAddr.SalesInvShipTo(ShipAddr, PostAddr, Header);

                        DocMgt.FormatBankingInfo(BankingInfoText);
                        DocMgt.FormatShippingAddress(ShippingAddressText, ShipAddr);
                    end;
                }
                dataitem(Labels; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(LabelsNo; 1)
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
                    column(AmountWithoutVAT_Line_Lbl; AmountWithoutVATLbl)
                    {
                    }
                    column(UnitPrice_Line_Lbl; UnitPriceLbl)
                    {
                    }
                    column(LineDiscountPct_Line_Lbl; GetLineDiscPctText())
                    {
                    }
                    column(LineAmount_Line_Lbl; StrSubstNo(AmountLbl, CurrencyCode))
                    {
                    }
                    column(VATID_Line_Lbl; VATIDLbl)
                    {
                    }
                    column(VATIdentifier_VATAmountLine_Lbl; VATIDLbl)
                    {
                    }
                    column(VATPct_VATAmountLine_Lbl; VATPct)
                    {
                    }
                    column(LineAmount_VATAmountLine_Lbl; TempVATAmountLine.FieldCaption("Line Amount"))
                    {
                    }
                    column(InvDiscBaseAmount_VATAmountLine_Lbl; VATInvDiscBaseLbl)
                    {
                    }
                    column(InvoiceDiscountAmount_VATAmountLine_Lbl; VATInvDiscAmtLbl)
                    {
                    }
                    column(VATBase_VATAmountLine_Lbl; VATBaseLbl)
                    {
                    }
                    column(VATAmount_VATAmountLine_Lbl; TempVATAmountLine.FieldCaption("VAT Amount"))
                    {
                    }
                    column(VATIdentifier_VATAmountLineLCY_Lbl; VATIDLbl)
                    {
                    }
                    column(VATPct_VATAmountLineLCY_Lbl; VATPct)
                    {
                    }
                    column(VATBase_VATAmountLineLCY_Lbl; VATBaseLbl)
                    {
                    }
                    column(VATAmount_VATAmountLineLCY_Lbl; TempVATAmountLine.FieldCaption("VAT Amount"))
                    {
                    }
                    column(VATIdentifier_VATClauseLine_Lbl; VATIDLbl)
                    {
                    }
                    column(VATClause_VATClauseLine_Lbl; VATClauseLbl)
                    {
                    }
                    column(VATAmount_VATClauseLine_Lbl; TempVATAmountLine.FieldCaption("VAT Amount"))
                    {
                    }
                    column(PosLbl; PosLbl)
                    {
                    }
                    column(MCLbl; MCText)
                    {
                    }
                    column(VATPc_Line_Lbl; VATPc_Line_Lbl)
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

                        DocMgt.GetPreText(Header, PreText);
                    end;
                }
                dataitem(TempLine; "Sales Invoice Line")
                {
                    DataItemTableView = sorting("Document No.", "Line No.");
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
                    column(Qty_Line; TempLine.Quantity)
                    {
                    }
                    column(AmountWithVAT_Line; TempLine."Amount Including VAT")
                    {
                    }
                    column(UnitPrice_Line; TempLine."Unit Price")
                    {
                    }
                    column(LineDiscountPct_Line; TempLine."Line Discount %")
                    {
                    }
                    column(LineAmount_Line; TempLine."Line Amount")
                    {
                        AutoFormatExpression = TempLine.GetCurrencyCode();
                        AutoFormatType = 1;
                    }
                    column(VATID_Line; TempLine."VAT Identifier")
                    {
                    }
                    column(VATPc_Line; TempLine."VAT %")
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
                    dataitem(AsmLine; "Posted Assembly Line")
                    {
                        DataItemTableView = sorting("Document No.", "Line No.");
                        UseTemporary = true;
                        column(LineNo_AsmLine; AsmLine."Line No.")
                        {
                        }
                        column(No_AsmLine; BlanksForIndent() + AsmLine."No.")
                        {
                        }
                        column(Type_AsmLine; AsmLine.Type)
                        {
                        }
                        column(Description_AsmLine; BlanksForIndent() + AsmLine.Description)
                        {
                        }
                        column(Qty_AsmLine; AsmLine.Quantity)
                        {
                        }
                        column(UoM_AsmLine; GetUOMText(AsmLine."Unit of Measure Code"))
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
                            CollectAsmInformation();
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

                        TempVATAmountLine.Init();
                        TempVATAmountLine."VAT Identifier" := "VAT Identifier";
                        TempVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                        TempVATAmountLine."Tax Group Code" := "Tax Group Code";
                        TempVATAmountLine."VAT %" := "VAT %";
                        TempVATAmountLine."VAT Base" := Amount;
                        TempVATAmountLine."Amount Including VAT" := "Amount Including VAT";
                        TempVATAmountLine."Line Amount" := "Line Amount";
                        if "Allow Invoice Disc." then
                            TempVATAmountLine."Inv. Disc. Base Amount" := "Line Amount";
                        TempVATAmountLine."Invoice Discount Amount" := "Inv. Discount Amount";
                        TempVATAmountLine."VAT Clause Code" := "VAT Clause Code";
                        TempVATAmountLine.InsertLine();

                        // Nr. + Beschreibung aus Referenzen, falls vorhanden
                        if TempLine.Type = TempLine.Type::Item then begin
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
                                TempLine.Modify();
                            end;
                        end;

                        PrevLineAmount := "Line Amount";

                        TotalSubTotal += "Line Amount";
                        TotalInvDiscAmount -= "Inv. Discount Amount";
                        TotalAmount += Amount;
                        TotalAmountVAT += "Amount Including VAT" - Amount;
                        TotalAmountInclVAT += "Amount Including VAT";
                        TotalPaymentDiscOnVAT += -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT");

                        // Zusatztexte holen
                        CreateAddTextLines();
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempVATAmountLine.DeleteAll();

                        // Aufbau Shipment Buffer
                        TempSalesShipmentBuffer.Reset();
                        TempSalesShipmentBuffer.DeleteAll();
                        FirstValueEntryNo := 0;

                        // Textbausteinzeilen werden im Zusatztext bereitgestellt
                        TempLine.SetFilter("Attached to Line No.", '<>0');
                        TempLine.DeleteAll();
                        TempLine.Reset();

                        if not TempLine.FindSet() then
                            CurrReport.Break();

                        Clear(TotalSubTotal);
                        Clear(TotalInvDiscAmount);
                        Clear(TotalAmount);
                        Clear(TotalAmountVAT);
                        Clear(TotalAmountInclVAT);
                        Clear(TotalPaymentDiscOnVAT);
                    end;
                }
                dataitem(TotalsBuffer; "Report Totals Buffer")
                {
                    DataItemTableView = sorting("Line No.");
                    UseTemporary = true;
                    column(LineNo_TotalsBuffer; TotalsBuffer."Line No.")
                    {
                    }
                    column(Description_TotalsBuffer; TotalsBuffer.Description)
                    {
                    }
                    column(AmountFormatted_TotalsBuffer; TotalsBuffer.Amount)
                    {
                    }
                    column(FontBold_TotalsBuffer; TotalsBuffer."Font Bold")
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        GetTotalsBuffer();
                    end;
                }
                dataitem(VATSpecification; Integer)
                {
                    DataItemTableView = sorting(Number);
                    column(Positive_VATAmountLine; TempVATAmountLine.Positive)
                    {
                    }
                    column(VATIdentifier_VATAmountLine; TempVATAmountLine."VAT Identifier")
                    {
                    }
                    column(VATPct_VATAmountLine; TempVATAmountLine."VAT %")
                    {
                    }
                    column(LineAmount_VATAmountLine; TempVATAmountLine."Line Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(InvDiscBaseAmount_VATAmountLine; TempVATAmountLine."Inv. Disc. Base Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                        DecimalPlaces = 0 : 0;
                    }
                    column(InvoiceDiscountAmount_VATAmountLine; TempVATAmountLine."Invoice Discount Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATBase_VATAmountLine; TempVATAmountLine."VAT Base")
                    {
                    }
                    column(VATAmount_VATAmountLine; TempVATAmountLine."VAT Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATTotalText; TotalLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                    end;

                    trigger OnPreDataItem()
                    begin
                        // MWSt.-Spezifikation
                        if (TempVATAmountLine.Count = 1) or (TotalAmountVAT = 0) then
                            CurrReport.Break();

                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem(VATSpecificationLCY; Integer)
                {
                    DataItemTableView = sorting(Number);
                    column(Positive_VATAmountLineLCY; TempVATAmountLine.Positive)
                    {
                    }
                    column(VALSpecLCYHeader; VALSpecLCYHeader)
                    {
                    }
                    column(VALExchRate; VALExchRate)
                    {
                    }
                    column(VATIdentifier_VATAmountLineLCY; TempVATAmountLine."VAT Identifier")
                    {
                    }
                    column(VATPct_VATAmountLineLCY; TempVATAmountLine."VAT %")
                    {
                    }
                    column(VATBase_VATAmountLineLCY; VALVATBaseLCY)
                    {
                    }
                    column(VATAmount_VATAmountLineLCY; VALVATAmountLCY)
                    {
                    }
                    column(VATLCYTotalText; TotalLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                        VALVATBaseLCY :=
                          TempVATAmountLine.GetBaseLCY(
                            Header."Posting Date", Header."Currency Code", Header."Currency Factor");
                        VALVATAmountLCY :=
                          TempVATAmountLine.GetAmountLCY(
                            Header."Posting Date", Header."Currency Code", Header."Currency Factor");
                    end;

                    trigger OnPreDataItem()
                    begin
                        // MWSt.-Spezifikation in MW
                        if (not GLSetup."Print VAT specification in LCY") or
                           (Header."Currency Code" = '') or
                           (TempVATAmountLine.GetTotalVATAmount() = 0) then
                            CurrReport.Break();

                        if GLSetup."LCY Code" = '' then
                            VALSpecLCYHeader := Text001 + Text002
                        else
                            VALSpecLCYHeader := Text001 + Format(GLSetup."LCY Code");

                        CurrExchRate.FindCurrency(Header."Posting Date", Header."Currency Code", 1);
                        VALExchRate := StrSubstNo(Text003, CurrExchRate."Relational Exch. Rate Amount", CurrExchRate."Exchange Rate Amount");

                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem(VATClauseSpec; "VAT Clause")
                {
                    DataItemTableView = sorting(Code);
                    UseTemporary = true;
                    column(VATIdentifiers_VATClauseSpec; VATIDText)
                    {
                    }
                    column(Description_VATClauseSpec; VATClauseSpec.Description)
                    {
                    }
                    column(Description2_VATClauseSpec; VATClauseSpec."Description 2")
                    {
                    }
                    column(ExtText_VATClauseSpec; VATClauseSpecExtText.ToText())
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        ExtendedTextHeader: Record "Extended Text Header";
                        TempExtendedTextLine: Record "Extended Text Line" temporary;
                        TransferExtendedText: Codeunit "Transfer Extended Text";
                    begin
                        Clear(VATIDText);
                        TempVATAmountLine.Reset();
                        TempVATAmountLine.SetRange("VAT Clause Code", VATClauseSpec.Code);
                        if TempVATAmountLine.FindSet() then
                            repeat
                                if VATIDText <> '' then
                                    VATIDText += ', ';
                                VATIDText += TempVATAmountLine."VAT Identifier";
                            until TempVATAmountLine.Next() = 0;

                        Clear(VATClauseSpecExtText);
                        ExtendedTextHeader.Reset();
                        ExtendedTextHeader.SetRange("Table Name", Enum::"Extended Text Table Name"::"VAT Clause");
                        ExtendedTextHeader.SetRange("No.", VATClauseSpec.Code);
                        if TransferExtendedText.ReadExtTextLines(ExtendedTextHeader, WorkDate(), Header."Language Code") then begin
                            TransferExtendedText.GetTempExtTextLine(TempExtendedTextLine);
                            if TempExtendedTextLine.FindSet() then
                                repeat
                                    DocMgt.AppendLine(VATClauseSpecExtText, TempExtendedTextLine.Text);
                                until TempExtendedTextLine.Next() = 0;
                        end;
                    end;
                }
                dataitem(PaymentReportingArgument; "Payment Reporting Argument")
                {
                    DataItemTableView = sorting(Key);
                    UseTemporary = true;
                    column(PaymentServiceLogo; Logo)
                    {
                    }
                    column(PaymentServiceURLText; "URL Caption")
                    {
                    }
                    column(PaymentServiceURL; GetTargetURL())
                    {
                    }

                    trigger OnPreDataItem()
                    var
                        PaymentServiceSetup: Record "Payment Service Setup";
                    begin
                        PaymentServiceSetup.CreateReportingArgs(PaymentReportingArgument, Header);
                        if IsEmpty then
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

                        // Zusätzliche Gebühr
                        if DisplayAdditionalFeeNoteG then begin
                            DocMgt.InsertTempTextLine(PostText, '');
                            if TempLineFeeNoteOnReportHist.FindSet() then
                                repeat
                                    DocMgt.InsertTempTextLine(PostText, TempLineFeeNoteOnReportHist.ReportText);
                                until TempLineFeeNoteOnReportHist.Next() = 0;
                        end;

                        DocMgt.GetPostText(Header, PostText);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    DocumentTitle := StrSubstNo('%1 %2', DocumentCaption(), Header."No.");
                    OutputNo += 1;
                    if Number > 1 then
                        DocumentTitle += FormatDocument.GetCOPYText();
                end;

                trigger OnPostDataItem()
                begin
                    if Print then
                        Codeunit.Run(Codeunit::"Sales Inv.-Printed", Header);
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopiesG) + 1 + Cust."Invoice Copies";
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

                if not Cust.Get("Bill-to Customer No.") then
                    Clear(Cust);

                if LogInteractionG then
                    if not CurrReport.Preview then
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              4, "No.", 0, 0, Database::Contact, "Bill-to Contact No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '')
                        else
                            SegManagement.LogDocument(
                              4, "No.", 0, 0, Database::Customer, "Bill-to Customer No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '');

                GetLineFeeNoteOnReportHist("No.");

                Clear(TempLine);
                TempLine.DeleteAll();
                TempVATAmountLine.Reset();
                TempVATAmountLine.DeleteAll();
                GetLines();
                TempLine.CalcVATAmountLines(Header, TempVATAmountLine);
                TotalLineAmount := GetTotalLineAmount();
                Clear(TotalAmountVAT);
                repeat
                    TotalAmountVAT += TempVATAmountLine."VAT Amount";
                until TempVATAmountLine.Next() = 0;

                GetVATClauseSpec();
                ShowVATSpec := (TempVATAmountLine.Count > 1) or (not VATClauseSpec.IsEmpty);

                if ShowVATSpec then
                    MCText := MCLbl
                else
                    MCText := '';

                // 4x4 Array für Fußzeile
                Clear(FooterArray);
                if not UseStationeryG then
                    DocMgt.FormatFooter(FooterArray);

                Header.CalcFields("Amount Including VAT");
            end;

            trigger OnPostDataItem()
            begin
                CurrReport.Language := GlobalLanguage;
            end;

            trigger OnPreDataItem()
            begin
                NoOfRecords := Count;
                Print := Print or not CurrReport.Preview;
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
                    }
                    field(LogInteraction; LogInteractionG)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                    }
                    field(ShowAssemblyComponents; DisplayAssemblyInfo)
                    {
                        Caption = 'Show Assembly Components';
                        ApplicationArea = All;
                    }
                    field(DisplayAdditionalFeeNote; DisplayAdditionalFeeNoteG)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Additional Fee Note';
                    }
                    field(UseStationery; UseStationeryG)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Stationary';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        var
            SegManagement: Codeunit SegManagement;
        begin
            LogInteractionG := (SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Inv.") <> '');

            LogInteractionEnable := LogInteractionG;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        GLSetup.Get();
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        Country: Record "Country/Region";
        CurrExchRate: Record "Currency Exchange Rate";
        Cust: Record Customer;
        GLSetup: Record "General Ledger Setup";
        ItemReference: Record "Item Reference";
        TempLineFeeNoteOnReportHist: Record "Line Fee Note on Report Hist." temporary;
        PmtTerms: Record "Payment Terms";
        RespCenter: Record "Responsibility Center";
        TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary;
        ShptMethod: Record "Shipment Method";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DocMgt: Codeunit "JWC Document Mgt.";
        FormatAddr: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        LanguageG: Codeunit Language;
        VATClauseSpecExtText: TextBuilder;
        DisplayAdditionalFeeNoteG: Boolean;
        DisplayAssemblyInfo: Boolean;
        Found: Boolean;
        LogInteractionG: Boolean;

        LogInteractionEnable: Boolean;
        Print: Boolean;
        ShowShippingAddr: Boolean;
        ShowVATSpec: Boolean;
        UseStationeryG: Boolean;
        CurrencyCode: Code[10];
        PrevLineAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalAmountVAT: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalLineAmount: Decimal;
        TotalPaymentDiscOnVAT: Decimal;
        TotalSubTotal: Decimal;
        VALVATAmountLCY: Decimal;
        VALVATBaseLCY: Decimal;
        FirstValueEntryNo: Integer;
        LineType: Integer;
        NextEntryNo: Integer;
        NoOfCopiesG: Integer;
        NoOfLoops: Integer;
        NoOfRecords: Integer;
        OutputNo: Integer;
        PicturePadLeft: Integer;
        PicturePadTop: Integer;
        AmountLbl: Label 'Amount in %1', Comment = 'FRA="Ligne en %1"';
        AmountWithoutVATLbl: Label 'Amount excl. VAT', Comment = 'FRA="Montant HT"';
        BankingInfoLbl: Label 'Banking Information', Comment = 'FRA="Informations Bancaires"';
        ContinuedLbl: Label 'Continued', Comment = 'FRA="Suite"';
        InvCaption: Label 'Invoice No.', Comment = 'FRA="Facture N°"';
        InvDiscountAmtLbl: Label 'Invoice Discount', Comment = 'FRA="% remise"';
        JurisdictionText: Label 'Jurisdiction for both parties: %1.', Comment = 'FRA="Juridiction pour les deux parties : %1."';
        LineDiscountLbl: Label '%', Comment = 'FRA="%"';
        MCLbl: Label 'MC';
        PageLbl: Label 'Page', Comment = 'FRA="Page"';
        PmtTermsLbl: Label 'Payment Terms', Comment = 'FRA="Conditions de Paiement"';
        PosLbl: Label 'Pos.';
        PrepmtInvCaption: Label 'Prepayment Invoice', Comment = 'FRA="Facture acompte"';
        QtyLbl: Label 'Qty. ', Comment = 'FRA="Qté"';
        ReturnText: Label 'Complaints can only be considered within 8 days after receipt of the goods.', Comment = 'FRA="Les réclamations ne peuvent être examinées que dans les 8 jours suivant la réception de la marchandise."';
        ShipmentCaptionLbl: Label 'Shipment', Comment = 'FRA="Expédition"';
        ShippingAddrLbl: Label 'Shipping Address', Comment = 'FRA="Adresse Livraison"';
        SubtotalLbl: Label 'Subtotal', Comment = 'FRA="Total EUR HT"';
        Text001: Label 'VAT Amount Specification in ';
        Text002: Label 'Local Currency', Comment = 'FRA="DS"';
        Text003: Label 'Exchange rate: %1/%2', Comment = 'FRA="Taux de change %1/%2"';
        TotalExclVATTextLbl: Label 'Total %1 Excl. VAT', Comment = 'FRA="Total %1 HT"';
        TotalInclVATTextLbl: Label 'Total %1 Incl. VAT', Comment = 'FRA="Total %1 TTC"';
        TotalLbl: Label 'Total';
        TotalTextLbl: Label 'Total %1';
        UnitPriceLbl: Label 'Unit Price excl. VAT', Comment = 'FRA="Prix unitaire"';
        VATBaseLbl: Label 'VAT Base', Comment = 'FRA="Base HT"';
        VATClauseLbl: Label 'VAT Clause', Comment = 'FRA="Clause TVA"';
        VATIDLbl: Label 'VAT Ident. ', Comment = 'FRA="Code TVA"';
        VATInvDiscAmtLbl: Label 'Inv. Disc. Amount', Comment = 'FRA="Montant remise facture"';
        VATInvDiscBaseLbl: Label 'Inv. Disc. Base Amount';
        VATPc_Line_Lbl: Label 'VAT %', Comment = 'FRA="% TVA"';
        VATPct: Label '%', Comment = 'FRA="%"';
        AdditionalMailText: Text;
        BankingInfoText: Text;
        CityDate: Text;
        CompInfo: array[2, 8] of Text;
        DocInfo: array[2, 8] of Text;
        DocumentTitle: Text;
        FooterArray: array[4, 4] of Text;
        HasAddMailText: Text;
        MCText: Text;
        PaymentTermsCaption: Text;
        ReturnAddress: Text;
        SalespersPurchaserInfo: array[2, 8] of Text;
        ShippingAddressText: Text;
        VATIDText: Text;
        CompAddr: array[8] of Text[50];
        PostAddr: array[8] of Text[50];
        ShipAddr: array[8] of Text[50];
        VALExchRate: Text[50];
        VALSpecLCYHeader: Text[80];

    procedure InitializeRequest(NewNoOfCopies: Integer; NewArchiveDocument: Boolean; NewLogInteraction: Boolean; NewPrint: Boolean; NewDisplayAssemblyInfo: Boolean; NewUseStationery: Boolean)
    begin
        // Für Automatisierungen
        NoOfCopiesG := NewNoOfCopies;
        LogInteractionG := NewLogInteraction;
        Print := NewPrint;
        DisplayAssemblyInfo := NewDisplayAssemblyInfo;
        UseStationeryG := NewUseStationery;
    end;

    local procedure GetLineDiscPctText(): Text
    begin
        TempLine.Reset();
        TempLine.SetFilter("Line Discount %", '<>0');
        if not TempLine.IsEmpty then begin
            TempLine.Reset();
            exit(LineDiscountLbl);
        end;
        TempLine.Reset();
    end;

    local procedure GetLines()
    var
        Line: Record "Sales Invoice Line";
    begin
        Line.SetRange("Document No.", Header."No.");
        if Line.FindSet() then
            repeat
                TempLine.Init();
                TempLine.Copy(Line);
                TempLine.Insert();
            until Line.Next() = 0;
    end;

    procedure CollectAsmInformation()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        PostedAsmHeader: Record "Posted Assembly Header";
        PostedAsmLine: Record "Posted Assembly Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ValueEntry: Record "Value Entry";
    begin
        AsmLine.DeleteAll();
        if TempLine.Type <> TempLine.Type::Item then
            exit;
        with ValueEntry do begin
            SetCurrentKey("Document No.");
            SetRange("Document No.", TempLine."Document No.");
            SetRange("Document Type", "Document Type"::"Sales Invoice");
            SetRange("Document Line No.", TempLine."Line No.");
            SetRange(Adjustment, false);
            if not FindSet() then
                exit;
        end;
        repeat
            if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then begin
                    SalesShipmentLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
                    if SalesShipmentLine.AsmToShipmentExists(PostedAsmHeader) then begin
                        PostedAsmLine.SetRange("Document No.", PostedAsmHeader."No.");
                        if PostedAsmLine.FindSet() then
                            repeat
                                TreatAsmLineBuffer(PostedAsmLine);
                            until PostedAsmLine.Next() = 0;
                    end;
                end;
        until ValueEntry.Next() = 0;
    end;

    procedure TreatAsmLineBuffer(PostedAsmLine: Record "Posted Assembly Line")
    begin
        Clear(AsmLine);
        AsmLine.SetRange(Type, PostedAsmLine.Type);
        AsmLine.SetRange("No.", PostedAsmLine."No.");
        AsmLine.SetRange("Variant Code", PostedAsmLine."Variant Code");
        AsmLine.SetRange(Description, PostedAsmLine.Description);
        AsmLine.SetRange("Unit of Measure Code", PostedAsmLine."Unit of Measure Code");
        if AsmLine.FindFirst() then begin
            AsmLine.Quantity += PostedAsmLine.Quantity;
            AsmLine.Modify();
        end else begin
            Clear(AsmLine);
            AsmLine := PostedAsmLine;
            AsmLine.Insert();
        end;
    end;

    procedure BlanksForIndent(): Text[10]
    begin
        exit(PadStr('', 2, ' '));
    end;

    procedure GetUOMText(UOMCode: Code[10]): Text[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit(UOMCode);
        exit(CopyStr(UnitOfMeasure.Description, 1, 10));
    end;

    local procedure GetTotalLineAmount() TotalLineAmount: Decimal
    begin
        TempLine.Reset();
        if TempLine.FindSet() then
            repeat
                TotalLineAmount += TempLine."Line Amount";
            until TempLine.Next() = 0;
    end;

    local procedure GetTotalsBuffer()
    begin
        TotalsBuffer.DeleteAll();
        if (TotalInvDiscAmount <> 0) or (TotalAmountVAT <> 0) then
            TotalsBuffer.Add(SubtotalLbl, TotalSubTotal, true, false, false);
        if TotalInvDiscAmount <> 0 then begin
            TotalsBuffer.Add(InvDiscountAmtLbl, TotalInvDiscAmount, false, false, false);
            if TotalAmountVAT <> 0 then
                TotalsBuffer.Add(StrSubstNo(TotalExclVATTextLbl, CurrencyCode), TotalAmount, true, false, false);
        end;
        if TotalAmountVAT <> 0 then begin
            TotalsBuffer.Add(TempVATAmountLine.VATAmountText(), TotalAmountVAT, false, false, false);
            if TotalAmountInclVAT <> 0 then
                TotalsBuffer.Add(StrSubstNo(TotalInclVATTextLbl, CurrencyCode), TotalAmountInclVAT, true, false, false);
        end else
            TotalsBuffer.Add(StrSubstNo(TotalTextLbl, CurrencyCode), TotalAmount, true, false, false);
        DocMgt.FormatTotalAmount(TotalsBuffer, CurrencyCode);
    end;

    local procedure GetVATClauseSpec()
    var
        VATClause: Record "VAT Clause";
    begin
        VATClauseSpec.Reset();
        VATClauseSpec.DeleteAll();
        TempLine.Reset();
        TempLine.SetFilter("VAT Clause Code", '<>%1', '');
        if TempLine.FindSet() then
            repeat
                if VATClause.Get(TempLine."VAT Clause Code") then begin
                    VATClause.TranslateDescription(Header."Language Code");
                    VATClauseSpec.Init();
                    VATClauseSpec.Copy(VATClause);
                    if VATClauseSpec.Insert() then;
                end;
            until TempLine.Next() = 0;
        TempLine.Reset();
    end;

    local procedure CreateAddTextLines()
    var
        Line: Record "Sales Invoice Line";
    begin
        AddTextLine.Reset();
        AddTextLine.DeleteAll();

        with TempLine do begin
            // Beschreibung 2
            if "Description 2" <> '' then
                DocMgt.InsertTempTextLine(AddTextLine, "Description 2");

            // Textbausteine
            Line.SetRange("Document No.", "Document No.");
            Line.SetRange("Attached to Line No.", "Line No.");
            if Line.FindSet() then
                repeat
                    DocMgt.InsertTempTextLine(AddTextLine, Line.Description);
                    if Line."Description 2" <> '' then
                        DocMgt.InsertTempTextLine(AddTextLine, Line."Description 2");
                until Line.Next() = 0;
        end;
        OnAfterCreateAddTextLines(Header, TempLine, AddTextLine);
    end;

    local procedure InsertPostedShipmentDate()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        if TempLine."Shipment No." <> '' then
            if SalesShipmentHeader.Get(TempLine."Shipment No.") then begin
                DocMgt.InsertTempTextLine(AddTextLine, StrSubstNo('%1: %2', ShipmentCaptionLbl, SalesShipmentHeader."Posting Date"));
                exit;
            end;

        if Header."Order No." = '' then begin
            DocMgt.InsertTempTextLine(AddTextLine, StrSubstNo('%1: %2', ShipmentCaptionLbl, TempLine."Posting Date"));
            exit;
        end;

        case TempLine.Type of
            TempLine.Type::Item:
                GenerateBufferFromValueEntry(TempLine);
            TempLine.Type::"G/L Account", TempLine.Type::Resource,
          TempLine.Type::"Charge (Item)", TempLine.Type::"Fixed Asset":
                GenerateBufferFromShipment(TempLine);
            TempLine.Type::" ":
                exit;
        end;

        TempSalesShipmentBuffer.Reset();
        TempSalesShipmentBuffer.SetRange("Document No.", TempLine."Document No.");
        TempSalesShipmentBuffer.SetRange("Line No.", TempLine."Line No.");
        if TempSalesShipmentBuffer.FindSet() then
            repeat
                DocMgt.InsertTempTextLine(AddTextLine, StrSubstNo('%1: %2 (%3 %4)', ShipmentCaptionLbl, TempSalesShipmentBuffer."Posting Date", TempSalesShipmentBuffer.Quantity, TempLine."Unit of Measure"));
            until TempSalesShipmentBuffer.Next() = 0
        else
            DocMgt.InsertTempTextLine(AddTextLine, StrSubstNo('%1: %2', ShipmentCaptionLbl, Header."Posting Date"));
    end;

    local procedure GenerateBufferFromValueEntry(SalesInvoiceLine2: Record "Sales Invoice Line")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        Quantity: Decimal;
        TotalQuantity: Decimal;
    begin
        TotalQuantity := SalesInvoiceLine2."Quantity (Base)";
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", SalesInvoiceLine2."Document No.");
        ValueEntry.SetRange("Posting Date", Header."Posting Date");
        ValueEntry.SetRange("Item Charge No.", '');
        ValueEntry.SetFilter("Entry No.", '%1..', FirstValueEntryNo);
        if ValueEntry.FindSet() then
            repeat
                if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then begin
                    if SalesInvoiceLine2."Qty. per Unit of Measure" <> 0 then
                        Quantity := ValueEntry."Invoiced Quantity" / SalesInvoiceLine2."Qty. per Unit of Measure"
                    else
                        Quantity := ValueEntry."Invoiced Quantity";
                    AddBufferEntry(
                      SalesInvoiceLine2,
                      -Quantity,
                      ItemLedgerEntry."Posting Date");
                    TotalQuantity := TotalQuantity + ValueEntry."Invoiced Quantity";
                end;
                FirstValueEntryNo := ValueEntry."Entry No." + 1;
            until (ValueEntry.Next() = 0) or (TotalQuantity = 0);
    end;

    local procedure GenerateBufferFromShipment(SalesInvoiceLine: Record "Sales Invoice Line")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine2: Record "Sales Invoice Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        Quantity: Decimal;
        TotalQuantity: Decimal;
    begin
        TotalQuantity := 0;
        SalesInvoiceHeader.SetCurrentKey("Order No.");
        SalesInvoiceHeader.SetFilter("No.", '..%1', Header."No.");
        SalesInvoiceHeader.SetRange("Order No.", Header."Order No.");
        if SalesInvoiceHeader.FindSet() then
            repeat
                SalesInvoiceLine2.SetRange("Document No.", SalesInvoiceHeader."No.");
                SalesInvoiceLine2.SetRange("Line No.", SalesInvoiceLine."Line No.");
                SalesInvoiceLine2.SetRange(Type, SalesInvoiceLine.Type);
                SalesInvoiceLine2.SetRange("No.", SalesInvoiceLine."No.");
                SalesInvoiceLine2.SetRange("Unit of Measure Code", SalesInvoiceLine."Unit of Measure Code");
                if SalesInvoiceLine2.FindSet() then
                    repeat
                        TotalQuantity := TotalQuantity + SalesInvoiceLine2.Quantity;
                    until SalesInvoiceLine2.Next() = 0;
            until SalesInvoiceHeader.Next() = 0;

        SalesShipmentLine.SetCurrentKey("Order No.", "Order Line No.");
        SalesShipmentLine.SetRange("Order No.", Header."Order No.");
        SalesShipmentLine.SetRange("Order Line No.", SalesInvoiceLine."Line No.");
        SalesShipmentLine.SetRange("Line No.", SalesInvoiceLine."Line No.");
        SalesShipmentLine.SetRange(Type, SalesInvoiceLine.Type);
        SalesShipmentLine.SetRange("No.", SalesInvoiceLine."No.");
        SalesShipmentLine.SetRange("Unit of Measure Code", SalesInvoiceLine."Unit of Measure Code");
        SalesShipmentLine.SetFilter(Quantity, '<>%1', 0);

        if SalesShipmentLine.FindSet() then
            repeat
                if Header."Get Shipment Used" then
                    CorrectShipment(SalesShipmentLine);
                if Abs(SalesShipmentLine.Quantity) <= Abs(TotalQuantity - SalesInvoiceLine.Quantity) then
                    TotalQuantity := TotalQuantity - SalesShipmentLine.Quantity
                else begin
                    if Abs(SalesShipmentLine.Quantity) > Abs(TotalQuantity) then
                        SalesShipmentLine.Quantity := TotalQuantity;
                    Quantity :=
                      SalesShipmentLine.Quantity - (TotalQuantity - SalesInvoiceLine.Quantity);

                    TotalQuantity := TotalQuantity - SalesShipmentLine.Quantity;
                    SalesInvoiceLine.Quantity := SalesInvoiceLine.Quantity - Quantity;

                    if SalesShipmentHeader.Get(SalesShipmentLine."Document No.") then
                        AddBufferEntry(
                          SalesInvoiceLine,
                          Quantity,
                          SalesShipmentHeader."Posting Date");
                end;
            until (SalesShipmentLine.Next() = 0) or (TotalQuantity = 0);
    end;

    local procedure CorrectShipment(var SalesShipmentLine: Record "Sales Shipment Line")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetCurrentKey("Shipment No.", "Shipment Line No.");
        SalesInvoiceLine.SetRange("Shipment No.", SalesShipmentLine."Document No.");
        SalesInvoiceLine.SetRange("Shipment Line No.", SalesShipmentLine."Line No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                SalesShipmentLine.Quantity := SalesShipmentLine.Quantity - SalesInvoiceLine.Quantity;
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure AddBufferEntry(SalesInvoiceLine: Record "Sales Invoice Line"; QtyOnShipment: Decimal; PostingDate: Date)
    begin
        TempSalesShipmentBuffer.SetRange("Document No.", SalesInvoiceLine."Document No.");
        TempSalesShipmentBuffer.SetRange("Line No.", SalesInvoiceLine."Line No.");
        TempSalesShipmentBuffer.SetRange("Posting Date", PostingDate);
        if TempSalesShipmentBuffer.FindFirst() then begin
            TempSalesShipmentBuffer.Quantity := TempSalesShipmentBuffer.Quantity + QtyOnShipment;
            TempSalesShipmentBuffer.Modify();
            exit;
        end;

        with TempSalesShipmentBuffer do begin
            "Document No." := SalesInvoiceLine."Document No.";
            "Line No." := SalesInvoiceLine."Line No.";
            "Entry No." := NextEntryNo;
            Type := SalesInvoiceLine.Type;
            "No." := SalesInvoiceLine."No.";
            Quantity := QtyOnShipment;
            "Posting Date" := PostingDate;
            Insert();
            NextEntryNo := NextEntryNo + 1
        end;
    end;

    local procedure DocumentCaption(): Text[250]
    begin
        if Header."Prepayment Invoice" then
            exit(PrepmtInvCaption);
        exit(InvCaption);
    end;

    local procedure GetLineFeeNoteOnReportHist(SalesInvoiceHeaderNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        LineFeeNoteOnReportHist: Record "Line Fee Note on Report Hist.";
    begin
        TempLineFeeNoteOnReportHist.DeleteAll();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not CustLedgerEntry.FindFirst() then
            exit;

        if not Customer.Get(CustLedgerEntry."Customer No.") then
            exit;

        LineFeeNoteOnReportHist.SetRange("Cust. Ledger Entry No", CustLedgerEntry."Entry No.");
        LineFeeNoteOnReportHist.SetRange("Language Code", Customer."Language Code");
        if LineFeeNoteOnReportHist.FindSet() then
            repeat
                TempLineFeeNoteOnReportHist.Init();
                TempLineFeeNoteOnReportHist.Copy(LineFeeNoteOnReportHist);
                TempLineFeeNoteOnReportHist.Insert();
            until LineFeeNoteOnReportHist.Next() = 0
        else begin
            LineFeeNoteOnReportHist.SetRange("Language Code", LanguageG.GetUserLanguageCode());
            if LineFeeNoteOnReportHist.FindSet() then
                repeat
                    TempLineFeeNoteOnReportHist.Init();
                    TempLineFeeNoteOnReportHist.Copy(LineFeeNoteOnReportHist);
                    TempLineFeeNoteOnReportHist.Insert();
                until LineFeeNoteOnReportHist.Next() = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAddTextLines(SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceLine: Record "Sales Invoice Line"; var AddTextLine: Record "JWC Temp. Text Buffer")
    begin
    end;
}

