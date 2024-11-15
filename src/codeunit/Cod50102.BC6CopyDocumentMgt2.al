namespace BCSYS.Jura;

using Microsoft.Finance.Currency;
using Microsoft.Inventory.Item;
using Microsoft.Assembly.Document;
using Microsoft.Assembly.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Projects.Resources.Resource;
using Microsoft.CRM.Team;
using Microsoft.Finance.GeneralLedger.Setup;
using System.IO;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Availability;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Inventory.Tracking;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Archive;
using System.Utilities;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Setup;
using Microsoft.Inventory.Ledger;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Payables;
using Microsoft.Service.Contract;
using Microsoft.Service.Item;
using Microsoft.Projects.Project.Planning;
using Microsoft.Finance.Deferral;
using Microsoft.Sales.Comment;
using Microsoft.Purchases.Comment;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.PaymentTerms;
codeunit 50102 "BC6 Copy Document Mgt2"
{
    trigger OnRun()
    begin
    end;

    var
        Currency: Record Currency;
        Item: Record Item;
        AsmHeader: Record "Assembly Header";
        PostedAsmHeader: Record "Posted Assembly Header";
        TempRecGTempSalesLine: Record "Sales Line" temporary;
        Resource: Record Resource;
        TempAsmHeader: Record "Assembly Header" temporary;
        TempAsmLine: Record "Assembly Line" temporary;
        TempSalesInvLineG: Record "Sales Invoice Line" temporary;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        GLSetup: Record "General Ledger Setup";
        TranslationHelper: Codeunit "Translation Helper";
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        TransferOldExtLines: Codeunit "Transfer Old Ext. Text Lines";
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
        UOMMgt: Codeunit "Unit of Measure Management";
        Window: Dialog;
        WindowUpdateDateTime: DateTime;
        InsertCancellationLine: Boolean;
        SalesDocType: Enum "Sales Document Type From";
        PurchDocType: Enum "Purchase Document Type From";
        ServDocType: Option Quote,Contract;
        QtyToAsmToOrder: Decimal;
        QtyToAsmToOrderBase: Decimal;
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;
        MoveNegLines: Boolean;
        Text000: Label 'Please enter a Document No.', Comment = 'FRA="Entrez un numéro de document."';
        Text001: Label '%1 %2 cannot be copied onto itself.', Comment = 'FRA="%1 %2 ne peut pas être copié vers lui-même."';
        DeleteLinesQst: Label 'The existing lines for %1 %2 will be deleted.\\Do you want to continue?', Comment = 'FRA="Les lignes existantes pour %1 %2 vont être supprimées.\\Voulez-vous continuer ?"';
        Text004: Label 'The document line(s) with a G/L account where direct posting is not allowed have not been copied to the new document by the Copy Document batch job.', Comment = 'FRA="Les lignes document avec un compte général pour lequel l''imputation directe n''est pas autorisée n''ont pas été copiées vers le nouveau document par le traitement par lots Copier document."';
        Text006: Label 'NOTE: A Payment Discount was Granted by %1 %2.', Comment = 'FRA="Remarque : un escompte a été accordé par %1 %2."';
        Text007: Label 'Quote,Blanket Order,Order,Invoice,Credit Memo,Posted Shipment,Posted Invoice,Posted Credit Memo,Posted Return Receipt', Comment = 'FRA="Devis,Commande cadre,Commande,Facture,Avoir,Expédition enregistrée,Facture enregistrée,Avoir enregistré,Réception retour enreg"';
        Text008: Label 'There are no negative sales lines to move.', Comment = 'FRA="Il n''existe pas de lignes vente négatives à déplacer."';
        Text009: Label 'NOTE: A Payment Discount was Received by %1 %2.', Comment = 'FRA="Remarque : un escompte a été réceptionné par %1 %2."';
        Text010: Label 'There are no negative purchase lines to move.', Comment = 'FRA="Il n''existe pas de lignes achat négatives à déplacer."';
        CreateToHeader: Boolean;
        Text011: Label 'Please enter a Vendor No.', Comment = 'FRA="Veuillez entrer un numéro de fournisseur."';
        HideDialog: Boolean;
        Text012: Label 'There are no sales lines to copy.', Comment = 'FRA="Il n''existe aucune ligne vente à copier."';
        Text013: Label 'Shipment No.,Invoice No.,Return Receipt No.,Credit Memo No.', Comment = 'FRA="N° livraison,N° facture,N° réception retour,N° avoir"';
        Text014: Label 'Receipt No.,Invoice No.,Return Shipment No.,Credit Memo No.', comment = 'FRA="N° bon de réception,N° facture,N° expédition retour,N° avoir"';
        Text015: Label '%1 %2:', comment = 'FRA="%1 %2:"';
        Text016: Label 'Inv. No. ,Shpt. No. ,Cr. Memo No. ,Rtrn. Rcpt. No. ', comment = 'FRA="N° fact.,N° expéd.,N° avoir,N° récept. ret."';
        Text017: Label 'Inv. No. ,Rcpt. No. ,Cr. Memo No. ,Rtrn. Shpt. No. ', comment = 'FRA="N° fact.,N° récept.,N° avoir,N° expéd. ret."';
        Text018: Label '%1 - %2:', comment = 'FRA="%1 - %2:"';
        Text019: Label 'Exact Cost Reversing Link has not been created for all copied document lines.', comment = 'FRA="Le lien coût retour identique n''a pas été créé pour toutes les lignes de document copiées."';
        Text020: Label '\', comment = 'FRA="\"';
        Text022: Label 'Copying document lines...\', comment = 'FRA="Copie des lignes de document...\"';
        Text023: Label 'Processing source lines      #1######\', comment = 'FRA="Traitement des lignes origine #1######\"';
        Text024: Label 'Creating new lines           #2######', comment = 'FRA="Création de lignes            #2######"';
        ExactCostRevMandatory: Boolean;
        ApplyFully: Boolean;
        AskApply: Boolean;
        ReappDone: Boolean;
        Text025: Label 'For one or more return document lines, you chose to return the original quantity, which is already fully applied. Therefore, when you post the return document, the program will reapply relevant entries. Beware that this may change the cost of existing entries. To avoid this, you must delete the affected return document lines before posting.', Comment = 'FRA="Pour une ou plusieurs lignes de document de retour, vous cherchez à renvoyer la quantité d''origine, déjà entièrement appliquée. Si vous validez plus tard le document de retour, le programme relettrera alors les entrées appropriées. Cela peut modifier le coût des entrées existantes. Pour éviter cela, vous devez supprimer les lignes de document de retour affectées avant la validation."';
        SkippedLine: Boolean;
        Text029: Label 'One or more return document lines were not inserted or they contain only the remaining quantity of the original document line. This is because quantities on the posted document line are already fully or partially applied. If you want to reverse the full quantity, you must select Return Original Quantity before getting the posted document lines.', Comment = 'FRA="Une ou plusieurs lignes de document de retour n''ont pas été insérées ou contiennent uniquement la quantité restante de la ligne de document originale. En effet, les quantités dans la ligne de document validée sont déjà appliquées entièrement ou partiellement. Si vous voulez contrepasser la quantité entière, vous devez sélectionner l''option Renvoyer quantité initiale avant de valider les lignes de document."';
        Text030: Label 'One or more return document lines were not copied. This is because quantities on the posted document line are already fully or partially applied, so the Exact Cost Reversing link could not be created.', Comment = 'FRA="Une ou plusieurs lignes de document de retour n''ont pas été copiées. En effet, des quantités sur la ligne de document validée sont déjà entièrement ou partiellement lettrées, de sorte que le lien Inversion de même coût n''a pas pu être créé."';
        Text031: Label 'Return document line contains only the original document line quantity, that is not already manually applied.', Comment = 'FRA="La ligne de document de retour contient uniquement la quantité de la ligne de document originale, qui n''est pas déjà appliquée manuellement."';
        SomeAreFixed: Boolean;
        AsmHdrExistsForFromDocLine: Boolean;
        Text032: Label 'The posted sales invoice %1 covers more than one shipment of linked assembly orders that potentially have different assembly components. Select Posted Shipment as document type, and then select a specific shipment of assembled items.', Comment = 'FRA="La facture vente enregistrée %1 couvre plusieurs expéditions d''ordres d''assemblage liés qui incluent peut-être différents composants d''assemblage. Sélectionnez Expédition enregistrée en tant que type de document, puis choisissez une expédition spécifique d''articles assemblés."';
        FromDocOccurrenceNo: Integer;
        FromDocVersionNo: Integer;
        SkipCopyFromDescription: Boolean;
        SkipTestCreditLimit: Boolean;
        WarningDone: Boolean;
        DiffPostDateOrderQst: Label 'The Posting Date of the copied document is different from the Posting Date of the original document. The original document already has a Posting No. based on a number series with date order. When you post the copied document, you may have the wrong date order in the posted documents.\Do you want to continue?', Comment = 'FRA="La date de comptabilisation du document copié est différente de celle du document original. Le document original a déjà un numéro de validation basé sur une souche de numéros avec ordre chronologique. Lorsque vous validez le document copié, il se peut que les documents validés contiennent le mauvais ordre chronologique.\Souhaitez-vous continuer ?"';
        CopyPostedDeferral: Boolean;
        CrMemoCancellationMsg: Label 'Cancellation of credit memo %1.', Comment = 'FRA="Annulation de l''avoir %1."';
        CopyExtText: Boolean;
        CopyJobData: Boolean;

    procedure SetProperties(NewIncludeHeader: Boolean; NewRecalculateLines: Boolean; NewMoveNegLines: Boolean; NewCreateToHeader: Boolean; NewHideDialog: Boolean; NewExactCostRevMandatory: Boolean; NewApplyFully: Boolean)
    begin
        IncludeHeader := NewIncludeHeader;
        RecalculateLines := NewRecalculateLines;
        MoveNegLines := NewMoveNegLines;
        CreateToHeader := NewCreateToHeader;
        HideDialog := NewHideDialog;
        ExactCostRevMandatory := NewExactCostRevMandatory;
        ApplyFully := NewApplyFully;
        AskApply := false;
        ReappDone := false;
        SkippedLine := false;
        SomeAreFixed := false;
        SkipCopyFromDescription := false;
        SkipTestCreditLimit := false;
    end;

    procedure SetPropertiesForCreditMemoCorrection()
    begin
        SetProperties(true, false, false, false, true, true, false);
    end;

    procedure SetPropertiesForInvoiceCorrection(NewSkipCopyFromDescription: Boolean)
    begin
        SetProperties(true, false, false, false, true, false, false);
        SkipTestCreditLimit := true;
        SkipCopyFromDescription := NewSkipCopyFromDescription;
    end;

    procedure SalesHeaderDocType(DocType: Option): Integer
    var
        SalesHeader: Record "Sales Header";
    begin
        case DocType of
            SalesDocType::Quote.AsInteger():
                exit(SalesHeader."Document Type"::Quote.AsInteger());
            SalesDocType::"Blanket Order".AsInteger():
                exit(SalesHeader."Document Type"::"Blanket Order".AsInteger());
            SalesDocType::Order.AsInteger():
                exit(SalesHeader."Document Type"::Order.AsInteger());
            SalesDocType::Invoice.AsInteger():
                exit(SalesHeader."Document Type"::Invoice.AsInteger());
            SalesDocType::"Return Order".AsInteger():
                exit(SalesHeader."Document Type"::"Return Order".AsInteger());
            SalesDocType::"Credit Memo".AsInteger():
                exit(SalesHeader."Document Type"::"Credit Memo".AsInteger());
        end;
    end;

    procedure PurchHeaderDocType(DocType: Option): Integer
    var
        FromPurchHeader: Record "Purchase Header";
    begin
        case DocType of
            PurchDocType::Quote.AsInteger():
                exit(FromPurchHeader."Document Type"::Quote.AsInteger());
            PurchDocType::"Blanket Order".AsInteger():
                exit(FromPurchHeader."Document Type"::"Blanket Order".AsInteger());
            PurchDocType::Order.AsInteger():
                exit(FromPurchHeader."Document Type"::Order.AsInteger());
            PurchDocType::Invoice.AsInteger():
                exit(FromPurchHeader."Document Type"::Invoice.AsInteger());
            PurchDocType::"Return Order".AsInteger():
                exit(FromPurchHeader."Document Type"::"Return Order".AsInteger());
            PurchDocType::"Credit Memo".AsInteger():
                exit(FromPurchHeader."Document Type"::"Credit Memo".AsInteger());
        end;
    end;

    procedure CopySalesDocForInvoiceCancelling(FromDocNo: Code[20]; var ToSalesHeader: Record "Sales Header")
    begin
        CopyJobData := true;
        OnBeforeCopySalesDocForInvoiceCancelling(ToSalesHeader, FromDocNo);

        CopySalesDoc(SalesDocType::"Posted Invoice", FromDocNo, ToSalesHeader);
    end;

    procedure CopySalesDocForCrMemoCancelling(FromDocNo: Code[20]; var ToSalesHeader: Record "Sales Header")
    begin
        InsertCancellationLine := true;
        OnBeforeCopySalesDocForCrMemoCancelling(ToSalesHeader, FromDocNo);

        CopySalesDoc(SalesDocType::"Posted Credit Memo", FromDocNo, ToSalesHeader);
        InsertCancellationLine := false;
    end;

    procedure CopySalesDoc(FromDocType: Enum "Sales Document Type From"; FromDocNo: Code[20]; var ToSalesHeader: Record "Sales Header")
    var
        ToSalesLine: Record "Sales Line";
        FromSalesHeader: Record "Sales Header";
        FromSalesShptHeader: Record "Sales Shipment Header";
        FromSalesInvHeader: Record "Sales Invoice Header";
        FromReturnRcptHeader: Record "Return Receipt Header";
        FromSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        FromSalesHeaderArchive: Record "Sales Header Archive";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        ConfirmManagement: Codeunit "Confirm Management";
        NextLineNo: Integer;
        LinesNotCopied: Integer;
        MissingExCostRevLink: Boolean;
        ReleaseDocument: Boolean;
    begin
        if not CreateToHeader then begin
            ToSalesHeader.TESTFIELD(Status, ToSalesHeader.Status::Open);
            if FromDocNo = '' then
                ERROR(Text000);
            ToSalesHeader.FIND();
        end;

        OnBeforeCopySalesDocument(FromDocType.AsInteger(), FromDocNo, ToSalesHeader);

        TransferOldExtLines.ClearLineNumbers();

        if not InitAndCheckSalesDocuments(
             FromDocType.AsInteger(), FromDocNo, FromSalesHeader, ToSalesHeader, ToSalesLine,
             FromSalesShptHeader, FromSalesInvHeader, FromReturnRcptHeader, FromSalesCrMemoHeader,
             FromSalesHeaderArchive)
        then
            exit;

        ToSalesLine.LOCKTABLE();

        ToSalesLine.SETRANGE("Document Type", ToSalesHeader."Document Type");
        if CreateToHeader then begin
            ToSalesHeader.INSERT(true);
            ToSalesLine.SETRANGE("Document No.", ToSalesHeader."No.");
        end else begin
            ToSalesLine.SETRANGE("Document No.", ToSalesHeader."No.");
            if IncludeHeader then
                if not ToSalesLine.ISEMPTY then begin
                    COMMIT();
                    if not ConfirmManagement.GetResponseOrDefault(
                         STRSUBSTNO(DeleteLinesQst, ToSalesHeader."Document Type", ToSalesHeader."No."), true)
                    then
                        exit;
                    ToSalesLine.DELETEALL(true);
                end;
        end;

        if ToSalesLine.FINDLAST() then
            NextLineNo := ToSalesLine."Line No."
        else
            NextLineNo := 0;

        if IncludeHeader then
            CopySalesDocUpdateHeader(
              FromDocType.AsInteger(), FromDocNo, ToSalesHeader, FromSalesHeader,
              FromSalesShptHeader, FromSalesInvHeader, FromReturnRcptHeader, FromSalesCrMemoHeader, FromSalesHeaderArchive, ReleaseDocument)
        else
            OnCopySalesDocWithoutHeader(ToSalesHeader, FromDocType.AsInteger(), FromDocNo, FromDocOccurrenceNo, FromDocVersionNo);

        LinesNotCopied := 0;
        case FromDocType of
            SalesDocType::Quote,
          SalesDocType::"Blanket Order",
          SalesDocType::Order,
          SalesDocType::Invoice,
          SalesDocType::"Return Order",
          SalesDocType::"Credit Memo":
                CopySalesDocSalesLine(FromSalesHeader, ToSalesHeader, LinesNotCopied, NextLineNo);
            SalesDocType::"Posted Shipment":
                begin
                    FromSalesHeader.TRANSFERFIELDS(FromSalesShptHeader);
                    OnCopySalesDocOnBeforeCopySalesDocShptLine(FromSalesShptHeader, ToSalesHeader);
                    CopySalesDocShptLine(FromSalesShptHeader, ToSalesHeader, LinesNotCopied, MissingExCostRevLink);
                end;
            SalesDocType::"Posted Invoice":
                begin
                    FromSalesHeader.TRANSFERFIELDS(FromSalesInvHeader);
                    OnCopySalesDocOnBeforeCopySalesDocInvLine(FromSalesInvHeader, ToSalesHeader);
                    CopySalesDocInvLine(FromSalesInvHeader, ToSalesHeader, LinesNotCopied, MissingExCostRevLink);
                end;
            SalesDocType::"Posted Return Receipt":
                begin
                    FromSalesHeader.TRANSFERFIELDS(FromReturnRcptHeader);
                    OnCopySalesDocOnBeforeCopySalesDocReturnRcptLine(FromReturnRcptHeader, ToSalesHeader);
                    CopySalesDocReturnRcptLine(FromReturnRcptHeader, ToSalesHeader, LinesNotCopied, MissingExCostRevLink);
                end;
            SalesDocType::"Posted Credit Memo":
                begin
                    FromSalesHeader.TRANSFERFIELDS(FromSalesCrMemoHeader);
                    OnCopySalesDocOnBeforeCopySalesDocCrMemoLine(FromSalesCrMemoHeader, ToSalesHeader);
                    CopySalesDocCrMemoLine(FromSalesCrMemoHeader, ToSalesHeader, LinesNotCopied, MissingExCostRevLink);
                end;
            SalesDocType::"Arch. Quote",
          SalesDocType::"Arch. Order",
          SalesDocType::"Arch. Blanket Order",
          SalesDocType::"Arch. Return Order":
                CopySalesDocSalesLineArchive(FromSalesHeaderArchive, ToSalesHeader, LinesNotCopied, NextLineNo);
        end;

        OnCopySalesDocOnBeforeUpdateSalesInvoiceDiscountValue(
          ToSalesHeader, FromDocType.AsInteger(), FromDocNo, FromDocOccurrenceNo, FromDocVersionNo, RecalculateLines);

        UpdateSalesInvoiceDiscountValue(ToSalesHeader);

        if MoveNegLines then begin
            OnBeforeDeleteNegSalesLines(FromDocType.AsInteger(), FromDocNo, ToSalesHeader);
            DeleteSalesLinesWithNegQty(FromSalesHeader, false);
            LinkJobPlanningLine(ToSalesHeader);
        end;

        OnCopySalesDocOnAfterCopySalesDocLines(
          FromDocType.AsInteger(), FromDocNo, FromDocOccurrenceNo, FromDocVersionNo, FromSalesHeader, IncludeHeader, ToSalesHeader);

        if ReleaseDocument then begin
            ToSalesHeader.Status := ToSalesHeader.Status::Released;
            ReleaseSalesDocument.Reopen(ToSalesHeader);
        end else
            if (FromDocType in
                [SalesDocType::Quote,
                 SalesDocType::"Blanket Order",
                 SalesDocType::Order,
                 SalesDocType::Invoice,
                 SalesDocType::"Return Order",
                 SalesDocType::"Credit Memo"])
               and not IncludeHeader and not RecalculateLines
            then
                if FromSalesHeader.Status = FromSalesHeader.Status::Released then begin
                    ReleaseSalesDocument.RUN(ToSalesHeader);
                    ReleaseSalesDocument.Reopen(ToSalesHeader);
                end;
        case true of
            MissingExCostRevLink and (LinesNotCopied <> 0):
                MESSAGE(Text019 + Text020 + Text004);
            MissingExCostRevLink:
                MESSAGE(Text019);
            LinesNotCopied <> 0:
                MESSAGE(Text004);
        end;

        OnAfterCopySalesDocument(
          FromDocType.AsInteger(), FromDocNo, ToSalesHeader, FromDocOccurrenceNo, FromDocVersionNo, IncludeHeader, RecalculateLines, MoveNegLines);
    end;

    local procedure CopySalesDocSalesLine(FromSalesHeader: Record "Sales Header"; var ToSalesHeader: Record "Sales Header"; var LinesNotCopied: Integer; NextLineNo: Integer)
    var
        ToSalesLine: Record "Sales Line";
        FromSalesLine: Record "Sales Line";
        ItemChargeAssgntNextLineNo: Integer;
    begin
        ItemChargeAssgntNextLineNo := 0;

        FromSalesLine.RESET();
        FromSalesLine.SETRANGE("Document Type", FromSalesHeader."Document Type");
        FromSalesLine.SETRANGE("Document No.", FromSalesHeader."No.");
        if MoveNegLines then
            FromSalesLine.SETFILTER(Quantity, '<=0');
        OnCopySalesDocSalesLineOnAfterSetFilters(FromSalesHeader, FromSalesLine, ToSalesHeader);
        if FromSalesLine.FIND('-') then
            repeat
                if not ExtTxtAttachedToPosSalesLine(FromSalesHeader, MoveNegLines, FromSalesLine."Attached to Line No.") then begin
                    InitAsmCopyHandling(true);
                    ToSalesLine."Document Type" := ToSalesHeader."Document Type";
                    AsmHdrExistsForFromDocLine := FromSalesLine.AsmToOrderExists(AsmHeader);
                    if AsmHdrExistsForFromDocLine then begin
                        case ToSalesLine."Document Type" of
                            ToSalesLine."Document Type"::Order:
                                begin
                                    QtyToAsmToOrder := FromSalesLine."Qty. to Assemble to Order";
                                    QtyToAsmToOrderBase := FromSalesLine."Qty. to Asm. to Order (Base)";
                                end;
                            ToSalesLine."Document Type"::Quote,
                            ToSalesLine."Document Type"::"Blanket Order":
                                begin
                                    QtyToAsmToOrder := FromSalesLine.Quantity;
                                    QtyToAsmToOrderBase := FromSalesLine."Quantity (Base)";
                                end;
                        end;
                        GenerateAsmDataFromNonPosted(AsmHeader);
                    end;
                    //>>BC6 SBE 27/01/2022
                    if not FromSalesLine."Completely Shipped" then
                        if CopySalesLine(
                           ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine,
                           NextLineNo, LinesNotCopied, false, DeferralTypeForSalesDoc(FromSalesHeader."Document Type".AsInteger()), CopyPostedDeferral,
                           FromSalesLine."Line No.")
                        //<<BC6 SBE 27/01/2022
                        then begin
                            if FromSalesLine.Type = FromSalesLine.Type::"Charge (Item)" then
                                CopyFromSalesDocAssgntToLine(
                                  ToSalesLine, FromSalesLine."Document Type".AsInteger(), FromSalesLine."Document No.", FromSalesLine."Line No.",
                                  ItemChargeAssgntNextLineNo);
                            OnAfterCopySalesLineFromSalesDocSalesLine(
                              ToSalesHeader, ToSalesLine, FromSalesLine, IncludeHeader, RecalculateLines);
                        end;
                end;
            until FromSalesLine.NEXT() = 0;
    end;

    local procedure CopySalesDocShptLine(FromSalesShptHeader: Record "Sales Shipment Header"; ToSalesHeader: Record "Sales Header"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        FromSalesShptLine: Record "Sales Shipment Line";
    begin
        FromSalesShptLine.RESET();
        FromSalesShptLine.SETRANGE("Document No.", FromSalesShptHeader."No.");
        if MoveNegLines then
            FromSalesShptLine.SETFILTER(Quantity, '<=0');
        OnCopySalesDocShptLineOnAfterSetFilters(ToSalesHeader, FromSalesShptHeader, FromSalesShptLine);
        CopySalesShptLinesToDoc(ToSalesHeader, FromSalesShptLine, LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopySalesDocInvLine(FromSalesInvHeader: Record "Sales Invoice Header"; ToSalesHeader: Record "Sales Header"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        FromSalesInvLine: Record "Sales Invoice Line";
    begin
        FromSalesInvLine.RESET();
        FromSalesInvLine.SETRANGE("Document No.", FromSalesInvHeader."No.");
        if MoveNegLines then
            FromSalesInvLine.SETFILTER(Quantity, '<=0');
        OnCopySalesDocInvLineOnAfterSetFilters(ToSalesHeader, FromSalesInvHeader, FromSalesInvLine);
        CopySalesInvLinesToDoc(ToSalesHeader, FromSalesInvLine, LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopySalesDocCrMemoLine(FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; ToSalesHeader: Record "Sales Header"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        FromSalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        FromSalesCrMemoLine.RESET();
        FromSalesCrMemoLine.SETRANGE("Document No.", FromSalesCrMemoHeader."No.");
        if MoveNegLines then
            FromSalesCrMemoLine.SETFILTER(Quantity, '<=0');
        OnCopySalesDocCrMemoLineOnAfterSetFilters(ToSalesHeader, FromSalesCrMemoHeader, FromSalesCrMemoLine);
        CopySalesCrMemoLinesToDoc(ToSalesHeader, FromSalesCrMemoLine, LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopySalesDocReturnRcptLine(FromReturnRcptHeader: Record "Return Receipt Header"; ToSalesHeader: Record "Sales Header"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        FromReturnRcptLine: Record "Return Receipt Line";
    begin
        FromReturnRcptLine.RESET();
        FromReturnRcptLine.SETRANGE("Document No.", FromReturnRcptHeader."No.");
        if MoveNegLines then
            FromReturnRcptLine.SETFILTER(Quantity, '<=0');
        OnCopySalesDocReturnRcptLineOnAfterSetFilters(ToSalesHeader, FromReturnRcptHeader, FromReturnRcptLine);
        CopySalesReturnRcptLinesToDoc(ToSalesHeader, FromReturnRcptLine, LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopySalesDocSalesLineArchive(FromSalesHeaderArchive: Record "Sales Header Archive"; var ToSalesHeader: Record "Sales Header"; var LinesNotCopied: Integer; NextLineNo: Integer)
    var
        ToSalesLine: Record "Sales Line";
        FromSalesLineArchive: Record "Sales Line Archive";
        ItemChargeAssgntNextLineNo: Integer;
    begin
        ItemChargeAssgntNextLineNo := 0;

        FromSalesLineArchive.RESET();
        FromSalesLineArchive.SETRANGE("Document Type", FromSalesHeaderArchive."Document Type");
        FromSalesLineArchive.SETRANGE("Document No.", FromSalesHeaderArchive."No.");
        FromSalesLineArchive.SETRANGE("Doc. No. Occurrence", FromSalesHeaderArchive."Doc. No. Occurrence");
        FromSalesLineArchive.SETRANGE("Version No.", FromSalesHeaderArchive."Version No.");
        if MoveNegLines then
            FromSalesLineArchive.SETFILTER(Quantity, '<=0');
        OnCopySalesDocSalesLineArchiveOnAfterSetFilters(FromSalesHeaderArchive, FromSalesLineArchive, ToSalesHeader);
        if FromSalesLineArchive.FIND('-') then
            repeat
                if CopyArchSalesLine(
                     ToSalesHeader, ToSalesLine, FromSalesHeaderArchive, FromSalesLineArchive, NextLineNo, LinesNotCopied, false)
                then begin
                    CopyFromArchSalesDocDimToLine(ToSalesLine, FromSalesLineArchive);
                    if FromSalesLineArchive.Type = FromSalesLineArchive.Type::"Charge (Item)" then
                        CopyFromSalesDocAssgntToLine(
                          ToSalesLine, FromSalesLineArchive."Document Type".AsInteger(), FromSalesLineArchive."Document No.", FromSalesLineArchive."Line No.",
                          ItemChargeAssgntNextLineNo);
                    OnAfterCopyArchSalesLine(ToSalesHeader, ToSalesLine, FromSalesLineArchive, IncludeHeader, RecalculateLines);
                end;
            until FromSalesLineArchive.NEXT() = 0;
    end;

    local procedure CopySalesDocUpdateHeader(FromDocType: Option; FromDocNo: Code[20]; var ToSalesHeader: Record "Sales Header"; FromSalesHeader: Record "Sales Header"; FromSalesShptHeader: Record "Sales Shipment Header"; FromSalesInvHeader: Record "Sales Invoice Header"; FromReturnRcptHeader: Record "Return Receipt Header"; FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; FromSalesHeaderArchive: Record "Sales Header Archive"; var ReleaseDocument: Boolean)
    var
        OldSalesHeader: Record "Sales Header";
        SavedDimSetId: Integer;
    begin
        CheckCustomer(FromSalesHeader, ToSalesHeader);
        OldSalesHeader := ToSalesHeader;
        case FromDocType of
            SalesDocType::Quote.AsInteger(),
            SalesDocType::"Blanket Order".AsInteger(),
            SalesDocType::Order.AsInteger(),
            SalesDocType::Invoice.AsInteger(),
            SalesDocType::"Return Order".AsInteger(),
            SalesDocType::"Credit Memo".AsInteger():
                begin
                    FromSalesHeader.CALCFIELDS("Work Description");
                    ToSalesHeader.TRANSFERFIELDS(FromSalesHeader, false);
                    ToSalesHeader."BC6 PreEDI" := false;
                    //MB 09/07/2021
                    //>>BC6 SBE 27/01/2022
                    ToSalesHeader."JWC Last Date Modified" := 0D;
                    ToSalesHeader.VALIDATE("Requested Delivery Date", 0D);
                    ToSalesHeader."Completely Shipped" := false;
                    //<<BC6 SBE 27/01/2022
                    UpdateSalesHeaderWhenCopyFromSalesHeader(ToSalesHeader, OldSalesHeader, FromDocType);
                    OnAfterCopySalesHeader(ToSalesHeader, OldSalesHeader, FromSalesHeader);
                end;
            SalesDocType::"Posted Shipment".AsInteger():
                begin
                    ToSalesHeader.VALIDATE("Sell-to Customer No.", FromSalesShptHeader."Sell-to Customer No.");
                    OnCopySalesDocOnBeforeTransferPostedShipmentFields(ToSalesHeader, FromSalesShptHeader);
                    ToSalesHeader.TRANSFERFIELDS(FromSalesShptHeader, false);
                    OnAfterCopyPostedShipment(ToSalesHeader, OldSalesHeader, FromSalesShptHeader);
                end;
            SalesDocType::"Posted Invoice".AsInteger():
                begin
                    FromSalesInvHeader.CALCFIELDS("Work Description");
                    ToSalesHeader.VALIDATE("Sell-to Customer No.", FromSalesInvHeader."Sell-to Customer No.");
                    OnCopySalesDocOnBeforeTransferPostedInvoiceFields(ToSalesHeader, FromSalesInvHeader);
                    ToSalesHeader.TRANSFERFIELDS(FromSalesInvHeader, false);
                    OnCopySalesDocOnAfterTransferPostedInvoiceFields(ToSalesHeader, FromSalesInvHeader, OldSalesHeader);
                end;
            SalesDocType::"Posted Return Receipt".AsInteger():
                begin
                    ToSalesHeader.VALIDATE("Sell-to Customer No.", FromReturnRcptHeader."Sell-to Customer No.");
                    OnCopySalesDocOnBeforeTransferPostedReturnReceiptFields(ToSalesHeader, FromReturnRcptHeader);
                    ToSalesHeader.TRANSFERFIELDS(FromReturnRcptHeader, false);
                    OnAfterCopyPostedReturnReceipt(ToSalesHeader, OldSalesHeader, FromReturnRcptHeader);
                end;
            SalesDocType::"Posted Credit Memo".AsInteger():
                TransferFieldsFromCrMemoToInv(ToSalesHeader, FromSalesCrMemoHeader);
            SalesDocType::"Arch. Quote".AsInteger(),
            SalesDocType::"Arch. Order".AsInteger(),
            SalesDocType::"Arch. Blanket Order".AsInteger(),
            SalesDocType::"Arch. Return Order".AsInteger():
                begin
                    ToSalesHeader.VALIDATE("Sell-to Customer No.", FromSalesHeaderArchive."Sell-to Customer No.");
                    ToSalesHeader.TRANSFERFIELDS(FromSalesHeaderArchive, false);
                    OnCopySalesDocOnAfterTransferArchSalesHeaderFields(ToSalesHeader, FromSalesHeaderArchive);
                    UpdateSalesHeaderWhenCopyFromSalesHeaderArchive(ToSalesHeader);
                    CopyFromArchSalesDocDimToHdr(ToSalesHeader, FromSalesHeaderArchive);
                    OnAfterCopySalesHeaderArchive(ToSalesHeader, OldSalesHeader, FromSalesHeaderArchive)
                end;
        end;
        OnAfterCopySalesHeaderDone(
          ToSalesHeader, OldSalesHeader, FromSalesHeader, FromSalesShptHeader, FromSalesInvHeader,
          FromReturnRcptHeader, FromSalesCrMemoHeader, FromSalesHeaderArchive);

        ToSalesHeader.Invoice := false;
        ToSalesHeader.Ship := false;
        if ToSalesHeader.Status = ToSalesHeader.Status::Released then begin
            ToSalesHeader.Status := ToSalesHeader.Status::Open;
            ReleaseDocument := true;
        end;
        if MoveNegLines or IncludeHeader then
            ToSalesHeader.VALIDATE("Location Code");
        CopyShiptoCodeFromInvToCrMemo(ToSalesHeader, FromSalesInvHeader, FromDocType);
        CopyFieldsFromOldSalesHeader(ToSalesHeader, OldSalesHeader);
        OnAfterCopyFieldsFromOldSalesHeader(ToSalesHeader, OldSalesHeader, MoveNegLines, IncludeHeader);
        if RecalculateLines then begin
            if IncludeHeader then
                SavedDimSetId := ToSalesHeader."Dimension Set ID";
            ToSalesHeader.CreateDimFromDefaultDim(0);
            if IncludeHeader then
                ToSalesHeader."Dimension Set ID" := SavedDimSetId;
        end;
        ToSalesHeader."No. Printed" := 0;
        ToSalesHeader."Applies-to Doc. Type" := ToSalesHeader."Applies-to Doc. Type"::" ";
        ToSalesHeader."Applies-to Doc. No." := '';
        ToSalesHeader."Applies-to ID" := '';
        ToSalesHeader."Opportunity No." := '';
        ToSalesHeader."Quote No." := '';
        OnCopySalesDocUpdateHeaderOnBeforeUpdateCustLedgerEntry(ToSalesHeader, FromDocType, FromDocNo);

        if ((FromDocType = SalesDocType::"Posted Invoice".AsInteger()) and
            (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::"Return Order", ToSalesHeader."Document Type"::"Credit Memo"])) or
           ((FromDocType = SalesDocType::"Posted Credit Memo".AsInteger()) and
            not (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::"Return Order", ToSalesHeader."Document Type"::"Credit Memo"]))
        then
            UpdateCustLedgEntry(ToSalesHeader, FromDocType, FromDocNo);

        HandleZeroAmountPostedInvoices(FromSalesInvHeader, ToSalesHeader, FromDocType, FromDocNo);

        if ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::"Blanket Order", ToSalesHeader."Document Type"::Quote] then
            ToSalesHeader."Posting Date" := 0D;

        ToSalesHeader.Correction := false;
        if ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::"Return Order", ToSalesHeader."Document Type"::"Credit Memo"] then
            UpdateSalesCreditMemoHeader(ToSalesHeader);

        OnBeforeModifySalesHeader(ToSalesHeader, FromDocType, FromDocNo, IncludeHeader, FromDocOccurrenceNo, FromDocVersionNo);

        if CreateToHeader then begin
            ToSalesHeader.VALIDATE("Payment Terms Code");
            ToSalesHeader.MODIFY(true);
        end else
            ToSalesHeader.MODIFY();
        OnCopySalesDocWithHeader(FromDocType, FromDocNo, ToSalesHeader, FromDocOccurrenceNo, FromDocVersionNo);
    end;

    local procedure CheckCustomer(var FromSalesHeader: Record "Sales Header"; var ToSalesHeader: Record "Sales Header")
    var
        Cust: Record Customer;
    begin
        if Cust.GET(FromSalesHeader."Sell-to Customer No.") then
            Cust.CheckBlockedCustOnDocs(Cust, ToSalesHeader."Document Type", false, false);
        if Cust.GET(FromSalesHeader."Bill-to Customer No.") then
            Cust.CheckBlockedCustOnDocs(Cust, ToSalesHeader."Document Type", false, false);
    end;

    local procedure CheckAsmHdrExistsForFromDocLine(ToSalesHeader: Record "Sales Header"; FromSalesLine2: Record "Sales Line"; var BufferCount: Integer; LineCountsEqual: Boolean)
    begin
        BufferCount += 1;
        AsmHdrExistsForFromDocLine := RetrieveSalesInvLine(FromSalesLine2, BufferCount, LineCountsEqual);
        InitAsmCopyHandling(true);
        if AsmHdrExistsForFromDocLine then begin
            AsmHdrExistsForFromDocLine := GetAsmDataFromSalesInvLine(ToSalesHeader."Document Type".AsInteger());
            if AsmHdrExistsForFromDocLine then begin
                QtyToAsmToOrder := TempSalesInvLineG.Quantity;
                QtyToAsmToOrderBase := TempSalesInvLineG.Quantity * TempSalesInvLineG."Qty. per Unit of Measure";
            end;
        end;
    end;

    local procedure HandleZeroAmountPostedInvoices(var FromSalesInvHeader: Record "Sales Invoice Header"; var ToSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20])
    begin
        // Apply credit memo to invoice in case of Sales Invoices with total amount 0
        FromSalesInvHeader.CALCFIELDS(Amount);
        if (ToSalesHeader."Applies-to Doc. Type" = ToSalesHeader."Applies-to Doc. Type"::" ") and (ToSalesHeader."Applies-to Doc. No." = '') and
   (FromDocType = SalesDocType::"Posted Invoice".AsInteger()) and (FromSalesInvHeader.Amount = 0)
then begin
            ToSalesHeader."Applies-to Doc. Type" := ToSalesHeader."Applies-to Doc. Type"::Invoice;
            ToSalesHeader."Applies-to Doc. No." := FromDocNo;
        end;
    end;

    procedure CopyPurchaseDocForInvoiceCancelling(FromDocNo: Code[20]; var ToPurchaseHeader: Record "Purchase Header")
    begin
        OnBeforeCopyPurchaseDocForInvoiceCancelling(ToPurchaseHeader, FromDocNo);

        CopyPurchDoc(PurchDocType::"Posted Invoice", FromDocNo, ToPurchaseHeader);
    end;

    procedure CopyPurchDocForCrMemoCancelling(FromDocNo: Code[20]; var ToPurchaseHeader: Record "Purchase Header")
    begin
        InsertCancellationLine := true;
        OnBeforeCopyPurchaseDocForCrMemoCancelling(ToPurchaseHeader, FromDocNo);

        CopyPurchDoc(SalesDocType::"Posted Credit Memo", FromDocNo, ToPurchaseHeader);
        InsertCancellationLine := false;
    end;

    procedure CopyPurchDoc(FromDocType: Enum "Purchase Document Type From"; FromDocNo: Code[20]; var ToPurchHeader: Record "Purchase Header")
    var
        ToPurchLine: Record "Purchase Line";
        FromPurchHeader: Record "Purchase Header";
        FromPurchRcptHeader: Record "Purch. Rcpt. Header";
        FromPurchInvHeader: Record "Purch. Inv. Header";
        FromReturnShptHeader: Record "Return Shipment Header";
        FromPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        FromPurchHeaderArchive: Record "Purchase Header Archive";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        ConfirmManagement: Codeunit "Confirm Management";
        NextLineNo: Integer;
        LinesNotCopied: Integer;
        MissingExCostRevLink: Boolean;
        ReleaseDocument: Boolean;
    begin
        if not CreateToHeader then begin
            ToPurchHeader.TESTFIELD(Status, ToPurchHeader.Status::Open);
            if FromDocNo = '' then
                ERROR(Text000);
            ToPurchHeader.FIND();
        end;

        OnBeforeCopyPurchaseDocument(FromDocType.AsInteger(), FromDocNo, ToPurchHeader);

        TransferOldExtLines.ClearLineNumbers();

        if not InitAndCheckPurchaseDocuments(
             FromDocType.AsInteger(), FromDocNo, FromPurchHeader, ToPurchHeader,
             FromPurchRcptHeader, FromPurchInvHeader, FromReturnShptHeader, FromPurchCrMemoHeader,
             FromPurchHeaderArchive)
        then
            exit;

        ToPurchLine.LOCKTABLE();

        if CreateToHeader then begin
            ToPurchHeader.INSERT(true);
            ToPurchLine.SETRANGE("Document Type", ToPurchHeader."Document Type");
            ToPurchLine.SETRANGE("Document No.", ToPurchHeader."No.");
        end else begin
            ToPurchLine.SETRANGE("Document Type", ToPurchHeader."Document Type");
            ToPurchLine.SETRANGE("Document No.", ToPurchHeader."No.");
            if IncludeHeader then
                if ToPurchLine.FINDFIRST() then begin
                    COMMIT();
                    if not ConfirmManagement.GetResponseOrDefault(
                         StrSubstNo(DeleteLinesQst, ToPurchHeader."Document Type", ToPurchHeader."No."), true)
                    then
                        exit;
                    ToPurchLine.DELETEALL(true);
                end;
        end;

        if ToPurchLine.FINDLAST() then
            NextLineNo := ToPurchLine."Line No."
        else
            NextLineNo := 0;

        if IncludeHeader then
            CopyPurchDocUpdateHeader(
              FromDocType, FromDocNo, ToPurchHeader, FromPurchHeader,
              FromPurchRcptHeader, FromPurchInvHeader, FromReturnShptHeader, FromPurchCrMemoHeader, FromPurchHeaderArchive, ReleaseDocument)
        else
            OnCopyPurchDocWithoutHeader(ToPurchHeader, FromDocType.AsInteger(), FromDocNo, FromDocOccurrenceNo, FromDocVersionNo);

        LinesNotCopied := 0;
        case FromDocType of
            PurchDocType::Quote,
          PurchDocType::"Blanket Order",
          PurchDocType::Order,
          PurchDocType::Invoice,
          PurchDocType::"Return Order",
          PurchDocType::"Credit Memo":
                CopyPurchDocPurchLine(FromPurchHeader, ToPurchHeader, LinesNotCopied, NextLineNo);
            PurchDocType::"Posted Receipt":
                begin
                    FromPurchHeader.TRANSFERFIELDS(FromPurchRcptHeader);
                    OnCopyPurchDocOnBeforeCopyPurchDocRcptLine(FromPurchRcptHeader, ToPurchHeader);
                    CopyPurchDocRcptLine(FromPurchRcptHeader, ToPurchHeader, LinesNotCopied, MissingExCostRevLink);
                end;
            PurchDocType::"Posted Invoice":
                begin
                    FromPurchHeader.TRANSFERFIELDS(FromPurchInvHeader);
                    OnCopyPurchDocOnBeforeCopyPurchDocInvLine(FromPurchInvHeader, ToPurchHeader);
                    CopyPurchDocInvLine(FromPurchInvHeader, ToPurchHeader, LinesNotCopied, MissingExCostRevLink);
                end;
            PurchDocType::"Posted Return Shipment":
                begin
                    FromPurchHeader.TRANSFERFIELDS(FromReturnShptHeader);
                    OnCopyPurchDocOnBeforeCopyPurchDocReturnShptLine(FromReturnShptHeader, ToPurchHeader);
                    CopyPurchDocReturnShptLine(FromReturnShptHeader, ToPurchHeader, LinesNotCopied, MissingExCostRevLink);
                end;
            PurchDocType::"Posted Credit Memo":
                begin
                    FromPurchHeader.TRANSFERFIELDS(FromPurchCrMemoHeader);
                    OnCopyPurchDocOnBeforeCopyPurchDocCrMemoLine(FromPurchCrMemoHeader, ToPurchHeader);
                    CopyPurchDocCrMemoLine(FromPurchCrMemoHeader, ToPurchHeader, LinesNotCopied, MissingExCostRevLink);
                end;
            PurchDocType::"Arch. Order",
          PurchDocType::"Arch. Quote",
          PurchDocType::"Arch. Blanket Order",
          PurchDocType::"Arch. Return Order":
                CopyPurchDocPurchLineArchive(FromPurchHeaderArchive, ToPurchHeader, LinesNotCopied, NextLineNo);
        end;

        OnCopyPurchDocOnBeforeUpdatePurchInvoiceDiscountValue(
          ToPurchHeader, FromDocType.AsInteger(), FromDocNo, FromDocOccurrenceNo, FromDocVersionNo, RecalculateLines);

        UpdatePurchaseInvoiceDiscountValue(ToPurchHeader);

        if MoveNegLines then
            DeletePurchLinesWithNegQty(FromPurchHeader, false);

        OnCopyPurchDocOnAfterCopyPurchDocLines(FromDocType.AsInteger(), FromDocNo, FromPurchHeader, IncludeHeader, ToPurchHeader);

        if ReleaseDocument then begin
            ToPurchHeader.Status := ToPurchHeader.Status::Released;
            ReleasePurchaseDocument.Reopen(ToPurchHeader);
        end else
            if (FromDocType in
                [PurchDocType::Quote,
                 PurchDocType::"Blanket Order",
                 PurchDocType::Order,
                 PurchDocType::Invoice,
                 PurchDocType::"Return Order",
                 PurchDocType::"Credit Memo"])
               and not IncludeHeader and not RecalculateLines
            then
                if FromPurchHeader.Status = FromPurchHeader.Status::Released then begin
                    ReleasePurchaseDocument.RUN(ToPurchHeader);
                    ReleasePurchaseDocument.Reopen(ToPurchHeader);
                end;

        case true of
            MissingExCostRevLink and (LinesNotCopied <> 0):
                MESSAGE(Text019 + Text020 + Text004);
            MissingExCostRevLink:
                MESSAGE(Text019);
            LinesNotCopied <> 0:
                MESSAGE(Text004);
        end;

        OnAfterCopyPurchaseDocument(
          FromDocType.AsInteger(), FromDocNo, ToPurchHeader, FromDocOccurrenceNo, FromDocVersionNo, IncludeHeader, RecalculateLines, MoveNegLines);
    end;

    local procedure CopyPurchDocPurchLine(FromPurchHeader: Record "Purchase Header"; ToPurchHeader: Record "Purchase Header"; var LinesNotCopied: Integer; NextLineNo: Integer)
    var
        ToPurchLine: Record "Purchase Line";
        FromPurchLine: Record "Purchase Line";
        ItemChargeAssgntNextLineNo: Integer;
    begin
        ItemChargeAssgntNextLineNo := 0;

        FromPurchLine.RESET();
        FromPurchLine.SETRANGE("Document Type", FromPurchHeader."Document Type");
        FromPurchLine.SETRANGE("Document No.", FromPurchHeader."No.");
        if MoveNegLines then
            FromPurchLine.SETFILTER(Quantity, '<=0');
        if FromPurchLine.FIND('-') then
            repeat
                if not ExtTxtAttachedToPosPurchLine(FromPurchHeader, MoveNegLines, FromPurchLine."Attached to Line No.") then
                    if CopyPurchLine(
                         ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine,
                         NextLineNo, LinesNotCopied, false, DeferralTypeForPurchDoc(FromPurchHeader."Document Type".AsInteger()), CopyPostedDeferral,
                         FromPurchLine."Line No.")
                    then
                        if FromPurchLine.Type = FromPurchLine.Type::"Charge (Item)" then
                            CopyFromPurchDocAssgntToLine(
                              ToPurchLine, FromPurchLine."Document Type".AsInteger(), FromPurchLine."Document No.", FromPurchLine."Line No.",
                              ItemChargeAssgntNextLineNo);
            until FromPurchLine.NEXT() = 0;
    end;

    local procedure CopyPurchDocRcptLine(FromPurchRcptHeader: Record "Purch. Rcpt. Header"; ToPurchHeader: Record "Purchase Header"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        FromPurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        FromPurchRcptLine.RESET();
        FromPurchRcptLine.SETRANGE("Document No.", FromPurchRcptHeader."No.");
        if MoveNegLines then
            FromPurchRcptLine.SETFILTER(Quantity, '<=0');
        CopyPurchRcptLinesToDoc(ToPurchHeader, FromPurchRcptLine, LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopyPurchDocInvLine(FromPurchInvHeader: Record "Purch. Inv. Header"; ToPurchHeader: Record "Purchase Header"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        FromPurchInvLine: Record "Purch. Inv. Line";
        FromPurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        FromPurchInvLine.RESET();
        FromPurchInvLine.SETRANGE("Document No.", FromPurchInvHeader."No.");
        if MoveNegLines then
            FromPurchInvLine.SETFILTER(Quantity, '<=0');
        CopyPurchInvLinesToDoc(ToPurchHeader, FromPurchCrMemoLine, FromPurchInvLine, LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopyPurchDocCrMemoLine(FromPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; ToPurchHeader: Record "Purchase Header"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        FromPurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        FromPurchCrMemoLine.RESET();
        FromPurchCrMemoLine.SETRANGE("Document No.", FromPurchCrMemoHeader."No.");
        if MoveNegLines then
            FromPurchCrMemoLine.SETFILTER(Quantity, '<=0');
        CopyPurchCrMemoLinesToDoc(ToPurchHeader, FromPurchCrMemoLine, LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopyPurchDocReturnShptLine(FromReturnShptHeader: Record "Return Shipment Header"; ToPurchHeader: Record "Purchase Header"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        FromReturnShptLine: Record "Return Shipment Line";
    begin
        FromReturnShptLine.RESET();
        FromReturnShptLine.SETRANGE("Document No.", FromReturnShptHeader."No.");
        if MoveNegLines then
            FromReturnShptLine.SETFILTER(Quantity, '<=0');
        CopyPurchReturnShptLinesToDoc(ToPurchHeader, FromReturnShptLine, LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopyPurchDocPurchLineArchive(FromPurchHeaderArchive: Record "Purchase Header Archive"; var ToPurchHeader: Record "Purchase Header"; var LinesNotCopied: Integer; NextLineNo: Integer)
    var
        ToPurchLine: Record "Purchase Line";
        FromPurchLineArchive: Record "Purchase Line Archive";
        ItemChargeAssgntNextLineNo: Integer;
    begin
        ItemChargeAssgntNextLineNo := 0;

        FromPurchLineArchive.RESET();
        FromPurchLineArchive.SETRANGE("Document Type", FromPurchHeaderArchive."Document Type");
        FromPurchLineArchive.SETRANGE("Document No.", FromPurchHeaderArchive."No.");
        FromPurchLineArchive.SETRANGE("Doc. No. Occurrence", FromPurchHeaderArchive."Doc. No. Occurrence");
        FromPurchLineArchive.SETRANGE("Version No.", FromPurchHeaderArchive."Version No.");
        if MoveNegLines then
            FromPurchLineArchive.SETFILTER(Quantity, '<=0');
        if FromPurchLineArchive.FIND('-') then
            repeat
                if CopyArchPurchLine(
                     ToPurchHeader, ToPurchLine, FromPurchHeaderArchive, FromPurchLineArchive, NextLineNo, LinesNotCopied, false)
                then begin
                    CopyFromArchPurchDocDimToLine(ToPurchLine, FromPurchLineArchive);
                    if FromPurchLineArchive.Type = FromPurchLineArchive.Type::"Charge (Item)" then
                        CopyFromPurchDocAssgntToLine(
                          ToPurchLine, FromPurchLineArchive."Document Type".AsInteger(), FromPurchLineArchive."Document No.", FromPurchLineArchive."Line No.",
                          ItemChargeAssgntNextLineNo);
                    OnAfterCopyArchPurchLine(ToPurchHeader, ToPurchLine, FromPurchLineArchive, IncludeHeader, RecalculateLines);
                end;
            until FromPurchLineArchive.NEXT() = 0;
    end;

    local procedure CopyPurchDocUpdateHeader(FromDocType: Enum "Purchase Document Type From"; FromDocNo: Code[20]; var ToPurchHeader: Record "Purchase Header"; FromPurchHeader: Record "Purchase Header"; FromPurchRcptHeader: Record "Purch. Rcpt. Header"; FromPurchInvHeader: Record "Purch. Inv. Header"; FromReturnShptHeader: Record "Return Shipment Header"; FromPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; FromPurchHeaderArchive: Record "Purchase Header Archive"; var ReleaseDocument: Boolean)
    var
        Vend: Record Vendor;
        OldPurchHeader: Record "Purchase Header";
        SavedDimSetId: Integer;
    begin
        if Vend.GET(FromPurchHeader."Buy-from Vendor No.") then
            Vend.CheckBlockedVendOnDocs(Vend, false);
        if Vend.GET(FromPurchHeader."Pay-to Vendor No.") then
            Vend.CheckBlockedVendOnDocs(Vend, false);
        OldPurchHeader := ToPurchHeader;

        case FromDocType of
            PurchDocType::Quote,
            PurchDocType::"Blanket Order",
            PurchDocType::Order,
            PurchDocType::Invoice,
            PurchDocType::"Return Order",
            PurchDocType::"Credit Memo":
                begin
                    ToPurchHeader.TRANSFERFIELDS(FromPurchHeader, false);
                    UpdatePurchHeaderWhenCopyFromPurchHeader(ToPurchHeader, OldPurchHeader, FromDocType.AsInteger());
                    OnAfterCopyPurchaseHeader(ToPurchHeader, OldPurchHeader);
                end;
            PurchDocType::"Posted Receipt":
                begin
                    ToPurchHeader.VALIDATE("Buy-from Vendor No.", FromPurchRcptHeader."Buy-from Vendor No.");
                    ToPurchHeader.TRANSFERFIELDS(FromPurchRcptHeader, false);
                    OnAfterCopyPostedReceipt(ToPurchHeader, OldPurchHeader, FromPurchRcptHeader);
                end;
            PurchDocType::"Posted Invoice":
                begin
                    ToPurchHeader.VALIDATE("Buy-from Vendor No.", FromPurchInvHeader."Buy-from Vendor No.");
                    ToPurchHeader.TRANSFERFIELDS(FromPurchInvHeader, false);
                    OnAfterCopyPostedPurchInvoice(ToPurchHeader, OldPurchHeader, FromPurchInvHeader);
                end;
            PurchDocType::"Posted Return Shipment":
                begin
                    ToPurchHeader.VALIDATE("Buy-from Vendor No.", FromReturnShptHeader."Buy-from Vendor No.");
                    ToPurchHeader.TRANSFERFIELDS(FromReturnShptHeader, false);
                    OnAfterCopyPostedReturnShipment(ToPurchHeader, OldPurchHeader, FromReturnShptHeader);
                end;
            PurchDocType::"Posted Credit Memo":
                begin
                    ToPurchHeader.VALIDATE("Buy-from Vendor No.", FromPurchCrMemoHeader."Buy-from Vendor No.");
                    ToPurchHeader.TRANSFERFIELDS(FromPurchCrMemoHeader, false);
                end;
            PurchDocType::"Arch. Order",
            PurchDocType::"Arch. Quote",
            PurchDocType::"Arch. Blanket Order",
            PurchDocType::"Arch. Return Order":
                begin
                    ToPurchHeader.VALIDATE("Buy-from Vendor No.", FromPurchHeaderArchive."Buy-from Vendor No.");
                    ToPurchHeader.TRANSFERFIELDS(FromPurchHeaderArchive, false);
                    UpdatePurchHeaderWhenCopyFromPurchHeaderArchive(ToPurchHeader);
                    CopyFromArchPurchDocDimToHdr(ToPurchHeader, FromPurchHeaderArchive);
                    OnAfterCopyPurchHeaderArchive(ToPurchHeader, OldPurchHeader, FromPurchHeaderArchive)
                end;
        end;
        OnAfterCopyPurchHeaderDone(
          ToPurchHeader, OldPurchHeader, FromPurchHeader, FromPurchRcptHeader, FromPurchInvHeader,
          FromReturnShptHeader, FromPurchCrMemoHeader, FromPurchHeaderArchive);

        ToPurchHeader.Invoice := false;
        ToPurchHeader.Receive := false;
        if ToPurchHeader.Status = ToPurchHeader.Status::Released then begin
            ToPurchHeader.Status := ToPurchHeader.Status::Open;
            ReleaseDocument := true;
        end;
        if MoveNegLines or IncludeHeader then begin
            ToPurchHeader.VALIDATE("Location Code");
            CopyShippingInfoPurchOrder(ToPurchHeader, FromPurchHeader);
        end;
        if MoveNegLines then
            ToPurchHeader.VALIDATE("Order Address Code");

        CopyFieldsFromOldPurchHeader(ToPurchHeader, OldPurchHeader);
        OnAfterCopyFieldsFromOldPurchHeader(ToPurchHeader, OldPurchHeader, MoveNegLines, IncludeHeader);
        if RecalculateLines then begin
            if IncludeHeader then
                SavedDimSetId := ToPurchHeader."Dimension Set ID";
            ToPurchHeader.CreateDimFromDefaultDim(0);
            if IncludeHeader then
                ToPurchHeader."Dimension Set ID" := SavedDimSetId;
        end;
        ToPurchHeader."No. Printed" := 0;
        ToPurchHeader."Applies-to Doc. Type" := ToPurchHeader."Applies-to Doc. Type"::" ";
        ToPurchHeader."Applies-to Doc. No." := '';
        ToPurchHeader."Applies-to ID" := '';
        ToPurchHeader."Quote No." := '';
        OnCopyPurchDocUpdateHeaderOnBeforeUpdateVendLedgerEntry(ToPurchHeader, FromDocType.AsInteger(), FromDocNo);

        if ((FromDocType.AsInteger() = PurchDocType::"Posted Invoice".AsInteger()) and
            (ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::"Return Order", ToPurchHeader."Document Type"::"Credit Memo"])) or
           ((FromDocType.AsInteger() = PurchDocType::"Posted Credit Memo".AsInteger()) and
            not (ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::"Return Order", ToPurchHeader."Document Type"::"Credit Memo"]))
        then
            UpdateVendLedgEntry(ToPurchHeader, FromDocType.AsInteger(), FromDocNo);

        if ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::"Blanket Order", ToPurchHeader."Document Type"::Quote] then
            ToPurchHeader."Posting Date" := 0D;

        ToPurchHeader.Correction := false;
        if ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::"Return Order", ToPurchHeader."Document Type"::"Credit Memo"] then
            UpdatePurchCreditMemoHeader(ToPurchHeader);

        OnBeforeModifyPurchHeader(ToPurchHeader, FromDocType.AsInteger(), FromDocNo, IncludeHeader, FromDocOccurrenceNo, FromDocVersionNo);

        if CreateToHeader then begin
            ToPurchHeader.VALIDATE("Payment Terms Code");
            ToPurchHeader.MODIFY(true);
        end else
            ToPurchHeader.MODIFY();

        OnCopyPurchDocWithHeader(FromDocType.AsInteger(), FromDocNo, ToPurchHeader, FromDocOccurrenceNo, FromDocVersionNo);
    end;

    procedure ShowSalesDoc(ToSalesHeader: Record "Sales Header")
    begin
        case ToSalesHeader."Document Type" of
            ToSalesHeader."Document Type"::Order:
                PAGE.RUN(PAGE::"Sales Order", ToSalesHeader);
            ToSalesHeader."Document Type"::Invoice:
                PAGE.RUN(PAGE::"Sales Invoice", ToSalesHeader);
            ToSalesHeader."Document Type"::"Return Order":
                PAGE.RUN(PAGE::"Sales Return Order", ToSalesHeader);
            ToSalesHeader."Document Type"::"Credit Memo":
                PAGE.RUN(PAGE::"Sales Credit Memo", ToSalesHeader);
        end;
    end;

    procedure ShowPurchDoc(ToPurchHeader: Record "Purchase Header")
    begin
        case ToPurchHeader."Document Type" of
            ToPurchHeader."Document Type"::Order:
                PAGE.RUN(PAGE::"Purchase Order", ToPurchHeader);
            ToPurchHeader."Document Type"::Invoice:
                PAGE.RUN(PAGE::"Purchase Invoice", ToPurchHeader);
            ToPurchHeader."Document Type"::"Return Order":
                PAGE.RUN(PAGE::"Purchase Return Order", ToPurchHeader);
            ToPurchHeader."Document Type"::"Credit Memo":
                PAGE.RUN(PAGE::"Purchase Credit Memo", ToPurchHeader);
        end;
    end;

    procedure CopyFromSalesToPurchDoc(VendorNo: Code[20]; FromSalesHeader: Record "Sales Header"; var ToPurchHeader: Record "Purchase Header")
    var
        FromSalesLine: Record "Sales Line";
        ToPurchLine: Record "Purchase Line";
        NextLineNo: Integer;
    begin
        if VendorNo = '' then
            ERROR(Text011);

        ToPurchLine.LOCKTABLE();
        OnCopyFromSalesToPurchDocOnBeforePurchaseHeaderInsert(ToPurchHeader, FromSalesHeader);
        ToPurchHeader.INSERT(true);
        ToPurchHeader.VALIDATE("Buy-from Vendor No.", VendorNo);
        ToPurchHeader.MODIFY(true);
        FromSalesLine.SETRANGE("Document Type", FromSalesHeader."Document Type");
        FromSalesLine.SETRANGE("Document No.", FromSalesHeader."No.");
        OnCopyFromSalesToPurchDocOnAfterSetFilters(FromSalesLine, FromSalesHeader);
        if not FromSalesLine.FIND('-') then
            ERROR(Text012);
        repeat
            NextLineNo := NextLineNo + 10000;
            CLEAR(ToPurchLine);
            ToPurchLine.INIT();
            ToPurchLine."Document Type" := ToPurchHeader."Document Type";
            ToPurchLine."Document No." := ToPurchHeader."No.";
            ToPurchLine."Line No." := NextLineNo;
            if FromSalesLine.Type = FromSalesLine.Type::" " then
                ToPurchLine.Description := FromSalesLine.Description
            else
                TransfldsFromSalesToPurchLine(FromSalesLine, ToPurchLine);
            OnBeforeCopySalesToPurchDoc(ToPurchLine, FromSalesLine);
            ToPurchLine.INSERT(true);
            if (FromSalesLine.Type <> FromSalesLine.Type::" ") and (ToPurchLine.Type = ToPurchLine.Type::Item) and (ToPurchLine.Quantity <> 0) then
                CopyItemTrackingEntries(
                  FromSalesLine, ToPurchLine, FromSalesHeader."Prices Including VAT",
                  ToPurchHeader."Prices Including VAT");
            OnAfterCopySalesToPurchDoc(ToPurchLine, FromSalesLine);
        until FromSalesLine.NEXT() = 0;

        OnAfterCopyFromSalesToPurchDoc(FromSalesHeader, ToPurchHeader);
    end;

    procedure TransfldsFromSalesToPurchLine(var FromSalesLine: Record "Sales Line"; var ToPurchLine: Record "Purchase Line")
    begin
        OnBeforeTransfldsFromSalesToPurchLine(FromSalesLine, ToPurchLine);

        ToPurchLine.VALIDATE(Type, FromSalesLine.Type);
        ToPurchLine.VALIDATE("No.", FromSalesLine."No.");
        ToPurchLine.VALIDATE("Variant Code", FromSalesLine."Variant Code");
        ToPurchLine.VALIDATE("Location Code", FromSalesLine."Location Code");
        ToPurchLine.VALIDATE("Unit of Measure Code", FromSalesLine."Unit of Measure Code");
        if (ToPurchLine.Type = ToPurchLine.Type::Item) and (ToPurchLine."No." <> '') then
            ToPurchLine.UpdateUOMQtyPerStockQty();
        ToPurchLine."Expected Receipt Date" := FromSalesLine."Shipment Date";
        ToPurchLine."Bin Code" := FromSalesLine."Bin Code";
        if (FromSalesLine."Document Type" = FromSalesLine."Document Type"::"Return Order") and
           (ToPurchLine."Document Type" = ToPurchLine."Document Type"::"Return Order")
        then
            ToPurchLine.VALIDATE(Quantity, FromSalesLine.Quantity)
        else
            ToPurchLine.VALIDATE(Quantity, FromSalesLine."Outstanding Quantity");
        ToPurchLine.VALIDATE("Return Reason Code", FromSalesLine."Return Reason Code");
        ToPurchLine.VALIDATE("Direct Unit Cost");
        ToPurchLine.Description := FromSalesLine.Description;
        ToPurchLine."Description 2" := FromSalesLine."Description 2";

        OnAfterTransfldsFromSalesToPurchLine(FromSalesLine, ToPurchLine);
    end;

    local procedure DeleteSalesLinesWithNegQty(FromSalesHeader: Record "Sales Header"; OnlyTest: Boolean)
    var
        FromSalesLine: Record "Sales Line";
    begin
        FromSalesLine.SETRANGE("Document Type", FromSalesHeader."Document Type");
        FromSalesLine.SETRANGE("Document No.", FromSalesHeader."No.");
        FromSalesLine.SETFILTER(Quantity, '<0');
        if OnlyTest then begin
            if not FromSalesLine.FIND('-') then
                ERROR(Text008);
            repeat
                FromSalesLine.TESTFIELD("Shipment No.", '');
                FromSalesLine.TESTFIELD("Return Receipt No.", '');
                FromSalesLine.TESTFIELD("Quantity Shipped", 0);
                FromSalesLine.TESTFIELD("Quantity Invoiced", 0);
            until FromSalesLine.NEXT() = 0;
        end else
            FromSalesLine.DELETEALL(true);
    end;

    local procedure DeletePurchLinesWithNegQty(FromPurchHeader: Record "Purchase Header"; OnlyTest: Boolean)
    var
        FromPurchLine: Record "Purchase Line";
    begin
        FromPurchLine.SETRANGE("Document Type", FromPurchHeader."Document Type");
        FromPurchLine.SETRANGE("Document No.", FromPurchHeader."No.");
        FromPurchLine.SETFILTER(Quantity, '<0');
        if OnlyTest then begin
            if not FromPurchLine.FIND('-') then
                ERROR(Text010);
            repeat
                FromPurchLine.TESTFIELD("Receipt No.", '');
                FromPurchLine.TESTFIELD("Return Shipment No.", '');
                FromPurchLine.TESTFIELD("Quantity Received", 0);
                FromPurchLine.TESTFIELD("Quantity Invoiced", 0);
            until FromPurchLine.NEXT() = 0;
        end else
            FromPurchLine.DELETEALL(true);
    end;

    local procedure CopySalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var NextLineNo: Integer; var LinesNotCopied: Integer; RecalculateAmount: Boolean; FromSalesDocType: Option; var CopyPostedDeferralP: Boolean; DocLineNo: Integer): Boolean
    var
        FromSalesLine2: Record "Sales Line";
        RoundingLineInserted: Boolean;
        CopyThisLine: Boolean;
        CheckVATBusGroup: Boolean;
        InvDiscountAmount: Decimal;
    begin
        //BCSYS 21112023
        FromSalesLine2 := FromSalesLine;
        //FIN BCSYS
        CopyThisLine := true;
        OnBeforeCopySalesLine(ToSalesHeader, FromSalesHeader, FromSalesLine, RecalculateLines, CopyThisLine, MoveNegLines);
        if not CopyThisLine then begin
            LinesNotCopied := LinesNotCopied + 1;
            exit(false);
        end;

        CheckSalesRounding(FromSalesLine, RoundingLineInserted);

        if ((ToSalesHeader."Language Code" <> FromSalesHeader."Language Code") or RecalculateLines) and
           (FromSalesLine."Attached to Line No." <> 0) or
           FromSalesLine."Prepayment Line" or RoundingLineInserted
        then
            exit(false);
        ToSalesLine.SetSalesHeader(ToSalesHeader);
        if RecalculateLines and not FromSalesLine."System-Created Entry" then begin
            ToSalesLine.INIT();
            OnAfterInitToSalesLine(ToSalesLine);
        end else begin
            CheckSalesLineIsBlocked(FromSalesLine);
            ToSalesLine := FromSalesLine;
            ToSalesLine."Returns Deferral Start Date" := 0D;
            //BCSYS 14122023 KO Partiel
            //>>BC6 MB 01/07/2021
            //>>BC6 ABJ 12/06/2023
            //ToSalesLine.VALIDATE(Quantity, FromSalesLine.Quantity - FromSalesLine."Quantity Shipped");
            //<<BC6
            //<<BC6
            OnCopySalesLineOnAfterTransferFieldsToSalesLine(ToSalesLine, FromSalesLine);
            if ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Quote, ToSalesHeader."Document Type"::"Blanket Order"] then
                ToSalesLine."Deferral Code" := '';
            if MoveNegLines and (ToSalesLine.Type <> ToSalesLine.Type::" ") then begin
                ToSalesLine.Amount := -ToSalesLine.Amount;
                ToSalesLine."Amount Including VAT" := -ToSalesLine."Amount Including VAT";
            end
        end;

        CheckVATBusGroup := (not RecalculateLines) and (ToSalesLine."No." <> '');
        OnCopySalesLineOnBeforeCheckVATBusGroup(ToSalesLine, CheckVATBusGroup);
        if CheckVATBusGroup then
            ToSalesLine.TESTFIELD("VAT Bus. Posting Group", ToSalesHeader."VAT Bus. Posting Group");

        //BCSYS 18122023
        //NextLineNo := NextLineNo + 10000;
        NextLineNo := FromSalesLine."Line No.";
        //FIN BCSYS 18122023
        ToSalesLine."Document Type" := ToSalesHeader."Document Type";
        ToSalesLine."Document No." := ToSalesHeader."No.";
        ToSalesLine."Line No." := NextLineNo;
        ToSalesLine."Copied From Posted Doc." := FromSalesLine."Copied From Posted Doc.";
        if (ToSalesLine.Type <> ToSalesLine.Type::" ") and
           (ToSalesLine."Document Type" in [ToSalesLine."Document Type"::"Return Order", ToSalesLine."Document Type"::"Credit Memo"])
        then begin
            ToSalesLine."Job Contract Entry No." := 0;
            if (ToSalesLine.Amount = 0) or
               (ToSalesHeader."Prices Including VAT" <> FromSalesHeader."Prices Including VAT") or
               (ToSalesHeader."Currency Factor" <> FromSalesHeader."Currency Factor")
            then begin
                InvDiscountAmount := ToSalesLine."Inv. Discount Amount";
                ToSalesLine.VALIDATE("Line Discount %");
                ToSalesLine.VALIDATE("Inv. Discount Amount", InvDiscountAmount);
            end;
        end;
        ToSalesLine.VALIDATE("Currency Code", FromSalesHeader."Currency Code");

        UpdateSalesLine(
          ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine,
          CopyThisLine, RecalculateAmount, FromSalesDocType, CopyPostedDeferralP);
        ToSalesLine.CheckLocationOnWMS();

        if ExactCostRevMandatory and
           (FromSalesLine.Type = FromSalesLine.Type::Item) and
           (FromSalesLine."Appl.-from Item Entry" <> 0) and
           not MoveNegLines
        then begin
            if RecalculateAmount then begin
                ToSalesLine.VALIDATE("Unit Price", FromSalesLine."Unit Price");
                ToSalesLine.VALIDATE("Line Discount %", FromSalesLine."Line Discount %");
                ToSalesLine.VALIDATE(
                  "Line Discount Amount",
                  ROUND(FromSalesLine."Line Discount Amount", Currency."Amount Rounding Precision"));
                ToSalesLine.VALIDATE(
                  "Inv. Discount Amount",
                  ROUND(FromSalesLine."Inv. Discount Amount", Currency."Amount Rounding Precision"));
            end;
            ToSalesLine.VALIDATE("Appl.-from Item Entry", FromSalesLine."Appl.-from Item Entry");
            if not CreateToHeader then
                if ToSalesLine."Shipment Date" = 0D then
                    InitShipmentDateInLine(ToSalesHeader, ToSalesLine);
        end;


        //  //>>BC6 ABJ 12/06/2023 18122023
        //  IF (ToSalesLine.Type <> ToSalesLine.Type::" ") THEN
        //     ToSalesLine.VALIDATE(Quantity, FromSalesLine.Quantity - FromSalesLine."Quantity Shipped");
        //  //<<BC6
        if MoveNegLines and (ToSalesLine.Type <> ToSalesLine.Type::" ") then begin
            ToSalesLine.VALIDATE(Quantity, -FromSalesLine.Quantity);
            ToSalesLine.VALIDATE("Unit Price", FromSalesLine."Unit Price");
            ToSalesLine.VALIDATE("Line Discount %", FromSalesLine."Line Discount %");
            ToSalesLine."Appl.-to Item Entry" := FromSalesLine."Appl.-to Item Entry";
            ToSalesLine."Appl.-from Item Entry" := FromSalesLine."Appl.-from Item Entry";
            ToSalesLine."Job No." := FromSalesLine."Job No.";
            ToSalesLine."Job Task No." := FromSalesLine."Job Task No.";
            ToSalesLine."Job Contract Entry No." := FromSalesLine."Job Contract Entry No.";
        end;

        if CopyJobData then
            CopySalesJobFields(ToSalesLine, ToSalesHeader, FromSalesLine);

        CopySalesLineExtText(ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine, DocLineNo, NextLineNo);

        if not RecalculateLines then begin
            ToSalesLine."Dimension Set ID" := FromSalesLine."Dimension Set ID";
            ToSalesLine."Shortcut Dimension 1 Code" := FromSalesLine."Shortcut Dimension 1 Code";
            ToSalesLine."Shortcut Dimension 2 Code" := FromSalesLine."Shortcut Dimension 2 Code";
            OnCopySalesLineOnAfterSetDimensions(ToSalesLine, FromSalesLine);
        end;

        if CopyThisLine then begin
            OnBeforeInsertToSalesLine(
              ToSalesLine, FromSalesLine, FromSalesDocType, RecalculateLines, ToSalesHeader, DocLineNo, NextLineNo);
            ToSalesLine.INSERT();

            //BCSYS 21112023
            if FromSalesLine.Quantity <> 0 then begin
                FromSalesLine.VALIDATE(Quantity, FromSalesLine2."Quantity Shipped");
                FromSalesLine.VALIDATE("Unit Price", FromSalesLine2."Unit Price");
                FromSalesLine.VALIDATE(FromSalesLine."Line Discount %", FromSalesLine2."Line Discount %");
                FromSalesLine.MODIFY();
            end;
            //FIN BCSYS

            HandleAsmAttachedToSalesLine(ToSalesLine);
            if ToSalesLine.Reserve = ToSalesLine.Reserve::Always then
                ToSalesLine.AutoReserve();
            OnAfterInsertToSalesLine(ToSalesLine, FromSalesLine, RecalculateLines);
        end else
            LinesNotCopied := LinesNotCopied + 1;

        exit(CopyThisLine);
    end;

    local procedure UpdateSalesHeaderWhenCopyFromSalesHeader(var SalesHeader: Record "Sales Header"; OriginalSalesHeader: Record "Sales Header"; FromDocType: Option)
    begin
        ClearSalesLastNoSFields(SalesHeader);
        SalesHeader.Status := SalesHeader.Status::Open;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            SalesHeader."Prepayment %" := 0;
        if FromDocType = SalesDocType::"Return Order".AsInteger() then begin
            SalesHeader.CopySellToAddressToShipToAddress();
            SalesHeader.VALIDATE("Ship-to Code");
        end;
        if FromDocType in [SalesDocType::Quote.AsInteger(), SalesDocType::"Blanket Order".AsInteger()] then
            if OriginalSalesHeader."Posting Date" = 0D then
                SalesHeader."Posting Date" := WORKDATE()
            else
                SalesHeader."Posting Date" := OriginalSalesHeader."Posting Date";
        //>>BC6 SBE 27/01/2022
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            SalesHeader.VALIDATE("Posting Date", TODAY);
            SalesHeader.VALIDATE("Shipment Date", TODAY);
            SalesHeader.VALIDATE("Order Date", TODAY);
        end;
        //<<BC6 SBE 27/01/2022
    end;

    local procedure UpdateSalesHeaderWhenCopyFromSalesHeaderArchive(var SalesHeader: Record "Sales Header")
    begin
        ClearSalesLastNoSFields(SalesHeader);
        SalesHeader.Status := SalesHeader.Status::Open;
    end;

    local procedure ClearSalesLastNoSFields(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."Last Shipping No." := '';
        SalesHeader."Last Posting No." := '';
        SalesHeader."Last Prepayment No." := '';
        SalesHeader."Last Prepmt. Cr. Memo No." := '';
        SalesHeader."Last Return Receipt No." := '';
    end;

    local procedure UpdateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var CopyThisLine: Boolean; RecalculateAmount: Boolean; FromSalesDocType: Option; var CopyPostedDeferralP: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        DeferralDocType: Integer;
    begin
        OnBeforeUpdateSalesLine(
          ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine,
          CopyThisLine, RecalculateAmount, FromSalesDocType, CopyPostedDeferralP);

        CopyPostedDeferralP := false;
        DeferralDocType := DeferralTypeForSalesDoc(FromSalesDocType);
        if RecalculateLines and not FromSalesLine."System-Created Entry" then begin
            RecalculateSalesLine(ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine, CopyThisLine);
            if IsDeferralToBeCopied(DeferralDocType, ToSalesLine."Document Type".AsInteger(), FromSalesDocType) then
                ToSalesLine.VALIDATE("Deferral Code", FromSalesLine."Deferral Code");
            OnUpdateSalesLineOnAfterRecalculateSalesLine(ToSalesLine, FromSalesLine);
        end else begin

            //>>BC6 SBE 27/01/2022
            TempRecGTempSalesLine.DELETEALL();
            TempRecGTempSalesLine := FromSalesLine;
            //<<BC6 SBE 27/01/2022

            SetDefaultValuesToSalesLine(ToSalesLine, ToSalesHeader, FromSalesLine."VAT Difference");
            if IsDeferralToBeCopied(DeferralDocType, ToSalesLine."Document Type".AsInteger(), FromSalesDocType) then
                if IsDeferralPosted(DeferralDocType, FromSalesDocType) then
                    CopyPostedDeferralP := true
                else
                    ToSalesLine."Returns Deferral Start Date" :=
                      CopyDeferrals(DeferralDocType, FromSalesLine."Document Type".AsInteger(), FromSalesLine."Document No.",
                        FromSalesLine."Line No.", ToSalesLine."Document Type".AsInteger(), ToSalesLine."Document No.", ToSalesLine."Line No.")
            else
                if IsDeferralToBeDefaulted(DeferralDocType, ToSalesLine."Document Type".AsInteger(), FromSalesDocType) then
                    InitSalesDeferralCode(ToSalesLine);

            if ToSalesLine."Document Type" <> ToSalesLine."Document Type"::Order then begin
                ToSalesLine."Drop Shipment" := false;
                ToSalesLine."Special Order" := false;
            end;

            //>>BC6 SBE 27/01/2022
            //IF RecalculateAmount AND (FromSalesLine."Appl.-from Item Entry" = 0) THEN BEGIN
            if (ToSalesLine."No." <> '') and (ToSalesLine.Quantity <> 0) then begin
                //<<BC6 SBE 27/01/2022
                if (ToSalesLine.Type <> ToSalesLine.Type::" ") and (ToSalesLine."No." <> '') then begin
                    ToSalesLine.VALIDATE("Line Discount %", FromSalesLine."Line Discount %");
                    ToSalesLine.VALIDATE(
                      "Inv. Discount Amount", ROUND(FromSalesLine."Inv. Discount Amount", Currency."Amount Rounding Precision"));
                end;
                ToSalesLine.VALIDATE("Unit Cost (LCY)", FromSalesLine."Unit Cost (LCY)");
            end;
            if VATPostingSetup.GET(ToSalesLine."VAT Bus. Posting Group", ToSalesLine."VAT Prod. Posting Group") then
                ToSalesLine."VAT Identifier" := VATPostingSetup."VAT Identifier";

            ToSalesLine.UpdateWithWarehouseShip();
            if (ToSalesLine.Type = ToSalesLine.Type::Item) and (ToSalesLine."No." <> '') then begin
                GetItem(ToSalesLine."No.");
                if (Item."Costing Method" = Item."Costing Method"::Standard) and not ToSalesLine.IsShipment() then
                    ToSalesLine.GetUnitCost();

                if Item.Reserve = Item.Reserve::Optional then
                    ToSalesLine.Reserve := ToSalesHeader.Reserve
                else
                    ToSalesLine.Reserve := Item.Reserve;
                if ToSalesLine.Reserve = ToSalesLine.Reserve::Always then
                    InitShipmentDateInLine(ToSalesHeader, ToSalesLine);
            end;
        end;

        OnAfterUpdateSalesLine(
          ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine,
          CopyThisLine, RecalculateAmount, FromSalesDocType, CopyPostedDeferralP);
    end;

    local procedure RecalculateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var CopyThisLine: Boolean)
    var
        GLAcc: Record "G/L Account";
    begin
        OnBeforeRecalculateSalesLine(ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine, CopyThisLine);

        ToSalesLine.VALIDATE(Type, FromSalesLine.Type);
        ToSalesLine.Description := FromSalesLine.Description;
        ToSalesLine.VALIDATE("Description 2", FromSalesLine."Description 2");
        OnUpdateSalesLine(ToSalesLine, FromSalesLine);

        if (FromSalesLine.Type.AsInteger() <> 0) and (FromSalesLine."No." <> '') then begin
            if ToSalesLine.Type = ToSalesLine.Type::"G/L Account" then begin
                ToSalesLine."No." := FromSalesLine."No.";
                GLAcc.GET(FromSalesLine."No.");
                CopyThisLine := GLAcc."Direct Posting";
                if CopyThisLine then
                    ToSalesLine.VALIDATE("No.", FromSalesLine."No.");
            end else
                ToSalesLine.VALIDATE("No.", FromSalesLine."No.");
            ToSalesLine.VALIDATE("Variant Code", FromSalesLine."Variant Code");
            ToSalesLine.VALIDATE("Location Code", FromSalesLine."Location Code");
            ToSalesLine.VALIDATE("Unit of Measure", FromSalesLine."Unit of Measure");
            ToSalesLine.VALIDATE("Unit of Measure Code", FromSalesLine."Unit of Measure Code");
            //>>BC6 SBE 27/01/2022
            //ToSalesLine.VALIDATE(Quantity,FromSalesLine.Quantity);
            ToSalesLine.VALIDATE(Quantity, FromSalesLine."Outstanding Quantity");
            //<<BC6 SBE 27/01/2022

            if not (FromSalesLine.Type in [FromSalesLine.Type::Item, FromSalesLine.Type::Resource]) then begin
                if (FromSalesHeader."Currency Code" <> ToSalesHeader."Currency Code") or
                   (FromSalesHeader."Prices Including VAT" <> ToSalesHeader."Prices Including VAT")
                then begin
                    ToSalesLine."Unit Price" := 0;
                    ToSalesLine."Line Discount %" := 0;
                end else begin
                    ToSalesLine.VALIDATE("Unit Price", FromSalesLine."Unit Price");
                    ToSalesLine.VALIDATE("Line Discount %", FromSalesLine."Line Discount %");
                end;
                if ToSalesLine.Quantity <> 0 then
                    ToSalesLine.VALIDATE("Line Discount Amount", FromSalesLine."Line Discount Amount");
            end;
            ToSalesLine.VALIDATE("Work Type Code", FromSalesLine."Work Type Code");
            if (ToSalesLine."Document Type" = ToSalesLine."Document Type"::Order) and
               (FromSalesLine."Purchasing Code" <> '')
            then
                ToSalesLine.VALIDATE("Purchasing Code", FromSalesLine."Purchasing Code");
        end;
        if (FromSalesLine.Type = FromSalesLine.Type::" ") and (FromSalesLine."No." <> '') then
            ToSalesLine.VALIDATE("No.", FromSalesLine."No.");

        OnAfterRecalculateSalesLine(ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine, CopyThisLine);
    end;

    local procedure HandleAsmAttachedToSalesLine(var ToSalesLine: Record "Sales Line")
    var
        ItemL: Record Item;
    begin
        if ToSalesLine.Type <> ToSalesLine.Type::Item then
            exit;
        if not (ToSalesLine."Document Type" in [ToSalesLine."Document Type"::Quote, ToSalesLine."Document Type"::Order, ToSalesLine."Document Type"::"Blanket Order"]) then
            exit;
        if AsmHdrExistsForFromDocLine then begin
            ToSalesLine."Qty. to Assemble to Order" := QtyToAsmToOrder;
            ToSalesLine."Qty. to Asm. to Order (Base)" := QtyToAsmToOrderBase;
            ToSalesLine.MODIFY();
            CopyAsmOrderToAsmOrder(TempAsmHeader, TempAsmLine, ToSalesLine, GetAsmOrderType(ToSalesLine."Document Type".AsInteger()), '', true);
        end else begin
            ItemL.GET(ToSalesLine."No.");
            if (ItemL."Assembly Policy" = ItemL."Assembly Policy"::"Assemble-to-Order") and
               (ItemL."Replenishment System" = ItemL."Replenishment System"::Assembly)
            then begin
                ToSalesLine.VALIDATE("Qty. to Assemble to Order", ToSalesLine.Quantity);
                ToSalesLine.MODIFY();
            end;
        end;
    end;

    local procedure CopyPurchLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; var FromPurchHeader: Record "Purchase Header"; var FromPurchLine: Record "Purchase Line"; var NextLineNo: Integer; var LinesNotCopied: Integer; RecalculateAmount: Boolean; FromPurchDocType: Option; var CopyPostedDeferralP: Boolean; DocLineNo: Integer): Boolean
    var
        RoundingLineInserted: Boolean;
        CopyThisLine: Boolean;
        CheckVATBusGroup: Boolean;
        InvDiscountAmount: Decimal;
    begin
        CopyThisLine := true;
        OnBeforeCopyPurchLine(
          ToPurchHeader, FromPurchHeader, FromPurchLine, RecalculateLines, CopyThisLine, ToPurchLine, MoveNegLines,
          RoundingLineInserted);
        if not CopyThisLine then begin
            LinesNotCopied := LinesNotCopied + 1;
            exit(false);
        end;

        CheckPurchRounding(FromPurchLine, RoundingLineInserted);

        if ((ToPurchHeader."Language Code" <> FromPurchHeader."Language Code") or RecalculateLines) and
           (FromPurchLine."Attached to Line No." <> 0) or
           FromPurchLine."Prepayment Line" or RoundingLineInserted
        then
            exit(false);

        if RecalculateLines and not FromPurchLine."System-Created Entry" then begin
            ToPurchLine.INIT();
            OnAfterInitToPurchLine(ToPurchLine);
        end else begin
            CheckPurchaseLineIsBlocked(FromPurchLine);
            ToPurchLine := FromPurchLine;
            ToPurchLine."Returns Deferral Start Date" := 0D;
            if ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::Quote, ToPurchHeader."Document Type"::"Blanket Order"] then
                ToPurchLine."Deferral Code" := '';
            if MoveNegLines and (ToPurchLine.Type <> ToPurchLine.Type::" ") then begin
                ToPurchLine.Amount := -ToPurchLine.Amount;
                ToPurchLine."Amount Including VAT" := -ToPurchLine."Amount Including VAT";
            end
        end;

        CheckVATBusGroup := (not RecalculateLines) and (ToPurchLine."No." <> '');
        OnCopyPurchLineOnBeforeCheckVATBusGroup(ToPurchLine, CheckVATBusGroup);
        if CheckVATBusGroup then
            ToPurchLine.TESTFIELD("VAT Bus. Posting Group", ToPurchHeader."VAT Bus. Posting Group");

        NextLineNo := NextLineNo + 10000;
        ToPurchLine."Document Type" := ToPurchHeader."Document Type";
        ToPurchLine."Document No." := ToPurchHeader."No.";
        ToPurchLine."Line No." := NextLineNo;
        ToPurchLine."Copied From Posted Doc." := FromPurchLine."Copied From Posted Doc.";
        ToPurchLine.VALIDATE("Currency Code", FromPurchHeader."Currency Code");
        if (ToPurchLine.Type <> ToPurchLine.Type::" ") and
           ((ToPurchLine.Amount = 0) or
            (ToPurchHeader."Prices Including VAT" <> FromPurchHeader."Prices Including VAT") or
            (ToPurchHeader."Currency Factor" <> FromPurchHeader."Currency Factor"))
        then begin
            InvDiscountAmount := ToPurchLine."Inv. Discount Amount";
            ToPurchLine.VALIDATE("Line Discount %");
            ToPurchLine.VALIDATE("Inv. Discount Amount", InvDiscountAmount);
        end;

        UpdatePurchLine(
          ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine,
          CopyThisLine, RecalculateAmount, FromPurchDocType, CopyPostedDeferralP);

        ToPurchLine.CheckLocationOnWMS();

        if ExactCostRevMandatory and
           (FromPurchLine.Type = FromPurchLine.Type::Item) and
           (FromPurchLine."Appl.-to Item Entry" <> 0) and
           not MoveNegLines
        then begin
            if RecalculateAmount then begin
                ToPurchLine.VALIDATE("Direct Unit Cost", FromPurchLine."Direct Unit Cost");
                ToPurchLine.VALIDATE("Line Discount %", FromPurchLine."Line Discount %");
                ToPurchLine.VALIDATE(
                  "Line Discount Amount",
                  ROUND(FromPurchLine."Line Discount Amount", Currency."Amount Rounding Precision"));
                ToPurchLine.VALIDATE(
                  "Inv. Discount Amount",
                  ROUND(FromPurchLine."Inv. Discount Amount", Currency."Amount Rounding Precision"));
            end;
            ToPurchLine.VALIDATE("Appl.-to Item Entry", FromPurchLine."Appl.-to Item Entry");
            if not CreateToHeader then
                if ToPurchLine."Expected Receipt Date" = 0D then
                    if ToPurchHeader."Expected Receipt Date" <> 0D then
                        ToPurchLine."Expected Receipt Date" := ToPurchHeader."Expected Receipt Date"
                    else
                        ToPurchLine."Expected Receipt Date" := WORKDATE();
        end;

        if MoveNegLines and (ToPurchLine.Type <> ToPurchLine.Type::" ") then begin
            ToPurchLine.VALIDATE(Quantity, -FromPurchLine.Quantity);
            ToPurchLine."Appl.-to Item Entry" := FromPurchLine."Appl.-to Item Entry"
        end;

        CopyPurchLineExtText(ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine, DocLineNo, NextLineNo);

        if FromPurchLine."Job No." <> '' then
            CopyPurchaseJobFields(ToPurchLine, FromPurchLine);

        if not RecalculateLines then begin
            ToPurchLine."Dimension Set ID" := FromPurchLine."Dimension Set ID";
            ToPurchLine."Shortcut Dimension 1 Code" := FromPurchLine."Shortcut Dimension 1 Code";
            ToPurchLine."Shortcut Dimension 2 Code" := FromPurchLine."Shortcut Dimension 2 Code";
            OnCopyPurchLineOnAfterSetDimensions(ToPurchLine, FromPurchLine);
        end;

        if CopyThisLine then begin
            OnBeforeInsertToPurchLine(ToPurchLine, FromPurchLine, FromPurchDocType, RecalculateLines, ToPurchHeader);
            ToPurchLine.INSERT();
            OnAfterInsertToPurchLine(ToPurchLine, FromPurchLine, RecalculateLines);
        end else
            LinesNotCopied := LinesNotCopied + 1;

        exit(CopyThisLine);
    end;

    local procedure UpdatePurchHeaderWhenCopyFromPurchHeader(var PurchaseHeader: Record "Purchase Header"; OriginalPurchaseHeader: Record "Purchase Header"; FromDocType: Option)
    begin
        ClearPurchLastNoSFields(PurchaseHeader);
        PurchaseHeader.Receive := false;
        PurchaseHeader.Status := PurchaseHeader.Status::Open;
        PurchaseHeader."IC Status" := PurchaseHeader."IC Status"::New;
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            PurchaseHeader."Prepayment %" := 0;
        if FromDocType in [PurchDocType::Quote.AsInteger(), PurchDocType::"Blanket Order".AsInteger()] then
            if OriginalPurchaseHeader."Posting Date" = 0D then
                PurchaseHeader."Posting Date" := WORKDATE()
            else
                PurchaseHeader."Posting Date" := OriginalPurchaseHeader."Posting Date";
    end;

    local procedure UpdatePurchHeaderWhenCopyFromPurchHeaderArchive(var PurchaseHeader: Record "Purchase Header")
    begin
        ClearPurchLastNoSFields(PurchaseHeader);
        PurchaseHeader.Status := PurchaseHeader.Status::Open;
    end;

    local procedure ClearPurchLastNoSFields(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader."Last Receiving No." := '';
        PurchaseHeader."Last Posting No." := '';
        PurchaseHeader."Last Prepayment No." := '';
        PurchaseHeader."Last Prepmt. Cr. Memo No." := '';
        PurchaseHeader."Last Return Shipment No." := '';
    end;

    local procedure UpdatePurchLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; var FromPurchHeader: Record "Purchase Header"; var FromPurchLine: Record "Purchase Line"; var CopyThisLine: Boolean; RecalculateAmount: Boolean; FromPurchDocType: Enum "Purchase Document Type From"; var CopyPostedDeferralP: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        DeferralDocType: Integer;
    begin
        OnBeforeUpdatePurchLine(
          ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine,
          CopyThisLine, RecalculateAmount, FromPurchDocType.AsInteger(), CopyPostedDeferralP);

        CopyPostedDeferralP := false;
        DeferralDocType := DeferralTypeForPurchDoc(FromPurchDocType.AsInteger());
        if RecalculateLines and not FromPurchLine."System-Created Entry" then begin
            RecalculatePurchLine(ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine, CopyThisLine);
            if IsDeferralToBeCopied(DeferralDocType, ToPurchLine."Document Type".AsInteger(), FromPurchDocType.AsInteger()) then
                ToPurchLine.VALIDATE("Deferral Code", FromPurchLine."Deferral Code");
        end else begin
            SetDefaultValuesToPurchLine(ToPurchLine, ToPurchHeader, FromPurchLine."VAT Difference");
            if IsDeferralToBeCopied(DeferralDocType, ToPurchLine."Document Type".AsInteger(), FromPurchDocType.AsInteger()) then
                if IsDeferralPosted(DeferralDocType, FromPurchDocType.AsInteger()) then
                    CopyPostedDeferralP := true
                else
                    ToPurchLine."Returns Deferral Start Date" :=
                      CopyDeferrals(DeferralDocType, FromPurchLine."Document Type".AsInteger(), FromPurchLine."Document No.",
                        FromPurchLine."Line No.", ToPurchLine."Document Type".AsInteger(), ToPurchLine."Document No.", ToPurchLine."Line No.")
            else
                if IsDeferralToBeDefaulted(DeferralDocType, ToPurchLine."Document Type".AsInteger(), FromPurchDocType.AsInteger()) then
                    InitPurchDeferralCode(ToPurchLine);

            if FromPurchLine."Drop Shipment" or FromPurchLine."Special Order" then
                ToPurchLine."Purchasing Code" := '';
            ToPurchLine."Drop Shipment" := false;
            ToPurchLine."Special Order" := false;
            if VATPostingSetup.GET(ToPurchLine."VAT Bus. Posting Group", ToPurchLine."VAT Prod. Posting Group") then
                ToPurchLine."VAT Identifier" := VATPostingSetup."VAT Identifier";

            OnBeforeCopyPurchLines(ToPurchLine);

            CopyDocLines(RecalculateAmount, ToPurchLine, FromPurchLine);

            ToPurchLine.UpdateWithWarehouseReceive();
            ToPurchLine."Pay-to Vendor No." := ToPurchHeader."Pay-to Vendor No.";
        end;
        ToPurchLine.VALIDATE("Order No.", FromPurchLine."Order No.");
        ToPurchLine.VALIDATE("Order Line No.", FromPurchLine."Order Line No.");

        OnAfterUpdatePurchLine(
          ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine,
          CopyThisLine, RecalculateAmount, FromPurchDocType.AsInteger(), CopyPostedDeferralP);
    end;

    local procedure RecalculatePurchLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; var FromPurchHeader: Record "Purchase Header"; var FromPurchLine: Record "Purchase Line"; var CopyThisLine: Boolean)
    var
        GLAcc: Record "G/L Account";
    begin
        ToPurchLine.VALIDATE(Type, FromPurchLine.Type);
        ToPurchLine.Description := FromPurchLine.Description;
        ToPurchLine.VALIDATE("Description 2", FromPurchLine."Description 2");
        OnUpdatePurchLine(ToPurchLine, FromPurchLine);

        if (FromPurchLine.Type.AsInteger() <> 0) and (FromPurchLine."No." <> '') then begin
            if ToPurchLine.Type = ToPurchLine.Type::"G/L Account" then begin
                ToPurchLine."No." := FromPurchLine."No.";
                GLAcc.GET(FromPurchLine."No.");
                CopyThisLine := GLAcc."Direct Posting";
                if CopyThisLine then
                    ToPurchLine.VALIDATE("No.", FromPurchLine."No.");
            end else
                ToPurchLine.VALIDATE("No.", FromPurchLine."No.");
            ToPurchLine.VALIDATE("Variant Code", FromPurchLine."Variant Code");
            ToPurchLine.VALIDATE("Location Code", FromPurchLine."Location Code");
            ToPurchLine.VALIDATE("Unit of Measure", FromPurchLine."Unit of Measure");
            ToPurchLine.VALIDATE("Unit of Measure Code", FromPurchLine."Unit of Measure Code");
            ToPurchLine.VALIDATE(Quantity, FromPurchLine.Quantity);
            if FromPurchLine.Type <> FromPurchLine.Type::Item then begin
                ToPurchHeader.TESTFIELD("Currency Code", FromPurchHeader."Currency Code");
                ToPurchLine.VALIDATE("Direct Unit Cost", FromPurchLine."Direct Unit Cost");
                ToPurchLine.VALIDATE("Line Discount %", FromPurchLine."Line Discount %");
                if ToPurchLine.Quantity <> 0 then
                    ToPurchLine.VALIDATE("Line Discount Amount", FromPurchLine."Line Discount Amount");
            end;
            if (ToPurchLine."Document Type" = ToPurchLine."Document Type"::Order) and
               (FromPurchLine."Purchasing Code" <> '') and not FromPurchLine."Drop Shipment" and not FromPurchLine."Special Order"
            then
                ToPurchLine.VALIDATE("Purchasing Code", FromPurchLine."Purchasing Code");
        end;
        if (FromPurchLine.Type = FromPurchLine.Type::" ") and (FromPurchLine."No." <> '') then
            ToPurchLine.VALIDATE("No.", FromPurchLine."No.");

        OnAfterRecalculatePurchLine(ToPurchLine);
    end;

    local procedure CheckPurchRounding(FromPurchLine: Record "Purchase Line"; var RoundingLineInserted: Boolean)
    var
        PurchSetup: Record "Purchases & Payables Setup";
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if (FromPurchLine.Type <> FromPurchLine.Type::"G/L Account") or (FromPurchLine."No." = '') then
            exit;
        if not FromPurchLine."System-Created Entry" then
            exit;

        PurchSetup.GET();
        if PurchSetup."Invoice Rounding" then begin
            Vendor.GET(FromPurchLine."Pay-to Vendor No.");
            VendorPostingGroup.GET(Vendor."Vendor Posting Group");
            RoundingLineInserted := FromPurchLine."No." = VendorPostingGroup.GetInvRoundingAccount();
        end;
    end;

    local procedure CheckSalesRounding(FromSalesLine: Record "Sales Line"; var RoundingLineInserted: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if (FromSalesLine.Type <> FromSalesLine.Type::"G/L Account") or (FromSalesLine."No." = '') then
            exit;
        if not FromSalesLine."System-Created Entry" then
            exit;

        SalesSetup.GET();
        if SalesSetup."Invoice Rounding" then begin
            Customer.GET(FromSalesLine."Bill-to Customer No.");
            CustomerPostingGroup.GET(Customer."Customer Posting Group");
            RoundingLineInserted := FromSalesLine."No." = CustomerPostingGroup.GetInvRoundingAccount();
        end;
    end;

    local procedure CopyFromSalesDocAssgntToLine(var ToSalesLine: Record "Sales Line"; FromDocType: Option; FromDocNo: Code[20]; FromLineNo: Integer; var ItemChargeAssgntNextLineNo: Integer)
    var
        FromItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        ToItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        ItemChargeAssgntSales: Codeunit "Item Charge Assgnt. (Sales)";
        IsHandled: Boolean;
    begin
        FromItemChargeAssgntSales.RESET();
        FromItemChargeAssgntSales.SETRANGE("Document Type", FromDocType);
        FromItemChargeAssgntSales.SETRANGE("Document No.", FromDocNo);
        FromItemChargeAssgntSales.SETRANGE("Document Line No.", FromLineNo);
        FromItemChargeAssgntSales.SETFILTER("Applies-to Doc. Type", '<>%1', FromDocType);
        OnCopyFromSalesDocAssgntToLineOnAfterSetFilters(FromItemChargeAssgntSales, RecalculateLines);
        if FromItemChargeAssgntSales.FIND('-') then
            repeat
                ToItemChargeAssgntSales.COPY(FromItemChargeAssgntSales);
                ToItemChargeAssgntSales."Document Type" := ToSalesLine."Document Type";
                ToItemChargeAssgntSales."Document No." := ToSalesLine."Document No.";
                ToItemChargeAssgntSales."Document Line No." := ToSalesLine."Line No.";
                IsHandled := false;
                OnCopyFromSalesDocAssgntToLineOnBeforeInsert(FromItemChargeAssgntSales, RecalculateLines, IsHandled);
                if not IsHandled then
                    ItemChargeAssgntSales.InsertItemChargeAssignment(
                      ToItemChargeAssgntSales, ToItemChargeAssgntSales."Applies-to Doc. Type",
                      ToItemChargeAssgntSales."Applies-to Doc. No.", ToItemChargeAssgntSales."Applies-to Doc. Line No.",
                      ToItemChargeAssgntSales."Item No.", ToItemChargeAssgntSales.Description, ItemChargeAssgntNextLineNo);
            until FromItemChargeAssgntSales.NEXT() = 0;

        OnAfterCopyFromSalesDocAssgntToLine(ToSalesLine, RecalculateLines);
    end;

    local procedure CopyFromPurchDocAssgntToLine(var ToPurchLine: Record "Purchase Line"; FromDocType: Option; FromDocNo: Code[20]; FromLineNo: Integer; var ItemChargeAssgntNextLineNo: Integer)
    var
        FromItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        ToItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        ItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
        IsHandled: Boolean;
    begin
        FromItemChargeAssgntPurch.RESET();
        FromItemChargeAssgntPurch.SETRANGE("Document Type", FromDocType);
        FromItemChargeAssgntPurch.SETRANGE("Document No.", FromDocNo);
        FromItemChargeAssgntPurch.SETRANGE("Document Line No.", FromLineNo);
        FromItemChargeAssgntPurch.SETFILTER("Applies-to Doc. Type", '<>%1', FromDocType);
        OnCopyFromPurchDocAssgntToLineOnAfterSetFilters(FromItemChargeAssgntPurch, RecalculateLines);
        if FromItemChargeAssgntPurch.FIND('-') then
            repeat
                ToItemChargeAssgntPurch.COPY(FromItemChargeAssgntPurch);
                ToItemChargeAssgntPurch."Document Type" := ToPurchLine."Document Type";
                ToItemChargeAssgntPurch."Document No." := ToPurchLine."Document No.";
                ToItemChargeAssgntPurch."Document Line No." := ToPurchLine."Line No.";
                IsHandled := false;
                OnCopyFromPurchDocAssgntToLineOnBeforeInsert(FromItemChargeAssgntPurch, RecalculateLines, IsHandled);
                if not IsHandled then
                    ItemChargeAssgntPurch.InsertItemChargeAssignment(
                      ToItemChargeAssgntPurch, ToItemChargeAssgntPurch."Applies-to Doc. Type",
                      ToItemChargeAssgntPurch."Applies-to Doc. No.", ToItemChargeAssgntPurch."Applies-to Doc. Line No.",
                      ToItemChargeAssgntPurch."Item No.", ToItemChargeAssgntPurch.Description, ItemChargeAssgntNextLineNo);
            until FromItemChargeAssgntPurch.NEXT() = 0;

        OnAfterCopyFromPurchDocAssgntToLine(ToPurchLine, RecalculateLines);
    end;

    local procedure CopyFromPurchLineItemChargeAssign(FromPurchLine: Record "Purchase Line"; ToPurchLine: Record "Purchase Line"; FromPurchHeader: Record "Purchase Header"; var ItemChargeAssgntNextLineNo: Integer)
    var
        TempToItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary;
        ToItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemL: Record Item;
        CurrencyL: Record Currency;
        ItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
        CurrencyFactor: Decimal;
        QtyToAssign: Decimal;
        SumQtyToAssign: Decimal;
        RemainingQty: Decimal;
    begin
        if FromPurchLine."Document Type" = FromPurchLine."Document Type"::"Credit Memo" then
            ValueEntry.SETRANGE("Document Type", ValueEntry."Document Type"::"Purchase Credit Memo")
        else
            ValueEntry.SETRANGE("Document Type", ValueEntry."Document Type"::"Purchase Invoice");

        ValueEntry.SETRANGE("Document No.", FromPurchLine."Document No.");
        ValueEntry.SETRANGE("Document Line No.", FromPurchLine."Line No.");
        ValueEntry.SETRANGE("Item Charge No.", FromPurchLine."No.");
        ToItemChargeAssignmentPurch."Document Type" := ToPurchLine."Document Type";
        ToItemChargeAssignmentPurch."Document No." := ToPurchLine."Document No.";
        ToItemChargeAssignmentPurch."Document Line No." := ToPurchLine."Line No.";
        ToItemChargeAssignmentPurch."Item Charge No." := FromPurchLine."No.";
        ToItemChargeAssignmentPurch."Unit Cost" := FromPurchLine."Unit Cost";

        if ValueEntry.FINDSET() then begin
            repeat
                if ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.") then
                    if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Receipt" then begin
                        ItemL.GET(ItemLedgerEntry."Item No.");
                        CurrencyFactor := FromPurchHeader."Currency Factor";

                        if not CurrencyL.GET(FromPurchHeader."Currency Code") then begin
                            CurrencyFactor := 1;
                            CurrencyL.InitRoundingPrecision();
                        end;

                        if ToPurchLine."Unit Cost" = 0 then
                            QtyToAssign := 0
                        else
                            QtyToAssign := ValueEntry."Cost Amount (Actual)" * CurrencyFactor / ToPurchLine."Unit Cost";
                        SumQtyToAssign += QtyToAssign;

                        ItemChargeAssgntPurch.InsertItemChargeAssignmentWithValuesTo(
                          ToItemChargeAssignmentPurch, ToItemChargeAssignmentPurch."Applies-to Doc. Type"::Receipt,
                          ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.", ItemLedgerEntry."Item No.", ItemL.Description,
                          QtyToAssign, 0, ItemChargeAssgntNextLineNo, TempToItemChargeAssignmentPurch);
                    end;
            until ValueEntry.NEXT() = 0;
            ItemChargeAssgntPurch.Summarize(TempToItemChargeAssignmentPurch, ToItemChargeAssignmentPurch);

            // Use 2 passes to correct rounding issues
            ToItemChargeAssignmentPurch.SETRANGE("Document Type", ToPurchLine."Document Type");
            ToItemChargeAssignmentPurch.SETRANGE("Document No.", ToPurchLine."Document No.");
            ToItemChargeAssignmentPurch.SETRANGE("Document Line No.", ToPurchLine."Line No.");
            if ToItemChargeAssignmentPurch.FINDSET(true) then begin
                RemainingQty := (FromPurchLine.Quantity - SumQtyToAssign) / ValueEntry.COUNT;
                SumQtyToAssign := 0;
                repeat
                    AddRemainingQtyToPurchItemCharge(ToItemChargeAssignmentPurch, RemainingQty);
                    SumQtyToAssign += ToItemChargeAssignmentPurch."Qty. to Assign";
                until ToItemChargeAssignmentPurch.NEXT() = 0;

                RemainingQty := FromPurchLine.Quantity - SumQtyToAssign;
                if RemainingQty <> 0 then
                    AddRemainingQtyToPurchItemCharge(ToItemChargeAssignmentPurch, RemainingQty);
            end;
        end;
    end;

    local procedure CopyFromSalesLineItemChargeAssign(FromSalesLine: Record "Sales Line"; ToSalesLine: Record "Sales Line"; FromSalesHeader: Record "Sales Header"; var ItemChargeAssgntNextLineNo: Integer)
    var
        ValueEntry: Record "Value Entry";
        CurrencyL: Record Currency;
        TempToItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)" temporary;
        ToItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemL: Record Item;
        ItemChargeAssgntSales: Codeunit "Item Charge Assgnt. (Sales)";
        CurrencyFactor: Decimal;
        QtyToAssign: Decimal;
        SumQtyToAssign: Decimal;
        RemainingQty: Decimal;
    begin
        if FromSalesLine."Document Type" = FromSalesLine."Document Type"::"Credit Memo" then
            ValueEntry.SETRANGE("Document Type", ValueEntry."Document Type"::"Sales Credit Memo")
        else
            ValueEntry.SETRANGE("Document Type", ValueEntry."Document Type"::"Sales Invoice");

        ValueEntry.SETRANGE("Document No.", FromSalesLine."Document No.");
        ValueEntry.SETRANGE("Document Line No.", FromSalesLine."Line No.");
        ValueEntry.SETRANGE("Item Charge No.", FromSalesLine."No.");
        ToItemChargeAssignmentSales."Document Type" := ToSalesLine."Document Type";
        ToItemChargeAssignmentSales."Document No." := ToSalesLine."Document No.";
        ToItemChargeAssignmentSales."Document Line No." := ToSalesLine."Line No.";
        ToItemChargeAssignmentSales."Item Charge No." := FromSalesLine."No.";
        ToItemChargeAssignmentSales."Unit Cost" := FromSalesLine."Unit Price";

        if ValueEntry.FINDSET() then begin
            repeat
                if ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.") then
                    if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then begin
                        ItemL.GET(ItemLedgerEntry."Item No.");
                        CurrencyFactor := FromSalesHeader."Currency Factor";

                        if not CurrencyL.GET(FromSalesHeader."Currency Code") then begin
                            CurrencyFactor := 1;
                            CurrencyL.InitRoundingPrecision();
                        end;

                        QtyToAssign := ValueEntry."Cost Amount (Actual)" * CurrencyFactor / ToSalesLine."Unit Price";
                        SumQtyToAssign += QtyToAssign;

                        ItemChargeAssgntSales.InsertItemChargeAssignmentWithValuesTo(
                          ToItemChargeAssignmentSales, ToItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment,
                          ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.", ItemLedgerEntry."Item No.", ItemL.Description,
                          QtyToAssign, 0, ItemChargeAssgntNextLineNo, TempToItemChargeAssignmentSales);
                    end;
            until ValueEntry.NEXT() = 0;
            ItemChargeAssgntSales.Summarize(TempToItemChargeAssignmentSales, ToItemChargeAssignmentSales);

            // Use 2 passes to correct rounding issues
            ToItemChargeAssignmentSales.SETRANGE("Document Type", ToSalesLine."Document Type");
            ToItemChargeAssignmentSales.SETRANGE("Document No.", ToSalesLine."Document No.");
            ToItemChargeAssignmentSales.SETRANGE("Document Line No.", ToSalesLine."Line No.");
            if ToItemChargeAssignmentSales.FINDSET(true) then begin
                RemainingQty := (FromSalesLine.Quantity - SumQtyToAssign) / ValueEntry.COUNT;
                SumQtyToAssign := 0;
                repeat
                    AddRemainingQtyToSalesItemCharge(ToItemChargeAssignmentSales, RemainingQty);
                    SumQtyToAssign += ToItemChargeAssignmentSales."Qty. to Assign";
                until ToItemChargeAssignmentSales.NEXT() = 0;

                RemainingQty := FromSalesLine.Quantity - SumQtyToAssign;
                if RemainingQty <> 0 then
                    AddRemainingQtyToSalesItemCharge(ToItemChargeAssignmentSales, RemainingQty);
            end;
        end;
    end;

    local procedure AddRemainingQtyToPurchItemCharge(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; RemainingQty: Decimal)
    begin
        ItemChargeAssignmentPurch.VALIDATE(
          "Qty. to Assign", ROUND(ItemChargeAssignmentPurch."Qty. to Assign" + RemainingQty, UOMMgt.QtyRndPrecision()));
        ItemChargeAssignmentPurch.MODIFY(true);
    end;

    local procedure AddRemainingQtyToSalesItemCharge(var ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)"; RemainingQty: Decimal)
    begin
        ItemChargeAssignmentSales.VALIDATE(
          "Qty. to Assign", ROUND(ItemChargeAssignmentSales."Qty. to Assign" + RemainingQty, UOMMgt.QtyRndPrecision()));
        ItemChargeAssignmentSales.MODIFY(true);
    end;

    local procedure WarnSalesInvoicePmtDisc(var ToSalesHeader: Record "Sales Header"; var FromSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20])
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if HideDialog then
            exit;

        if IncludeHeader and
           (ToSalesHeader."Document Type" in
            [ToSalesHeader."Document Type"::"Return Order", ToSalesHeader."Document Type"::"Credit Memo"])
        then begin
            CustLedgEntry.SETCURRENTKEY("Document No.");
            CustLedgEntry.SETRANGE("Document Type", FromSalesHeader."Document Type"::Invoice);
            CustLedgEntry.SETRANGE("Document No.", FromDocNo);
            if CustLedgEntry.FINDFIRST() then
                if (CustLedgEntry."Pmt. Disc. Given (LCY)" <> 0) and
                   (CustLedgEntry."Journal Batch Name" = '')
                then
                    MESSAGE(Text006, SELECTSTR(FromDocType, Text007), FromDocNo);
        end;

        if IncludeHeader and
           (ToSalesHeader."Document Type" in
            [ToSalesHeader."Document Type"::Invoice, ToSalesHeader."Document Type"::Order,
             ToSalesHeader."Document Type"::Quote, ToSalesHeader."Document Type"::"Blanket Order"]) and
           (FromDocType = 9)
        then begin
            CustLedgEntry.SETCURRENTKEY("Document No.");
            CustLedgEntry.SETRANGE("Document Type", FromSalesHeader."Document Type"::"Credit Memo");
            CustLedgEntry.SETRANGE("Document No.", FromDocNo);
            if CustLedgEntry.FINDFIRST() then
                if (CustLedgEntry."Pmt. Disc. Given (LCY)" <> 0) and
                   (CustLedgEntry."Journal Batch Name" = '')
                then
                    MESSAGE(Text006, SELECTSTR(FromDocType - 1, Text007), FromDocNo);
        end;
    end;

    local procedure WarnPurchInvoicePmtDisc(var ToPurchHeader: Record "Purchase Header"; var FromPurchHeader: Record "Purchase Header"; FromDocType: Option; FromDocNo: Code[20])
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        if HideDialog then
            exit;

        if IncludeHeader and
           (ToPurchHeader."Document Type" in
            [ToPurchHeader."Document Type"::"Return Order", ToPurchHeader."Document Type"::"Credit Memo"])
        then begin
            VendLedgEntry.SETCURRENTKEY("Document No.");
            VendLedgEntry.SETRANGE("Document Type", FromPurchHeader."Document Type"::Invoice);
            VendLedgEntry.SETRANGE("Document No.", FromDocNo);
            if VendLedgEntry.FINDFIRST() then
                if (VendLedgEntry."Pmt. Disc. Rcd.(LCY)" <> 0) and
                   (VendLedgEntry."Journal Batch Name" = '')
                then
                    MESSAGE(Text009, SELECTSTR(FromDocType, Text007), FromDocNo);
        end;

        if IncludeHeader and
           (ToPurchHeader."Document Type" in
            [ToPurchHeader."Document Type"::Invoice, ToPurchHeader."Document Type"::Order,
             ToPurchHeader."Document Type"::Quote, ToPurchHeader."Document Type"::"Blanket Order"]) and
           (FromDocType = 9)
        then begin
            VendLedgEntry.SETCURRENTKEY("Document No.");
            VendLedgEntry.SETRANGE("Document Type", FromPurchHeader."Document Type"::"Credit Memo");
            VendLedgEntry.SETRANGE("Document No.", FromDocNo);
            if VendLedgEntry.FINDFIRST() then
                if (VendLedgEntry."Pmt. Disc. Rcd.(LCY)" <> 0) and
                   (VendLedgEntry."Journal Batch Name" = '')
                then
                    MESSAGE(Text006, SELECTSTR(FromDocType - 1, Text007), FromDocNo);
        end;
    end;

    local procedure CheckCopyFromSalesHeaderAvail(FromSalesHeader: Record "Sales Header"; ToSalesHeader: Record "Sales Header")
    var
        FromSalesLine: Record "Sales Line";
        ToSalesLine: Record "Sales Line";
    begin
        if ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Order, ToSalesHeader."Document Type"::Invoice] then begin
            FromSalesLine.SETRANGE("Document Type", FromSalesHeader."Document Type");
            FromSalesLine.SETRANGE("Document No.", FromSalesHeader."No.");
            FromSalesLine.SETRANGE(Type, FromSalesLine.Type::Item);
            FromSalesLine.SETFILTER("No.", '<>%1', '');
            if FromSalesLine.FIND('-') then
                repeat
                    if FromSalesLine.Quantity > 0 then begin
                        ToSalesLine."No." := FromSalesLine."No.";
                        ToSalesLine."Variant Code" := FromSalesLine."Variant Code";
                        ToSalesLine."Location Code" := FromSalesLine."Location Code";
                        ToSalesLine."Bin Code" := FromSalesLine."Bin Code";
                        ToSalesLine."Unit of Measure Code" := FromSalesLine."Unit of Measure Code";
                        ToSalesLine."Qty. per Unit of Measure" := FromSalesLine."Qty. per Unit of Measure";
                        //>>BC6 SBE 27/01/2022
                        //ToSalesLine."Outstanding Quantity" := FromSalesLine.Quantity;
                        ToSalesLine."Outstanding Quantity" := FromSalesLine."Outstanding Quantity";
                        //<<BC6 SBE 27/01/2022
                        if ToSalesHeader."Document Type" = ToSalesHeader."Document Type"::Order then
                            //>>BC6 SBE 27/01/2022
                            //ToSalesLine."Outstanding Quantity" := FromSalesLine.Quantity - FromSalesLine."Qty. to Assemble to Order";
                            ToSalesLine."Outstanding Quantity" := FromSalesLine."Outstanding Quantity" - FromSalesLine."Qty. to Assemble to Order";
                        //<<BC6 SBE 27/01/2022
                        ToSalesLine."Qty. to Assemble to Order" := 0;
                        ToSalesLine."Drop Shipment" := FromSalesLine."Drop Shipment";
                        CheckItemAvailability(ToSalesHeader, ToSalesLine);
                        OnCheckCopyFromSalesHeaderAvailOnAfterCheckItemAvailability(
                          ToSalesHeader, ToSalesLine, FromSalesHeader, IncludeHeader);

                        if ToSalesHeader."Document Type" = ToSalesHeader."Document Type"::Order then begin
                            //>>BC6 MB 01/07/2021
                            //ToSalesLine."Outstanding Quantity" := FromSalesLine.Quantity;
                            ToSalesLine."Outstanding Quantity" := FromSalesLine."Outstanding Quantity";
                            //<<BC6 MB
                            ToSalesLine."Qty. to Assemble to Order" := FromSalesLine."Qty. to Assemble to Order";
                            CheckATOItemAvailable(FromSalesLine, ToSalesLine);
                        end;
                    end;
                until FromSalesLine.NEXT() = 0;
        end;
    end;

    local procedure CheckCopyFromSalesShptAvail(FromSalesShptHeader: Record "Sales Shipment Header"; ToSalesHeader: Record "Sales Header")
    var
        FromSalesShptLine: Record "Sales Shipment Line";
        ToSalesLine: Record "Sales Line";
        FromPostedAsmHeader: Record "Posted Assembly Header";
    begin
        if not (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Order, ToSalesHeader."Document Type"::Invoice]) then
            exit;

        FromSalesShptLine.SETRANGE("Document No.", FromSalesShptHeader."No.");
        FromSalesShptLine.SETRANGE(Type, FromSalesShptLine.Type::Item);
        FromSalesShptLine.SETFILTER("No.", '<>%1', '');
        if FromSalesShptLine.FIND('-') then
            repeat
                if FromSalesShptLine.Quantity > 0 then begin
                    ToSalesLine."No." := FromSalesShptLine."No.";
                    ToSalesLine."Variant Code" := FromSalesShptLine."Variant Code";
                    ToSalesLine."Location Code" := FromSalesShptLine."Location Code";
                    ToSalesLine."Bin Code" := FromSalesShptLine."Bin Code";
                    ToSalesLine."Unit of Measure Code" := FromSalesShptLine."Unit of Measure Code";
                    ToSalesLine."Qty. per Unit of Measure" := FromSalesShptLine."Qty. per Unit of Measure";
                    ToSalesLine."Outstanding Quantity" := FromSalesShptLine.Quantity;

                    if ToSalesLine."Document Type" = ToSalesLine."Document Type"::Order then
                        if FromSalesShptLine.AsmToShipmentExists(FromPostedAsmHeader) then
                            ToSalesLine."Outstanding Quantity" := FromSalesShptLine.Quantity - FromPostedAsmHeader.Quantity;
                    ToSalesLine."Qty. to Assemble to Order" := 0;
                    ToSalesLine."Drop Shipment" := FromSalesShptLine."Drop Shipment";
                    CheckItemAvailability(ToSalesHeader, ToSalesLine);
                    OnCheckCopyFromSalesShptAvailOnAfterCheckItemAvailability(
                      ToSalesHeader, ToSalesLine, FromSalesShptHeader, IncludeHeader);

                    if ToSalesLine."Document Type" = ToSalesLine."Document Type"::Order then
                        if FromSalesShptLine.AsmToShipmentExists(FromPostedAsmHeader) then begin
                            ToSalesLine."Qty. to Assemble to Order" := FromPostedAsmHeader.Quantity;
                            CheckPostedATOItemAvailable(FromSalesShptLine, ToSalesLine);
                        end;
                end;
            until FromSalesShptLine.NEXT() = 0;
    end;

    local procedure CheckCopyFromSalesInvoiceAvail(FromSalesInvHeader: Record "Sales Invoice Header"; ToSalesHeader: Record "Sales Header")
    var
        FromSalesInvLine: Record "Sales Invoice Line";
        ToSalesLine: Record "Sales Line";
    begin
        if not (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Order, ToSalesHeader."Document Type"::Invoice]) then
            exit;

        FromSalesInvLine.SETRANGE("Document No.", FromSalesInvHeader."No.");
        FromSalesInvLine.SETRANGE(Type, FromSalesInvLine.Type::Item);
        FromSalesInvLine.SETFILTER("No.", '<>%1', '');
        FromSalesInvLine.SETRANGE("Prepayment Line", false);
        if FromSalesInvLine.FIND('-') then
            repeat
                if FromSalesInvLine.Quantity > 0 then begin
                    ToSalesLine."No." := FromSalesInvLine."No.";
                    ToSalesLine."Variant Code" := FromSalesInvLine."Variant Code";
                    ToSalesLine."Location Code" := FromSalesInvLine."Location Code";
                    ToSalesLine."Bin Code" := FromSalesInvLine."Bin Code";
                    ToSalesLine."Unit of Measure Code" := FromSalesInvLine."Unit of Measure Code";
                    ToSalesLine."Qty. per Unit of Measure" := FromSalesInvLine."Qty. per Unit of Measure";
                    ToSalesLine."Outstanding Quantity" := FromSalesInvLine.Quantity;
                    ToSalesLine."Drop Shipment" := FromSalesInvLine."Drop Shipment";
                    CheckItemAvailability(ToSalesHeader, ToSalesLine);
                    OnCheckCopyFromSalesInvoiceAvailOnAfterCheckItemAvailability(
                      ToSalesHeader, ToSalesLine, FromSalesInvHeader, IncludeHeader);
                end;
            until FromSalesInvLine.NEXT() = 0;
    end;

    local procedure CheckCopyFromSalesRetRcptAvail(FromReturnRcptHeader: Record "Return Receipt Header"; ToSalesHeader: Record "Sales Header")
    var
        FromReturnRcptLine: Record "Return Receipt Line";
        ToSalesLine: Record "Sales Line";
    begin
        if not (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Order, ToSalesHeader."Document Type"::Invoice]) then
            exit;

        FromReturnRcptLine.SETRANGE("Document No.", FromReturnRcptHeader."No.");
        FromReturnRcptLine.SETRANGE(Type, FromReturnRcptLine.Type::Item);
        FromReturnRcptLine.SETFILTER("No.", '<>%1', '');
        if FromReturnRcptLine.FIND('-') then
            repeat
                if FromReturnRcptLine.Quantity > 0 then begin
                    ToSalesLine."No." := FromReturnRcptLine."No.";
                    ToSalesLine."Variant Code" := FromReturnRcptLine."Variant Code";
                    ToSalesLine."Location Code" := FromReturnRcptLine."Location Code";
                    ToSalesLine."Bin Code" := FromReturnRcptLine."Bin Code";
                    ToSalesLine."Unit of Measure Code" := FromReturnRcptLine."Unit of Measure Code";
                    ToSalesLine."Qty. per Unit of Measure" := FromReturnRcptLine."Qty. per Unit of Measure";
                    ToSalesLine."Outstanding Quantity" := FromReturnRcptLine.Quantity;
                    ToSalesLine."Drop Shipment" := false;
                    CheckItemAvailability(ToSalesHeader, ToSalesLine);
                    OnCheckCopyFromSalesRetRcptAvailOnAfterCheckItemAvailability(
                      ToSalesHeader, ToSalesLine, FromReturnRcptHeader, IncludeHeader);
                end;
            until FromReturnRcptLine.NEXT() = 0;
    end;

    local procedure CheckCopyFromSalesCrMemoAvail(FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; ToSalesHeader: Record "Sales Header")
    var
        FromSalesCrMemoLine: Record "Sales Cr.Memo Line";
        ToSalesLine: Record "Sales Line";
    begin
        if not (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Order, ToSalesHeader."Document Type"::Invoice]) then
            exit;

        FromSalesCrMemoLine.SETRANGE("Document No.", FromSalesCrMemoHeader."No.");
        FromSalesCrMemoLine.SETRANGE(Type, FromSalesCrMemoLine.Type::Item);
        FromSalesCrMemoLine.SETFILTER("No.", '<>%1', '');
        FromSalesCrMemoLine.SETRANGE("Prepayment Line", false);
        if FromSalesCrMemoLine.FIND('-') then
            repeat
                if FromSalesCrMemoLine.Quantity > 0 then begin
                    ToSalesLine."No." := FromSalesCrMemoLine."No.";
                    ToSalesLine."Variant Code" := FromSalesCrMemoLine."Variant Code";
                    ToSalesLine."Location Code" := FromSalesCrMemoLine."Location Code";
                    ToSalesLine."Bin Code" := FromSalesCrMemoLine."Bin Code";
                    ToSalesLine."Unit of Measure Code" := FromSalesCrMemoLine."Unit of Measure Code";
                    ToSalesLine."Qty. per Unit of Measure" := FromSalesCrMemoLine."Qty. per Unit of Measure";
                    ToSalesLine."Outstanding Quantity" := FromSalesCrMemoLine.Quantity;
                    ToSalesLine."Drop Shipment" := false;
                    CheckItemAvailability(ToSalesHeader, ToSalesLine);
                    OnCheckCopyFromSalesCrMemoAvailOnAfterCheckItemAvailability(
                      ToSalesHeader, ToSalesLine, FromSalesCrMemoHeader, IncludeHeader);
                end;
            until FromSalesCrMemoLine.NEXT() = 0;
    end;

    local procedure CheckItemAvailability(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line")
    begin
        if HideDialog then
            exit;

        ToSalesLine."Document Type" := ToSalesHeader."Document Type";
        ToSalesLine."Document No." := ToSalesHeader."No.";
        ToSalesLine.Type := ToSalesLine.Type::Item;
        ToSalesLine."Purchase Order No." := '';
        ToSalesLine."Purch. Order Line No." := 0;
        ToSalesLine."Drop Shipment" :=
          not RecalculateLines and ToSalesLine."Drop Shipment" and
          (ToSalesHeader."Document Type" = ToSalesHeader."Document Type"::Order);

        SetShipmentDateInLine(ToSalesHeader, ToSalesLine);

        if ItemCheckAvail.SalesLineCheck(ToSalesLine) then
            ItemCheckAvail.RaiseUpdateInterruptedError();
    end;

    local procedure InitShipmentDateInLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        if SalesHeader."Shipment Date" <> 0D then
            SalesLine."Shipment Date" := SalesHeader."Shipment Date"
        else
            SalesLine."Shipment Date" := WORKDATE();
    end;

    local procedure SetShipmentDateInLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        OnBeforeSetShipmentDateInLine(SalesHeader, SalesLine);
        if SalesLine."Shipment Date" = 0D then begin
            InitShipmentDateInLine(SalesHeader, SalesLine);
            SalesLine.VALIDATE("Shipment Date");
        end;
    end;

    local procedure CheckATOItemAvailable(var FromSalesLine: Record "Sales Line"; ToSalesLine: Record "Sales Line")
    var
        ATOLink: Record "Assemble-to-Order Link";
        AsmHeaderL: Record "Assembly Header";
        TempAsmHeaderL: Record "Assembly Header" temporary;
        TempAsmLineL: Record "Assembly Line" temporary;
    begin
        if HideDialog then
            exit;

        if ATOLink.ATOCopyCheckAvailShowWarning(
             AsmHeaderL, ToSalesLine, TempAsmHeaderL, TempAsmLineL,
             not FromSalesLine.AsmToOrderExists(AsmHeaderL))
        then
            if ItemCheckAvail.ShowAsmWarningYesNo(TempAsmHeaderL, TempAsmLineL) then
                ItemCheckAvail.RaiseUpdateInterruptedError();
    end;

    local procedure CheckPostedATOItemAvailable(var FromSalesShptLine: Record "Sales Shipment Line"; ToSalesLine: Record "Sales Line")
    var
        ATOLink: Record "Assemble-to-Order Link";
        PostedAsmHeaderL: Record "Posted Assembly Header";
        TempAsmHeaderL: Record "Assembly Header" temporary;
        TempAsmLineL: Record "Assembly Line" temporary;
    begin
        if HideDialog then
            exit;

        if ATOLink.PstdATOCopyCheckAvailShowWarn(
             PostedAsmHeaderL, ToSalesLine, TempAsmHeaderL, TempAsmLineL,
             not FromSalesShptLine.AsmToShipmentExists(PostedAsmHeaderL))
        then
            if ItemCheckAvail.ShowAsmWarningYesNo(TempAsmHeaderL, TempAsmLineL) then
                ItemCheckAvail.RaiseUpdateInterruptedError();
    end;

    procedure CopyServContractLines(ToServContractHeader: Record "Service Contract Header"; FromDocType: Option; FromDocNo: Code[20]; var FromServContractLine: Record "Service Contract Line") AllLinesCopied: Boolean
    var
        ExistingServContractLine: Record "Service Contract Line";
        LineNo: Integer;
    begin
        if FromDocNo = '' then
            ERROR(Text000);

        ExistingServContractLine.LOCKTABLE();
        ExistingServContractLine.RESET();
        ExistingServContractLine.SETRANGE("Contract Type", ToServContractHeader."Contract Type");
        ExistingServContractLine.SETRANGE("Contract No.", ToServContractHeader."Contract No.");
        if ExistingServContractLine.FINDLAST() then
            LineNo := ExistingServContractLine."Line No." + 10000
        else
            LineNo := 10000;

        AllLinesCopied := true;
        FromServContractLine.RESET();
        FromServContractLine.SETRANGE("Contract Type", FromDocType);
        FromServContractLine.SETRANGE("Contract No.", FromDocNo);
        if FromServContractLine.FIND('-') then
            repeat
                if not ProcessServContractLine(
                     ToServContractHeader,
                     FromServContractLine,
                     LineNo)
                then begin
                    AllLinesCopied := false;
                    FromServContractLine.MARK(true)
                end else
                    LineNo := LineNo + 10000
            until FromServContractLine.NEXT() = 0;

        OnAfterCopyServContractLines(ToServContractHeader, FromDocType, FromDocNo, FromServContractLine);
    end;

    procedure ServContractHeaderDocType(DocType: Option): Integer
    var
        ServContractHeader: Record "Service Contract Header";
    begin
        case DocType of
            ServDocType::Quote:
                exit(ServContractHeader."Contract Type"::Quote.AsInteger());
            ServDocType::Contract:
                exit(ServContractHeader."Contract Type"::Contract.AsInteger());
        end;
    end;

    local procedure ProcessServContractLine(ToServContractHeader: Record "Service Contract Header"; var FromServContractLine: Record "Service Contract Line"; LineNo: Integer): Boolean
    var
        ToServContractLine: Record "Service Contract Line";
        ExistingServContractLine: Record "Service Contract Line";
        ServItem: Record "Service Item";
    begin
        if FromServContractLine."Service Item No." <> '' then begin
            ServItem.GET(FromServContractLine."Service Item No.");
            if ServItem."Customer No." <> ToServContractHeader."Customer No." then
                exit(false);

            ExistingServContractLine.RESET();
            ExistingServContractLine.SETCURRENTKEY("Service Item No.", "Contract Status");
            ExistingServContractLine.SETRANGE("Service Item No.", FromServContractLine."Service Item No.");
            ExistingServContractLine.SETRANGE("Contract Type", ToServContractHeader."Contract Type");
            ExistingServContractLine.SETRANGE("Contract No.", ToServContractHeader."Contract No.");
            if not ExistingServContractLine.ISEMPTY then
                exit(false);
        end;

        ToServContractLine := FromServContractLine;
        ToServContractLine."Last Planned Service Date" := 0D;
        ToServContractLine."Last Service Date" := 0D;
        ToServContractLine."Last Preventive Maint. Date" := 0D;
        ToServContractLine."Invoiced to Date" := 0D;
        ToServContractLine."Contract Type" := ToServContractHeader."Contract Type";
        ToServContractLine."Contract No." := ToServContractHeader."Contract No.";
        ToServContractLine."Line No." := LineNo;
        ToServContractLine."New Line" := true;
        ToServContractLine.Credited := false;
        ToServContractLine.SetupNewLine();
        ToServContractLine.INSERT(true);

        OnAfterProcessServContractLine(ToServContractLine, FromServContractLine);
        exit(true);
    end;

    procedure CopySalesShptLinesToDoc(ToSalesHeader: Record "Sales Header"; var FromSalesShptLine: Record "Sales Shipment Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempTrkgItemLedgEntry: Record "Item Ledger Entry" temporary;
        FromSalesHeader: Record "Sales Header";
        FromSalesLine: Record "Sales Line";
        ToSalesLine: Record "Sales Line";
        TempFromSalesLine: Record "Sales Line" temporary;
        FromSalesShptHeader: Record "Sales Shipment Header";
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        TempDocSalesLine: Record "Sales Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        OldDocNo: Code[20];
        NextLineNo: Integer;
        NextItemTrkgEntryNo: Integer;
        FromLineCounter: Integer;
        ToLineCounter: Integer;
        CopyItemTrkg: Boolean;
        SplitLine: Boolean;
        FillExactCostRevLink: Boolean;
        CopyLine: Boolean;
        InsertDocNoLine: Boolean;
    begin
        MissingExCostRevLink := false;
        InitCurrency(ToSalesHeader."Currency Code");
        OpenWindow();

        OnBeforeCopySalesShptLinesToDoc(TempDocSalesLine, ToSalesHeader, FromSalesShptLine);

        if FromSalesShptLine.FINDSET() then
            repeat
                FromLineCounter := FromLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(1, FromLineCounter);
                if FromSalesShptHeader."No." <> FromSalesShptLine."Document No." then begin
                    FromSalesShptHeader.GET(FromSalesShptLine."Document No.");
                    TransferOldExtLines.ClearLineNumbers();
                end;
                FromSalesShptHeader.TESTFIELD("Prices Including VAT", ToSalesHeader."Prices Including VAT");
                FromSalesHeader.TRANSFERFIELDS(FromSalesShptHeader);
                FillExactCostRevLink :=
                  IsSalesFillExactCostRevLink(ToSalesHeader, 0, FromSalesHeader."Currency Code");
                FromSalesLine.TRANSFERFIELDS(FromSalesShptLine);
                FromSalesLine."Appl.-from Item Entry" := 0;
                FromSalesLine."Copied From Posted Doc." := true;

                if FromSalesShptLine."Document No." <> OldDocNo then begin
                    OldDocNo := FromSalesShptLine."Document No.";
                    InsertDocNoLine := true;
                end;

                OnBeforeCopySalesShptLinesToBuffer(FromSalesLine, FromSalesShptLine, ToSalesHeader);

                SplitLine := true;
                FromSalesShptLine.FilterPstdDocLnItemLedgEntries(ItemLedgEntry);
                if not SplitPstdSalesLinesPerILE(
                     ToSalesHeader, FromSalesHeader, ItemLedgEntry, TempFromSalesLine,
                     FromSalesLine, TempDocSalesLine, NextLineNo, CopyItemTrkg, MissingExCostRevLink, FillExactCostRevLink, true)
                then
                    if CopyItemTrkg then
                        SplitLine :=
                          SplitSalesDocLinesPerItemTrkg(
                            ItemLedgEntry, TempItemTrkgEntry, TempFromSalesLine,
                            FromSalesLine, TempDocSalesLine, NextLineNo, NextItemTrkgEntryNo, MissingExCostRevLink, true)
                    else
                        SplitLine := false;

                if not SplitLine then begin
                    TempFromSalesLine := FromSalesLine;
                    CopyLine := true;
                end else
                    CopyLine := TempFromSalesLine.FINDSET() and FillExactCostRevLink;

                Window.UPDATE(1, FromLineCounter);
                if CopyLine then begin
                    NextLineNo := GetLastToSalesLineNo(ToSalesHeader);
                    AsmHdrExistsForFromDocLine := FromSalesShptLine.AsmToShipmentExists(PostedAsmHeader);
                    InitAsmCopyHandling(true);
                    if AsmHdrExistsForFromDocLine then begin
                        QtyToAsmToOrder := FromSalesShptLine.Quantity;
                        QtyToAsmToOrderBase := FromSalesShptLine."Quantity (Base)";
                        GenerateAsmDataFromPosted(PostedAsmHeader, ToSalesHeader."Document Type".AsInteger());
                    end;
                    if InsertDocNoLine then begin
                        InsertOldSalesDocNoLine(ToSalesHeader, FromSalesShptLine."Document No.", 1, NextLineNo);
                        InsertDocNoLine := false;
                    end;
                    repeat
                        ToLineCounter := ToLineCounter + 1;
                        if IsTimeForUpdate() then
                            Window.UPDATE(2, ToLineCounter);

                        OnCopySalesShptLinesToDocOnBeforeCopySalesLine(ToSalesHeader, TempFromSalesLine);

                        if CopySalesLine(
                             ToSalesHeader, ToSalesLine, FromSalesHeader, TempFromSalesLine, NextLineNo, LinesNotCopied,
                             false, DeferralTypeForSalesDoc(SalesDocType::"Posted Shipment".AsInteger()), CopyPostedDeferral,
                             TempFromSalesLine."Line No.")
                        then begin
                            if CopyItemTrkg then begin
                                if SplitLine then
                                    ItemTrackingDocMgt.CollectItemTrkgPerPostedDocLine(
                                      TempItemTrkgEntry, TempTrkgItemLedgEntry, false, TempFromSalesLine."Document No.", TempFromSalesLine."Line No.")
                                else
                                    ItemTrackingDocMgt.CopyItemLedgerEntriesToTemp(TempTrkgItemLedgEntry, ItemLedgEntry);

                                ItemTrackingMgt.CopyItemLedgEntryTrkgToSalesLn(
                                  TempTrkgItemLedgEntry, ToSalesLine,
                                  FillExactCostRevLink and ExactCostRevMandatory, MissingExCostRevLink,
                                  FromSalesHeader."Prices Including VAT", ToSalesHeader."Prices Including VAT", true);
                            end;
                            OnAfterCopySalesLineFromSalesShptLineBuffer(
                              ToSalesLine, FromSalesShptLine, IncludeHeader, RecalculateLines, TempDocSalesLine, ToSalesHeader, TempFromSalesLine);
                        end;
                    until TempFromSalesLine.NEXT() = 0;
                end;
            until FromSalesShptLine.NEXT() = 0;

        Window.CLOSE();
    end;

    procedure CopySalesInvLinesToDoc(ToSalesHeader: Record "Sales Header"; var FromSalesInvLine: Record "Sales Invoice Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        FromSalesHeader: Record "Sales Header";
        FromSalesLine: Record "Sales Line";
        FromSalesLine2: Record "Sales Line";
        ToSalesLine: Record "Sales Line";
        TempSalesLineBuf: Record "Sales Line" temporary;
        FromSalesInvHeader: Record "Sales Invoice Header";
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        TempDocSalesLine: Record "Sales Line" temporary;
        OldInvDocNo: Code[20];
        OldShptDocNo: Code[20];
        OldBufDocNo: Code[20];
        NextLineNo: Integer;
        SalesCombDocLineNo: Integer;
        NextItemTrkgEntryNo: Integer;
        FromLineCounter: Integer;
        ToLineCounter: Integer;
        CopyItemTrkg: Boolean;
        SplitLine: Boolean;
        FillExactCostRevLink: Boolean;
        SalesInvLineCount: Integer;
        SalesLineCount: Integer;
        BufferCount: Integer;
        FirstLineShipped: Boolean;
        FirstLineText: Boolean;
        ItemChargeAssgntNextLineNo: Integer;
    begin
        MissingExCostRevLink := false;
        InitCurrency(ToSalesHeader."Currency Code");
        TempSalesLineBuf.RESET();
        TempSalesLineBuf.DELETEALL();
        TempItemTrkgEntry.RESET();
        TempItemTrkgEntry.DELETEALL();
        OpenWindow();
        InitAsmCopyHandling(true);
        TempSalesInvLineG.DELETEALL();

        OnBeforeCopySalesInvLines(TempDocSalesLine, ToSalesHeader, FromSalesInvLine);

        // Fill sales line buffer
        SalesInvLineCount := 0;
        FirstLineText := false;
        if FromSalesInvLine.FINDSET() then
            repeat
                FromLineCounter := FromLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(1, FromLineCounter);
                SetTempSalesInvLine(FromSalesInvLine, TempSalesInvLineG, SalesInvLineCount, NextLineNo, FirstLineText);
                if FromSalesInvHeader."No." <> FromSalesInvLine."Document No." then begin
                    FromSalesInvHeader.GET(FromSalesInvLine."Document No.");
                    TransferOldExtLines.ClearLineNumbers();
                end;
                FromSalesInvHeader.TESTFIELD("Prices Including VAT", ToSalesHeader."Prices Including VAT");
                FromSalesHeader.TRANSFERFIELDS(FromSalesInvHeader);
                FillExactCostRevLink := IsSalesFillExactCostRevLink(ToSalesHeader, 1, FromSalesHeader."Currency Code");
                FromSalesLine.TRANSFERFIELDS(FromSalesInvLine);
                FromSalesLine."Appl.-from Item Entry" := 0;
                // Reuse fields to buffer invoice line information
                FromSalesLine."Shipment No." := FromSalesInvLine."Document No.";
                FromSalesLine."Shipment Line No." := 0;
                FromSalesLine."Return Receipt No." := '';
                FromSalesLine."Return Receipt Line No." := FromSalesInvLine."Line No.";
                FromSalesLine."Copied From Posted Doc." := true;

                OnBeforeCopySalesInvLinesToBuffer(FromSalesLine, FromSalesInvLine, ToSalesHeader);

                SplitLine := true;
                FromSalesInvLine.GetItemLedgEntries(TempItemLedgEntry, true);
                if not SplitPstdSalesLinesPerILE(
                     ToSalesHeader, FromSalesHeader, TempItemLedgEntry, TempSalesLineBuf,
                     FromSalesLine, TempDocSalesLine, NextLineNo, CopyItemTrkg, MissingExCostRevLink, FillExactCostRevLink, false)
                then
                    if CopyItemTrkg then
                        SplitLine := SplitSalesDocLinesPerItemTrkg(
                            TempItemLedgEntry, TempItemTrkgEntry, TempSalesLineBuf,
                            FromSalesLine, TempDocSalesLine, NextLineNo, NextItemTrkgEntryNo, MissingExCostRevLink, false)
                    else
                        SplitLine := false;

                if not SplitLine then
                    CopySalesLinesToBuffer(
                      FromSalesHeader, FromSalesLine, FromSalesLine2, TempSalesLineBuf,
                      ToSalesHeader, TempDocSalesLine, FromSalesInvLine."Document No.", NextLineNo);

                OnAfterCopySalesInvLine(TempDocSalesLine, ToSalesHeader, TempSalesLineBuf, FromSalesInvLine);
            until FromSalesInvLine.NEXT() = 0;

        // Create sales line from buffer
        Window.UPDATE(1, FromLineCounter);
        BufferCount := 0;
        FirstLineShipped := true;
        // Sorting according to Sales Line Document No.,Line No.
        TempSalesLineBuf.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        SalesLineCount := 0;
        if TempSalesLineBuf.FINDSET() then
            repeat
                if TempSalesLineBuf.Type = TempSalesLineBuf.Type::Item then
                    SalesLineCount += 1;
            until TempSalesLineBuf.NEXT() = 0;
        if TempSalesLineBuf.FINDSET() then begin
            NextLineNo := GetLastToSalesLineNo(ToSalesHeader);
            repeat
                ToLineCounter := ToLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(2, ToLineCounter);
                if TempSalesLineBuf."Shipment No." <> OldInvDocNo then begin
                    OldInvDocNo := TempSalesLineBuf."Shipment No.";
                    OldShptDocNo := '';
                    FirstLineShipped := true;
                    InsertOldSalesDocNoLine(ToSalesHeader, OldInvDocNo, 2, NextLineNo);
                end;
                CheckFirstLineShipped(TempSalesLineBuf."Document No.", TempSalesLineBuf."Shipment Line No.", SalesCombDocLineNo, NextLineNo, FirstLineShipped);
                if (TempSalesLineBuf."Document No." <> OldShptDocNo) and (TempSalesLineBuf."Shipment Line No." > 0) then begin
                    if FirstLineShipped then
                        SalesCombDocLineNo := NextLineNo;
                    OldShptDocNo := TempSalesLineBuf."Document No.";
                    InsertOldSalesCombDocNoLine(ToSalesHeader, OldInvDocNo, OldShptDocNo, SalesCombDocLineNo, true);
                    NextLineNo := NextLineNo + 10000;
                    FirstLineShipped := true;
                end;

                InitFromSalesLine2(FromSalesLine2, TempSalesLineBuf);
                if GetSalesDocNo(TempDocSalesLine, TempSalesLineBuf."Line No.") <> OldBufDocNo then begin
                    OldBufDocNo := GetSalesDocNo(TempDocSalesLine, TempSalesLineBuf."Line No.");
                    TransferOldExtLines.ClearLineNumbers();
                end;

                OnCopySalesInvLinesToDocOnBeforeCopySalesLine(ToSalesHeader, FromSalesLine2);

                AsmHdrExistsForFromDocLine := false;
                if TempSalesLineBuf.Type = TempSalesLineBuf.Type::Item then
                    CheckAsmHdrExistsForFromDocLine(ToSalesHeader, FromSalesLine2, BufferCount, SalesLineCount = SalesInvLineCount);

                if CopySalesLine(ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine2, NextLineNo, LinesNotCopied,
                     TempSalesLineBuf."Return Receipt No." = '', DeferralTypeForSalesDoc(SalesDocType::"Posted Invoice".AsInteger()), CopyPostedDeferral,
                     GetSalesLineNo(TempDocSalesLine, FromSalesLine2."Line No."))
                then begin
                    CopySalesPostedDeferrals(ToSalesLine, "Deferral Document Type"::Sales.AsInteger(),
                    DeferralTypeForSalesDoc("Sales Document Type From"::"Posted Credit Memo".AsInteger()), TempSalesLineBuf."Shipment No.",
                    TempSalesLineBuf."Return Receipt Line No.", ToSalesLine."Document Type".AsInteger(), ToSalesLine."Document No.", ToSalesLine."Line No.");
                    TempSalesLineBuf.Get(TempSalesLineBuf."Shipment No.", TempSalesLineBuf."Return Receipt Line No.");
                    // copy item charges
                    if TempSalesLineBuf.Type = TempSalesLineBuf.Type::"Charge (Item)" then begin
                        FromSalesLine.TRANSFERFIELDS(FromSalesInvLine);
                        FromSalesLine."Document Type" := FromSalesLine."Document Type"::Invoice;
                        CopyFromSalesLineItemChargeAssign(FromSalesLine, ToSalesLine, FromSalesHeader, ItemChargeAssgntNextLineNo);
                    end;
                    // copy item tracking
                    if (TempSalesLineBuf.Type = TempSalesLineBuf.Type::Item) and (TempSalesLineBuf.Quantity <> 0) and SalesDocCanReceiveTracking(ToSalesHeader) then begin
                        FromSalesInvLine."Document No." := OldInvDocNo;
                        FromSalesInvLine."Line No." := TempSalesLineBuf."Return Receipt Line No.";
                        FromSalesInvLine.GetItemLedgEntries(TempItemLedgEntry, true);
                        if IsCopyItemTrkg(TempItemLedgEntry, CopyItemTrkg, FillExactCostRevLink) then
                            CopyItemLedgEntryTrackingToSalesLine(
                              TempItemLedgEntry, TempItemTrkgEntry, TempSalesLineBuf, ToSalesLine, ToSalesHeader."Prices Including VAT",
                              FromSalesHeader."Prices Including VAT", FillExactCostRevLink, MissingExCostRevLink);
                    end;

                    OnAfterCopySalesLineFromSalesLineBuffer(
                      ToSalesLine, FromSalesInvLine, IncludeHeader, RecalculateLines, TempDocSalesLine, ToSalesHeader, TempSalesLineBuf);
                end;
            until TempSalesLineBuf.NEXT() = 0;
        end;
        Window.CLOSE();
    end;

    procedure CopySalesCrMemoLinesToDoc(ToSalesHeader: Record "Sales Header"; var FromSalesCrMemoLine: Record "Sales Cr.Memo Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        TempItemLedgEntryBuf: Record "Item Ledger Entry" temporary;
        TempTrkgItemLedgEntry: Record "Item Ledger Entry" temporary;
        FromSalesHeader: Record "Sales Header";
        FromSalesLine: Record "Sales Line";
        FromSalesLine2: Record "Sales Line";
        ToSalesLine: Record "Sales Line";
        TempFromSalesLineBuf: Record "Sales Line" temporary;
        FromSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        TempDocSalesLine: Record "Sales Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        OldCrMemoDocNo: Code[20];
        OldReturnRcptDocNo: Code[20];
        OldBufDocNo: Code[20];
        NextLineNo: Integer;
        NextItemTrkgEntryNo: Integer;
        FromLineCounter: Integer;
        ToLineCounter: Integer;
        ItemChargeAssgntNextLineNo: Integer;
        CopyItemTrkg: Boolean;
        SplitLine: Boolean;
        FillExactCostRevLink: Boolean;
    begin
        MissingExCostRevLink := false;
        InitCurrency(ToSalesHeader."Currency Code");
        TempFromSalesLineBuf.RESET();
        TempFromSalesLineBuf.DELETEALL();
        TempItemTrkgEntry.RESET();
        TempItemTrkgEntry.DELETEALL();
        OpenWindow();

        OnBeforeCopySalesCrMemoLinesToDoc(TempDocSalesLine, ToSalesHeader, FromSalesCrMemoLine);
        // Fill sales line buffer
        if FromSalesCrMemoLine.FINDSET() then
            repeat
                FromLineCounter := FromLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(1, FromLineCounter);
                if FromSalesCrMemoHeader."No." <> FromSalesCrMemoLine."Document No." then begin
                    FromSalesCrMemoHeader.GET(FromSalesCrMemoLine."Document No.");
                    TransferOldExtLines.ClearLineNumbers();
                end;
                FromSalesHeader.TRANSFERFIELDS(FromSalesCrMemoHeader);
                FillExactCostRevLink :=
                  IsSalesFillExactCostRevLink(ToSalesHeader, 3, FromSalesHeader."Currency Code");
                FromSalesLine.TRANSFERFIELDS(FromSalesCrMemoLine);
                FromSalesLine."Appl.-from Item Entry" := 0;
                // Reuse fields to buffer credit memo line information
                FromSalesLine."Shipment No." := FromSalesCrMemoLine."Document No.";
                FromSalesLine."Shipment Line No." := 0;
                FromSalesLine."Return Receipt No." := '';
                FromSalesLine."Return Receipt Line No." := FromSalesCrMemoLine."Line No.";
                FromSalesLine."Copied From Posted Doc." := true;

                OnBeforeCopySalesCrMemoLinesToBuffer(FromSalesLine, FromSalesCrMemoLine, ToSalesHeader);

                SplitLine := true;
                FromSalesCrMemoLine.GetItemLedgEntries(TempItemLedgEntryBuf, true);
                if not SplitPstdSalesLinesPerILE(
                     ToSalesHeader, FromSalesHeader, TempItemLedgEntryBuf, TempFromSalesLineBuf,
                     FromSalesLine, TempDocSalesLine, NextLineNo, CopyItemTrkg, MissingExCostRevLink, FillExactCostRevLink, false)
                then
                    if CopyItemTrkg then
                        SplitLine :=
                          SplitSalesDocLinesPerItemTrkg(
                            TempItemLedgEntryBuf, TempItemTrkgEntry, TempFromSalesLineBuf,
                            FromSalesLine, TempDocSalesLine, NextLineNo, NextItemTrkgEntryNo, MissingExCostRevLink, false)
                    else
                        SplitLine := false;

                if not SplitLine then
                    CopySalesLinesToBuffer(
                      FromSalesHeader, FromSalesLine, FromSalesLine2, TempFromSalesLineBuf,
                      ToSalesHeader, TempDocSalesLine, FromSalesCrMemoLine."Document No.", NextLineNo);
            until FromSalesCrMemoLine.NEXT() = 0;

        // Create sales line from buffer
        Window.UPDATE(1, FromLineCounter);
        // Sorting according to Sales Line Document No.,Line No.
        TempFromSalesLineBuf.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        if TempFromSalesLineBuf.FINDSET() then begin
            NextLineNo := GetLastToSalesLineNo(ToSalesHeader);
            repeat
                ToLineCounter := ToLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(2, ToLineCounter);
                if TempFromSalesLineBuf."Shipment No." <> OldCrMemoDocNo then begin
                    OldCrMemoDocNo := TempFromSalesLineBuf."Shipment No.";
                    OldReturnRcptDocNo := '';
                    InsertOldSalesDocNoLine(ToSalesHeader, OldCrMemoDocNo, 4, NextLineNo);
                end;
                if (TempFromSalesLineBuf."Document No." <> OldReturnRcptDocNo) and (TempFromSalesLineBuf."Shipment Line No." > 0) then begin
                    OldReturnRcptDocNo := TempFromSalesLineBuf."Document No.";
                    InsertOldSalesCombDocNoLine(ToSalesHeader, OldCrMemoDocNo, OldReturnRcptDocNo, NextLineNo, false);
                end;
                // Empty buffer fields
                FromSalesLine2 := TempFromSalesLineBuf;
                FromSalesLine2."Shipment No." := '';
                FromSalesLine2."Shipment Line No." := 0;
                FromSalesLine2."Return Receipt No." := '';
                FromSalesLine2."Return Receipt Line No." := 0;
                if GetSalesDocNo(TempDocSalesLine, TempFromSalesLineBuf."Line No.") <> OldBufDocNo then begin
                    OldBufDocNo := GetSalesDocNo(TempDocSalesLine, TempFromSalesLineBuf."Line No.");
                    TransferOldExtLines.ClearLineNumbers();
                end;

                OnCopySalesCrMemoLinesToDocOnBeforeCopySalesLine(ToSalesHeader, FromSalesLine2);

                if CopySalesLine(
                     ToSalesHeader, ToSalesLine, FromSalesHeader,
                     FromSalesLine2, NextLineNo, LinesNotCopied, TempFromSalesLineBuf."Return Receipt No." = '',
                     DeferralTypeForSalesDoc(SalesDocType::"Posted Credit Memo".AsInteger()), CopyPostedDeferral,
                     GetSalesLineNo(TempDocSalesLine, FromSalesLine2."Line No."))
                then begin
                    if CopyPostedDeferral then
                        CopySalesPostedDeferrals(ToSalesLine, "Deferral Document Type"::Sales.AsInteger(),
                       DeferralTypeForSalesDoc("Sales Document Type From"::"Posted Credit Memo".AsInteger()), TempFromSalesLineBuf."Shipment No.",
                       TempFromSalesLineBuf."Return Receipt Line No.", ToSalesLine."Document Type".AsInteger(), ToSalesLine."Document No.", ToSalesLine."Line No.");
                    FromSalesCrMemoLine.Get(TempFromSalesLineBuf."Shipment No.", TempFromSalesLineBuf."Return Receipt Line No.");
                    // copy item charges
                    if TempFromSalesLineBuf.Type = TempFromSalesLineBuf.Type::"Charge (Item)" then begin
                        FromSalesLine.TRANSFERFIELDS(FromSalesCrMemoLine);
                        FromSalesLine."Document Type" := FromSalesLine."Document Type"::"Credit Memo";
                        CopyFromSalesLineItemChargeAssign(FromSalesLine, ToSalesLine, FromSalesHeader, ItemChargeAssgntNextLineNo);
                    end;
                    // copy item tracking
                    if (TempFromSalesLineBuf.Type = TempFromSalesLineBuf.Type::Item) and (TempFromSalesLineBuf.Quantity <> 0) then begin
                        FromSalesCrMemoLine."Document No." := OldCrMemoDocNo;
                        FromSalesCrMemoLine."Line No." := TempFromSalesLineBuf."Return Receipt Line No.";
                        FromSalesCrMemoLine.GetItemLedgEntries(TempItemLedgEntryBuf, true);
                        if IsCopyItemTrkg(TempItemLedgEntryBuf, CopyItemTrkg, FillExactCostRevLink) then begin
                            if MoveNegLines or not ExactCostRevMandatory then
                                ItemTrackingDocMgt.CopyItemLedgerEntriesToTemp(TempTrkgItemLedgEntry, TempItemLedgEntryBuf)
                            else
                                ItemTrackingDocMgt.CollectItemTrkgPerPostedDocLine(
                                  TempItemTrkgEntry, TempTrkgItemLedgEntry, false, TempFromSalesLineBuf."Document No.", TempFromSalesLineBuf."Line No.");

                            ItemTrackingMgt.CopyItemLedgEntryTrkgToSalesLn(
                              TempTrkgItemLedgEntry, ToSalesLine,
                              FillExactCostRevLink and ExactCostRevMandatory, MissingExCostRevLink,
                              FromSalesHeader."Prices Including VAT", ToSalesHeader."Prices Including VAT", false);
                        end;
                    end;
                    OnAfterCopySalesLineFromSalesCrMemoLineBuffer(
                      ToSalesLine, FromSalesCrMemoLine, IncludeHeader, RecalculateLines, TempDocSalesLine, ToSalesHeader, TempFromSalesLineBuf);
                end;
            until TempFromSalesLineBuf.NEXT() = 0;
        end;

        Window.CLOSE();
    end;

    procedure CopySalesReturnRcptLinesToDoc(ToSalesHeader: Record "Sales Header"; var FromReturnRcptLine: Record "Return Receipt Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempTrkgItemLedgEntry: Record "Item Ledger Entry" temporary;
        FromSalesHeader: Record "Sales Header";
        FromSalesLine: Record "Sales Line";
        ToSalesLine: Record "Sales Line";
        TempFromSalesLineBuf: Record "Sales Line" temporary;
        FromReturnRcptHeader: Record "Return Receipt Header";
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        TempDocSalesLine: Record "Sales Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        OldDocNo: Code[20];
        NextLineNo: Integer;
        NextItemTrkgEntryNo: Integer;
        FromLineCounter: Integer;
        ToLineCounter: Integer;
        CopyItemTrkg: Boolean;
        SplitLine: Boolean;
        FillExactCostRevLink: Boolean;
        CopyLine: Boolean;
        InsertDocNoLine: Boolean;
    begin
        MissingExCostRevLink := false;
        InitCurrency(ToSalesHeader."Currency Code");
        OpenWindow();

        OnBeforeCopySalesReturnRcptLinesToDoc(TempDocSalesLine, ToSalesHeader, FromReturnRcptLine);

        if FromReturnRcptLine.FINDSET() then
            repeat
                FromLineCounter := FromLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(1, FromLineCounter);
                if FromReturnRcptHeader."No." <> FromReturnRcptLine."Document No." then begin
                    FromReturnRcptHeader.GET(FromReturnRcptLine."Document No.");
                    TransferOldExtLines.ClearLineNumbers();
                end;
                FromSalesHeader.TRANSFERFIELDS(FromReturnRcptHeader);
                FillExactCostRevLink :=
                  IsSalesFillExactCostRevLink(ToSalesHeader, 2, FromSalesHeader."Currency Code");
                FromSalesLine.TRANSFERFIELDS(FromReturnRcptLine);
                FromSalesLine."Appl.-from Item Entry" := 0;
                FromSalesLine."Copied From Posted Doc." := true;

                if FromReturnRcptLine."Document No." <> OldDocNo then begin
                    OldDocNo := FromReturnRcptLine."Document No.";
                    InsertDocNoLine := true;
                end;

                OnBeforeCopySalesReturnRcptLinesToBuffer(FromSalesLine, FromReturnRcptLine, ToSalesHeader);

                SplitLine := true;
                FromReturnRcptLine.FilterPstdDocLnItemLedgEntries(ItemLedgEntry);
                if not SplitPstdSalesLinesPerILE(
                     ToSalesHeader, FromSalesHeader, ItemLedgEntry, TempFromSalesLineBuf,
                     FromSalesLine, TempDocSalesLine, NextLineNo, CopyItemTrkg, MissingExCostRevLink, FillExactCostRevLink, true)
                then
                    if CopyItemTrkg then
                        SplitLine :=
                          SplitSalesDocLinesPerItemTrkg(
                            ItemLedgEntry, TempItemTrkgEntry, TempFromSalesLineBuf,
                            FromSalesLine, TempDocSalesLine, NextLineNo, NextItemTrkgEntryNo, MissingExCostRevLink, true)
                    else
                        SplitLine := false;

                if not SplitLine then begin
                    TempFromSalesLineBuf := FromSalesLine;
                    CopyLine := true;
                end else
                    CopyLine := TempFromSalesLineBuf.FINDSET() and FillExactCostRevLink;

                Window.UPDATE(1, FromLineCounter);
                if CopyLine then begin
                    NextLineNo := GetLastToSalesLineNo(ToSalesHeader);
                    if InsertDocNoLine then begin
                        InsertOldSalesDocNoLine(ToSalesHeader, FromReturnRcptLine."Document No.", 3, NextLineNo);
                        InsertDocNoLine := false;
                    end;
                    repeat
                        ToLineCounter := ToLineCounter + 1;
                        if IsTimeForUpdate() then
                            Window.UPDATE(2, ToLineCounter);
                        if CopySalesLine(
                             ToSalesHeader, ToSalesLine, FromSalesHeader, TempFromSalesLineBuf, NextLineNo, LinesNotCopied,
                             false, DeferralTypeForSalesDoc(SalesDocType::"Posted Return Receipt".AsInteger()), CopyPostedDeferral,
                             TempFromSalesLineBuf."Line No.")
                        then begin
                            if CopyItemTrkg then begin
                                if SplitLine then
                                    ItemTrackingDocMgt.CollectItemTrkgPerPostedDocLine(
                                      TempItemTrkgEntry, TempTrkgItemLedgEntry, false, TempFromSalesLineBuf."Document No.", TempFromSalesLineBuf."Line No.")
                                else
                                    ItemTrackingDocMgt.CopyItemLedgerEntriesToTemp(TempTrkgItemLedgEntry, ItemLedgEntry);

                                ItemTrackingMgt.CopyItemLedgEntryTrkgToSalesLn(
                                  TempTrkgItemLedgEntry, ToSalesLine,
                                  FillExactCostRevLink and ExactCostRevMandatory, MissingExCostRevLink,
                                  FromSalesHeader."Prices Including VAT", ToSalesHeader."Prices Including VAT", true);
                            end;
                            OnAfterCopySalesLineFromReturnRcptLineBuffer(
                              ToSalesLine, FromReturnRcptLine, IncludeHeader, RecalculateLines,
                              TempDocSalesLine, ToSalesHeader, TempFromSalesLineBuf, CopyItemTrkg);
                        end;
                    until TempFromSalesLineBuf.NEXT() = 0
                end;
            until FromReturnRcptLine.NEXT() = 0;

        Window.CLOSE();
    end;

    local procedure CopySalesLinesToBuffer(FromSalesHeader: Record "Sales Header"; FromSalesLine: Record "Sales Line"; var FromSalesLine2: Record "Sales Line"; var TempSalesLineBuf: Record "Sales Line" temporary; ToSalesHeader: Record "Sales Header"; var TempDocSalesLine: Record "Sales Line" temporary; DocNo: Code[20]; var NextLineNo: Integer)
    begin
        FromSalesLine2 := TempSalesLineBuf;
        TempSalesLineBuf := FromSalesLine;
        TempSalesLineBuf."Document No." := FromSalesLine2."Document No.";
        TempSalesLineBuf."Shipment Line No." := FromSalesLine2."Shipment Line No.";
        TempSalesLineBuf."Line No." := NextLineNo;
        OnAfterCopySalesLinesToBufferFields(TempSalesLineBuf, FromSalesLine2);

        NextLineNo := NextLineNo + 10000;
        if not IsRecalculateAmount(
             FromSalesHeader."Currency Code", ToSalesHeader."Currency Code",
             FromSalesHeader."Prices Including VAT", ToSalesHeader."Prices Including VAT")
        then
            TempSalesLineBuf."Return Receipt No." := DocNo;
        ReCalcSalesLine(FromSalesHeader, ToSalesHeader, TempSalesLineBuf);
        OnCopySalesLinesToBufferTransferFields(FromSalesHeader, FromSalesLine, TempSalesLineBuf);
        TempSalesLineBuf.INSERT();
        AddSalesDocLine(TempDocSalesLine, TempSalesLineBuf."Line No.", DocNo, FromSalesLine."Line No.");
    end;

    local procedure CopyItemLedgEntryTrackingToSalesLine(var TempItemLedgEntry: Record "Item Ledger Entry" temporary; var TempReservationEntry: Record "Reservation Entry" temporary; TempFromSalesLine: Record "Sales Line" temporary; ToSalesLine: Record "Sales Line"; ToSalesPricesInctVAT: Boolean; FromSalesPricesInctVAT: Boolean; FillExactCostRevLink: Boolean; var MissingExCostRevLink: Boolean)
    var
        TempTrkgItemLedgEntry: Record "Item Ledger Entry" temporary;
        AssemblyHeader: Record "Assembly Header";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        if MoveNegLines or not ExactCostRevMandatory then
            ItemTrackingDocMgt.CopyItemLedgerEntriesToTemp(TempTrkgItemLedgEntry, TempItemLedgEntry)
        else
            ItemTrackingDocMgt.CollectItemTrkgPerPostedDocLine(
              TempReservationEntry, TempTrkgItemLedgEntry, false, TempFromSalesLine."Document No.", TempFromSalesLine."Line No.");

        if ToSalesLine.AsmToOrderExists(AssemblyHeader) then
            SetTrackingOnAssemblyReservation(AssemblyHeader, TempItemLedgEntry)
        else
            ItemTrackingMgt.CopyItemLedgEntryTrkgToSalesLn(
              TempTrkgItemLedgEntry, ToSalesLine, FillExactCostRevLink and ExactCostRevMandatory, MissingExCostRevLink,
              FromSalesPricesInctVAT, ToSalesPricesInctVAT, false);
    end;

    local procedure SplitPstdSalesLinesPerILE(ToSalesHeader: Record "Sales Header"; FromSalesHeader: Record "Sales Header"; var ItemLedgEntry: Record "Item Ledger Entry"; var TempSalesLineBuf: Record "Sales Line" temporary; FromSalesLine: Record "Sales Line"; var TempDocSalesLine: Record "Sales Line" temporary; var NextLineNo: Integer; var CopyItemTrkg: Boolean; var MissingExCostRevLink: Boolean; FillExactCostRevLink: Boolean; FromShptOrRcpt: Boolean): Boolean
    var
        OrgQtyBase: Decimal;
    begin
        if FromShptOrRcpt then begin
            TempSalesLineBuf.RESET();
            TempSalesLineBuf.DELETEALL();
        end else
            TempSalesLineBuf.INIT();

        CopyItemTrkg := false;

        if (FromSalesLine.Type <> FromSalesLine.Type::Item) or (FromSalesLine.Quantity = 0) then
            exit(false);
        if IsCopyItemTrkg(ItemLedgEntry, CopyItemTrkg, FillExactCostRevLink) or
           not FillExactCostRevLink or MoveNegLines or
           not ExactCostRevMandatory
        then
            exit(false);

        ItemLedgEntry.FINDSET();
        if ItemLedgEntry.Quantity >= 0 then begin
            TempSalesLineBuf."Document No." := ItemLedgEntry."Document No.";
            if GetSalesDocType(ItemLedgEntry) in
               [TempSalesLineBuf."Document Type"::Order.AsInteger(), TempSalesLineBuf."Document Type"::"Return Order".AsInteger()]
            then
                TempSalesLineBuf."Shipment Line No." := 1;
            exit(false);
        end;
        OrgQtyBase := FromSalesLine."Quantity (Base)";
        repeat
            if ItemLedgEntry."Shipped Qty. Not Returned" = 0 then
                SkippedLine := true;

            if ItemLedgEntry."Shipped Qty. Not Returned" < 0 then begin
                TempSalesLineBuf := FromSalesLine;

                if -ItemLedgEntry."Shipped Qty. Not Returned" < ABS(FromSalesLine."Quantity (Base)") then begin
                    if FromSalesLine."Quantity (Base)" > 0 then
                        TempSalesLineBuf."Quantity (Base)" := -ItemLedgEntry."Shipped Qty. Not Returned"
                    else
                        TempSalesLineBuf."Quantity (Base)" := ItemLedgEntry."Shipped Qty. Not Returned";
                    if TempSalesLineBuf."Qty. per Unit of Measure" = 0 then
                        TempSalesLineBuf.Quantity := TempSalesLineBuf."Quantity (Base)"
                    else
                        TempSalesLineBuf.Quantity :=
                          ROUND(
                            TempSalesLineBuf."Quantity (Base)" / TempSalesLineBuf."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision());
                end;
                FromSalesLine."Quantity (Base)" := FromSalesLine."Quantity (Base)" - TempSalesLineBuf."Quantity (Base)";
                FromSalesLine.Quantity := FromSalesLine.Quantity - TempSalesLineBuf.Quantity;
                TempSalesLineBuf."Appl.-from Item Entry" := ItemLedgEntry."Entry No.";
                NextLineNo := NextLineNo + 1;
                TempSalesLineBuf."Line No." := NextLineNo;
                NextLineNo := NextLineNo + 1;
                TempSalesLineBuf."Document No." := ItemLedgEntry."Document No.";
                if GetSalesDocType(ItemLedgEntry) in
                   [TempSalesLineBuf."Document Type"::Order.AsInteger(), TempSalesLineBuf."Document Type"::"Return Order".AsInteger()]
                then
                    TempSalesLineBuf."Shipment Line No." := 1;

                if not FromShptOrRcpt then
                    UpdateRevSalesLineAmount(
                      TempSalesLineBuf, OrgQtyBase,
                      FromSalesHeader."Prices Including VAT", ToSalesHeader."Prices Including VAT");

                OnSplitPstdSalesLinesPerILETransferFields(FromSalesHeader, FromSalesLine, TempSalesLineBuf, ToSalesHeader);
                TempSalesLineBuf.INSERT();
                AddSalesDocLine(TempDocSalesLine, TempSalesLineBuf."Line No.", ItemLedgEntry."Document No.", TempSalesLineBuf."Line No.");
            end;
        until (ItemLedgEntry.NEXT() = 0) or (FromSalesLine."Quantity (Base)" = 0);

        if (FromSalesLine."Quantity (Base)" <> 0) and FillExactCostRevLink then
            MissingExCostRevLink := true;
        CheckUnappliedLines(SkippedLine, MissingExCostRevLink);
        exit(true);
    end;

    local procedure SplitSalesDocLinesPerItemTrkg(var ItemLedgEntry: Record "Item Ledger Entry"; var TempItemTrkgEntry: Record "Reservation Entry" temporary; var TempSalesLineBuf: Record "Sales Line" temporary; FromSalesLine: Record "Sales Line"; var TempDocSalesLine: Record "Sales Line" temporary; var NextLineNo: Integer; var NextItemTrkgEntryNo: Integer; var MissingExCostRevLink: Boolean; FromShptOrRcpt: Boolean): Boolean
    var
        SalesLineBuf: array[2] of Record "Sales Line" temporary;
        Tracked: Boolean;
        ReversibleQtyBase: Decimal;
        SignFactor: Integer;
        i: Integer;
    begin
        if FromShptOrRcpt then begin
            TempSalesLineBuf.RESET();
            TempSalesLineBuf.DELETEALL();
            TempItemTrkgEntry.RESET();
            TempItemTrkgEntry.DELETEALL();
        end else
            TempSalesLineBuf.INIT();

        if MoveNegLines or not ExactCostRevMandatory then
            exit(false);

        if FromSalesLine."Quantity (Base)" < 0 then
            SignFactor := -1
        else
            SignFactor := 1;

        ItemLedgEntry.SETCURRENTKEY("Document No.", "Document Type", "Document Line No.");
        ItemLedgEntry.FINDSET();
        repeat
            SalesLineBuf[1] := FromSalesLine;
            SalesLineBuf[1]."Line No." := NextLineNo;
            SalesLineBuf[1]."Quantity (Base)" := 0;
            SalesLineBuf[1].Quantity := 0;
            SalesLineBuf[1]."Document No." := ItemLedgEntry."Document No.";
            if GetSalesDocType(ItemLedgEntry) in
               [SalesLineBuf[1]."Document Type"::Order.AsInteger(), SalesLineBuf[1]."Document Type"::"Return Order".AsInteger()]
            then
                SalesLineBuf[1]."Shipment Line No." := 1;
            SalesLineBuf[2] := SalesLineBuf[1];
            SalesLineBuf[2]."Line No." := SalesLineBuf[2]."Line No." + 1;

            if not FromShptOrRcpt then begin
                ItemLedgEntry.SETRANGE("Document No.", ItemLedgEntry."Document No.");
                ItemLedgEntry.SETRANGE("Document Type", ItemLedgEntry."Document Type");
                ItemLedgEntry.SETRANGE("Document Line No.", ItemLedgEntry."Document Line No.");
            end;
            repeat
                i := 1;
                if not ItemLedgEntry.Positive then
                    ItemLedgEntry."Shipped Qty. Not Returned" :=
                      ItemLedgEntry."Shipped Qty. Not Returned" -
                      CalcDistributedQty(TempItemTrkgEntry, ItemLedgEntry, SalesLineBuf[2]."Line No." + 1);
                if ItemLedgEntry."Shipped Qty. Not Returned" = 0 then
                    SkippedLine := true;

                if ItemLedgEntry."Document Type" in [ItemLedgEntry."Document Type"::"Sales Return Receipt", ItemLedgEntry."Document Type"::"Sales Credit Memo"] then
                    if ItemLedgEntry."Remaining Quantity" < FromSalesLine."Quantity (Base)" * SignFactor then
                        ReversibleQtyBase := ItemLedgEntry."Remaining Quantity" * SignFactor
                    else
                        ReversibleQtyBase := FromSalesLine."Quantity (Base)"
                else
                    if ItemLedgEntry.Positive then begin
                        ReversibleQtyBase := ItemLedgEntry."Remaining Quantity";
                        if ReversibleQtyBase < FromSalesLine."Quantity (Base)" * SignFactor then
                            ReversibleQtyBase := ReversibleQtyBase * SignFactor
                        else
                            ReversibleQtyBase := FromSalesLine."Quantity (Base)";
                    end else
                        if -ItemLedgEntry."Shipped Qty. Not Returned" < FromSalesLine."Quantity (Base)" * SignFactor then
                            ReversibleQtyBase := -ItemLedgEntry."Shipped Qty. Not Returned" * SignFactor
                        else
                            ReversibleQtyBase := FromSalesLine."Quantity (Base)";

                if ReversibleQtyBase <> 0 then begin
                    if not ItemLedgEntry.Positive then
                        if IsSplitItemLedgEntry(ItemLedgEntry) then
                            i := 2;

                    SalesLineBuf[i]."Quantity (Base)" := SalesLineBuf[i]."Quantity (Base)" + ReversibleQtyBase;
                    if SalesLineBuf[i]."Qty. per Unit of Measure" = 0 then
                        SalesLineBuf[i].Quantity := SalesLineBuf[i]."Quantity (Base)"
                    else
                        SalesLineBuf[i].Quantity :=
                          ROUND(
                            SalesLineBuf[i]."Quantity (Base)" / SalesLineBuf[i]."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision());
                    FromSalesLine."Quantity (Base)" := FromSalesLine."Quantity (Base)" - ReversibleQtyBase;
                    // Fill buffer with exact cost reversing link
                    InsertTempItemTrkgEntry(
                      ItemLedgEntry, TempItemTrkgEntry, -ABS(ReversibleQtyBase),
                      SalesLineBuf[i]."Line No.", NextItemTrkgEntryNo, true);
                    Tracked := true;
                end;
            until (ItemLedgEntry.NEXT() = 0) or (FromSalesLine."Quantity (Base)" = 0);

            for i := 1 to 2 do
                if SalesLineBuf[i]."Quantity (Base)" <> 0 then begin
                    TempSalesLineBuf := SalesLineBuf[i];
                    TempSalesLineBuf.INSERT();
                    AddSalesDocLine(TempDocSalesLine, TempSalesLineBuf."Line No.", ItemLedgEntry."Document No.", FromSalesLine."Line No.");
                    NextLineNo := SalesLineBuf[i]."Line No." + 1;
                end;

            if not FromShptOrRcpt then begin
                ItemLedgEntry.SETRANGE("Document No.");
                ItemLedgEntry.SETRANGE("Document Type");
                ItemLedgEntry.SETRANGE("Document Line No.");
            end;
        until (ItemLedgEntry.NEXT() = 0) or FromShptOrRcpt;

        if (FromSalesLine."Quantity (Base)" <> 0) and not Tracked then
            MissingExCostRevLink := true;
        CheckUnappliedLines(SkippedLine, MissingExCostRevLink);

        exit(true);
    end;

    procedure CopyPurchRcptLinesToDoc(ToPurchHeader: Record "Purchase Header"; var FromPurchRcptLine: Record "Purch. Rcpt. Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempTrkgItemLedgEntry: Record "Item Ledger Entry" temporary;
        FromPurchHeader: Record "Purchase Header";
        FromPurchLine: Record "Purchase Line";
        OriginalPurchHeader: Record "Purchase Header";
        ToPurchLine: Record "Purchase Line";
        TempFromPurchLineBuf: Record "Purchase Line" temporary;
        FromPurchRcptHeader: Record "Purch. Rcpt. Header";
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        TempDocPurchaseLine: Record "Purchase Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        OldDocNo: Code[20];
        NextLineNo: Integer;
        NextItemTrkgEntryNo: Integer;
        FromLineCounter: Integer;
        ToLineCounter: Integer;
        CopyItemTrkg: Boolean;
        FillExactCostRevLink: Boolean;
        SplitLine: Boolean;
        CopyLine: Boolean;
        InsertDocNoLine: Boolean;
    begin
        MissingExCostRevLink := false;
        InitCurrency(ToPurchHeader."Currency Code");
        OpenWindow();

        if FromPurchRcptLine.FINDSET() then
            repeat
                FromLineCounter := FromLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(1, FromLineCounter);
                if FromPurchRcptHeader."No." <> FromPurchRcptLine."Document No." then begin
                    FromPurchRcptHeader.GET(FromPurchRcptLine."Document No.");
                    if OriginalPurchHeader.GET(OriginalPurchHeader."Document Type"::Order, FromPurchRcptHeader."Order No.") then
                        OriginalPurchHeader.TESTFIELD("Prices Including VAT", ToPurchHeader."Prices Including VAT");
                    TransferOldExtLines.ClearLineNumbers();
                end;
                FromPurchHeader.TRANSFERFIELDS(FromPurchRcptHeader);
                FillExactCostRevLink :=
                  IsPurchFillExactCostRevLink(ToPurchHeader, 0, FromPurchHeader."Currency Code");
                FromPurchLine.TRANSFERFIELDS(FromPurchRcptLine);
                FromPurchLine."Appl.-to Item Entry" := 0;
                FromPurchLine."Copied From Posted Doc." := true;

                OnCopyPurchRcptLinesToDocOnAfterTransferFields(FromPurchLine, FromPurchHeader, ToPurchHeader, FromPurchRcptHeader);

                if FromPurchRcptLine."Document No." <> OldDocNo then begin
                    OldDocNo := FromPurchRcptLine."Document No.";
                    InsertDocNoLine := true;
                end;

                SplitLine := true;
                FromPurchRcptLine.FilterPstdDocLnItemLedgEntries(ItemLedgEntry);
                if not SplitPstdPurchLinesPerILE(
                     ToPurchHeader, FromPurchHeader, ItemLedgEntry, TempFromPurchLineBuf,
                     FromPurchLine, TempDocPurchaseLine, NextLineNo, CopyItemTrkg, MissingExCostRevLink, FillExactCostRevLink, true)
                then
                    if CopyItemTrkg then
                        SplitLine :=
                          SplitPurchDocLinesPerItemTrkg(
                            ItemLedgEntry, TempItemTrkgEntry, TempFromPurchLineBuf,
                            FromPurchLine, TempDocPurchaseLine, NextLineNo, NextItemTrkgEntryNo, MissingExCostRevLink, true)
                    else
                        SplitLine := false;

                if not SplitLine then begin
                    TempFromPurchLineBuf := FromPurchLine;
                    CopyLine := true;
                end else
                    CopyLine := TempFromPurchLineBuf.FINDSET() and FillExactCostRevLink;

                Window.UPDATE(1, FromLineCounter);
                if CopyLine then begin
                    NextLineNo := GetLastToPurchLineNo(ToPurchHeader);
                    if InsertDocNoLine then begin
                        InsertOldPurchDocNoLine(ToPurchHeader, FromPurchRcptLine."Document No.", 1, NextLineNo);
                        InsertDocNoLine := false;
                    end;
                    repeat
                        ToLineCounter := ToLineCounter + 1;
                        if IsTimeForUpdate() then
                            Window.UPDATE(2, ToLineCounter);
                        if FromPurchLine."Prod. Order No." <> '' then
                            FromPurchLine."Quantity (Base)" := 0;

                        OnCopyPurchRcptLinesToDocOnBeforeCopyPurchLine(ToPurchHeader, TempFromPurchLineBuf);

                        if CopyPurchLine(ToPurchHeader, ToPurchLine, FromPurchHeader, TempFromPurchLineBuf, NextLineNo, LinesNotCopied,
                             false, DeferralTypeForPurchDoc(PurchDocType::"Posted Receipt".AsInteger()), CopyPostedDeferral, TempFromPurchLineBuf."Line No.")
                        then begin
                            if CopyItemTrkg then begin
                                if SplitLine then
                                    ItemTrackingDocMgt.CollectItemTrkgPerPostedDocLine(
                                      TempItemTrkgEntry, TempTrkgItemLedgEntry, true, TempFromPurchLineBuf."Document No.", TempFromPurchLineBuf."Line No.")
                                else
                                    ItemTrackingDocMgt.CopyItemLedgerEntriesToTemp(TempTrkgItemLedgEntry, ItemLedgEntry);

                                ItemTrackingMgt.CopyItemLedgEntryTrkgToPurchLn(
                                  TempTrkgItemLedgEntry, ToPurchLine,
                                  FillExactCostRevLink and ExactCostRevMandatory, MissingExCostRevLink,
                                  FromPurchHeader."Prices Including VAT", ToPurchHeader."Prices Including VAT", true);
                            end;
                            OnAfterCopyPurchLineFromPurchRcptLineBuffer(
                              ToPurchLine, FromPurchRcptLine, IncludeHeader, RecalculateLines,
                              TempDocPurchaseLine, ToPurchHeader, TempFromPurchLineBuf, CopyItemTrkg);
                        end;
                    until TempFromPurchLineBuf.NEXT() = 0;
                    OnAfterCopyPurchRcptLine(FromPurchRcptLine, ToPurchLine);
                end;
            until FromPurchRcptLine.NEXT() = 0;

        Window.CLOSE();
    end;

    procedure CopyPurchInvLinesToDoc(ToPurchHeader: Record "Purchase Header"; var FromPurchCrMemoLine: Record "Purch. Cr. Memo Line"; var FromPurchInvLine: Record "Purch. Inv. Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        TempItemLedgEntryBuf: Record "Item Ledger Entry" temporary;
        TempTrkgItemLedgEntry: Record "Item Ledger Entry" temporary;
        FromPurchHeader: Record "Purchase Header";
        FromPurchLine: Record "Purchase Line";
        FromPurchLine2: Record "Purchase Line";
        ToPurchLine: Record "Purchase Line";
        TempFromPurchLineBuf: Record "Purchase Line" temporary;
        FromPurchInvHeader: Record "Purch. Inv. Header";
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        TempDocPurchaseLine: Record "Purchase Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        OldInvDocNo: Code[20];
        OldRcptDocNo: Code[20];
        OldBufDocNo: Code[20];
        NextLineNo: Integer;
        NextItemTrkgEntryNo: Integer;
        FromLineCounter: Integer;
        ToLineCounter: Integer;
        CopyItemTrkg: Boolean;
        SplitLine: Boolean;
        FillExactCostRevLink: Boolean;
        ItemChargeAssgntNextLineNo: Integer;
    begin
        MissingExCostRevLink := false;
        InitCurrency(ToPurchHeader."Currency Code");
        TempFromPurchLineBuf.RESET();
        TempFromPurchLineBuf.DELETEALL();
        TempItemTrkgEntry.RESET();
        TempItemTrkgEntry.DELETEALL();
        OpenWindow();

        OnBeforeCopyPurchInvLines(TempDocPurchaseLine, ToPurchHeader, FromPurchInvLine);
        // Fill purchase line buffer
        if FromPurchInvLine.FINDSET() then
            repeat
                FromLineCounter := FromLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(1, FromLineCounter);
                if FromPurchInvHeader."No." <> FromPurchInvLine."Document No." then begin
                    FromPurchInvHeader.GET(FromPurchInvLine."Document No.");
                    FromPurchInvHeader.TESTFIELD("Prices Including VAT", ToPurchHeader."Prices Including VAT");
                    TransferOldExtLines.ClearLineNumbers();
                end;
                FromPurchHeader.TRANSFERFIELDS(FromPurchInvHeader);
                FillExactCostRevLink := IsPurchFillExactCostRevLink(ToPurchHeader, 1, FromPurchHeader."Currency Code");
                FromPurchLine.TRANSFERFIELDS(FromPurchInvLine);
                FromPurchLine."Appl.-to Item Entry" := 0;
                // Reuse fields to buffer invoice line information
                FromPurchLine."Receipt No." := FromPurchInvLine."Document No.";
                FromPurchLine."Receipt Line No." := 0;
                FromPurchLine."Return Shipment No." := '';
                FromPurchLine."Return Shipment Line No." := FromPurchInvLine."Line No.";
                FromPurchLine."Copied From Posted Doc." := true;

                OnCopyPurchInvLinesToDocOnAfterTransferFields(FromPurchLine, FromPurchHeader, ToPurchHeader);

                SplitLine := true;
                FromPurchInvLine.GetItemLedgEntries(TempItemLedgEntryBuf, true);
                if not SplitPstdPurchLinesPerILE(
                     ToPurchHeader, FromPurchHeader, TempItemLedgEntryBuf, TempFromPurchLineBuf,
                     FromPurchLine, TempDocPurchaseLine, NextLineNo, CopyItemTrkg, MissingExCostRevLink, FillExactCostRevLink, false)
                then
                    if CopyItemTrkg then
                        SplitLine := SplitPurchDocLinesPerItemTrkg(
                            TempItemLedgEntryBuf, TempItemTrkgEntry, TempFromPurchLineBuf,
                            FromPurchLine, TempDocPurchaseLine, NextLineNo, NextItemTrkgEntryNo, MissingExCostRevLink, false)
                    else
                        SplitLine := false;

                if not SplitLine then
                    CopyPurchLinesToBuffer(
                      FromPurchHeader, FromPurchLine, FromPurchLine2, TempFromPurchLineBuf, ToPurchHeader, TempDocPurchaseLine,
                      FromPurchInvLine."Document No.", NextLineNo);

                OnAfterCopyPurchInvLines(TempDocPurchaseLine, ToPurchHeader, TempFromPurchLineBuf, FromPurchInvLine);
            until FromPurchInvLine.NEXT() = 0;

        // Create purchase line from buffer
        Window.UPDATE(1, FromLineCounter);
        // Sorting according to Purchase Line Document No.,Line No.
        TempFromPurchLineBuf.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        if TempFromPurchLineBuf.FINDSET() then begin
            NextLineNo := GetLastToPurchLineNo(ToPurchHeader);
            repeat
                ToLineCounter := ToLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(2, ToLineCounter);
                if TempFromPurchLineBuf."Receipt No." <> OldInvDocNo then begin
                    OldInvDocNo := TempFromPurchLineBuf."Receipt No.";
                    OldRcptDocNo := '';
                    InsertOldPurchDocNoLine(ToPurchHeader, OldInvDocNo, 2, NextLineNo);
                end;
                if (TempFromPurchLineBuf."Document No." <> OldRcptDocNo) and (TempFromPurchLineBuf."Receipt Line No." > 0) then begin
                    OldRcptDocNo := TempFromPurchLineBuf."Document No.";
                    InsertOldPurchCombDocNoLine(ToPurchHeader, OldInvDocNo, OldRcptDocNo, NextLineNo, true);
                end;
                // Empty buffer fields
                FromPurchLine2 := TempFromPurchLineBuf;
                FromPurchLine2."Receipt No." := '';
                FromPurchLine2."Receipt Line No." := 0;
                FromPurchLine2."Return Shipment No." := '';
                FromPurchLine2."Return Shipment Line No." := 0;
                if GetPurchDocNo(TempDocPurchaseLine, TempFromPurchLineBuf."Line No.") <> OldBufDocNo then begin
                    OldBufDocNo := GetPurchDocNo(TempDocPurchaseLine, TempFromPurchLineBuf."Line No.");
                    TransferOldExtLines.ClearLineNumbers();
                end;

                OnCopyPurchInvLinesToDocOnBeforeCopyPurchLine(ToPurchHeader, FromPurchLine2);

                if CopyPurchLine(ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine2, NextLineNo, LinesNotCopied,
                     TempFromPurchLineBuf."Return Shipment No." = '', DeferralTypeForPurchDoc(PurchDocType::"Posted Invoice".AsInteger()), CopyPostedDeferral,
                     GetPurchLineNo(TempDocPurchaseLine, FromPurchLine2."Line No."))
                then begin
                    if CopyPostedDeferral then
                        CopyPurchPostedDeferrals(
                         ToPurchLine, "Deferral Document Type"::Purchase.AsInteger(),
                         DeferralTypeForPurchDoc("Purchase Document Type From"::"Posted Credit Memo".AsInteger()), TempFromPurchLineBuf."Receipt No.",
                         TempFromPurchLineBuf."Return Shipment Line No.", ToPurchLine."Document Type".AsInteger(), ToPurchLine."Document No.", ToPurchLine."Line No.");
                    FromPurchCrMemoLine.Get(TempFromPurchLineBuf."Receipt No.", TempFromPurchLineBuf."Return Shipment Line No.");
                    // copy item charges
                    if TempFromPurchLineBuf.Type = TempFromPurchLineBuf.Type::"Charge (Item)" then begin
                        FromPurchLine.TRANSFERFIELDS(FromPurchInvLine);
                        FromPurchLine."Document Type" := FromPurchLine."Document Type"::Invoice;
                        CopyFromPurchLineItemChargeAssign(FromPurchLine, ToPurchLine, FromPurchHeader, ItemChargeAssgntNextLineNo);
                    end;
                    // copy item tracking
                    if (TempFromPurchLineBuf.Type = TempFromPurchLineBuf.Type::Item) and (TempFromPurchLineBuf.Quantity <> 0) and (TempFromPurchLineBuf."Prod. Order No." = '') and
                       PurchaseDocCanReceiveTracking(ToPurchHeader)
                    then begin
                        FromPurchInvLine."Document No." := OldInvDocNo;
                        FromPurchInvLine."Line No." := TempFromPurchLineBuf."Return Shipment Line No.";
                        FromPurchInvLine.GetItemLedgEntries(TempItemLedgEntryBuf, true);
                        if IsCopyItemTrkg(TempItemLedgEntryBuf, CopyItemTrkg, FillExactCostRevLink) then begin
                            if TempFromPurchLineBuf."Job No." <> '' then
                                TempItemLedgEntryBuf.SETFILTER("Entry Type", '<> %1', TempItemLedgEntryBuf."Entry Type"::"Negative Adjmt.");
                            if MoveNegLines or not ExactCostRevMandatory then
                                ItemTrackingDocMgt.CopyItemLedgerEntriesToTemp(TempTrkgItemLedgEntry, TempItemLedgEntryBuf)
                            else
                                ItemTrackingDocMgt.CollectItemTrkgPerPostedDocLine(
                                  TempItemTrkgEntry, TempTrkgItemLedgEntry, true, TempFromPurchLineBuf."Document No.", TempFromPurchLineBuf."Line No.");

                            ItemTrackingMgt.CopyItemLedgEntryTrkgToPurchLn(TempTrkgItemLedgEntry, ToPurchLine,
                              FillExactCostRevLink and ExactCostRevMandatory, MissingExCostRevLink,
                              FromPurchHeader."Prices Including VAT", ToPurchHeader."Prices Including VAT", false);
                        end;
                    end;
                    OnAfterCopyPurchLineFromPurchLineBuffer(
                      ToPurchLine, FromPurchInvLine, IncludeHeader, RecalculateLines, TempDocPurchaseLine, ToPurchHeader, TempFromPurchLineBuf);
                end;
                OnAfterCopyPurchInvLine(FromPurchInvLine, ToPurchLine);
            until TempFromPurchLineBuf.NEXT() = 0;
        end;

        Window.CLOSE();
    end;

    procedure CopyPurchCrMemoLinesToDoc(ToPurchHeader: Record "Purchase Header"; var FromPurchCrMemoLine: Record "Purch. Cr. Memo Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        TempItemLedgEntryBuf: Record "Item Ledger Entry" temporary;
        TempTrkgItemLedgEntry: Record "Item Ledger Entry" temporary;
        FromPurchHeader: Record "Purchase Header";
        FromPurchLine: Record "Purchase Line";
        FromPurchLine2: Record "Purchase Line";
        ToPurchLine: Record "Purchase Line";
        TempFromPurchLineBuf: Record "Purchase Line" temporary;
        FromPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        TempDocPurchaseLine: Record "Purchase Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        OldCrMemoDocNo: Code[20];
        OldReturnShptDocNo: Code[20];
        OldBufDocNo: Code[20];
        NextLineNo: Integer;
        NextItemTrkgEntryNo: Integer;
        FromLineCounter: Integer;
        ToLineCounter: Integer;
        ItemChargeAssgntNextLineNo: Integer;
        CopyItemTrkg: Boolean;
        SplitLine: Boolean;
        FillExactCostRevLink: Boolean;
    begin
        MissingExCostRevLink := false;
        InitCurrency(ToPurchHeader."Currency Code");
        TempFromPurchLineBuf.RESET();
        TempFromPurchLineBuf.DELETEALL();
        TempItemTrkgEntry.RESET();
        TempItemTrkgEntry.DELETEALL();
        OpenWindow();

        OnBeforeCopyPurchCrMemoLinesToDoc(TempDocPurchaseLine, ToPurchHeader, FromPurchCrMemoLine);
        // Fill purchase line buffer
        if FromPurchCrMemoLine.FINDSET() then
            repeat
                FromLineCounter := FromLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(1, FromLineCounter);
                if FromPurchCrMemoHeader."No." <> FromPurchCrMemoLine."Document No." then begin
                    FromPurchCrMemoHeader.GET(FromPurchCrMemoLine."Document No.");
                    FromPurchCrMemoHeader.TESTFIELD("Prices Including VAT", ToPurchHeader."Prices Including VAT");
                    TransferOldExtLines.ClearLineNumbers();
                end;
                FromPurchHeader.TRANSFERFIELDS(FromPurchCrMemoHeader);
                FillExactCostRevLink :=
                  IsPurchFillExactCostRevLink(ToPurchHeader, 3, FromPurchHeader."Currency Code");
                FromPurchLine.TRANSFERFIELDS(FromPurchCrMemoLine);
                FromPurchLine."Appl.-to Item Entry" := 0;
                // Reuse fields to buffer credit memo line information
                FromPurchLine."Receipt No." := FromPurchCrMemoLine."Document No.";
                FromPurchLine."Receipt Line No." := 0;
                FromPurchLine."Return Shipment No." := '';
                FromPurchLine."Return Shipment Line No." := FromPurchCrMemoLine."Line No.";
                FromPurchLine."Copied From Posted Doc." := true;

                OnCopyPurchCrMemoLinesToDocOnAfterTransferFields(FromPurchLine, FromPurchHeader, ToPurchHeader, FromPurchCrMemoHeader);

                SplitLine := true;
                FromPurchCrMemoLine.GetItemLedgEntries(TempItemLedgEntryBuf, true);
                if not SplitPstdPurchLinesPerILE(
                     ToPurchHeader, FromPurchHeader, TempItemLedgEntryBuf, TempFromPurchLineBuf,
                     FromPurchLine, TempDocPurchaseLine, NextLineNo, CopyItemTrkg, MissingExCostRevLink, FillExactCostRevLink, false)
                then
                    if CopyItemTrkg then
                        SplitLine :=
                          SplitPurchDocLinesPerItemTrkg(
                            TempItemLedgEntryBuf, TempItemTrkgEntry, TempFromPurchLineBuf,
                            FromPurchLine, TempDocPurchaseLine, NextLineNo, NextItemTrkgEntryNo, MissingExCostRevLink, false)
                    else
                        SplitLine := false;

                if not SplitLine then
                    CopyPurchLinesToBuffer(
                      FromPurchHeader, FromPurchLine, FromPurchLine2, TempFromPurchLineBuf, ToPurchHeader, TempDocPurchaseLine,
                      FromPurchCrMemoLine."Document No.", NextLineNo);
            until FromPurchCrMemoLine.NEXT() = 0;

        // Create purchase line from buffer
        Window.UPDATE(1, FromLineCounter);
        // Sorting according to Purchase Line Document No.,Line No.
        TempFromPurchLineBuf.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        if TempFromPurchLineBuf.FINDSET() then begin
            NextLineNo := GetLastToPurchLineNo(ToPurchHeader);
            repeat
                ToLineCounter := ToLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(2, ToLineCounter);
                if TempFromPurchLineBuf."Receipt No." <> OldCrMemoDocNo then begin
                    OldCrMemoDocNo := TempFromPurchLineBuf."Receipt No.";
                    OldReturnShptDocNo := '';
                    InsertOldPurchDocNoLine(ToPurchHeader, OldCrMemoDocNo, 4, NextLineNo);
                end;
                if TempFromPurchLineBuf."Document No." <> OldReturnShptDocNo then begin
                    OldReturnShptDocNo := TempFromPurchLineBuf."Document No.";
                    InsertOldPurchCombDocNoLine(ToPurchHeader, OldCrMemoDocNo, OldReturnShptDocNo, NextLineNo, false);
                end;
                // Empty buffer fields
                FromPurchLine2 := TempFromPurchLineBuf;
                FromPurchLine2."Receipt No." := '';
                FromPurchLine2."Receipt Line No." := 0;
                FromPurchLine2."Return Shipment No." := '';
                FromPurchLine2."Return Shipment Line No." := 0;
                if GetPurchDocNo(TempDocPurchaseLine, TempFromPurchLineBuf."Line No.") <> OldBufDocNo then begin
                    OldBufDocNo := GetPurchDocNo(TempDocPurchaseLine, TempFromPurchLineBuf."Line No.");
                    TransferOldExtLines.ClearLineNumbers();
                end;

                OnCopyPurchCrMemoLinesToDocOnBeforeCopyPurchLine(ToPurchHeader, FromPurchLine2);

                if CopyPurchLine(ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine2, NextLineNo, LinesNotCopied,
                     TempFromPurchLineBuf."Return Shipment No." = '', DeferralTypeForPurchDoc(PurchDocType::"Posted Credit Memo".AsInteger()), CopyPostedDeferral,
                     GetPurchLineNo(TempDocPurchaseLine, FromPurchLine2."Line No."))
                then begin
                    if CopyPostedDeferral then
                        CopyPurchPostedDeferrals(
                         ToPurchLine, "Deferral Document Type"::Purchase.AsInteger(),
                         DeferralTypeForPurchDoc("Purchase Document Type From"::"Posted Credit Memo".AsInteger()), TempFromPurchLineBuf."Receipt No.",
                         TempFromPurchLineBuf."Return Shipment Line No.", ToPurchLine."Document Type".AsInteger(), ToPurchLine."Document No.", ToPurchLine."Line No.");
                    FromPurchCrMemoLine.Get(TempFromPurchLineBuf."Receipt No.", TempFromPurchLineBuf."Return Shipment Line No.");
                    // copy item charges
                    if TempFromPurchLineBuf.Type = TempFromPurchLineBuf.Type::"Charge (Item)" then begin
                        FromPurchLine.TRANSFERFIELDS(FromPurchCrMemoLine);
                        FromPurchLine."Document Type" := FromPurchLine."Document Type"::"Credit Memo";
                        CopyFromPurchLineItemChargeAssign(FromPurchLine, ToPurchLine, FromPurchHeader, ItemChargeAssgntNextLineNo);
                    end;
                    // copy item tracking
                    if (TempFromPurchLineBuf.Type = TempFromPurchLineBuf.Type::Item) and (TempFromPurchLineBuf.Quantity <> 0) and (TempFromPurchLineBuf."Prod. Order No." = '') then begin
                        FromPurchCrMemoLine."Document No." := OldCrMemoDocNo;
                        FromPurchCrMemoLine."Line No." := TempFromPurchLineBuf."Return Shipment Line No.";
                        FromPurchCrMemoLine.GetItemLedgEntries(TempItemLedgEntryBuf, true);
                        if IsCopyItemTrkg(TempItemLedgEntryBuf, CopyItemTrkg, FillExactCostRevLink) then begin
                            if TempFromPurchLineBuf."Job No." <> '' then
                                TempItemLedgEntryBuf.SETFILTER("Entry Type", '<> %1', TempItemLedgEntryBuf."Entry Type"::"Negative Adjmt.");
                            if MoveNegLines or not ExactCostRevMandatory then
                                ItemTrackingDocMgt.CopyItemLedgerEntriesToTemp(TempTrkgItemLedgEntry, TempItemLedgEntryBuf)
                            else
                                ItemTrackingDocMgt.CollectItemTrkgPerPostedDocLine(
                                  TempItemTrkgEntry, TempTrkgItemLedgEntry, true, TempFromPurchLineBuf."Document No.", TempFromPurchLineBuf."Line No.");

                            ItemTrackingMgt.CopyItemLedgEntryTrkgToPurchLn(
                              TempTrkgItemLedgEntry, ToPurchLine,
                              FillExactCostRevLink and ExactCostRevMandatory, MissingExCostRevLink,
                              FromPurchHeader."Prices Including VAT", ToPurchHeader."Prices Including VAT", false);
                        end;
                    end;
                    OnAfterCopyPurchLineFromPurchCrMemoLineBuffer(
                      ToPurchLine, FromPurchCrMemoLine, IncludeHeader, RecalculateLines, TempDocPurchaseLine, ToPurchHeader, TempFromPurchLineBuf);
                end;
                OnAfterCopyPurchCrMemoLine(FromPurchCrMemoLine, ToPurchLine);
            until TempFromPurchLineBuf.NEXT() = 0;
        end;

        Window.CLOSE();
    end;

    procedure CopyPurchReturnShptLinesToDoc(ToPurchHeader: Record "Purchase Header"; var FromReturnShptLine: Record "Return Shipment Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempTrkgItemLedgEntry: Record "Item Ledger Entry" temporary;
        FromPurchHeader: Record "Purchase Header";
        FromPurchLine: Record "Purchase Line";
        OriginalPurchHeader: Record "Purchase Header";
        ToPurchLine: Record "Purchase Line";
        TempFromPurchLineBuf: Record "Purchase Line" temporary;
        FromReturnShptHeader: Record "Return Shipment Header";
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        TempDocPurchaseLine: Record "Purchase Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        OldDocNo: Code[20];
        NextLineNo: Integer;
        NextItemTrkgEntryNo: Integer;
        FromLineCounter: Integer;
        ToLineCounter: Integer;
        CopyItemTrkg: Boolean;
        SplitLine: Boolean;
        FillExactCostRevLink: Boolean;
        CopyLine: Boolean;
        InsertDocNoLine: Boolean;
    begin
        MissingExCostRevLink := false;
        InitCurrency(ToPurchHeader."Currency Code");
        OpenWindow();

        OnBeforeCopyPurchReturnShptLinesToDoc(TempDocPurchaseLine, ToPurchHeader, FromReturnShptLine);

        if FromReturnShptLine.FINDSET() then
            repeat
                FromLineCounter := FromLineCounter + 1;
                if IsTimeForUpdate() then
                    Window.UPDATE(1, FromLineCounter);
                if FromReturnShptHeader."No." <> FromReturnShptLine."Document No." then begin
                    FromReturnShptHeader.GET(FromReturnShptLine."Document No.");
                    if OriginalPurchHeader.GET(OriginalPurchHeader."Document Type"::"Return Order", FromReturnShptHeader."Return Order No.") then
                        OriginalPurchHeader.TESTFIELD("Prices Including VAT", ToPurchHeader."Prices Including VAT");
                    TransferOldExtLines.ClearLineNumbers();
                end;
                FromPurchHeader.TRANSFERFIELDS(FromReturnShptHeader);
                FillExactCostRevLink :=
                  IsPurchFillExactCostRevLink(ToPurchHeader, 2, FromPurchHeader."Currency Code");
                FromPurchLine.TRANSFERFIELDS(FromReturnShptLine);
                FromPurchLine.VALIDATE("Order No.", FromReturnShptLine."Return Order No.");
                FromPurchLine.VALIDATE("Order Line No.", FromReturnShptLine."Return Order Line No.");
                FromPurchLine."Appl.-to Item Entry" := 0;
                FromPurchLine."Copied From Posted Doc." := true;

                OnCopyPurchReturnShptLinesToDocOnAfterTransferFields(
                  FromPurchLine, FromPurchHeader, ToPurchHeader, FromReturnShptHeader);

                if FromReturnShptLine."Document No." <> OldDocNo then begin
                    OldDocNo := FromReturnShptLine."Document No.";
                    InsertDocNoLine := true;
                end;

                SplitLine := true;
                FromReturnShptLine.FilterPstdDocLnItemLedgEntries(ItemLedgEntry);
                if not SplitPstdPurchLinesPerILE(
                     ToPurchHeader, FromPurchHeader, ItemLedgEntry, TempFromPurchLineBuf,
                     FromPurchLine, TempDocPurchaseLine, NextLineNo, CopyItemTrkg, MissingExCostRevLink, FillExactCostRevLink, true)
                then
                    if CopyItemTrkg then
                        SplitLine :=
                          SplitPurchDocLinesPerItemTrkg(
                            ItemLedgEntry, TempItemTrkgEntry, TempFromPurchLineBuf,
                            FromPurchLine, TempDocPurchaseLine, NextLineNo, NextItemTrkgEntryNo, MissingExCostRevLink, true)
                    else
                        SplitLine := false;

                if not SplitLine then begin
                    TempFromPurchLineBuf := FromPurchLine;
                    CopyLine := true;
                end else
                    CopyLine := TempFromPurchLineBuf.FINDSET() and FillExactCostRevLink;

                Window.UPDATE(1, FromLineCounter);
                if CopyLine then begin
                    NextLineNo := GetLastToPurchLineNo(ToPurchHeader);
                    if InsertDocNoLine then begin
                        InsertOldPurchDocNoLine(ToPurchHeader, FromReturnShptLine."Document No.", 3, NextLineNo);
                        InsertDocNoLine := false;
                    end;
                    repeat
                        ToLineCounter := ToLineCounter + 1;
                        if IsTimeForUpdate() then
                            Window.UPDATE(2, ToLineCounter);

                        OnCopyPurchReturnShptLinesToDocOnBeforeCopyPurchLine(ToPurchHeader, TempFromPurchLineBuf);

                        if CopyPurchLine(ToPurchHeader, ToPurchLine, FromPurchHeader, TempFromPurchLineBuf, NextLineNo, LinesNotCopied,
                             false, DeferralTypeForPurchDoc(PurchDocType::"Posted Return Shipment".AsInteger()), CopyPostedDeferral,
                             TempFromPurchLineBuf."Line No.")
                        then begin
                            if CopyItemTrkg then begin
                                if SplitLine then
                                    ItemTrackingDocMgt.CollectItemTrkgPerPostedDocLine(
                                      TempItemTrkgEntry, TempTrkgItemLedgEntry, true, TempFromPurchLineBuf."Document No.", TempFromPurchLineBuf."Line No.")
                                else
                                    ItemTrackingDocMgt.CopyItemLedgerEntriesToTemp(TempTrkgItemLedgEntry, ItemLedgEntry);

                                ItemTrackingMgt.CopyItemLedgEntryTrkgToPurchLn(
                                  TempTrkgItemLedgEntry, ToPurchLine,
                                  FillExactCostRevLink and ExactCostRevMandatory, MissingExCostRevLink,
                                  FromPurchHeader."Prices Including VAT", ToPurchHeader."Prices Including VAT", true);
                            end;
                            OnAfterCopyPurchLineFromReturnShptLineBuffer(
                              ToPurchLine, FromReturnShptLine, IncludeHeader, RecalculateLines,
                              TempDocPurchaseLine, ToPurchHeader, TempFromPurchLineBuf, CopyItemTrkg);
                        end;
                    until TempFromPurchLineBuf.NEXT() = 0;
                end;
                OnAfterCopyReturnShptLine(FromReturnShptLine, ToPurchLine);
            until FromReturnShptLine.NEXT() = 0;

        Window.CLOSE();
    end;

    local procedure CopyPurchLinesToBuffer(FromPurchHeader: Record "Purchase Header"; FromPurchLine: Record "Purchase Line"; var FromPurchLine2: Record "Purchase Line"; var TempPurchLineBuf: Record "Purchase Line" temporary; ToPurchHeader: Record "Purchase Header"; var TempDocPurchaseLine: Record "Purchase Line" temporary; DocNo: Code[20]; var NextLineNo: Integer)
    begin
        FromPurchLine2 := TempPurchLineBuf;
        TempPurchLineBuf := FromPurchLine;
        TempPurchLineBuf."Document No." := FromPurchLine2."Document No.";
        TempPurchLineBuf."Receipt Line No." := FromPurchLine2."Receipt Line No.";
        TempPurchLineBuf."Line No." := NextLineNo;
        OnAfterCopyPurchLinesToBufferFields(TempPurchLineBuf, FromPurchLine2);

        NextLineNo := NextLineNo + 10000;
        if not IsRecalculateAmount(
             FromPurchHeader."Currency Code", ToPurchHeader."Currency Code",
             FromPurchHeader."Prices Including VAT", ToPurchHeader."Prices Including VAT")
        then
            TempPurchLineBuf."Return Shipment No." := DocNo;
        ReCalcPurchLine(FromPurchHeader, ToPurchHeader, TempPurchLineBuf);
        TempPurchLineBuf.INSERT();
        AddPurchDocLine(TempDocPurchaseLine, TempPurchLineBuf."Line No.", DocNo, FromPurchLine."Line No.");
    end;

    local procedure CreateJobPlanningLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; JobContractEntryNo: Integer): Integer
    var
        JobPlanningLine: Record "Job Planning Line";
        NewJobPlanningLine: Record "Job Planning Line";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        JobPlanningLine.SETCURRENTKEY("Job Contract Entry No.");
        JobPlanningLine.SETRANGE("Job Contract Entry No.", JobContractEntryNo);
        if JobPlanningLine.FINDFIRST() then begin
            NewJobPlanningLine.InitFromJobPlanningLine(JobPlanningLine, SalesLine.Quantity);

            JobPlanningLineInvoice.InitFromJobPlanningLine(NewJobPlanningLine);
            JobPlanningLineInvoice.InitFromSales(SalesHeader, SalesHeader."Posting Date", SalesLine."Line No.");
            JobPlanningLineInvoice.INSERT();

            NewJobPlanningLine.UpdateQtyToTransfer();
            NewJobPlanningLine.INSERT();
        end;

        exit(NewJobPlanningLine."Job Contract Entry No.");
    end;

    local procedure SplitPstdPurchLinesPerILE(ToPurchHeader: Record "Purchase Header"; FromPurchHeader: Record "Purchase Header"; var ItemLedgEntry: Record "Item Ledger Entry"; var FromPurchLineBuf: Record "Purchase Line"; FromPurchLine: Record "Purchase Line"; var TempDocPurchaseLine: Record "Purchase Line" temporary; var NextLineNo: Integer; var CopyItemTrkg: Boolean; var MissingExCostRevLink: Boolean; FillExactCostRevLink: Boolean; FromShptOrRcpt: Boolean): Boolean
    var
        ItemL: Record Item;
        ApplyRec: Record "Item Application Entry";
        OrgQtyBase: Decimal;
    begin
        if FromShptOrRcpt then begin
            FromPurchLineBuf.RESET();
            FromPurchLineBuf.DELETEALL();
        end else
            FromPurchLineBuf.INIT();

        CopyItemTrkg := false;

        if (FromPurchLine.Type <> FromPurchLine.Type::Item) or (FromPurchLine.Quantity = 0) or (FromPurchLine."Prod. Order No." <> '')
        then
            exit(false);

        ItemL.GET(FromPurchLine."No.");
        if ItemL.IsNonInventoriableType() then
            exit(false);

        if IsCopyItemTrkg(ItemLedgEntry, CopyItemTrkg, FillExactCostRevLink) or
           not FillExactCostRevLink or MoveNegLines or
           not ExactCostRevMandatory
        then
            exit(false);

        if FromPurchLine."Job No." <> '' then
            exit(false);

        ItemLedgEntry.FINDSET();
        if ItemLedgEntry.Quantity <= 0 then begin
            FromPurchLineBuf."Document No." := ItemLedgEntry."Document No.";
            if GetPurchDocType(ItemLedgEntry) in
               [FromPurchLineBuf."Document Type"::Order.AsInteger(), FromPurchLineBuf."Document Type"::"Return Order".AsInteger()]
            then
                FromPurchLineBuf."Receipt Line No." := 1;
            exit(false);
        end;
        OrgQtyBase := FromPurchLine."Quantity (Base)";
        repeat
            if not ApplyFully then begin
                ApplyRec.AppliedOutbndEntryExists(ItemLedgEntry."Entry No.", false, false);
                if ApplyRec.FIND('-') then
                    SkippedLine := SkippedLine or ApplyRec.FIND('-');
            end;
            if ApplyFully then begin
                ApplyRec.AppliedOutbndEntryExists(ItemLedgEntry."Entry No.", false, false);
                if ApplyRec.FIND('-') then
                    repeat
                        SomeAreFixed := SomeAreFixed or ApplyRec.Fixed();
                    until ApplyRec.NEXT() = 0;
            end;

            if AskApply and (ItemLedgEntry."Item Tracking" = ItemLedgEntry."Item Tracking"::None) then
                if not (ItemLedgEntry."Remaining Quantity" > 0) or (ItemLedgEntry."Item Tracking" <> ItemLedgEntry."Item Tracking"::None) then
                    ConfirmApply();
            if AskApply then
                if ItemLedgEntry."Remaining Quantity" < ABS(FromPurchLine."Quantity (Base)") then
                    ConfirmApply();
            if (ItemLedgEntry."Remaining Quantity" > 0) or ApplyFully then begin
                FromPurchLineBuf := FromPurchLine;
                if ItemLedgEntry."Remaining Quantity" < ABS(FromPurchLine."Quantity (Base)") then
                    if not ApplyFully then begin
                        if FromPurchLine."Quantity (Base)" > 0 then
                            FromPurchLineBuf."Quantity (Base)" := ItemLedgEntry."Remaining Quantity"
                        else
                            FromPurchLineBuf."Quantity (Base)" := -ItemLedgEntry."Remaining Quantity";
                        ConvertFromBase(
                          FromPurchLineBuf.Quantity, FromPurchLineBuf."Quantity (Base)", FromPurchLineBuf."Qty. per Unit of Measure");
                    end else begin
                        ReappDone := true;
                        FromPurchLineBuf."Quantity (Base)" := Sign(ItemLedgEntry.Quantity) * ItemLedgEntry.Quantity - ApplyRec.Returned(ItemLedgEntry."Entry No.");
                        ConvertFromBase(
                          FromPurchLineBuf.Quantity, FromPurchLineBuf."Quantity (Base)", FromPurchLineBuf."Qty. per Unit of Measure");
                    end;
                FromPurchLine."Quantity (Base)" := FromPurchLine."Quantity (Base)" - FromPurchLineBuf."Quantity (Base)";
                FromPurchLine.Quantity := FromPurchLine.Quantity - FromPurchLineBuf.Quantity;
                FromPurchLineBuf."Appl.-to Item Entry" := ItemLedgEntry."Entry No.";
                FromPurchLineBuf."Line No." := NextLineNo;
                NextLineNo := NextLineNo + 1;
                FromPurchLineBuf."Document No." := ItemLedgEntry."Document No.";
                if GetPurchDocType(ItemLedgEntry) in
                   [FromPurchLineBuf."Document Type"::Order.AsInteger(), FromPurchLineBuf."Document Type"::"Return Order".AsInteger()]
                then
                    FromPurchLineBuf."Receipt Line No." := 1;

                if not FromShptOrRcpt then
                    UpdateRevPurchLineAmount(
                      FromPurchLineBuf, OrgQtyBase,
                      FromPurchHeader."Prices Including VAT", ToPurchHeader."Prices Including VAT");
                if FromPurchLineBuf.Quantity <> 0 then begin
                    FromPurchLineBuf.INSERT();
                    AddPurchDocLine(TempDocPurchaseLine, FromPurchLineBuf."Line No.", ItemLedgEntry."Document No.", FromPurchLineBuf."Line No.");
                end else
                    SkippedLine := true;
            end else
                if ItemLedgEntry."Remaining Quantity" = 0 then
                    SkippedLine := true;
        until (ItemLedgEntry.NEXT() = 0) or (FromPurchLine."Quantity (Base)" = 0);

        if (FromPurchLine."Quantity (Base)" <> 0) and FillExactCostRevLink then
            MissingExCostRevLink := true;
        CheckUnappliedLines(SkippedLine, MissingExCostRevLink);

        exit(true);
    end;

    local procedure SplitPurchDocLinesPerItemTrkg(var ItemLedgEntry: Record "Item Ledger Entry"; var TempItemTrkgEntry: Record "Reservation Entry" temporary; var FromPurchLineBuf: Record "Purchase Line"; FromPurchLine: Record "Purchase Line"; var TempDocPurchaseLine: Record "Purchase Line" temporary; var NextLineNo: Integer; var NextItemTrkgEntryNo: Integer; var MissingExCostRevLink: Boolean; FromShptOrRcpt: Boolean): Boolean
    var
        PurchLineBuf: array[2] of Record "Purchase Line" temporary;
        ApplyRec: Record "Item Application Entry";
        Tracked: Boolean;
        RemainingQtyBase: Decimal;
        SignFactor: Integer;
        i: Integer;
    begin
        if FromShptOrRcpt then begin
            FromPurchLineBuf.RESET();
            FromPurchLineBuf.DELETEALL();
            TempItemTrkgEntry.RESET();
            TempItemTrkgEntry.DELETEALL();
        end else
            FromPurchLineBuf.INIT();

        if MoveNegLines or not ExactCostRevMandatory then
            exit(false);

        if FromPurchLine."Quantity (Base)" < 0 then
            SignFactor := -1
        else
            SignFactor := 1;

        ItemLedgEntry.SETCURRENTKEY("Document No.", "Document Type", "Document Line No.");
        ItemLedgEntry.FINDSET();
        repeat
            PurchLineBuf[1] := FromPurchLine;
            PurchLineBuf[1]."Line No." := NextLineNo;
            PurchLineBuf[1]."Quantity (Base)" := 0;
            PurchLineBuf[1].Quantity := 0;
            PurchLineBuf[1]."Document No." := ItemLedgEntry."Document No.";
            if GetPurchDocType(ItemLedgEntry) in
               [PurchLineBuf[1]."Document Type"::Order.AsInteger(), PurchLineBuf[1]."Document Type"::"Return Order".AsInteger()]
            then
                PurchLineBuf[1]."Receipt Line No." := 1;
            PurchLineBuf[2] := PurchLineBuf[1];
            PurchLineBuf[2]."Line No." := PurchLineBuf[2]."Line No." + 1;

            if not FromShptOrRcpt then begin
                ItemLedgEntry.SETRANGE("Document No.", ItemLedgEntry."Document No.");
                ItemLedgEntry.SETRANGE("Document Type", ItemLedgEntry."Document Type");
                ItemLedgEntry.SETRANGE("Document Line No.", ItemLedgEntry."Document Line No.");
            end;
            repeat
                i := 1;
                if ItemLedgEntry.Positive then
                    ItemLedgEntry."Remaining Quantity" :=
                      ItemLedgEntry."Remaining Quantity" -
                      CalcDistributedQty(TempItemTrkgEntry, ItemLedgEntry, PurchLineBuf[2]."Line No." + 1);

                if ItemLedgEntry."Document Type" in [ItemLedgEntry."Document Type"::"Purchase Return Shipment", ItemLedgEntry."Document Type"::"Purchase Credit Memo"] then
                    if -ItemLedgEntry."Shipped Qty. Not Returned" < FromPurchLine."Quantity (Base)" * SignFactor then
                        RemainingQtyBase := -ItemLedgEntry."Shipped Qty. Not Returned" * SignFactor
                    else
                        RemainingQtyBase := FromPurchLine."Quantity (Base)"
                else
                    if not ItemLedgEntry.Positive then begin
                        RemainingQtyBase := -ItemLedgEntry."Shipped Qty. Not Returned";
                        if RemainingQtyBase < FromPurchLine."Quantity (Base)" * SignFactor then
                            RemainingQtyBase := RemainingQtyBase * SignFactor
                        else
                            RemainingQtyBase := FromPurchLine."Quantity (Base)";
                    end else
                        if ItemLedgEntry."Remaining Quantity" < FromPurchLine."Quantity (Base)" * SignFactor then begin
                            if (ItemLedgEntry."Item Tracking" = ItemLedgEntry."Item Tracking"::None) and AskApply then
                                ConfirmApply();
                            if (not ApplyFully) or (ItemLedgEntry."Item Tracking" <> ItemLedgEntry."Item Tracking"::None) then
                                RemainingQtyBase := GetQtyOfPurchILENotShipped(ItemLedgEntry."Entry No.") * SignFactor
                            else
                                RemainingQtyBase := FromPurchLine."Quantity (Base)" - ApplyRec.Returned(ItemLedgEntry."Entry No.");
                        end else
                            RemainingQtyBase := FromPurchLine."Quantity (Base)";

                if RemainingQtyBase <> 0 then begin
                    if ItemLedgEntry.Positive then
                        if IsSplitItemLedgEntry(ItemLedgEntry) then
                            i := 2;

                    PurchLineBuf[i]."Quantity (Base)" := PurchLineBuf[i]."Quantity (Base)" + RemainingQtyBase;
                    if PurchLineBuf[i]."Qty. per Unit of Measure" = 0 then
                        PurchLineBuf[i].Quantity := PurchLineBuf[i]."Quantity (Base)"
                    else
                        PurchLineBuf[i].Quantity :=
                          ROUND(
                            PurchLineBuf[i]."Quantity (Base)" / PurchLineBuf[i]."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision());
                    FromPurchLine."Quantity (Base)" := FromPurchLine."Quantity (Base)" - RemainingQtyBase;
                    // Fill buffer with exact cost reversing link for remaining quantity
                    if ItemLedgEntry."Document Type" in [ItemLedgEntry."Document Type"::"Purchase Return Shipment", ItemLedgEntry."Document Type"::"Purchase Credit Memo"] then
                        InsertTempItemTrkgEntry(
                          ItemLedgEntry, TempItemTrkgEntry, -ABS(RemainingQtyBase),
                          PurchLineBuf[i]."Line No.", NextItemTrkgEntryNo, true)
                    else
                        InsertTempItemTrkgEntry(
                          ItemLedgEntry, TempItemTrkgEntry, ABS(RemainingQtyBase),
                          PurchLineBuf[i]."Line No.", NextItemTrkgEntryNo, true);
                    Tracked := true;
                end else
                    SkippedLine := true;
            until (ItemLedgEntry.NEXT() = 0) or (FromPurchLine."Quantity (Base)" = 0);

            for i := 1 to 2 do
                if PurchLineBuf[i]."Quantity (Base)" <> 0 then begin
                    FromPurchLineBuf := PurchLineBuf[i];
                    FromPurchLineBuf.INSERT();
                    AddPurchDocLine(TempDocPurchaseLine, FromPurchLineBuf."Line No.", ItemLedgEntry."Document No.", FromPurchLine."Line No.");
                    NextLineNo := PurchLineBuf[i]."Line No." + 1;
                end;

            if not FromShptOrRcpt then begin
                ItemLedgEntry.SETRANGE("Document No.");
                ItemLedgEntry.SETRANGE("Document Type");
                ItemLedgEntry.SETRANGE("Document Line No.");
            end;
        until (ItemLedgEntry.NEXT() = 0) or FromShptOrRcpt;
        if (FromPurchLine."Quantity (Base)" <> 0) and not Tracked then
            MissingExCostRevLink := true;
        CheckUnappliedLines(SkippedLine, MissingExCostRevLink);

        exit(true);
    end;

    local procedure CalcDistributedQty(var TempItemTrkgEntry: Record "Reservation Entry" temporary; ItemLedgEntry: Record "Item Ledger Entry"; NextLineNo: Integer): Decimal
    begin
        TempItemTrkgEntry.RESET();
        TempItemTrkgEntry.SETCURRENTKEY("Source ID", "Source Ref. No.");
        TempItemTrkgEntry.SETRANGE("Source ID", ItemLedgEntry."Document No.");
        TempItemTrkgEntry.SETFILTER("Source Ref. No.", '<%1', NextLineNo);
        TempItemTrkgEntry.SETRANGE("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
        TempItemTrkgEntry.CALCSUMS("Quantity (Base)");
        TempItemTrkgEntry.RESET();
        exit(TempItemTrkgEntry."Quantity (Base)");
    end;

    local procedure IsSplitItemLedgEntry(OrgItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.SETCURRENTKEY("Document No.");
        ItemLedgEntry.SETRANGE("Document No.", OrgItemLedgEntry."Document No.");
        ItemLedgEntry.SETRANGE("Document Type", OrgItemLedgEntry."Document Type");
        ItemLedgEntry.SETRANGE("Document Line No.", OrgItemLedgEntry."Document Line No.");
        ItemLedgEntry.SETRANGE("Lot No.", OrgItemLedgEntry."Lot No.");
        ItemLedgEntry.SETRANGE("Serial No.", OrgItemLedgEntry."Serial No.");
        ItemLedgEntry.SETFILTER("Entry No.", '<%1', OrgItemLedgEntry."Entry No.");
        exit(not ItemLedgEntry.ISEMPTY);
    end;

    local procedure IsCopyItemTrkg(var ItemLedgEntry: Record "Item Ledger Entry"; var CopyItemTrkg: Boolean; FillExactCostRevLink: Boolean): Boolean
    begin
        if ItemLedgEntry.ISEMPTY then
            exit(true);
        ItemLedgEntry.SETFILTER("Lot No.", '<>''''');
        if not ItemLedgEntry.ISEMPTY then begin
            if FillExactCostRevLink then
                CopyItemTrkg := true;
            exit(true);
        end;
        ItemLedgEntry.SETRANGE("Lot No.");
        ItemLedgEntry.SETFILTER("Serial No.", '<>''''');
        if not ItemLedgEntry.ISEMPTY then begin
            if FillExactCostRevLink then
                CopyItemTrkg := true;
            exit(true);
        end;
        ItemLedgEntry.SETRANGE("Serial No.");
        exit(false);
    end;

    local procedure InsertTempItemTrkgEntry(ItemLedgEntry: Record "Item Ledger Entry"; var TempItemTrkgEntry: Record "Reservation Entry"; QtyBase: Decimal; DocLineNo: Integer; var NextEntryNo: Integer; FillExactCostRevLink: Boolean)
    begin
        if QtyBase = 0 then
            exit;

        TempItemTrkgEntry.INIT();
        TempItemTrkgEntry."Entry No." := NextEntryNo;
        NextEntryNo := NextEntryNo + 1;
        if not FillExactCostRevLink then
            TempItemTrkgEntry."Reservation Status" := TempItemTrkgEntry."Reservation Status"::Prospect;
        TempItemTrkgEntry."Source ID" := ItemLedgEntry."Document No.";
        TempItemTrkgEntry."Source Ref. No." := DocLineNo;
        TempItemTrkgEntry."Item Ledger Entry No." := ItemLedgEntry."Entry No.";
        TempItemTrkgEntry."Quantity (Base)" := QtyBase;
        TempItemTrkgEntry.INSERT();
    end;

    local procedure GetLastToSalesLineNo(ToSalesHeader: Record "Sales Header"): Decimal
    var
        ToSalesLine: Record "Sales Line";
    begin
        ToSalesLine.LOCKTABLE();
        ToSalesLine.SETRANGE("Document Type", ToSalesHeader."Document Type");
        ToSalesLine.SETRANGE("Document No.", ToSalesHeader."No.");
        if ToSalesLine.FINDLAST() then
            exit(ToSalesLine."Line No.");
        exit(0);
    end;

    local procedure GetLastToPurchLineNo(ToPurchHeader: Record "Purchase Header"): Decimal
    var
        ToPurchLine: Record "Purchase Line";
    begin
        ToPurchLine.LOCKTABLE();
        ToPurchLine.SETRANGE("Document Type", ToPurchHeader."Document Type");
        ToPurchLine.SETRANGE("Document No.", ToPurchHeader."No.");
        if ToPurchLine.FINDLAST() then
            exit(ToPurchLine."Line No.");
        exit(0);
    end;

    local procedure InsertOldSalesDocNoLine(ToSalesHeader: Record "Sales Header"; OldDocNo: Code[20]; OldDocType: Integer; var NextLineNo: Integer)
    var
        ToSalesLine2: Record "Sales Line";
    begin
        if SkipCopyFromDescription then
            exit;

        NextLineNo := NextLineNo + 10000;
        ToSalesLine2.INIT();
        ToSalesLine2."Line No." := NextLineNo;
        ToSalesLine2."Document Type" := ToSalesHeader."Document Type";
        ToSalesLine2."Document No." := ToSalesHeader."No.";

        TranslationHelper.SetGlobalLanguageByCode(ToSalesHeader."Language Code");
        if InsertCancellationLine then
            ToSalesLine2.Description := STRSUBSTNO(CrMemoCancellationMsg, OldDocNo)
        else
            ToSalesLine2.Description := STRSUBSTNO(Text015, SELECTSTR(OldDocType, Text013), OldDocNo);
        TranslationHelper.RestoreGlobalLanguage();

        OnBeforeInsertOldSalesDocNoLine(ToSalesHeader, ToSalesLine2, OldDocType, OldDocNo);
        ToSalesLine2.INSERT();
    end;

    local procedure InsertOldSalesCombDocNoLine(ToSalesHeader: Record "Sales Header"; OldDocNo: Code[20]; OldDocNo2: Code[20]; var NextLineNo: Integer; CopyFromInvoice: Boolean)
    var
        ToSalesLine2: Record "Sales Line";
    begin
        NextLineNo := NextLineNo + 10000;
        ToSalesLine2.INIT();
        ToSalesLine2."Line No." := NextLineNo;
        ToSalesLine2."Document Type" := ToSalesHeader."Document Type";
        ToSalesLine2."Document No." := ToSalesHeader."No.";

        TranslationHelper.SetGlobalLanguageByCode(ToSalesHeader."Language Code");
        if CopyFromInvoice then
            ToSalesLine2.Description :=
              STRSUBSTNO(
                Text018,
                COPYSTR(SELECTSTR(1, Text016) + OldDocNo, 1, 23),
                COPYSTR(SELECTSTR(2, Text016) + OldDocNo2, 1, 23))
        else
            ToSalesLine2.Description :=
              STRSUBSTNO(
                Text018,
                COPYSTR(SELECTSTR(3, Text016) + OldDocNo, 1, 23),
                COPYSTR(SELECTSTR(4, Text016) + OldDocNo2, 1, 23));
        TranslationHelper.RestoreGlobalLanguage();

        OnBeforeInsertOldSalesCombDocNoLine(ToSalesHeader, ToSalesLine2, CopyFromInvoice, OldDocNo, OldDocNo2);
        ToSalesLine2.INSERT();
    end;

    local procedure InsertOldPurchDocNoLine(ToPurchHeader: Record "Purchase Header"; OldDocNo: Code[20]; OldDocType: Integer; var NextLineNo: Integer)
    var
        ToPurchLine2: Record "Purchase Line";
    begin
        if SkipCopyFromDescription then
            exit;

        NextLineNo := NextLineNo + 10000;
        ToPurchLine2.INIT();
        ToPurchLine2."Line No." := NextLineNo;
        ToPurchLine2."Document Type" := ToPurchHeader."Document Type";
        ToPurchLine2."Document No." := ToPurchHeader."No.";

        TranslationHelper.SetGlobalLanguageByCode(ToPurchHeader."Language Code");
        if InsertCancellationLine then
            ToPurchLine2.Description := STRSUBSTNO(CrMemoCancellationMsg, OldDocNo)
        else
            ToPurchLine2.Description := STRSUBSTNO(Text015, SELECTSTR(OldDocType, Text014), OldDocNo);
        TranslationHelper.RestoreGlobalLanguage();

        OnBeforeInsertOldPurchDocNoLine(ToPurchHeader, ToPurchLine2, OldDocType, OldDocNo);
        ToPurchLine2.INSERT();
    end;

    local procedure InsertOldPurchCombDocNoLine(ToPurchHeader: Record "Purchase Header"; OldDocNo: Code[20]; OldDocNo2: Code[20]; var NextLineNo: Integer; CopyFromInvoice: Boolean)
    var
        ToPurchLine2: Record "Purchase Line";
    begin
        NextLineNo := NextLineNo + 10000;
        ToPurchLine2.INIT();
        ToPurchLine2."Line No." := NextLineNo;
        ToPurchLine2."Document Type" := ToPurchHeader."Document Type";
        ToPurchLine2."Document No." := ToPurchHeader."No.";

        TranslationHelper.SetGlobalLanguageByCode(ToPurchHeader."Language Code");
        if CopyFromInvoice then
            ToPurchLine2.Description :=
              STRSUBSTNO(
                Text018,
                COPYSTR(SELECTSTR(1, Text017) + OldDocNo, 1, 23),
                COPYSTR(SELECTSTR(2, Text017) + OldDocNo2, 1, 23))
        else
            ToPurchLine2.Description :=
              STRSUBSTNO(
                Text018,
                COPYSTR(SELECTSTR(3, Text017) + OldDocNo, 1, 23),
                COPYSTR(SELECTSTR(4, Text017) + OldDocNo2, 1, 23));
        TranslationHelper.RestoreGlobalLanguage();

        OnBeforeInsertOldPurchCombDocNoLine(ToPurchHeader, ToPurchLine2, CopyFromInvoice, OldDocNo, OldDocNo2);
        ToPurchLine2.INSERT();
    end;

    procedure IsSalesFillExactCostRevLink(ToSalesHeader: Record "Sales Header"; FromDocType: Option "Sales Shipment","Sales Invoice","Sales Return Receipt","Sales Credit Memo"; CurrencyCode: Code[10]): Boolean
    begin
        case FromDocType of
            FromDocType::"Sales Shipment":
                exit(ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::"Return Order", ToSalesHeader."Document Type"::"Credit Memo"]);
            FromDocType::"Sales Invoice":
                exit(
                  (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::"Return Order", ToSalesHeader."Document Type"::"Credit Memo"]) and
                  (ToSalesHeader."Currency Code" = CurrencyCode));
            FromDocType::"Sales Return Receipt":
                exit(ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Order, ToSalesHeader."Document Type"::Invoice]);
            FromDocType::"Sales Credit Memo":
                exit(
                  (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Order, ToSalesHeader."Document Type"::Invoice]) and
                  (ToSalesHeader."Currency Code" = CurrencyCode));
        end;
        exit(false);
    end;

    procedure IsPurchFillExactCostRevLink(ToPurchHeader: Record "Purchase Header"; FromDocType: Option "Purchase Receipt","Purchase Invoice","Purchase Return Shipment","Purchase Credit Memo"; CurrencyCode: Code[10]): Boolean
    begin
        case FromDocType of
            FromDocType::"Purchase Receipt":
                exit(ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::"Return Order", ToPurchHeader."Document Type"::"Credit Memo"]);
            FromDocType::"Purchase Invoice":
                exit(
                  (ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::"Return Order", ToPurchHeader."Document Type"::"Credit Memo"]) and
                  (ToPurchHeader."Currency Code" = CurrencyCode));
            FromDocType::"Purchase Return Shipment":
                exit(ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::Order, ToPurchHeader."Document Type"::Invoice]);
            FromDocType::"Purchase Credit Memo":
                exit(
                  (ToPurchHeader."Document Type" in [ToPurchHeader."Document Type"::Order, ToPurchHeader."Document Type"::Invoice]) and
                  (ToPurchHeader."Currency Code" = CurrencyCode));
        end;
        exit(false);
    end;

    local procedure GetSalesDocType(ItemLedgEntry: Record "Item Ledger Entry"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        case ItemLedgEntry."Document Type" of
            ItemLedgEntry."Document Type"::"Sales Shipment":
                exit(SalesLine."Document Type"::Order.AsInteger());
            ItemLedgEntry."Document Type"::"Sales Invoice":
                exit(SalesLine."Document Type"::Invoice.AsInteger());
            ItemLedgEntry."Document Type"::"Sales Credit Memo":
                exit(SalesLine."Document Type"::"Credit Memo".AsInteger());
            ItemLedgEntry."Document Type"::"Sales Return Receipt":
                exit(SalesLine."Document Type"::"Return Order".AsInteger());
        end;
    end;

    local procedure GetPurchDocType(ItemLedgEntry: Record "Item Ledger Entry"): Integer
    var
        PurchLine: Record "Purchase Line";
    begin
        case ItemLedgEntry."Document Type" of
            ItemLedgEntry."Document Type"::"Purchase Receipt":
                exit(PurchLine."Document Type"::Order.AsInteger());
            ItemLedgEntry."Document Type"::"Purchase Invoice":
                exit(PurchLine."Document Type"::Invoice.AsInteger());
            ItemLedgEntry."Document Type"::"Purchase Credit Memo":
                exit(PurchLine."Document Type"::"Credit Memo".AsInteger());
            ItemLedgEntry."Document Type"::"Purchase Return Shipment":
                exit(PurchLine."Document Type"::"Return Order".AsInteger());
        end;
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if ItemNo <> Item."No." then
            if not Item.GET(ItemNo) then
                Item.INIT();
    end;

    local procedure CalcVAT(var Value: Decimal; VATPercentage: Decimal; FromPricesInclVAT: Boolean; ToPricesInclVAT: Boolean; RndgPrecision: Decimal)
    begin
        if (ToPricesInclVAT = FromPricesInclVAT) or (Value = 0) then
            exit;

        if ToPricesInclVAT then
            Value := ROUND(Value * (100 + VATPercentage) / 100, RndgPrecision)
        else
            Value := ROUND(Value * 100 / (100 + VATPercentage), RndgPrecision);
    end;

    local procedure ReCalcSalesLine(FromSalesHeader: Record "Sales Header"; ToSalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        CurrExchRate: Record "Currency Exchange Rate";
        SalesLineAmount: Decimal;
    begin
        if not IsRecalculateAmount(
     FromSalesHeader."Currency Code", ToSalesHeader."Currency Code",
     FromSalesHeader."Prices Including VAT", ToSalesHeader."Prices Including VAT")
then
            exit;

        if FromSalesHeader."Currency Code" <> ToSalesHeader."Currency Code" then begin
            if SalesLine.Quantity <> 0 then
                SalesLineAmount := SalesLine."Unit Price" * SalesLine.Quantity
            else
                SalesLineAmount := SalesLine."Unit Price";
            if FromSalesHeader."Currency Code" <> '' then begin
                SalesLineAmount :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    FromSalesHeader."Posting Date", FromSalesHeader."Currency Code",
                    SalesLineAmount, FromSalesHeader."Currency Factor");
                SalesLine."Line Discount Amount" :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    FromSalesHeader."Posting Date", FromSalesHeader."Currency Code",
                    SalesLine."Line Discount Amount", FromSalesHeader."Currency Factor");
                SalesLine."Inv. Discount Amount" :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    FromSalesHeader."Posting Date", FromSalesHeader."Currency Code",
                    SalesLine."Inv. Discount Amount", FromSalesHeader."Currency Factor");
            end;

            if ToSalesHeader."Currency Code" <> '' then begin
                SalesLineAmount :=
                  CurrExchRate.ExchangeAmtLCYToFCY(
                    ToSalesHeader."Posting Date", ToSalesHeader."Currency Code", SalesLineAmount, ToSalesHeader."Currency Factor");
                SalesLine."Line Discount Amount" :=
                  CurrExchRate.ExchangeAmtLCYToFCY(
                    ToSalesHeader."Posting Date", ToSalesHeader."Currency Code", SalesLine."Line Discount Amount", ToSalesHeader."Currency Factor");
                SalesLine."Inv. Discount Amount" :=
                  CurrExchRate.ExchangeAmtLCYToFCY(
                    ToSalesHeader."Posting Date", ToSalesHeader."Currency Code", SalesLine."Inv. Discount Amount", ToSalesHeader."Currency Factor");
            end;
        end;

        SalesLine."Currency Code" := ToSalesHeader."Currency Code";
        if SalesLine.Quantity <> 0 then begin
            SalesLineAmount := ROUND(SalesLineAmount, Currency."Amount Rounding Precision");
            SalesLine."Unit Price" := ROUND(SalesLineAmount / SalesLine.Quantity, Currency."Unit-Amount Rounding Precision");
        end else
            SalesLine."Unit Price" := ROUND(SalesLineAmount, Currency."Unit-Amount Rounding Precision");
        SalesLine."Line Discount Amount" := ROUND(SalesLine."Line Discount Amount", Currency."Amount Rounding Precision");
        SalesLine."Inv. Discount Amount" := ROUND(SalesLine."Inv. Discount Amount", Currency."Amount Rounding Precision");

        CalcVAT(
          SalesLine."Unit Price", SalesLine."VAT %", FromSalesHeader."Prices Including VAT",
          ToSalesHeader."Prices Including VAT", Currency."Unit-Amount Rounding Precision");
        CalcVAT(
          SalesLine."Line Discount Amount", SalesLine."VAT %", FromSalesHeader."Prices Including VAT",
          ToSalesHeader."Prices Including VAT", Currency."Amount Rounding Precision");
        CalcVAT(
          SalesLine."Inv. Discount Amount", SalesLine."VAT %", FromSalesHeader."Prices Including VAT",
          ToSalesHeader."Prices Including VAT", Currency."Amount Rounding Precision");
    end;

    local procedure ReCalcPurchLine(FromPurchHeader: Record "Purchase Header"; ToPurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    var
        CurrExchRate: Record "Currency Exchange Rate";
        PurchLineAmount: Decimal;
    begin
        if not IsRecalculateAmount(
     FromPurchHeader."Currency Code", ToPurchHeader."Currency Code",
     FromPurchHeader."Prices Including VAT", ToPurchHeader."Prices Including VAT")
then
            exit;

        if FromPurchHeader."Currency Code" <> ToPurchHeader."Currency Code" then begin
            if PurchLine.Quantity <> 0 then
                PurchLineAmount := PurchLine."Direct Unit Cost" * PurchLine.Quantity
            else
                PurchLineAmount := PurchLine."Direct Unit Cost";
            if FromPurchHeader."Currency Code" <> '' then begin
                PurchLineAmount :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    FromPurchHeader."Posting Date", FromPurchHeader."Currency Code",
                    PurchLineAmount, FromPurchHeader."Currency Factor");
                PurchLine."Line Discount Amount" :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    FromPurchHeader."Posting Date", FromPurchHeader."Currency Code",
                    PurchLine."Line Discount Amount", FromPurchHeader."Currency Factor");
                PurchLine."Inv. Discount Amount" :=
                  CurrExchRate.ExchangeAmtFCYToLCY(
                    FromPurchHeader."Posting Date", FromPurchHeader."Currency Code",
                    PurchLine."Inv. Discount Amount", FromPurchHeader."Currency Factor");
            end;

            if ToPurchHeader."Currency Code" <> '' then begin
                PurchLineAmount :=
                  CurrExchRate.ExchangeAmtLCYToFCY(
                    ToPurchHeader."Posting Date", ToPurchHeader."Currency Code", PurchLineAmount, ToPurchHeader."Currency Factor");
                PurchLine."Line Discount Amount" :=
                  CurrExchRate.ExchangeAmtLCYToFCY(
                    ToPurchHeader."Posting Date", ToPurchHeader."Currency Code", PurchLine."Line Discount Amount", ToPurchHeader."Currency Factor");
                PurchLine."Inv. Discount Amount" :=
                  CurrExchRate.ExchangeAmtLCYToFCY(
                    ToPurchHeader."Posting Date", ToPurchHeader."Currency Code", PurchLine."Inv. Discount Amount", ToPurchHeader."Currency Factor");
            end;
        end;

        PurchLine."Currency Code" := ToPurchHeader."Currency Code";
        if PurchLine.Quantity <> 0 then begin
            PurchLineAmount := ROUND(PurchLineAmount, Currency."Amount Rounding Precision");
            PurchLine."Direct Unit Cost" := ROUND(PurchLineAmount / PurchLine.Quantity, Currency."Unit-Amount Rounding Precision");
        end else
            PurchLine."Direct Unit Cost" := ROUND(PurchLineAmount, Currency."Unit-Amount Rounding Precision");
        PurchLine."Line Discount Amount" := ROUND(PurchLine."Line Discount Amount", Currency."Amount Rounding Precision");
        PurchLine."Inv. Discount Amount" := ROUND(PurchLine."Inv. Discount Amount", Currency."Amount Rounding Precision");

        CalcVAT(
          PurchLine."Direct Unit Cost", PurchLine."VAT %", FromPurchHeader."Prices Including VAT",
          ToPurchHeader."Prices Including VAT", Currency."Unit-Amount Rounding Precision");
        CalcVAT(
          PurchLine."Line Discount Amount", PurchLine."VAT %", FromPurchHeader."Prices Including VAT",
          ToPurchHeader."Prices Including VAT", Currency."Amount Rounding Precision");
        CalcVAT(
          PurchLine."Inv. Discount Amount", PurchLine."VAT %", FromPurchHeader."Prices Including VAT",
          ToPurchHeader."Prices Including VAT", Currency."Amount Rounding Precision");
    end;

    local procedure IsRecalculateAmount(FromCurrencyCode: Code[10]; ToCurrencyCode: Code[10]; FromPricesInclVAT: Boolean; ToPricesInclVAT: Boolean): Boolean
    begin
        exit(
          (FromCurrencyCode <> ToCurrencyCode) or
          (FromPricesInclVAT <> ToPricesInclVAT));
    end;

    local procedure UpdateRevSalesLineAmount(var SalesLine: Record "Sales Line"; OrgQtyBase: Decimal; FromPricesInclVAT: Boolean; ToPricesInclVAT: Boolean)
    var
        Amount: Decimal;
    begin
        if (OrgQtyBase = 0) or (SalesLine.Quantity = 0) or
           ((FromPricesInclVAT = ToPricesInclVAT) and (OrgQtyBase = SalesLine."Quantity (Base)"))
        then
            exit;

        Amount := SalesLine.Quantity * SalesLine."Unit Price";
        CalcVAT(
          Amount, SalesLine."VAT %", FromPricesInclVAT, ToPricesInclVAT, Currency."Amount Rounding Precision");
        SalesLine."Unit Price" := Amount / SalesLine.Quantity;
        SalesLine."Line Discount Amount" :=
          ROUND(
            ROUND(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision") *
            SalesLine."Line Discount %" / 100,
            Currency."Amount Rounding Precision");
        Amount :=
          ROUND(SalesLine."Inv. Discount Amount" / OrgQtyBase * SalesLine."Quantity (Base)", Currency."Amount Rounding Precision");
        CalcVAT(
          Amount, SalesLine."VAT %", FromPricesInclVAT, ToPricesInclVAT, Currency."Amount Rounding Precision");
        SalesLine."Inv. Discount Amount" := Amount;
    end;

    procedure CalculateRevSalesLineAmount(var SalesLine: Record "Sales Line"; OrgQtyBase: Decimal; FromPricesInclVAT: Boolean; ToPricesInclVAT: Boolean)
    var
        UnitPrice: Decimal;
        LineDiscAmt: Decimal;
        InvDiscAmt: Decimal;
    begin
        UpdateRevSalesLineAmount(SalesLine, OrgQtyBase, FromPricesInclVAT, ToPricesInclVAT);

        UnitPrice := SalesLine."Unit Price";
        LineDiscAmt := SalesLine."Line Discount Amount";
        InvDiscAmt := SalesLine."Inv. Discount Amount";

        SalesLine.VALIDATE("Unit Price", UnitPrice);
        SalesLine.VALIDATE("Line Discount Amount", LineDiscAmt);
        SalesLine.VALIDATE("Inv. Discount Amount", InvDiscAmt);
    end;

    local procedure UpdateRevPurchLineAmount(var PurchLine: Record "Purchase Line"; OrgQtyBase: Decimal; FromPricesInclVAT: Boolean; ToPricesInclVAT: Boolean)
    var
        Amount: Decimal;
    begin
        if (OrgQtyBase = 0) or (PurchLine.Quantity = 0) or
           ((FromPricesInclVAT = ToPricesInclVAT) and (OrgQtyBase = PurchLine."Quantity (Base)"))
        then
            exit;

        Amount := PurchLine.Quantity * PurchLine."Direct Unit Cost";
        CalcVAT(
          Amount, PurchLine."VAT %", FromPricesInclVAT, ToPricesInclVAT, Currency."Amount Rounding Precision");
        PurchLine."Direct Unit Cost" := Amount / PurchLine.Quantity;
        PurchLine."Line Discount Amount" :=
          ROUND(
            ROUND(PurchLine.Quantity * PurchLine."Direct Unit Cost", Currency."Amount Rounding Precision") *
            PurchLine."Line Discount %" / 100,
            Currency."Amount Rounding Precision");
        Amount :=
          ROUND(PurchLine."Inv. Discount Amount" / OrgQtyBase * PurchLine."Quantity (Base)", Currency."Amount Rounding Precision");
        CalcVAT(
          Amount, PurchLine."VAT %", FromPricesInclVAT, ToPricesInclVAT, Currency."Amount Rounding Precision");
        PurchLine."Inv. Discount Amount" := Amount;
    end;

    procedure CalculateRevPurchLineAmount(var PurchLine: Record "Purchase Line"; OrgQtyBase: Decimal; FromPricesInclVAT: Boolean; ToPricesInclVAT: Boolean)
    var
        DirectUnitCost: Decimal;
        LineDiscAmt: Decimal;
        InvDiscAmt: Decimal;
    begin
        UpdateRevPurchLineAmount(PurchLine, OrgQtyBase, FromPricesInclVAT, ToPricesInclVAT);

        DirectUnitCost := PurchLine."Direct Unit Cost";
        LineDiscAmt := PurchLine."Line Discount Amount";
        InvDiscAmt := PurchLine."Inv. Discount Amount";

        PurchLine.VALIDATE("Direct Unit Cost", DirectUnitCost);
        PurchLine.VALIDATE("Line Discount Amount", LineDiscAmt);
        PurchLine.VALIDATE("Inv. Discount Amount", InvDiscAmt);
    end;

    local procedure InitCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyCode <> '' then
            Currency.GET(CurrencyCode)
        else
            Currency.InitRoundingPrecision();

        Currency.TESTFIELD("Unit-Amount Rounding Precision");
        Currency.TESTFIELD("Amount Rounding Precision");
    end;

    local procedure OpenWindow()
    begin
        Window.OPEN(
          Text022 +
          Text023 +
          Text024);
        WindowUpdateDateTime := CURRENTDATETIME;
    end;

    local procedure IsTimeForUpdate(): Boolean
    begin
        if CURRENTDATETIME - WindowUpdateDateTime >= 1000 then begin
            WindowUpdateDateTime := CURRENTDATETIME;
            exit(true);
        end;
        exit(false);
    end;

    local procedure ConfirmApply()
    begin
        AskApply := false;
        ApplyFully := false;
    end;

    local procedure ConvertFromBase(var Quantity: Decimal; QuantityBase: Decimal; QtyPerUOM: Decimal)
    begin
        if QtyPerUOM = 0 then
            Quantity := QuantityBase
        else
            Quantity := ROUND(QuantityBase / QtyPerUOM, UOMMgt.QtyRndPrecision());
    end;

    local procedure Sign(Quantity: Decimal): Decimal
    begin
        if Quantity < 0 then
            exit(-1);
        exit(1);
    end;

    procedure ShowMessageReapply(OriginalQuantity: Boolean)
    var
        Text: Text[1024];
    begin
        Text := '';
        if SkippedLine then
            Text := Text029;
        if OriginalQuantity and ReappDone then
            if Text = '' then
                Text := Text025;
        if SomeAreFixed then
            MESSAGE(Text031);
        if Text <> '' then
            MESSAGE(Text);
    end;

    local procedure LinkJobPlanningLine(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        JobPlanningLine: Record "Job Planning Line";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        JobPlanningLine.SETCURRENTKEY("Job Contract Entry No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        repeat
            JobPlanningLine.SETRANGE("Job Contract Entry No.", SalesLine."Job Contract Entry No.");
            if JobPlanningLine.FINDFIRST() then begin
                JobPlanningLineInvoice."Job No." := JobPlanningLine."Job No.";
                JobPlanningLineInvoice."Job Task No." := JobPlanningLine."Job Task No.";
                JobPlanningLineInvoice."Job Planning Line No." := JobPlanningLine."Line No.";
                case SalesHeader."Document Type" of
                    SalesHeader."Document Type"::Invoice:
                        begin
                            JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::Invoice;
                            JobPlanningLineInvoice."Quantity Transferred" := SalesLine.Quantity;
                        end;
                    SalesHeader."Document Type"::"Credit Memo":
                        begin
                            JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::"Credit Memo";
                            JobPlanningLineInvoice."Quantity Transferred" := -SalesLine.Quantity;
                        end;
                    else
                        exit;
                end;
                JobPlanningLineInvoice."Document No." := SalesHeader."No.";
                JobPlanningLineInvoice."Line No." := SalesLine."Line No.";
                JobPlanningLineInvoice."Transferred Date" := SalesHeader."Posting Date";
                JobPlanningLineInvoice.INSERT();

                JobPlanningLine.UpdateQtyToTransfer();
                JobPlanningLine.MODIFY();
            end;
        until SalesLine.NEXT() = 0;
    end;

    local procedure GetQtyOfPurchILENotShipped(ItemLedgerEntryNo: Integer): Decimal
    var
        ItemApplicationEntry: Record "Item Application Entry";
        ItemLedgerEntryLocal: Record "Item Ledger Entry";
        QtyNotShipped: Decimal;
    begin
        QtyNotShipped := 0;
        ItemApplicationEntry.RESET();
        ItemApplicationEntry.SETCURRENTKEY("Inbound Item Entry No.", "Outbound Item Entry No.");
        ItemApplicationEntry.SETRANGE("Inbound Item Entry No.", ItemLedgerEntryNo);
        ItemApplicationEntry.SETRANGE("Outbound Item Entry No.", 0);
        if not ItemApplicationEntry.FINDFIRST() then
            exit(QtyNotShipped);
        QtyNotShipped := ItemApplicationEntry.Quantity;
        ItemApplicationEntry.SETFILTER("Outbound Item Entry No.", '<>0');
        if not ItemApplicationEntry.FINDSET(false) then
            exit(QtyNotShipped);
        repeat
            ItemLedgerEntryLocal.GET(ItemApplicationEntry."Outbound Item Entry No.");
            if (ItemLedgerEntryLocal."Entry Type" in
                [ItemLedgerEntryLocal."Entry Type"::Sale,
                 ItemLedgerEntryLocal."Entry Type"::Purchase]) or
               ((ItemLedgerEntryLocal."Entry Type" in
                 [ItemLedgerEntryLocal."Entry Type"::"Positive Adjmt.", ItemLedgerEntryLocal."Entry Type"::"Negative Adjmt."]) and
                (ItemLedgerEntryLocal."Job No." = ''))
            then
                QtyNotShipped += ItemApplicationEntry.Quantity;
        until ItemApplicationEntry.NEXT() = 0;
        exit(QtyNotShipped);
    end;

    local procedure CopyAsmOrderToAsmOrder(var TempFromAsmHeader: Record "Assembly Header" temporary; var TempFromAsmLine: Record "Assembly Line" temporary; ToSalesLine: Record "Sales Line"; ToAsmHeaderDocType: Integer; ToAsmHeaderDocNo: Code[20]; InclAsmHeader: Boolean)
    var
        FromAsmHeader: Record "Assembly Header";
        ToAsmHeader: Record "Assembly Header";
        TempToAsmHeader: Record "Assembly Header" temporary;
        AssembleToOrderLink: Record "Assemble-to-Order Link";
        ToAsmLine: Record "Assembly Line";
        BasicAsmOrderCopy: Boolean;
    begin
        if ToAsmHeaderDocType = -1 then
            exit;
        BasicAsmOrderCopy := ToAsmHeaderDocNo <> '';
        if BasicAsmOrderCopy then
            ToAsmHeader.GET(ToAsmHeaderDocType, ToAsmHeaderDocNo)
        else begin
            if ToSalesLine.AsmToOrderExists(FromAsmHeader) then
                exit;
            CLEAR(ToAsmHeader);
            AssembleToOrderLink.InsertAsmHeader(ToAsmHeader, ToAsmHeaderDocType, '');
            InclAsmHeader := true;
        end;

        if InclAsmHeader then begin
            if BasicAsmOrderCopy then begin
                TempToAsmHeader := ToAsmHeader;
                TempToAsmHeader.INSERT();
                ProcessToAsmHeader(TempToAsmHeader, TempFromAsmHeader, ToSalesLine, true, true); // Basic, Availabilitycheck
                CheckAsmOrderAvailability(TempToAsmHeader, TempFromAsmLine, ToSalesLine);
            end;
            ProcessToAsmHeader(ToAsmHeader, TempFromAsmHeader, ToSalesLine, BasicAsmOrderCopy, false);
        end else
            if BasicAsmOrderCopy then
                CheckAsmOrderAvailability(ToAsmHeader, TempFromAsmLine, ToSalesLine);
        CreateToAsmLines(ToAsmHeader, TempFromAsmLine, ToAsmLine, ToSalesLine, BasicAsmOrderCopy, false);
        if not BasicAsmOrderCopy then begin
            AssembleToOrderLink."Assembly Document Type" := ToAsmHeader."Document Type";
            AssembleToOrderLink."Assembly Document No." := ToAsmHeader."No.";
            AssembleToOrderLink.Type := AssembleToOrderLink.Type::Sale;
            AssembleToOrderLink."Document Type" := ToSalesLine."Document Type";
            AssembleToOrderLink."Document No." := ToSalesLine."Document No.";
            AssembleToOrderLink."Document Line No." := ToSalesLine."Line No.";
            AssembleToOrderLink.INSERT();
            if ToSalesLine."Document Type" = ToSalesLine."Document Type"::Order then begin
                if ToSalesLine."Shipment Date" = 0D then begin
                    ToSalesLine."Shipment Date" := ToAsmHeader."Due Date";
                    ToSalesLine.MODIFY();
                end;
                AssembleToOrderLink.ReserveAsmToSale(ToSalesLine, ToSalesLine.Quantity, ToSalesLine."Quantity (Base)");
            end;
        end;

        ToAsmHeader.ShowDueDateBeforeWorkDateMsg();
    end;

    procedure CopyAsmHeaderToAsmHeader(FromAsmHeader: Record "Assembly Header"; ToAsmHeader: Record "Assembly Header"; IncludeHeaderP: Boolean)
    var
        EmptyToSalesLine: Record "Sales Line";
    begin
        InitialToAsmHeaderCheck(ToAsmHeader, IncludeHeaderP);
        GenerateAsmDataFromNonPosted(FromAsmHeader);
        CLEAR(EmptyToSalesLine);
        EmptyToSalesLine.INIT();
        CopyAsmOrderToAsmOrder(TempAsmHeader, TempAsmLine, EmptyToSalesLine, ToAsmHeader."Document Type".AsInteger(), ToAsmHeader."No.", IncludeHeaderP);
    end;

    procedure CopyPostedAsmHeaderToAsmHeader(PostedAsmHeaderL: Record "Posted Assembly Header"; ToAsmHeader: Record "Assembly Header"; IncludeHeaderP: Boolean)
    var
        EmptyToSalesLine: Record "Sales Line";
    begin
        InitialToAsmHeaderCheck(ToAsmHeader, IncludeHeaderP);
        GenerateAsmDataFromPosted(PostedAsmHeaderL, 0);
        CLEAR(EmptyToSalesLine);
        EmptyToSalesLine.INIT();
        CopyAsmOrderToAsmOrder(TempAsmHeader, TempAsmLine, EmptyToSalesLine, ToAsmHeader."Document Type".AsInteger(), ToAsmHeader."No.", IncludeHeaderP);
    end;

    local procedure GenerateAsmDataFromNonPosted(AsmHeaderP: Record "Assembly Header")
    var
        AsmLine: Record "Assembly Line";
    begin
        InitAsmCopyHandling(false);
        TempAsmHeader := AsmHeaderP;
        TempAsmHeader.INSERT();
        AsmLine.SETRANGE("Document Type", AsmHeaderP."Document Type");
        AsmLine.SETRANGE("Document No.", AsmHeaderP."No.");
        if AsmLine.FINDSET() then
            repeat
                TempAsmLine := AsmLine;
                TempAsmLine.INSERT();
            until AsmLine.NEXT() = 0;
    end;

    local procedure GenerateAsmDataFromPosted(PostedAsmHeaderP: Record "Posted Assembly Header"; DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order")
    var
        PostedAsmLine: Record "Posted Assembly Line";
    begin
        InitAsmCopyHandling(false);
        TempAsmHeader.TRANSFERFIELDS(PostedAsmHeaderP);
        OnAfterTransferTempAsmHeader(TempAsmHeader, PostedAsmHeaderP);
        case DocType of
            DocType::Quote:
                TempAsmHeader."Document Type" := TempAsmHeader."Document Type"::Quote;
            DocType::Order:
                TempAsmHeader."Document Type" := TempAsmHeader."Document Type"::Order;
            DocType::"Blanket Order":
                TempAsmHeader."Document Type" := TempAsmHeader."Document Type"::"Blanket Order";
            else
                exit;
        end;
        TempAsmHeader.INSERT();
        PostedAsmLine.SETRANGE("Document No.", PostedAsmHeaderP."No.");
        if PostedAsmLine.FINDSET() then
            repeat
                TempAsmLine.TRANSFERFIELDS(PostedAsmLine);
                TempAsmLine."Document No." := TempAsmHeader."No.";
                TempAsmLine."Cost Amount" := PostedAsmLine.Quantity * PostedAsmLine."Unit Cost";
                TempAsmLine.INSERT();
            until PostedAsmLine.NEXT() = 0;
    end;

    local procedure GetAsmDataFromSalesInvLine(DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"): Boolean
    var
        ValueEntry: Record "Value Entry";
        ValueEntry2: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntry2: Record "Item Ledger Entry";
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        CLEAR(PostedAsmHeader);
        if TempSalesInvLineG.Type <> TempSalesInvLineG.Type::Item then
            exit(false);
        ValueEntry.SETCURRENTKEY("Document No.");
        ValueEntry.SETRANGE("Document No.", TempSalesInvLineG."Document No.");
        ValueEntry.SETRANGE("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SETRANGE("Document Line No.", TempSalesInvLineG."Line No.");
        if not ValueEntry.FINDFIRST() then
            exit(false);
        if not ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.") then
            exit(false);
        if ItemLedgerEntry."Document Type" <> ItemLedgerEntry."Document Type"::"Sales Shipment" then
            exit(false);
        SalesShipmentLine.GET(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
        if not SalesShipmentLine.AsmToShipmentExists(PostedAsmHeader) then
            exit(false);
        if ValueEntry.COUNT > 1 then begin
            ValueEntry2.COPY(ValueEntry);
            ValueEntry2.SETFILTER("Item Ledger Entry No.", '<>%1', ValueEntry."Item Ledger Entry No.");
            if ValueEntry2.FINDSET() then
                repeat
                    ItemLedgerEntry2.GET(ValueEntry2."Item Ledger Entry No.");
                    if (ItemLedgerEntry2."Document Type" <> ItemLedgerEntry."Document Type") or
                       (ItemLedgerEntry2."Document No." <> ItemLedgerEntry."Document No.") or
                       (ItemLedgerEntry2."Document Line No." <> ItemLedgerEntry."Document Line No.")
                    then
                        ERROR(Text032, TempSalesInvLineG."Document No.");
                until ValueEntry2.NEXT() = 0;
        end;
        GenerateAsmDataFromPosted(PostedAsmHeader, DocType);
        exit(true);
    end;

    procedure InitAsmCopyHandling(ResetQuantities: Boolean)
    begin
        if ResetQuantities then begin
            QtyToAsmToOrder := 0;
            QtyToAsmToOrderBase := 0;
        end;
        TempAsmHeader.DELETEALL();
        TempAsmLine.DELETEALL();
    end;

    local procedure RetrieveSalesInvLine(SalesLine: Record "Sales Line"; PosNo: Integer; LineCountsEqual: Boolean): Boolean
    begin
        if not LineCountsEqual then
            exit(false);
        TempSalesInvLineG.FINDSET();
        if PosNo > 1 then
            TempSalesInvLineG.NEXT(PosNo - 1);
        exit((SalesLine.Type = TempSalesInvLineG.Type) and (SalesLine."No." = TempSalesInvLineG."No."));
    end;

    procedure InitialToAsmHeaderCheck(ToAsmHeader: Record "Assembly Header"; IncludeHeaderP: Boolean)
    begin
        ToAsmHeader.TESTFIELD("No.");
        if IncludeHeaderP then begin
            ToAsmHeader.TESTFIELD("Item No.", '');
            ToAsmHeader.TESTFIELD(Quantity, 0);
        end else begin
            ToAsmHeader.TESTFIELD("Item No.");
            ToAsmHeader.TESTFIELD(Quantity);
        end;
    end;

    local procedure GetAsmOrderType(SalesLineDocType: Option Quote,"Order",,,"Blanket Order"): Integer
    begin
        if SalesLineDocType in [SalesLineDocType::Quote, SalesLineDocType::Order, SalesLineDocType::"Blanket Order"] then
            exit(SalesLineDocType);
        exit(-1);
    end;

    local procedure ProcessToAsmHeader(var ToAsmHeader: Record "Assembly Header"; TempFromAsmHeader: Record "Assembly Header" temporary; ToSalesLine: Record "Sales Line"; BasicAsmOrderCopy: Boolean; AvailabilityCheck: Boolean)
    begin
        if AvailabilityCheck then begin
            ToAsmHeader."Item No." := TempFromAsmHeader."Item No.";
            ToAsmHeader."Location Code" := TempFromAsmHeader."Location Code";
            ToAsmHeader."Variant Code" := TempFromAsmHeader."Variant Code";
            ToAsmHeader."Unit of Measure Code" := TempFromAsmHeader."Unit of Measure Code";
        end else begin
            ToAsmHeader.VALIDATE("Item No.", TempFromAsmHeader."Item No.");
            ToAsmHeader.VALIDATE("Location Code", TempFromAsmHeader."Location Code");
            ToAsmHeader.VALIDATE("Variant Code", TempFromAsmHeader."Variant Code");
            ToAsmHeader.VALIDATE("Unit of Measure Code", TempFromAsmHeader."Unit of Measure Code");
        end;
        if BasicAsmOrderCopy then begin
            ToAsmHeader.VALIDATE("Due Date", TempFromAsmHeader."Due Date");
            ToAsmHeader.Quantity := TempFromAsmHeader.Quantity;
            ToAsmHeader."Quantity (Base)" := TempFromAsmHeader."Quantity (Base)";
        end else begin
            if ToSalesLine."Shipment Date" <> 0D then
                ToAsmHeader.VALIDATE("Due Date", ToSalesLine."Shipment Date");
            ToAsmHeader.Quantity := QtyToAsmToOrder;
            ToAsmHeader."Quantity (Base)" := QtyToAsmToOrderBase;
        end;
        ToAsmHeader."Bin Code" := TempFromAsmHeader."Bin Code";
        ToAsmHeader."Unit Cost" := TempFromAsmHeader."Unit Cost";
        ToAsmHeader.RoundQty(ToAsmHeader.Quantity);
        ToAsmHeader.RoundQty(ToAsmHeader."Quantity (Base)");
        ToAsmHeader."Cost Amount" := ROUND(ToAsmHeader.Quantity * ToAsmHeader."Unit Cost");
        ToAsmHeader.InitRemainingQty();
        ToAsmHeader.InitQtyToAssemble();
        if not AvailabilityCheck then begin
            ToAsmHeader.VALIDATE("Quantity to Assemble");
            ToAsmHeader.VALIDATE("Planning Flexibility", TempFromAsmHeader."Planning Flexibility");
        end;
        CopyFromAsmOrderDimToHdr(ToAsmHeader, TempFromAsmHeader, ToSalesLine);
        ToAsmHeader.MODIFY();
    end;

    local procedure CreateToAsmLines(ToAsmHeader: Record "Assembly Header"; var FromAsmLine: Record "Assembly Line"; var ToAssemblyLine: Record "Assembly Line"; ToSalesLine: Record "Sales Line"; BasicAsmOrderCopy: Boolean; AvailabilityCheck: Boolean)
    var
        AssemblyLineMgt: Codeunit "Assembly Line Management";
        UOMMgtL: Codeunit "Unit of Measure Management";
    begin
        if FromAsmLine.FINDSET() then
            repeat
                ToAssemblyLine.INIT();
                ToAssemblyLine."Document Type" := ToAsmHeader."Document Type";
                ToAssemblyLine."Document No." := ToAsmHeader."No.";
                ToAssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(ToAssemblyLine, AvailabilityCheck);
                ToAssemblyLine.INSERT(not AvailabilityCheck);
                if AvailabilityCheck then begin
                    ToAssemblyLine.Type := FromAsmLine.Type;
                    ToAssemblyLine."No." := FromAsmLine."No.";
                    ToAssemblyLine."Resource Usage Type" := FromAsmLine."Resource Usage Type";
                    ToAssemblyLine."Unit of Measure Code" := FromAsmLine."Unit of Measure Code";
                    ToAssemblyLine."Quantity per" := FromAsmLine."Quantity per";
                    ToAssemblyLine.Quantity := GetAppliedQuantityForAsmLine(BasicAsmOrderCopy, ToAsmHeader, FromAsmLine, ToSalesLine);
                end else begin
                    ToAssemblyLine.VALIDATE(Type, FromAsmLine.Type);
                    ToAssemblyLine.VALIDATE("No.", FromAsmLine."No.");
                    ToAssemblyLine.VALIDATE("Resource Usage Type", FromAsmLine."Resource Usage Type");
                    ToAssemblyLine.VALIDATE("Unit of Measure Code", FromAsmLine."Unit of Measure Code");
                    if ToAssemblyLine.Type <> ToAssemblyLine.Type::" " then
                        ToAssemblyLine.VALIDATE("Quantity per", FromAsmLine."Quantity per");
                    ToAssemblyLine.VALIDATE(Quantity, GetAppliedQuantityForAsmLine(BasicAsmOrderCopy, ToAsmHeader, FromAsmLine, ToSalesLine));
                end;
                ToAssemblyLine.ValidateDueDate(ToAsmHeader, ToAsmHeader."Starting Date", false);
                ToAssemblyLine.ValidateLeadTimeOffset(ToAsmHeader, FromAsmLine."Lead-Time Offset", false);
                ToAssemblyLine.Description := FromAsmLine.Description;
                ToAssemblyLine."Description 2" := FromAsmLine."Description 2";
                ToAssemblyLine.Position := FromAsmLine.Position;
                ToAssemblyLine."Position 2" := FromAsmLine."Position 2";
                ToAssemblyLine."Position 3" := FromAsmLine."Position 3";
                if ToAssemblyLine.Type = ToAssemblyLine.Type::Item then
                    if AvailabilityCheck then begin
                        ToAssemblyLine."Location Code" := FromAsmLine."Location Code";
                        ToAssemblyLine."Variant Code" := FromAsmLine."Variant Code";
                    end else begin
                        ToAssemblyLine.VALIDATE("Location Code", FromAsmLine."Location Code");
                        ToAssemblyLine.VALIDATE("Variant Code", FromAsmLine."Variant Code");
                    end;
                if ToAssemblyLine.Type <> ToAssemblyLine.Type::" " then begin
                    if RecalculateLines then
                        ToAssemblyLine."Unit Cost" := ToAssemblyLine.GetUnitCost()
                    else
                        ToAssemblyLine."Unit Cost" := FromAsmLine."Unit Cost";
                    ToAssemblyLine."Cost Amount" := ToAssemblyLine.CalcCostAmount(ToAssemblyLine.Quantity, ToAssemblyLine."Unit Cost");
                    if AvailabilityCheck then begin
                        ToAssemblyLine."Quantity (Base)" := UOMMgtL.CalcBaseQty(ToAssemblyLine.Quantity, ToAssemblyLine."Qty. per Unit of Measure");
                        ToAssemblyLine."Remaining Quantity" := ToAssemblyLine."Quantity (Base)";
                        ToAssemblyLine."Quantity to Consume" := ToAsmHeader."Quantity to Assemble" * FromAsmLine."Quantity per";
                        ToAssemblyLine."Quantity to Consume (Base)" := UOMMgtL.CalcBaseQty(ToAssemblyLine."Quantity to Consume", ToAssemblyLine."Qty. per Unit of Measure");
                    end
                    else
                        ToAssemblyLine.VALIDATE("Quantity to Consume", ToAsmHeader."Quantity to Assemble" * FromAsmLine."Quantity per");
                end;
                CopyFromAsmOrderDimToLine(ToAssemblyLine, FromAsmLine, BasicAsmOrderCopy);
                ToAssemblyLine.MODIFY(not AvailabilityCheck);
            until FromAsmLine.NEXT() = 0;
    end;

    local procedure CheckAsmOrderAvailability(ToAsmHeader: Record "Assembly Header"; var FromAsmLine: Record "Assembly Line"; ToSalesLine: Record "Sales Line")
    var
        TempToAsmHeader: Record "Assembly Header" temporary;
        TempToAsmLine: Record "Assembly Line" temporary;
        AsmLineOnDestinationOrder: Record "Assembly Line";
        AssemblyLineMgt: Codeunit "Assembly Line Management";
        ItemCheckAvailL: Codeunit "Item-Check Avail.";
        LineNo: Integer;
    begin
        TempToAsmHeader := ToAsmHeader;
        TempToAsmHeader.INSERT();
        CreateToAsmLines(TempToAsmHeader, FromAsmLine, TempToAsmLine, ToSalesLine, true, true);
        if TempToAsmLine.FINDLAST() then
            LineNo := TempToAsmLine."Line No.";
        CLEAR(TempToAsmLine);
        AsmLineOnDestinationOrder.SETRANGE("Document Type", ToAsmHeader."Document Type");
        AsmLineOnDestinationOrder.SETRANGE("Document No.", ToAsmHeader."No.");
        AsmLineOnDestinationOrder.SETRANGE(Type, AsmLineOnDestinationOrder.Type::Item);
        if AsmLineOnDestinationOrder.FINDSET() then
            repeat
                TempToAsmLine := AsmLineOnDestinationOrder;
                LineNo += 10000;
                TempToAsmLine."Line No." := LineNo;
                TempToAsmLine.INSERT();
            until AsmLineOnDestinationOrder.NEXT() = 0;
        if AssemblyLineMgt.ShowAvailability(false, TempToAsmHeader, TempToAsmLine) then
            ItemCheckAvailL.RaiseUpdateInterruptedError();
        TempToAsmLine.DELETEALL();
    end;

    local procedure GetAppliedQuantityForAsmLine(BasicAsmOrderCopy: Boolean; ToAsmHeader: Record "Assembly Header"; TempFromAsmLine: Record "Assembly Line" temporary; ToSalesLine: Record "Sales Line"): Decimal
    begin
        if BasicAsmOrderCopy then
            exit(ToAsmHeader.Quantity * TempFromAsmLine."Quantity per");
        case ToSalesLine."Document Type" of
            ToSalesLine."Document Type"::Order:
                exit(ToSalesLine."Qty. to Assemble to Order" * TempFromAsmLine."Quantity per");
            ToSalesLine."Document Type"::Quote,
          ToSalesLine."Document Type"::"Blanket Order":
                exit(ToSalesLine.Quantity * TempFromAsmLine."Quantity per");
        end;
    end;

    procedure ArchSalesHeaderDocType(DocType: Option): Integer
    var
        FromSalesHeaderArchive: Record "Sales Header Archive";
    begin
        case DocType of
            SalesDocType::"Arch. Quote".AsInteger():
                exit(FromSalesHeaderArchive."Document Type"::Quote.AsInteger());
            SalesDocType::"Arch. Order".AsInteger():
                exit(FromSalesHeaderArchive."Document Type"::Order.AsInteger());
            SalesDocType::"Arch. Blanket Order".AsInteger():
                exit(FromSalesHeaderArchive."Document Type"::"Blanket Order".AsInteger());
            SalesDocType::"Arch. Return Order".AsInteger():
                exit(FromSalesHeaderArchive."Document Type"::"Return Order".AsInteger());
        end;
    end;

    local procedure CopyFromArchSalesDocDimToHdr(var ToSalesHeader: Record "Sales Header"; FromSalesHeaderArchive: Record "Sales Header Archive")
    begin
        ToSalesHeader."Shortcut Dimension 1 Code" := FromSalesHeaderArchive."Shortcut Dimension 1 Code";
        ToSalesHeader."Shortcut Dimension 2 Code" := FromSalesHeaderArchive."Shortcut Dimension 2 Code";
        ToSalesHeader."Dimension Set ID" := FromSalesHeaderArchive."Dimension Set ID";
    end;

    local procedure CopyFromArchSalesDocDimToLine(var ToSalesLine: Record "Sales Line"; FromSalesLineArchive: Record "Sales Line Archive")
    begin
        if IncludeHeader then begin
            ToSalesLine."Shortcut Dimension 1 Code" := FromSalesLineArchive."Shortcut Dimension 1 Code";
            ToSalesLine."Shortcut Dimension 2 Code" := FromSalesLineArchive."Shortcut Dimension 2 Code";
            ToSalesLine."Dimension Set ID" := FromSalesLineArchive."Dimension Set ID";
        end;
    end;

    procedure ArchPurchHeaderDocType(DocType: Option): Integer
    var
        FromPurchHeaderArchive: Record "Purchase Header Archive";
    begin
        case DocType of
            PurchDocType::"Arch. Quote".AsInteger():
                exit(FromPurchHeaderArchive."Document Type"::Quote.AsInteger());
            PurchDocType::"Arch. Order".AsInteger():
                exit(FromPurchHeaderArchive."Document Type"::Order.AsInteger());
            PurchDocType::"Arch. Blanket Order".AsInteger():
                exit(FromPurchHeaderArchive."Document Type"::"Blanket Order".AsInteger());
            PurchDocType::"Arch. Return Order".AsInteger():
                exit(FromPurchHeaderArchive."Document Type"::"Return Order".AsInteger());
        end;
    end;

    local procedure CopyFromArchPurchDocDimToHdr(var ToPurchHeader: Record "Purchase Header"; FromPurchHeaderArchive: Record "Purchase Header Archive")
    begin
        ToPurchHeader."Shortcut Dimension 1 Code" := FromPurchHeaderArchive."Shortcut Dimension 1 Code";
        ToPurchHeader."Shortcut Dimension 2 Code" := FromPurchHeaderArchive."Shortcut Dimension 2 Code";
        ToPurchHeader."Dimension Set ID" := FromPurchHeaderArchive."Dimension Set ID";
    end;

    local procedure CopyFromArchPurchDocDimToLine(var ToPurchLine: Record "Purchase Line"; FromPurchLineArchive: Record "Purchase Line Archive")
    begin
        if IncludeHeader then begin
            ToPurchLine."Shortcut Dimension 1 Code" := FromPurchLineArchive."Shortcut Dimension 1 Code";
            ToPurchLine."Shortcut Dimension 2 Code" := FromPurchLineArchive."Shortcut Dimension 2 Code";
            ToPurchLine."Dimension Set ID" := FromPurchLineArchive."Dimension Set ID";
        end;
    end;

    local procedure CopyFromAsmOrderDimToHdr(var ToAssemblyHeader: Record "Assembly Header"; FromAssemblyHeader: Record "Assembly Header"; ToSalesLine: Record "Sales Line")
    begin
        if RecalculateLines then begin
            ToAssemblyHeader."Dimension Set ID" := ToSalesLine."Dimension Set ID";
            ToAssemblyHeader."Shortcut Dimension 1 Code" := ToSalesLine."Shortcut Dimension 1 Code";
            ToAssemblyHeader."Shortcut Dimension 2 Code" := ToSalesLine."Shortcut Dimension 2 Code";
        end else begin
            ToAssemblyHeader."Dimension Set ID" := FromAssemblyHeader."Dimension Set ID";
            ToAssemblyHeader."Shortcut Dimension 1 Code" := FromAssemblyHeader."Shortcut Dimension 1 Code";
            ToAssemblyHeader."Shortcut Dimension 2 Code" := FromAssemblyHeader."Shortcut Dimension 2 Code";
        end;
    end;

    local procedure CopyFromAsmOrderDimToLine(var ToAssemblyLine: Record "Assembly Line"; FromAssemblyLine: Record "Assembly Line"; BasicAsmOrderCopy: Boolean)
    begin
        if RecalculateLines or BasicAsmOrderCopy then
            exit;

        ToAssemblyLine."Dimension Set ID" := FromAssemblyLine."Dimension Set ID";
        ToAssemblyLine."Shortcut Dimension 1 Code" := FromAssemblyLine."Shortcut Dimension 1 Code";
        ToAssemblyLine."Shortcut Dimension 2 Code" := FromAssemblyLine."Shortcut Dimension 2 Code";
    end;

    procedure SetArchDocVal(DocOccurrencyNo: Integer; DocVersionNo: Integer)
    begin
        FromDocOccurrenceNo := DocOccurrencyNo;
        FromDocVersionNo := DocVersionNo;
    end;

    local procedure CopyArchSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeaderArchive: Record "Sales Header Archive"; var FromSalesLineArchive: Record "Sales Line Archive"; var NextLineNo: Integer; var LinesNotCopied: Integer; RecalculateAmount: Boolean): Boolean
    var
        ToSalesLine2: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FromSalesHeader: Record "Sales Header";
        FromSalesLine: Record "Sales Line";
        CopyThisLine: Boolean;
    begin
        CopyThisLine := true;
        OnBeforeCopyArchSalesLine(ToSalesHeader, FromSalesHeaderArchive, FromSalesLineArchive, RecalculateLines, CopyThisLine);
        if not CopyThisLine then begin
            LinesNotCopied := LinesNotCopied + 1;
            exit(false);
        end;

        if ((ToSalesHeader."Language Code" <> FromSalesHeaderArchive."Language Code") or RecalculateLines) and
           (FromSalesLineArchive."Attached to Line No." <> 0)
        then
            exit(false);

        ToSalesLine.SetSalesHeader(ToSalesHeader);
        if RecalculateLines and not FromSalesLineArchive."System-Created Entry" then
            ToSalesLine.INIT()
        else
            ToSalesLine.TRANSFERFIELDS(FromSalesLineArchive);
        NextLineNo := NextLineNo + 10000;
        ToSalesLine."Document Type" := ToSalesHeader."Document Type";
        ToSalesLine."Document No." := ToSalesHeader."No.";
        ToSalesLine."Line No." := NextLineNo;
        ToSalesLine.VALIDATE("Currency Code", FromSalesHeaderArchive."Currency Code");

        if RecalculateLines and not FromSalesLineArchive."System-Created Entry" then begin
            FromSalesHeader.TRANSFERFIELDS(FromSalesHeaderArchive, true);
            FromSalesLine.TRANSFERFIELDS(FromSalesLineArchive, true);
            RecalculateSalesLine(ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine, CopyThisLine);
        end else begin
            InitSalesLineFields(ToSalesLine);

            ToSalesLine.InitOutstanding();
            if ToSalesLine."Document Type" in
               [ToSalesLine."Document Type"::"Return Order", ToSalesLine."Document Type"::"Credit Memo"]
            then
                ToSalesLine.InitQtyToReceive()
            else
                ToSalesLine.InitQtyToShip();
            ToSalesLine."VAT Difference" := FromSalesLineArchive."VAT Difference";
            if not CreateToHeader then
                ToSalesLine."Shipment Date" := ToSalesHeader."Shipment Date";
            ToSalesLine."Appl.-from Item Entry" := 0;
            ToSalesLine."Appl.-to Item Entry" := 0;

            CleanSpecialOrderDropShipmentInSalesLine(ToSalesLine);
            if RecalculateAmount and (FromSalesLineArchive."Appl.-from Item Entry" = 0) then begin
                ToSalesLine.VALIDATE("Line Discount %", FromSalesLineArchive."Line Discount %");
                ToSalesLine.VALIDATE(
                  "Inv. Discount Amount",
                  ROUND(FromSalesLineArchive."Inv. Discount Amount", Currency."Amount Rounding Precision"));
                ToSalesLine.VALIDATE("Unit Cost (LCY)", FromSalesLineArchive."Unit Cost (LCY)");
            end;
            if VATPostingSetup.GET(ToSalesLine."VAT Bus. Posting Group", ToSalesLine."VAT Prod. Posting Group") then
                ToSalesLine."VAT Identifier" := VATPostingSetup."VAT Identifier";

            ToSalesLine.UpdateWithWarehouseShip();
            if (ToSalesLine.Type = ToSalesLine.Type::Item) and (ToSalesLine."No." <> '') then begin
                GetItem(ToSalesLine."No.");
                if (Item."Costing Method" = Item."Costing Method"::Standard) and not ToSalesLine.IsShipment() then
                    ToSalesLine.GetUnitCost();
            end;
        end;

        if ExactCostRevMandatory and
           (FromSalesLineArchive.Type = FromSalesLineArchive.Type::Item) and
           (FromSalesLineArchive."Appl.-from Item Entry" <> 0) and
           not MoveNegLines
        then begin
            if RecalculateAmount then begin
                ToSalesLine.VALIDATE("Unit Price", FromSalesLineArchive."Unit Price");
                ToSalesLine.VALIDATE(
                  "Line Discount Amount",
                  ROUND(FromSalesLineArchive."Line Discount Amount", Currency."Amount Rounding Precision"));
                ToSalesLine.VALIDATE(
                  "Inv. Discount Amount",
                  ROUND(FromSalesLineArchive."Inv. Discount Amount", Currency."Amount Rounding Precision"));
            end;
            ToSalesLine.VALIDATE("Appl.-from Item Entry", FromSalesLineArchive."Appl.-from Item Entry");
            if not CreateToHeader then
                if ToSalesLine."Shipment Date" = 0D then
                    InitShipmentDateInLine(ToSalesHeader, ToSalesLine);
        end;

        if MoveNegLines and (ToSalesLine.Type <> ToSalesLine.Type::" ") then begin
            ToSalesLine.VALIDATE(Quantity, -FromSalesLineArchive.Quantity);
            ToSalesLine.VALIDATE("Line Discount %", FromSalesLineArchive."Line Discount %");
            ToSalesLine."Appl.-to Item Entry" := FromSalesLineArchive."Appl.-to Item Entry";
            ToSalesLine."Appl.-from Item Entry" := FromSalesLineArchive."Appl.-from Item Entry";
        end;

        if not ((ToSalesHeader."Language Code" <> FromSalesHeaderArchive."Language Code") or RecalculateLines) then
            ToSalesLine."Attached to Line No." :=
              TransferOldExtLines.TransferExtendedText(
                FromSalesLineArchive."Line No.", NextLineNo, FromSalesLineArchive."Attached to Line No.")
        else
            if TransferExtendedText.SalesCheckIfAnyExtText(ToSalesLine, false) then begin
                TransferExtendedText.InsertSalesExtText(ToSalesLine);
                ToSalesLine2.SETRANGE("Document Type", ToSalesLine."Document Type");
                ToSalesLine2.SETRANGE("Document No.", ToSalesLine."Document No.");
                ToSalesLine2.FINDLAST();
                NextLineNo := ToSalesLine2."Line No.";
            end;

        if CopyThisLine then begin
            OnCopyArchSalesLineOnBeforeToSalesLineInsert(ToSalesLine, FromSalesLineArchive, RecalculateLines);
            ToSalesLine.INSERT();
            OnCopyArchSalesLineOnAfterToSalesLineInsert(ToSalesLine, FromSalesLineArchive, RecalculateLines);
        end else
            LinesNotCopied := LinesNotCopied + 1;

        exit(CopyThisLine);
    end;

    local procedure CopyArchPurchLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; var FromPurchHeaderArchive: Record "Purchase Header Archive"; var FromPurchLineArchive: Record "Purchase Line Archive"; var NextLineNo: Integer; var LinesNotCopied: Integer; RecalculateAmount: Boolean): Boolean
    var
        ToPurchLine2: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FromPurchHeader: Record "Purchase Header";
        FromPurchLine: Record "Purchase Line";
        CopyThisLine: Boolean;
    begin
        CopyThisLine := true;
        OnBeforeCopyArchPurchLine(ToPurchHeader, FromPurchHeaderArchive, FromPurchLineArchive, RecalculateLines, CopyThisLine);
        if not CopyThisLine then begin
            LinesNotCopied := LinesNotCopied + 1;
            exit(false);
        end;

        if ((ToPurchHeader."Language Code" <> FromPurchHeaderArchive."Language Code") or RecalculateLines) and
           (FromPurchLineArchive."Attached to Line No." <> 0)
        then
            exit(false);

        if RecalculateLines and not FromPurchLineArchive."System-Created Entry" then
            ToPurchLine.INIT()
        else
            ToPurchLine.TRANSFERFIELDS(FromPurchLineArchive);
        NextLineNo := NextLineNo + 10000;
        ToPurchLine."Document Type" := ToPurchHeader."Document Type";
        ToPurchLine."Document No." := ToPurchHeader."No.";
        ToPurchLine."Line No." := NextLineNo;
        ToPurchLine.VALIDATE("Currency Code", FromPurchHeaderArchive."Currency Code");

        if RecalculateLines and not FromPurchLineArchive."System-Created Entry" then begin
            FromPurchHeader.TRANSFERFIELDS(FromPurchHeaderArchive, true);
            FromPurchLine.TRANSFERFIELDS(FromPurchLineArchive, true);
            RecalculatePurchLine(ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine, CopyThisLine);
        end else begin
            InitPurchLineFields(ToPurchLine);

            ToPurchLine.InitOutstanding();
            if ToPurchLine."Document Type" in
               [ToPurchLine."Document Type"::"Return Order", ToPurchLine."Document Type"::"Credit Memo"]
            then
                ToPurchLine.InitQtyToShip()
            else
                ToPurchLine.InitQtyToReceive();
            ToPurchLine."VAT Difference" := FromPurchLineArchive."VAT Difference";
            ToPurchLine."Receipt No." := '';
            ToPurchLine."Receipt Line No." := 0;
            if not CreateToHeader then
                ToPurchLine."Expected Receipt Date" := ToPurchHeader."Expected Receipt Date";
            ToPurchLine."Appl.-to Item Entry" := 0;

            if FromPurchLineArchive."Drop Shipment" or FromPurchLineArchive."Special Order" then
                ToPurchLine."Purchasing Code" := '';
            CleanSpecialOrderDropShipmentInPurchLine(ToPurchLine);

            if RecalculateAmount then begin
                ToPurchLine.VALIDATE("Line Discount %", FromPurchLineArchive."Line Discount %");
                ToPurchLine.VALIDATE(
                  "Inv. Discount Amount",
                  ROUND(FromPurchLineArchive."Inv. Discount Amount", Currency."Amount Rounding Precision"));
            end;
            if VATPostingSetup.GET(ToPurchLine."VAT Bus. Posting Group", ToPurchLine."VAT Prod. Posting Group") then
                ToPurchLine."VAT Identifier" := VATPostingSetup."VAT Identifier";

            ToPurchLine.UpdateWithWarehouseReceive();
            ToPurchLine."Pay-to Vendor No." := ToPurchHeader."Pay-to Vendor No.";
        end;

        if ExactCostRevMandatory and
           (FromPurchLineArchive.Type = FromPurchLineArchive.Type::Item) and
           (FromPurchLineArchive."Appl.-to Item Entry" <> 0) and
           not MoveNegLines
        then begin
            if RecalculateAmount then begin
                ToPurchLine.VALIDATE("Direct Unit Cost", FromPurchLineArchive."Direct Unit Cost");
                ToPurchLine.VALIDATE(
                  "Line Discount Amount",
                  ROUND(FromPurchLineArchive."Line Discount Amount", Currency."Amount Rounding Precision"));
                ToPurchLine.VALIDATE(
                  "Inv. Discount Amount",
                  ROUND(FromPurchLineArchive."Inv. Discount Amount", Currency."Amount Rounding Precision"));
            end;
            ToPurchLine.VALIDATE("Appl.-to Item Entry", FromPurchLineArchive."Appl.-to Item Entry");
            if not CreateToHeader then
                if ToPurchLine."Expected Receipt Date" = 0D then
                    if ToPurchHeader."Expected Receipt Date" <> 0D then
                        ToPurchLine."Expected Receipt Date" := ToPurchHeader."Expected Receipt Date"
                    else
                        ToPurchLine."Expected Receipt Date" := WORKDATE();
        end;

        if MoveNegLines and (ToPurchLine.Type <> ToPurchLine.Type::" ") then begin
            ToPurchLine.VALIDATE(Quantity, -FromPurchLineArchive.Quantity);
            ToPurchLine."Appl.-to Item Entry" := FromPurchLineArchive."Appl.-to Item Entry"
        end;

        if not ((ToPurchHeader."Language Code" <> FromPurchHeaderArchive."Language Code") or RecalculateLines) then
            ToPurchLine."Attached to Line No." :=
              TransferOldExtLines.TransferExtendedText(
                FromPurchLineArchive."Line No.", NextLineNo, FromPurchLineArchive."Attached to Line No.")
        else
            if TransferExtendedText.PurchCheckIfAnyExtText(ToPurchLine, false) then begin
                TransferExtendedText.InsertPurchExtText(ToPurchLine);
                ToPurchLine2.SETRANGE("Document Type", ToPurchLine."Document Type");
                ToPurchLine2.SETRANGE("Document No.", ToPurchLine."Document No.");
                ToPurchLine2.FINDLAST();
                NextLineNo := ToPurchLine2."Line No.";
            end;

        if CopyThisLine then begin
            OnCopyArchPurchLineOnBeforeToPurchLineInsert(ToPurchLine, FromPurchLineArchive, RecalculateLines);
            ToPurchLine.INSERT();
            OnCopyArchPurchLineOnAfterToPurchLineInsert(ToPurchLine, FromPurchLineArchive, RecalculateLines);
        end else
            LinesNotCopied := LinesNotCopied + 1;

        exit(CopyThisLine);
    end;

    local procedure CopyDocLines(RecalculateAmount: Boolean; ToPurchLine: Record "Purchase Line"; var FromPurchLine: Record "Purchase Line")
    begin
        if not RecalculateAmount then
            exit;
        if (ToPurchLine.Type <> ToPurchLine.Type::" ") and (ToPurchLine."No." <> '') then begin
            ToPurchLine.VALIDATE("Line Discount %", FromPurchLine."Line Discount %");
            ToPurchLine.VALIDATE(
              "Inv. Discount Amount",
              ROUND(FromPurchLine."Inv. Discount Amount", Currency."Amount Rounding Precision"));
        end;
    end;

    local procedure CheckCreditLimit(FromSalesHeader: Record "Sales Header"; ToSalesHeader: Record "Sales Header")
    begin
        if SkipTestCreditLimit then
            exit;

        if IncludeHeader then
            CustCheckCreditLimit.SalesHeaderCheck(FromSalesHeader)
        else
            CustCheckCreditLimit.SalesHeaderCheck(ToSalesHeader);
    end;

    local procedure CheckUnappliedLines(SkippedLineP: Boolean; var MissingExCostRevLink: Boolean)
    begin
        if SkippedLineP and MissingExCostRevLink then begin
            if not WarningDone then
                MESSAGE(Text030);
            MissingExCostRevLink := false;
            WarningDone := true;
        end;
    end;

    local procedure SetDefaultValuesToSalesLine(var ToSalesLine: Record "Sales Line"; ToSalesHeader: Record "Sales Header"; VATDifference: Decimal)
    begin
        InitSalesLineFields(ToSalesLine);

        if ToSalesLine."Document Type" in
           [ToSalesLine."Document Type"::"Blanket Order",
            ToSalesLine."Document Type"::"Credit Memo",
            ToSalesLine."Document Type"::"Return Order"]
        then begin
            ToSalesLine."Blanket Order No." := '';
            ToSalesLine."Blanket Order Line No." := 0;
        end;

        //>>BC6 SBE 27/01/2022
        ToSalesLine.SetHideValidationDialog(true);
        ToSalesLine.Quantity := TempRecGTempSalesLine."Outstanding Quantity";
        ToSalesLine."Quantity (Base)" := TempRecGTempSalesLine."Outstanding Quantity";
        ToSalesLine."Line Discount %" := TempRecGTempSalesLine."Line Discount %";
        //<<BC6 SBE 27/01/2022

        ToSalesLine.InitOutstanding();
        if ToSalesLine."Document Type" in
           [ToSalesLine."Document Type"::"Return Order", ToSalesLine."Document Type"::"Credit Memo"]
        then
            ToSalesLine.InitQtyToReceive()
        else
            ToSalesLine.InitQtyToShip();
        ToSalesLine."VAT Difference" := VATDifference;
        ToSalesLine."Shipment No." := '';
        ToSalesLine."Shipment Line No." := 0;
        if not CreateToHeader and RecalculateLines then
            ToSalesLine."Shipment Date" := ToSalesHeader."Shipment Date";
        ToSalesLine."Appl.-from Item Entry" := 0;
        ToSalesLine."Appl.-to Item Entry" := 0;

        ToSalesLine."Purchase Order No." := '';
        ToSalesLine."Purch. Order Line No." := 0;
        ToSalesLine."Special Order Purchase No." := '';
        ToSalesLine."Special Order Purch. Line No." := 0;

        OnAfterSetDefaultValuesToSalesLine(ToSalesLine, ToSalesHeader);
    end;

    local procedure SetDefaultValuesToPurchLine(var ToPurchLine: Record "Purchase Line"; ToPurchHeader: Record "Purchase Header"; VATDifference: Decimal)
    begin
        InitPurchLineFields(ToPurchLine);

        if ToPurchLine."Document Type" in
           [ToPurchLine."Document Type"::"Blanket Order",
            ToPurchLine."Document Type"::"Credit Memo",
            ToPurchLine."Document Type"::"Return Order"]
        then begin
            ToPurchLine."Blanket Order No." := '';
            ToPurchLine."Blanket Order Line No." := 0;
        end;

        ToPurchLine.InitOutstanding();
        if ToPurchLine."Document Type" in
           [ToPurchLine."Document Type"::"Return Order", ToPurchLine."Document Type"::"Credit Memo"]
        then
            ToPurchLine.InitQtyToShip()
        else
            ToPurchLine.InitQtyToReceive();
        ToPurchLine."VAT Difference" := VATDifference;
        ToPurchLine."Receipt No." := '';
        ToPurchLine."Receipt Line No." := 0;
        if not CreateToHeader then
            ToPurchLine."Expected Receipt Date" := ToPurchHeader."Expected Receipt Date";
        ToPurchLine."Appl.-to Item Entry" := 0;

        ToPurchLine."Sales Order No." := '';
        ToPurchLine."Sales Order Line No." := 0;
        ToPurchLine."Special Order Sales No." := '';
        ToPurchLine."Special Order Sales Line No." := 0;

        OnAfterSetDefaultValuesToPurchLine(ToPurchLine);
    end;

    local procedure CopyItemTrackingEntries(SalesLine: Record "Sales Line"; var PurchLine: Record "Purchase Line"; SalesPricesIncludingVAT: Boolean; PurchPricesIncludingVAT: Boolean)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        TrackingSpecification: Record "Tracking Specification";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        MissingExCostRevLink: Boolean;
    begin
        PurchasesPayablesSetup.GET();
        FindTrackingEntries(
          TempItemLedgerEntry, DATABASE::"Sales Line", TrackingSpecification."Source Subtype"::"5",
          SalesLine."Document No.", '', 0, SalesLine."Line No.", SalesLine."No.");
        ItemTrackingMgt.CopyItemLedgEntryTrkgToPurchLn(
          TempItemLedgerEntry, PurchLine, PurchasesPayablesSetup."Exact Cost Reversing Mandatory", MissingExCostRevLink,
          SalesPricesIncludingVAT, PurchPricesIncludingVAT, true);
    end;

    local procedure FindTrackingEntries(var TempItemLedgerEntry: Record "Item Ledger Entry" temporary; Type: Integer; Subtype: Integer; ID: Code[20]; BatchName: Code[10]; ProdOrderLine: Integer; RefNo: Integer; ItemNo: Code[20])
    var
        TrackingSpecification: Record "Tracking Specification";
    begin
        TrackingSpecification.SETCURRENTKEY("Source ID", "Source Type", "Source Subtype", "Source Batch Name",
  "Source Prod. Order Line", "Source Ref. No.");
        TrackingSpecification.SETRANGE("Source ID", ID);
        TrackingSpecification.SETRANGE("Source Ref. No.", RefNo);
        TrackingSpecification.SETRANGE("Source Type", Type);
        TrackingSpecification.SETRANGE("Source Subtype", Subtype);
        TrackingSpecification.SETRANGE("Source Batch Name", BatchName);
        TrackingSpecification.SETRANGE("Source Prod. Order Line", ProdOrderLine);
        TrackingSpecification.SETRANGE("Item No.", ItemNo);
        if TrackingSpecification.FINDSET() then
            repeat
                AddItemLedgerEntry(TempItemLedgerEntry, TrackingSpecification."Lot No.", TrackingSpecification."Serial No.", TrackingSpecification."Entry No.");
            until TrackingSpecification.NEXT() = 0;
    end;

    local procedure AddItemLedgerEntry(var TempItemLedgerEntry: Record "Item Ledger Entry" temporary; LotNo: Code[50]; SerialNo: Code[50]; EntryNo: Integer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if (LotNo = '') and (SerialNo = '') then
            exit;

        if not ItemLedgerEntry.GET(EntryNo) then
            exit;

        TempItemLedgerEntry := ItemLedgerEntry;
        if TempItemLedgerEntry.INSERT() then;
    end;

    local procedure CopyFieldsFromOldSalesHeader(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header")
    begin
        ToSalesHeader."No. Series" := OldSalesHeader."No. Series";
        ToSalesHeader."Posting Description" := OldSalesHeader."Posting Description";
        ToSalesHeader."Posting No." := OldSalesHeader."Posting No.";
        ToSalesHeader."Posting No. Series" := OldSalesHeader."Posting No. Series";
        ToSalesHeader."Shipping No." := OldSalesHeader."Shipping No.";
        ToSalesHeader."Shipping No. Series" := OldSalesHeader."Shipping No. Series";
        ToSalesHeader."Return Receipt No." := OldSalesHeader."Return Receipt No.";
        ToSalesHeader."Return Receipt No. Series" := OldSalesHeader."Return Receipt No. Series";
        ToSalesHeader."Prepayment No. Series" := OldSalesHeader."Prepayment No. Series";
        ToSalesHeader."Prepayment No." := OldSalesHeader."Prepayment No.";
        ToSalesHeader."Prepmt. Posting Description" := OldSalesHeader."Prepmt. Posting Description";
        ToSalesHeader."Prepmt. Cr. Memo No. Series" := OldSalesHeader."Prepmt. Cr. Memo No. Series";
        ToSalesHeader."Prepmt. Cr. Memo No." := OldSalesHeader."Prepmt. Cr. Memo No.";
        ToSalesHeader."Prepmt. Posting Description" := OldSalesHeader."Prepmt. Posting Description";
        SetSalespersonPurchaserCode(ToSalesHeader."Salesperson Code");
    end;

    local procedure CopyFieldsFromOldPurchHeader(var ToPurchHeader: Record "Purchase Header"; OldPurchHeader: Record "Purchase Header")
    begin
        ToPurchHeader."No. Series" := OldPurchHeader."No. Series";
        ToPurchHeader."Posting Description" := OldPurchHeader."Posting Description";
        ToPurchHeader."Posting No." := OldPurchHeader."Posting No.";
        ToPurchHeader."Posting No. Series" := OldPurchHeader."Posting No. Series";
        ToPurchHeader."Receiving No." := OldPurchHeader."Receiving No.";
        ToPurchHeader."Receiving No. Series" := OldPurchHeader."Receiving No. Series";
        ToPurchHeader."Return Shipment No." := OldPurchHeader."Return Shipment No.";
        ToPurchHeader."Return Shipment No. Series" := OldPurchHeader."Return Shipment No. Series";
        ToPurchHeader."Prepayment No. Series" := OldPurchHeader."Prepayment No. Series";
        ToPurchHeader."Prepayment No." := OldPurchHeader."Prepayment No.";
        ToPurchHeader."Prepmt. Posting Description" := OldPurchHeader."Prepmt. Posting Description";
        ToPurchHeader."Prepmt. Cr. Memo No. Series" := OldPurchHeader."Prepmt. Cr. Memo No. Series";
        ToPurchHeader."Prepmt. Cr. Memo No." := OldPurchHeader."Prepmt. Cr. Memo No.";
        ToPurchHeader."Prepmt. Posting Description" := OldPurchHeader."Prepmt. Posting Description";
        SetSalespersonPurchaserCode(ToPurchHeader."Purchaser Code");
    end;

    local procedure CheckFromSalesHeader(SalesHeaderFrom: Record "Sales Header"; SalesHeaderTo: Record "Sales Header")
    begin
        SalesHeaderFrom.TESTFIELD("Sell-to Customer No.", SalesHeaderTo."Sell-to Customer No.");
        SalesHeaderFrom.TESTFIELD("Bill-to Customer No.", SalesHeaderTo."Bill-to Customer No.");
        SalesHeaderFrom.TESTFIELD("Customer Posting Group", SalesHeaderTo."Customer Posting Group");
        SalesHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", SalesHeaderTo."Gen. Bus. Posting Group");
        SalesHeaderFrom.TESTFIELD("Currency Code", SalesHeaderTo."Currency Code");
        SalesHeaderFrom.TESTFIELD("Prices Including VAT", SalesHeaderTo."Prices Including VAT");

        OnAfterCheckFromSalesHeader(SalesHeaderFrom, SalesHeaderTo);
    end;

    local procedure CheckFromSalesShptHeader(SalesShipmentHeaderFrom: Record "Sales Shipment Header"; SalesHeaderTo: Record "Sales Header")
    begin
        SalesShipmentHeaderFrom.TESTFIELD("Sell-to Customer No.", SalesHeaderTo."Sell-to Customer No.");
        SalesShipmentHeaderFrom.TESTFIELD("Bill-to Customer No.", SalesHeaderTo."Bill-to Customer No.");
        SalesShipmentHeaderFrom.TESTFIELD("Customer Posting Group", SalesHeaderTo."Customer Posting Group");
        SalesShipmentHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", SalesHeaderTo."Gen. Bus. Posting Group");
        SalesShipmentHeaderFrom.TESTFIELD("Currency Code", SalesHeaderTo."Currency Code");
        SalesShipmentHeaderFrom.TESTFIELD("Prices Including VAT", SalesHeaderTo."Prices Including VAT");

        OnAfterCheckFromSalesShptHeader(SalesShipmentHeaderFrom, SalesHeaderTo);
    end;

    local procedure CheckFromSalesInvHeader(SalesInvoiceHeaderFrom: Record "Sales Invoice Header"; SalesHeaderTo: Record "Sales Header")
    begin
        SalesInvoiceHeaderFrom.TESTFIELD("Sell-to Customer No.", SalesHeaderTo."Sell-to Customer No.");
        SalesInvoiceHeaderFrom.TESTFIELD("Bill-to Customer No.", SalesHeaderTo."Bill-to Customer No.");
        SalesInvoiceHeaderFrom.TESTFIELD("Customer Posting Group", SalesHeaderTo."Customer Posting Group");
        SalesInvoiceHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", SalesHeaderTo."Gen. Bus. Posting Group");
        SalesInvoiceHeaderFrom.TESTFIELD("Currency Code", SalesHeaderTo."Currency Code");
        SalesInvoiceHeaderFrom.TESTFIELD("Prices Including VAT", SalesHeaderTo."Prices Including VAT");

        OnAfterCheckFromSalesInvHeader(SalesInvoiceHeaderFrom, SalesHeaderTo);
    end;

    local procedure CheckFromSalesReturnRcptHeader(ReturnReceiptHeaderFrom: Record "Return Receipt Header"; SalesHeaderTo: Record "Sales Header")
    begin
        ReturnReceiptHeaderFrom.TESTFIELD("Sell-to Customer No.", SalesHeaderTo."Sell-to Customer No.");
        ReturnReceiptHeaderFrom.TESTFIELD("Bill-to Customer No.", SalesHeaderTo."Bill-to Customer No.");
        ReturnReceiptHeaderFrom.TESTFIELD("Customer Posting Group", SalesHeaderTo."Customer Posting Group");
        ReturnReceiptHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", SalesHeaderTo."Gen. Bus. Posting Group");
        ReturnReceiptHeaderFrom.TESTFIELD("Currency Code", SalesHeaderTo."Currency Code");
        ReturnReceiptHeaderFrom.TESTFIELD("Prices Including VAT", SalesHeaderTo."Prices Including VAT");

        OnAfterCheckFromSalesReturnRcptHeader(ReturnReceiptHeaderFrom, SalesHeaderTo);
    end;

    local procedure CheckFromSalesCrMemoHeader(SalesCrMemoHeaderFrom: Record "Sales Cr.Memo Header"; SalesHeaderTo: Record "Sales Header")
    begin
        SalesCrMemoHeaderFrom.TESTFIELD("Sell-to Customer No.", SalesHeaderTo."Sell-to Customer No.");
        SalesCrMemoHeaderFrom.TESTFIELD("Bill-to Customer No.", SalesHeaderTo."Bill-to Customer No.");
        SalesCrMemoHeaderFrom.TESTFIELD("Customer Posting Group", SalesHeaderTo."Customer Posting Group");
        SalesCrMemoHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", SalesHeaderTo."Gen. Bus. Posting Group");
        SalesCrMemoHeaderFrom.TESTFIELD("Currency Code", SalesHeaderTo."Currency Code");
        SalesCrMemoHeaderFrom.TESTFIELD("Prices Including VAT", SalesHeaderTo."Prices Including VAT");

        OnAfterCheckFromSalesCrMemoHeader(SalesCrMemoHeaderFrom, SalesHeaderTo);
    end;

    local procedure CheckFromPurchaseHeader(PurchaseHeaderFrom: Record "Purchase Header"; PurchaseHeaderTo: Record "Purchase Header")
    begin
        PurchaseHeaderFrom.TESTFIELD("Buy-from Vendor No.", PurchaseHeaderTo."Buy-from Vendor No.");
        PurchaseHeaderFrom.TESTFIELD("Pay-to Vendor No.", PurchaseHeaderTo."Pay-to Vendor No.");
        PurchaseHeaderFrom.TESTFIELD("Vendor Posting Group", PurchaseHeaderTo."Vendor Posting Group");
        PurchaseHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", PurchaseHeaderTo."Gen. Bus. Posting Group");
        PurchaseHeaderFrom.TESTFIELD("Currency Code", PurchaseHeaderTo."Currency Code");

        OnAfterCheckFromPurchaseHeader(PurchaseHeaderFrom, PurchaseHeaderTo);
    end;

    local procedure CheckFromPurchaseRcptHeader(PurchRcptHeaderFrom: Record "Purch. Rcpt. Header"; PurchaseHeaderTo: Record "Purchase Header")
    begin
        PurchRcptHeaderFrom.TESTFIELD("Buy-from Vendor No.", PurchaseHeaderTo."Buy-from Vendor No.");
        PurchRcptHeaderFrom.TESTFIELD("Pay-to Vendor No.", PurchaseHeaderTo."Pay-to Vendor No.");
        PurchRcptHeaderFrom.TESTFIELD("Vendor Posting Group", PurchaseHeaderTo."Vendor Posting Group");
        PurchRcptHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", PurchaseHeaderTo."Gen. Bus. Posting Group");
        PurchRcptHeaderFrom.TESTFIELD("Currency Code", PurchaseHeaderTo."Currency Code");

        OnAfterCheckFromPurchaseRcptHeader(PurchRcptHeaderFrom, PurchaseHeaderTo);
    end;

    local procedure CheckFromPurchaseInvHeader(PurchInvHeaderFrom: Record "Purch. Inv. Header"; PurchaseHeaderTo: Record "Purchase Header")
    begin
        PurchInvHeaderFrom.TESTFIELD("Buy-from Vendor No.", PurchaseHeaderTo."Buy-from Vendor No.");
        PurchInvHeaderFrom.TESTFIELD("Pay-to Vendor No.", PurchaseHeaderTo."Pay-to Vendor No.");
        PurchInvHeaderFrom.TESTFIELD("Vendor Posting Group", PurchaseHeaderTo."Vendor Posting Group");
        PurchInvHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", PurchaseHeaderTo."Gen. Bus. Posting Group");
        PurchInvHeaderFrom.TESTFIELD("Currency Code", PurchaseHeaderTo."Currency Code");

        OnAfterCheckFromPurchaseInvHeader(PurchInvHeaderFrom, PurchaseHeaderTo);
    end;

    local procedure CheckFromPurchaseReturnShptHeader(ReturnShipmentHeaderFrom: Record "Return Shipment Header"; PurchaseHeaderTo: Record "Purchase Header")
    begin
        ReturnShipmentHeaderFrom.TESTFIELD("Buy-from Vendor No.", PurchaseHeaderTo."Buy-from Vendor No.");
        ReturnShipmentHeaderFrom.TESTFIELD("Pay-to Vendor No.", PurchaseHeaderTo."Pay-to Vendor No.");
        ReturnShipmentHeaderFrom.TESTFIELD("Vendor Posting Group", PurchaseHeaderTo."Vendor Posting Group");
        ReturnShipmentHeaderFrom.TESTFIELD("Gen. Bus. Posting Group", PurchaseHeaderTo."Gen. Bus. Posting Group");
        ReturnShipmentHeaderFrom.TESTFIELD("Currency Code", PurchaseHeaderTo."Currency Code");

        OnAfterCheckFromPurchaseReturnShptHeader(ReturnShipmentHeaderFrom, PurchaseHeaderTo);
    end;

    local procedure CheckFromPurchaseCrMemoHeader(PurchCrMemoHdrFrom: Record "Purch. Cr. Memo Hdr."; PurchaseHeaderTo: Record "Purchase Header")
    begin
        PurchCrMemoHdrFrom.TESTFIELD("Buy-from Vendor No.", PurchaseHeaderTo."Buy-from Vendor No.");
        PurchCrMemoHdrFrom.TESTFIELD("Pay-to Vendor No.", PurchaseHeaderTo."Pay-to Vendor No.");
        PurchCrMemoHdrFrom.TESTFIELD("Vendor Posting Group", PurchaseHeaderTo."Vendor Posting Group");
        PurchCrMemoHdrFrom.TESTFIELD("Gen. Bus. Posting Group", PurchaseHeaderTo."Gen. Bus. Posting Group");
        PurchCrMemoHdrFrom.TESTFIELD("Currency Code", PurchaseHeaderTo."Currency Code");

        OnAfterCheckFromPurchaseCrMemoHeader(PurchCrMemoHdrFrom, PurchaseHeaderTo);
    end;

    local procedure CopyDeferrals(DeferralDocType: Integer; FromDocType: Integer; FromDocNo: Code[20]; FromLineNo: Integer; ToDocType: Integer; ToDocNo: Code[20]; ToLineNo: Integer) StartDate: Date
    var
        FromDeferralHeader: Record "Deferral Header";
        FromDeferralLine: Record "Deferral Line";
        ToDeferralHeader: Record "Deferral Header";
        ToDeferralLine: Record "Deferral Line";
        SalesCommentLine: Record "Sales Comment Line";
    begin
        StartDate := 0D;
        if FromDeferralHeader.GET(
             DeferralDocType, '', '',
             FromDocType, FromDocNo, FromLineNo)
        then begin
            RemoveDefaultDeferralCode(DeferralDocType, ToDocType, ToDocNo, ToLineNo);
            ToDeferralHeader.INIT();
            ToDeferralHeader.TRANSFERFIELDS(FromDeferralHeader);
            ToDeferralHeader."Document Type" := ToDocType;
            ToDeferralHeader."Document No." := ToDocNo;
            ToDeferralHeader."Line No." := ToLineNo;
            ToDeferralHeader.INSERT();
            FromDeferralLine.SETRANGE("Deferral Doc. Type", DeferralDocType);
            FromDeferralLine.SETRANGE("Gen. Jnl. Template Name", '');
            FromDeferralLine.SETRANGE("Gen. Jnl. Batch Name", '');
            FromDeferralLine.SETRANGE("Document Type", FromDocType);
            FromDeferralLine.SETRANGE("Document No.", FromDocNo);
            FromDeferralLine.SETRANGE("Line No.", FromLineNo);
            if FromDeferralLine.FINDSET() then
                repeat
                    ToDeferralLine.INIT();
                    ToDeferralLine.TRANSFERFIELDS(FromDeferralLine);
                    ToDeferralLine."Document Type" := ToDocType;
                    ToDeferralLine."Document No." := ToDocNo;
                    ToDeferralLine."Line No." := ToLineNo;
                    ToDeferralLine.INSERT();
                until FromDeferralLine.NEXT() = 0;
            if ToDocType = SalesCommentLine."Document Type"::"Return Order".AsInteger() then
                StartDate := FromDeferralHeader."Start Date"
        end;
    end;

    local procedure CopyPostedDeferrals(DeferralDocType: Integer; FromDocType: Integer; FromDocNo: Code[20]; FromLineNo: Integer; ToDocType: Integer; ToDocNo: Code[20]; ToLineNo: Integer) StartDate: Date
    var
        PostedDeferralHeader: Record "Posted Deferral Header";
        PostedDeferralLine: Record "Posted Deferral Line";
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
        SalesCommentLine: Record "Sales Comment Line";
        InitialAmountToDefer: Decimal;
    begin
        StartDate := 0D;
        if PostedDeferralHeader.GET(DeferralDocType, '', '',
             FromDocType, FromDocNo, FromLineNo)
        then begin
            RemoveDefaultDeferralCode(DeferralDocType, ToDocType, ToDocNo, ToLineNo);
            InitialAmountToDefer := 0;
            DeferralHeader.INIT();
            DeferralHeader.TRANSFERFIELDS(PostedDeferralHeader);
            DeferralHeader."Document Type" := ToDocType;
            DeferralHeader."Document No." := ToDocNo;
            DeferralHeader."Line No." := ToLineNo;
            DeferralHeader.INSERT();
            PostedDeferralLine.SETRANGE("Deferral Doc. Type", DeferralDocType);
            PostedDeferralLine.SETRANGE("Gen. Jnl. Document No.", '');
            PostedDeferralLine.SETRANGE("Account No.", '');
            PostedDeferralLine.SETRANGE("Document Type", FromDocType);
            PostedDeferralLine.SETRANGE("Document No.", FromDocNo);
            PostedDeferralLine.SETRANGE("Line No.", FromLineNo);
            if PostedDeferralLine.FINDSET() then
                repeat
                    DeferralLine.INIT();
                    DeferralLine.TRANSFERFIELDS(PostedDeferralLine);
                    DeferralLine."Document Type" := ToDocType;
                    DeferralLine."Document No." := ToDocNo;
                    DeferralLine."Line No." := ToLineNo;
                    if PostedDeferralLine."Amount (LCY)" <> 0.0 then
                        InitialAmountToDefer := InitialAmountToDefer + PostedDeferralLine."Amount (LCY)"
                    else
                        InitialAmountToDefer := InitialAmountToDefer + PostedDeferralLine.Amount;
                    DeferralLine.INSERT();
                until PostedDeferralLine.NEXT() = 0;
            if ToDocType = SalesCommentLine."Document Type"::"Return Order".AsInteger() then
                StartDate := PostedDeferralHeader."Start Date";
            if DeferralHeader.GET(DeferralDocType, '', '', ToDocType, ToDocNo, ToLineNo) then begin
                DeferralHeader."Initial Amount to Defer" := InitialAmountToDefer;
                DeferralHeader.MODIFY();
            end;
        end;
    end;

    local procedure IsDeferralToBeCopied(DeferralDocType: Integer; ToDocType: Option; FromDocType: Option): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesCommentLine: Record "Sales Comment Line";
        PurchLine: Record "Purchase Line";
        PurchCommentLine: Record "Purch. Comment Line";
        DeferralHeader: Record "Deferral Header";
    begin
        if DeferralDocType = DeferralHeader."Deferral Doc. Type"::Sales.AsInteger() then
            case ToDocType of
                SalesLine."Document Type"::Order.AsInteger(),
              SalesLine."Document Type"::Invoice.AsInteger(),
              SalesLine."Document Type"::"Credit Memo".AsInteger(),
              SalesLine."Document Type"::"Return Order".AsInteger():
                    case FromDocType of
                        SalesCommentLine."Document Type"::Order.AsInteger(),
                      SalesCommentLine."Document Type"::Invoice.AsInteger(),
                      SalesCommentLine."Document Type"::"Credit Memo".AsInteger(),
                      SalesCommentLine."Document Type"::"Return Order".AsInteger(),
                      SalesCommentLine."Document Type"::"Posted Invoice".AsInteger(),
                      SalesCommentLine."Document Type"::"Posted Credit Memo".AsInteger():
                            exit(true)
                    end;
            end
        else
            if DeferralDocType = DeferralHeader."Deferral Doc. Type"::Purchase.AsInteger() then
                case ToDocType of
                    PurchLine."Document Type"::Order.AsInteger(),
                  PurchLine."Document Type"::Invoice.AsInteger(),
                  PurchLine."Document Type"::"Credit Memo".AsInteger(),
                  PurchLine."Document Type"::"Return Order".AsInteger():
                        case FromDocType of
                            PurchCommentLine."Document Type"::Order.AsInteger(),
                          PurchCommentLine."Document Type"::Invoice.AsInteger(),
                          PurchCommentLine."Document Type"::"Credit Memo".AsInteger(),
                          PurchCommentLine."Document Type"::"Return Order".AsInteger(),
                          PurchCommentLine."Document Type"::"Posted Invoice".AsInteger(),
                          PurchCommentLine."Document Type"::"Posted Credit Memo".AsInteger():
                                exit(true)
                        end;
                end;

        exit(false);
    end;

    local procedure IsDeferralToBeDefaulted(DeferralDocType: Integer; ToDocType: Option; FromDocType: Option): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesCommentLine: Record "Sales Comment Line";
        PurchLine: Record "Purchase Line";
        PurchCommentLine: Record "Purch. Comment Line";
        DeferralHeader: Record "Deferral Header";
    begin
        if DeferralDocType = DeferralHeader."Deferral Doc. Type"::Sales.AsInteger() then
            case ToDocType of
                SalesLine."Document Type"::Order.AsInteger(),
              SalesLine."Document Type"::Invoice.AsInteger(),
              SalesLine."Document Type"::"Credit Memo".AsInteger(),
              SalesLine."Document Type"::"Return Order".AsInteger():
                    case FromDocType of
                        SalesCommentLine."Document Type"::Quote.AsInteger(),
                      SalesCommentLine."Document Type"::"Blanket Order".AsInteger(),
                      SalesCommentLine."Document Type"::Shipment.AsInteger(),
                      SalesCommentLine."Document Type"::"Posted Return Receipt".AsInteger():
                            exit(true)
                    end;
            end
        else
            if DeferralDocType = DeferralHeader."Deferral Doc. Type"::Purchase.AsInteger() then
                case ToDocType of
                    PurchLine."Document Type"::Order.AsInteger(),
                  PurchLine."Document Type"::Invoice.AsInteger(),
                  PurchLine."Document Type"::"Credit Memo".AsInteger(),
                  PurchLine."Document Type"::"Return Order".AsInteger():
                        case FromDocType of
                            PurchCommentLine."Document Type"::Quote.AsInteger(),
                          PurchCommentLine."Document Type"::"Blanket Order".AsInteger(),
                          PurchCommentLine."Document Type"::Receipt.AsInteger(),
                          PurchCommentLine."Document Type"::"Posted Return Shipment".AsInteger():
                                exit(true)
                        end;
                end;

        exit(false);
    end;

    local procedure IsDeferralPosted(DeferralDocType: Integer; FromDocType: Option): Boolean
    var
        SalesCommentLine: Record "Sales Comment Line";
        PurchCommentLine: Record "Purch. Comment Line";
        DeferralHeader: Record "Deferral Header";
    begin
        if DeferralDocType = DeferralHeader."Deferral Doc. Type"::Sales.AsInteger() then
            case FromDocType of
                SalesCommentLine."Document Type"::Shipment.AsInteger(),
              SalesCommentLine."Document Type"::"Posted Invoice".AsInteger(),
              SalesCommentLine."Document Type"::"Posted Credit Memo".AsInteger(),
              SalesCommentLine."Document Type"::"Posted Return Receipt".AsInteger():
                    exit(true);
            end
        else
            if DeferralDocType = DeferralHeader."Deferral Doc. Type"::Purchase.AsInteger() then
                case FromDocType of
                    PurchCommentLine."Document Type"::Receipt.AsInteger(),
                  PurchCommentLine."Document Type"::"Posted Invoice".AsInteger(),
                  PurchCommentLine."Document Type"::"Posted Credit Memo".AsInteger(),
                  PurchCommentLine."Document Type"::"Posted Return Shipment".AsInteger():
                        exit(true);
                end;

        exit(false);
    end;

    local procedure InitSalesDeferralCode(var ToSalesLine: Record "Sales Line")
    var
        GLAccount: Record "G/L Account";
        ItemL: Record Item;
        ResourceL: Record Resource;
    begin
        if ToSalesLine."No." = '' then
            exit;

        case ToSalesLine."Document Type" of
            ToSalesLine."Document Type"::Order,
          ToSalesLine."Document Type"::Invoice,
          ToSalesLine."Document Type"::"Credit Memo",
          ToSalesLine."Document Type"::"Return Order":
                case ToSalesLine.Type of
                    ToSalesLine.Type::"G/L Account":
                        begin
                            GLAccount.GET(ToSalesLine."No.");
                            ToSalesLine.VALIDATE("Deferral Code", GLAccount."Default Deferral Template Code");
                        end;
                    ToSalesLine.Type::Item:
                        begin
                            ItemL.GET(ToSalesLine."No.");
                            ToSalesLine.VALIDATE("Deferral Code", ItemL."Default Deferral Template Code");
                        end;
                    ToSalesLine.Type::Resource:
                        begin
                            ResourceL.GET(ToSalesLine."No.");
                            ToSalesLine.VALIDATE("Deferral Code", ResourceL."Default Deferral Template Code");
                        end;
                end;
        end;
    end;

    local procedure InitFromSalesLine2(var FromSalesLine2: Record "Sales Line"; var FromSalesLineBuf: Record "Sales Line")
    begin
        // Empty buffer fields
        FromSalesLine2 := FromSalesLineBuf;
        FromSalesLine2."Shipment No." := '';
        FromSalesLine2."Shipment Line No." := 0;
        FromSalesLine2."Return Receipt No." := '';
        FromSalesLine2."Return Receipt Line No." := 0;
    end;

    local procedure CleanSpecialOrderDropShipmentInSalesLine(var SalesLine: Record "Sales Line")
    begin
        SalesLine."Purchase Order No." := '';
        SalesLine."Purch. Order Line No." := 0;
        SalesLine."Special Order Purchase No." := '';
        SalesLine."Special Order Purch. Line No." := 0;
    end;

    local procedure CleanSpecialOrderDropShipmentInPurchLine(var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine."Sales Order No." := '';
        PurchaseLine."Sales Order Line No." := 0;
        PurchaseLine."Special Order Sales No." := '';
        PurchaseLine."Special Order Sales Line No." := 0;
        PurchaseLine."Drop Shipment" := false;
        PurchaseLine."Special Order" := false;
    end;

    local procedure RemoveDefaultDeferralCode(DeferralDocType: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer)
    var
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
    begin
        if DeferralHeader.GET(DeferralDocType, '', '', DocType, DocNo, LineNo) then
            DeferralHeader.DELETE();

        DeferralLine.SETRANGE("Deferral Doc. Type", DeferralDocType);
        DeferralLine.SETRANGE("Gen. Jnl. Template Name", '');
        DeferralLine.SETRANGE("Gen. Jnl. Batch Name", '');
        DeferralLine.SETRANGE("Document Type", DocType);
        DeferralLine.SETRANGE("Document No.", DocNo);
        DeferralLine.SETRANGE("Line No.", LineNo);
        DeferralLine.DELETEALL();
    end;

    procedure DeferralTypeForSalesDoc(DocType: Option): Integer
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        case DocType of
            SalesDocType::Quote.AsInteger():
                exit(SalesCommentLine."Document Type"::Quote.AsInteger());
            SalesDocType::"Blanket Order".AsInteger():
                exit(SalesCommentLine."Document Type"::"Blanket Order".AsInteger());
            SalesDocType::Order.AsInteger():
                exit(SalesCommentLine."Document Type"::Order.AsInteger());
            SalesDocType::Invoice.AsInteger():
                exit(SalesCommentLine."Document Type"::Invoice.AsInteger());
            SalesDocType::"Return Order".AsInteger():
                exit(SalesCommentLine."Document Type"::"Return Order".AsInteger());
            SalesDocType::"Credit Memo".AsInteger():
                exit(SalesCommentLine."Document Type"::"Credit Memo".AsInteger());
            SalesDocType::"Posted Shipment".AsInteger():
                exit(SalesCommentLine."Document Type"::Shipment.AsInteger());
            SalesDocType::"Posted Invoice".AsInteger():
                exit(SalesCommentLine."Document Type"::"Posted Invoice".AsInteger());
            SalesDocType::"Posted Return Receipt".AsInteger():
                exit(SalesCommentLine."Document Type"::"Posted Return Receipt".AsInteger());
            SalesDocType::"Posted Credit Memo".AsInteger():
                exit(SalesCommentLine."Document Type"::"Posted Credit Memo".AsInteger());
        end;
    end;

    procedure DeferralTypeForPurchDoc(DocType: Option): Integer
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        case DocType of
            PurchDocType::Quote.AsInteger():
                exit(PurchCommentLine."Document Type"::Quote.AsInteger());
            PurchDocType::"Blanket Order".AsInteger():
                exit(PurchCommentLine."Document Type"::"Blanket Order".AsInteger());
            PurchDocType::Order.AsInteger():
                exit(PurchCommentLine."Document Type"::Order.AsInteger());
            PurchDocType::Invoice.AsInteger():
                exit(PurchCommentLine."Document Type"::Invoice.AsInteger());
            PurchDocType::"Return Order".AsInteger():
                exit(PurchCommentLine."Document Type"::"Return Order".AsInteger());
            PurchDocType::"Credit Memo".AsInteger():
                exit(PurchCommentLine."Document Type"::"Credit Memo".AsInteger());
            PurchDocType::"Posted Receipt".AsInteger():
                exit(PurchCommentLine."Document Type"::Receipt.AsInteger());
            PurchDocType::"Posted Invoice".AsInteger():
                exit(PurchCommentLine."Document Type"::"Posted Invoice".AsInteger());
            PurchDocType::"Posted Return Shipment".AsInteger():
                exit(PurchCommentLine."Document Type"::"Posted Return Shipment".AsInteger());
            PurchDocType::"Posted Credit Memo".AsInteger():
                exit(PurchCommentLine."Document Type"::"Posted Credit Memo".AsInteger());
        end;
    end;

    local procedure InitPurchDeferralCode(var ToPurchLine: Record "Purchase Line")
    var
        GLAccount: Record "G/L Account";
        ItemL: Record Item;
    begin
        if ToPurchLine."No." = '' then
            exit;

        case ToPurchLine."Document Type" of
            ToPurchLine."Document Type"::Order,
          ToPurchLine."Document Type"::Invoice,
          ToPurchLine."Document Type"::"Credit Memo",
          ToPurchLine."Document Type"::"Return Order":
                case ToPurchLine.Type of
                    ToPurchLine.Type::"G/L Account":
                        begin
                            GLAccount.GET(ToPurchLine."No.");
                            ToPurchLine.VALIDATE("Deferral Code", GLAccount."Default Deferral Template Code");
                        end;
                    ToPurchLine.Type::Item:
                        begin
                            ItemL.GET(ToPurchLine."No.");
                            ToPurchLine.VALIDATE("Deferral Code", ItemL."Default Deferral Template Code");
                        end;
                end;
        end;
    end;

    local procedure CopySalesPostedDeferrals(ToSalesLine: Record "Sales Line"; DeferralDocType: Integer; FromDocType: Integer; FromDocNo: Code[20]; FromLineNo: Integer; ToDocType: Integer; ToDocNo: Code[20]; ToLineNo: Integer)
    begin
        ToSalesLine."Returns Deferral Start Date" :=
          CopyPostedDeferrals(DeferralDocType,
            FromDocType, FromDocNo, FromLineNo,
            ToDocType, ToDocNo, ToLineNo);
        ToSalesLine.MODIFY();
    end;

    local procedure CopyPurchPostedDeferrals(ToPurchaseLine: Record "Purchase Line"; DeferralDocType: Integer; FromDocType: Integer; FromDocNo: Code[20]; FromLineNo: Integer; ToDocType: Integer; ToDocNo: Code[20]; ToLineNo: Integer)
    begin
        ToPurchaseLine."Returns Deferral Start Date" :=
          CopyPostedDeferrals(DeferralDocType,
            FromDocType, FromDocNo, FromLineNo,
            ToDocType, ToDocNo, ToLineNo);
        ToPurchaseLine.MODIFY();
    end;

    local procedure CheckDateOrder(PostingNo: Code[20]; PostingNoSeries: Code[20]; OldPostingDate: Date; NewPostingDate: Date): Boolean
    var
        NoSeries: Record "No. Series";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if IncludeHeader then
            if (PostingNo <> '') and (OldPostingDate <> NewPostingDate) then
                if NoSeries.GET(PostingNoSeries) then
                    if NoSeries."Date Order" then
                        exit(ConfirmManagement.GetResponseOrDefault(DiffPostDateOrderQst, true));
        exit(true)
    end;

    local procedure CheckSalesDocItselfCopy(FromSalesHeader: Record "Sales Header"; ToSalesHeader: Record "Sales Header")
    begin
        if (FromSalesHeader."Document Type" = ToSalesHeader."Document Type") and
           (FromSalesHeader."No." = ToSalesHeader."No.")
        then
            ERROR(Text001, ToSalesHeader."Document Type", ToSalesHeader."No.");
    end;

    local procedure CheckPurchDocItselfCopy(FromPurchHeader: Record "Purchase Header"; ToPurchHeader: Record "Purchase Header")
    begin
        if (FromPurchHeader."Document Type" = ToPurchHeader."Document Type") and
           (FromPurchHeader."No." = ToPurchHeader."No.")
        then
            ERROR(Text001, ToPurchHeader."Document Type", ToPurchHeader."No.");
    end;

    local procedure UpdateCustLedgEntry(var ToSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20])
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        OnBeforeUpdateCustLedgEntry(ToSalesHeader, CustLedgEntry);

        CustLedgEntry.SETCURRENTKEY("Document No.");
        if FromDocType = SalesDocType::"Posted Invoice".AsInteger() then
            CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Invoice)
        else
            CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::"Credit Memo");
        CustLedgEntry.SETRANGE("Document No.", FromDocNo);
        CustLedgEntry.SETRANGE("Customer No.", ToSalesHeader."Bill-to Customer No.");
        CustLedgEntry.SETRANGE(Open, true);
        if CustLedgEntry.FINDFIRST() then begin
            ToSalesHeader."Bal. Account No." := '';
            if FromDocType = SalesDocType::"Posted Invoice".AsInteger() then begin
                ToSalesHeader."Applies-to Doc. Type" := ToSalesHeader."Applies-to Doc. Type"::Invoice;
                ToSalesHeader."Applies-to Doc. No." := FromDocNo;
            end else begin
                ToSalesHeader."Applies-to Doc. Type" := ToSalesHeader."Applies-to Doc. Type"::"Credit Memo";
                ToSalesHeader."Applies-to Doc. No." := FromDocNo;
            end;
            CustLedgEntry.CALCFIELDS("Remaining Amount");
            CustLedgEntry."Amount to Apply" := CustLedgEntry."Remaining Amount";
            CustLedgEntry."Accepted Payment Tolerance" := 0;
            CustLedgEntry."Accepted Pmt. Disc. Tolerance" := false;
            CODEUNIT.RUN(CODEUNIT::"Cust. Entry-Edit", CustLedgEntry);
        end;
    end;

    procedure UpdateVendLedgEntry(var ToPurchHeader: Record "Purchase Header"; FromDocType: Option; FromDocNo: Code[20])
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        OnBeforeUpdateVendLedgEntry(ToPurchHeader, VendLedgEntry);

        VendLedgEntry.SETCURRENTKEY("Document No.");
        if FromDocType = PurchDocType::"Posted Invoice".AsInteger() then
            VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Invoice)
        else
            VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
        VendLedgEntry.SETRANGE("Document No.", FromDocNo);
        VendLedgEntry.SETRANGE("Vendor No.", ToPurchHeader."Pay-to Vendor No.");
        VendLedgEntry.SETRANGE(Open, true);
        if VendLedgEntry.FINDFIRST() then begin
            if FromDocType = PurchDocType::"Posted Invoice".AsInteger() then begin
                ToPurchHeader."Applies-to Doc. Type" := ToPurchHeader."Applies-to Doc. Type"::Invoice;
                ToPurchHeader."Applies-to Doc. No." := FromDocNo;
            end else begin
                ToPurchHeader."Applies-to Doc. Type" := ToPurchHeader."Applies-to Doc. Type"::"Credit Memo";
                ToPurchHeader."Applies-to Doc. No." := FromDocNo;
            end;
            VendLedgEntry.CALCFIELDS("Remaining Amount");
            VendLedgEntry."Amount to Apply" := VendLedgEntry."Remaining Amount";
            VendLedgEntry."Accepted Payment Tolerance" := 0;
            VendLedgEntry."Accepted Pmt. Disc. Tolerance" := false;
            CODEUNIT.RUN(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);
        end;
    end;

    local procedure UpdatePurchCreditMemoHeader(var PurchaseHeader: Record "Purchase Header")
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PurchaseHeader."Expected Receipt Date" := 0D;
        GLSetup.GET();
        PurchaseHeader.Correction := GLSetup."Mark Cr. Memos as Corrections";
        if (PurchaseHeader."Payment Terms Code" <> '') and (PurchaseHeader."Document Date" <> 0D) then
            PaymentTerms.GET(PurchaseHeader."Payment Terms Code")
        else
            CLEAR(PaymentTerms);
        if not PaymentTerms."Calc. Pmt. Disc. on Cr. Memos" then begin
            PurchaseHeader."Payment Terms Code" := '';
            PurchaseHeader."Payment Discount %" := 0;
            PurchaseHeader."Pmt. Discount Date" := 0D;
        end;
    end;

    local procedure UpdateSalesCreditMemoHeader(var SalesHeader: Record "Sales Header")
    var
        PaymentTerms: Record "Payment Terms";
    begin
        SalesHeader."Shipment Date" := 0D;
        GLSetup.GET();
        SalesHeader.Correction := GLSetup."Mark Cr. Memos as Corrections";
        if (SalesHeader."Payment Terms Code" <> '') and (SalesHeader."Document Date" <> 0D) then
            PaymentTerms.GET(SalesHeader."Payment Terms Code")
        else
            CLEAR(PaymentTerms);
        if not PaymentTerms."Calc. Pmt. Disc. on Cr. Memos" then begin
            SalesHeader."Payment Terms Code" := '';
            SalesHeader."Payment Discount %" := 0;
            SalesHeader."Pmt. Discount Date" := 0D;
        end;
    end;

    local procedure UpdateSalesInvoiceDiscountValue(var SalesHeader: Record "Sales Header")
    begin
        if IncludeHeader and RecalculateLines then begin
            SalesHeader.CALCFIELDS(Amount);
            if SalesHeader."Invoice Discount Value" > SalesHeader.Amount then begin
                SalesHeader."Invoice Discount Value" := SalesHeader.Amount;
                SalesHeader.MODIFY();
            end;
        end;
    end;

    local procedure UpdatePurchaseInvoiceDiscountValue(var PurchaseHeader: Record "Purchase Header")
    begin
        if IncludeHeader and RecalculateLines then begin
            PurchaseHeader.CALCFIELDS(Amount);
            if PurchaseHeader."Invoice Discount Value" > PurchaseHeader.Amount then begin
                PurchaseHeader."Invoice Discount Value" := PurchaseHeader.Amount;
                PurchaseHeader.MODIFY();
            end;
        end;
    end;

    local procedure ExtTxtAttachedToPosSalesLine(SalesHeader: Record "Sales Header"; MoveNegLinesP: Boolean; AttachedToLineNo: Integer): Boolean
    var
        AttachedToSalesLine: Record "Sales Line";
    begin
        if MoveNegLinesP then
            if AttachedToLineNo <> 0 then
                if AttachedToSalesLine.GET(SalesHeader."Document Type", SalesHeader."No.", AttachedToLineNo) then
                    if AttachedToSalesLine.Quantity >= 0 then
                        exit(true);

        exit(false);
    end;

    local procedure ExtTxtAttachedToPosPurchLine(PurchHeader: Record "Purchase Header"; MoveNegLinesP: Boolean; AttachedToLineNo: Integer): Boolean
    var
        AttachedToPurchLine: Record "Purchase Line";
    begin
        if MoveNegLinesP then
            if AttachedToLineNo <> 0 then
                if AttachedToPurchLine.GET(PurchHeader."Document Type", PurchHeader."No.", AttachedToLineNo) then
                    if AttachedToPurchLine.Quantity >= 0 then
                        exit(true);

        exit(false);
    end;

    local procedure SalesDocCanReceiveTracking(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(
          (SalesHeader."Document Type" <> SalesHeader."Document Type"::Quote) and
          (SalesHeader."Document Type" <> SalesHeader."Document Type"::"Blanket Order"));
    end;

    local procedure PurchaseDocCanReceiveTracking(PurchaseHeader: Record "Purchase Header"): Boolean
    begin
        exit(
          (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Quote) and
          (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::"Blanket Order"));
    end;

    local procedure CheckFirstLineShipped(DocNo: Code[20]; ShipmentLineNo: Integer; var SalesCombDocLineNo: Integer; var NextLineNo: Integer; var FirstLineShipped: Boolean)
    begin
        if (DocNo = '') and (ShipmentLineNo = 0) and FirstLineShipped then begin
            FirstLineShipped := false;
            SalesCombDocLineNo := NextLineNo;
            NextLineNo := NextLineNo + 10000;
        end;
    end;

    local procedure SetTempSalesInvLine(FromSalesInvLine: Record "Sales Invoice Line"; var TempSalesInvLine: Record "Sales Invoice Line" temporary; var SalesInvLineCount: Integer; var NextLineNo: Integer; var FirstLineText: Boolean)
    begin
        if FromSalesInvLine.Type = FromSalesInvLine.Type::Item then begin
            SalesInvLineCount += 1;
            TempSalesInvLine := FromSalesInvLine;
            TempSalesInvLine.INSERT();
            if FirstLineText then begin
                NextLineNo := NextLineNo + 10000;
                FirstLineText := false;
            end;
        end else
            if FromSalesInvLine.Type = FromSalesInvLine.Type::" " then
                FirstLineText := true;
    end;

    local procedure InitAndCheckSalesDocuments(FromDocType: Option; FromDocNo: Code[20]; var FromSalesHeader: Record "Sales Header"; var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesShipmentHeader: Record "Sales Shipment Header"; var FromSalesInvoiceHeader: Record "Sales Invoice Header"; var FromReturnReceiptHeader: Record "Return Receipt Header"; var FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; var FromSalesHeaderArchive: Record "Sales Header Archive"): Boolean
    var
        FromSalesLineArchive: Record "Sales Line Archive";
    begin
        case FromDocType of
            SalesDocType::Quote.AsInteger(),
            SalesDocType::"Blanket Order".AsInteger(),
            SalesDocType::Order.AsInteger(),
            SalesDocType::Invoice.AsInteger(),
            SalesDocType::"Return Order".AsInteger(),
            SalesDocType::"Credit Memo".AsInteger():
                begin
                    FromSalesHeader.GET(SalesHeaderDocType(FromDocType), FromDocNo);
                    //BCSYS 21112023
                    ToSalesHeader."BC6 PreEDI" := false;
                    ToSalesHeader."JWC Last Date Modified" := 0D;
                    ToSalesHeader.VALIDATE("Requested Delivery Date", 0D);
                    ToSalesHeader."Completely Shipped" := false;

                    if ToSalesHeader."Document Type" = ToSalesHeader."Document Type"::Order then begin
                        ToSalesHeader.VALIDATE("Posting Date", TODAY);
                        ToSalesHeader.VALIDATE("Shipment Date", TODAY);
                        ToSalesHeader.VALIDATE("Order Date", TODAY);
                    end;
                    //FIN BCSYS
                    if not CheckDateOrder(
                         ToSalesHeader."Posting No.", ToSalesHeader."Posting No. Series",
                         ToSalesHeader."Posting Date", FromSalesHeader."Posting Date")
                    then
                        exit(false);
                    if MoveNegLines then
                        DeleteSalesLinesWithNegQty(FromSalesHeader, true);
                    CheckSalesDocItselfCopy(ToSalesHeader, FromSalesHeader);

                    if ToSalesHeader."Document Type".AsInteger() <= ToSalesHeader."Document Type"::Invoice.AsInteger() then begin
                        FromSalesHeader.CALCFIELDS("Amount Including VAT");
                        ToSalesHeader."Amount Including VAT" := FromSalesHeader."Amount Including VAT";
                        //>>BC6 SBE 27/01/2022
                        //CheckCreditLimit(FromSalesHeader,ToSalesHeader);
                        //<<BC6 SBE 27/01/2022
                    end;
                    CheckCopyFromSalesHeaderAvail(FromSalesHeader, ToSalesHeader);

                    if not IncludeHeader and not RecalculateLines then
                        CheckFromSalesHeader(FromSalesHeader, ToSalesHeader);
                end;
            SalesDocType::"Posted Shipment".AsInteger():
                begin
                    FromSalesShipmentHeader.GET(FromDocNo);
                    if not CheckDateOrder(
                         ToSalesHeader."Posting No.", ToSalesHeader."Posting No. Series",
                         ToSalesHeader."Posting Date", FromSalesShipmentHeader."Posting Date")
                    then
                        exit(false);
                    CheckCopyFromSalesShptAvail(FromSalesShipmentHeader, ToSalesHeader);

                    if not IncludeHeader and not RecalculateLines then
                        CheckFromSalesShptHeader(FromSalesShipmentHeader, ToSalesHeader);
                end;
            SalesDocType::"Posted Invoice".AsInteger():
                begin
                    FromSalesInvoiceHeader.GET(FromDocNo);
                    FromSalesInvoiceHeader.TESTFIELD("Prepayment Invoice", false);
                    WarnSalesInvoicePmtDisc(ToSalesHeader, FromSalesHeader, FromDocType, FromDocNo);
                    if not CheckDateOrder(
                         ToSalesHeader."Posting No.", ToSalesHeader."Posting No. Series",
                         ToSalesHeader."Posting Date", FromSalesInvoiceHeader."Posting Date")
                    then
                        exit(false);
                    if ToSalesHeader."Document Type".AsInteger() <= ToSalesHeader."Document Type"::Invoice.AsInteger() then begin
                        FromSalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
                        ToSalesHeader."Amount Including VAT" := FromSalesInvoiceHeader."Amount Including VAT";
                        if IncludeHeader then
                            FromSalesHeader.TRANSFERFIELDS(FromSalesInvoiceHeader);
                        CheckCreditLimit(FromSalesHeader, ToSalesHeader);
                    end;
                    CheckCopyFromSalesInvoiceAvail(FromSalesInvoiceHeader, ToSalesHeader);

                    if not IncludeHeader and not RecalculateLines then
                        CheckFromSalesInvHeader(FromSalesInvoiceHeader, ToSalesHeader);
                end;
            SalesDocType::"Posted Return Receipt".AsInteger():
                begin
                    FromReturnReceiptHeader.GET(FromDocNo);
                    if not CheckDateOrder(
                         ToSalesHeader."Posting No.", ToSalesHeader."Posting No. Series",
                         ToSalesHeader."Posting Date", FromReturnReceiptHeader."Posting Date")
                    then
                        exit(false);
                    CheckCopyFromSalesRetRcptAvail(FromReturnReceiptHeader, ToSalesHeader);

                    if not IncludeHeader and not RecalculateLines then
                        CheckFromSalesReturnRcptHeader(FromReturnReceiptHeader, ToSalesHeader);
                end;
            SalesDocType::"Posted Credit Memo".AsInteger():
                begin
                    FromSalesCrMemoHeader.GET(FromDocNo);
                    FromSalesCrMemoHeader.TESTFIELD("Prepayment Credit Memo", false);
                    WarnSalesInvoicePmtDisc(ToSalesHeader, FromSalesHeader, FromDocType, FromDocNo);
                    if not CheckDateOrder(
                         ToSalesHeader."Posting No.", ToSalesHeader."Posting No. Series",
                         ToSalesHeader."Posting Date", FromSalesCrMemoHeader."Posting Date")
                    then
                        exit(false);
                    if ToSalesHeader."Document Type".AsInteger() <= ToSalesHeader."Document Type"::Invoice.AsInteger() then begin
                        FromSalesCrMemoHeader.CALCFIELDS("Amount Including VAT");
                        ToSalesHeader."Amount Including VAT" := FromSalesCrMemoHeader."Amount Including VAT";
                        if IncludeHeader then
                            FromSalesHeader.TRANSFERFIELDS(FromSalesCrMemoHeader);
                        CheckCreditLimit(FromSalesHeader, ToSalesHeader);
                    end;
                    CheckCopyFromSalesCrMemoAvail(FromSalesCrMemoHeader, ToSalesHeader);

                    if not IncludeHeader and not RecalculateLines then
                        CheckFromSalesCrMemoHeader(FromSalesCrMemoHeader, ToSalesHeader);
                end;
            SalesDocType::"Arch. Quote".AsInteger(),
            SalesDocType::"Arch. Order".AsInteger(),
            SalesDocType::"Arch. Blanket Order".AsInteger(),
            SalesDocType::"Arch. Return Order".AsInteger():
                begin
                    FromSalesHeaderArchive.GET(ArchSalesHeaderDocType(FromDocType), FromDocNo, FromDocOccurrenceNo, FromDocVersionNo);
                    if SalesDocType.AsInteger() <= SalesDocType::Invoice.AsInteger() then begin
                        FromSalesHeaderArchive.CALCFIELDS("Amount Including VAT");
                        ToSalesHeader."Amount Including VAT" := FromSalesHeaderArchive."Amount Including VAT";
                        CustCheckCreditLimit.SalesHeaderCheck(ToSalesHeader);
                    end;
                    if SalesDocType in [SalesDocType::Order, SalesDocType::Invoice] then begin
                        FromSalesLineArchive.SETRANGE("Document Type", FromSalesHeaderArchive."Document Type");
                        FromSalesLineArchive.SETRANGE("Document No.", FromSalesHeaderArchive."No.");
                        FromSalesLineArchive.SETRANGE("Doc. No. Occurrence", FromSalesHeaderArchive."Doc. No. Occurrence");
                        FromSalesLineArchive.SETRANGE("Version No.", FromSalesHeaderArchive."Version No.");
                        FromSalesLineArchive.SETRANGE(Type, FromSalesLineArchive.Type::Item);
                        FromSalesLineArchive.SETFILTER("No.", '<>%1', '');
                        if FromSalesLineArchive.FINDSET() then
                            repeat
                                if FromSalesLineArchive.Quantity > 0 then begin
                                    ToSalesLine."No." := FromSalesLineArchive."No.";
                                    ToSalesLine."Variant Code" := FromSalesLineArchive."Variant Code";
                                    ToSalesLine."Location Code" := FromSalesLineArchive."Location Code";
                                    ToSalesLine."Bin Code" := FromSalesLineArchive."Bin Code";
                                    ToSalesLine."Unit of Measure Code" := FromSalesLineArchive."Unit of Measure Code";
                                    ToSalesLine."Qty. per Unit of Measure" := FromSalesLineArchive."Qty. per Unit of Measure";
                                    ToSalesLine."Outstanding Quantity" := FromSalesLineArchive.Quantity;
                                    CheckItemAvailability(ToSalesHeader, ToSalesLine);
                                end;
                            until FromSalesLineArchive.NEXT() = 0;
                    end;
                    if not IncludeHeader and not RecalculateLines then begin
                        FromSalesHeaderArchive.TESTFIELD("Sell-to Customer No.", ToSalesHeader."Sell-to Customer No.");
                        FromSalesHeaderArchive.TESTFIELD("Bill-to Customer No.", ToSalesHeader."Bill-to Customer No.");
                        FromSalesHeaderArchive.TESTFIELD("Customer Posting Group", ToSalesHeader."Customer Posting Group");
                        FromSalesHeaderArchive.TESTFIELD("Gen. Bus. Posting Group", ToSalesHeader."Gen. Bus. Posting Group");
                        FromSalesHeaderArchive.TESTFIELD("Currency Code", ToSalesHeader."Currency Code");
                        FromSalesHeaderArchive.TESTFIELD("Prices Including VAT", ToSalesHeader."Prices Including VAT");
                    end;
                end;
        end;

        OnAfterInitAndCheckSalesDocuments(
          FromDocType, FromDocNo, FromDocOccurrenceNo, FromDocVersionNo,
          FromSalesHeader, ToSalesHeader, ToSalesLine,
          FromSalesShipmentHeader, FromSalesInvoiceHeader, FromReturnReceiptHeader, FromSalesCrMemoHeader, FromSalesHeaderArchive,
          IncludeHeader, RecalculateLines);

        exit(true);
    end;

    local procedure InitAndCheckPurchaseDocuments(FromDocType: Option; FromDocNo: Code[20]; var FromPurchaseHeader: Record "Purchase Header"; var ToPurchaseHeader: Record "Purchase Header"; var FromPurchRcptHeader: Record "Purch. Rcpt. Header"; var FromPurchInvHeader: Record "Purch. Inv. Header"; var FromReturnShipmentHeader: Record "Return Shipment Header"; var FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var FromPurchaseHeaderArchive: Record "Purchase Header Archive"): Boolean
    begin
        case FromDocType of
            PurchDocType::Quote.AsInteger(),
            PurchDocType::"Blanket Order".AsInteger(),
            PurchDocType::Order.AsInteger(),
            PurchDocType::Invoice.AsInteger(),
            PurchDocType::"Return Order".AsInteger(),
            PurchDocType::"Credit Memo".AsInteger():
                begin
                    FromPurchaseHeader.GET(PurchHeaderDocType(FromDocType), FromDocNo);
                    if not CheckDateOrder(
                         ToPurchaseHeader."Posting No.", ToPurchaseHeader."Posting No. Series",
                         ToPurchaseHeader."Posting Date", FromPurchaseHeader."Posting Date")
                    then
                        exit(false);
                    if MoveNegLines then
                        DeletePurchLinesWithNegQty(FromPurchaseHeader, true);
                    CheckPurchDocItselfCopy(ToPurchaseHeader, FromPurchaseHeader);
                    if not IncludeHeader and not RecalculateLines then
                        CheckFromPurchaseHeader(FromPurchaseHeader, ToPurchaseHeader);
                end;
            PurchDocType::"Posted Receipt".AsInteger():
                begin
                    FromPurchRcptHeader.GET(FromDocNo);
                    if not CheckDateOrder(
                         ToPurchaseHeader."Posting No.", ToPurchaseHeader."Posting No. Series",
                         ToPurchaseHeader."Posting Date", FromPurchRcptHeader."Posting Date")
                    then
                        exit(false);
                    if not IncludeHeader and not RecalculateLines then
                        CheckFromPurchaseRcptHeader(FromPurchRcptHeader, ToPurchaseHeader);
                end;
            PurchDocType::"Posted Invoice".AsInteger():
                begin
                    FromPurchInvHeader.GET(FromDocNo);
                    if not CheckDateOrder(
                         ToPurchaseHeader."Posting No.", ToPurchaseHeader."Posting No. Series",
                         ToPurchaseHeader."Posting Date", FromPurchInvHeader."Posting Date")
                    then
                        exit(false);
                    FromPurchInvHeader.TESTFIELD("Prepayment Invoice", false);
                    WarnPurchInvoicePmtDisc(ToPurchaseHeader, FromPurchaseHeader, FromDocType, FromDocNo);
                    if not IncludeHeader and not RecalculateLines then
                        CheckFromPurchaseInvHeader(FromPurchInvHeader, ToPurchaseHeader);
                end;
            PurchDocType::"Posted Return Shipment".AsInteger():
                begin
                    FromReturnShipmentHeader.GET(FromDocNo);
                    if not CheckDateOrder(
                         ToPurchaseHeader."Posting No.", ToPurchaseHeader."Posting No. Series",
                         ToPurchaseHeader."Posting Date", FromReturnShipmentHeader."Posting Date")
                    then
                        exit(false);
                    if not IncludeHeader and not RecalculateLines then
                        CheckFromPurchaseReturnShptHeader(FromReturnShipmentHeader, ToPurchaseHeader);
                end;
            PurchDocType::"Posted Credit Memo".AsInteger():
                begin
                    FromPurchCrMemoHdr.GET(FromDocNo);
                    if not CheckDateOrder(
                         ToPurchaseHeader."Posting No.", ToPurchaseHeader."Posting No. Series",
                         ToPurchaseHeader."Posting Date", FromPurchCrMemoHdr."Posting Date")
                    then
                        exit(false);
                    FromPurchCrMemoHdr.TESTFIELD("Prepayment Credit Memo", false);
                    WarnPurchInvoicePmtDisc(ToPurchaseHeader, FromPurchaseHeader, FromDocType, FromDocNo);
                    if not IncludeHeader and not RecalculateLines then
                        CheckFromPurchaseCrMemoHeader(FromPurchCrMemoHdr, ToPurchaseHeader);
                end;
            PurchDocType::"Arch. Order".AsInteger(),
            PurchDocType::"Arch. Quote".AsInteger(),
            PurchDocType::"Arch. Blanket Order".AsInteger(),
            PurchDocType::"Arch. Return Order".AsInteger():
                begin
                    FromPurchaseHeaderArchive.GET(ArchPurchHeaderDocType(FromDocType), FromDocNo, FromDocOccurrenceNo, FromDocVersionNo);
                    if not IncludeHeader and not RecalculateLines then begin
                        FromPurchaseHeaderArchive.TESTFIELD("Buy-from Vendor No.", ToPurchaseHeader."Buy-from Vendor No.");
                        FromPurchaseHeaderArchive.TESTFIELD("Pay-to Vendor No.", ToPurchaseHeader."Pay-to Vendor No.");
                        FromPurchaseHeaderArchive.TESTFIELD("Vendor Posting Group", ToPurchaseHeader."Vendor Posting Group");
                        FromPurchaseHeaderArchive.TESTFIELD("Gen. Bus. Posting Group", ToPurchaseHeader."Gen. Bus. Posting Group");
                        FromPurchaseHeaderArchive.TESTFIELD("Currency Code", ToPurchaseHeader."Currency Code");
                    end;
                end;
        end;

        OnAfterInitAndCheckPurchaseDocuments(
          FromDocType, FromDocNo, FromDocOccurrenceNo, FromDocVersionNo,
          FromPurchaseHeader, ToPurchaseHeader,
          FromPurchRcptHeader, FromPurchInvHeader, FromReturnShipmentHeader, FromPurchCrMemoHdr, FromPurchaseHeaderArchive,
          IncludeHeader, RecalculateLines);

        exit(true);
    end;

    local procedure InitSalesLineFields(var ToSalesLine: Record "Sales Line")
    begin
        OnBeforeInitSalesLineFields(ToSalesLine);

        if ToSalesLine."Document Type" <> ToSalesLine."Document Type"::Order then begin
            ToSalesLine."Prepayment %" := 0;
            ToSalesLine."Prepayment VAT %" := 0;
            ToSalesLine."Prepmt. VAT Calc. Type" := 0;
            ToSalesLine."Prepayment VAT Identifier" := '';
            ToSalesLine."Prepayment VAT %" := 0;
            ToSalesLine."Prepayment Tax Group Code" := '';
            ToSalesLine."Prepmt. Line Amount" := 0;
            ToSalesLine."Prepmt. Amt. Incl. VAT" := 0;
        end;
        ToSalesLine."Prepmt. Amt. Inv." := 0;
        ToSalesLine."Prepmt. Amount Inv. (LCY)" := 0;
        ToSalesLine."Prepayment Amount" := 0;
        ToSalesLine."Prepmt. VAT Base Amt." := 0;
        ToSalesLine."Prepmt Amt to Deduct" := 0;
        ToSalesLine."Prepmt Amt Deducted" := 0;
        ToSalesLine."Prepmt. Amount Inv. Incl. VAT" := 0;
        ToSalesLine."Prepayment VAT Difference" := 0;
        ToSalesLine."Prepmt VAT Diff. to Deduct" := 0;
        ToSalesLine."Prepmt VAT Diff. Deducted" := 0;
        ToSalesLine."Prepmt. Amt. Incl. VAT" := 0;
        ToSalesLine."Prepmt. VAT Amount Inv. (LCY)" := 0;
        ToSalesLine."Quantity Shipped" := 0;
        ToSalesLine."Qty. Shipped (Base)" := 0;
        ToSalesLine."Return Qty. Received" := 0;
        ToSalesLine."Return Qty. Received (Base)" := 0;
        ToSalesLine."Quantity Invoiced" := 0;
        ToSalesLine."Qty. Invoiced (Base)" := 0;
        ToSalesLine."Reserved Quantity" := 0;
        ToSalesLine."Reserved Qty. (Base)" := 0;
        ToSalesLine."Qty. to Ship" := 0;
        ToSalesLine."Qty. to Ship (Base)" := 0;
        ToSalesLine."Return Qty. to Receive" := 0;
        ToSalesLine."Return Qty. to Receive (Base)" := 0;
        ToSalesLine."Qty. to Invoice" := 0;
        ToSalesLine."Qty. to Invoice (Base)" := 0;
        ToSalesLine."Qty. Shipped Not Invoiced" := 0;
        ToSalesLine."Return Qty. Rcd. Not Invd." := 0;
        ToSalesLine."Shipped Not Invoiced" := 0;
        ToSalesLine."Return Rcd. Not Invd." := 0;
        ToSalesLine."Qty. Shipped Not Invd. (Base)" := 0;
        ToSalesLine."Ret. Qty. Rcd. Not Invd.(Base)" := 0;
        ToSalesLine."Shipped Not Invoiced (LCY)" := 0;
        ToSalesLine."Return Rcd. Not Invd. (LCY)" := 0;
        ToSalesLine."Job No." := '';
        ToSalesLine."Job Task No." := '';
        ToSalesLine."Job Contract Entry No." := 0;
        //>>BC6 SBE 27/01/2022
        ToSalesLine."Quantity (Base)" := 0;
        ToSalesLine."Outstanding Qty. (Base)" := 0;
        ToSalesLine."Qty. to Invoice (Base)" := 0;
        ToSalesLine."Qty. to Ship (Base)" := 0;
        //<<BC6 SBE 27/01/2022

        OnAfterInitSalesLineFields(ToSalesLine);
    end;

    local procedure InitPurchLineFields(var ToPurchLine: Record "Purchase Line")
    begin
        OnBeforeInitPurchLineFields(ToPurchLine);

        if ToPurchLine."Document Type" <> ToPurchLine."Document Type"::Order then begin
            ToPurchLine."Prepayment %" := 0;
            ToPurchLine."Prepayment VAT %" := 0;
            ToPurchLine."Prepmt. VAT Calc. Type" := 0;
            ToPurchLine."Prepayment VAT Identifier" := '';
            ToPurchLine."Prepayment VAT %" := 0;
            ToPurchLine."Prepayment Tax Group Code" := '';
            ToPurchLine."Prepmt. Line Amount" := 0;
            ToPurchLine."Prepmt. Amt. Incl. VAT" := 0;
        end;
        ToPurchLine."Prepmt. Amt. Inv." := 0;
        ToPurchLine."Prepmt. Amount Inv. (LCY)" := 0;
        ToPurchLine."Prepayment Amount" := 0;
        ToPurchLine."Prepmt. VAT Base Amt." := 0;
        ToPurchLine."Prepmt Amt to Deduct" := 0;
        ToPurchLine."Prepmt Amt Deducted" := 0;
        ToPurchLine."Prepmt. Amount Inv. Incl. VAT" := 0;
        ToPurchLine."Prepayment VAT Difference" := 0;
        ToPurchLine."Prepmt VAT Diff. to Deduct" := 0;
        ToPurchLine."Prepmt VAT Diff. Deducted" := 0;
        ToPurchLine."Prepmt. Amt. Incl. VAT" := 0;
        ToPurchLine."Prepmt. VAT Amount Inv. (LCY)" := 0;
        ToPurchLine."Quantity Received" := 0;
        ToPurchLine."Qty. Received (Base)" := 0;
        ToPurchLine."Return Qty. Shipped" := 0;
        ToPurchLine."Return Qty. Shipped (Base)" := 0;
        ToPurchLine."Quantity Invoiced" := 0;
        ToPurchLine."Qty. Invoiced (Base)" := 0;
        ToPurchLine."Reserved Quantity" := 0;
        ToPurchLine."Reserved Qty. (Base)" := 0;
        ToPurchLine."Qty. Rcd. Not Invoiced" := 0;
        ToPurchLine."Qty. Rcd. Not Invoiced (Base)" := 0;
        ToPurchLine."Return Qty. Shipped Not Invd." := 0;
        ToPurchLine."Ret. Qty. Shpd Not Invd.(Base)" := 0;
        ToPurchLine."Qty. to Receive" := 0;
        ToPurchLine."Qty. to Receive (Base)" := 0;
        ToPurchLine."Return Qty. to Ship" := 0;
        ToPurchLine."Return Qty. to Ship (Base)" := 0;
        ToPurchLine."Qty. to Invoice" := 0;
        ToPurchLine."Qty. to Invoice (Base)" := 0;
        ToPurchLine."Amt. Rcd. Not Invoiced" := 0;
        ToPurchLine."Amt. Rcd. Not Invoiced (LCY)" := 0;
        ToPurchLine."Return Shpd. Not Invd." := 0;
        ToPurchLine."Return Shpd. Not Invd. (LCY)" := 0;

        OnAfterInitPurchLineFields(ToPurchLine);
    end;

    local procedure CopySalesJobFields(var ToSalesLine: Record "Sales Line"; ToSalesHeader: Record "Sales Header"; FromSalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopySalesJobFields(ToSalesLine, FromSalesLine, IsHandled);
        if IsHandled then
            exit;

        ToSalesLine."Job No." := FromSalesLine."Job No.";
        ToSalesLine."Job Task No." := FromSalesLine."Job Task No.";
        if ToSalesHeader."Document Type" = ToSalesHeader."Document Type"::Invoice then
            ToSalesLine."Job Contract Entry No." :=
              CreateJobPlanningLine(ToSalesHeader, ToSalesLine, FromSalesLine."Job Contract Entry No.")
        else
            ToSalesLine."Job Contract Entry No." := FromSalesLine."Job Contract Entry No.";
    end;

    local procedure CopySalesLineExtText(ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; FromSalesHeader: Record "Sales Header"; FromSalesLine: Record "Sales Line"; DocLineNo: Integer; var NextLineNo: Integer)
    var
        ToSalesLine2: Record "Sales Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopySalesLineExtText(ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine, DocLineNo, NextLineNo, IsHandled);
        if IsHandled then
            exit;

        if (ToSalesHeader."Language Code" <> FromSalesHeader."Language Code") or RecalculateLines or CopyExtText then
            if TransferExtendedText.SalesCheckIfAnyExtText(ToSalesLine, false) then begin
                TransferExtendedText.InsertSalesExtText(ToSalesLine);
                ToSalesLine2.SETRANGE("Document Type", ToSalesLine."Document Type");
                ToSalesLine2.SETRANGE("Document No.", ToSalesLine."Document No.");
                ToSalesLine2.FINDLAST();
                NextLineNo := ToSalesLine2."Line No.";
                exit;
            end;

        ToSalesLine."Attached to Line No." :=
          TransferOldExtLines.TransferExtendedText(DocLineNo, NextLineNo, FromSalesLine."Attached to Line No.");
    end;

    procedure CopySalesLinesToDoc(FromDocType: Option; ToSalesHeader: Record "Sales Header"; var FromSalesShipmentLine: Record "Sales Shipment Line"; var FromSalesInvoiceLine: Record "Sales Invoice Line"; var FromReturnReceiptLine: Record "Return Receipt Line"; var FromSalesCrMemoLine: Record "Sales Cr.Memo Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    begin
        OnBeforeCopySalesLinesToDoc(
          FromDocType, ToSalesHeader, FromSalesShipmentLine, FromSalesInvoiceLine, FromReturnReceiptLine, FromSalesCrMemoLine,
          LinesNotCopied, MissingExCostRevLink);
        CopyExtText := true;
        case FromDocType of
            SalesDocType::"Posted Shipment".AsInteger():
                CopySalesShptLinesToDoc(ToSalesHeader, FromSalesShipmentLine, LinesNotCopied, MissingExCostRevLink);
            SalesDocType::"Posted Invoice".AsInteger():
                CopySalesInvLinesToDoc(ToSalesHeader, FromSalesInvoiceLine, LinesNotCopied, MissingExCostRevLink);
            SalesDocType::"Posted Return Receipt".AsInteger():
                CopySalesReturnRcptLinesToDoc(ToSalesHeader, FromReturnReceiptLine, LinesNotCopied, MissingExCostRevLink);
            SalesDocType::"Posted Credit Memo".AsInteger():
                CopySalesCrMemoLinesToDoc(ToSalesHeader, FromSalesCrMemoLine, LinesNotCopied, MissingExCostRevLink);
        end;
        CopyExtText := false;
        OnAfterCopySalesLinesToDoc(
          FromDocType, ToSalesHeader, FromSalesShipmentLine, FromSalesInvoiceLine, FromReturnReceiptLine, FromSalesCrMemoLine,
          LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopyPurchaseJobFields(var ToPurchLine: Record "Purchase Line"; FromPurchLine: Record "Purchase Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyPurchaseJobFields(ToPurchLine, FromPurchLine, IsHandled);
        if IsHandled then
            exit;

        ToPurchLine.VALIDATE("Job No.", FromPurchLine."Job No.");
        ToPurchLine.VALIDATE("Job Task No.", FromPurchLine."Job Task No.");
        ToPurchLine.VALIDATE("Job Line Type", FromPurchLine."Job Line Type");
    end;

    local procedure CopyPurchLineExtText(ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; FromPurchHeader: Record "Purchase Header"; FromPurchLine: Record "Purchase Line"; DocLineNo: Integer; var NextLineNo: Integer)
    var
        ToPurchLine2: Record "Purchase Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyPurchLineExtText(ToPurchHeader, ToPurchLine, FromPurchHeader, FromPurchLine, DocLineNo, NextLineNo, IsHandled);
        if IsHandled then
            exit;

        if (ToPurchHeader."Language Code" <> FromPurchHeader."Language Code") or RecalculateLines or CopyExtText then
            if TransferExtendedText.PurchCheckIfAnyExtText(ToPurchLine, false) then begin
                TransferExtendedText.InsertPurchExtText(ToPurchLine);
                ToPurchLine2.SETRANGE("Document Type", ToPurchLine."Document Type");
                ToPurchLine2.SETRANGE("Document No.", ToPurchLine."Document No.");
                ToPurchLine2.FINDLAST();
                NextLineNo := ToPurchLine2."Line No.";
                exit;
            end;

        ToPurchLine."Attached to Line No." :=
          TransferOldExtLines.TransferExtendedText(DocLineNo, NextLineNo, FromPurchLine."Attached to Line No.");
    end;

    procedure CopyPurchaseLinesToDoc(FromDocType: Option; ToPurchaseHeader: Record "Purchase Header"; var FromPurchRcptLine: Record "Purch. Rcpt. Line"; var FromPurchInvLine: Record "Purch. Inv. Line"; var FromReturnShipmentLine: Record "Return Shipment Line"; var FromPurchCrMemoLine: Record "Purch. Cr. Memo Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    begin
        OnBeforeCopyPurchaseLinesToDoc(
          FromDocType, ToPurchaseHeader, FromPurchRcptLine, FromPurchInvLine, FromReturnShipmentLine, FromPurchCrMemoLine,
          LinesNotCopied, MissingExCostRevLink);
        CopyExtText := true;
        case FromDocType of
            PurchDocType::"Posted Receipt".AsInteger():
                CopyPurchRcptLinesToDoc(ToPurchaseHeader, FromPurchRcptLine, LinesNotCopied, MissingExCostRevLink);
            PurchDocType::"Posted Invoice".AsInteger():
                CopyPurchInvLinesToDoc(ToPurchaseHeader, FromPurchCrMemoLine, FromPurchInvLine, LinesNotCopied, MissingExCostRevLink);
            PurchDocType::"Posted Return Shipment".AsInteger():
                CopyPurchReturnShptLinesToDoc(ToPurchaseHeader, FromReturnShipmentLine, LinesNotCopied, MissingExCostRevLink);
            PurchDocType::"Posted Credit Memo".AsInteger():
                CopyPurchCrMemoLinesToDoc(ToPurchaseHeader, FromPurchCrMemoLine, LinesNotCopied, MissingExCostRevLink);
        end;
        CopyExtText := false;
        OnAfterCopyPurchaseLinesToDoc(
          FromDocType, ToPurchaseHeader, FromPurchRcptLine, FromPurchInvLine, FromReturnShipmentLine, FromPurchCrMemoLine,
          LinesNotCopied, MissingExCostRevLink);
    end;

    local procedure CopyShiptoCodeFromInvToCrMemo(var ToSalesHeader: Record "Sales Header"; FromSalesInvHeader: Record "Sales Invoice Header"; FromDocType: Option)
    begin
        if (FromDocType = SalesDocType::"Posted Invoice".AsInteger()) and
           (FromSalesInvHeader."Ship-to Code" <> '') and
           (ToSalesHeader."Document Type" = ToSalesHeader."Document Type"::"Credit Memo")
        then
            ToSalesHeader."Ship-to Code" := FromSalesInvHeader."Ship-to Code";
    end;

    local procedure TransferFieldsFromCrMemoToInv(var ToSalesHeader: Record "Sales Header"; FromSalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        ToSalesHeader.VALIDATE("Sell-to Customer No.", FromSalesCrMemoHeader."Sell-to Customer No.");
        ToSalesHeader.TRANSFERFIELDS(FromSalesCrMemoHeader, false);
        if (ToSalesHeader."Document Type" = ToSalesHeader."Document Type"::Invoice) and IncludeHeader then begin
            ToSalesHeader.CopySellToAddressToShipToAddress();
            ToSalesHeader.VALIDATE("Ship-to Code", FromSalesCrMemoHeader."Ship-to Code");
        end;

        OnAfterTransferFieldsFromCrMemoToInv(ToSalesHeader, FromSalesCrMemoHeader);
    end;

    local procedure CopyShippingInfoPurchOrder(var ToPurchaseHeader: Record "Purchase Header"; FromPurchaseHeader: Record "Purchase Header")
    begin
        if (ToPurchaseHeader."Document Type" = ToPurchaseHeader."Document Type"::Order) and
           (FromPurchaseHeader."Document Type" = FromPurchaseHeader."Document Type"::Order)
        then begin
            ToPurchaseHeader."Ship-to Address" := FromPurchaseHeader."Ship-to Address";
            ToPurchaseHeader."Ship-to Address 2" := FromPurchaseHeader."Ship-to Address 2";
            ToPurchaseHeader."Ship-to City" := FromPurchaseHeader."Ship-to City";
            ToPurchaseHeader."Ship-to Country/Region Code" := FromPurchaseHeader."Ship-to Country/Region Code";
            ToPurchaseHeader."Ship-to County" := FromPurchaseHeader."Ship-to County";
            ToPurchaseHeader."Ship-to Name" := FromPurchaseHeader."Ship-to Name";
            ToPurchaseHeader."Ship-to Name 2" := FromPurchaseHeader."Ship-to Name 2";
            ToPurchaseHeader."Ship-to Post Code" := FromPurchaseHeader."Ship-to Post Code";
            ToPurchaseHeader."Ship-to Contact" := FromPurchaseHeader."Ship-to Contact";
            ToPurchaseHeader."Inbound Whse. Handling Time" := FromPurchaseHeader."Inbound Whse. Handling Time";
        end;
    end;

    local procedure SetSalespersonPurchaserCode(var SalespersonPurchaserCode: Code[20])
    begin
        if SalespersonPurchaserCode <> '' then
            if SalespersonPurchaser.GET(SalespersonPurchaserCode) then
                if SalespersonPurchaser.VerifySalesPersonPurchaserPrivacyBlocked(SalespersonPurchaser) then
                    SalespersonPurchaserCode := ''
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesDocument(FromDocumentType: Option; FromDocumentNo: Code[20]; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesLine(var ToSalesHeader: Record "Sales Header"; FromSalesHeader: Record "Sales Header"; FromSalesLine: Record "Sales Line"; RecalculateAmount: Boolean; var CopyThisLine: Boolean; MoveNegLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyArchSalesLine(var ToSalesHeader: Record "Sales Header"; FromSalesHeaderArchive: Record "Sales Header Archive"; FromSalesLineArchive: Record "Sales Line Archive"; RecalculateAmount: Boolean; var CopyThisLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchaseDocument(FromDocumentType: Option; FromDocumentNo: Code[20]; var ToPurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchLine(var ToPurchHeader: Record "Purchase Header"; FromPurchHeader: Record "Purchase Header"; FromPurchLine: Record "Purchase Line"; RecalculateAmount: Boolean; var CopyThisLine: Boolean; ToPurchLine: Record "Purchase Line"; MoveNegLines: Boolean; var RoundingLineInserted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyArchPurchLine(var ToPurchHeader: Record "Purchase Header"; FromPurchHeaderArchive: Record "Purchase Header Archive"; FromPurchLineArchive: Record "Purchase Line Archive"; RecalculateAmount: Boolean; var CopyThisLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesHeader(var ToSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20]; IncludeHeader: Boolean; FromDocOccurenceNo: Integer; FromDocVersionNo: Integer)
    begin
    end;

    local procedure AddSalesDocLine(var TempDocSalesLine: Record "Sales Line" temporary; BufferLineNo: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer)
    begin
        OnBeforeAddSalesDocLine(TempDocSalesLine, BufferLineNo, DocumentNo, DocumentLineNo);

        TempDocSalesLine."Document No." := DocumentNo;
        TempDocSalesLine."Line No." := DocumentLineNo;
        TempDocSalesLine."Shipment Line No." := BufferLineNo;
        TempDocSalesLine.INSERT();
    end;

    local procedure GetSalesLineNo(var TempDocSalesLine: Record "Sales Line" temporary; BufferLineNo: Integer): Integer
    begin
        TempDocSalesLine.SETRANGE("Shipment Line No.", BufferLineNo);
        if not TempDocSalesLine.FINDFIRST() then
            exit(0);
        exit(TempDocSalesLine."Line No.");
    end;

    local procedure GetSalesDocNo(var TempDocSalesLine: Record "Sales Line" temporary; BufferLineNo: Integer): Code[20]
    begin
        TempDocSalesLine.SETRANGE("Shipment Line No.", BufferLineNo);
        if not TempDocSalesLine.FINDFIRST() then
            exit('');
        exit(TempDocSalesLine."Document No.");
    end;

    local procedure AddPurchDocLine(var TempDocPurchaseLine: Record "Purchase Line" temporary; BufferLineNo: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer)
    begin
        OnBeforeAddPurchDocLine(TempDocPurchaseLine, BufferLineNo, DocumentNo, DocumentLineNo);

        TempDocPurchaseLine."Document No." := DocumentNo;
        TempDocPurchaseLine."Line No." := DocumentLineNo;
        TempDocPurchaseLine."Receipt Line No." := BufferLineNo;
        TempDocPurchaseLine.INSERT();
    end;

    local procedure GetPurchLineNo(var TempDocPurchaseLine: Record "Purchase Line" temporary; BufferLineNo: Integer): Integer
    begin
        TempDocPurchaseLine.SETRANGE("Receipt Line No.", BufferLineNo);
        if not TempDocPurchaseLine.FINDFIRST() then
            exit(0);
        exit(TempDocPurchaseLine."Line No.");
    end;

    local procedure GetPurchDocNo(var TempDocPurchaseLine: Record "Purchase Line" temporary; BufferLineNo: Integer): Code[20]
    begin
        TempDocPurchaseLine.SETRANGE("Receipt Line No.", BufferLineNo);
        if not TempDocPurchaseLine.FINDFIRST() then
            exit('');
        exit(TempDocPurchaseLine."Document No.");
    end;

    local procedure SetTrackingOnAssemblyReservation(AssemblyHeader: Record "Assembly Header"; var TempItemLedgerEntry: Record "Item Ledger Entry" temporary)
    var
        ReservationEntry: Record "Reservation Entry";
        TempReservationEntry: Record "Reservation Entry" temporary;
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEngineMgt: Codeunit "Reservation Engine Mgt.";
        QtyToAddAsBlank: Decimal;
    begin
        TempItemLedgerEntry.SETFILTER("Lot No.", '<>%1', '');
        if TempItemLedgerEntry.ISEMPTY then
            exit;

        ReservationEntry.SETRANGE("Source Type", DATABASE::"Assembly Header");
        ReservationEntry.SETRANGE("Source Subtype", AssemblyHeader."Document Type");
        ReservationEntry.SETRANGE("Source ID", AssemblyHeader."No.");
        ReservationEntry.SETRANGE("Source Ref. No.", 0);
        ReservationEntry.SETRANGE("Reservation Status", ReservationEntry."Reservation Status"::Reservation);
        if ReservationEntry.FINDSET() then
            repeat
                TempReservationEntry := ReservationEntry;
                TempReservationEntry.INSERT();
            until ReservationEntry.NEXT() = 0;

        if TempItemLedgerEntry.FINDSET() then
            repeat
                TempTrackingSpecification."Entry No." += 1;
                TempTrackingSpecification."Item No." := TempItemLedgerEntry."Item No.";
                TempTrackingSpecification."Location Code" := TempItemLedgerEntry."Location Code";
                TempTrackingSpecification."Quantity (Base)" := TempItemLedgerEntry.Quantity;
                TempTrackingSpecification."Serial No." := TempItemLedgerEntry."Serial No.";
                TempTrackingSpecification."Lot No." := TempItemLedgerEntry."Lot No.";
                TempTrackingSpecification."Warranty Date" := TempItemLedgerEntry."Warranty Date";
                TempTrackingSpecification."Expiration Date" := TempItemLedgerEntry."Expiration Date";
                TempTrackingSpecification.INSERT();
            until TempItemLedgerEntry.NEXT() = 0;

        if TempTrackingSpecification.FINDSET() then
            repeat
                if GetItemTrackingCode(ItemTrackingCode, TempTrackingSpecification."Item No.") then
                    ReservationEngineMgt.AddItemTrackingToTempRecSet(
                          TempReservationEntry, TempTrackingSpecification, TempTrackingSpecification."Quantity (Base)",
                          QtyToAddAsBlank, ItemTrackingCode);
            until TempTrackingSpecification.NEXT() = 0;
    end;

    local procedure GetItemTrackingCode(var ItemTrackingCode: Record "Item Tracking Code"; ItemNo: Code[20]): Boolean
    begin
        if not Item.GET(ItemNo) then
            exit(false);

        if Item."Item Tracking Code" = '' then
            exit(false);

        ItemTrackingCode.GET(Item."Item Tracking Code");
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddPurchDocLine(var TempDocPurchaseLine: Record "Purchase Line" temporary; BufferLineNo: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddSalesDocLine(var TempDocSalesLine: Record "Sales Line" temporary; BufferLineNo: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchLines(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchInvLines(var TempDocPurchaseLine: Record "Purchase Line" temporary; var ToPurchHeader: Record "Purchase Header"; var FromPurchInvLine: Record "Purch. Inv. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchCrMemoLinesToDoc(var TempDocPurchaseLine: Record "Purchase Line" temporary; var ToPurchHeader: Record "Purchase Header"; var FromPurchCrMemoLine: Record "Purch. Cr. Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchaseLinesToDoc(FromDocType: Option; var ToPurchaseHeader: Record "Purchase Header"; var FromPurchRcptLine: Record "Purch. Rcpt. Line"; var FromPurchInvLine: Record "Purch. Inv. Line"; var FromReturnShipmentLine: Record "Return Shipment Line"; var FromPurchCrMemoLine: Record "Purch. Cr. Memo Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchReturnShptLinesToDoc(var TempDocPurchaseLine: Record "Purchase Line" temporary; var ToPurchHeader: Record "Purchase Header"; var FromReturnShipmentLine: Record "Return Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchaseJobFields(var ToPurchaseLine: Record "Purchase Line"; FromPurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchLineExtText(ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; FromPurchHeader: Record "Purchase Header"; FromPurchLine: Record "Purchase Line"; DocLineNo: Integer; var NextLineNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesShptLinesToDoc(var TempDocSalesLine: Record "Sales Line" temporary; var ToSalesHeader: Record "Sales Header"; var FromSalesShptLine: Record "Sales Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesShptLinesToBuffer(var FromSalesLine: Record "Sales Line"; var FromSalesShptLine: Record "Sales Shipment Line"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesInvLines(var TempDocSalesLine: Record "Sales Line" temporary; var ToSalesHeader: Record "Sales Header"; var FromSalesInvLine: Record "Sales Invoice Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesInvLinesToBuffer(var FromSalesLine: Record "Sales Line"; var FromSalesInvLine: Record "Sales Invoice Line"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesCrMemoLinesToDoc(var TempDocSalesLine: Record "Sales Line" temporary; var ToSalesHeader: Record "Sales Header"; var FromSalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesCrMemoLinesToBuffer(var FromSalesLine: Record "Sales Line"; var FromSalesCrMemoLine: Record "Sales Cr.Memo Line"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesReturnRcptLinesToDoc(var TempDocSalesLine: Record "Sales Line" temporary; var ToSalesHeader: Record "Sales Header"; var FromReturnReceiptLine: Record "Return Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesReturnRcptLinesToBuffer(var FromSalesLine: Record "Sales Line"; var FromReturnReceiptLine: Record "Return Receipt Line"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesToPurchDoc(var ToPurchLine: Record "Purchase Line"; var FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesLinesToDoc(FromDocType: Option; var ToSalesHeader: Record "Sales Header"; var FromSalesShipmentLine: Record "Sales Shipment Line"; var FromSalesInvoiceLine: Record "Sales Invoice Line"; var FromReturnReceiptLine: Record "Return Receipt Line"; var FromSalesCrMemoLine: Record "Sales Cr.Memo Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesJobFields(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesLineExtText(ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; FromSalesHeader: Record "Sales Header"; FromSalesLine: Record "Sales Line"; DocLineNo: Integer; var NextLineNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesDocForInvoiceCancelling(var ToSalesHeader: Record "Sales Header"; FromDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesDocForCrMemoCancelling(var ToSalesHeader: Record "Sales Header"; FromDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchaseDocForInvoiceCancelling(var ToPurchaseHeader: Record "Purchase Header"; FromDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchaseDocForCrMemoCancelling(var ToPurchaseHeader: Record "Purchase Header"; FromDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteNegSalesLines(FromDocType: Option; FromDocNo: Code[20]; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetShipmentDateInLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransfldsFromSalesToPurchLine(var FromSalesLine: Record "Sales Line"; var ToPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var CopyThisLine: Boolean; RecalculateAmount: Boolean; FromSalesDocType: Option; var CopyPostedDeferral: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyPurchHeader(var ToPurchHeader: Record "Purchase Header"; FromDocType: Option; FromDocNo: Code[20]; IncludeHeader: Boolean; FromDocOccurenceNo: Integer; FromDocVersionNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRecalculateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var CopyThisLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePurchLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; var FromPurchHeader: Record "Purchase Header"; var FromPurchLine: Record "Purchase Line"; var CopyThisLine: Boolean; RecalculateAmount: Boolean; FromPurchDocType: Option; var CopyPostedDeferral: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromSalesHeader(SalesHeaderFrom: Record "Sales Header"; SalesHeaderTo: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromSalesShptHeader(SalesShipmentHeaderFrom: Record "Sales Shipment Header"; SalesHeaderTo: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromSalesInvHeader(SalesInvoiceHeaderFrom: Record "Sales Invoice Header"; SalesHeaderTo: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromSalesCrMemoHeader(SalesCrMemoHeaderFrom: Record "Sales Cr.Memo Header"; SalesHeaderTo: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromSalesReturnRcptHeader(ReturnReceiptHeaderFrom: Record "Return Receipt Header"; SalesHeaderTo: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromPurchaseHeader(PurchaseHeaderFrom: Record "Purchase Header"; PurchaseHeaderTo: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromPurchaseRcptHeader(PurchRcptHeaderFrom: Record "Purch. Rcpt. Header"; PurchaseHeaderTo: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromPurchaseInvHeader(PurchInvHeaderFrom: Record "Purch. Inv. Header"; PurchaseHeaderTo: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromPurchaseCrMemoHeader(PurchCrMemoHdrFrom: Record "Purch. Cr. Memo Hdr."; PurchaseHeaderTo: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckFromPurchaseReturnShptHeader(ReturnShipmentHeaderFrom: Record "Return Shipment Header"; PurchaseHeaderTo: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromPurchDocAssgntToLine(var ToPurchaseLine: Record "Purchase Line"; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromSalesDocAssgntToLine(var ToSalesLine: Record "Sales Line"; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyArchSalesLine(ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; FromSalesLineArchive: Record "Sales Line Archive"; IncludeHeader: Boolean; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyArchPurchLine(ToPurchHeader: Record "Purchase Header"; var ToPurchaseLine: Record "Purchase Line"; FromPurchaseLineArchive: Record "Purchase Line Archive"; IncludeHeader: Boolean; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPostedReceipt(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header"; FromPurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPostedShipment(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; FromSalesShipmentHeader: Record "Sales Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPostedPurchInvoice(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header"; FromPurchInvHeader: Record "Purch. Inv. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPostedReturnReceipt(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; ReturnReceiptHeader: Record "Return Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPostedReturnShipment(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header"; FromReturnShipmentHeader: Record "Return Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesDocument(FromDocumentType: Option; FromDocumentNo: Code[20]; var ToSalesHeader: Record "Sales Header"; FromDocOccurenceNo: Integer; FromDocVersionNo: Integer; IncludeHeader: Boolean; RecalculateLines: Boolean; MoveNegLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesHeaderArchive(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; FromSalesHeaderArchive: Record "Sales Header Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesHeaderDone(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; FromSalesHeader: Record "Sales Header"; FromSalesShipmentHeader: Record "Sales Shipment Header"; FromSalesInvoiceHeader: Record "Sales Invoice Header"; FromReturnReceiptHeader: Record "Return Receipt Header"; FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; FromSalesHeaderArchive: Record "Sales Header Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesInvLine(var TempDocSalesLine: Record "Sales Line" temporary; var ToSalesHeader: Record "Sales Header"; var FromSalesLineBuf: Record "Sales Line"; var FromSalesInvLine: Record "Sales Invoice Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesLinesToBufferFields(var TempSalesLine: Record "Sales Line" temporary; FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesLinesToDoc(FromDocType: Option; var ToSalesHeader: Record "Sales Header"; var FromSalesShipmentLine: Record "Sales Shipment Line"; var FromSalesInvoiceLine: Record "Sales Invoice Line"; var FromReturnReceiptLine: Record "Return Receipt Line"; var FromSalesCrMemoLine: Record "Sales Cr.Memo Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyServContractLines(ToServiceContractHeader: Record "Service Contract Header"; FromDocType: Option; FromDocNo: Code[20]; var FormServiceContractLine: Record "Service Contract Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchaseDocument(FromDocumentType: Option; FromDocumentNo: Code[20]; var ToPurchaseHeader: Record "Purchase Header"; FromDocOccurenceNo: Integer; FromDocVersionNo: Integer; IncludeHeader: Boolean; RecalculateLines: Boolean; MoveNegLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchHeaderArchive(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header"; FromPurchaseHeaderArchive: Record "Purchase Header Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchHeaderDone(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header"; FromPurchaseHeader: Record "Purchase Header"; FromPurchRcptHeader: Record "Purch. Rcpt. Header"; FromPurchInvHeader: Record "Purch. Inv. Header"; ReturnShipmentHeader: Record "Return Shipment Header"; FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; FromPurchaseHeaderArchive: Record "Purchase Header Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchInvLines(var TempDocPurchaseLine: Record "Purchase Line" temporary; var ToPurchHeader: Record "Purchase Header"; var FromPurchLineBuf: Record "Purchase Line"; var FromPurchInvLine: Record "Purch. Inv. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchInvLine(FromPurchInvLine: Record "Purch. Inv. Line"; ToPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchLinesToBufferFields(var TempPurchaseLine: Record "Purchase Line" temporary; FromPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchaseLinesToDoc(FromDocType: Option; var ToPurchaseHeader: Record "Purchase Header"; var FromPurchRcptLine: Record "Purch. Rcpt. Line"; var FromPurchInvLine: Record "Purch. Inv. Line"; var FromReturnShipmentLine: Record "Return Shipment Line"; var FromPurchCrMemoLine: Record "Purch. Cr. Memo Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchCrMemoLine(FromPurchCrMemoLine: Record "Purch. Cr. Memo Line"; ToPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchRcptLine(FromPurchRcptLine: Record "Purch. Rcpt. Line"; ToPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyReturnShptLine(FromReturnShipmentLine: Record "Return Shipment Line"; ToPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessServContractLine(var ToServContractLine: Record "Service Contract Line"; FromServContractLine: Record "Service Contract Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRecalculatePurchLine(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRecalculateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var CopyThisLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDefaultValuesToSalesLine(var ToSalesLine: Record "Sales Line"; ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDefaultValuesToPurchLine(var ToPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferFieldsFromCrMemoToInv(var ToSalesHeader: Record "Sales Header"; FromSalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferTempAsmHeader(var TempAssemblyHeader: Record "Assembly Header" temporary; PostedAssemblyHeader: Record "Posted Assembly Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var CopyThisLine: Boolean; RecalculateAmount: Boolean; FromSalesDocType: Option; var CopyPostedDeferral: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdatePurchLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; var FromPurchHeader: Record "Purchase Header"; var FromPurchLine: Record "Purchase Line"; var CopyThisLine: Boolean; RecalculateAmount: Boolean; FromPurchDocType: Option; var CopyPostedDeferral: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateSalesLine(var ToSalesLine: Record "Sales Line"; var FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdatePurchLine(var ToPurchLine: Record "Purchase Line"; var FromPurchLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocWithHeader(FromDocType: Option; FromDocNo: Code[20]; var ToSalesHeader: Record "Sales Header"; FromDocOccurenceNo: Integer; FromDocVersionNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocWithHeader(FromDocType: Option; FromDocNo: Code[20]; var ToPurchHeader: Record "Purchase Header"; FromDocOccurenceNo: Integer; FromDocVersionNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransfldsFromSalesToPurchLine(var FromSalesLine: Record "Sales Line"; var ToPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitAndCheckSalesDocuments(FromDocType: Option; FromDocNo: Code[20]; FromDocOccurrenceNo: Integer; FromDocVersionNo: Integer; var FromSalesHeader: Record "Sales Header"; var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesShipmentHeader: Record "Sales Shipment Header"; var FromSalesInvoiceHeader: Record "Sales Invoice Header"; var FromReturnReceiptHeader: Record "Return Receipt Header"; var FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; var FromSalesHeaderArchive: Record "Sales Header Archive"; IncludeHeader: Boolean; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitAndCheckPurchaseDocuments(FromDocType: Option; FromDocNo: Code[20]; FromDocOccurrenceNo: Integer; FromDocVersionNo: Integer; var FromPurchaseHeader: Record "Purchase Header"; var ToPurchaseHeader: Record "Purchase Header"; var FromPurchRcptHeader: Record "Purch. Rcpt. Header"; var FromPurchInvHeader: Record "Purch. Inv. Header"; var FromReturnShipmentHeader: Record "Return Shipment Header"; var FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var FromPurchaseHeaderArchive: Record "Purchase Header Archive"; IncludeHeader: Boolean; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitSalesLineFields(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPurchLineFields(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitToSalesLine(var ToSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSalesLineFields(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitPurchLineFields(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertToSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; FromDocType: Option; RecalcLines: Boolean; var ToSalesHeader: Record "Sales Header"; DocLineNo: Integer; var NextLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertOldSalesDocNoLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; OldDocType: Option; OldDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertOldSalesCombDocNoLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; CopyFromInvoice: Boolean; OldDocNo: Code[20]; OldDocNo2: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitToPurchLine(var ToPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertToPurchLine(var ToPurchLine: Record "Purchase Line"; FromPurchLine: Record "Purchase Line"; FromDocType: Option; RecalcLines: Boolean; var ToPurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertOldPurchDocNoLine(ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; OldDocType: Option; OldDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertOldPurchCombDocNoLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line"; CopyFromInvoice: Boolean; OldDocNo: Code[20]; OldDocNo2: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateCustLedgEntry(var ToSalesHeader: Record "Sales Header"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateVendLedgEntry(var ToPurchaseHeader: Record "Purchase Header"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, true)]
    local procedure OnAfterInsertToSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; RecalculateLinesP: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesToPurchDoc(var ToPurchLine: Record "Purchase Line"; var FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, true)]
    local procedure OnAfterInsertToPurchLine(var ToPurchLine: Record "Purchase Line"; var FromPurchLine: Record "Purchase Line"; RecalculateLinesP: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesHeader(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; FromSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchaseHeader(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesLineFromSalesDocSalesLine(ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesLine: Record "Sales Line"; IncludeHeader: Boolean; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesLineFromSalesLineBuffer(var ToSalesLine: Record "Sales Line"; FromSalesInvLine: Record "Sales Invoice Line"; IncludeHeader: Boolean; RecalculateLines: Boolean; var TempDocSalesLine: Record "Sales Line" temporary; ToSalesHeader: Record "Sales Header"; FromSalesLineBuf: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesLineFromSalesCrMemoLineBuffer(var ToSalesLine: Record "Sales Line"; FromSalesCrMemoLine: Record "Sales Cr.Memo Line"; IncludeHeader: Boolean; RecalculateLines: Boolean; var TempDocSalesLine: Record "Sales Line" temporary; ToSalesHeader: Record "Sales Header"; FromSalesLineBuf: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesLineFromSalesShptLineBuffer(var ToSalesLine: Record "Sales Line"; FromSalesShipmentLine: Record "Sales Shipment Line"; IncludeHeader: Boolean; RecalculateLines: Boolean; var TempDocSalesLine: Record "Sales Line" temporary; ToSalesHeader: Record "Sales Header"; FromSalesLineBuf: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopySalesLineFromReturnRcptLineBuffer(var ToSalesLine: Record "Sales Line"; FromReturnReceiptLine: Record "Return Receipt Line"; IncludeHeader: Boolean; RecalculateLines: Boolean; var TempDocSalesLine: Record "Sales Line" temporary; ToSalesHeader: Record "Sales Header"; FromSalesLineBuf: Record "Sales Line"; CopyItemTrkg: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchLineFromPurchLineBuffer(var ToPurchLine: Record "Purchase Line"; FromPurchInvLine: Record "Purch. Inv. Line"; IncludeHeader: Boolean; RecalculateLines: Boolean; var TempDocPurchaseLine: Record "Purchase Line" temporary; ToPurchHeader: Record "Purchase Header"; FromPurchLineBuf: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchLineFromPurchCrMemoLineBuffer(var ToPurchaseLine: Record "Purchase Line"; FromPurchCrMemoLine: Record "Purch. Cr. Memo Line"; IncludeHeader: Boolean; RecalculateLines: Boolean; var TempDocPurchLine: Record "Purchase Line" temporary; ToPurchHeader: Record "Purchase Header"; FromPurchLineBuf: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchLineFromPurchRcptLineBuffer(var ToPurchaseLine: Record "Purchase Line"; FromPurchRcptLine: Record "Purch. Rcpt. Line"; IncludeHeader: Boolean; RecalculateLines: Boolean; var TempDocPurchLine: Record "Purchase Line" temporary; ToPurchHeader: Record "Purchase Header"; FromPurchLineBuf: Record "Purchase Line"; CopyItemTrkg: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPurchLineFromReturnShptLineBuffer(var ToPurchaseLine: Record "Purchase Line"; FromReturnShipmentLine: Record "Return Shipment Line"; IncludeHeader: Boolean; RecalculateLines: Boolean; var TempDocPurchLine: Record "Purchase Line" temporary; ToPurchHeader: Record "Purchase Header"; FromPurchLineBuf: Record "Purchase Line"; CopyItemTrkg: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFieldsFromOldSalesHeader(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; MoveNegLines: Boolean; IncludeHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFieldsFromOldPurchHeader(var ToPurchHeader: Record "Purchase Header"; OldPurchHeader: Record "Purchase Header"; MoveNegLines: Boolean; IncludeHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromSalesToPurchDoc(FromSalesHeader: Record "Sales Header"; var ToPurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckCopyFromSalesHeaderAvailOnAfterCheckItemAvailability(ToSalesHeader: Record "Sales Header"; ToSalesLine: Record "Sales Line"; FromSalesHeader: Record "Sales Header"; IncludeHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckCopyFromSalesRetRcptAvailOnAfterCheckItemAvailability(ToSalesHeader: Record "Sales Header"; ToSalesLine: Record "Sales Line"; FromReturnReceiptHeader: Record "Return Receipt Header"; IncludeHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckCopyFromSalesCrMemoAvailOnAfterCheckItemAvailability(ToSalesHeader: Record "Sales Header"; ToSalesLine: Record "Sales Line"; FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; IncludeHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckCopyFromSalesInvoiceAvailOnAfterCheckItemAvailability(ToSalesHeader: Record "Sales Header"; ToSalesLine: Record "Sales Line"; FromSalesInvoiceHeader: Record "Sales Invoice Header"; IncludeHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckCopyFromSalesShptAvailOnAfterCheckItemAvailability(ToSalesHeader: Record "Sales Header"; ToSalesLine: Record "Sales Line"; FromSalesShipmentHeader: Record "Sales Shipment Header"; IncludeHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyArchSalesLineOnAfterToSalesLineInsert(var ToSalesLine: Record "Sales Line"; FromSalesLineArchive: Record "Sales Line Archive"; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyArchSalesLineOnBeforeToSalesLineInsert(var ToSalesLine: Record "Sales Line"; FromSalesLineArchive: Record "Sales Line Archive"; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyArchPurchLineOnAfterToPurchLineInsert(var ToPurchLine: Record "Purchase Line"; FromPurchLineArchive: Record "Purchase Line Archive"; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyArchPurchLineOnBeforeToPurchLineInsert(var ToPurchLine: Record "Purchase Line"; FromPurchLineArchive: Record "Purchase Line Archive"; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromPurchDocAssgntToLineOnAfterSetFilters(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromPurchDocAssgntToLineOnBeforeInsert(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; RecalculateLines: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromSalesDocAssgntToLineOnAfterSetFilters(var ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)"; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromSalesDocAssgntToLineOnBeforeInsert(var ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)"; RecalculateLines: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromSalesToPurchDocOnAfterSetFilters(var FromSalesLine: Record "Sales Line"; FromSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromSalesToPurchDocOnBeforePurchaseHeaderInsert(var ToPurchaseHeader: Record "Purchase Header"; FromSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchLineOnBeforeCheckVATBusGroup(PurchaseLine: Record "Purchase Line"; var CheckVATBusGroup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchCrMemoLinesToDocOnAfterTransferFields(var FromPurchaseLine: Record "Purchase Line"; var FromPurchaseHeader: Record "Purchase Header"; var ToPurchaseHeader: Record "Purchase Header"; var FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchInvLinesToDocOnAfterTransferFields(var FromPurchaseLine: Record "Purchase Line"; var FromPurchaseHeader: Record "Purchase Header"; var ToPurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchRcptLinesToDocOnAfterTransferFields(var FromPurchaseLine: Record "Purchase Line"; var FromPurchaseHeader: Record "Purchase Header"; var ToPurchaseHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchReturnShptLinesToDocOnAfterTransferFields(var FromPurchaseLine: Record "Purchase Line"; var FromPurchaseHeader: Record "Purchase Header"; var ToPurchaseHeader: Record "Purchase Header"; var FromReturnShipmentHeader: Record "Return Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocOnAfterCopyPurchDocLines(FromDocType: Option; FromDocNo: Code[20]; FromPurchaseHeader: Record "Purchase Header"; IncludeHeader: Boolean; var ToPurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocOnBeforeCopyPurchDocRcptLine(var FromPurchRcptHeader: Record "Purch. Rcpt. Header"; var ToPurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocOnBeforeCopyPurchDocInvLine(var FromPurchInvHeader: Record "Purch. Inv. Header"; var ToPurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocOnBeforeCopyPurchDocReturnShptLine(var FromReturnShipmentHeader: Record "Return Shipment Header"; var ToPurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocOnBeforeCopyPurchDocCrMemoLine(var FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ToPurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocOnBeforeUpdatePurchInvoiceDiscountValue(var ToPurchaseHeader: Record "Purchase Header"; FromDocType: Option; FromDocNo: Code[20]; FromDocOccurrenceNo: Integer; FromDocVersionNo: Integer; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocUpdateHeaderOnBeforeUpdateVendLedgerEntry(var ToPurchaseHeader: Record "Purchase Header"; FromDocType: Option; FromDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchDocWithoutHeader(var ToPurchaseHeader: Record "Purchase Header"; FromDocType: Option; FromDocNo: Code[20]; FromOccurenceNo: Integer; FromVersionNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnAfterCopySalesDocLines(FromDocType: Option; FromDocNo: Code[20]; FromDocOccurrenceNo: Integer; FromDocVersionNo: Integer; FromSalesHeader: Record "Sales Header"; IncludeHeader: Boolean; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnBeforeCopySalesDocShptLine(var FromSalesShipmentHeader: Record "Sales Shipment Header"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnBeforeCopySalesDocInvLine(var FromSalesInvoiceHeader: Record "Sales Invoice Header"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnBeforeCopySalesDocCrMemoLine(var FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnBeforeCopySalesDocReturnRcptLine(var FromReturnReceiptHeader: Record "Return Receipt Header"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnBeforeTransferPostedShipmentFields(var ToSalesHeader: Record "Sales Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnAfterTransferPostedInvoiceFields(var ToSalesHeader: Record "Sales Header"; SalesInvoiceHeader: Record "Sales Invoice Header"; OldSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnAfterTransferArchSalesHeaderFields(var ToSalesHeader: Record "Sales Header"; FromSalesHeaderArchive: Record "Sales Header Archive")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnBeforeTransferPostedInvoiceFields(var ToSalesHeader: Record "Sales Header"; SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnBeforeTransferPostedReturnReceiptFields(var ToSalesHeader: Record "Sales Header"; ReturnReceiptHeader: Record "Return Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocOnBeforeUpdateSalesInvoiceDiscountValue(var ToSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20]; FromDocOccurrenceNo: Integer; FromDocVersionNo: Integer; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocInvLineOnAfterSetFilters(var ToSalesHeader: Record "Sales Header"; var FromSalesInvoiceHeader: Record "Sales Invoice Header"; var FromSalesInvoiceLine: Record "Sales Invoice Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocCrMemoLineOnAfterSetFilters(var ToSalesHeader: Record "Sales Header"; var FromSalesCrMemoHeader: Record "Sales Cr.Memo Header"; var FromSalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocShptLineOnAfterSetFilters(var ToSalesHeader: Record "Sales Header"; var FromSalesShipmentHeader: Record "Sales Shipment Header"; var FromSalesShipmentLine: Record "Sales Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocReturnRcptLineOnAfterSetFilters(var ToSalesHeader: Record "Sales Header"; var FromReturnReceiptHeader: Record "Return Receipt Header"; var FromReturnReceiptLine: Record "Return Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocSalesLineOnAfterSetFilters(FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocSalesLineArchiveOnAfterSetFilters(FromSalesHeaderArchive: Record "Sales Header Archive"; var FromSalesLineArchive: Record "Sales Line Archive"; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocUpdateHeaderOnBeforeUpdateCustLedgerEntry(var ToSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesDocWithoutHeader(var ToSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20]; FromOccurenceNo: Integer; FromVersionNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesLineOnAfterTransferFieldsToSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchRcptLinesToDocOnBeforeCopyPurchLine(ToPurchaseHeader: Record "Purchase Header"; var FromPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchInvLinesToDocOnBeforeCopyPurchLine(ToPurchaseHeader: Record "Purchase Header"; var FromPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchCrMemoLinesToDocOnBeforeCopyPurchLine(ToPurchaseHeader: Record "Purchase Header"; var FromPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchReturnShptLinesToDocOnBeforeCopyPurchLine(ToPurchaseHeader: Record "Purchase Header"; var FromPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesShptLinesToDocOnBeforeCopySalesLine(ToSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesInvLinesToDocOnBeforeCopySalesLine(ToSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesCrMemoLinesToDocOnBeforeCopySalesLine(ToSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesLineOnBeforeCheckVATBusGroup(SalesLine: Record "Sales Line"; var CheckVATBusGroup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesLinesToBufferTransferFields(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var TempSalesLineBuf: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopySalesLineOnAfterSetDimensions(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyPurchLineOnAfterSetDimensions(var ToPurchaseLine: Record "Purchase Line"; FromPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSplitPstdSalesLinesPerILETransferFields(var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var TempSalesLineBuf: Record "Sales Line" temporary; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateSalesLineOnAfterRecalculateSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
    end;

    local procedure CheckSalesLineIsBlocked(FromSalesLine: Record "Sales Line")
    begin
        if FromSalesLine."No." = '' then
            exit;

        case FromSalesLine.Type of
            FromSalesLine.Type::Item:
                begin
                    Item.GET(FromSalesLine."No.");
                    Item.TESTFIELD(Blocked, false);
                end;
            FromSalesLine.Type::Resource:
                begin
                    Resource.GET(FromSalesLine."No.");
                    Resource.CheckResourcePrivacyBlocked(false);
                    Resource.TESTFIELD(Blocked, false);
                end;
        end;
    end;

    local procedure CheckPurchaseLineIsBlocked(FromPurchLine: Record "Purchase Line")
    begin
        if (FromPurchLine.Type <> FromPurchLine.Type::Item) or (FromPurchLine."No." = '') then
            exit;

        Item.GET(FromPurchLine."No.");
        Item.TESTFIELD(Blocked, false);
    end;


    local procedure CopySalesLine2(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var NextLineNo: Integer; var LinesNotCopied: Integer; RecalculateAmount: Boolean; FromSalesDocType: Option; var CopyPostedDeferralP: Boolean; DocLineNo: Integer): Boolean
    var
        FromSalesLine2: Record "Sales Line";
        SalesCommentLine: Record "Sales Comment Line";
        SalesCommentLine2: Record "Sales Comment Line";
        RoundingLineInserted: Boolean;
        CopyThisLine: Boolean;
        CheckVATBusGroup: Boolean;
        InvDiscountAmount: Decimal;
    begin
        //>>BC6 MB 01/07/2021
        FromSalesLine2 := FromSalesLine;
        //<<BC6
        CopyThisLine := true;
        OnBeforeCopySalesLine(ToSalesHeader, FromSalesHeader, FromSalesLine, RecalculateLines, CopyThisLine, MoveNegLines);
        if not CopyThisLine then begin
            LinesNotCopied := LinesNotCopied + 1;
            exit(false);
        end;

        CheckSalesRounding(FromSalesLine, RoundingLineInserted);

        if ((ToSalesHeader."Language Code" <> FromSalesHeader."Language Code") or RecalculateLines) and
           (FromSalesLine."Attached to Line No." <> 0) or
           FromSalesLine."Prepayment Line" or RoundingLineInserted
        then
            exit(false);
        ToSalesLine.SetSalesHeader(ToSalesHeader);
        if RecalculateLines and not FromSalesLine."System-Created Entry" then begin
            ToSalesLine.INIT();
            OnAfterInitToSalesLine(ToSalesLine);
        end else begin
            CheckSalesLineIsBlocked(FromSalesLine);
            ToSalesLine := FromSalesLine;
            ToSalesLine."Returns Deferral Start Date" := 0D;
            OnCopySalesLineOnAfterTransferFieldsToSalesLine(ToSalesLine, FromSalesLine);
            if ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::Quote, ToSalesHeader."Document Type"::"Blanket Order"] then
                ToSalesLine."Deferral Code" := '';
            if MoveNegLines and (ToSalesLine.Type <> ToSalesLine.Type::" ") then begin
                ToSalesLine.Amount := -ToSalesLine.Amount;
                ToSalesLine."Amount Including VAT" := -ToSalesLine."Amount Including VAT";
            end
        end;

        CheckVATBusGroup := (not RecalculateLines) and (ToSalesLine."No." <> '');
        OnCopySalesLineOnBeforeCheckVATBusGroup(ToSalesLine, CheckVATBusGroup);
        if CheckVATBusGroup then
            ToSalesLine.TESTFIELD("VAT Bus. Posting Group", ToSalesHeader."VAT Bus. Posting Group");

        //>>BC6 MB 01/07/2021
        //NextLineNo := NextLineNo + 10000;
        NextLineNo := FromSalesLine."Line No.";
        //<<BC6
        ToSalesLine."Document Type" := ToSalesHeader."Document Type";
        ToSalesLine."Document No." := ToSalesHeader."No.";
        ToSalesLine."Line No." := NextLineNo;
        ToSalesLine."Copied From Posted Doc." := FromSalesLine."Copied From Posted Doc.";
        if (ToSalesLine.Type <> ToSalesLine.Type::" ") and
           (ToSalesLine."Document Type" in [ToSalesLine."Document Type"::"Return Order", ToSalesLine."Document Type"::"Credit Memo"])
        then begin
            ToSalesLine."Job Contract Entry No." := 0;
            if (ToSalesLine.Amount = 0) or
               (ToSalesHeader."Prices Including VAT" <> FromSalesHeader."Prices Including VAT") or
               (ToSalesHeader."Currency Factor" <> FromSalesHeader."Currency Factor")
            then begin
                InvDiscountAmount := ToSalesLine."Inv. Discount Amount";
                ToSalesLine.VALIDATE("Line Discount %");
                ToSalesLine.VALIDATE("Inv. Discount Amount", InvDiscountAmount);
            end;
        end;
        ToSalesLine.VALIDATE("Currency Code", FromSalesHeader."Currency Code");

        UpdateSalesLine(
          ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine,
          CopyThisLine, RecalculateAmount, FromSalesDocType, CopyPostedDeferralP);
        ToSalesLine.CheckLocationOnWMS();

        if ExactCostRevMandatory and
           (FromSalesLine.Type = FromSalesLine.Type::Item) and
           (FromSalesLine."Appl.-from Item Entry" <> 0) and
           not MoveNegLines
        then begin
            if RecalculateAmount then begin
                ToSalesLine.VALIDATE("Unit Price", FromSalesLine."Unit Price");
                ToSalesLine.VALIDATE("Line Discount %", FromSalesLine."Line Discount %");
                ToSalesLine.VALIDATE(
                  "Line Discount Amount",
                  ROUND(FromSalesLine."Line Discount Amount", Currency."Amount Rounding Precision"));
                ToSalesLine.VALIDATE(
                  "Inv. Discount Amount",
                  ROUND(FromSalesLine."Inv. Discount Amount", Currency."Amount Rounding Precision"));
            end;
            ToSalesLine.VALIDATE("Appl.-from Item Entry", FromSalesLine."Appl.-from Item Entry");
            if not CreateToHeader then
                if ToSalesLine."Shipment Date" = 0D then
                    InitShipmentDateInLine(ToSalesHeader, ToSalesLine);
        end;

        if MoveNegLines and (ToSalesLine.Type <> ToSalesLine.Type::" ") then begin
            ToSalesLine.VALIDATE(Quantity, -FromSalesLine.Quantity);
            ToSalesLine.VALIDATE("Unit Price", FromSalesLine."Unit Price");
            ToSalesLine.VALIDATE("Line Discount %", FromSalesLine."Line Discount %");
            ToSalesLine."Appl.-to Item Entry" := FromSalesLine."Appl.-to Item Entry";
            ToSalesLine."Appl.-from Item Entry" := FromSalesLine."Appl.-from Item Entry";
            ToSalesLine."Job No." := FromSalesLine."Job No.";
            ToSalesLine."Job Task No." := FromSalesLine."Job Task No.";
            ToSalesLine."Job Contract Entry No." := FromSalesLine."Job Contract Entry No.";
        end;

        if CopyJobData then
            CopySalesJobFields(ToSalesLine, ToSalesHeader, FromSalesLine);

        CopySalesLineExtText(ToSalesHeader, ToSalesLine, FromSalesHeader, FromSalesLine, DocLineNo, NextLineNo);

        if not RecalculateLines then begin
            ToSalesLine."Dimension Set ID" := FromSalesLine."Dimension Set ID";
            ToSalesLine."Shortcut Dimension 1 Code" := FromSalesLine."Shortcut Dimension 1 Code";
            ToSalesLine."Shortcut Dimension 2 Code" := FromSalesLine."Shortcut Dimension 2 Code";
            OnCopySalesLineOnAfterSetDimensions(ToSalesLine, FromSalesLine);
        end;

        if CopyThisLine then begin
            OnBeforeInsertToSalesLine(
              ToSalesLine, FromSalesLine, FromSalesDocType, RecalculateLines, ToSalesHeader, DocLineNo, NextLineNo);
            ToSalesLine.INSERT();

            //>>BC6 SBE 27/01/2022
            //BC6 011019
            SalesCommentLine.RESET();
            SalesCommentLine.SETRANGE("Document Type", FromSalesLine."Document Type");
            SalesCommentLine.SETRANGE("No.", FromSalesLine."Document No.");
            SalesCommentLine.SETRANGE("Document Line No.", FromSalesLine."Line No.");
            if SalesCommentLine.FINDSET() then
                repeat
                    SalesCommentLine2.INIT();
                    SalesCommentLine2.TRANSFERFIELDS(SalesCommentLine);
                    SalesCommentLine2."No." := ToSalesHeader."No.";
                    SalesCommentLine2.INSERT(true);
                until SalesCommentLine.NEXT() = 0;
            //<<BC6 SBE 27/01/2022

            //>>BC6 MB 01/07/2021
            if CopyThisLine then
                if FromSalesLine.Quantity <> 0 then begin
                    FromSalesLine.VALIDATE(Quantity, FromSalesLine2."Quantity Shipped");
                    FromSalesLine.VALIDATE("Unit Price", FromSalesLine2."Unit Price");
                    FromSalesLine.VALIDATE(FromSalesLine."Line Discount %", FromSalesLine2."Line Discount %");
                    FromSalesLine.MODIFY();
                end;
            //<<BC6

            HandleAsmAttachedToSalesLine(ToSalesLine);
            if ToSalesLine.Reserve = ToSalesLine.Reserve::Always then
                ToSalesLine.AutoReserve();
            OnAfterInsertToSalesLine(ToSalesLine, FromSalesLine, RecalculateLines);
        end else
            LinesNotCopied := LinesNotCopied + 1;

        exit(CopyThisLine);
    end;
}

