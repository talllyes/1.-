<%@ WebHandler Language="C#" Class="GetIntersection" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;

public class GetIntersection : IHttpHandler,System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        string postType = "";
        string MapRoadLoginID = "";
        if (context.Request.QueryString["type"] != null)
        {
            postType = context.Request.QueryString["type"].ToString();
        }
        if (context.Session["MapRoadLoginID"] != null && !context.Session["MapRoadLoginID"].Equals(""))
        {
            MapRoadLoginID=context.Session["MapRoadLoginID"].ToString();
        }
        else
        {
            MapRoadLoginID = "hacker";
        }
        if (postType.Equals("setLoc"))
        {
            var Result = from k in DB.Intersection
                         where k.State == "1" && (k.Position == null || k.Position == "")
                         select new
                         {
                             k.ENumber,
                             k.IntersectionID,
                             k.Position,
                             k.RoadName,
                             k.Zone,
                             Img = "img/map.png"
                         }
                ;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else
        {
            var Result = from k in DB.Intersection
                         where k.State == "1" && k.Position != null &&  k.Position != ""
                         select new
                         {
                             k.ENumber,
                             k.IntersectionID,
                             k.Position,
                             k.RoadName,
                             k.Zone,
                             Img = "img/map.png"
                         }
                     ;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
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