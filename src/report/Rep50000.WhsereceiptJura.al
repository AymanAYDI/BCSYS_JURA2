namespace BCSYS.Jura;

using Microsoft.Purchases.Document;
using System.Utilities;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.CRM.Team;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Address;
report 50000 "Whse. receipt (Jura)"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/rdl/WhsereceiptJura.rdl';
    ApplicationArea = All;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = sorting("Document Type", "No.")
                                where("Document Type" = const(Order));
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Purchase Order';
            column(PurchHeader_No; "No.")
            {
            }
            dataitem(PageLoop; Integer)
            {
                DataItemTableView = sorting(Number)
                                    where(Number = const(1));
                column(Picture; CompanyInfo.Picture)
                {
                }
                column(Company_Name; CompanyInfo.Name)
                {
                }
                column(Company_Address; CompanyInfo.Address)
                {
                }
                column(CompanyInfoPosteCodeInfocity; CompanyInfo.Address + ' ' + CompanyInfo."Post Code" + ' ' + CompanyInfo.City)
                {
                }
                column(CompanyInfoHomepage; CompanyInfo."Home Page")
                {
                }
                column(Adresse_destinataire; Adressedestinataire)
                {
                }
                column(ShipToAddr_1; ShipToAddr[1])
                {
                }
                column(ShipToAddr_2; ShipToAddr[2])
                {
                }
                column(ShipToAddr_3; ShipToAddr[3])
                {
                }
                column(ShipToAddr_4; ShipToAddr[4])
                {
                }
                column(ShipToAddr_5; ShipToAddr[5])
                {
                }
                column(ShipToAddr_6; ShipToAddr[6])
                {
                }
                column(ShipToAddr_7; ShipToAddr[7])
                {
                }
                column(ShipToAddr_8; ShipToAddr[8])
                {
                }
                column(BuyFromAddr_1; BuyFromAddr[1])
                {
                }
                column(BuyFromAddr_2; BuyFromAddr[2])
                {
                }
                column(BuyFromAddr_3; BuyFromAddr[3])
                {
                }
                column(BuyFromAddr_4; BuyFromAddr[4])
                {
                }
                column(BuyFromAddr_5; BuyFromAddr[5])
                {
                }
                column(BuyFromAddr_6; BuyFromAddr[6])
                {
                }
                column(BuyFromAddr_7; BuyFromAddr[7])
                {
                }
                column(BuyFromAddr_8; BuyFromAddr[8])
                {
                }
                column("No_téléphone"; "N°_téléphone")
                {
                }
                column(CompanyInfo_Phone_No; CompanyInfo."Phone No.")
                {
                }
                column("No_télécopie"; N_télécopie)
                {
                }
                column(CompanyInfo_Fax_No; CompanyInfo."Fax No.")
                {
                }
                column(PurchaserText; PurchaserText)
                {
                }
                column(SalesPurchPers_Name; SalesPurchPerson.Name)
                {
                }
                column(PurchaseHeader_YourReference; "Purchase Header"."Your Reference")
                {
                }
                column(Date_Commande; Date_commande)
                {
                }
                column(PurchaseHeader_DocumentDate; FORMAT("Purchase Header"."Document Date", 0, 4))
                {
                }
                column(No_Commande; "N°_commande")
                {
                }
                column(PurchaseHeader_No; "Purchase Header"."No.")
                {
                }
                column(Date_Commande_Order; Date_commande)
                {
                }
                column(PurchaseHeader_OrderDate; "Purchase Header"."Order Date")
                {
                }
                column(No_Fournisseur; "N°_fournisseur")
                {
                }
                column(PurchaseHeader_BuyFrom_VendorFrom; "Purchase Header"."Buy-from Vendor No.")
                {
                }
                column(Date_Rangement; Date_de_rangement)
                {
                }
                column(PurchaseHeader_ReceiptDate; "Purchase Header"."Expected Receipt Date")
                {
                }
                column(Condition_Livraison; Condition_livraison)
                {
                }
                column(ShipmentMethod_Descr; ShipmentMethod.Description)
                {
                }
                column(STRSUBSTNO; STRSUBSTNO(Text005, FORMAT(CurrReport.PAGENO())))
                {
                }
                column(Copy_Text; CopyText)
                {
                }
                column(Magasin_Reception; Magasin_Réception)
                {
                }
                column("Emballé"; "Emballé_de:")
                {
                }
                column(By; By)
                {
                }
                column(Signature; Signature)
                {
                }
                column(Au_Capital; au_capitalde)
                {
                }
                column(CompanyInfo_Stock; CompanyInfo."Stock Capital")
                {
                }
                column("tiré"; "-")
                {
                }
                column(No_TVA; "N°_TVA_VAT:")
                {
                }
                column(CompanyInfo_VAT_reg; CompanyInfo."VAT Registration No.")
                {
                }
                column(Text_CompanyInfo_RegNo; Text011 + ' ' + CompanyInfo."Registration No.")
                {
                }
                column("Siége_Social"; Siège_social)
                {
                }
                column(Service_Apres_Vente; "Service_après_vente :")
                {
                }
                dataitem("Purchase Line"; "Purchase Line")
                {
                    DataItemLink = "Document Type" = field("Document Type"),
                                   "Document No." = field("No.");
                    DataItemLinkReference = "Purchase Header";
                    DataItemTableView = sorting("Document Type", "Document No.", Type, "Shelf No.")
                                        order(ascending)
                                        where(Type = const(Item));
                    column(pos; Pos)
                    {
                    }
                    column(Article; Article)
                    {
                    }
                    column("Désignation"; Désignation)
                    {
                    }
                    column("Quantité"; Quantité)
                    {
                    }
                    column("Unité"; Unité)
                    {
                    }
                    column(No_Emplacement; "N°_emplacement")
                    {
                    }
                    column(Ship_Qut; "Ship._Qut.")
                    {
                    }
                    column(Ok; Ok)
                    {
                    }
                    column(Out_Qut; "Out._Qut.")
                    {
                    }
                    column(Ship_Out_Qut; "Ship_Out._Qut.")
                    {
                    }
                    column(Purchase_Line_No; "Purchase Line"."No.")
                    {
                    }
                    column(PurchaseLine_Description; "Purchase Line".Description)
                    {
                    }
                    column(Quantity_Base; "Quantity (Base)")
                    {
                    }
                    column(PurchaseLine_UnitOfMeasure; "Purchase Line"."Unit of Measure")
                    {
                    }
                    column(LocalShelf; LocalShelf)
                    {
                    }
                    column(PurchLine_LineNo; "Line No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin

                        // -JFR001
                        LocalShelf := '';
                        if Type = Type::Item then begin
                            Item.GET("No.");
                            LocalShelf := Item."No. Local Shelf";
                        end;
                        // +JFR001
                    end;

                    trigger OnPreDataItem()
                    begin

                        MoreLines := FIND('+');
                        while MoreLines and (Description = '') and ("Description 2" = '') and
                                            ("No." = '') and (Quantity = 0) and (Amount = 0) do
                            MoreLines := NEXT(-1) <> 0;
                        if not MoreLines then
                            CurrReport.BREAK();
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin

                //CurrReport.LANGUAGE := Language.GetLanguageID("Language Code");
                // CurrReport.PAGENO := 1;

                CompanyInfo.GET();
                // NTR Start
                CompanyInfo.CALCFIELDS(Picture);
                // NTR End

                if RespCenter.GET("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

                if "Purchaser Code" = '' then begin
                    SalesPurchPerson.INIT();
                    PurchaserText := '';
                end else begin
                    SalesPurchPerson.GET("Purchaser Code");
                    PurchaserText := Text000
                end;
                if "Your Reference" = '' then
                    ReferenceText := ''
                else
                    ReferenceText := CopyStr(FIELDCAPTION("Your Reference"), 1, MaxStrLen(ReferenceText));
                FormatAddr.PurchHeaderBuyFrom(BuyFromAddr, "Purchase Header");
                if ("Purchase Header"."Buy-from Vendor No." <> "Purchase Header"."Pay-to Vendor No.") then
                    FormatAddr.PurchHeaderPayTo(VendAddr, "Purchase Header");
                if "Shipment Method Code" = '' then
                    ShipmentMethod.INIT()
                else begin
                    ShipmentMethod.GET("Shipment Method Code");
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                end;

                // UnitofMeasureTranslation.GET(UnitofMeasureTranslation.Code);
                // UnitofMeasureTranslation.TranslateDescription(UnitofMeasureTranslation,"Language Code");
                FormatAddr.PurchHeaderShipTo(ShipToAddr, "Purchase Header");
            end;
        }
    }

    var
        CompanyInfo: Record "Company Information";
        ShipmentMethod: Record "Shipment Method";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        Item: Record Item;
        RespCenter: Record "Responsibility Center";
        FormatAddr: Codeunit "Format Address";
        VendAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        BuyFromAddr: array[8] of Text[50];
        PurchaserText: Text[30];
        ReferenceText: Text[30];
        MoreLines: Boolean;
        CopyText: Text[30];
        LocalShelf: Code[10];
        Text000: Label 'Purchaser', Comment = 'FRA="Acheteur"';
        Text005: Label 'Page %1';
        Text011: Label 'Reg. No.:', Comment = 'FRA="N° SIRET:"';
        Adressedestinataire: Label 'Adresse destinataire';
        "N°_téléphone": Label 'Phone No', Comment = 'FRA="N° téléphone"';
        "N_télécopie": Label 'Telecopie No', Comment = 'FRA="N° télécopie"';
        Date_commande: Label 'Date commande';
        "N°_fournisseur": Label 'N° fournisseur';
        "N°_commande": Label 'N° commande';
        Date_de_rangement: Label 'Date de rangement';
        Condition_livraison: Label 'Condition livraison';
        "Magasin_Réception": Label 'Magasin - Réception';
        Pos: Label 'Pos';
        Article: Label 'Article';
        "Désignation": Label 'Désignation';
        "Quantité": Label 'Quantité';
        "Unité": Label 'Unité';
        "N°_emplacement": Label 'Emplacement No', Comment = 'FRA="N° étagère locale"';
        "Ship._Qut.": Label 'Ship. Qut.';
        Ok: Label 'Ok';
        "Out._Qut.": Label 'Out. Qut.';
        "Ship_Out._Qut.": Label 'Ship Out. Qut.';
        "Emballé_de:": Label 'Received on ', Comment = 'FRA="Réceptionné le"';
        By: Label 'by ', Comment = 'FRA="par"';
        Signature: Label 'signature :', Comment = 'FRA="signature :"';
        au_capitalde: Label 'au capital de';
        "N°_TVA_VAT:": Label 'N° TVA-VAT:';
        "-": Label '-';
        "Siège_social": Label 'Siège social :';
        "Service_après_vente :": Label ' Service après-vente :';
}

