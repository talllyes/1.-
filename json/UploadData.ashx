<%@ WebHandler Language="C#" Class="PostUpdateBase" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;

public class PostUpdateBase : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string postType = "";
        if (context.Request.QueryString["type"] != null)
        {
            postType = context.Request.QueryString["type"].ToString();
        }
        if (postType.Equals("img"))
        {
            HttpPostedFile aFile = context.Request.Files[0];
            string appPath = context.Request.PhysicalApplicationPath;
            string name = DateTime.Now.ToString("yyyyMMddHHmmss") + System.IO.Path.GetExtension(aFile.FileName);
            string savePath = appPath + "upload/timePhaseImg/" + name;
            aFile.SaveAs(savePath);
            context.Response.ContentType = "text/plain";
            context.Response.Write(name);
        }
        else if (postType.Equals("data"))
        {
            HttpPostedFile aFile = context.Request.Files[0];
            string appPath = context.Request.PhysicalApplicationPath;
            string name = DateTime.Now.ToString("yyyyMMddHHmmss") + System.IO.Path.GetExtension(aFile.FileName);
            string savePath = appPath + "upload/jobData/" + name;
            aFile.SaveAs(savePath);
            context.Response.ContentType = "text/plain";
            context.Response.Write(name);
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