<%@ WebHandler Language="C#" Class="getTimePhaseDescriptionHandler" %>

using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;

public class getTimePhaseDescriptionHandler : IHttpHandler {

    public void ProcessRequest (HttpContext context) {

        int id = Convert.ToInt32(context.Request["intersectionDetailId"]);
        //id = 170;

        DataClassesDataContext db = new DataClassesDataContext();

        var description = from d in db.TimePhase
                          where d.IntersectionDetailID == id
                          orderby d.TimePhaseID ascending
                          select d.TimePhaseRoad;
        string json = JsonConvert.SerializeObject(description);

        context.Response.ContentType = "text/plain";
        context.Response.Write(json);
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}