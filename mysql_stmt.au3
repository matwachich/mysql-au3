#include-once

;~ Allocate and initialize memory for MYSQL_STMT structure
Func _MySQL_Stmt_Init($pMYSQL)
	; MYSQL_STMT * mysql_stmt_init(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "ptr", "mysql_stmt_init", "ptr", $pMYSQL)[0]
EndFunc

;~ Free memory used by prepared statement
Func _MySQL_Stmt_Close($pSTMT)
	; my_bool mysql_stmt_close(MYSQL_STMT *stmt)
	Return DllCall($__gMySQL_hDLL, "boolean", "mysql_stmt_close", "ptr", $pSTMT)[0] = 0
EndFunc

;~ Prepare statement for execution
Func _MySQL_Stmt_Prepare($pSTMT, $sQuery)
	; int mysql_stmt_prepare(MYSQL_STMT *stmt, const char *stmt_str, unsigned long length)
	$sQuery = __mySQL_strToBuf($sQuery)
	Return DllCall($pSTMT, "int", "mysql_stmt_prepare", "ptr", $pSTMT, "struct*", $sQuery, "ulong", @extended)[0]
EndFunc

;~ Associate application data buffers with parameter markers in prepared statement
Func _MySQL_Stmt_BindParam($pSTMT)
	; my_bool mysql_stmt_bind_param(MYSQL_STMT *stmt, MYSQL_BIND *bind)

EndFunc

;~ Execute prepared statement
Func _MySQL_Stmt_Execute($pSTMT)
	; int mysql_stmt_execute(MYSQL_STMT *stmt)
	Return DllCall($__gMySQL_hDLL, "int", "mysql_stmt_execute", "ptr", $pSTMT)[0] = 0
EndFunc
