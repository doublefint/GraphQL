Class GraphQL.Scope.Superclass Extends Abstract
{

Parameter SUPERCLASS = {"GraphQL.Scope.Superclass"};

/// This method should return a list of classes, available for GraphQL 
ClassMethod GetClasses() As %List
{
	set list = ""
	set rs = ..SubclassesListFunc()
	while rs.%Next() 
	{
		set classname = rs.Name
		continue:$e(classname)="%"
		continue:$$$defClassKeyGet(classname, $$$cCLASSsystem)'=0 // Skip system classes
		continue:'$$$comClassDefined(classname) // TODO fix for mapped classes
		set list = list _ $lb(classname)
	}
	quit list
}

/// This method should return a list of class fields, available for GraphQL 
ClassMethod GetProperties(classname As %Dictionary.CacheClassname) As %List
{
	if ($$$classIsPersistent(classname))
	{
		set class = ##class(%Dictionary.CompiledClass).%OpenId(classname)
		for i=1:1:class.Properties.Count() 
		{
			set property = class.Properties.GetAt(i)
			if property.Internal || property.Calculated || property.ReadOnly || property.Private || property.Identity continue
			set list = list _ $lb(property)
		}
	}else{
		quit $$$ERROR($$$GeneralError,"Class: "_classname_" must by %Persystent")
	}
	quit list
}

Query SubclassesList(superclass = {..#SUPERCLASS}) As %SQLQuery
{
SELECT s1.name
FROM %Dictionary.ClassDefinitionQuery_SubclassOf('%Library.Persistent') s1
INNER JOIN %Dictionary.ClassDefinitionQuery_SubclassOf(:superclass) s2 ON s2.name = s1.name
}

}

