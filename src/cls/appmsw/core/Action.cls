/// Withdraw the necessary actions
Class appmsw.core.Action Extends %CSP.Page
{

/// s par=##class(apptools.core.Action).GetParam(.%request,"ns",param)
ClassMethod GetParam(req, paramName, param, del = "&") As %Status
{
 if $d(req) { 
 	q $tr(req.Get(paramName),"#")
 }
 else { set val=$p($p(param,(del_paramName_"="),2),del,1)
 	quit val
 }
}

/// Main method generate the content of page
ClassMethod OnPage(param) As %Status
{
	set $zt="Err"
 	#dim %request as %CSP.Request

 	;set $$$AppL("MSW","req")=$$$AppObJs(%request)
 	;merge $$$AppL("MSW","%request.Data")=%request.Data
	;set $$$AppL("MSW","%request.AppData")=%request.AppData

 	if %request.Get("appAct")'="" { //AppAct=NameSpace:Packet.ClassName:Method:@Par1=Val1@Par2=Val2...
 		set appPar=$p(%request.Get("appAct"),"AppAct=",2,*)
		set i=""
		for { set i=$o(%request.Data(i)) quit:i=""
			set:$o(%request.Data(i,""),-1)'="" appPar("%request.Data",i)=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
		}
		zw appPar
		d ..RunMethod($p(appPar,":",1),$p(appPar,":",2),$p(appPar,":",3),.appPar)
		q $$$OK
 	}
Err 
	write $zconvert($ze,"O","HTML")
	quit $$$OK
}

/// To execute the method
ClassMethod RunMethod(appNsp, appClass, appMethod, appPar) As %Status
{
	if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
	set NSpace=$namespace
		set:appClass="" appClass="appmsw.core.Action"
		if $e(appPar,1)="{" {
			;Parse json TODO
		}
		elseif appPar["~" {
			do ..ParseURL(appPar,.appPar,"~")  ;parse in array
		}
		elseif appPar["&" {
			d ..ParseURL(appPar,.appPar,"&")
		}
		w $namespace,"=" zw appPar
		w
		Do $CLASSMETHOD(appClass,appMethod,.appPar)
		quit $$$OK
}

/// Parse a string of CGI variable 
ClassMethod ParseURL(str As %String, ByRef out, del = "&") As %Status
{
	f i=1:1:$l(str,del) {
		continue:$p(str,del,i)=""
		continue:$p($p(str,del,i),"=")=""
		s out($p($p(str,del,i),"="))=$p($p(str,del,i),"=",2)
	}
}

}

