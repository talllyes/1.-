<%@ WebHandler Language="C#" Class="getTrafficLightHandler" %>

using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;

public class getTrafficLightHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {

        int id = Convert.ToInt32(context.Request["intersectionDetailId"]);
        //id = 130;

        DataClassesDataContext db = new DataClassesDataContext();

        var json = db.IntersectionDetail.Single(p => p.IntersectionDetailID == id).TrafficLightJson;                    

        context.Response.ContentType = "text/plain";
        context.Response.Write(json);

    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}