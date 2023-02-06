/// JDBC utility install for SQL Gateway Connection
Class appmsw.gateway.jdbc [ Abstract ]
{

/// write ##class(appmsw.gateway.jdbc).ImportSQLConnection("view")
ClassMethod ImportSQLConnection(mode = "") As %Status
{
	set st=$$$OK
	KILL %appTmp,%appClass,%appClassProp,%appClassPropVal,%appClassPropType,%appClassSave,%appClassPropSet
	if $namespace'="%SYS" set msg="This project needs to be installed in the %SYS namespace" write !,msg quit $$$ERROR($$$GeneralError,msg)
	set sourcedir=##class(%File).NormalizeDirectory("lib\jdbc\", ##class(%File).GetDirectory($zu(86)))
	set jsonfile=sourcedir_"gateways.json"
	if mode="view" {set exec="##class(appmsw.gateway.jdbc).ImportView()"
	}
	elseif mode'="" {set exec=mode
	}
	else {set exec="##class(appmsw.gateway.jdbc).ImportChange($lb("""_sourcedir_"""))"
	}
	set st=..ImportSelect(jsonfile,.json,exec)
	quit st
}

/// module for viewing objects in a file
ClassMethod ImportView(%appTmp) As %Status
{
	write:$g(%appClassSave) !
	write !,$g(%appClass)_"."_%appClassProp_" = """_%appClassPropVal_""" " ; type:"_%appClassPropType ;_" "_$g(%appClassSave)_" "_$g(%appTmp)_" "_$g(%appClassPropSet)
	set %appClassPropSet=0 ; don't assign a property with that name
	set %appClassSave=0  ; don't save an instance of the class
	zt "show_must_go_on" ; redefine the exception <INTERRUPT>
	quit $$$OK
}

/// Module for selective recovery with the ability to change the name and url. SQL Gateway Connection 
ClassMethod ImportChange(%appTmp) As %Status
{
	;write !,$g(%appClass)_". "_%appClassProp_" = "_%appClassPropVal ;_" type:"_%appClassPropType_" "_$g(%appClassSave)_" "_$g(%appTmp)_" "_$g(%appClassPropSet)
	if $lf($lb("Name","URL","Usr","driver"),%appClassProp) do ..Prompt()
	if %appClassProp="pwd" set %appClassPropSet=0,%appClassPropVal="" write !,"The password will need to be entered in the portal interface",!! ;don't assign a property with that name
	if %appClassProp="classpath" {
		set pathfile=%appClassPropVal
		set slash=$s($zversion(1)=3:"/",1:"\")
		set filesjar=$lg(%appTmp,1)_$p(pathfile,slash,*)
		set %appClassPropVal=filesjar
		do ..Prompt(),..CopyJar()
	}
	if %appClassProp="isJDBC" set %appClassPropVal=1
	quit $$$OK
}

/// check path and copy driver
/// Class path (May be a comma separated list if multiple jar files are required. ) TODO
ClassMethod CopyJar() As %Status
{
	set pathfile=%appClassPropVal
	set slash=$s($zversion(1)=3:"/",1:"\")
	if ##class(%Library.File).Exists(pathfile) write !,pathfile_" already exists" quit $$$OK
	set filesjar=$lg(%appTmp,1)_$p(pathfile,slash,*)
	write !,"Copied from "_filesjar_" to "_pathfile
	if ##class(%Library.File).DirectoryExists(pathfile) {
		Set st = ##class(%ZPM.PackageManager.Developer.File).CopyFile(filesjar,pathfile)
	}
	else {
		set tTargetDir=$p(pathfile,slash,1,*-1)
		Set st = ##class(%ZPM.PackageManager.Developer.File).CreateDirectoryChain(tTargetDir)
		Set:st st = ##class(%ZPM.PackageManager.Developer.File).CopyFile(filesjar,pathfile)
	}
	if 'st write !,$System.Status.GetErrorText(st)
	quit $$$OK
}

/// property value change
ClassMethod Prompt() As %Status
{
	write !,"Change the value of a field '"_%appClassProp_"' <"_%appClassPropVal_"> " read r set %appClassPropVal=$s(r="":%appClassPropVal,1:r)
	quit $$$OK
}

/// set exec="##class(appmsw.gateway.jdbc).ImportChange()"
/// write ##class(apptools.core.json).ImportSelect("/tmp/gateways.json",.js,exec)
ClassMethod ImportSelect(filename = "", ByRef json, exec = "") As %Status
{
	set st=$$$OK
	;write !,"Import from: "_filename
	set f=##class(%File).%New(filename)
	if f.Open("RSU") {
	    set file=f.Read() 
	}
	else { 
	    set msg = $System.Status.GetErrorText($g(%objlasterror))
	    write msg
	    quit $$$ERROR($$$GeneralError,msg)
	}
	Set json=##class(%Library.DynamicAbstractObject).%FromJSON(file)
	set class=json.Classname
	new %appTmp,%appClass,%appClassProp,%appClassPropVal,%appClassPropType,%appClassSave,%appClassPropSet
	set AbstractObject=json.Instances
	set iter = AbstractObject.%GetIterator()
	set ImpWhile=1
	   while ImpWhile,iter.%GetNext(.key, .obj, .typeArray ) {
	      if $isobject(obj) {
	      	set newobj=$classmethod(class,"%New")
	       	set %appClass=class
	       	set %appClassSave=1
	      	set oiter = obj.%GetIterator()
	   		while ImpWhile,oiter.%GetNext(.propname, .propvalue, .typeObj ) {
		   		set %appClassProp=propname
		   		set %appClassPropVal=propvalue
		   		set %appClassPropType=typeObj
		   		set %appClassPropSet=1
	      		if $G(exec)'="" { 
		      		try {
						xecute "do "_exec ;
					}
					catch ex {
						write:$ze'["<Zshow" ex.AsStatus()
					}
	      		}
	      		if ("@"_$ze)["@<INTERRUPT>" set ImpWhile=0 quit ; $$$ThrowOnError($$$ERROR($$$GeneralError,$ze))
	      		set:$G(%appClassPropSet) $property(newobj,%appClassProp)=%appClassPropVal
	   		}
	   		;w !,"Finaly "_$g(%appClassSave)
	   		;zw newobj
	   		if $g(%appClassSave) {
		   		set st=newobj.%Save()
		   		if 'st write !,$System.Status.GetErrorText(st)
		   		else  write !,"saved"
	   		}
	   		
	      }
	}
	quit st
}

}

