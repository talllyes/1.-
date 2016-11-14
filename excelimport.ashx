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
        DataClassesDataContext DB = new DataClassesDataContext();
        HSSFWorkbook wk;
        HSSFSheet hst;
        HSSFRow hr;
        using (FileStream file = new FileStream(AppDomain.CurrentDomain.BaseDirectory + "excel\\一心路段.xls", FileMode.Open, FileAccess.Read))
        {
            wk = new HSSFWorkbook(file);
        }

        int i = 0;
        bool flag = true;
        hst = (HSSFSheet)wk.GetSheetAt(0);
        hr = (HSSFRow)hst.GetRow(0);
        if (hr.GetCell(0).ToString().Equals("區域"))
        {
            Intersection st = new Intersection
            {
                State = "1",
                EmployeeID = "system",
                ENumber = (hr.GetCell(47) == null ? "" : hr.GetCell(47).ToString())
            };
            DB.Intersection.InsertOnSubmit(st);
            DB.SubmitChanges();
            int id = st.IntersectionID;
            while (flag)
            {
                //更新Intersection
                //hr = (HSSFRow)hst.GetRow(i + 1);
                //string Zone = (hr.GetCell(0) == null ? "" : hr.GetCell(0).ToString());
                //hr = (HSSFRow)hst.GetRow(i + 3);
                //string RoadName = (hr.GetCell(0) == null ? "0" : hr.GetCell(0).ToString()).Replace(" ", "").Replace("\n", "<br />");
                //var updateBase = DB.Intersection.First(o => o.IntersectionID == id);
                //updateBase.RoadName = "12";
                //updateBase.Zone = "12";

                //DB.SubmitChanges();


                //將舊的IntersectionDetail設為不可編輯
                var IntersectionDetail2 = (from x in DB.IntersectionDetail
                                           where x.IntersectionID == id
                                           select x);
                if (IntersectionDetail2 != null)
                {
                    foreach (var temp in IntersectionDetail2)
                    {
                        temp.State = "0";
                    }
                    DB.SubmitChanges();
                }

                //新增IntersectionDetail
                hr = (HSSFRow)hst.GetRow(i + 7);
                string Controller = (hr.GetCell(0) == null ? "" : hr.GetCell(0).ToString());
                hr = (HSSFRow)hst.GetRow(i + 3);
                string GPS = ((hr.GetCell(40).CellStyle.FillForegroundColor + "") != "64" ? "1" : "0");
                hr = (HSSFRow)hst.GetRow(i + 5);
                string Remark = (hr.GetCell(40) == null ? "" : hr.GetCell(40).ToString());
                hr = (HSSFRow)hst.GetRow(i + 1);
                string VersionDate = (hr.GetCell(40) == null ? "" : hr.GetCell(40).ToString()).Replace(".", "-");
                System.Globalization.CultureInfo tc = new System.Globalization.CultureInfo("zh-TW");
                tc.DateTimeFormat.Calendar = new System.Globalization.TaiwanCalendar();
                var dd = DateTime.Parse(VersionDate, tc).Date;
                IntersectionDetail st2 = new IntersectionDetail
                {
                    IntersectionID = id,
                    Controller = Controller,
                    GPS = GPS,
                    Remark = Remark,
                    VersionDate = dd,
                    State = "1",
                    EmployeeID = "system",
                    TwoVer = "0"
                };
                DB.IntersectionDetail.InsertOnSubmit(st2);
                DB.SubmitChanges();


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
                        TimePlan qt1 = new TimePlan
                        {
                            IntersectionDetailID = st2.IntersectionDetailID,
                            TimePlanSN = TimePlanSN,
                            TimePhaseSN = TimePhaseSN,
                            TimeDiff = TimeDiff
                        };
                        DB.TimePlan.InsertOnSubmit(qt1);
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
                                TimeIntervalTypeDetail qt2 = new TimeIntervalTypeDetail
                                {
                                    TimeIntervalTypeID = qt1.TimeIntervalTypeID,
                                    Hour = Hour,
                                    Minute = Minute,
                                    TimePlanSN = TimePlanSN
                                };
                                DB.TimeIntervalTypeDetail.InsertOnSubmit(qt2);
                            }
                        }
                        DB.SubmitChanges();
                    }
                }

                //新增TimePhase&TimePhaseDetail
                for (int y = 0; y < 6; y++)
                {
                    hr = (HSSFRow)hst.GetRow(i + 1);
                    if (hr.GetCell(10 + (y * 5)) != null && !hr.GetCell(10 + (y * 5)).ToString().Equals(""))
                    {
                        string TimePhaseRoad = hr.GetCell(10 + (y * 5)).ToString();
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
                                string TimePlanSN = (hr.GetCell(6) == null ? "" : hr.GetCell(6).ToString());
                                int Y = StringToInt(hr.GetCell(13 + (y * 5)).ToString());
                                int R = StringToInt(hr.GetCell(14 + (y * 5)).ToString());
                                int PH = StringToInt(hr.GetCell(10 + (y * 5)).ToString());
                                int G = StringToInt(hr.GetCell(11 + (y * 5)).ToString());
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
                }
                else if (!hr.GetCell(0).ToString().Equals("區域"))
                {
                    flag = false;
                }
            }
        }
        context.Response.ContentType = "text/plain";
        context.Response.Write("KK");
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