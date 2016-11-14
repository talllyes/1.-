<%@ WebHandler Language="C#" Class="rootSearch" %>

using System;
using System.Web;
using System.IO;
using Newtonsoft.Json;
using System.Linq;
using System.Collections.Generic;

public class rootSearch : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {


        string InitDirectory = AppDomain.CurrentDomain.BaseDirectory + @"excel\";
        string[] sss = Directory.GetDirectories(InitDirectory);
        List<rootb> myStringLists = new List<rootb>();
        foreach (string s in sss)
        {
            rootb a = new rootb();
            a.fileroot = Path.GetFileName(s);
            string folderName = AppDomain.CurrentDomain.BaseDirectory + @"excel\" + Path.GetFileName(s) + @"\";
            foreach (string fname in System.IO.Directory.GetFileSystemEntries(folderName))
            {
                a.excel.Add(Path.GetFileName(fname));
            }
            myStringLists.Add(a);
        }
        context.Response.ContentType = "text/plain";
        context.Response.Write(JsonConvert.SerializeObject(myStringLists));
    }
    class rootb
    {
        public string fileroot;
        public List<string> excel;
        public rootb()
        {
            excel = new List<string>();
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