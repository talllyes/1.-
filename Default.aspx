<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">

        <asp:View ID="View1" runat="server">3345</asp:View>
    </form>
</body>
</html>
<script>
    
    var a = (function () {
        var _x = { c: "a", p: "a" };

        return { g: _x};
    })();
    a.g.c = "bbb";
    console.log(a.g);
</script>
