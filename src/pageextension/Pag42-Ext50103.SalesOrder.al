namespace BCSYS.Jura;

using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;

pageextension 50103 "Sales Order" extends "Sales Order" //42
{
    layout
    {
        addafter(WorkDescription)
        {
            field("BC6_Print Serial No."; Rec."Print Serial No.")
            {
                ApplicationArea = all;
            }
            field("BC6 ID Import"; Rec."BC6 ID Import")
            {
                ApplicationArea = All;
            }
        }
        addafter("Salesperson Code")
        {
            field("BC6_BC6 PreEDI"; Rec."BC6 PreEDI")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("BC6_Order Status"; Rec."Order Status")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }
    actions
    {
        addlast(Action21)
        {
            action("BC6_EDI Schneider")
            {
                ApplicationArea = All;
                Caption = 'EDI Schneider', Comment = 'FRA="EDI Schneider"';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Category5;

                trigger OnAction()
                var
                    RecLSalesHeader: Record "Sales Header";
                    RecLSalesReceivablesSetup: Record "Sales & Receivables Setup";
                    CduUpdateSalesOrderStatus: Codeunit "Update Sales Order Status";
                begin
                    RecLSalesReceivablesSetup.GET();
                    if RecLSalesReceivablesSetup."Enable SO Status" then begin
                        if Rec."Order Status" = Rec."Order Status"::"Not verified" then begin
                            CduUpdateSalesOrderStatus.UpdateOrderStatus(Rec);
                            COMMIT();
                        end;
                        Rec.CheckBeforeSchneiderSend();
                    end;
                    RecLSalesHeader.RESET();
                    RecLSalesHeader.GET(Rec."Document Type", Rec."No.");
                    RecLSalesHeader.SETRECFILTER();
                    REPORT.RUN(REPORT::"BC6 Export LS Schneider Pre", false, false, RecLSalesHeader);
                end;
            }
            action(BC6_DupliquerCommande)
            {
                ApplicationArea = All;
                Caption = 'Duplicate Order', Comment = 'FRA="Dupliquer Commande"';
                Image = CopyCostBudget;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = false;

                trigger OnAction()
                var
                    RecLSalesHeader: Record "Sales Header";
                    RecLSalesLine: Record "Sales Line";
                    DuplicateMsg: Label '%1 has been transfered on %2 ''%3'' successfuly.', Comment = 'FRA="%1 ont été transférées sur %2 ''%3'' avec succès."';
                begin
                    RecLSalesHeader.SETRANGE("Document Type", Rec."Document Type");
                    RecLSalesHeader.SETRANGE("No.", Rec."No.");
                    REPORT.RUN(REPORT::"BC6 Duplicate Sales Order", false, false, RecLSalesHeader);
                    COMMIT();

                    if (STRPOS(Rec."No.", '/') < STRLEN(Rec."No.")) and (STRPOS(Rec."No.", '/') <> 0) then
                        RecLSalesHeader.SETRANGE("No.", INCSTR(Rec."No."))
                    else
                        RecLSalesHeader.SETRANGE("No.", STRSUBSTNO('%1/%2', Rec."No.", 1));
                    RecLSalesHeader.FINDLAST();
                    Rec := RecLSalesHeader;
                    CurrPage.UPDATE(false);
                    MESSAGE(DuplicateMsg, RecLSalesLine.FIELDCAPTION("Outstanding Quantity"), Rec.TABLECAPTION, Rec."No.");
                end;
            }
        }
    }
}
