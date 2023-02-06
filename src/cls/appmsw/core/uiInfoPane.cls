Class appmsw.core.uiInfoPane Extends %CSP.Util.Pane
{

Parameter version = "1.0.4";

Parameter XMLTYPE = "appmsw.core";

/// Drawing the form to enter information
Method DrawBODY(pInstance As PageInstance) As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
	;do ##class(appmsw.core.uiInfoPane).AddJS()	
	&html<
	<!-- ui-dialog -->
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
		<form name="loginfo" id="loginfo" action="/csp/sys/appmsw.core.uiInfo.cls" method="POST">
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
			<H2><a target=_blank href='/csp/sys/mgr/UtilSqlGateways.csp'> SQLConnection </a></H2>
			</td>
		</tr>
		<tr>
			<td>
			#(##class(appmsw.core.uiInfoPane).GetListSqlGateways())#
 			</td>
		</tr>
		</table>
		<br><input type='submit' id='submit' name='submit' value='Import Selected Items'> 
		 <input type='submit' id='submit2' name='submit2' value='Refresh'> 
		<!--<button onclick='AppAct("loginfo","dialogContent","%SYS:appmsw.core.uiInfoPane:ImportSubmit:~aaa=444")'>Import</button>-->
		</form>
		<div id='dialogContent'></div>
	>
	if $d(%request),%request.Get("submit")'="" {
		set i=""
		for { set i=$o(%request.Data(i)) quit:i=""
			if $o(%request.Data(i,""),-1)'=""&(i'="submit") {
				set appPar(i)=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
				write "<br>"_i
			}
		}
		m %appSQLitem=appPar
		set view="##class(appmsw.core.uiInfoPane).ImportUI()"
		quit ##class(appmsw.gateway.jdbc).ImportSQLConnection(view)
	}
	quit $$$OK
}

ClassMethod GetListSqlGateways(par) As %String
{
	set view="##class(appmsw.core.uiInfoPane).ImportViewUI()"
	quit ##class(appmsw.gateway.jdbc).ImportSQLConnection(view)
}

ClassMethod ImportUI() As %Status
{
	if %appClassProp="Name" {
		if $d(%appSQLitem(%appClassPropVal)) {
			set %appSQLitem=1
			write "<br>"
		}
		else {
			set %appSQLitem=0
		}
	}
	set %appClassPropSet=$g(%appSQLitem) ; don't assign a property with that name
	set %appClassSave=$g(%appSQLitem)  ; don't save an instance of the class
	zt "show_must_go_on" ; redefine the exception <INTERRUPT>
	quit $$$OK
}

/// module for viewing objects in a file
ClassMethod ImportViewUI(%appTmp) As %Status
{
	write:$g(%appClassSave) !
	if "Name,driver,URL"[%appClassProp {
		if %appClassProp="Name" write "<br><br><input type='checkbox' id='"_%appClassPropVal_"' name='"_%appClassPropVal_"'> "_%appClassProp_" = "_%appClassPropVal
		write "<br>"," "_%appClassProp_" = "_%appClassPropVal
		;write:"driver"=%appClassProp "<br>"
	}
	set %appClassPropSet=0 ; don't assign a property with that name
	set %appClassSave=0  ; don't save an instance of the class
	zt "show_must_go_on" ; redefine the exception <INTERRUPT>
	quit $$$OK
}

}

