<%@ WebHandler Language="C#" Class="saveTrafficLightHandler" %>

using System;
using System.Web;
using System.Linq;

public class saveTrafficLightHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        int id = Convert.ToInt32(context.Request["intersectionDetailId"]);
        string json = context.Request["trafficLightJson"];

        DataClassesDataContext db = new DataClassesDataContext();

        var result = db.IntersectionDetail.Single(p => p.IntersectionDetailID == id);

        result.TrafficLightJson = json;
        
        db.SubmitChanges();

        context.Response.ContentType = "text/plain";
        context.Response.Write("test");

    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}