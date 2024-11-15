namespace BCSYS.Jura;

using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
tableextension 50113 "JWS JURA Services Cue" extends "JWS JURA Services Cue" //81029
{
    fields
    {
        field(50100; "BC6 In-Transit"; Integer)
        {
            Caption = 'In-Transit', Comment = 'FRA="En Transit"';
        }
        field(50101; "BC6 Boulanger"; Integer)
        {
            Caption = 'Boulanger', Comment = 'FRA="Boulanger en cours"';
        }
        field(50102; "BC6 Status JURA"; Integer)
        {
            Caption = 'Status JURA';
        }
        field(50103; "BC6 Under-Reparation Singen"; Integer)
        {
            Caption = 'Under-Reparation Singen', Comment = 'FRA="En réparation Singen"';
        }
        field(50104; "BC6 Local Singen Reparation"; Integer)
        {
            Caption = 'Local Singen Reparation', Comment = 'FRA="En réparation Local"';
        }
        field(50105; "BC6 SafePray to Post"; Integer)
        {
            Caption = 'SafePray to Post', Comment = 'FRA="SafePray à valider"';
        }
        field(50106; "Service Orders - Ediag New"; Integer)
        {
            CalcFormula = count("JWS Service Order" where(Status = const(Jura),
                                                       "CE Location Code" = const('EDIAGNEU')));
            Caption = 'Service Orders - EDIAGNEU';
            FieldClass = FlowField;
        }
        field(50107; "Service Orders - Ediag Finish"; Integer)
        {
            CalcFormula = count("JWS Service Order" where(Status = const(Jura),
                                                       "CE Location Code" = const('EDIAGERL')));
            Caption = 'Service Orders - EDIAGERL';
            FieldClass = FlowField;
        }
        field(50108; "BC6 - Customer"; Integer)
        {
            CalcFormula = count(Customer);
            Caption = 'Customer', Comment = 'FRA="Clients"';
            FieldClass = FlowField;
        }
        field(50109; "BC6 - Items"; Integer)
        {
            CalcFormula = count(Item);
            Caption = 'Items', Comment = 'FRA="Articles"';
            FieldClass = FlowField;
        }
        field(50110; "BC6 - Sales Quotes"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = const(Quote)));
            Caption = 'Sales Quotes', Comment = 'FRA="Devis"';
            FieldClass = FlowField;
        }
        field(50111; "BC6 - Posted Sales Invoices"; Integer)
        {
            CalcFormula = count("Sales Invoice Header");
            Caption = 'Posted Sales Invoices', Comment = 'FRA="Factures vente enregistrés"';
            FieldClass = FlowField;
        }
        field(50112; "BC6 - Posted Sales Cr Memo"; Integer)
        {
            CalcFormula = count("Sales Cr.Memo Header");
            Caption = 'Posted Sales Cr Memo', Comment = 'FRA="Avoirs vente enregistrés"';
            FieldClass = FlowField;
        }
        field(50113; "BC6 - Sales Invoices"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = const(Invoice)));
            Caption = 'Sales Invoices', Comment = 'FRA="Factures vente"';
            FieldClass = FlowField;
        }
        field(50114; "BC6 - Sales Cr Memo"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = const("Credit Memo")));
            Caption = 'Sales Cr Memo', Comment = 'FRA="Avoirs vente"';
            FieldClass = FlowField;
        }
        field(50115; "BC6 - Sales Orders"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = const(Order)));
            Caption = 'Sales Orders', Comment = 'FRA="Commandes vente"';
            FieldClass = FlowField;
        }

        field(50116; "Service Orders WA"; Integer)
        {
            CalcFormula = count("JWS Service Order" where(Status = filter(< Closed),
                                                       "CE Location Code" = filter('WA*'),
                                                       "Remove Machine" = const(true)));
            Caption = 'Service Orders';
            FieldClass = FlowField;
        }
        field(50117; "Service Orders - Jura Singen"; Integer)
        {
            CalcFormula = count("JWS Service Order" where(Status = const(Jura),
                                                       "RP Decided at" = const(),
                                                       Plant = const(Singen)));
            Caption = 'Service Orders - Jura Singen';
            FieldClass = FlowField;
        }
    }
}