namespace BCSYS.Jura;

using System.Security.User;
codeunit 50104 "Start Internal Repair"
{

    trigger OnRun()
    var
        ServiceReceipt: Record "JWS Service Receipt";
        JuraSetup: Record "JWS JURA Service Setup";
        UserSetup: Record "User Setup";
        AnimationNo: Record "JWS Animation No.";
        ServiceMgt: Codeunit "JWS Service Functions";
    begin
        JuraSetup.GET();
        JuraSetup.TESTFIELD("Internal Repair Acc. No.");

        ServiceReceipt.INIT();
        ServiceReceipt.INSERT(true);

        ServiceReceipt.VALIDATE("Sell-to Customer No.", JuraSetup."Internal Repair Acc. No.");
        ServiceReceipt.VALIDATE("To Do (order)", ServiceReceipt."To Do (order)"::"Cost estimate");
        ServiceReceipt.MODIFY();
        COMMIT();

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
            ServiceMgt.ImportIncDiagnoseJSON2(ServiceReceipt);
        end;
    end;

    var
        Text001: Label 'Unsupported action';
}

