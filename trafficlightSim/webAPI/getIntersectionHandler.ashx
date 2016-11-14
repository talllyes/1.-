<%@ WebHandler Language="C#" Class="getIntersectionHandler" %>

using System;
using System.Web;
using System.Linq;
using Newtonsoft.Json;

public class getIntersectionHandler : IHttpHandler {

    public void ProcessRequest (HttpContext context) {

        int id = Convert.ToInt32(context.Request["intersectionDetailId"]);
        //int id = 1;

        DataClassesDataContext db = new DataClassesDataContext();
        
        var intersectionID = db.IntersectionDetail.Single(p => p.IntersectionDetailID == id).IntersectionID;

        var result = db.Intersection.Single(p => p.IntersectionID == intersectionID);

        string json = JsonConvert.SerializeObject(result);

        context.Response.ContentType = "text/plain";
        context.Response.Write(json);
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}