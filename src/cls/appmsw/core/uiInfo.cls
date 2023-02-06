Class appmsw.core.uiInfo Extends appmsw.core.AutoPage
{

Parameter CSPURL = "appmsw.core.uiInfo.cls";

Parameter PAGENAME = "ImportSQLConnection";

Parameter PARENTPAGE = "appmsw.core.AutoPage.cls";

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	quit ##class(appmsw.core.uiInfoPane).%New()
}

}

