using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class manage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["MapRoadLoginID"] == null || Session["MapRoadLoginID"].Equals(""))
        {
            Session["MapRoadLoginID"] = "";
            Response.Redirect("login.aspx");
        }
        if (Session["MapRoadadmin"] == null)
        {
            Session["MapRoadadmin"] = "";
            Response.Redirect("index.aspx");
        }
        if (!Session["MapRoadadmin"].ToString().Equals("1"))
        {
            Response.Redirect("index.aspx");
        }
    }
}