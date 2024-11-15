dotnet
{
    assembly("System.Xml")
    {
        Version = '2.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Xml.XmlNode"; "XmlNode")
        {
        }

        type("System.Xml.XmlDocument"; "XmlDocument")
        {
        }

        type("System.Xml.XmlNodeType"; "XmlNodeType")
        {
        }

        type("System.Xml.XmlReader"; "XmlReader")
        {
        }

        type("System.Xml.XmlNamespaceManager"; "XmlNamespaceManager")
        {
        }
    }

    assembly("System")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Net.HttpStatusCode"; "HttpStatusCode")
        {
        }

        type("System.Collections.Specialized.NameValueCollection"; "NameValueCollection")
        {
        }

        type("System.Net.HttpWebResponse"; "HttpWebResponse")
        {
        }
    }

}
