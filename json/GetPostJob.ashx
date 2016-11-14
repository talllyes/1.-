<%@ WebHandler Language="C#" Class="GetMakerJob" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;

public class GetMakerJob : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        var taiwanCalendar = new System.Globalization.TaiwanCalendar();
        string MapRoadLoginID = "";
        string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
        string postType = "";
        if (context.Session["MapRoadLoginID"] != null && !context.Session["MapRoadLoginID"].Equals(""))
        {
            MapRoadLoginID = context.Session["MapRoadLoginID"].ToString();
        }
        else
        {
            MapRoadLoginID = "hacker";
        }
        if (context.Request.QueryString["type"] != null)
        {
            postType = context.Request.QueryString["type"].ToString();
        }
        if (postType.Equals("getJob"))
        {
            int id = Int32.Parse(strJson);
            var Result = from p in DB.Job
                         where p.IntersectionID == id
                         orderby p.JobDate descending
                         select new
                         {
                             p.JobID,
                             p.JobContent,
                             p.IntersectionID,
                             p.ZoneName,
                             p.Src,
                             SrcShow = string.IsNullOrEmpty(p.Src),
                             JobDate = string.Format("{0}-{1:MM-dd<br />HH:mm}", taiwanCalendar.GetYear(Convert.ToDateTime(p.JobDate.ToString())), Convert.ToDateTime(p.JobDate)),
                             RepairDate = string.Format("{0}-{1:MM-dd<br />HH:mm}", taiwanCalendar.GetYear(Convert.ToDateTime(p.RepairDate.ToString())), Convert.ToDateTime(p.RepairDate))
                         }
                         ;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("insertJob"))
        {
            dynamic json = JValue.Parse(strJson);
            string dd = json.JobDate;
            dd = (Int32.Parse(dd.Split('-')[0]) + 1911) + "-" + dd.Split('-')[1] + "-" + dd.Split('-')[2];
            DateTime cc = DateTime.Parse(dd);
            string RepairDate = json.RepairDate;
            RepairDate = (Int32.Parse(RepairDate.Split('-')[0]) + 1911) + "-" + RepairDate.Split('-')[1] + "-" + RepairDate.Split('-')[2];
            DateTime RepairDate2 = DateTime.Parse(RepairDate);
            Job st = new Job
            {
                IntersectionID = json.IntersectionID,
                JobContent = json.JobContent,
                ZoneName = json.ZoneName,
                Src = json.Src,
                JobDate = cc,
                EmployeeID = MapRoadLoginID,
                RepairDate = RepairDate2
            };
            DB.Job.InsertOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("updateJob"))
        {
            dynamic json = JValue.Parse(strJson);
            int id = json.JobID;
            string dd = json.JobDate;
            dd = (Int32.Parse(dd.Split('-')[0]) + 1911) + "-" + dd.Split('-')[1] + "-" + dd.Split('-')[2];
            DateTime cc = DateTime.Parse(dd);
            string RepairDate = json.RepairDate;
            RepairDate = (Int32.Parse(RepairDate.Split('-')[0]) + 1911) + "-" + RepairDate.Split('-')[1] + "-" + RepairDate.Split('-')[2];
            DateTime RepairDate2 = DateTime.Parse(RepairDate);


            var updateJob = DB.Job.First(o => o.JobID == id);
            updateJob.ZoneName = json.ZoneName;
            updateJob.JobDate = cc;
            updateJob.Src = json.Src;
            updateJob.EmployeeID = MapRoadLoginID;
            updateJob.JobContent = json.JobContent;
            updateJob.RepairDate = RepairDate2;
            DB.SubmitChanges();
        }
        else if (postType.Equals("deleteJob"))
        {
            int JobID = Int32.Parse(strJson);
            Job st = DB.Job.First(c => c.JobID == JobID);
            DB.Job.DeleteOnSubmit(st);
            DB.SubmitChanges();
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("warning,不正確的執行參數！");
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