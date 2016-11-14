<%@ WebHandler Language="C#" Class="PostUpdateVer" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;

public class PostUpdateVer : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    DataClassesDataContext DB;
    public void ProcessRequest(HttpContext context)
    {
        DB = new DataClassesDataContext();
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
        if (postType.Equals("updateIntersectionDeta"))
        {
            dynamic json = JValue.Parse(strJson);
            int id = json.IntersectionDetailID;
            string twoVer = json.TwoVer2;
            int id2 = 0;
            System.Globalization.CultureInfo tc = new System.Globalization.CultureInfo("zh-TW");
            tc.DateTimeFormat.Calendar = new System.Globalization.TaiwanCalendar();
            var updateVer = DB.IntersectionDetail.First(o => o.IntersectionDetailID == id);
            string GPS = json.GPS;
            updateVer.Controller = json.Controller;
            string gg = "0";
            if (GPS.Equals("裝設"))
            {
                gg = "1";
            }
            else
            {
                gg = "0";
            }
            updateVer.GPS = gg;
            updateVer.Remark = json.Remark;
            string dd = json.VersionDate;
            updateVer.VersionDate = DateTime.Parse(dd, tc).Date;
            updateVer.Src = json.Src;
            updateVer.EmployeeID = MapRoadLoginID;
            var updateVer2 = DB.IntersectionDetail.First(o => o.IntersectionDetailID == id);
            if (!twoVer.Equals("0") && !twoVer.Equals("1"))
            {
                string aa = json.TwoVer2;
                id2 = Int32.Parse(aa);
                updateVer2 = DB.IntersectionDetail.First(o => o.IntersectionDetailID == id2);
                updateVer2.Controller = json.Controller;
                updateVer2.Remark = json.Remark;
                updateVer2.GPS = gg;
                updateVer2.VersionDate = DateTime.Parse(dd, tc).Date;
                updateVer2.Src = json.Src;
            }
            else if (twoVer.Equals("1"))
            {
                id2 = json.IntersectionDetailID;
                updateVer2 = DB.IntersectionDetail.First(o => o.TwoVer == id2 + "");
                updateVer2.Controller = json.Controller;
                updateVer2.Remark = json.Remark;
                updateVer2.GPS = gg;
                updateVer2.VersionDate = DateTime.Parse(dd, tc).Date;
                updateVer2.Src = json.Src;
            }
            updateVer2.EmployeeID = MapRoadLoginID;
            DB.SubmitChanges();
        }
        else if (postType.Equals("updateWeekType"))
        {
            dynamic json = JValue.Parse(strJson);
            int id = json.WeekTypeID;
            int IntersectionDetailID = json.IntersectionDetailID;
            var updateVer = DB.WeekType.First(o => o.WeekTypeID == id);
            updateVer.Monday = json.Monday;
            updateVer.Tuesday = json.Tuesday;
            updateVer.Wednesday = json.Wednesday;
            updateVer.Thursday = json.Thursday;
            updateVer.Friday = json.Friday;
            updateVer.Saturday = json.Saturday;
            updateVer.Sunday = json.Sunday;
            DB.SubmitChanges();
            string twoVer = json.twoVer2;
            if (!twoVer.Equals("0") && !twoVer.Equals("1"))
            {
                int id2 = Int32.Parse(twoVer);
                var updateVer2 = DB.WeekType.First(o => o.IntersectionDetailID == id2);
                updateVer2.Monday = json.Monday;
                updateVer2.Tuesday = json.Tuesday;
                updateVer2.Wednesday = json.Wednesday;
                updateVer2.Thursday = json.Thursday;
                updateVer2.Friday = json.Friday;
                updateVer2.Saturday = json.Saturday;
                updateVer2.Sunday = json.Sunday;
                DB.SubmitChanges();
            }
            else if (twoVer.Equals("1"))
            {
                var updateVer2 = DB.WeekType.First(o => o.IntersectionDetailID == ((from q in DB.IntersectionDetail
                                                                                    where q.TwoVer == IntersectionDetailID + ""
                                                                                    select q.IntersectionDetailID).FirstOrDefault()));
                updateVer2.Monday = json.Monday;
                updateVer2.Tuesday = json.Tuesday;
                updateVer2.Wednesday = json.Wednesday;
                updateVer2.Thursday = json.Thursday;
                updateVer2.Friday = json.Friday;
                updateVer2.Saturday = json.Saturday;
                updateVer2.Sunday = json.Sunday;
                DB.SubmitChanges();
            }
        }
        else if (postType.Equals("insertTimeIntervalType"))
        {
            string TimeType = strJson.Split(',')[1];
            int IntersectionDetailID = Int32.Parse(strJson.Split(',')[0]);

            TimeIntervalType st = new TimeIntervalType
            {
                TimeType = TimeType,
                IntersectionDetailID = IntersectionDetailID
            };
            DB.TimeIntervalType.InsertOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("deleteTimeType"))
        {
            int TimeIntervalTypeID = Int32.Parse(strJson);
            TimeIntervalType st = DB.TimeIntervalType.First(c => c.TimeIntervalTypeID == TimeIntervalTypeID);
            DB.TimeIntervalType.DeleteOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("insertTimeIntervalTypeDetail"))
        {
            dynamic json = JValue.Parse(strJson);
            TimeIntervalTypeDetail st = new TimeIntervalTypeDetail
            {
                TimeIntervalTypeID = json.id,
                Hour = json.timeTypeHour,
                Minute = json.timeTypeMinute
            };
            DB.TimeIntervalTypeDetail.InsertOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("editTimeIntervalTypeDetail"))
        {
            dynamic json = JValue.Parse(strJson);
            int TimeIntervalTypeID = json.TimeIntervalTypeID;
            var delete = from a in DB.TimeIntervalTypeDetail
                         where a.TimeIntervalTypeID == TimeIntervalTypeID
                         select a;
            DB.TimeIntervalTypeDetail.DeleteAllOnSubmit(delete);

            foreach (dynamic temp in json.TimeIntervalTypeDetail)
            {
                TimeIntervalTypeDetail insert = new TimeIntervalTypeDetail
                {
                    TimeIntervalTypeID = json.TimeIntervalTypeID,
                    Hour = temp.Hour,
                    Minute = temp.Minute,
                    TimePlanSN = temp.TimePlanSN
                };
                DB.TimeIntervalTypeDetail.InsertOnSubmit(insert);
            }
            DB.SubmitChanges();
        }
        else if (postType.Equals("editTimePlan"))
        {
            dynamic json = JValue.Parse(strJson);
            int IntersectionDetailID = json.IntersectionDetailID;
            var delete = from a in DB.TimePlan
                         where a.IntersectionDetailID == IntersectionDetailID
                         select a;
            DB.TimePlan.DeleteAllOnSubmit(delete);
            foreach (dynamic temp in json.TimePlan)
            {
                TimePlan insert = new TimePlan
                {
                    IntersectionDetailID = json.IntersectionDetailID,
                    TimePlanSN = temp.TimePlanSN,
                    TimePhaseSN = temp.TimePhaseSN,
                    TimeDiff = temp.TimeDiff,
                    TimeCycle = temp.TimeCycle
                };
                DB.TimePlan.InsertOnSubmit(insert);
            }

            foreach (dynamic temp in json.TimePhase)
            {
                int id = temp.TimePhaseID;
                var delete1 = from a in DB.TimePhaseDetail
                              where a.TimePhaseID == id
                              select a;
                DB.TimePhaseDetail.DeleteAllOnSubmit(delete1);
            }
            foreach (dynamic temp in json.TimePhase)
            {
                foreach (dynamic temp1 in temp.TimePhaseDetail)
                {
                    TimePhaseDetail insert = new TimePhaseDetail
                    {
                        TimePhaseID = temp1.TimePhaseID,
                        TimePlanSN = temp1.TimePlanSN,
                        PH = temp1.PH,
                        G = temp1.G,
                        Y = temp1.Y,
                        R = temp1.R,
                    };
                    DB.TimePhaseDetail.InsertOnSubmit(insert);
                }
            }

            DB.SubmitChanges();

        }
        else if (postType.Equals("timePlanInsert"))
        {
            dynamic json = JValue.Parse(strJson);
            TimePlan st = new TimePlan
            {
                IntersectionDetailID = json.id,
                TimePlanSN = json.TimePlanSN,
                TimePhaseSN = json.TimePhaseSN,
                TimeDiff = json.TimeDiff,
                TimeCycle = json.TimeCycle
            };
            DB.TimePlan.InsertOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("insertTimePhase"))
        {
            int IntersectionDetailID = Int32.Parse(strJson);
            TimePhase st = new TimePhase
            {
                IntersectionDetailID = IntersectionDetailID,
                ImgSrc = "img/nopic.jpg"
            };
            DB.TimePhase.InsertOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("deleteTimePhase"))
        {
            int TimePhaseID = Int32.Parse(strJson);
            TimePhase st = DB.TimePhase.First(c => c.TimePhaseID == TimePhaseID);
            DB.TimePhase.DeleteOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("insertTimePhaseDetail"))
        {
            dynamic json = JValue.Parse(strJson);
            TimePhaseDetail st = new TimePhaseDetail
            {
                TimePhaseID = json.id,
                PH = json.PH,
                G = json.G,
                Y = json.Y,
                R = json.R
            };
            DB.TimePhaseDetail.InsertOnSubmit(st);
            DB.SubmitChanges();
        }
        else if (postType.Equals("editTimePhase"))
        {
            dynamic json = JValue.Parse(strJson);
            int TimePhaseID = json.TimePhaseID;
            var delete = from a in DB.TimePhaseDetail
                         where a.TimePhaseID == TimePhaseID
                         select a;
            DB.TimePhaseDetail.DeleteAllOnSubmit(delete);

            var updateVer = DB.TimePhase.First(o => o.TimePhaseID == TimePhaseID);
            updateVer.TimePhaseRoad = json.TimePhaseRoad;
            updateVer.ImgSrc = json.ImgSrc;

            if (json.TimePhaseDetail != null)
            {
                foreach (dynamic temp in json.TimePhaseDetail)
                {
                    TimePhaseDetail insert = new TimePhaseDetail
                    {
                        TimePhaseID = json.TimePhaseID,
                        PH = temp.PH,
                        G = temp.G,
                        Y = temp.Y,
                        R = temp.R,
                        TimePlanSN = temp.TimePlanSN
                    };
                    DB.TimePhaseDetail.InsertOnSubmit(insert);
                }
            }
            DB.SubmitChanges();
        }
        else if (postType.Equals("updateBase"))
        {
            dynamic json = JValue.Parse(strJson);
            int id = json.IntersectionID;
            var updateBase = DB.Intersection.First(o => o.IntersectionID == id);
            updateBase.Position = json.Position;
            updateBase.RoadName = json.RoadName;
            updateBase.ENumber = json.ENumber;
            updateBase.Zone = json.Zone;
            updateBase.EmployeeID = MapRoadLoginID;
            DB.SubmitChanges();
        }
        else if (postType.Equals("newVer"))
        {
            int IntersectionID = Int32.Parse(strJson);
            //將過去版本鎖定編輯
            var IntersectionDetail2 = DB.IntersectionDetail.Where(x => x.IntersectionID == IntersectionID);
            foreach (var temp in IntersectionDetail2)
            {
                temp.State = "0";
            }
            DB.SubmitChanges();
            createNewVer(IntersectionID,MapRoadLoginID);
            DB.SubmitChanges();
        }
        else if (postType.Equals("verDelete"))
        {
            dynamic json = JValue.Parse(strJson);
            int IntersectionDetailID = json.IntersectionDetailID;
            IntersectionDetail IntersectionDetail = DB.IntersectionDetail.First(c => c.IntersectionDetailID == IntersectionDetailID);
            DB.IntersectionDetail.DeleteOnSubmit(IntersectionDetail);
            string twoVer = json.TwoVer2;
            if (twoVer.Equals("1"))
            {
                var update = DB.IntersectionDetail.First(c => c.TwoVer == IntersectionDetailID + "");
                update.TwoVer = "0";
                update.EmployeeID = MapRoadLoginID;
            }
            else if (!twoVer.Equals("0") && !twoVer.Equals("1"))
            {
                IntersectionDetail IntersectionDetail2 = DB.IntersectionDetail.First(c => c.IntersectionDetailID == Convert.ToInt32(twoVer));
                DB.IntersectionDetail.DeleteOnSubmit(IntersectionDetail2);
            }
            DB.SubmitChanges();
        }
        else if (postType.Equals("roadDelete"))
        {
            int IntersectionID = Int32.Parse(strJson);

            var Intersection = DB.Intersection.First(o => o.IntersectionID == IntersectionID);

            Intersection.State = "0";
            Intersection.EmployeeID = MapRoadLoginID;
            DB.SubmitChanges();
        }
        else if (postType.Equals("newTwoVer"))
        {
            dynamic json = JValue.Parse(strJson);
            int IntersectionID = json.IntersectionID;
            int IntersectionDetailID = json.IntersectionDetailID;
            System.Globalization.CultureInfo tc = new System.Globalization.CultureInfo("zh-TW");
            tc.DateTimeFormat.Calendar = new System.Globalization.TaiwanCalendar();
            string dd = json.VersionDate;
            string gg = "";
            string kkk = json.GPS;
            if (kkk.Equals("裝設"))
            {
                gg = "1";
            }
            else
            {
                gg = "0";
            }
            IntersectionDetail st = new IntersectionDetail
            {
                IntersectionID = IntersectionID,
                State = "1",
                TwoVer = "1",
                Controller = json.Controller,
                GPS = gg,
                Remark = json.Remark,
                Src = json.Src,
                EmployeeID = MapRoadLoginID,
                VersionDate = DateTime.Parse(dd, tc).Date
            };
            DB.IntersectionDetail.InsertOnSubmit(st);
            DB.SubmitChanges();


            var updateVer = DB.IntersectionDetail.First(o => o.IntersectionDetailID == IntersectionDetailID);
            updateVer.TwoVer = st.IntersectionDetailID + "";
            foreach (dynamic temp in json.TimeIntervalType)
            {
                TimeIntervalType bb1 = new TimeIntervalType
                {
                    TimeType = temp.TimeType,
                    IntersectionDetailID = st.IntersectionDetailID
                };
                DB.TimeIntervalType.InsertOnSubmit(bb1);
                DB.SubmitChanges();
                foreach (dynamic temp2 in temp.TimeIntervalTypeDetail)
                {
                    TimeIntervalTypeDetail insert2 = new TimeIntervalTypeDetail
                    {
                        TimeIntervalTypeID = bb1.TimeIntervalTypeID,
                        Hour = temp2.Hour,
                        Minute = temp2.Minute,
                        TimePlanSN = temp2.TimePlanSN
                    };
                    DB.TimeIntervalTypeDetail.InsertOnSubmit(insert2);
                }
                DB.SubmitChanges();
            }


            WeekType st2 = new WeekType
            {
                IntersectionDetailID = st.IntersectionDetailID,
                Monday = json.WeekType.Monday,
                Tuesday = json.WeekType.Tuesday,
                Wednesday = json.WeekType.Wednesday,
                Thursday = json.WeekType.Thursday,
                Friday = json.WeekType.Friday,
                Saturday = json.WeekType.Saturday,
                Sunday = json.WeekType.Sunday
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
            context.Response.Write(st.IntersectionDetailID + "");

        }
        else
        {
            throw new Exception("錯誤喔");
        }
    }


    public void createNewVer(int IntersectionID,string MapRoadLoginID)
    {
        var json = (from p in DB.IntersectionDetail
                    where p.IntersectionDetailID == ((from o in DB.IntersectionDetail
                                                      where o.IntersectionID == IntersectionID && o.TwoVer != "1"
                                                      orderby o.IntersectionDetailID descending
                                                      select o.IntersectionDetailID).FirstOrDefault())
                    select new
                    {
                        p.IntersectionID,
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
                        p.GPS,
                        p.Remark,
                        p.VersionDate,
                        p.TwoVer,
                        p.Src,
                        p.EmployeeID,
                        p.ModifiedDate
                    }).FirstOrDefault();

        //新增IntersectionDetail
        IntersectionDetail st = new IntersectionDetail
        {
            IntersectionID = json.IntersectionID,
            State = "1",
            TwoVer = "0",
            Controller = json.Controller,
            GPS = json.GPS,
            Remark = json.Remark,
            Src = json.Src,
            EmployeeID = MapRoadLoginID,
            VersionDate = DateTime.Now
        };
        DB.IntersectionDetail.InsertOnSubmit(st);
        DB.SubmitChanges();

        //新增WeekType
        WeekType st2 = new WeekType
        {
            IntersectionDetailID = st.IntersectionDetailID,
            Monday = json.WeekType.Monday,
            Tuesday = json.WeekType.Tuesday,
            Wednesday = json.WeekType.Wednesday,
            Thursday = json.WeekType.Thursday,
            Friday = json.WeekType.Friday,
            Saturday = json.WeekType.Saturday,
            Sunday = json.WeekType.Sunday
        };
        DB.WeekType.InsertOnSubmit(st2);
        DB.SubmitChanges();

        //新增TimeIntervalType
        foreach (dynamic temp in json.TimeIntervalType)
        {
            TimeIntervalType st3 = new TimeIntervalType
            {
                TimeType = temp.TimeType,
                IntersectionDetailID = st.IntersectionDetailID
            };
            DB.TimeIntervalType.InsertOnSubmit(st3);
            DB.SubmitChanges();
            foreach (dynamic temp2 in temp.TimeIntervalTypeDetail)
            {
                TimeIntervalTypeDetail st4 = new TimeIntervalTypeDetail
                {
                    TimeIntervalTypeID = st3.TimeIntervalTypeID,
                    Hour = temp2.Hour,
                    Minute = temp2.Minute,
                    TimePlanSN = temp2.TimePlanSN
                };
                DB.TimeIntervalTypeDetail.InsertOnSubmit(st4);
            }
            DB.SubmitChanges();
        }

        //新增TimePhase
        foreach (dynamic temp in json.TimePhase)
        {
            TimePhase st5 = new TimePhase
            {
                IntersectionDetailID = st.IntersectionDetailID,
                ImgSrc = temp.ImgSrc,
                TimePhaseRoad = temp.TimePhaseRoad
            };
            DB.TimePhase.InsertOnSubmit(st5);
            DB.SubmitChanges();
            foreach (dynamic temp2 in temp.TimePhaseDetail)
            {
                TimePhaseDetail st6 = new TimePhaseDetail
                {
                    TimePhaseID = st5.TimePhaseID,
                    TimePlanSN = temp2.TimePlanSN,
                    PH = temp2.PH + "",
                    G = temp2.G + "",
                    Y = temp2.Y + "",
                    R = temp2.R + ""
                };
                DB.TimePhaseDetail.InsertOnSubmit(st6);
            }
            DB.SubmitChanges();
        }

        //新增TimePlan
        foreach (dynamic temp in json.TimePlan)
        {
            TimePlan st7 = new TimePlan
            {
                IntersectionDetailID = st.IntersectionDetailID,
                TimePlanSN = temp.TimePlanSN + "",
                TimePhaseSN = temp.TimePhaseSN + "",
                TimeDiff = temp.TimeDiff + ""
            };
            DB.TimePlan.InsertOnSubmit(st7);
        }
        DB.SubmitChanges();
        string TwoVer = json.TwoVer;
        if (!TwoVer.Equals("0"))
        {
            createTwoVer(Int32.Parse(TwoVer), st.IntersectionDetailID,MapRoadLoginID);
        }
    }



    public void createTwoVer(int IntersectionDetailID, int IntersectionDetailID2,string MapRoadLoginID)
    {
        var json = (from p in DB.IntersectionDetail
                    where p.IntersectionDetailID == IntersectionDetailID
                    select new
                    {
                        p.IntersectionID,
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
                        p.GPS,
                        p.Remark,
                        p.VersionDate,
                        p.TwoVer,
                        p.Src,
                        p.EmployeeID,
                        p.ModifiedDate
                    }).FirstOrDefault();

        //新增IntersectionDetail
        IntersectionDetail st = new IntersectionDetail
        {
            IntersectionID = json.IntersectionID,
            State = "1",
            TwoVer = "1",
            Controller = json.Controller,
            GPS = json.GPS,
            Remark = json.Remark,
            Src = json.Src,
            EmployeeID = MapRoadLoginID,
            VersionDate = DateTime.Now
        };
        DB.IntersectionDetail.InsertOnSubmit(st);
        DB.SubmitChanges();

        var update = DB.IntersectionDetail.First(o => o.IntersectionDetailID == IntersectionDetailID2);
        update.TwoVer = st.IntersectionDetailID + "";
        DB.SubmitChanges();

        //新增WeekType
        WeekType st2 = new WeekType
        {
            IntersectionDetailID = st.IntersectionDetailID,
            Monday = json.WeekType.Monday,
            Tuesday = json.WeekType.Tuesday,
            Wednesday = json.WeekType.Wednesday,
            Thursday = json.WeekType.Thursday,
            Friday = json.WeekType.Friday,
            Saturday = json.WeekType.Saturday,
            Sunday = json.WeekType.Sunday
        };
        DB.WeekType.InsertOnSubmit(st2);
        DB.SubmitChanges();

        //新增TimeIntervalType
        foreach (dynamic temp in json.TimeIntervalType)
        {
            TimeIntervalType st3 = new TimeIntervalType
            {
                TimeType = temp.TimeType,
                IntersectionDetailID = st.IntersectionDetailID
            };
            DB.TimeIntervalType.InsertOnSubmit(st3);
            DB.SubmitChanges();
            foreach (dynamic temp2 in temp.TimeIntervalTypeDetail)
            {
                TimeIntervalTypeDetail st4 = new TimeIntervalTypeDetail
                {
                    TimeIntervalTypeID = st3.TimeIntervalTypeID,
                    Hour = temp2.Hour,
                    Minute = temp2.Minute,
                    TimePlanSN = temp2.TimePlanSN
                };
                DB.TimeIntervalTypeDetail.InsertOnSubmit(st4);
            }
            DB.SubmitChanges();
        }

        //新增TimePhase
        foreach (dynamic temp in json.TimePhase)
        {
            TimePhase st5 = new TimePhase
            {
                IntersectionDetailID = st.IntersectionDetailID,
                ImgSrc = temp.ImgSrc,
                TimePhaseRoad = temp.TimePhaseRoad
            };
            DB.TimePhase.InsertOnSubmit(st5);
            DB.SubmitChanges();
            foreach (dynamic temp2 in temp.TimePhaseDetail)
            {
                TimePhaseDetail st6 = new TimePhaseDetail
                {
                    TimePhaseID = st5.TimePhaseID,
                    TimePlanSN = temp2.TimePlanSN,
                    PH = temp2.PH + "",
                    G = temp2.G + "",
                    Y = temp2.Y + "",
                    R = temp2.R + ""
                };
                DB.TimePhaseDetail.InsertOnSubmit(st6);
            }
            DB.SubmitChanges();
        }

        //新增TimePlan
        foreach (dynamic temp in json.TimePlan)
        {
            TimePlan st7 = new TimePlan
            {
                IntersectionDetailID = st.IntersectionDetailID,
                TimePlanSN = temp.TimePlanSN + "",
                TimePhaseSN = temp.TimePhaseSN + "",
                TimeDiff = temp.TimeDiff + ""
            };
            DB.TimePlan.InsertOnSubmit(st7);
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