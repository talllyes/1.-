<%@ WebHandler Language="C#" Class="GetPostUser" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

public class GetPostUser : IHttpHandler, System.Web.SessionState.IRequiresSessionState
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
        if (postType.Equals("getUser"))
        {
            var Result = from x in DB.UserLogin
                         where x.UserID != "super"
                         orderby x.UserLoginID descending
                         select new
                         {
                             x.UserLoginID,
                             x.UserName,
                             x.UserID,
                             x.Password,
                             x.JobTitle,
                             admin = (x.admin == "1" ? true : false),
                             State = (from q in DB.UserLogin
                                      where q.UserLoginID == x.UserLoginID
                                      select new
                                      {
                                          Permission = (q.State == "1" ? true : false),
                                          Class = (q.State == "1" ? "toggle-on" : "")
                                      }).FirstOrDefault()
                         };
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getPermission"))
        {
            int userLoginID = Int32.Parse(strJson);
            var Result = (from u in DB.UserLogin
                          where u.UserLoginID == userLoginID
                          select new
                          {
                              u.UserLoginID,
                              admin = (u.admin == "1" ? true : false),
                              PermissionDetail = (from h in DB.ItemGroup
                                                  select new
                                                  {
                                                      h.ItemGroupName,
                                                      ItemName = (from p in (from x in DB.UseItem where x.ItemGroupID == h.ItemGroupID select x)
                                                                  join q in (from b in DB.Permission where b.UserLoginID == userLoginID select b) on
                                                                  p.UseItemID equals q.UseItemID
                                                                  into ps
                                                                  from o in ps.DefaultIfEmpty()
                                                                  select new
                                                                  {
                                                                      p.UseItemID,
                                                                      p.ItemName,
                                                                      Permission = (o.UserLoginID == null ? false : true),
                                                                      Class = (o.UserLoginID == null ? "" : "toggle-on")
                                                                  })
                                                  })
                          }).First();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getMapPermission"))
        {
            string userID = "";
            if (context.Session["MapRoadLoginID"] != null)
            {
                userID = context.Session["MapRoadLoginID"].ToString();
            }
            if (userID.Equals("super"))
            {
                var Result = (from u in DB.UserLogin
                              where u.UserID == userID
                              select new
                              {
                                  u.UserLoginID,
                                  u.JobTitle,
                                  u.UserName,
                                  admin = (u.admin == "1" ? true : false),
                                  ItemName = (from p in DB.UseItem
                                              join q in (from b in DB.Permission where b.UserLoginID == u.UserLoginID select b) on
                                              p.UseItemID equals q.UseItemID
                                              into ps
                                              from o in ps.DefaultIfEmpty()
                                              orderby p.UseItemID
                                              select new
                                              {
                                                  p.UseItemID,
                                                  Permission = true
                                              })
                              }).First();
                context.Response.ContentType = "text/plain";
                context.Response.Write(JsonConvert.SerializeObject(Result));
            }
            else
            {
                var Result = (from u in DB.UserLogin
                              where u.UserID == userID
                              select new
                              {
                                  u.UserLoginID,
                                  u.JobTitle,
                                  u.UserName,
                                  admin = (u.admin == "1" ? true : false),
                                  ItemName = (from p in DB.UseItem
                                              join q in (from b in DB.Permission where b.UserLoginID == u.UserLoginID select b) on
                                              p.UseItemID equals q.UseItemID
                                              into ps
                                              from o in ps.DefaultIfEmpty()
                                              orderby p.UseItemID
                                              select new
                                              {
                                                  p.UseItemID,
                                                  Permission = (o.UserLoginID == null ? false : true)
                                              })
                              }).First();
                context.Response.ContentType = "text/plain";
                context.Response.Write(JsonConvert.SerializeObject(Result));
            }

        }
        else if (postType.Equals("getNullPermission"))
        {
            int userLoginID = Int32.Parse(strJson);

            var Result = (from u in DB.UserLogin
                          where u.UserLoginID == 1
                          select new
                          {
                              u.UserLoginID,
                              admin = (u.admin == "1" ? true : false),
                              PermissionDetail = (from h in DB.ItemGroup
                                                  select new
                                                  {
                                                      h.ItemGroupName,
                                                      ItemName = (from p in (from x in DB.UseItem where x.ItemGroupID == h.ItemGroupID select x)
                                                                  join q in (from b in DB.Permission where b.UserLoginID == userLoginID select b) on
                                                                  p.UseItemID equals q.UseItemID
                                                                  into ps
                                                                  from o in ps.DefaultIfEmpty()
                                                                  select new
                                                                  {
                                                                      p.UseItemID,
                                                                      p.ItemName,
                                                                      Permission = (o.UserLoginID == null ? false : true),
                                                                      Class = (o.UserLoginID == null ? "" : "toggle-on")
                                                                  })
                                                  })
                          }).First();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("getUserMenu"))
        {
            int UserLoginID = Int32.Parse(strJson);
            var Result = (from x in DB.UserLogin
                          where x.UserLoginID == UserLoginID
                          select new
                          {
                              x.UserLoginID,
                              x.UserName,
                              x.UserID,
                              x.JobTitle,
                              admin = (from q in DB.UserLogin
                                       where q.UserLoginID == x.UserLoginID
                                       select new
                                       {
                                           Permission = (q.admin == "1" ? true : false),
                                           Class = (q.admin == "1" ? "toggle-on" : "")
                                       }).FirstOrDefault(),
                              State = (from q in DB.UserLogin
                                       where q.UserLoginID == x.UserLoginID
                                       select new
                                       {
                                           Permission = (q.State == "1" ? true : false),
                                           Class = (q.State == "1" ? "toggle-on" : "")
                                       }).FirstOrDefault()
                          }).FirstOrDefault();
            context.Response.ContentType = "text/plain";
            context.Response.Write(JsonConvert.SerializeObject(Result));
        }
        else if (postType.Equals("updateMyUser"))
        {
            dynamic json = JValue.Parse(strJson);
            string password = json.Password + "";
            int UserLoginID = Convert.ToInt32(context.Session["MapRoadLoginIDs"].ToString());
            var updateUserLogin = DB.UserLogin.First(o => o.UserLoginID == UserLoginID);
            updateUserLogin.UserName = json.UserName;
            if (!password.Equals(""))
            {
                SHA256 sha256 = new SHA256CryptoServiceProvider();
                byte[] source = Encoding.Default.GetBytes(password);
                byte[] crypto = sha256.ComputeHash(source);
                string result = Convert.ToBase64String(crypto);
                updateUserLogin.Password = result;
            }
            DB.SubmitChanges();
            context.Response.ContentType = "text/plain";
            context.Response.Write("ok");
        }
        else if (postType.Equals("updateUser"))
        {
            dynamic json = JValue.Parse(strJson);
            string password = json.Password + "";
            int UserLoginID = json.UserLoginID;
            var updateUserLogin = DB.UserLogin.First(o => o.UserLoginID == UserLoginID);
            updateUserLogin.UserName = json.UserName;
            updateUserLogin.JobTitle = json.JobTitle;
            if (!password.Equals(""))
            {
                SHA256 sha256 = new SHA256CryptoServiceProvider();
                byte[] source = Encoding.Default.GetBytes(password);
                byte[] crypto = sha256.ComputeHash(source);
                string result = Convert.ToBase64String(crypto);
                updateUserLogin.Password = result;
            }
            if ((bool)json.admin.Permission)
            {
                updateUserLogin.admin = "1";
            }
            else
            {
                updateUserLogin.admin = "0";
            }
            if ((bool)json.State.Permission)
            {
                updateUserLogin.State = "1";
            }
            else
            {
                updateUserLogin.State = "0";
            }
            DB.SubmitChanges();

            var delete = from a in DB.Permission
                         where a.UserLoginID == UserLoginID
                         select a;
            DB.Permission.DeleteAllOnSubmit(delete);
            DB.SubmitChanges();
            foreach (dynamic PermissionDetail in json.PermissionDetail)
            {
                foreach (dynamic ItemName in PermissionDetail.ItemName)
                {
                    if ((bool)ItemName.Permission)
                    {
                        Permission st = new Permission
                        {
                            UserLoginID = UserLoginID,
                            UseItemID = ItemName.UseItemID
                        };
                        DB.Permission.InsertOnSubmit(st);
                    }
                }
            }
            DB.SubmitChanges();
        }
        else if (postType.Equals("newUser"))
        {
            dynamic json = JValue.Parse(strJson);
            string userID = json.UserID;

            var res = (from s in DB.UserLogin
                       where s.UserID == userID
                       select s).Count();
            if (res == 0)
            {
                SHA256 sha256 = new SHA256CryptoServiceProvider(); string password = json.Password;
                byte[] source = Encoding.Default.GetBytes(password);
                byte[] crypto = sha256.ComputeHash(source);
                string result = Convert.ToBase64String(crypto);
                UserLogin stx = new UserLogin
                {
                    UserID = json.UserID,
                    UserName = json.UserName,
                    JobTitle = json.JobTitle,
                    Password = result,
                    State = "1",
                    admin = "0"
                };
                DB.UserLogin.InsertOnSubmit(stx);
                DB.SubmitChanges();
                foreach (dynamic PermissionDetail in json.PermissionDetail)
                {
                    foreach (dynamic ItemName in PermissionDetail.ItemName)
                    {
                        if ((bool)ItemName.Permission)
                        {
                            Permission st = new Permission
                            {
                                UserLoginID = stx.UserLoginID,
                                UseItemID = ItemName.UseItemID
                            };
                            DB.Permission.InsertOnSubmit(st);
                        }
                    }
                }
                DB.SubmitChanges();
            }
            else
            {
                context.Response.ContentType = "text/plain";
                context.Response.Write("err");
            }
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