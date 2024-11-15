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
using Microsoft.Sales.Posting;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Interaction;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Reporting;
report 50007 "BC6 Sales Pro-Forma Invoice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/rdl/SalesProFormaInvoice.rdl';

    Caption = 'Sales Pro-Forma Invoice';
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
        dataitem(Header; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.");
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
                column(HasAddMailText; HasAddMailText)
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
                        // -OP043198
                        DocMgt.JURAFormatCityDate(CityDate, Header."Document Date", UseStationeryG);
                        // +OP043198

                        // NAV Standard wäre Bill-to
                        // FormatAddr.SalesHeaderBillTo(CustAddr,Header);
                        FormatAddr.SalesHeaderSellTo(PostAddr, Header);

                        // Dynamische Kopftexte
                        // -OP043198
                        DocMgt.JURAFormatCompInfo(CompInfo, UseStationeryG);
                        DocMgt.JURAFormatDocInfo(DocInfo, Header);
                        // +OP043198
                        DocMgt.FormatSalespersPurchaserInfo(SalespersPurchaserInfo, Header);

                        // Firmendaten
                        if RespCenter.Get(Header."Responsibility Center") then begin
                            FormatAddr.RespCenter(CompAddr, RespCenter);
                            CompanyInfo."Phone No." := RespCenter."Phone No.";
                            CompanyInfo."Fax No." := RespCenter."Fax No.";
                        end else begin
                            CompanyInfo.Get();
                            // -OP047410
                            DocMgt.JURAFormatCompanyAddr(CompAddr, CompanyInfo);
                            // +OP047410
                        end;

                        // Währung
                        if Header."Currency Code" <> '' then
                            CurrencyCode := Header."Currency Code"
                        else
                            CurrencyCode := GLSetup."LCY Code";

                        // Zahlungsbedingungen
                        // -OP047410
                        PaymentTermsCaption := PmtTermsLbl;
                        // +OP047410
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
                        ShowShippingAddr := FormatAddr.SalesHeaderShipTo(ShipAddr, PostAddr, Header);

                        // -OP047410
                        DocMgt.FormatBankingInfo(BankingInfoText);
                        DocMgt.FormatShippingAddress(ShippingAddressText, ShipAddr);
                        // +OP047410
                    end;
                }
                dataitem(LabelsD; Integer)
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
                    column(AmountWithoutVAT_Line_Lbl; AmountWithoutVATLbl)
                    {
                    }
                    column(UoM_Line_Lbl; UoMLbl)
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
                    column(VATID_Line_Lbl; VATIDText)
                    {
                    }
                    column(LineNo_AsmLine_Lbl; AsmLine.FieldCaption("No."))
                    {
                    }
                    column(Type_AsmLine_Lbl; AsmLine.FieldCaption(Type))
                    {
                    }
                    column(Description_AsmLine_Lbl; AsmLine.FieldCaption(Description))
                    {
                    }
                    column(Qty_AsmLine_Lbl; AsmLine.FieldCaption(Quantity))
                    {
                    }
                    column(UoM_AsmLine_Lbl; UoMLbl)
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

                        DocMgt.InsertTempTextLine(PreText, DeclarationLbl);
                    end;
                }
                dataitem(TempLine; "Sales Line")
                {
                    DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                    UseTemporary = true;
                    column(LineNo_Line; TempLine."Line No.")
                    {
                    }
                    column(Type_Line; LineType)
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
                    column(UoM_Line; TempLine."Unit of Measure")
                    {
                    }
                    column(UnitPrice_Line; TempLine."Unit Price")
                    {
                        AutoFormatExpression = TempLine."Currency Code";
                        AutoFormatType = 2;
                    }
                    column(LineDiscountPct_Line; TempLine."Line Discount %")
                    {
                    }
                    column(LineAmount_Line; TempLine."Line Amount")
                    {
                        AutoFormatExpression = TempLine."Currency Code";
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
                    dataitem(AsmLine; "Assembly Line")
                    {
                        DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
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
                        column(UoM_AsmLine; GetUnitOfMeasureDescr(AsmLine."Unit of Measure Code"))
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not DisplayAssemblyInfo then
                                CurrReport.Break();
                            if not AsmInfoExistsForLine then
                                CurrReport.Break();
                            SetRange("Document Type", AsmHeader."Document Type");
                            SetRange("Document No.", AsmHeader."No.");
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

                        PrevLineAmount := "Line Amount";
                        TotalSubTotal += "Line Amount";
                        TotalInvDiscAmount -= "Inv. Discount Amount";
                        TotalAmount += Amount;
                        TotalAmountVAT += "Amount Including VAT" - Amount;
                        TotalAmountInclVAT += "Amount Including VAT";
                        TotalPaymentDiscOnVAT += -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT");

                        // Zusatztexte holen
                        CreateAddTextLines();

                        if DisplayAssemblyInfo then
                            AsmInfoExistsForLine := TempLine.AsmToOrderExists(AsmHeader);
                    end;

                    trigger OnPreDataItem()
                    begin
                        // Textbausteinzeilen werden im Zusatztext bereitgestellt
                        TempLine.SetFilter("Attached to Line No.", '<>0');
                        TempLine.DeleteAll();
                        TempLine.Reset();

                        if not TempLine.FindSet() then
                            CurrReport.Break();

                        // Nr. + Beschreibung aus Referenzen, falls vorhanden
                        with TempLine do
                            if Type = Type::Item then begin
                                ItemReference.Reset();
                                ItemReference.SetRange("Item No.", "No.");
                                ItemReference.SetRange("Variant Code", "Variant Code");
                                ItemReference.SetRange("Unit of Measure", "Unit of Measure Code");
                                ItemReference.SetRange("Reference Type", "Item Reference Type"::Customer);
                                ItemReference.SetRange("Reference Type No.", "Sell-to Customer No.");
                                if ItemReference.FindFirst() then
                                    Found := true
                                else begin
                                    ItemReference.SetRange("Reference Type No.", '');
                                    Found := ItemReference.FindFirst();
                                end;

                                if Found then begin
                                    "No." := CopyStr(ItemReference."Reference No.", 1, MaxStrLen("No."));
                                    if ItemReference.Description <> '' then begin
                                        Description := ItemReference.Description;
                                        "Description 2" := ItemReference."Description 2";
                                    end;
                                    Modify();
                                end;
                            end;

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
                        if (not ShowVATSpec) or (TotalAmountVAT = 0) then
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

                        CurrExchRate.FindCurrency(Header."Order Date", Header."Currency Code", 1);
                        VALExchRate := StrSubstNo(Text003, CurrExchRate."Relational Exch. Rate Amount", CurrExchRate."Exchange Rate Amount");

                        SetRange(Number, 1, TempVATAmountLine.Count);
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

                        DocMgt.GetPostText(Header, PostText);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    DocumentTitle := StrSubstNo('%1 %2', DocTitleLbl, Header."No.");
                    OutputNo += 1;
                    if Number > 1 then
                        DocumentTitle += FormatDocument.GetCOPYText();
                end;

                trigger OnPostDataItem()
                begin
                    if Print then
                        Codeunit.Run(Codeunit::"Sales-Printed", Header);
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
                SalesPost: Codeunit "Sales-Post";
                SegManagement: Codeunit SegManagement;
            begin
                if ("Language Code" <> '') then
                    CurrReport.Language := LanguageG.GetLanguageId("Language Code");

                if Print then
                    // -OP037561
                    // IF CurrReport.USEREQUESTPAGE AND ArchiveDocument OR
                    //   NOT CurrReport.USEREQUESTPAGE AND SalesSetup."Arch. Orders and Ret. Orders"
                    // THEN
                    //   ArchiveManagement.StoreSalesDocument(Header,LogInteraction);
                    // +OP037561

                    if LogInteractionG then begin
                        CalcFields("No. of Archived Versions");
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", Database::Contact, "Bill-to Contact No."
                              , "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", Database::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    end;

                Clear(TempLine);
                Clear(SalesPost);
                TempLine.DeleteAll();
                TempVATAmountLine.Reset();
                TempVATAmountLine.DeleteAll();
                SalesPost.GetSalesLines(Header, TempLine, 1);
                TempLine.CalcVATAmountLines(1, Header, TempLine, TempVATAmountLine);
                TempLine.UpdateVATOnLines(1, Header, TempLine, TempVATAmountLine);
                TotalLineAmount := GetTotalLineAmount();

                Clear(TotalAmountVAT);
                repeat
                    TotalAmountVAT += TempVATAmountLine."VAT Amount";
                until TempVATAmountLine.Next() = 0;

                ShowVATSpec := TempVATAmountLine.Count > 1;
                Mark(true);

                // -OP043198
                if ShowVATSpec then
                    MCText := MCLbl
                else
                    MCText := '';
                // +OP043198

                // 4x4 Array für Fußzeile
                Clear(FooterArray);
                if not UseStationeryG then
                    DocMgt.FormatFooter(FooterArray);
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
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ArchiveDocument; ArchiveDocumentG)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archive Document';
                        ToolTip = 'Specifies if the document is archived after you preview or print it.';

                        trigger OnValidate()
                        begin
                            if not ArchiveDocumentG then
                                LogInteractionG := false;
                        end;
                    }
                    field(LogInteraction; LogInteractionG)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies that interactions with the contact are logged.';

                        trigger OnValidate()
                        begin
                            if LogInteractionG then
                                ArchiveDocumentG := ArchiveDocumentEnable;
                        end;
                    }
                    field(ShowAssemblyComponents; DisplayAssemblyInfo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Assembly Components';
                        ToolTip = 'Specifies that interactions with the contact are logged.';
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

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        var
            SegManagement: Codeunit SegManagement;
        begin
            // -OP037561
            // CASE SalesSetup."Archiving Sales Quote" OF
            //   SalesSetup."Archiving Sales Quote"::"0":
            //     ArchiveDocument := FALSE;
            //   SalesSetup."Archiving Sales Quote"::"2":
            //   ArchiveDocument := TRUE;
            // END;
            // +OP037561
            LogInteractionG := (SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Draft Invoice") <> '');

            LogInteractionEnable := LogInteractionG;
        end;
    }

    trigger OnPreReport()
    begin
        GLSetup.Get();
        CompanyInfo.Get();
    end;

    var
        AsmHeader: Record "Assembly Header";
        CompanyInfo: Record "Company Information";
        Country: Record "Country/Region";
        CurrExchRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        ItemReference: Record "Item Reference";
        PmtTerms: Record "Payment Terms";
        RespCenter: Record "Responsibility Center";
        ShptMethod: Record "Shipment Method";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DocMgt: Codeunit "JWC Document Mgt.";
        FormatAddr: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        LanguageG: Codeunit Language;
        ArchiveDocumentG: Boolean;

        ArchiveDocumentEnable: Boolean;
        AsmInfoExistsForLine: Boolean;
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
        TotalNetWeight: Decimal;
        TotalPaymentDiscOnVAT: Decimal;
        TotalSubTotal: Decimal;
        VALVATAmountLCY: Decimal;
        VALVATBaseLCY: Decimal;
        LineType: Integer;
        NoOfCopiesG: Integer;
        NoOfLoops: Integer;
        NoOfRecords: Integer;
        OutputNo: Integer;
        PicturePadLeft: Integer;
        PicturePadTop: Integer;
        AmountLbl: Label 'Amount %1', Comment = 'FRA="Ligne en %1"';
        AmountWithoutVATLbl: Label 'Amount excl. VAT', Comment = 'FRA="Montant HT"';
        BankingInfoLbl: Label 'Banking Information', Comment = 'FRA="Informations Bancaires"';
        ContinuedLbl: Label 'Continued', Comment = 'FRA="Suite"';
        DeclarationLbl: Label 'For customs purposes only.';
        DocTitleLbl: Label 'Pro-Forma Invoice', Comment = 'FRA="Facture pro forma"';
        InvDiscountAmtLbl: Label 'Invoice Discount', Comment = 'FRA="% remise"';
        JurisdictionText: Label 'Jurisdiction for both parties: %1.', Comment = 'FRA="Juridiction pour les deux parties : %1."';
        LineDiscountLbl: Label '%', Comment = 'FRA="%"';
        MCLbl: Label 'MC';
        PageLbl: Label 'Page', Comment = 'FRA="Page"';
        PmtTermsLbl: Label 'Payment Terms', Comment = 'FRA="Conditions de paiement"';
        PosLbl: Label 'Pos.';
        QtyLbl: Label 'Qty. ', Comment = 'FRA="Qté"';
        ReturnText: Label 'Complaints can only be considered within 8 days after receipt of the goods.', Comment = 'FRA="Les réclamations ne peuvent être examinées que dans les 8 jours suivant la réception de la marchandise."';
        ShippingAddrLbl: Label 'Shipping Address', Comment = 'FRA="Adresse Livraison"';
        SubtotalLbl: Label 'Subtotal', Comment = 'FRA="TOTAL EUR HT"';
        Text001: Label 'VAT Amount Specification in ', Comment = 'FRA="Spécification Montant TVA en"';
        Text002: Label 'Local Currency', Comment = 'FRA="DS"';
        Text003: Label 'Exchange rate: %1/%2', Comment = 'FRA="Taux de change %1/%2"';
        TotalExclVATTextLbl: Label 'Total %1 Excl. VAT', Comment = 'FRA="Total % HT"';
        TotalInclVATTextLbl: Label 'Total %1 Incl. VAT', Comment = 'FRA="Total %1 TTC"';
        TotalLbl: Label 'Total', Comment = 'FRA="Total"';
        TotalTextLbl: Label 'Total %1', Comment = 'FRA="Total %1"';
        UnitPriceLbl: Label 'Unit Price excl. VAT', Comment = 'FRA="Prix unitaire HT"';
        UoMLbl: Label '';
        VATBaseLbl: Label 'VAT Base', Comment = 'FRA="Base HT"';
        VATIDLbl: Label 'VAT Ident. ', Comment = 'FRA="Code TVA"';
        VATInvDiscAmtLbl: Label 'Inv. Disc. Amount', Comment = 'FRA="Montant remise facture"';
        VATInvDiscBaseLbl: Label 'Inv. Disc. Base Amount', Comment = 'FRA="Montant base remise facture"';
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
        ArchiveDocumentG := NewArchiveDocument;
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

    local procedure GetTotalLineAmount() TotalLineAmount: Decimal
    begin
        TempLine.Reset();
        if TempLine.FindSet() then
            repeat
                TotalLineAmount += TempLine."Line Amount";
            until TempLine.Next() = 0;
    end;

    procedure GetUnitOfMeasureDescr(UOMCode: Code[10]): Text[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit(UOMCode);
        exit(CopyStr(UnitOfMeasure.Description, 1, 10));
    end;

    procedure BlanksForIndent(): Text[10]
    begin
        exit(PadStr('', 2, ' '));
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

    local procedure CreateAddTextLines()
    var
        Item: Record Item;
        Line: Record "Sales Line";
    begin
        AddTextLine.Reset();
        AddTextLine.DeleteAll();

        with TempLine do begin
            // Beschreibung 2
            if "Description 2" <> '' then
                DocMgt.InsertTempTextLine(AddTextLine, "Description 2");

            // Textbausteine
            Line.SetRange("Document Type", "Document Type");
            Line.SetRange("Document No.", "Document No.");
            Line.SetRange("Attached to Line No.", "Line No.");
            if Line.FindSet() then
                repeat
                    DocMgt.InsertTempTextLine(AddTextLine, Line.Description);
                    if Line."Description 2" <> '' then
                        DocMgt.InsertTempTextLine(AddTextLine, Line."Description 2");
                until Line.Next() = 0;

            if (Header."Ship-to Country/Region Code" <> '') then
                if (Type = Type::Item) and Item.Get("No.") then;
            // -OP043198
            //IF Item."Tariff No." <> '' THEN
            //DocMgt.InsertTempTextLine(AddTextLine,STRSUBSTNO('%1: %2',Item.FIELDCAPTION("Tariff No."),Item."Tariff No."));
            // +OP043198
            // -OP047410
            //IF Item."Country/Region of Origin Code" <> '' THEN
            //DocMgt.InsertTempTextLine(AddTextLine,STRSUBSTNO('%1: %2',Item.FIELDCAPTION("Country/Region of Origin Code"),Item."Country/Region of Origin Code"));
            // +OP047410

            if ("Net Weight" <> 0) and ("Qty. to Invoice" <> 0) then begin
                DocMgt.InsertTempTextLine(AddTextLine, StrSubstNo('%1: %2', FieldCaption("Net Weight"), Round("Qty. to Invoice" * "Net Weight")));
                TotalNetWeight += Round("Qty. to Invoice" * "Net Weight");
            end;
        end;
        OnAfterCreateAddTextLines(Header, TempLine, AddTextLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAddTextLines(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var AddTextLine: Record "JWC Temp. Text Buffer")
    begin
    end;
}

