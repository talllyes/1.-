using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string logout = "";
        if (Request.QueryString["logout"] != null)
        {
            logout = Request.QueryString["logout"].ToString();
        }

        if (logout.Equals("true") || Session["MapRoadLoginID"] == null)
        {
            Session["MapRoadLoginID"] = "";
        }
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        DataClasses2DataContext DB2 = new DataClasses2DataContext();
        string password = "";
        if (!account.Text.Equals(""))
        {
            password = pwdTb.Text.ToString();
            SHA256 sha256 = new SHA256CryptoServiceProvider();
            byte[] source = Encoding.Default.GetBytes(password);
            byte[] crypto = sha256.ComputeHash(source);
            string temp = Convert.ToBase64String(crypto);
            password = temp;
        }
        var result = (from s in DB.UserLogin
                      where s.UserID == account.Text && s.Password == password
                      select s).FirstOrDefault();

        if (result != null)
        {
            if (result.State.Equals("1")){
                Session["MapRoadLoginID"] = result.UserID.ToString();
                Session["MapRoadLoginIDs"] = result.UserLoginID.ToString();
                Session["MapRoadadmin"] = result.admin.ToString();
                var r = (from a in DB2.loginNum where a.SystemType == "1system" select a).FirstOrDefault();
                loginNum st = new loginNum
                {
                    LoginDate = DateTime.Now,
                    SystemType = "1",
                    LoginID = result.UserID.ToString()
                };
                DB2.loginNum.InsertOnSubmit(st);
                DB2.SubmitChanges();
                Response.Redirect("index.aspx");
            }
            else{
                message.Visible = true;
                message.Text = "帳號已停用！";
            }
        }
        else
        {
            message.Visible = true;
            message.Text = "帳號或密碼錯誤！";
        }
    }
}