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
        var taiwanCalendar = new System.Globalization.TaiwanCalendar();
        string postType = "";
        if (context.Request.QueryString["type"] != null)
        {
            postType = context.Request.QueryString["type"].ToString();
        }
        if (postType.Equals("getTwoVer"))
        {
            int id = Int32.Parse(context.Request.QueryString["id"]);
            var Result = (from res in (from p in DB.IntersectionDetail
                                       where p.IntersectionDetailID == id && p.TwoVer == "1"
                                       select new
                                       {
                                           ver = (from o in DB.IntersectionDetail
                                                  where o.IntersectionDetailID < p.IntersectionDetailID && o.IntersectionDetailID == id
                                                  select o).Count() + 1,
                                           p.IntersectionID,
                                           p.IntersectionDetailID,
                                           WeekType = (from s in DB.WeekType where s.IntersectionDetailID == p.IntersectionDetailID select s).FirstOrDefault(),
                                           TimeIntervalType = (from r in DB.TimeIntervalType
                                                               where r.IntersectionDetailID == p.IntersectionDetailID
                                                               orderby Convert.ToInt32(r.TimeType)
                                                               select new
                                                               {
                                                                   r.TimeType,
                                                                   r.TimeIntervalTypeID,
                                                                   TimeIntervalTypeDetail = (from t in DB.TimeIntervalTypeDetail
                                                                                             where t.TimeIntervalTypeID == r.TimeIntervalTypeID
                                                                                             orderby Convert.ToInt32(t.Hour)
                                                                                             select new
                                                                                             {
                                                                                                 t.TimeIntervalTypeDetailID,
                                                                                                 t.Hour,
                                                                                                 t.Minute,
                                                                                                 t.TimePlanSN
                                                                                             })
                                                               }),
                                           TimePlan = (from v in DB.TimePlan
                                                       where v.IntersectionDetailID == p.IntersectionDetailID
                                                       orderby Convert.ToInt32(v.TimePlanSN)
                                                       select new
                                                       {
                                                           v.IntersectionDetailID,
                                                           TimePlanCycle = (from x in DB.TimePlanCycle where x.IntersectionDetailID == v.IntersectionDetailID && x.TimePlanSN == v.TimePlanSN select x.Cycle).First(),
                                                           v.TimeDiff,
                                                           v.TimePhaseSN,
                                                           v.TimePlanID,
                                                           v.TimePlanSN
                                                       }),
                                           TimePhase = (from x in DB.TimePhase
                                                        where x.IntersectionDetailID == p.IntersectionDetailID
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
                                                                                   PH = (b.PH == null ? 0 : Convert.ToInt32(b.PH)),
                                                                                   G = (b.G == null ? 0 : Convert.ToInt32(b.G)),
                                                                                   Y = (b.Y == null ? 0 : Convert.ToInt32(b.Y)),
                                                                                   R = (b.R == null ? 0 : Convert.ToInt32(b.R)),
                                                                               }),
                                                            x.ImgSrc
                                                        }),
                                           p.Controller,
                                           GPS = (p.GPS == "1" ? "裝設" : "未裝設"),
                                           p.Remark,
                                           VersionDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(p.VersionDate.ToString())), Convert.ToDateTime(p.VersionDate)),
                                           p.Src,
                                           State = (p.State == "1" ? true : false),
                                           TwoVer = (p.TwoVer == "0" ? false : true),
                                           TwoVerNum = (p.TwoVer == "0" ? "0" : p.TwoVer),
                                           ClassTwo = (p.TwoVer == "0" ? "" : "TwoVer"),
                                           TwoVer2 = p.TwoVer,
                                           p.EmployeeID,
                                           p.ModifiedDate
                                       })
                          orderby res.ver descending
                          select res).FirstOrDefault()
            ;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getVer"))
        {
            int id = Int32.Parse(context.Request.QueryString["id"]);
            var Result = from s in (from p in DB.IntersectionDetail
                                    where p.IntersectionID == id && p.TwoVer != "1"
                                    select new
                                    {
                                        ver = (from o in DB.IntersectionDetail
                                               where o.IntersectionDetailID < p.IntersectionDetailID && o.IntersectionID == id && o.TwoVer != "1"
                                               select o).Count() + 1,
                                        p.IntersectionDetailID
                                    })
                         orderby s.ver descending
                         select s
                          ;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getMarker"))
        {
            int id = Int32.Parse(context.Request.QueryString["id"]);
            var Result = (from res in (from p in DB.IntersectionDetail
                                       where p.IntersectionDetailID == id
                                       select new
                                       {
                                           ver = 0,
                                           p.IntersectionID,
                                           p.IntersectionDetailID,
                                           WeekType = (from s in DB.WeekType where s.IntersectionDetailID == p.IntersectionDetailID select s).FirstOrDefault(),
                                           TimeIntervalType = (from r in DB.TimeIntervalType
                                                               where r.IntersectionDetailID == p.IntersectionDetailID
                                                               orderby Convert.ToInt32(r.TimeType)
                                                               select new
                                                               {
                                                                   r.TimeType,
                                                                   r.TimeIntervalTypeID,
                                                                   TimeIntervalTypeDetail = (from t in DB.TimeIntervalTypeDetail
                                                                                             where t.TimeIntervalTypeID == r.TimeIntervalTypeID
                                                                                             orderby Convert.ToInt32(t.Hour)
                                                                                             select new
                                                                                             {
                                                                                                 t.TimeIntervalTypeDetailID,
                                                                                                 t.Hour,
                                                                                                 t.Minute,
                                                                                                 t.TimePlanSN
                                                                                             })
                                                               }),
                                           TimePlan = (from v in DB.TimePlan
                                                       where v.IntersectionDetailID == p.IntersectionDetailID
                                                       orderby Convert.ToInt32(v.TimePlanSN)
                                                       select new
                                                       {
                                                           v.IntersectionDetailID,
                                                           TimePlanCycle = (from x in DB.TimePlanCycle where x.IntersectionDetailID == v.IntersectionDetailID && x.TimePlanSN == v.TimePlanSN select x.Cycle).First(),
                                                           v.TimeDiff,
                                                           v.TimePhaseSN,
                                                           v.TimePlanID,
                                                           v.TimePlanSN
                                                       }),
                                           TimePhase = (from x in DB.TimePhase
                                                        where x.IntersectionDetailID == p.IntersectionDetailID
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
                                                                                   PH = (b.PH == null ? 0 : Convert.ToInt32(b.PH)),
                                                                                   G = (b.G == null ? 0 : Convert.ToInt32(b.G)),
                                                                                   Y = (b.Y == null ? 0 : Convert.ToInt32(b.Y)),
                                                                                   R = (b.R == null ? 0 : Convert.ToInt32(b.R)),
                                                                               }),
                                                            x.ImgSrc
                                                        }),
                                           p.Controller,
                                           GPS = (p.GPS == "1" ? "裝設" : "未裝設"),
                                           p.Remark,
                                           VersionDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(p.VersionDate.ToString())), Convert.ToDateTime(p.VersionDate)),
                                           p.Src,
                                           State = (p.State == "1" ? true : false),
                                           TwoVer = (p.TwoVer == "0" ? false : true),
                                           TwoVerNum = (p.TwoVer == "0" ? "0" : p.TwoVer),
                                           ClassTwo = (p.TwoVer == "0" ? "" : "TwoVer"),
                                           TwoVer2 = p.TwoVer,
                                           p.EmployeeID,
                                           p.ModifiedDate
                                       })
                          orderby res.ver descending
                          select res).FirstOrDefault()
            ;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));

        }
        else if (postType.Equals("getTwoMarker"))
        {
            int id = Int32.Parse(context.Request.QueryString["id"]);
            var Result = (from res in (from p in DB.IntersectionDetail
                                       where p.TwoVer == id + ""
                                       select new
                                       {
                                           ver = 0,
                                           p.IntersectionID,
                                           p.IntersectionDetailID,
                                           WeekType = (from s in DB.WeekType where s.IntersectionDetailID == p.IntersectionDetailID select s).FirstOrDefault(),
                                           TimeIntervalType = (from r in DB.TimeIntervalType
                                                               where r.IntersectionDetailID == p.IntersectionDetailID
                                                               orderby Convert.ToInt32(r.TimeType)
                                                               select new
                                                               {
                                                                   r.TimeType,
                                                                   r.TimeIntervalTypeID,
                                                                   TimeIntervalTypeDetail = (from t in DB.TimeIntervalTypeDetail
                                                                                             where t.TimeIntervalTypeID == r.TimeIntervalTypeID
                                                                                             orderby Convert.ToInt32(t.Hour)
                                                                                             select new
                                                                                             {
                                                                                                 t.TimeIntervalTypeDetailID,
                                                                                                 t.Hour,
                                                                                                 t.Minute,
                                                                                                 t.TimePlanSN
                                                                                             })
                                                               }),
                                           TimePlan = (from v in DB.TimePlan
                                                       where v.IntersectionDetailID == p.IntersectionDetailID
                                                       orderby Convert.ToInt32(v.TimePlanSN)
                                                       select new
                                                       {
                                                           v.IntersectionDetailID,
                                                           TimePlanCycle = (from x in DB.TimePlanCycle where x.IntersectionDetailID == v.IntersectionDetailID && x.TimePlanSN == v.TimePlanSN select x.Cycle).First(),
                                                           v.TimeDiff,
                                                           v.TimePhaseSN,
                                                           v.TimePlanID,
                                                           v.TimePlanSN
                                                       }),
                                           TimePhase = (from x in DB.TimePhase
                                                        where x.IntersectionDetailID == p.IntersectionDetailID
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
                                                                                   PH = (b.PH == null ? 0 : Convert.ToInt32(b.PH)),
                                                                                   G = (b.G == null ? 0 : Convert.ToInt32(b.G)),
                                                                                   Y = (b.Y == null ? 0 : Convert.ToInt32(b.Y)),
                                                                                   R = (b.R == null ? 0 : Convert.ToInt32(b.R)),
                                                                               }),
                                                            x.ImgSrc
                                                        }),
                                           p.Controller,
                                           GPS = (p.GPS == "1" ? "裝設" : "未裝設"),
                                           p.Remark,
                                           VersionDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(p.VersionDate.ToString())), Convert.ToDateTime(p.VersionDate)),
                                           p.Src,
                                           State = (p.State == "1" ? true : false),
                                           TwoVer = (p.TwoVer == "0" ? false : true),
                                           TwoVerNum = (p.TwoVer == "0" ? "0" : p.TwoVer),
                                           ClassTwo = (p.TwoVer == "0" ? "" : "TwoVer"),
                                           TwoVer2 = p.TwoVer,
                                           p.EmployeeID,
                                           p.ModifiedDate
                                       })
                          orderby res.ver descending
                          select res).FirstOrDefault()
            ;
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));

        }
        else
        {
            int id = Int32.Parse(context.Request.QueryString["id"]);
            var Result = from res in (from p in DB.IntersectionDetail
                                      where p.IntersectionID == id && p.TwoVer != "1"
                                      select new
                                      {
                                          ver = (from o in DB.IntersectionDetail
                                                 where o.IntersectionDetailID < p.IntersectionDetailID && o.IntersectionID == id && o.TwoVer != "1"
                                                 select o).Count() + 1,
                                          p.IntersectionID,
                                          p.IntersectionDetailID,
                                          WeekType = (from s in DB.WeekType where s.IntersectionDetailID == p.IntersectionDetailID select s).FirstOrDefault(),
                                          TimeIntervalType = (from r in DB.TimeIntervalType
                                                              where r.IntersectionDetailID == p.IntersectionDetailID
                                                              orderby Convert.ToInt32(r.TimeType)
                                                              select new
                                                              {
                                                                  r.TimeType,
                                                                  r.TimeIntervalTypeID,
                                                                  TimeIntervalTypeDetail = (from t in DB.TimeIntervalTypeDetail
                                                                                            where t.TimeIntervalTypeID == r.TimeIntervalTypeID
                                                                                            orderby Convert.ToInt32(t.Hour)
                                                                                            select new
                                                                                            {
                                                                                                t.TimeIntervalTypeDetailID,
                                                                                                t.Hour,
                                                                                                t.Minute,
                                                                                                t.TimePlanSN
                                                                                            })
                                                              }),
                                          TimePlan = (from v in DB.TimePlan
                                                      where v.IntersectionDetailID == p.IntersectionDetailID
                                                      orderby Convert.ToInt32(v.TimePlanSN)
                                                      select new
                                                      {
                                                          v.IntersectionDetailID,
                                                          TimePlanCycle = (from x in DB.TimePlanCycle where x.IntersectionDetailID == v.IntersectionDetailID && x.TimePlanSN == v.TimePlanSN select x.Cycle).First(),
                                                          v.TimeDiff,
                                                          v.TimePhaseSN,
                                                          v.TimePlanID,
                                                          v.TimePlanSN
                                                      }),
                                          TimePhase = (from x in DB.TimePhase
                                                       where x.IntersectionDetailID == p.IntersectionDetailID
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
                                                                                  PH = (b.PH == null ? 0 : Convert.ToInt32(b.PH)),
                                                                                  G = (b.G == null ? 0 : Convert.ToInt32(b.G)),
                                                                                  Y = (b.Y == null ? 0 : Convert.ToInt32(b.Y)),
                                                                                  R = (b.R == null ? 0 : Convert.ToInt32(b.R)),
                                                                              }),
                                                           x.ImgSrc
                                                       }),
                                          p.Controller,
                                          GPS = (p.GPS == "1" ? "裝設" : "未裝設"),
                                          p.Remark,
                                          VersionDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(p.VersionDate.ToString())), Convert.ToDateTime(p.VersionDate)),
                                          p.Src,
                                          State = (p.State == "1" ? true : false),
                                          TwoVer = (p.TwoVer == "0" ? false : true),
                                          TwoVerNum = (p.TwoVer == "0" ? "0" : p.TwoVer),
                                          ClassTwo = (p.TwoVer == "0" ? "" : "TwoVer"),
                                          TwoVer2 = p.TwoVer,
                                          p.EmployeeID,
                                          p.ModifiedDate
                                      })
                         orderby res.ver descending
                         select res
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