namespace BCSYS.Jura;

pageextension 50115 "JWS JURA Serv. Role Center" extends "JWS JURA Serv. Role Center" //81038
{
    layout
    {
        modify(Control1907692008)
        {
            Visible = false;
        }
    }

    actions
    {
        addlast(processing)
        {
            action("Import Exit Diagnosis")
            {
                Caption = 'Import Exit Diagnosis';
                RunObject = Page "Import Exit Diagnosis";
                ApplicationArea = All;
            }
            action("Start Internal Repair")
            {
                Caption = 'Start Internal Repair';
                Image = ImportCodes;
                RunObject = Codeunit "Start Internal Repair";
                ApplicationArea = All;
            }
        }
    }
}