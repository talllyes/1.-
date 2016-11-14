<%@ WebHandler Language="C#" Class="intersectionDetailExcel" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NPOI;
using NPOI.HSSF.UserModel;
using NPOI.XSSF.UserModel;
using NPOI.SS.UserModel;
using System.IO;
using NPOI.SS.Util;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Drawing.Imaging;
using System.Drawing;

public class intersectionDetailExcel : IHttpHandler
{
    HSSFWorkbook workbook;
    HSSFCellStyle cs;
    RootBase roadbase;
    public void ProcessRequest(HttpContext context)
    {

        DataClassesDataContext DB = new DataClassesDataContext();

        int id = Int32.Parse(context.Request.QueryString["id"]);

        var taiwanCalendar = new System.Globalization.TaiwanCalendar();
        var Result = (from p in DB.IntersectionDetail
                      where p.IntersectionDetailID == id
                      select new
                      {
                          BaseRoadData = (from x in DB.Intersection where x.IntersectionID == p.IntersectionID select x).FirstOrDefault(),
                          p.IntersectionID,
                          p.IntersectionDetailID,
                          WeekType = (from s in DB.WeekType where s.IntersectionDetailID == p.IntersectionDetailID select s).FirstOrDefault(),
                          TimeIntervalType = (from r in DB.TimeIntervalType
                                              where r.IntersectionDetailID == p.IntersectionDetailID
                                              orderby Convert.ToInt32(r.TimeType)
                                              select new
                                              {
                                                  r.TimeType,
                                                  r.TimeIntervalTypeID,
                                                  TimeIntervalTypeDetail = (from t in DB.TimeIntervalTypeDetail
                                                                            where t.TimeIntervalTypeID == r.TimeIntervalTypeID
                                                                            orderby Convert.ToInt32(t.Hour)
                                                                            select new
                                                                            {
                                                                                t.TimeIntervalTypeDetailID,
                                                                                t.Hour,
                                                                                t.Minute,
                                                                                t.TimePlanSN
                                                                            })
                                              }),
                          TimePlan = (from v in DB.TimePlan
                                      where v.IntersectionDetailID == p.IntersectionDetailID
                                      orderby Convert.ToInt32(v.TimePlanSN)
                                      select new
                                      {
                                          v.IntersectionDetailID,
                                          TimePlanCycle = (from x in DB.TimePlanCycle where x.IntersectionDetailID == v.IntersectionDetailID && x.TimePlanSN == v.TimePlanSN select x.Cycle).First(),
                                          TimePlanDetail = (from x in DB.TimePlanExcel where x.IntersectionDetailID == v.IntersectionDetailID && x.TimePlanSN == v.TimePlanSN orderby x.TimePhaseID select x),
                                          TimeDiff = (v.TimeDiff == null ? "" : v.TimeDiff),
                                          TimePhaseSN = (v.TimePhaseSN == null ? "" : v.TimePhaseSN),
                                          v.TimePlanID,
                                          v.TimePlanSN
                                      }),
                          TimePhase = (from x in DB.TimePhase
                                       where x.IntersectionDetailID == p.IntersectionDetailID
                                       select new
                                       {
                                           x.TimePhaseID,
                                           x.TimePhaseRoad,
                                           TimePhaseDetail = (from b in DB.TimePhaseDetail
                                                              where b.TimePhaseID == x.TimePhaseID
                                                              orderby Convert.ToInt32(b.TimePlanSN)
                                                              select b),
                                           x.ImgSrc
                                       }),
                          p.Controller,
                          GPS = (p.GPS == "1" ? "裝設" : "未裝設"),
                          p.Remark,
                          VersionDate = string.Format("{0}-{1:MM-dd}", taiwanCalendar.GetYear(Convert.ToDateTime(p.VersionDate.ToString())), Convert.ToDateTime(p.VersionDate)),
                          p.Src,
                          p.State,
                          p.EmployeeID,
                          p.ModifiedDate
                      }).FirstOrDefault();

        //context.Response.ContentType = "text/plain";
        //context.Response.Write(JsonConvert.SerializeObject(Result));
        roadbase = JsonConvert.DeserializeObject<RootBase>(JsonConvert.SerializeObject(Result));

        CreateExcel(context);


       
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
    public void CreateExcel(HttpContext context)
    {
        context.Response.Clear();
        //context.Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        workbook = new HSSFWorkbook();

        cs = (HSSFCellStyle)workbook.CreateCellStyle();
        cs.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
        cs.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
        cs.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
        cs.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
        cs.VerticalAlignment = VerticalAlignment.Center;
        cs.Alignment = HorizontalAlignment.Center;

        HSSFSheet u_sheet = (HSSFSheet)workbook.CreateSheet("時制表");
        SetSheet(u_sheet);
        for (int i = 0; i < 23; i++)
        {
            SetRow(u_sheet, i, context);
        }
        for (int i = 0; i < 6; i++)
        {
            if (roadbase.TimePhase.Count() > i)
            {
                if (!roadbase.TimePhase[i].ImgSrc.Equals("img/nopic.jpg"))
                {
                    setImg(context, u_sheet, i);
                }
            }
        }
        MemoryStream MS = new MemoryStream();   //==需要 System.IO命名空間
        workbook.Write(MS);

        //== Excel檔名，請寫在最後面 filename的地方
        context.Response.AddHeader("Content-Disposition", "attachment; filename=" + DateTime.Now.ToString("yyyyMMddhhmm") + ".xls");
        context.Response.BinaryWrite(MS.ToArray());

        //== 釋放資源
        workbook = null;
        MS.Close();
        MS.Dispose();

        context.Response.Flush();
        context.Response.End();
    }
    public void setImg(HttpContext context, HSSFSheet u_sheet, int index)
    {
        string appPath = context.Request.PhysicalApplicationPath;
        string savePath = appPath + roadbase.TimePhase[index].ImgSrc;
        System.Drawing.Image image = System.Drawing.Image.FromFile(savePath);
        ImageFormat thisFormat = image.RawFormat;
        Bitmap imageOutput = new Bitmap(image, 523, 397);
        MemoryStream oMemoryStream = new MemoryStream();
        imageOutput.Save(oMemoryStream, ImageFormat.Jpeg);
        oMemoryStream.Position = 0;
        byte[] buffer = new byte[oMemoryStream.Length];
        oMemoryStream.Read(buffer, 0, Convert.ToInt32(oMemoryStream.Length));
        oMemoryStream.Flush();
        HSSFPatriarch patriarch = (HSSFPatriarch)u_sheet.CreateDrawingPatriarch();
        HSSFClientAnchor anchor = new HSSFClientAnchor(50, 5, 0, 0, 9, 10, 9, 10);
        if (index == 0)
        {
            anchor = new HSSFClientAnchor(50, 5, 0, 0, 9, 10, 9, 10);
        }
        else if (index == 1)
        {
            anchor = new HSSFClientAnchor(50, 5, 0, 0, 21, 10, 21, 10);
        }
        else if (index == 2)
        {
            anchor = new HSSFClientAnchor(50, 5, 0, 0, 33, 10, 33, 10);
        }
        else if (index == 3)
        {
            anchor = new HSSFClientAnchor(50, 5, 0, 0, 9, 17, 9, 17);
        }
        else if (index == 4)
        {
            anchor = new HSSFClientAnchor(50, 5, 0, 0, 21, 17, 21, 17);
        }
        else if (index == 5)
        {
            anchor = new HSSFClientAnchor(50, 5, 0, 0, 33, 17, 33, 17);
        }
        else if (index == 6)
        {
            anchor = new HSSFClientAnchor(50, 5, 0, 0, 33, 17, 33, 17);
        }
        int y = workbook.AddPicture(buffer, PictureType.JPEG);
        HSSFPicture picture = (HSSFPicture)patriarch.CreatePicture(anchor, y);
        picture.Resize();
    }





    public void SetRow(HSSFSheet s, int row, HttpContext context)
    {
        IRow rowStat = s.CreateRow(row);
        for (int i = 0; i < 45; i++)
        {
            rowStat.CreateCell(i);
            rowStat.GetCell(i).CellStyle = cs;
        }

        switch (row)
        {
            case 0:
                rowStat.GetCell(0).SetCellValue("區域");
                rowStat.GetCell(0).CellStyle = CsSet(16, true);
                rowStat.GetCell(4).SetCellValue("周內日");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.GetCell(6).SetCellValue("時制計畫編號");
                rowStat.GetCell(6).CellStyle = CsSet(12, true);
                rowStat.GetCell(7).SetCellValue("時相編號");
                rowStat.GetCell(7).CellStyle = CsSet(12, true);
                rowStat.GetCell(8).SetCellValue("時　　差");
                rowStat.GetCell(8).CellStyle = CsSet(12, true);
                rowStat.GetCell(9).SetCellValue("週　　期");
                rowStat.GetCell(9).CellStyle = CsSet(12, true);
                rowStat.GetCell(10).SetCellValue("時相一");
                rowStat.GetCell(10).CellStyle = CsSet(16, true);
                rowStat.GetCell(15).SetCellValue("時相二");
                rowStat.GetCell(15).CellStyle = CsSet(16, true);
                rowStat.GetCell(20).SetCellValue("時相三");
                rowStat.GetCell(20).CellStyle = CsSet(16, true);
                rowStat.GetCell(25).SetCellValue("時相四");
                rowStat.GetCell(25).CellStyle = CsSet(16, true);
                rowStat.GetCell(30).SetCellValue("時相五");
                rowStat.GetCell(30).CellStyle = CsSet(16, true);
                rowStat.GetCell(35).SetCellValue("時相六");
                rowStat.GetCell(35).CellStyle = CsSet(16, true);
                rowStat.GetCell(40).SetCellValue("日期");
                rowStat.GetCell(40).CellStyle = CsSet(16, true);
                rowStat.Height = (Int32)(40 * 20);
                break;
            case 1:
                rowStat.GetCell(4).SetCellValue("星期");
                rowStat.GetCell(4).CellStyle = CsSet(9, true);
                rowStat.GetCell(5).SetCellValue("時段型態");
                rowStat.GetCell(5).CellStyle = CsSet(9, true);
                rowStat.Height = (Int32)(40 * 20);
                rowStat.GetCell(0).SetCellValue(roadbase.BaseRoadData.Zone);
                if (roadbase.TimePhase.Count() > 0)
                {
                    if (roadbase.TimePhase[0].TimePhaseRoad != null)
                    {
                        roadbase.TimePhase[0].TimePhaseRoad = roadbase.TimePhase[0].TimePhaseRoad.Replace("<br />", "\n");
                    }
                    rowStat.GetCell(10).SetCellValue(roadbase.TimePhase[0].TimePhaseRoad);
                    rowStat.GetCell(10).CellStyle = CsSet(12, true);
                }
                if (roadbase.TimePhase.Count() > 1)
                {
                    if (roadbase.TimePhase[1].TimePhaseRoad != null)
                    {
                        roadbase.TimePhase[1].TimePhaseRoad = roadbase.TimePhase[1].TimePhaseRoad.Replace("<br />", "\n");
                    }
                    rowStat.GetCell(15).SetCellValue(roadbase.TimePhase[1].TimePhaseRoad);
                    rowStat.GetCell(15).CellStyle = CsSet(12, true);
                }
                if (roadbase.TimePhase.Count() > 2)
                {
                    if (roadbase.TimePhase[2].TimePhaseRoad != null)
                    {
                        roadbase.TimePhase[2].TimePhaseRoad = roadbase.TimePhase[2].TimePhaseRoad.Replace("<br />", "\n");
                    }
                    rowStat.GetCell(20).SetCellValue(roadbase.TimePhase[2].TimePhaseRoad);
                    rowStat.GetCell(20).CellStyle = CsSet(12, true);
                }
                if (roadbase.TimePhase.Count() > 3)
                {
                    if (roadbase.TimePhase[3].TimePhaseRoad != null)
                    {
                        roadbase.TimePhase[3].TimePhaseRoad = roadbase.TimePhase[3].TimePhaseRoad.Replace("<br />", "\n");
                    }
                    rowStat.GetCell(25).SetCellValue(roadbase.TimePhase[3].TimePhaseRoad);
                    rowStat.GetCell(25).CellStyle = CsSet(12, true);
                }
                if (roadbase.TimePhase.Count() > 4)
                {
                    if (roadbase.TimePhase[4].TimePhaseRoad != null)
                    {
                        roadbase.TimePhase[4].TimePhaseRoad = roadbase.TimePhase[4].TimePhaseRoad.Replace("<br />", "\n");
                    }
                    rowStat.GetCell(30).SetCellValue(roadbase.TimePhase[4].TimePhaseRoad);
                    rowStat.GetCell(30).CellStyle = CsSet(12, true);
                }
                if (roadbase.TimePhase.Count() > 5)
                {
                    if (roadbase.TimePhase[5].TimePhaseRoad != null)
                    {
                        roadbase.TimePhase[5].TimePhaseRoad = roadbase.TimePhase[5].TimePhaseRoad.Replace("<br />", "\n");
                    }
                    rowStat.GetCell(35).SetCellValue(roadbase.TimePhase[5].TimePhaseRoad);
                    rowStat.GetCell(35).CellStyle = CsSet(12, true);
                }

                rowStat.GetCell(40).SetCellValue(roadbase.VersionDate);
                rowStat.GetCell(40).CellStyle = CsSet(16, true);
                break;
            case 2:
                rowStat.GetCell(0).SetCellValue("路口名稱");
                rowStat.GetCell(0).CellStyle = CsSet(16, true);
                rowStat.GetCell(4).SetCellValue("一");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.GetCell(40).SetCellValue("GPS單元");
                rowStat.GetCell(40).CellStyle = CsSet(16, true);
                rowStat.Height = (Int32)(40 * 20);

                rowStat.GetCell(5).SetCellValue(roadbase.WeekType.Monday);
                break;
            case 3:
                rowStat.GetCell(4).SetCellValue("二");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.GetCell(40).SetCellValue("裝設");

                rowStat.GetCell(42).SetCellValue("未裝設");

                if (roadbase.GPS.Equals("裝設"))
                {
                    rowStat.GetCell(40).CellStyle = CsSet(16, true, true);
                    rowStat.GetCell(42).CellStyle = CsSet(16, true);
                }
                else
                {
                    rowStat.GetCell(40).CellStyle = CsSet(16, true);
                    rowStat.GetCell(42).CellStyle = CsSet(16, true, true);
                }
                for (int i = 0; i < 6; i++)
                {
                    i = i * 5;
                    rowStat.GetCell(10 + i).SetCellValue("PH");
                    rowStat.GetCell(10 + i).CellStyle = CsSet(12, true);
                    rowStat.GetCell(11 + i).SetCellValue("G");
                    rowStat.GetCell(11 + i).CellStyle = CsSet(12, true);
                    rowStat.GetCell(12 + i).SetCellValue("PF");
                    rowStat.GetCell(12 + i).CellStyle = CsSet(12, true);
                    rowStat.GetCell(13 + i).SetCellValue("Y");
                    rowStat.GetCell(13 + i).CellStyle = CsSet(12, true);
                    rowStat.GetCell(14 + i).SetCellValue("R");
                    rowStat.GetCell(14 + i).CellStyle = CsSet(12, true);
                    i = i / 5;
                }


                rowStat.Height = (Int32)(40 * 20);
                if (roadbase.BaseRoadData.RoadName != null)
                {
                    roadbase.BaseRoadData.RoadName = roadbase.BaseRoadData.RoadName.Replace("<br />", "\n");
                }
                rowStat.GetCell(0).SetCellValue(roadbase.BaseRoadData.RoadName);
                rowStat.GetCell(0).CellStyle = CsSet(12, true);
                rowStat.GetCell(5).SetCellValue(roadbase.WeekType.Tuesday);

                break;
            case 4:
                rowStat.GetCell(4).SetCellValue("三");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.GetCell(40).SetCellValue("備註");
                rowStat.GetCell(40).CellStyle = CsSet(16, true);
                rowStat.Height = (Int32)(40 * 20);

                rowStat.GetCell(5).SetCellValue(roadbase.WeekType.Wednesday);
                if (roadbase.TimePlan.Count() > 0)
                {
                    rowStat.GetCell(6).SetCellValue(roadbase.TimePlan[0].TimePlanSN);
                    rowStat.GetCell(7).SetCellValue(roadbase.TimePlan[0].TimePhaseSN);
                    rowStat.GetCell(8).SetCellValue(roadbase.TimePlan[0].TimeDiff);
                    rowStat.GetCell(9).SetCellValue(roadbase.TimePlan[0].TimePlanCycle);
                    for (int j = 0; j < 6; j++)
                    {
                        if (roadbase.TimePlan[0].TimePlanDetail.Count() > j)
                        {
                            rowStat.GetCell(10 + j * 5).SetCellValue(roadbase.TimePlan[0].TimePlanDetail[j].PH);
                            rowStat.GetCell(11 + j * 5).SetCellValue(roadbase.TimePlan[0].TimePlanDetail[j].G);
                            rowStat.GetCell(13 + j * 5).SetCellValue(roadbase.TimePlan[0].TimePlanDetail[j].Y);
                            rowStat.GetCell(14 + j * 5).SetCellValue(roadbase.TimePlan[0].TimePlanDetail[j].R);
                        }
                    }
                }
                break;
            case 5:
                rowStat.GetCell(4).SetCellValue("四");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.Height = (Int32)(40 * 20);

                rowStat.GetCell(5).SetCellValue(roadbase.WeekType.Thursday);
                if (roadbase.Remark != null)
                {
                    roadbase.Remark = roadbase.Remark.Replace("<br />", "\n");
                }
                rowStat.GetCell(40).SetCellValue(roadbase.Remark);
                rowStat.GetCell(40).CellStyle = CsSet(14, true);
                if (roadbase.TimePlan.Count() > 1)
                {
                    rowStat.GetCell(6).SetCellValue(roadbase.TimePlan[1].TimePlanSN);
                    rowStat.GetCell(7).SetCellValue(roadbase.TimePlan[1].TimePhaseSN);
                    rowStat.GetCell(8).SetCellValue(roadbase.TimePlan[1].TimeDiff);
                    rowStat.GetCell(9).SetCellValue(roadbase.TimePlan[1].TimePlanCycle);
                    for (int j = 0; j < 6; j++)
                    {
                        if (roadbase.TimePlan[1].TimePlanDetail.Count() > j)
                        {
                            rowStat.GetCell(10 + j * 5).SetCellValue(roadbase.TimePlan[1].TimePlanDetail[j].PH);
                            rowStat.GetCell(11 + j * 5).SetCellValue(roadbase.TimePlan[1].TimePlanDetail[j].G);
                            rowStat.GetCell(13 + j * 5).SetCellValue(roadbase.TimePlan[1].TimePlanDetail[j].Y);
                            rowStat.GetCell(14 + j * 5).SetCellValue(roadbase.TimePlan[1].TimePlanDetail[j].R);
                        }
                    }
                }

                break;
            case 6:
                rowStat.GetCell(0).SetCellValue("廠牌控制器");
                rowStat.GetCell(0).CellStyle = CsSet(16, true);
                rowStat.GetCell(4).SetCellValue("五");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.Height = (Int32)(40 * 20);

                rowStat.GetCell(5).SetCellValue(roadbase.WeekType.Friday);
                if (roadbase.TimePlan.Count() > 2)
                {
                    rowStat.GetCell(6).SetCellValue(roadbase.TimePlan[2].TimePlanSN);
                    rowStat.GetCell(7).SetCellValue(roadbase.TimePlan[2].TimePhaseSN);
                    rowStat.GetCell(8).SetCellValue(roadbase.TimePlan[2].TimeDiff);
                    rowStat.GetCell(9).SetCellValue(roadbase.TimePlan[2].TimePlanCycle);
                    for (int j = 0; j < 6; j++)
                    {
                        if (roadbase.TimePlan[2].TimePlanDetail.Count() > j)
                        {
                            rowStat.GetCell(10 + j * 5).SetCellValue(roadbase.TimePlan[2].TimePlanDetail[j].PH);
                            rowStat.GetCell(11 + j * 5).SetCellValue(roadbase.TimePlan[2].TimePlanDetail[j].G);
                            rowStat.GetCell(13 + j * 5).SetCellValue(roadbase.TimePlan[2].TimePlanDetail[j].Y);
                            rowStat.GetCell(14 + j * 5).SetCellValue(roadbase.TimePlan[2].TimePlanDetail[j].R);
                        }
                    }
                }

                break;
            case 7:
                rowStat.GetCell(4).SetCellValue("六");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.Height = (Int32)(40 * 20);

                rowStat.GetCell(0).SetCellValue(roadbase.Controller);
                rowStat.GetCell(5).SetCellValue(roadbase.WeekType.Saturday);
                if (roadbase.TimePlan.Count() > 3)
                {
                    rowStat.GetCell(6).SetCellValue(roadbase.TimePlan[3].TimePlanSN);
                    rowStat.GetCell(7).SetCellValue(roadbase.TimePlan[3].TimePhaseSN);
                    rowStat.GetCell(8).SetCellValue(roadbase.TimePlan[3].TimeDiff);
                    rowStat.GetCell(9).SetCellValue(roadbase.TimePlan[3].TimePlanCycle);
                    for (int j = 0; j < 6; j++)
                    {
                        if (roadbase.TimePlan[3].TimePlanDetail.Count() > j)
                        {
                            rowStat.GetCell(10 + j * 5).SetCellValue(roadbase.TimePlan[3].TimePlanDetail[j].PH);
                            rowStat.GetCell(11 + j * 5).SetCellValue(roadbase.TimePlan[3].TimePlanDetail[j].G);
                            rowStat.GetCell(13 + j * 5).SetCellValue(roadbase.TimePlan[3].TimePlanDetail[j].Y);
                            rowStat.GetCell(14 + j * 5).SetCellValue(roadbase.TimePlan[3].TimePlanDetail[j].R);
                        }
                    }
                }

                break;
            case 8:
                rowStat.GetCell(4).SetCellValue("日");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.Height = (Int32)(40 * 20);

                rowStat.GetCell(5).SetCellValue(roadbase.WeekType.Sunday);
                if (roadbase.TimePlan.Count() > 4)
                {
                    rowStat.GetCell(6).SetCellValue(roadbase.TimePlan[4].TimePlanSN);
                    rowStat.GetCell(7).SetCellValue(roadbase.TimePlan[4].TimePhaseSN);
                    rowStat.GetCell(8).SetCellValue(roadbase.TimePlan[4].TimeDiff);
                    rowStat.GetCell(9).SetCellValue(roadbase.TimePlan[4].TimePlanCycle);
                    for (int j = 0; j < 6; j++)
                    {
                        if (roadbase.TimePlan[4].TimePlanDetail.Count() > j)
                        {
                            rowStat.GetCell(10 + j * 5).SetCellValue(roadbase.TimePlan[4].TimePlanDetail[j].PH);
                            rowStat.GetCell(11 + j * 5).SetCellValue(roadbase.TimePlan[4].TimePlanDetail[j].G);
                            rowStat.GetCell(13 + j * 5).SetCellValue(roadbase.TimePlan[4].TimePlanDetail[j].Y);
                            rowStat.GetCell(14 + j * 5).SetCellValue(roadbase.TimePlan[4].TimePlanDetail[j].R);
                        }
                    }
                }

                break;
            case 9:
                rowStat.GetCell(0).SetCellValue("時段型態");
                rowStat.GetCell(0).CellStyle = CsSet(16, true);
                rowStat.GetCell(9).SetCellValue("時相一    動線");
                rowStat.GetCell(9).CellStyle = CsSet(16, true);
                rowStat.GetCell(21).SetCellValue("時相二    動線");
                rowStat.GetCell(21).CellStyle = CsSet(16, true);
                rowStat.GetCell(33).SetCellValue("時相三    動線");
                rowStat.GetCell(33).CellStyle = CsSet(16, true);
                rowStat.Height = (Int32)(40 * 20);
                break;
            case 10:
                rowStat.Height = (Int32)(40 * 20);
                if (roadbase.TimeIntervalType.Count() > 0)
                {
                    rowStat.GetCell(0).SetCellValue(roadbase.TimeIntervalType[0].TimeType);
                }
                if (roadbase.TimeIntervalType.Count() > 1)
                {
                    rowStat.GetCell(3).SetCellValue(roadbase.TimeIntervalType[1].TimeType);
                }
                if (roadbase.TimeIntervalType.Count() > 2)
                {
                    rowStat.GetCell(6).SetCellValue(roadbase.TimeIntervalType[2].TimeType);
                }
                break;
            case 11:
                rowStat.GetCell(0).SetCellValue("時");
                rowStat.GetCell(0).CellStyle = CsSet(12, true);
                rowStat.GetCell(1).SetCellValue("分");
                rowStat.GetCell(1).CellStyle = CsSet(12, true);
                rowStat.GetCell(2).SetCellValue("時制計畫");
                rowStat.GetCell(2).CellStyle = CsSet(12, true);
                rowStat.GetCell(3).SetCellValue("時");
                rowStat.GetCell(3).CellStyle = CsSet(12, true);
                rowStat.GetCell(4).SetCellValue("分");
                rowStat.GetCell(4).CellStyle = CsSet(12, true);
                rowStat.GetCell(5).SetCellValue("時制計畫");
                rowStat.GetCell(5).CellStyle = CsSet(12, true);
                rowStat.GetCell(6).SetCellValue("時");
                rowStat.GetCell(6).CellStyle = CsSet(12, true);
                rowStat.GetCell(7).SetCellValue("分");
                rowStat.GetCell(7).CellStyle = CsSet(12, true);
                rowStat.GetCell(8).SetCellValue("時制計畫");
                rowStat.GetCell(8).CellStyle = CsSet(12, true);
                rowStat.Height = (Int32)(40 * 20);
                break;
            case 12:
                rowStat.Height = (Int32)(40 * 20);
                break;
            case 13:
                rowStat.Height = (Int32)(40 * 20);
                setTimeType(rowStat, 0);

                break;
            case 14:
                rowStat.Height = (Int32)(40 * 20);
                setTimeType(rowStat, 1);
                break;
            case 15:
                rowStat.Height = (Int32)(40 * 20);
                setTimeType(rowStat, 2);
                break;
            case 16:
                rowStat.GetCell(9).SetCellValue("時相四    動線");
                rowStat.GetCell(9).CellStyle = CsSet(16, true);
                rowStat.GetCell(21).SetCellValue("時相五    動線");
                rowStat.GetCell(21).CellStyle = CsSet(16, true);
                rowStat.GetCell(33).SetCellValue("時相六    動線");
                rowStat.GetCell(33).CellStyle = CsSet(16, true);
                rowStat.Height = (Int32)(40 * 20);
                setTimeType(rowStat, 3);
                break;
            case 17:
                rowStat.Height = (Int32)(40 * 20);
                setTimeType(rowStat, 4);
                break;
            case 18:
                rowStat.Height = (Int32)(40 * 20);
                setTimeType(rowStat, 5);
                break;
            case 19:
                rowStat.Height = (Int32)(40 * 20);
                setTimeType(rowStat, 6);
                break;
            case 20:
                rowStat.Height = (Int32)(40 * 20);
                break;
            case 21:
                rowStat.Height = (Int32)(40 * 20);
                break;
            case 22:
                rowStat.Height = (Int32)(40 * 20);
                break;
        }

    }

    public void setTimeType(IRow rowStat, int x)
    {
        if (roadbase.TimeIntervalType.Count() > 0)
        {
            if (roadbase.TimeIntervalType[0].TimeIntervalTypeDetail.Count() > x)
            {
                rowStat.GetCell(0).SetCellValue(roadbase.TimeIntervalType[0].TimeIntervalTypeDetail[x].Hour);
                rowStat.GetCell(1).SetCellValue(roadbase.TimeIntervalType[0].TimeIntervalTypeDetail[x].Minute);
                rowStat.GetCell(2).SetCellValue(roadbase.TimeIntervalType[0].TimeIntervalTypeDetail[x].TimePlanSN);
            }
        }
        if (roadbase.TimeIntervalType.Count() > 1)
        {
            if (roadbase.TimeIntervalType[1].TimeIntervalTypeDetail.Count() > x)
            {
                rowStat.GetCell(3).SetCellValue(roadbase.TimeIntervalType[1].TimeIntervalTypeDetail[x].Hour);
                rowStat.GetCell(4).SetCellValue(roadbase.TimeIntervalType[1].TimeIntervalTypeDetail[x].Minute);
                rowStat.GetCell(5).SetCellValue(roadbase.TimeIntervalType[1].TimeIntervalTypeDetail[x].TimePlanSN);
            }
        }
        if (roadbase.TimeIntervalType.Count() > 2)
        {
            if (roadbase.TimeIntervalType[2].TimeIntervalTypeDetail.Count() > x)
            {
                rowStat.GetCell(6).SetCellValue(roadbase.TimeIntervalType[2].TimeIntervalTypeDetail[x].Hour);
                rowStat.GetCell(7).SetCellValue(roadbase.TimeIntervalType[2].TimeIntervalTypeDetail[x].Minute);
                rowStat.GetCell(8).SetCellValue(roadbase.TimeIntervalType[2].TimeIntervalTypeDetail[x].TimePlanSN);
            }
        }
    }


    public HSSFCellStyle CsSet(short size, bool x, bool y)
    {
        HSSFFont font = (HSSFFont)workbook.CreateFont();
        font.FontName = "微軟正黑體";
        font.FontHeightInPoints = size;
        HSSFCellStyle cs = (HSSFCellStyle)workbook.CreateCellStyle();
        cs.SetFont(font);
        cs.WrapText = true;
        cs.VerticalAlignment = VerticalAlignment.Center;
        cs.Alignment = HorizontalAlignment.Center;
        if (x)
        {
            cs.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.WrapText = true;
        }
        if (y)
        {
            cs.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.Grey40Percent.Index;
            cs.FillPattern = NPOI.SS.UserModel.FillPattern.SolidForeground;

        }
        return cs;
    }




    public HSSFCellStyle CsSet(short size, bool x)
    {

        HSSFFont font = (HSSFFont)workbook.CreateFont();
        font.FontName = "微軟正黑體";
        font.FontHeightInPoints = size;
        HSSFCellStyle cs = (HSSFCellStyle)workbook.CreateCellStyle();
        cs.SetFont(font);
        cs.WrapText = true;
        cs.VerticalAlignment = VerticalAlignment.Center;
        cs.Alignment = HorizontalAlignment.Center;
        if (x)
        {
            cs.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.WrapText = true;
        }
        return cs;
    }

    public void SetSheet(HSSFSheet s)
    {

        //上半部
        s.AddMergedRegion(new CellRangeAddress(0, 0, 0, 3));
        s.AddMergedRegion(new CellRangeAddress(1, 1, 0, 3));
        s.AddMergedRegion(new CellRangeAddress(2, 2, 0, 3));
        s.AddMergedRegion(new CellRangeAddress(0, 0, 4, 5));

        s.AddMergedRegion(new CellRangeAddress(0, 0, 10, 14));
        s.AddMergedRegion(new CellRangeAddress(1, 2, 10, 14));

        s.AddMergedRegion(new CellRangeAddress(0, 0, 15, 19));
        s.AddMergedRegion(new CellRangeAddress(1, 2, 15, 19));

        s.AddMergedRegion(new CellRangeAddress(0, 0, 20, 24));
        s.AddMergedRegion(new CellRangeAddress(1, 2, 20, 24));

        s.AddMergedRegion(new CellRangeAddress(0, 0, 25, 29));
        s.AddMergedRegion(new CellRangeAddress(1, 2, 25, 29));

        s.AddMergedRegion(new CellRangeAddress(0, 0, 30, 34));
        s.AddMergedRegion(new CellRangeAddress(1, 2, 30, 34));

        s.AddMergedRegion(new CellRangeAddress(0, 0, 35, 39));
        s.AddMergedRegion(new CellRangeAddress(1, 2, 35, 39));

        s.AddMergedRegion(new CellRangeAddress(0, 0, 40, 44));
        s.AddMergedRegion(new CellRangeAddress(1, 1, 40, 44));
        s.AddMergedRegion(new CellRangeAddress(2, 2, 40, 44));
        s.AddMergedRegion(new CellRangeAddress(3, 3, 40, 41));
        s.AddMergedRegion(new CellRangeAddress(3, 3, 42, 44));
        s.AddMergedRegion(new CellRangeAddress(4, 4, 40, 44));
        s.AddMergedRegion(new CellRangeAddress(5, 8, 40, 44));

        s.AddMergedRegion(new CellRangeAddress(0, 3, 6, 6));
        s.AddMergedRegion(new CellRangeAddress(0, 3, 7, 7));
        s.AddMergedRegion(new CellRangeAddress(0, 3, 8, 8));
        s.AddMergedRegion(new CellRangeAddress(0, 3, 9, 9));

        s.AddMergedRegion(new CellRangeAddress(3, 5, 0, 3));

        s.AddMergedRegion(new CellRangeAddress(6, 6, 0, 3));
        s.AddMergedRegion(new CellRangeAddress(7, 8, 0, 3));
        //下半部
        s.AddMergedRegion(new CellRangeAddress(9, 9, 0, 8));

        //時相一
        s.AddMergedRegion(new CellRangeAddress(9, 9, 9, 20));
        s.AddMergedRegion(new CellRangeAddress(10, 15, 9, 20));
        s.AddMergedRegion(new CellRangeAddress(16, 16, 9, 20));
        s.AddMergedRegion(new CellRangeAddress(17, 22, 9, 20));

        //時相二
        s.AddMergedRegion(new CellRangeAddress(9, 9, 21, 32));
        s.AddMergedRegion(new CellRangeAddress(10, 15, 21, 32));
        s.AddMergedRegion(new CellRangeAddress(16, 16, 21, 32));
        s.AddMergedRegion(new CellRangeAddress(17, 22, 21, 32));

        //時相三
        s.AddMergedRegion(new CellRangeAddress(9, 9, 33, 44));
        s.AddMergedRegion(new CellRangeAddress(10, 15, 33, 44));
        s.AddMergedRegion(new CellRangeAddress(16, 16, 33, 44));
        s.AddMergedRegion(new CellRangeAddress(17, 22, 33, 44));

        s.AddMergedRegion(new CellRangeAddress(10, 10, 0, 2));
        s.AddMergedRegion(new CellRangeAddress(10, 10, 3, 5));
        s.AddMergedRegion(new CellRangeAddress(10, 10, 6, 8));

        s.AddMergedRegion(new CellRangeAddress(11, 12, 0, 0));
        s.AddMergedRegion(new CellRangeAddress(11, 12, 1, 1));
        s.AddMergedRegion(new CellRangeAddress(11, 12, 2, 2));
        s.AddMergedRegion(new CellRangeAddress(11, 12, 3, 3));
        s.AddMergedRegion(new CellRangeAddress(11, 12, 4, 4));
        s.AddMergedRegion(new CellRangeAddress(11, 12, 5, 5));
        s.AddMergedRegion(new CellRangeAddress(11, 12, 6, 6));
        s.AddMergedRegion(new CellRangeAddress(11, 12, 7, 7));
        s.AddMergedRegion(new CellRangeAddress(11, 12, 8, 8));



        s.PrintSetup.Landscape = true;
        s.FitToPage = true;
        s.SetRowBreak(22);
        s.PrintSetup.FitWidth = 1;
        s.PrintSetup.FitHeight = 0;
        for (int i = 0; i < 45; i++)
        {
            s.SetColumnWidth(i, 5 * 256);
        }
        s.SetZoom(60, 85);
    }

    public class BaseRoadData
    {
        public int IntersectionID { get; set; }
        public string Zone { get; set; }
        public string RoadName { get; set; }
        public string Position { get; set; }
        public string ENumber { get; set; }
        public object EmployeeID { get; set; }
        public object ModifiedDate { get; set; }
    }

    public class WeekType
    {
        public int WeekTypeID { get; set; }
        public int IntersectionDetailID { get; set; }
        public string Monday { get; set; }
        public string Tuesday { get; set; }
        public string Wednesday { get; set; }
        public string Thursday { get; set; }
        public string Friday { get; set; }
        public string Saturday { get; set; }
        public string Sunday { get; set; }
    }

    public class TimeIntervalTypeDetail
    {
        public int TimeIntervalTypeDetailID { get; set; }
        public string Hour { get; set; }
        public string Minute { get; set; }
        public string TimePlanSN { get; set; }
    }

    public class TimeIntervalType
    {
        public string TimeType { get; set; }
        public int TimeIntervalTypeID { get; set; }
        public List<TimeIntervalTypeDetail> TimeIntervalTypeDetail { get; set; }
    }

    public class TimePlanDetail
    {
        public int IntersectionDetailID { get; set; }
        public string TimePlanSN { get; set; }
        public string G { get; set; }
        public string PH { get; set; }
        public string Y { get; set; }
        public string R { get; set; }
        public int TimePhaseID { get; set; }
    }

    public class TimePlan
    {
        public int IntersectionDetailID { get; set; }
        public string TimePlanCycle { get; set; }
        public List<TimePlanDetail> TimePlanDetail { get; set; }
        public string TimeDiff { get; set; }
        public string TimePhaseSN { get; set; }
        public int TimePlanID { get; set; }
        public string TimePlanSN { get; set; }
    }

    public class TimePhaseDetail
    {
        public int TimePhaseDetailID { get; set; }
        public int TimePhaseID { get; set; }
        public string TimePlanSN { get; set; }
        public string PH { get; set; }
        public string G { get; set; }
        public string Y { get; set; }
        public string R { get; set; }
    }

    public class TimePhase
    {
        public int TimePhaseID { get; set; }
        public string TimePhaseRoad { get; set; }
        public List<TimePhaseDetail> TimePhaseDetail { get; set; }
        public string ImgSrc { get; set; }
    }

    public class RootBase
    {
        public BaseRoadData BaseRoadData { get; set; }
        public int IntersectionID { get; set; }
        public int IntersectionDetailID { get; set; }
        public WeekType WeekType { get; set; }
        public List<TimeIntervalType> TimeIntervalType { get; set; }
        public List<TimePlan> TimePlan { get; set; }
        public List<TimePhase> TimePhase { get; set; }
        public string Controller { get; set; }
        public string GPS { get; set; }
        public string Remark { get; set; }
        public string VersionDate { get; set; }
        public object Src { get; set; }
        public object State { get; set; }
        public object EmployeeID { get; set; }
        public object ModifiedDate { get; set; }
    }
}