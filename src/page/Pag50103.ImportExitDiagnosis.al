namespace BCSYS.Jura;

using System.Security.User;
page 50103 "Import Exit Diagnosis"
{
    Permissions = TableData 91 = rm;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(ScanNo; ScanNo)
            {
                Caption = 'No.';

                trigger OnValidate()
                var
                    ServiceOrder: Record "JWS Service Order";
                    UserSetup: Record "User Setup";
                    JuraSetup: Record "JWS JURA Service Setup";
                    AnimationNo: Record "JWS Animation No.";
                    ServiceMgt: Codeunit "JWS Service Functions";
                // AnimationNos: Page "JWS Animation Nos";
                begin
                    if not ServiceOrder.GET(ScanNo) then
                        ERROR(Text002);

                    // Import Diagnosis
                    JuraSetup.GET();
                    if JuraSetup."Type Animation" = JuraSetup."Type Animation"::Client then
                        ERROR(Text001)
                    else begin
                        UserSetup.GET(USERID);
                        if UserSetup."JWS No. Animation" = '' then begin
                            AnimationNo.RESET();
                            if PAGE.RUNMODAL(81030, AnimationNo) = ACTION::LookupOK then begin
                                UserSetup."JWS No. Animation" := AnimationNo.Code;
                                UserSetup.MODIFY();
                            end;
                        end;
                        // Hide Confirm message
                        ServiceOrder."Hide Status Change Confirm" := true;
                        ServiceMgt.ImportOutDiagnoseJSON(ServiceOrder);
                        ServiceOrder."Hide Status Change Confirm" := false;
                        ServiceOrder.MODIFY();
                        COMMIT();
                        PAGE.RUNMODAL(PAGE::"JWS Jura Service Order", ServiceOrder);
                    end;

                    CurrPage.CLOSE();
                end;
            }
        }
    }

    var
        ScanNo: Code[20];
        Text001: Label 'Unsupported action';
        Text002: Label 'No matches found';
}

