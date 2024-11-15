namespace BCSYS.Jura;

using Microsoft.Foundation.Company;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Sales.History;
using Microsoft.Sales.Document;
using Microsoft.Foundation.NoSeries;
using System.Utilities;
using System.Integration;
using System.Xml;
using System.EMail;
using System.Text;
using System.IO;
codeunit 50103 "BC6 WS Partner Management"
{

    var
        CompanyInformation: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        WebservicePartner: Record "BC6 Webservice Partner";
        CountryRegion: Record "Country/Region";
        CurrColliQty: Integer;
        EnvNamespace: Label 'http://schemas.xmlsoap.org/soap/envelope/', comment = 'FRA="http://schemas.xmlsoap.org/soap/envelope/"';
        ShipNamespace: Label 'http://scxgxtt.phx-dc.dhl.com/euExpressRateBook/ShipmentMsgRequest', comment = 'FRA="http://scxgxtt.phx-dc.dhl.com/euExpressRateBook/ShipmentMsgRequest"';
        ShipperName: Label 'SAV JURA SAS', Comment = 'FRA="SAV JURA SAS"';
        ShipperName2: Label 'c/o Jura Elektrogeräte Vertriebs GmbH', Comment = 'FRA="c/o Jura Elektrogeräte Vertriebs GmbH"';
        ShipperStreetName: Label 'Otto-Hahn-Straße', Comment = 'FRA="Otto-Hahn-Straße"';
        ShipperStreetNo: Label '16-22', Comment = 'FRA="16-22"';
        ShipperPostCode: Label '78224', Comment = 'FRA="78224"';
        ShipperCity: Label 'Singen';
        ShipperCountry: Label 'DE', Comment = 'FRA="DE"';
        CurrColliEntryNo: Integer;
        PhoneNo: Text[50];
        ContentTXT: Text[30];


    procedure ConsumeMyDHLFromServiceReceipt(var ServiceReceipt: Record "JWS Service Receipt"; IsRetoure: Boolean)
    var
        SalesShipmentHeader2: Record "Sales Shipment Header";
    begin
        // Fill Information from Service Receipt
        SalesShipmentHeader2.INIT();
        SalesShipmentHeader2."No." := ServiceReceipt."No.";
        SalesShipmentHeader2."Shipment Date" := ServiceReceipt."Document Date";
        SalesShipmentHeader2."Ship-to Name" := ServiceReceipt."Ship-to Name";
        SalesShipmentHeader2."Ship-to Name 2" := ServiceReceipt."Ship-to Name 2";
        SalesShipmentHeader2."Ship-to Address" := ServiceReceipt."Ship-to Address";
        SalesShipmentHeader2."Ship-to Address 2" := ServiceReceipt."Ship-to Address 2";
        SalesShipmentHeader2."Ship-to Post Code" := ServiceReceipt."Ship-to Post Code";
        SalesShipmentHeader2."Ship-to City" := ServiceReceipt."Ship-to City";
        SalesShipmentHeader2."Ship-to Country/Region Code" := ServiceReceipt."Ship-to Country Code";
        SalesShipmentHeader2."Sell-to Contact" := ServiceReceipt."Ship-to Contact";
        SalesShipmentHeader2."BC6 No. of Shipment Labels" := ServiceReceipt."BC6 No. of Shipment Labels";
        SalesShipmentHeader2."Currency Code" := 'EUR';
        SalesShipmentHeader2."JWC Phone No." := CopyStr(ServiceReceipt."Sell-to Phone No.", 1, MaxStrLen(SalesShipmentHeader2."JWC Phone No."));
        PhoneNo := ServiceReceipt."Sell-to Phone No.";
        if IsRetoure then
            ConsumeMyDHLRetoureWebservice(2, SalesShipmentHeader2)
        else
            ConsumeMyDHLWebservice(2, SalesShipmentHeader2);
    end;


    procedure ConsumeMyDHLFromPostedSalesInv(var SalesInvoiceHeader: Record "Sales Invoice Header"; IsRetoure: Boolean)
    var
        SalesShipmentHeader2: Record "Sales Shipment Header";
    begin
        // Fill Information from Sales Invoice
        SalesShipmentHeader2.INIT();
        SalesShipmentHeader2."No." := SalesInvoiceHeader."No.";
        SalesShipmentHeader2."Shipment Date" := SalesInvoiceHeader."Shipment Date";
        SalesShipmentHeader2."Salesperson Code" := SalesInvoiceHeader."Salesperson Code";
        SalesShipmentHeader2."Ship-to Name" := SalesInvoiceHeader."Ship-to Name";
        SalesShipmentHeader2."Ship-to Name 2" := SalesInvoiceHeader."Ship-to Name 2";
        SalesShipmentHeader2."Ship-to Address" := SalesInvoiceHeader."Ship-to Address";
        SalesShipmentHeader2."Ship-to Address 2" := SalesInvoiceHeader."Ship-to Address 2";
        SalesShipmentHeader2."Ship-to Post Code" := SalesInvoiceHeader."Ship-to Post Code";
        SalesShipmentHeader2."Ship-to City" := SalesInvoiceHeader."Ship-to City";
        SalesShipmentHeader2."Ship-to Country/Region Code" := SalesInvoiceHeader."Ship-to Country/Region Code";
        SalesShipmentHeader2."Sell-to Contact" := SalesInvoiceHeader."Sell-to Contact";
        SalesShipmentHeader2."BC6 No. of Shipment Labels" := SalesInvoiceHeader."BC6 No. of Shipment Labels";
        SalesShipmentHeader2."Currency Code" := SalesInvoiceHeader."Currency Code";
        PhoneNo := SalesInvoiceHeader."Sell-to Phone No.";
        if PhoneNo = '' then
            PhoneNo := SalesInvoiceHeader."JWC Phone No.";
        if IsRetoure then
            ConsumeMyDHLRetoureWebservice(3, SalesShipmentHeader2)
        else
            ConsumeMyDHLWebservice(3, SalesShipmentHeader2);
    end;


    procedure ConsumeMyDHLFromSalesHeader(var SalesHeader: Record "Sales Header"; IsRetoure: Boolean)
    var
        SalesShipmentHeader2: Record "Sales Shipment Header";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        // Fill Information from Sales Header
        SalesShipmentHeader2.INIT();
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then begin
            if SalesHeader."Posting No." = '' then begin
                SalesHeader.TESTFIELD("Posting No. Series");
                SalesHeader."Posting No." := NoSeriesManagement.GetNextNo(SalesHeader."Posting No. Series", SalesHeader."Posting Date", true);
                SalesHeader.MODIFY();
            end;
            SalesShipmentHeader2."No." := SalesHeader."Posting No."
        end else begin
            if SalesHeader."Shipping No." = '' then begin
                SalesHeader.TESTFIELD("Shipping No. Series");
                SalesHeader."Shipping No." := NoSeriesManagement.GetNextNo(SalesHeader."Shipping No. Series", SalesHeader."Posting Date", true);
                SalesHeader.MODIFY();
            end;
            SalesShipmentHeader2."No." := SalesHeader."Shipping No.";
        end;
        SalesShipmentHeader2."Shipment Date" := SalesHeader."Shipment Date";
        SalesShipmentHeader2."Salesperson Code" := SalesHeader."Salesperson Code";
        SalesShipmentHeader2."Ship-to Name" := SalesHeader."Ship-to Name";
        SalesShipmentHeader2."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
        SalesShipmentHeader2."Ship-to Address" := SalesHeader."Ship-to Address";
        SalesShipmentHeader2."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
        SalesShipmentHeader2."Ship-to Post Code" := SalesHeader."Ship-to Post Code";
        SalesShipmentHeader2."Ship-to City" := SalesHeader."Ship-to City";
        SalesShipmentHeader2."Ship-to Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
        SalesShipmentHeader2."Sell-to Contact" := SalesHeader."Sell-to Contact";
        SalesShipmentHeader2."BC6 No. of Shipment Labels" := SalesHeader."BC6 No. of Shipment Labels";
        SalesShipmentHeader2."Currency Code" := SalesHeader."Currency Code";
        PhoneNo := SalesHeader."Sell-to Phone No.";
        if PhoneNo = '' then
            PhoneNo := SalesHeader."JWC Phone No.";
        if IsRetoure then
            ConsumeMyDHLRetoureWebservice(1, SalesShipmentHeader2)
        else
            ConsumeMyDHLWebservice(1, SalesShipmentHeader2);
    end;


    procedure ConsumeMyDHLRetoureWebservice(RecordType: Option "Sales Shipment Header","Sales Header","Service Receipt","Sales Invoice Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    var
        TempBLOB: Codeunit "Temp Blob";
        ResponseInStreamTempBlob: Codeunit "Temp Blob";
        HttpWebRequest: Codeunit "Http Web Request Mgt.";
        XMLDOMManagement: Codeunit "XML DOM Management";
        SoapEnvNode: DotNet XmlNode;
        HeaderNode: DotNet XmlNode;
        NewBodyXMLNode: DotNet XmlNode;
        NewBodyXMLNode2: DotNet XmlNode;
        NewBodyXMLNode3: DotNet XmlNode;
        NewBodyRootXMLNode: DotNet XmlNode;
        NewBodyXMLNode4: DotNet XmlNode;
        NewBodyXMLNode5: DotNet XmlNode;
        NewBodyXMLNode6: DotNet XmlNode;
        NewbodyXMLNode7: DotNet XmlNode;
        Instr: InStream;
        ReqXMLDoc: DotNet XmlDocument;
        RespXMLDoc: DotNet XmlDocument;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
        outstr: OutStream;
        soapFile: File;
        DotLXMLNodeType: DotNet XmlNodeType;
    begin
        CompanyInformation.GET();
        GLSetup.GET();

        // Webservice Partner (eigene Tabelle)
        WebservicePartner.GET(WebservicePartner."No."::MyDHL);

        if SalesShipmentHeader."BC6 No. of Shipment Labels" = 0 then
            SalesShipmentHeader."BC6 No. of Shipment Labels" := 1;
        CurrColliQty := SalesShipmentHeader."BC6 No. of Shipment Labels";

        // Envelope erstellen
        CLEAR(ReqXMLDoc);
        ReqXMLDoc := ReqXMLDoc.XmlDocument();

        // SoapEnv erstellen
        SoapEnvNode := ReqXMLDoc.CreateNode(DotLXMLNodeType.Element, 'soapenv:Envelope', EnvNamespace);
        ReqXMLDoc.AppendChild(SoapEnvNode);

        XMLDOMManagement.AddElement(SoapEnvNode, 'soapenv:Header', '', EnvNamespace, HeaderNode);
        XMLDOMManagement.AddElement(HeaderNode, 'wsse:Security', '', 'http://schemas.xmlsoap.org/ws/2003/06/secext', NewBodyXMLNode);
        XMLDOMManagement.AddElement(NewBodyXMLNode, 'wsse:UsernameToken', '',
                                    'http://schemas.xmlsoap.org/ws/2003/06/secext', NewBodyXMLNode2);
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'wsse:Username', WebservicePartner."Login Name", 'http://schemas.xmlsoap.org/ws/2003/06/secext', NewBodyXMLNode3);
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'wsse:Password', WebservicePartner.Password,
                                    'http://schemas.xmlsoap.org/ws/2003/06/secext', NewBodyXMLNode3);

        XMLDOMManagement.AddElement(SoapEnvNode, 'soapenv:Body', '', EnvNamespace, NewBodyRootXMLNode);
        XMLDOMManagement.AddElement(NewBodyRootXMLNode, 'ship:ShipmentRequest', '', ShipNamespace, NewBodyXMLNode);
        XMLDOMManagement.AddElement(NewBodyXMLNode, 'RequestedShipment', '', '', NewBodyXMLNode2);
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'ShipmentInfo', '', '', NewBodyXMLNode3);

        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'DropOffType', 'REGULAR_PICKUP', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'ServiceType', 'W', '', NewBodyXMLNode4);

        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Billing', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'ShipperAccountNumber', WebservicePartner."Our Import Customer No.", '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'ShippingPaymentType', 'S', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'BillingAccountNumber', WebservicePartner."Our Import Customer No.", '', NewBodyXMLNode5);

        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'SpecialServices', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Service', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'ServiceType', 'PT', '', NewBodyXMLNode6);

        if SalesShipmentHeader."Currency Code" = '' then
            SalesShipmentHeader."Currency Code" := GLSetup."LCY Code";
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Currency', SalesShipmentHeader."Currency Code", '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'UnitOfMeasurement', 'SI', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'LabelType', 'PDF', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'ShipmentReferences', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'ShipmentReference', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'ShipmentReference', SalesShipmentHeader."No.", '', NewBodyXMLNode6);

        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'ShipTimestamp', GetCurrTimestampWithOffset(), '', NewBodyXMLNode3);
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'PaymentInfo', 'DAP', '', NewBodyXMLNode3);

        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'InternationalDetail', '', '', NewBodyXMLNode3);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Commodities', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Description', 'Coffee Machine', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Content', 'DOCUMENTS', '', NewBodyXMLNode4);

        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'Ship', '', '', NewBodyXMLNode3);

        // Shipper
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Shipper', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Contact', '', '', NewBodyXMLNode5);
        if SalesShipmentHeader."Sell-to Contact" <> '' then
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PersonName', SalesShipmentHeader."Sell-to Contact", '', NewBodyXMLNode6)
        else
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PersonName', SalesShipmentHeader."Ship-to Name", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'CompanyName', SalesShipmentHeader."Ship-to Name", '', NewBodyXMLNode6);

        if PhoneNo = '' then
            PhoneNo := CompanyInformation."Phone No.";
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PhoneNumber', PhoneNo, '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Address', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'StreetLines', SalesShipmentHeader."Ship-to Address", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'City', SalesShipmentHeader."Ship-to City", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PostalCode', SalesShipmentHeader."Ship-to Post Code", '', NewBodyXMLNode6);
        if not CountryRegion.GET(SalesShipmentHeader."Ship-to Country/Region Code") then begin
            CountryRegion.INIT();
            CountryRegion.Code := 'FR';
            CountryRegion.Name := 'France';
        end;
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'CountryCode', CountryRegion.Code, '', NewBodyXMLNode6);

        // Recipient
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Recipient', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Contact', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PersonName', WebservicePartner."Responsible Service Receipt", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'CompanyName', STRSUBSTNO('%1 %2', ShipperName, ShipperName2), '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PhoneNumber', CompanyInformation."Phone No.", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Address', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'StreetLines', STRSUBSTNO('%1 %2', ShipperStreetName, ShipperStreetNo),
                                    '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'StreetName', ShipperStreetName, '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'StreetNumber', ShipperStreetNo, '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'City', ShipperCity, '', NewbodyXMLNode7);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PostalCode', ShipperPostCode, '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'CountryCode', ShipperCountry, '', NewBodyXMLNode6);

        // Packages
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'Packages', '', '', NewBodyXMLNode3);
        CLEAR(CurrColliEntryNo);
        repeat
            CurrColliEntryNo += 1;
            XMLDOMManagement.AddElement(NewBodyXMLNode3, 'RequestedPackages', '', '', NewBodyXMLNode4);
            XMLDOMManagement.AddAttribute(NewBodyXMLNode4, 'number', FORMAT(CurrColliEntryNo, 0, 9));
            if WebservicePartner."Package Weight" <> 0 then
                XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Weight', FORMAT(WebservicePartner."Package Weight", 0, 9), '', NewBodyXMLNode5)
            else
                XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Weight', FORMAT(1, 0, 9), '', NewBodyXMLNode5);
            XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Dimensions', '', '', NewBodyXMLNode5);
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'Length', FORMAT(WebservicePartner."Package Length", 0, 9), '', NewBodyXMLNode6);
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'Width', FORMAT(WebservicePartner."Package Width", 0, 9), '', NewBodyXMLNode6);
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'Height', FORMAT(WebservicePartner."Package Height", 0, 9), '', NewBodyXMLNode6);
            CurrColliQty := CurrColliQty - 1;
        until CurrColliQty <= 0;

        // ResponseInStreamTempBlob.INIT();
        ResponseInStreamTempBlob.CREATEOUTSTREAM(outstr);
        ReqXMLDoc.Save(outstr);

        // XMLDOMManagement.SaveXMLDocumentToOutStream(outstr, SoapEnvNode);
        // soapFile.Create('C:\soapmessage.txt');
        // soapFile.CreateOutStream(outstr);
        // ReqXMLDoc.Save(outstr);
        // soapFile.Close();
        // exit;

        // TempBLOB.INIT();
        TempBLOB.CREATEINSTREAM(Instr);

        CLEAR(HttpWebRequest);
        HttpWebRequest.Initialize(WebservicePartner.URL);
        HttpWebRequest.DisableUI();
        HttpWebRequest.AddHeader('Password-Type', 'PasswordText');
        HttpWebRequest.SetMethod('POST');
        HttpWebRequest.SetContentType('application/xml;charset=UTF-8');
        HttpWebRequest.SetReturnType('application/xml');
        HttpWebRequest.AddBodyBlob(ResponseInStreamTempBlob);

        HttpWebRequest.GetResponse(Instr, HttpStatusCode, ResponseHeaders);

        // ResponseInStreamTempBlob.INIT();
        ResponseInStreamTempBlob.CREATEOUTSTREAM(outstr);

        RespXMLDoc := RespXMLDoc.XmlDocument();
        RespXMLDoc.Load(Instr);

        COPYSTREAM(outstr, Instr);
        soapFile.CREATE('C:\Respsoapmessage.txt');
        soapFile.CREATEOUTSTREAM(outstr);
        RespXMLDoc.Save(outstr);
        soapFile.CLOSE();

        SaveMyDHLWebserviceResult(RespXMLDoc, SalesShipmentHeader, true);
    end;


    procedure ConsumeMyDHLWebservice(RecordType: Option "Sales Shipment Header","Sales Header","Service Receipt","Sales Invoice Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    var
        TempBLOB: Codeunit "Temp Blob";
        HttpWebRequest: Codeunit "Http Web Request Mgt.";
        ResponseInStreamTempBlob: Codeunit "Temp Blob";
        XMLDOMManagement: Codeunit "XML DOM Management";
        SoapEnvNode: DotNet XmlNode;
        HeaderNode: DotNet XmlNode;
        NewBodyXMLNode: DotNet XmlNode;
        NewBodyXMLNode2: DotNet XmlNode;
        NewBodyXMLNode3: DotNet XmlNode;
        NewBodyRootXMLNode: DotNet XmlNode;
        NewBodyXMLNode4: DotNet XmlNode;
        NewBodyXMLNode5: DotNet XmlNode;
        NewBodyXMLNode6: DotNet XmlNode;
        NewbodyXMLNode7: DotNet XmlNode;
        Instr: InStream;
        ReqXMLDoc: DotNet XmlDocument;
        RespXMLDoc: DotNet XmlDocument;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
        outstr: OutStream;
        DotLXMLNodeType: DotNet XmlNodeType;
    begin
        CompanyInformation.GET();
        GLSetup.GET();

        // Webservice Partner (eigene Tabelle)
        WebservicePartner.GET(WebservicePartner."No."::MyDHL);

        if SalesShipmentHeader."BC6 No. of Shipment Labels" = 0 then
            SalesShipmentHeader."BC6 No. of Shipment Labels" := 1;
        CurrColliQty := SalesShipmentHeader."BC6 No. of Shipment Labels";

        // Envelope erstellen
        CLEAR(ReqXMLDoc);
        ReqXMLDoc := ReqXMLDoc.XmlDocument();

        // SoapEnv erstellen
        SoapEnvNode := ReqXMLDoc.CreateNode(DotLXMLNodeType.Element, 'soapenv:Envelope', EnvNamespace);
        ReqXMLDoc.AppendChild(SoapEnvNode);

        XMLDOMManagement.AddElement(SoapEnvNode, 'soapenv:Header', '', EnvNamespace, HeaderNode);
        XMLDOMManagement.AddElement(HeaderNode, 'wsse:Security', '', 'http://schemas.xmlsoap.org/ws/2003/06/secext', NewBodyXMLNode);
        XMLDOMManagement.AddElement(NewBodyXMLNode, 'wsse:UsernameToken', '',
                                    'http://schemas.xmlsoap.org/ws/2003/06/secext', NewBodyXMLNode2);
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'wsse:Username', WebservicePartner."Login Name",
                                    'http://schemas.xmlsoap.org/ws/2003/06/secext', NewBodyXMLNode3);
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'wsse:Password', WebservicePartner.Password,
                                    'http://schemas.xmlsoap.org/ws/2003/06/secext', NewBodyXMLNode3);

        XMLDOMManagement.AddElement(SoapEnvNode, 'soapenv:Body', '', EnvNamespace, NewBodyRootXMLNode);
        XMLDOMManagement.AddElement(NewBodyRootXMLNode, 'ship:ShipmentRequest', '', ShipNamespace, NewBodyXMLNode);
        XMLDOMManagement.AddElement(NewBodyXMLNode, 'RequestedShipment', '', '', NewBodyXMLNode2);
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'ShipmentInfo', '', '', NewBodyXMLNode3);

        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'DropOffType', 'REGULAR_PICKUP', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'ServiceType', 'W', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Account', WebservicePartner."Our Customer No.", '', NewBodyXMLNode4);
        if SalesShipmentHeader."Currency Code" = '' then
            SalesShipmentHeader."Currency Code" := GLSetup."LCY Code";
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Currency', SalesShipmentHeader."Currency Code", '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'UnitOfMeasurement', 'SI', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'LabelType', 'PDF', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'ShipmentReferences', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'ShipmentReference', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'ShipmentReference', SalesShipmentHeader."No.", '', NewBodyXMLNode6);

        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'ShipTimestamp', GetCurrTimestampWithOffset(), '', NewBodyXMLNode3);
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'PaymentInfo', 'DAP', '', NewBodyXMLNode3);

        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'InternationalDetail', '', '', NewBodyXMLNode3);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Commodities', '', '', NewBodyXMLNode4);
        // -CS001
        if STRPOS(SalesShipmentHeader."No.", 'GR') > 0 then
            ContentTXT := 'empty box for Coffee Machine'
        else
            ContentTXT := 'Coffee Machine';

        // +CS001
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Description', ContentTXT, '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Content', 'DOCUMENTS', '', NewBodyXMLNode4);

        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'Ship', '', '', NewBodyXMLNode3);

        // Shipper
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Shipper', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Contact', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PersonName', WebservicePartner."Responsible Service Receipt", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'CompanyName', STRSUBSTNO('%1 %2', ShipperName, ShipperName2), '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PhoneNumber', CompanyInformation."Phone No.", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Address', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'StreetLines', STRSUBSTNO('%1 %2', ShipperStreetName, ShipperStreetNo),
                                    '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'StreetName', ShipperStreetName, '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'StreetNumber', ShipperStreetNo, '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'City', ShipperCity, '', NewbodyXMLNode7);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PostalCode', ShipperPostCode, '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'CountryCode', ShipperCountry, '', NewBodyXMLNode6);

        // Recipient
        XMLDOMManagement.AddElement(NewBodyXMLNode3, 'Recipient', '', '', NewBodyXMLNode4);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Contact', '', '', NewBodyXMLNode5);
        if SalesShipmentHeader."Sell-to Contact" <> '' then
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PersonName', SalesShipmentHeader."Sell-to Contact", '', NewBodyXMLNode6)
        else
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PersonName', SalesShipmentHeader."Ship-to Name", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'CompanyName', SalesShipmentHeader."Ship-to Name", '', NewBodyXMLNode6);

        if PhoneNo = '' then
            PhoneNo := CompanyInformation."Phone No.";
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PhoneNumber', PhoneNo, '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Address', '', '', NewBodyXMLNode5);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'StreetLines', SalesShipmentHeader."Ship-to Address", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'City', SalesShipmentHeader."Ship-to City", '', NewBodyXMLNode6);
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'PostalCode', SalesShipmentHeader."Ship-to Post Code", '', NewBodyXMLNode6);
        if not CountryRegion.GET(SalesShipmentHeader."Ship-to Country/Region Code") then begin
            CountryRegion.INIT();
            CountryRegion.Code := 'FR';
            CountryRegion.Name := 'France';
        end;
        XMLDOMManagement.AddElement(NewBodyXMLNode5, 'CountryCode', CountryRegion.Code, '', NewBodyXMLNode6);

        // Packages
        XMLDOMManagement.AddElement(NewBodyXMLNode2, 'Packages', '', '', NewBodyXMLNode3);
        CLEAR(CurrColliEntryNo);
        repeat
            CurrColliEntryNo += 1;
            XMLDOMManagement.AddElement(NewBodyXMLNode3, 'RequestedPackages', '', '', NewBodyXMLNode4);
            XMLDOMManagement.AddAttribute(NewBodyXMLNode4, 'number', FORMAT(CurrColliEntryNo, 0, 9));
            if WebservicePartner."Package Weight" <> 0 then
                XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Weight', FORMAT(WebservicePartner."Package Weight", 0, 9), '', NewBodyXMLNode5)
            else
                XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Weight', FORMAT(1, 0, 9), '', NewBodyXMLNode5);
            XMLDOMManagement.AddElement(NewBodyXMLNode4, 'Dimensions', '', '', NewBodyXMLNode5);
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'Length', FORMAT(WebservicePartner."Package Length", 0, 9), '', NewBodyXMLNode6);
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'Width', FORMAT(WebservicePartner."Package Width", 0, 9), '', NewBodyXMLNode6);
            XMLDOMManagement.AddElement(NewBodyXMLNode5, 'Height', FORMAT(WebservicePartner."Package Height", 0, 9), '', NewBodyXMLNode6);
            CurrColliQty := CurrColliQty - 1;
        until CurrColliQty <= 0;

        // ResponseInStreamTempBlob.INIT();
        ResponseInStreamTempBlob.CREATEOUTSTREAM(outstr);
        ReqXMLDoc.Save(outstr);

        // TempBLOB.INIT();
        TempBLOB.CREATEINSTREAM(Instr);

        CLEAR(HttpWebRequest);
        HttpWebRequest.Initialize(WebservicePartner.URL);
        HttpWebRequest.DisableUI();
        HttpWebRequest.AddHeader('Password-Type', 'PasswordText');
        HttpWebRequest.SetMethod('POST');
        HttpWebRequest.SetContentType('application/xml;charset=UTF-8');
        HttpWebRequest.SetReturnType('application/xml');
        HttpWebRequest.AddBodyBlob(ResponseInStreamTempBlob);

        //>>BC6 SBE 06/04/2022
        //ResponseInStreamTempBlob.Blob.EXPORT('C:\Users\sbe\Documents\messagesoap.txt');
        //<<BC6 SBE 06/04/2022

        HttpWebRequest.GetResponse(Instr, HttpStatusCode, ResponseHeaders);

        // ResponseInStreamTempBlob.INIT();
        ResponseInStreamTempBlob.CREATEOUTSTREAM(outstr);

        RespXMLDoc := RespXMLDoc.XmlDocument();
        RespXMLDoc.Load(Instr);

        //>>BC6 SBE 06/04/2022
        // COPYSTREAM(outstr,Instr);
        // ResponseInStreamTempBlob.Blob.EXPORT('C:\Users\sbe\Documents\Response.txt');
        //<<BC6 SBE 06/04/2022

        SaveMyDHLWebserviceResult(RespXMLDoc, SalesShipmentHeader, false);
    end;


    procedure SaveMyDHLWebserviceResult(var RespXmlDoc: DotNet XmlDocument; SalesShipmentHeader: Record "Sales Shipment Header"; IsRetoure: Boolean)
    var
        Paketschein: Record "JWC Packing Track No.";
        RecLEmailItem: Record "Email Item";
        PackingTrackNoToPrint: Record "JWC Packing Track No.";
        Base64Convert: Codeunit "Base64 Convert";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        PackageTrackingNo: Text[100];
        NextLineNo: Integer;
        OStream: OutStream;
        NoOfPackages: Integer;
        i: Integer;
        IStream: InStream;
        MaxTextLen: Integer;
        NodePos: Integer;
        NodeLength: Integer;
        MailSubject: Label '''Etiquette retour pour votre colis retour … JURA Elektrogeräte Vertriebs GmbH %1''';
        RespNode: DotNet XmlNode;
        RespNode2: DotNet XmlNode;
        RespNode2FirstChild: DotNet XmlNode;
        RespNode2Text: Text;
        NMS: DotNet XmlNamespaceManager;
    begin
        i := 1;
        CLEAR(PackageTrackingNo);
        RespNode := RespXmlDoc.DocumentElement;

        RespNode.Normalize();
        NMS := NMS.XmlNamespaceManager(RespNode.OwnerDocument.NameTable);
        NMS.AddNamespace('shipresp', 'http://scxgxtt.phx-dc.dhl.com/euExpressRateBook/ShipmentMsgResponse');

        // Shipping No. speichern
        NoOfPackages := SalesShipmentHeader."BC6 No. of Shipment Labels";
        while i <= NoOfPackages do begin
            RespNode2 := RespNode.SelectSingleNode('//shipresp:ShipmentResponse/PackagesResult/PackageResult[' + FORMAT(i) + ']/TrackingNumber', NMS);
            // Abfragen, ob Shipping No. vorhanden
            if ISNULL(RespNode2) then begin
                RespNode2 := RespNode.SelectSingleNode('//ShipmentResponse/Notification/Message');
                if ISNULL(RespNode2) then
                    ERROR(RespNode.Value())
                else
                    ERROR(RespNode2.Value());
            end;

            RespNode2FirstChild := RespNode2.FirstChild;
            PackageTrackingNo := RespNode2FirstChild.Value();

            // Shipment Label speichern
            RespNode2 := RespNode.SelectSingleNode('//shipresp:ShipmentResponse/LabelImage/GraphicImage', NMS);
            // Abfragen, ob Label vorhanden
            if ISNULL(RespNode2) then begin
                RespNode2 := RespNode.SelectSingleNode('//shipresp:ShipmentResponse/Notification/Message', NMS);
                if ISNULL(RespNode2) then
                    ERROR(RespNode.Value())
                else
                    ERROR(RespNode2.Value());
            end;

            // TempBlob2.RESET();
            // TempBlob2.DELETEALL();
            // TempBlob2.INIT();
            TempBlob2.CREATEOUTSTREAM(OStream);

            RespNode2FirstChild := RespNode2.FirstChild;
            RespNode2Text := RespNode2FirstChild.Value();

            NodePos := 1;
            NodeLength := STRLEN(RespNode2Text);
            MaxTextLen := 1024;
            while NodeLength > NodePos do begin
                OStream.WRITE(COPYSTR(RespNode2Text, NodePos, MaxTextLen));
                NodePos += MaxTextLen;
            end;
            TempBlob2.CREATEINSTREAM(IStream);

            // TempBlob.RESET();
            // TempBlob.DELETEALL();
            // TempBlob.INIT();
            TempBlob.CREATEOUTSTREAM(OStream);
            Base64Convert.FromBase64(RespNode2Text, OStream);

            NextLineNo := 10000;
            Paketschein.RESET();
            Paketschein.SETRANGE("Shipment No.", SalesShipmentHeader."No.");
            if Paketschein.FINDLAST() then
                NextLineNo := Paketschein."Line No." + 10000;

            Paketschein.INIT();
            Paketschein.VALIDATE("Shipment No.", SalesShipmentHeader."No.");
            Paketschein.VALIDATE("Line No.", NextLineNo);
            Paketschein.VALIDATE("Package Tracking No.", PackageTrackingNo);
            //Paketschein."BC6 Shipment Label" := TempBlob.Blob;
            RecordRef.GetTable(Paketschein);
            TempBlob.ToRecordRef(RecordRef, Paketschein.FieldNo("BC6 Shipment Label"));
            RecordRef.SetTable(Paketschein);
            Paketschein.INSERT(true);
            COMMIT();

            i += 1;
        end;

        if IsRetoure then begin
            //TempBlob.Blob.EXPORT('C:\Temp\DHLRetoure.pdf');
            FileManagement.BLOBExportToServerFile(TempBlob, 'C:\Temp\DHLRetoure.pdf');
            RecLEmailItem.INIT();
            RecLEmailItem.Initialize();
            RecLEmailItem.VALIDATE("Send to", WebservicePartner."E-Mail Recipient Retoure");
            RecLEmailItem.Subject := STRSUBSTNO(MailSubject, SalesShipmentHeader."No.");
            RecLEmailItem."Attachment File Path" := 'C:\Temp\DHLRetoure.pdf';
            RecLEmailItem."Attachment Name" := 'DHLRetoure.pdf';
            RecLEmailItem."Message Type" := RecLEmailItem."Message Type"::"Custom Message";
            // RecLEmailItem.Send(false);
            RecLEmailItem.Send(false, Enum::"Email Scenario"::Notification);
        end else begin
            Paketschein.RESET();
            Paketschein.SETRANGE("Shipment No.", SalesShipmentHeader."No.");
            Paketschein.SETRANGE("Package Tracking No.", PackageTrackingNo);
            if Paketschein.FINDLAST() then begin
                PackingTrackNoToPrint.SETRANGE("Shipment No.", Paketschein."Shipment No.");
                PackingTrackNoToPrint.SETRANGE("Line No.", Paketschein."Line No.");
                if PackingTrackNoToPrint.FINDFIRST() then
                    if WebservicePartner."DL DHL Label Instead of Print" then
                        DownloadDHLLabel(PackingTrackNoToPrint)
                    else
                        REPORT.RUN(REPORT::"BC6 Print Shipment Label", false, false, PackingTrackNoToPrint);
            end;
        end;
    end;


    procedure GetCurrTimestampWithOffset(): Text[30]
    var
        CurrDateTime: DateTime;
        LocalTime: Time;
        GMTTime: Time;
        DateTimeText: Text[30];
        TimeText: Text[30];
        TimeDifferenceText: Text[30];
        SignText: Text[30];
        ResultText: Text[30];
        Txt001: Label '%1 GMT%2%3', Comment = 'FRA="%1 GMT%2%3"';
    begin
        // Current Date + 2 hours
        CurrDateTime := CURRENTDATETIME + 7200000;

        LocalTime := DT2TIME(CurrDateTime);
        DateTimeText := FORMAT(CurrDateTime, 0, 9);
        TimeText := CopyStr(COPYSTR(DateTimeText, STRPOS(DateTimeText, 'T') + 1), 1, MaxStrLen(TimeText));
        TimeText := CopyStr(COPYSTR(TimeText, 1, STRLEN(TimeText) - 1), 1, MaxStrLen(TimeText));
        EVALUATE(GMTTime, TimeText);

        TimeDifferenceText := FORMAT((LocalTime - GMTTime) / 3600);

        SignText := '+';
        if TimeDifferenceText[1] = '-' then begin
            SignText := '-';
            TimeDifferenceText := DELCHR(TimeDifferenceText, '=', '-');
        end;
        EVALUATE(LocalTime, TimeDifferenceText);
        ResultText := STRSUBSTNO(Txt001, FORMAT(CurrDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>'), SignText, COPYSTR(FORMAT(LocalTime), 1, 5));

        exit(ResultText);
    end;

    local procedure DownloadDHLLabel(var _Paketschein: Record "JWC Packing Track No.")
    var
        L_TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        Txt002: Label '%1_%2.pdf', Comment = 'FRA="%1_%2.pdf"';
    begin
        if _Paketschein.FINDFIRST() then
            repeat
                _Paketschein.CALCFIELDS("BC6 Shipment Label");
                if _Paketschein."BC6 Shipment Label".HASVALUE then begin
                    // L_TempBlob.DELETEALL();
                    // L_TempBlob.INIT();
                    // L_TempBlob.Blob := _Paketschein."BC6 Shipment Label";
                    // L_TempBlob.INSERT();
                    L_TempBlob.FromRecord(_Paketschein, _Paketschein.FieldNo("BC6 Shipment Label"));
                    FileManagement.BLOBExport(L_TempBlob, STRSUBSTNO(Txt002, _Paketschein.FIELDCAPTION("BC6 Shipment Label"), _Paketschein."Line No."), true);
                end;
            until _Paketschein.NEXT() = 0;
    end;
}

