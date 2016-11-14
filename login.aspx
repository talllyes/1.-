<%@ Page Language="C#" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>交通號誌時制管理系統-登入頁面</title>
    <link rel="short icon" href="SigFavicon.ico" />
    <link rel="icon" href="SigFavicon.ico" type="image/ico" />
    <link rel="Bookmark" href="SigFavicon.ico" type="image/x-icon" />
    <!-- Bootstrap -->
    <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <link rel="stylesheet" href="Bootstrap/css/bootstrap.css" />
    <script type="text/javascript" src="Bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="Bootstrap/js/bootstrap3-typeahead.js"></script>
    <link rel="stylesheet" href="css/KaiCss.css" />
</head>
<body style="background-image: url('img/mapbk.jpg'); background-size: cover;">
    <form id="form1" runat="server">
        <nav class="navbar navbar-default" role="navigation" style="margin-bottom: 0px; border: 0px; border-bottom: 1px; border-color: #B0B0B0; border-style: solid;">
            <div class="container">
                <div class="navbar-header">
                    <a class="navbar-brand" style="font-family: 微軟正黑體;" href="#">交通號誌時制管理系統</a>
                </div>
            </div>
        </nav>
        <div style="width: 400px; margin: 0 auto;">
            <div class="kai-callout kai-callout-primary" style="padding: 10px; background-color: white; border-left-color: #ABABAB; border-right-color: #ABABAB; border-bottom-color: #ABABAB;">
                <div>
                    <div style="margin-bottom: 5px; font-size: 28px; text-align: center;">
                        帳號登入                        
                    </div>
                </div>
                <div>
                    <table style="width: 100%;">
                        <tr>
                            <td style="padding: 10px;" colspan="2">
                                <div class="input-group" style="width:100%;">
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-user" aria-hidden="true"></span>
                                    </span>
                                    <asp:TextBox ID="account" Width="100%" runat="server" placeholder="帳號" CssClass="form-control"></asp:TextBox>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 10px;" colspan="2">
                                <div class="input-group" style="width:100%;">
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
                                    </span>
                                    <asp:TextBox ID="pwdTb" runat="server" placeholder="密碼" CssClass="form-control" TextMode="Password"></asp:TextBox>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td style="width:50%;padding:10px;">
                                <asp:Button ID="Button1" runat="server" Text="登入" CssClass="btn btn-primary" OnClick="Button1_Click" Width="100%" />
                            </td>
                            <td style="width:50%;text-align:center;">
                                忘記密碼?
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 10px;" align="center" colspan="2">
                                <asp:Label ID="message" runat="server" ForeColor="Red" Width="100%" Visible="false"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

