namespace BCSYS.Jura;

using System.Utilities;
using Microsoft.Utilities;
using Microsoft.CRM.Segment;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Location;
using System.Globalization;
using Microsoft.Foundation.UOM;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Interaction;
using Microsoft.Finance.Currency;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Reporting;
using Microsoft.Sales.History;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Finance.VAT.Clause;
report 50009 "BC6 JWC Sales Credit Memo"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/rdl/SalesCreditMemo.rdl';

    Caption = 'Sales Credit Memo';
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
        dataitem(Header; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.";
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);
                column(DocumentTitle; DocumentTitle)
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
                    column(DocumentNo; Header."No.")
                    {
                    }
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
                        FormatAddr.SalesCrMemoBillTo(PostAddr, Header);

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

                        // Lieferadresse
                        if Country.Get(Header."Sell-to Country/Region Code") then
                            SelltoCountry := Country.Name;
                        ShowShippingAddr := FormatAddr.SalesCrMemoShipTo(ShipAddr, PostAddr, Header);

                        DocMgt.FormatBankingInfo(BankingInfoText);
                        DocMgt.FormatShippingAddress(ShippingAddressText, ShipAddr);
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
                    column(AmountWithoutVAT_Line_Lbl; AmountWithoutVATLbl)
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
                dataitem(TempLine; "Sales Cr.Memo Line")
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
                    column(UoM_Line; TempLine."Unit of Measure")
                    {
                    }
                    column(UnitPrice_Line; TempLine."Unit Price")
                    {
                        AutoFormatExpression = TempLine.GetCurrencyCode();
                        AutoFormatType = 2;
                    }
                    column(LineDiscountPct_Line; TempLine."Line Discount %")
                    {
                    }
                    column(LineAmount_Line; TempLine."Line Amount")
                    {
                        AutoFormatExpression = TempLine.GetCurrencyCode();
                        AutoFormatType = 2;
                    }
                    column(VATID_Line; TempLine."VAT Identifier")
                    {
                    }
                    column(AmountWithVAT_Line; TempLine."Amount Including VAT")
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

                        // MWSt.-Kennzeichen nur bei MwSt.-Spezifikation
                        // -OP047410
                        //IF NOT ShowVATSpec THEN
                        //CLEAR(TempLine."VAT Identifier");
                        // +OP047410

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

                        // Textbausteinzeilen werden im Zusatztext bereitgestellt
                        TempLine.SetFilter("Attached to Line No.", '<>0');
                        TempLine.DeleteAll();
                        TempLine.Reset();

                        if not TempLine.FindSet() then
                            CurrReport.Break();

                        // -OP047410
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
                        // +OP047410

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

                        CurrExchRate.FindCurrency(Header."Posting Date", Header."Currency Code", 1);
                        VALExchRate := StrSubstNo(Text003, CurrExchRate."Relational Exch. Rate Amount", CurrExchRate."Exchange Rate Amount");

                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;
                }
                dataitem(VATClauseSpec; "VAT Clause")
                {
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

                        // -OP047410
                        // // Lieferadresse
                        // IF ShowShippingAddr THEN BEGIN
                        //  DocMgt.InsertTempTextLine(PostText,'');
                        //  DocMgt.InsertTempTextLine(PostText,ShipToLbl);
                        //  DocMgt.InsertTempTextLine(PostText,'');
                        //  FOR i := 1 TO ARRAYLEN(ShipAddr) DO
                        //    IF ShipAddr[i] <> '' THEN
                        //      DocMgt.InsertTempTextLine(PostText,ShipAddr[i]);
                        // END;
                        // +OP047410

                        DocMgt.GetPostText(Header, PostText);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    DocumentTitle := StrSubstNo('%1 %2', GetDocumentCaption(), Header."No.");
                    OutputNo += 1;
                    if Number > 1 then
                        DocumentTitle += FormatDocument.GetCOPYText();
                end;

                trigger OnPostDataItem()
                begin
                    if Print then
                        Codeunit.Run(Codeunit::"Sales Cr. Memo-Printed", Header);
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

                if LogInteractionG then
                    if not CurrReport.Preview then
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              6, "No.", 0, 0, Database::Contact, "Bill-to Contact No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '')
                        else
                            SegManagement.LogDocument(
                              6, "No.", 0, 0, Database::Customer, "Bill-to Customer No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '');

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
            LogInteractionG := (SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Cr. Memo") <> '');

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
        GLSetup: Record "General Ledger Setup";
        ItemReference: Record "Item Reference";
        RespCenter: Record "Responsibility Center";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DocMgt: Codeunit "JWC Document Mgt.";
        FormatAddr: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        LanguageG: Codeunit Language;
        VATClauseSpecExtText: TextBuilder;
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
        LineType: Integer;
        NoOfCopiesG: Integer;
        NoOfLoops: Integer;
        NoOfRecords: Integer;
        OutputNo: Integer;
        PicturePadLeft: Integer;
        PicturePadTop: Integer;
        AmountLbl: Label 'Amount %1', Comment = 'FRA="Ligne en %1"';
        AmountWithoutVATLbl: Label 'Amount excl. VAT', Comment = 'FRA="Montant excl. TVA"';
        BankingInfoLbl: Label 'Banking Information', Comment = 'FRA="Informations Bancaires"';
        ContinuedLbl: Label 'Continued', Comment = 'FRA="Suite"';
        DocCreditMemoCap: Label 'Credit Memo', Comment = 'FRA="Avoir N°"';
        DocCreditMemoPrepmtCap: Label 'Prepayment Credit Memo', Comment = 'FRA="Devis de Prépaiement"';
        DocDECap: Label 'Corrective Invoice', Comment = 'FRA="Facture Corrective"';
        DocDEPrepmtCap: Label 'Prepayment Corrective Invoice', Comment = 'FRA="Facture Corrective de Prépaiement"';
        InvDiscountAmtLbl: Label 'Invoice Discount', Comment = 'FRA="% remise"';
        JurisdictionText: Label 'Jurisdiction for both parties: %1.', Comment = 'FRA="Juridiction pour les deux parties : %1."';
        LineDiscountLbl: Label '%', Comment = 'FRA="%"';
        MCLbl: Label 'MC';
        PageLbl: Label 'Page', Comment = 'FRA="Page"';
        PosLbl: Label 'Pos.';
        QtyLbl: Label 'Qty. ', Comment = 'FRA="Qté"';
        ReturnText: Label 'Complaints can only be considered within 8 days after receipt of the goods.', Comment = 'FRA=""';
        ShippingAddrLbl: Label 'Shipping Address', Comment = 'FRA=""';
        SubtotalLbl: Label 'Subtotal', Comment = 'FRA=""';
        Text001: Label 'VAT Amount Specification in ', Comment = 'FRA="Spécification Montant TVA en"';
        Text002: Label 'Local Currency', Comment = 'FRA="DS"';
        Text003: Label 'Exchange rate: %1/%2', Comment = 'FRA="Taux de change %1/%2"';
        TotalExclVATTextLbl: Label 'Total %1 Excl. VAT', Comment = 'FRA=""';
        TotalInclVATTextLbl: Label 'Total %1 Incl. VAT', Comment = 'FRA=""';
        TotalLbl: Label 'Total', Comment = 'FRA=""';
        TotalTextLbl: Label 'Total %1', Comment = 'FRA=""';
        UnitPriceLbl: Label 'Unit Price excl. VAT', Comment = 'FRA=""';
        UoMLbl: Label '';
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
        ReturnAddress: Text;
        SalespersPurchaserInfo: array[2, 8] of Text;
        ShippingAddressText: Text;
        VATIDText: Text;
        CompAddr: array[8] of Text[50];
        PostAddr: array[8] of Text[50];
        ShipAddr: array[8] of Text[50];
        VALExchRate: Text[50];
        VALSpecLCYHeader: Text[80];

    procedure InitializeRequest(NewNoOfCopies: Integer; NewArchiveDocument: Boolean; NewLogInteraction: Boolean; NewPrint: Boolean; NewUseStationery: Boolean)
    begin
        // Für Automatisierungen
        NoOfCopiesG := NewNoOfCopies;
        LogInteractionG := NewLogInteraction;
        Print := NewPrint;
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
        Line: Record "Sales Cr.Memo Line";
    begin
        Line.SetRange("Document No.", Header."No.");
        if Line.FindSet() then
            repeat
                TempLine.Init();
                TempLine.Copy(Line);
                TempLine.Insert();
            until Line.Next() = 0;
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
        Line: Record "Sales Cr.Memo Line";
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

    local procedure GetDocumentCaption(): Text
    var
        Caption: Text;
    begin
        if CompanyInfo."Country/Region Code" = 'DE' then begin
            if Header."Prepayment Credit Memo" then
                Caption := DocDEPrepmtCap
            else
                Caption := DocDECap;
        end else
            if Header."Prepayment Credit Memo" then
                Caption := DocCreditMemoPrepmtCap
            else
                Caption := DocCreditMemoCap;
        exit(Caption);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAddTextLines(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; var AddTextLine: Record "JWC Temp. Text Buffer")
    begin
    end;
}

