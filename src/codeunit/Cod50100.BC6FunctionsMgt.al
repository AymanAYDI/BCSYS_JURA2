namespace BCSYS.Jura;

using Microsoft.Foundation.Reporting;
using System.Utilities;
using System.Device;
using System.Integration;
using System.IO;
using System.Reflection;
using System.Text;
codeunit 50100 "BC6 Functions Mgt."
{
    procedure FctCalcInTransitServiceReceipt(): Integer
    var
        RecLServiceReceipt: Record "JWS Service Receipt";
    begin
        RecLServiceReceipt.RESET();
        RecLServiceReceipt.SETRANGE(Status, RecLServiceReceipt.Status::Released);
        exit(RecLServiceReceipt.COUNT);
    end;

    procedure FctDrillInTransitServiceReceipt()
    var
        RecLServiceReceipt: Record "JWS Service Receipt";
    begin
        RecLServiceReceipt.RESET();
        RecLServiceReceipt.SETRANGE(Status, RecLServiceReceipt.Status::Released);
        RecLServiceReceipt.SETCURRENTKEY("No.");
        PAGE.RUN(0, RecLServiceReceipt);
    end;

    procedure FctCalcUnderReparSingentServiceOrder(): Integer
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE(Plant, RecLServiceOrder.Plant::Singen);
        RecLServiceOrder.SETFILTER(Status, '<>%1', RecLServiceOrder.Status::Closed);
        exit(RecLServiceOrder.COUNT);
    end;

    procedure FctDrillUnderReparSingentServiceOrder()
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE(Plant, RecLServiceOrder.Plant::Singen);
        RecLServiceOrder.SETFILTER(Status, '<>%1', RecLServiceOrder.Status::Closed);
        PAGE.RUN(0, RecLServiceOrder);
    end;

    procedure FctCalcLocalReparSingentServiceOrder(): Integer
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE(Plant, RecLServiceOrder.Plant::"local");
        RecLServiceOrder.SETFILTER(Status, '<>%1', RecLServiceOrder.Status::Closed);
        exit(RecLServiceOrder.COUNT);
    end;

    procedure FctDrillLocalReparSingentServiceOrder()
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE(Plant, RecLServiceOrder.Plant::"local");
        RecLServiceOrder.SETFILTER(Status, '<>%1', RecLServiceOrder.Status::Closed);
        PAGE.RUN(0, RecLServiceOrder);
    end;

    procedure FctCalcBoulangerServiceOrder(): Integer
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE("Sell-to Customer No.", '11057');
        RecLServiceOrder.SETFILTER(Status, '<>%1', RecLServiceOrder.Status::Closed);
        exit(RecLServiceOrder.COUNT);
    end;

    procedure FctDrillBoulangerServiceOrder()
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE("Sell-to Customer No.", '11057');
        RecLServiceOrder.SETFILTER(Status, '<>%1', RecLServiceOrder.Status::Closed);
        PAGE.RUN(0, RecLServiceOrder);
    end;

    procedure FctCalcJURAStatutServiceOrder(): Integer
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE(Plant, RecLServiceOrder.Plant::Singen);
        RecLServiceOrder.SETRANGE(Status, RecLServiceOrder.Status::Jura);
        exit(RecLServiceOrder.COUNT);
    end;

    procedure FctDrillJURAStatutServiceOrder()
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE(Plant, RecLServiceOrder.Plant::Singen);
        RecLServiceOrder.SETRANGE(Status, RecLServiceOrder.Status::Jura);
        PAGE.RUN(0, RecLServiceOrder);
    end;

    procedure FctCalcSafePrayToPost(): Integer
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE(Plant, RecLServiceOrder.Plant::Singen);
        RecLServiceOrder.SETRANGE(Status, RecLServiceOrder.Status::Closed);
        exit(RecLServiceOrder.COUNT);
    end;

    procedure FctDrillSafePrayToPost()
    var
        RecLServiceOrder: Record "JWS Service Order";
    begin
        RecLServiceOrder.RESET();
        RecLServiceOrder.SETRANGE(Plant, RecLServiceOrder.Plant::Singen);
        RecLServiceOrder.SETRANGE(Status, RecLServiceOrder.Status::Closed);
        //BCSYS 31072024
        RecLServiceOrder.SETRANGE("Service Payment Status", RecLServiceOrder."Service Payment Status"::Prepaid);
        PAGE.RUN(0, RecLServiceOrder);
    end;
}
