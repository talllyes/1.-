<%@ WebHandler Language="C#" Class="PostUpdateBase" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;

public class PostUpdateBase : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
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
        if (postType.Equals("updateIntersectionBase"))
        {
            dynamic json = JValue.Parse(strJson);
            int id = json.IntersectionID;
            var updateBase = DB.Intersection.First(o => o.IntersectionID == id);
            updateBase.Position = json.Position;
            updateBase.RoadName = json.RoadName;
            updateBase.ENumber = json.ENumber;
            updateBase.EmployeeID = MapRoadLoginID;
            updateBase.Zone = json.Zone;
            DB.SubmitChanges();
        }
        else if (postType.Equals("updateLoc"))
        {
            dynamic json = JValue.Parse(strJson);
            int id = json.IntersectionID;
            var updateBase = DB.Intersection.First(o => o.IntersectionID == id);
            updateBase.Position = json.Position;
            updateBase.EmployeeID = MapRoadLoginID;
            DB.SubmitChanges();
        }
        else if (postType.Equals("insertIntersectionBase"))
        {
            Intersection stx = new Intersection
            {
                Position = strJson,
                EmployeeID = MapRoadLoginID,
                State = "1"
            };
            DB.Intersection.InsertOnSubmit(stx);
            DB.SubmitChanges();

            int IntersectionID = stx.IntersectionID;
            IntersectionDetail st = new IntersectionDetail
            {
                IntersectionID = IntersectionID,
                VersionDate = DateTime.Now,
                EmployeeID = MapRoadLoginID,
                State = "1",
                TwoVer = "0"
            };
            DB.IntersectionDetail.InsertOnSubmit(st);
            DB.SubmitChanges();

            WeekType st2 = new WeekType
            {
                IntersectionDetailID = st.IntersectionDetailID
            };
            TimePhase st3 = new TimePhase
            {
                IntersectionDetailID = st.IntersectionDetailID,
                ImgSrc = "img/nopic.jpg"
            };
            TimePhase st4 = new TimePhase
            {
                IntersectionDetailID = st.IntersectionDetailID,
                ImgSrc = "img/nopic.jpg"
            };
            DB.TimePhase.InsertOnSubmit(st3);
            DB.TimePhase.InsertOnSubmit(st4);
            DB.WeekType.InsertOnSubmit(st2);
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write(stx.IntersectionID);
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