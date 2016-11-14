<%@ WebHandler Language="C#" Class="getTimingPlansHandler" %>

using System;
using System.Web;
using System.Linq;
using System.Collections.Generic;
using Newtonsoft.Json;

public class getTimingPlansHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {

        int id = Convert.ToInt32(context.Request["intersectionDetailId"]);
        id = 1;

        DataClassesDataContext db = new DataClassesDataContext();

        var result = (from t in db.TimePhase
                      join d in db.TimePhaseDetail on t.TimePhaseID equals d.TimePhaseID
                      where t.IntersectionDetailID == id
                      group d by d.TimePlanSN into g
                      select new TimingPlan()
                      {
                          NO = g.Key,
                          Phase = (from t1 in db.TimePhase
                                   join d1 in db.TimePhaseDetail on t1.TimePhaseID equals d1.TimePhaseID
                                   where t1.IntersectionDetailID == id && d1.TimePlanSN == g.Key
                                   select new phase()
                                   {
                                       G = d1.G == null ? 0 : Convert.ToInt32(d1.G),
                                       Y = d1.Y == null ? 0 : Convert.ToInt32(d1.Y),
                                       R = d1.R == null ? 0 : Convert.ToInt32(d1.R)
                                   }).ToList()
                      }).ToList();

        List<TimingPlan> data = new List<TimingPlan>();

        foreach (var i in result)
        {
            int cycle = 0;
            foreach (var j in i.Phase)
            {
                cycle = cycle + j.G + j.Y + j.R;
            }
            if (cycle != 0)
            {
                    data.Add(i);
            }
        }

        string json = JsonConvert.SerializeObject(data);

        context.Response.ContentType = "text/plain";
        context.Response.Write(json);
    }

    public class phase
    {
        public int G { get; set; }
        public int Y { get; set; }
        public int R { get; set; }
    }

    public class TimingPlan
    {
        public string NO { get; set; }
        public List<phase> Phase { get; set; }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}