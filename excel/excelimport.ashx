<%@ WebHandler Language="C#" Class="excelimport" %>

using System;
using System.Web;
using System.IO;
using NPOI.HSSF.UserModel;
using System.Linq;
public class excelimport : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        string fileroot = context.Request.QueryString["fileroot"];
        string fname = context.Request.QueryString["name"];
        string now = DateTime.Now.ToString("yyyyMMddHHmm");
        DataClassesDataContext DB = new DataClassesDataContext();
        DataClassesDataContext DB2 = new DataClassesDataContext();
        string error = "";
        System.Globalization.CultureInfo tc = new System.Globalization.CultureInfo("zh-TW");
        tc.DateTimeFormat.Calendar = new System.Globalization.TaiwanCalendar();
        string folderName = AppDomain.CurrentDomain.BaseDirectory + @"excel\" + fileroot + @"\" + fname;
        HSSFWorkbook wk;
        HSSFSheet hst;
        HSSFRow hr;
        if (!fname.Equals("Thumbs.db"))
        {
            using (FileStream file = new FileStream(folderName, FileMode.Open, FileAccess.Read))
            {
                wk = new HSSFWorkbook(file);
            }
            int sheetNum = wk.NumberOfSheets;
            for (int pp = 0; pp < sheetNum; pp++)
            {
                hst = (HSSFSheet)wk.GetSheetAt(pp);
                hr = (HSSFRow)hst.GetRow(0);
                string excelname = "(" + hst.SheetName + ")";
                int i = 0;
                bool flag = true;
                if (hr.GetCell(0).ToString().Equals("區域"))
                {
                    Intersection st = new Intersection
                    {
                        State = "1",
                        EmployeeID = "system" + now,
                        ENumber = (hr.GetCell(46) == null ? "" : hr.GetCell(46).ToString())
                    };
                    DB2.Intersection.InsertOnSubmit(st);
                    DB2.SubmitChanges();
                    int id = st.IntersectionID;
                    var updateBase = DB2.Intersection.First(o => o.IntersectionID == id);
                    int notnum = 2;
                    bool notflag = true;
                    hr = (HSSFRow)hst.GetRow(notnum);
                    if (notnum > hst.LastRowNum)
                    {
                        notflag = false;
                    }
                    else if (hr.Count() == 0)
                    {
                        notflag = false;
                    }
                    else if (hr.GetCell(45) == null || hr.GetCell(45).ToString().Equals(""))
                    {
                        notflag = false;
                    }
                    while (notflag)
                    {
                        string Who = (hr.GetCell(45) == null ? "" : hr.GetCell(45).ToString()).Replace(" ", "").Replace("\n", "<br />");
                        string[] year = (hr.GetCell(46) == null ? "" : hr.GetCell(46).ToString()).Split('\n')[0].Split('/');
                        string NoticeContent = (hr.GetCell(47) == null ? "" : hr.GetCell(47).ToString()).Replace(" ", "").Replace("\n", "<br />");
                        string Result = (hr.GetCell(48) == null ? "" : hr.GetCell(48).ToString()).Replace(" ", "").Replace("\n", "<br />");
                        string Remark = (hr.GetCell(49) == null ? "" : hr.GetCell(49).ToString()).Replace(" ", "").Replace("\n", "<br />");
                        string NoticeDate = "2000-01-01";
                        DateTime dd = Convert.ToDateTime(NoticeDate);
                        try
                        {
                            NoticeDate = Int32.Parse(year[0]) + 1911 + "-" + year[1] + "-" + year[2] + " " + (hr.GetCell(46) == null ? "" : hr.GetCell(46).ToString()).Split('\n')[1];
                            dd = Convert.ToDateTime(NoticeDate);
                        }
                        catch
                        {
                            error = error + "IntersectionID：" + id + ">" + excelname + "第" + (notnum + 1) + "列：通報日期不正確" + "<br />";
                        }
                        if (NoticeContent.Length > 300)
                        {
                            NoticeContent = "";
                            error = error + "IntersectionID：" + id + ">" + excelname + "第" + (notnum + 1) + "列：通報內容太長了" + "<br />";
                        }
                        if (Result.Length > 300)
                        {
                            Result = "";
                            error = error + "IntersectionID：" + id + ">" + excelname + "第" + (notnum + 1) + "列：結果太長了" + "<br />";
                        }
                        if (Remark.Length > 150)
                        {
                            Remark = "";
                            error = error + "IntersectionID：" + id + ">" + excelname + "第" + (notnum + 1) + "列：備註太長了" + "<br />";
                        }
                        if (Who.Length > 29)
                        {
                            Who = "";
                            error = error + "IntersectionID：" + id + ">" + excelname + "第" + (notnum + 1) + "列：通報單位太長了" + "<br />";
                        }
                        Notice notice = new Notice
                        {
                            IntersectionID = id,
                            Who = Who,
                            NoticeDate = dd,
                            NoticeContent = NoticeContent,
                            Result = Result,
                            Remark = Remark,
                            EmployeeID = "system" + now
                        };
                        DB.Notice.InsertOnSubmit(notice);
                        notnum = notnum + 2;
                        hr = (HSSFRow)hst.GetRow(notnum);
                        if (notnum > hst.LastRowNum)
                        {
                            notflag = false;
                        }
                        else if (hr.Count() == 0)
                        {
                            notflag = false;
                        }
                        else if (hr.GetCell(45) == null || hr.GetCell(45).ToString().Equals(""))
                        {
                            notflag = false;
                        }
                        DB.SubmitChanges();
                    }
                    while (flag)
                    {
                        //更新Intersection
                        hr = (HSSFRow)hst.GetRow(i + 1);
                        string Zone = (hr.GetCell(0) == null ? "" : hr.GetCell(0).ToString());
                        hr = (HSSFRow)hst.GetRow(i + 3);
                        string RoadName = (hr.GetCell(0) == null ? "0" : hr.GetCell(0).ToString()).Replace(" ", "").Replace("\n", "<br />");

                        if (RoadName.Length > 99)
                        {
                            RoadName = "";
                            error = error + "IntersectionID：" + id + ">" + excelname + "第" + (i + 2) + "列：路口名稱太長了" + "<br />";
                        }
                        if (Zone.Length > 19)
                        {
                            Zone = "";
                            error = error + "IntersectionID：" + id + ">" + excelname + "第" + (i + 4) + "列：地區太長了" + "<br />";
                        }
                        updateBase.RoadName = RoadName;
                        updateBase.Zone = Zone;

                        ////將舊的IntersectionDetail設為不可編輯
                        //var IntersectionDetail2 = (from x in DB.IntersectionDetail
                        //                           where x.IntersectionID == id
                        //                           select x);
                        //if (IntersectionDetail2 != null)
                        //{
                        //    foreach (var temp in IntersectionDetail2)
                        //    {
                        //        temp.State = "0";
                        //    }
                        //    DB.SubmitChanges();
                        //}

                        //新增IntersectionDetail
                        string Controller = "";
                        hr = (HSSFRow)hst.GetRow(i + 7);
                        if (hr.GetCell(0).ToString().Equals("設備編號"))
                        {
                            hr = (HSSFRow)hst.GetRow(i + 6);
                            Controller = (hr.GetCell(0) == null ? "" : hr.GetCell(0).ToString());
                            hr = (HSSFRow)hst.GetRow(i + 8);
                            Controller = Controller + " " + (hr.GetCell(0) == null ? "" : hr.GetCell(0).ToString());
                        }
                        else
                        {
                            hr = (HSSFRow)hst.GetRow(i + 7);
                            Controller = (hr.GetCell(0) == null ? "" : hr.GetCell(0).ToString());
                        }
                        Controller = Controller.Replace(" ", "");
                        if (Controller.Length > 19)
                        {
                            error = error + "ControllerID：" + id + ">" + excelname + "第" + (i + 4) + "列：控制項太長了" + "<br />";
                            Controller = "";
                        }
                        hr = (HSSFRow)hst.GetRow(i + 3);
                        string GPS = ((hr.GetCell(40).CellStyle.FillForegroundColor + "") != "23" ? "0" : "1");
                        hr = (HSSFRow)hst.GetRow(i + 5);
                        string Remark = (hr.GetCell(40) == null ? "" : hr.GetCell(40).ToString()).Replace(" ", "").Replace("\n", "<br />");
                        hr = (HSSFRow)hst.GetRow(i + 1);
                        string VersionDate = (hr.GetCell(40) == null ? "" : hr.GetCell(40).ToString()).Replace(".", "-");
                        bool rak = false;
                        if (Remark.Length > 149)
                        {
                            Remark = "";
                            rak = true;
                        }
                        var dd = DateTime.Parse("90-01-01", tc).Date;
                        bool cat = false;
                        try
                        {
                            dd = DateTime.Parse(VersionDate, tc).Date;
                        }
                        catch
                        {
                            cat = true;
                        }
                        hr = (HSSFRow)hst.GetRow(i + 3);
                        IntersectionDetail st2 = new IntersectionDetail
                        {
                            IntersectionID = id,
                            Controller = Controller,
                            GPS = GPS,
                            Remark = Remark,
                            VersionDate = dd,
                            State = "1",
                            EmployeeID = "system" + now,
                            TwoVer = "0"
                        };
                        DB.IntersectionDetail.InsertOnSubmit(st2);
                        DB.SubmitChanges();
                        if (cat)
                        {
                            error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + (i + 2) + "列：日期不正確" + "<br />";
                        }
                        if (rak)
                        {
                            error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + (i + 6) + "列：備註太長了" + "<br />";
                        }
                        hr = (HSSFRow)hst.GetRow(i + 2);
                        string Monday = (hr.GetCell(5) == null ? "" : hr.GetCell(5).ToString());
                        hr = (HSSFRow)hst.GetRow(i + 3);
                        string Tuesday = (hr.GetCell(5) == null ? "" : hr.GetCell(5).ToString());
                        hr = (HSSFRow)hst.GetRow(i + 4);
                        string Wednesday = (hr.GetCell(5) == null ? "" : hr.GetCell(5).ToString());
                        hr = (HSSFRow)hst.GetRow(i + 5);
                        string Thursday = (hr.GetCell(5) == null ? "" : hr.GetCell(5).ToString());
                        hr = (HSSFRow)hst.GetRow(i + 6);
                        string Friday = (hr.GetCell(5) == null ? "" : hr.GetCell(5).ToString());
                        hr = (HSSFRow)hst.GetRow(i + 7);
                        string Saturday = (hr.GetCell(5) == null ? "" : hr.GetCell(5).ToString());
                        hr = (HSSFRow)hst.GetRow(i + 8);
                        string Sunday = (hr.GetCell(5) == null ? "" : hr.GetCell(5).ToString());
                        if (Monday.Length > 3 || Tuesday.Length > 3 || Wednesday.Length > 3 || Thursday.Length > 3 || Friday.Length > 3 || Saturday.Length > 3 || Sunday.Length > 3)
                        {
                            error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + i + "+n列：星期內容太長了" + "<br />";
                            Monday = "";
                            Tuesday = "";
                            Wednesday = "";
                            Thursday = "";
                            Friday = "";
                            Saturday = "";
                            Sunday = "";
                        }
                        //新增WeekType
                        WeekType st3 = new WeekType
                        {
                            IntersectionDetailID = st2.IntersectionDetailID,
                            Monday = Monday,
                            Tuesday = Tuesday,
                            Wednesday = Wednesday,
                            Thursday = Thursday,
                            Friday = Friday,
                            Saturday = Saturday,
                            Sunday = Sunday
                        };
                        DB.WeekType.InsertOnSubmit(st3);
                        DB.SubmitChanges();

                        //新增TimePlan
                        for (int q = 4; q < 8; q++)
                        {
                            hr = (HSSFRow)hst.GetRow(i + q);
                            if (hr.GetCell(6) != null && !hr.GetCell(6).ToString().Equals(""))
                            {
                                string TimePlanSN = (hr.GetCell(6) == null ? "" : hr.GetCell(6).ToString());
                                string TimePhaseSN = (hr.GetCell(7) == null ? "" : hr.GetCell(7).ToString());
                                string TimeDiff = (hr.GetCell(8) == null ? "" : hr.GetCell(8).ToString());
                                if (TimePlanSN.Length < 4 && TimePhaseSN.Length < 4 && TimeDiff.Length < 4)
                                {
                                    TimePlan qt1 = new TimePlan
                                    {
                                        IntersectionDetailID = st2.IntersectionDetailID,
                                        TimePlanSN = TimePlanSN,
                                        TimePhaseSN = TimePhaseSN,
                                        TimeDiff = TimeDiff
                                    };
                                    DB.TimePlan.InsertOnSubmit(qt1);
                                }
                                else
                                {
                                    error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + (i + q + 1) + "列：計劃長度大於四" + "<br />";
                                }
                            }
                        }
                        DB.SubmitChanges();

                        //新增TimeIntervalType&TimeIntervalTypeDetail
                        for (int p = 0; p < 3; p++)
                        {
                            hr = (HSSFRow)hst.GetRow(i + 10);
                            if (hr.GetCell(p * 3) != null && !hr.GetCell(p * 3).ToString().Equals(""))
                            {
                                string TimeType = (hr.GetCell(p * 3).ToString());
                                if (TimeType.Length < 4)
                                {
                                    TimeIntervalType qt1 = new TimeIntervalType
                                    {
                                        IntersectionDetailID = st2.IntersectionDetailID,
                                        TimeType = TimeType
                                    };
                                    DB.TimeIntervalType.InsertOnSubmit(qt1);
                                    DB.SubmitChanges();
                                    for (int y = 13; y < 19; y++)
                                    {
                                        hr = (HSSFRow)hst.GetRow(i + y);
                                        if (hr.GetCell(p * 3) != null && !hr.GetCell(p * 3).ToString().Equals(""))
                                        {
                                            string Hour = hr.GetCell((p * 3) + 0).ToString();
                                            string Minute = hr.GetCell((p * 3) + 1).ToString();
                                            string TimePlanSN = hr.GetCell((p * 3) + 2).ToString();
                                            if (Hour.Length < 4 && Minute.Length < 4 && TimePlanSN.Length < 4)
                                            {
                                                TimeIntervalTypeDetail qt2 = new TimeIntervalTypeDetail
                                                {
                                                    TimeIntervalTypeID = qt1.TimeIntervalTypeID,
                                                    Hour = Hour,
                                                    Minute = Minute,
                                                    TimePlanSN = TimePlanSN
                                                };
                                                DB.TimeIntervalTypeDetail.InsertOnSubmit(qt2);
                                            }
                                            else
                                            {
                                                error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + (i + y + 1) + "列：時段類型內容長度大於四" + "<br />";
                                            }
                                        }
                                    }
                                    DB.SubmitChanges();
                                }
                                else
                                {
                                    error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + (i + 11) + "列：時段類型長度大於四" + "<br />";
                                }
                            }
                        }

                        //新增TimePhase&TimePhaseDetail
                        for (int y = 0; y < 6; y++)
                        {
                            hr = (HSSFRow)hst.GetRow(i + 1);
                            if (hr.GetCell(10 + (y * 5)) != null && !hr.GetCell(10 + (y * 5)).ToString().Equals(""))
                            {
                                string TimePhaseRoad = hr.GetCell(10 + (y * 5)).ToString();
                                if (TimePhaseRoad.Length > 200)
                                {
                                    TimePhaseRoad = "";
                                    error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + (i + 2) + "列：時相路段名稱太長了" + "<br />";
                                }
                                TimePhase qt1 = new TimePhase
                                {
                                    IntersectionDetailID = st2.IntersectionDetailID,
                                    TimePhaseRoad = TimePhaseRoad,
                                    ImgSrc = "img/nopic.jpg"
                                };
                                DB.TimePhase.InsertOnSubmit(qt1);
                                DB.SubmitChanges();

                                for (int p = 4; p < 8; p++)
                                {
                                    hr = (HSSFRow)hst.GetRow(i + p);
                                    if (hr.GetCell(6) != null && !hr.GetCell(6).ToString().Equals(""))
                                    {
                                        string TimePlanSN = "";
                                        int Y = 0;
                                        int R = 0;
                                        int PH = 0;
                                        int G = 0;
                                        try
                                        {
                                            TimePlanSN = (hr.GetCell(6) == null ? "" : hr.GetCell(6).ToString());
                                            Y = StringToInt(hr.GetCell(13 + (y * 5)).ToString());
                                            R = StringToInt(hr.GetCell(14 + (y * 5)).ToString());
                                            PH = StringToInt(hr.GetCell(10 + (y * 5)).ToString());
                                            G = StringToInt(hr.GetCell(11 + (y * 5)).ToString());
                                        }
                                        catch
                                        {
                                            error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + (i + p + 1) + "列：時相內容存有非數字" + "<br />";
                                        }
                                        if (PH == 0)
                                        {
                                            PH = G + R + Y;
                                        }
                                        else if (G == 0)
                                        {
                                            G = PH - Y - R;
                                        }
                                        TimePhaseDetail qt2 = new TimePhaseDetail
                                        {
                                            TimePhaseID = qt1.TimePhaseID,
                                            TimePlanSN = TimePlanSN,
                                            PH = PH + "",
                                            G = G + "",
                                            Y = Y + "",
                                            R = R + ""
                                        };
                                        DB.TimePhaseDetail.InsertOnSubmit(qt2);
                                    }
                                }
                            }
                            DB.SubmitChanges();
                        }
                        i = i + 23;
                        hr = (HSSFRow)hst.GetRow(i);

                        if (i > hst.LastRowNum)
                        {
                            flag = false;
                            DB2.SubmitChanges();
                        }
                        else if (hr == null)
                        {
                            flag = false;
                            DB2.SubmitChanges();
                        }
                        else if (hr.Count() == 0)
                        {
                            flag = false;
                            DB2.SubmitChanges();
                        }
                        else
                        {
                            try
                            {
                                if (!hr.GetCell(0).ToString().Equals("區域"))
                                {
                                    flag = false;
                                    DB2.SubmitChanges();
                                    if (hr.GetCell(0).ToString().Length != 0)
                                    {
                                        error = error + "IntersectionDetailID：" + st2.IntersectionDetailID + ">" + excelname + "第" + (i + 2) + "列：有值但非區域(" + hr.GetCell(0).ToString() + ")" + "<br />";
                                    }
                                }
                            }
                            catch
                            {
                                flag = false;
                                DB2.SubmitChanges();
                            }
                        }
                    }
                }
                else
                {
                    error = error + "(" + hst.SheetName + ")" + "有值但非區域<br />";
                    sheetNum = sheetNum - 1;
                }
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write(fname + "(" + sheetNum + ")<br />" + error + "," + sheetNum);


        }
        //}
        //catch
        //{
        //    context.Response.ContentType = "text/plain";
        //    context.Response.Write(fname + "未預期的錯誤<br />");
        //}
    }
    public int StringToInt(string a)
    {
        int u = 0;
        try
        {
            u = Convert.ToInt32(a);
        }
        catch
        {

        }
        return u;
    }


    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}