<%@ WebHandler Language="C#" Class="GetMakerData" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;

public class GetMakerData : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {

        DataClassesDataContext DB = new DataClassesDataContext();
        string strJson = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
        string postType = "";
        if (context.Request.QueryString["type"] != null)
        {
            postType = context.Request.QueryString["type"].ToString();
        }
        if (postType.Equals("getTimeIntervalTypeDetail"))
        {
            int id = Int32.Parse(strJson);
            var Result = from p in DB.TimeIntervalTypeDetail
                         where p.TimeIntervalTypeID == id
                         orderby p.Hour
                         select p;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getTimePlan"))
        {
            int id = Int32.Parse(strJson);
            var Result = from p in DB.TimePlan
                         where p.IntersectionDetailID == id
                         orderby Convert.ToInt32(p.TimePlanSN)
                         select new
                         {
                             p.IntersectionDetailID,
                             TimePlanCycle = (from x in DB.TimePlanCycle where x.IntersectionDetailID == p.IntersectionDetailID && x.TimePlanSN == p.TimePlanSN select x.Cycle).First(),
                             p.TimeDiff,
                             p.TimePhaseSN,
                             p.TimePlanID,
                             p.TimePlanSN
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getTimeIntervalType"))
        {
            int id = Int32.Parse(strJson);
            var Result = from p in DB.TimeIntervalType
                         where p.IntersectionDetailID == id
                         orderby Convert.ToInt32(p.TimeType)
                         select new
                         {
                             p.TimeType,
                             p.TimeIntervalTypeID,
                             TimeIntervalTypeDetail = (from t in DB.TimeIntervalTypeDetail
                                                       where t.TimeIntervalTypeID == p.TimeIntervalTypeID
                                                       orderby Convert.ToInt32(t.Hour)
                                                       select new
                                                       {
                                                           t.TimeIntervalTypeDetailID,
                                                           t.Hour,
                                                           t.Minute,
                                                           t.TimePlanSN
                                                       })
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getTimePhase"))
        {
            int id = Int32.Parse(strJson);
            var Result = (from x in DB.TimePhase
                          where x.IntersectionDetailID == id
                          orderby x.TimePhaseID
                          select new
                          {
                              x.TimePhaseID,
                              x.TimePhaseRoad,
                              TimePhaseDetail = (from b in DB.TimePlanDetial
                                                 where b.TimePhaseID == x.TimePhaseID
                                                 orderby Convert.ToInt32(b.TimePlanSN)
                                                 select new
                                                 {
                                                     b.TimePhaseDetailID,
                                                     b.TimePhaseID,
                                                     b.TimePlanSN,
                                                     b.IntersectionDetailID,
                                                     PH = (b.PH == null ? 0 : Convert.ToInt32(b.PH)),
                                                     G = (b.G == null ? 0 : Convert.ToInt32(b.G)),
                                                     Y = (b.Y == null ? 0 : Convert.ToInt32(b.Y)),
                                                     R = (b.R == null ? 0 : Convert.ToInt32(b.R)),
                                                 }),
                              x.ImgSrc
                          });
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getTimePhaseDetail"))
        {
            int id = Int32.Parse(strJson);
            var Result = (from x in DB.TimePhase
                          where x.TimePhaseID == id
                          orderby x.TimePhaseID
                          select new
                          {
                              x.TimePhaseID,
                              x.TimePhaseRoad,
                              TimePhaseDetail = (from b in DB.TimePlanDetial
                                                 where b.TimePhaseID == x.TimePhaseID
                                                 && b.TimePlanSN != null
                                                 orderby Convert.ToInt32(b.TimePlanSN)
                                                 select new
                                                 {
                                                     b.TimePhaseDetailID,
                                                     b.TimePhaseID,
                                                     b.TimePlanSN,
                                                     b.IntersectionDetailID,
                                                     PH = (b.PH == null ? "0" : b.PH),
                                                     b.G,
                                                     b.Y,
                                                     b.R,
                                                 }),
                              x.ImgSrc
                          }).First();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getMarker"))
        {
            int id = Int32.Parse(strJson);
            var Result = from p in DB.IntersectionDetail
                         where p.IntersectionID == id
                         select p;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getSelect"))
        {
            int id = Int32.Parse(strJson);
            var Result = (from p in DB.IntersectionDetail
                          where p.IntersectionDetailID == id
                          select new
                          {
                              WeekType = (from r in DB.TimeIntervalType
                                          where r.IntersectionDetailID == p.IntersectionDetailID
                                          orderby Convert.ToInt32(r.TimeType)
                                          select r.TimeType
                                          ),
                              TimePlan = (from r in DB.TimePlan
                                          where r.IntersectionDetailID == p.IntersectionDetailID
                                          orderby Convert.ToInt32(r.TimePlanSN)
                                          select r.TimePlanSN
                                          )
                          }).First();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }else if (postType.Equals("getWeekSelect"))
        {
            int id = Int32.Parse(strJson);
            var Result = (from p in DB.IntersectionDetail
                          where p.IntersectionDetailID == id
                          select new
                          {
                              WeekType = (from r in DB.TimeIntervalType
                                          where r.IntersectionDetailID == p.IntersectionDetailID
                                          orderby Convert.ToInt32(r.TimeType)
                                          select r.TimeType
                                          ),
                              TimePlan = (from r in DB.TimePlan
                                          where r.IntersectionDetailID == p.IntersectionDetailID
                                          orderby Convert.ToInt32(r.TimePlanSN)
                                          select r.TimePlanSN
                                          )
                          }).First();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("使用非法數值");
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