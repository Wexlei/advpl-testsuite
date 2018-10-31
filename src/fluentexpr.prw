#include 'protheus.ch'
#include 'fluentexpr.ch'
#include 'testsuite.ch'

/**
 * This class is an assertion library whose expressions
 * are called by the TestSuite metaclass.
 *
 * @class FluentExpr
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Class FluentExpr

    Data xValue
    Data lNot

    Method New( xValue ) Constructor
    Method Not()

    Method ToBe( xOther )
    Method ToBeAFile()
    Method ToBeAFileWithContents( cContent )
    Method ToBeAFolder()
    Method ToHaveType( cType )
    Method ToThrowError()

EndClass

/**
 * @method New
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Method New( xValue ) Class FluentExpr

    ::xValue := xValue
    ::lNot := .F.

    Return Self

/**
 * @method Not
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Method Not() Class FluentExpr

    ::lNot := .T.

    Return Self

/**
 * @method ToBe
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Method ToBe( xOther ) Class FluentExpr

    Local cValue := ToString( ::xValue )
    Local cOther := ToString( xOther )

    If ::lNot
        If cValue == cOther
            Throw 'Expected {1} to not be {2}' With { cValue, cOther }
        EndIf

        Passed 'Expected {1} to not be {2}' With { cValue, cOther }
    Else
        If !(cValue == cOther)
            Throw 'Expected {1} to be {2}' With { cValue, cOther }
        EndIf

        Passed 'Expected {1} to be {2}' With { cValue, cOther }
    EndIf

    Return Self

/**
 * @method ToBeAFile
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Method ToBeAFile() Class FluentExpr

    Local lIsFile := File( ::xValue )

    If ::lNot
        If lIsFile
            Throw 'Expected {1} to not be a file' with { ::xValue }
        EndIf
        Passed 'Expected {1} to not be a file' With { ::xValue }
    Else
        If !lIsFile
            Throw 'Expected {1} to be a file' with { ::xValue }
        EndIf
        Passed 'Expected {1} to be a file' With { ::xValue }
    EndIf

    Return Self

/**
 * @method ToBeAFileWithContents
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Method ToBeAFileWithContents( cContent ) Class FluentExpr

    Local lIsFile := File( ::xValue )

    If ::lNot
        If lIsFile .And. MemoRead( ::xValue ) == cContent
            Throw 'Expected {1} to not be a file with contents "{2}"' with { ::xValue, cContent }
        EndIf
        Passed 'Expected {1} to not be a file with contents "{2}"' With { ::xValue, cContent }
    Else
        If !lIsFile .Or. !(MemoRead( ::xValue ) == cContent)
            Throw 'Expected {1} to be a file with contents "{2}"' with { ::xValue, cContent }
        EndIf
        Passed 'Expected {1} to be a file with contents "{2}"' With { ::xValue, cContent }
    EndIf

    Return Self

/**
 * @method ToBeAFolder
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Method ToBeAFolder() Class FluentExpr

    Local lIsFolder := ExistDir( ::xValue )

    If ::lNot
        If lIsFolder
            Throw 'Expected {1} to not be a folder' with { ::xValue }
        EndIf
        Passed 'Expected {1} to not be a folder' With { ::xValue }
    Else
        If !lIsFolder
            Throw 'Expected {1} to be a folder' with { ::xValue }
        EndIf
        Passed 'Expected {1} to be a folder' With { ::xValue }
    EndIf

    Return Self

/**
 * @method ToHaveType
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Method ToHaveType( cType ) Class FluentExpr

    Local cMyType := ValType( ::xValue )

    If ::lNot
        If cMyType == cType
            Throw 'Expected {1} to not have type {2}, but it does' With { ::xValue, cType }
        EndIf
        Passed 'Expected {1} to not have type {2} (it is a {3})' With { ::xValue, cType, cMyType }
    Else
        If !(cMyType == cType)
            Throw 'Expected {1} to have type {2}, but it has type {3}' With { ::xValue, cType, cMyType }
        EndIf
        Passed 'Expected {1} to have type {2}' With { ::xValue, cType }
    EndIf

    Return Self

/**
 * @method ToThrowError
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Method ToThrowError() Class FluentExpr

    Local oError
    Local bError := ErrorBlock( { |oExc| oError := oExc } )
    Local cSource := GetCBSource( ::xValue )

    Begin Sequence
        Eval( ::xValue )
    End Sequence

    ErrorBlock( bError )

    If oError == Nil
        aAdd( aTestReport, { .F., 'Expected {1} to throw an error', { cSource } } )
        UserException( 'Expected ' + cSource + ' to throw error' )
        Return Self
    EndIf
    aAdd( aTestReport, { .T., 'Expected {1} to throw an error', { cSource } } )

    Return Self

/**
 * @function Format
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Static Function Format( cString, aValues )

    Local cResult := cString
    Local nIndex

    For nIndex := 1 To Len( aValues )
        cResult := StrTran( cResult, '{' + AllTrim( Str( nIndex ) ) + '}', ToString( aValues[ nIndex ] ) )
    Next

    Return cResult

/**
 * @function ToString
 * @author Marcelo Camargo
 * @since 02/2018
 **/
Static Function ToString( xValue )

    Local cType := ValType( xValue )

    If cType == "A"
        Return '{ ' + ArrTokStr( xValue, ', ') + ' }'
    ElseIf cType == "B"
        Return GetCBSource( xValue )
    ElseIf cType == "O"
        Return ArrTokStr( ClassMethArr( xValue, .T. ), ' | ' )
    EndIf

    Return cValToChar( xValue )
