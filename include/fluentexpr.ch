#xcommand Throw <cMsg> With <aValues> ;
    => ;
    __MSG__ := Format( <cMsg>, <aValues> ) ;;
    aAdd( aTestReport, { .F., __MSG__ } ) ;;
    UserException( __MSG__ ) ;;
    Return Self

#xcommand Passed <cMsg> With <aValues> ;
    => ;
    __MSG__ := Format( <cMsg>, <aValues> ) ;;
    aAdd( aTestReport, { .T., __MSG__ } ) ;;
    Return Self
