<%@ WebHandler Language="C#" Class="GetMakerNotice" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;

public class GetMakerNotice : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {

        DataClassesDataContext DB = new DataClassesDataContext();
        var taiwanCalendar = new System.Globalization.TaiwanCalendar();

        string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
        string postType = "";
        string MapRoadLoginID = "";
        if (context.Request.QueryString["type"] != null)
        {
            postType = context.Request.QueryString["type"].ToString();
        }
        if (context.Session["MapRoadLoginID"] != null && !context.Session["MapRoadLoginID"].Equals(""))
        {
            MapRoadLoginID = context.Session["MapRoadLoginID"].ToString();
        }
        else
        {
            MapRoadLoginID = "hacker";
        }
        if (postType.Equals("getNotice"))
        {
            int id = Int32.Parse(strJson);
            var Result = from p in DB.Notice
                         where p.IntersectionID == id
                         orderby p.NoticeDate descending
                         select new
                         {
                             p.NoticeID,
                             p.NoticeContent,
                             p.Who,
                             p.Remark,
                             p.Result,
                             NoticeDate = string.Format("{0}-{1:MM-dd<br />HH:mm}", taiwanCalendar.GetYear(Convert.ToDateTime(p.NoticeDate.ToString())), Convert.ToDateTime(p.NoticeDate))
                         }
                         ;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("insertNotice"))
        {
            dynamic json = JValue.Parse(strJson);
            string dd = json.NoticeDate;
            dd = (Int32.Parse(dd.Split('-')[0]) + 1911) + "-" + dd.Split('-')[1] + "-" + dd.Split('-')[2];
            DateTime cc = DateTime.Parse(dd);
            Notice st = new Notice
            {
                IntersectionID = json.id,
                Who = json.Who,
                NoticeContent = json.NoticeContent,
                Remark = json.Remark,
                Result = json.Result,
                EmployeeID = MapRoadLoginID,
                NoticeDate = cc
            };
            DB.Notice.InsertOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("updateNotice"))
        {
            dynamic json = JValue.Parse(strJson);
            int id = json.NoticeID;
            string dd = json.NoticeDate;
            dd = (Int32.Parse(dd.Split('-')[0]) + 1911) + "-" + dd.Split('-')[1] + "-" + dd.Split('-')[2];
            DateTime cc = DateTime.Parse(dd);
            var updateNotice = DB.Notice.First(o => o.NoticeID == id);
            updateNotice.NoticeContent = json.NoticeContent;
            updateNotice.NoticeDate = cc;
            updateNotice.Who = json.Who;
            updateNotice.Remark = json.Remark;
            updateNotice.EmployeeID = MapRoadLoginID;
            updateNotice.Result = json.Result;
            DB.SubmitChanges();
        }
        else if (postType.Equals("deleteNotice"))
        {
            int NoticeID = Int32.Parse(strJson);
            Notice st = DB.Notice.First(c => c.NoticeID == NoticeID);
            DB.Notice.DeleteOnSubmit(st);
            DB.SubmitChanges();
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("err,不正確的執行參數！");
        }

    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}