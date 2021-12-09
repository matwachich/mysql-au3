#include-once

#include "mysql_defs.au3"
#include "mysql_tags.au3"
#include "mysql_errors.au3"

#Region : AutoIt UDF specific functions ===========================================================

Global $__gMySQL_hDLL = -1, $__gMySQL_fnOutput = Null

Func _MySQL_Startup($sDLLPath, $fnOutput = Default)
	$__gMySQL_hDLL = DllOpen($sDLLPath)
	If $__gMySQL_hDLL = -1 Then Return SetError(@error, 0, False)
	$__gMySQL_fnOutput = @Compiled ? Null : ($fnOutput = Default ? ConsoleWrite : $fnOutput)
	Return True
EndFunc

Func _MySQL_Shutdown()
	DllClose($__gMySQL_hDLL)
	$__gMySQL_hDLL = -1
	$__gMySQL_fnOutput = Null
EndFunc

; set label that will be displayed with error message
Func _MySQL_Au3_SetTraceLabel($sLabel = Default)
	Static $s_sLabel = Null
	If $sLabel <> Default Then
		$s_sLabel = $sLabel
	EndIf
	Return $s_sLabel
EndFunc

#EndRegion

#Region : getting info and version ================================================================

;~ Server status
Func _MySQL_Stat($pMYSQL)
	; const char * mysql_stat(MYSQL *mysql)
	Local $sRet = DllCall($__gMySQL_hDLL, "str", "mysql_stat", "ptr", $pMYSQL)[0]
	Return $sRet ? $sRet : SetError(__mySQL_outputError($pMYSQL, "mysql_stat"), 0, "")
EndFunc

; Get client version
Func _MySQL_GetClientVersion($bAsNumber = False)
	; const char * mysql_get_client_info(void)
	; unsigned long mysql_get_client_version(void)
	Return DllCall($__gMySQL_hDLL, $bAsNumber ? "ulong" : "str", "mysql_get_client_" & ($bAsNumber ? "version" : "info"))[0]
EndFunc

; Get server version
Func _MySQL_GetServerVersion($pMYSQL, $bAsNumber = False)
	; const char * mysql_get_server_info(MYSQL *mysql)
	; unsigned long mysql_get_server_version(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, $bAsNumber ? "ulong" : "str", "mysql_get_server_" & ($bAsNumber ? "version" : "info"), "ptr", $pMYSQL)[0]
EndFunc

;~ Information about the connection
Func _MySQL_GetHostInfo($pMYSQL)
	; const char * mysql_get_host_info(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "str", "mysql_get_host_info", "ptr", $pMYSQL)[0]
EndFunc

;~ Protocol version used by the connection
Func _MySQL_GetProtoInfo($pMYSQL)
	; unsigned int mysql_get_proto_info(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "uint", "mysql_get_proto_info", "ptr", $pMYSQL)[0]
EndFunc

;~ Current SSL cipher
Func _MySQL_GetSslCipher($pMYSQL)
	; const char * mysql_get_ssl_cipher(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "str", "mysql_get_ssl_cipher", "ptr", $pMYSQL)[0]
EndFunc

#EndRegion

#Region : init, config and connect ================================================================

;~ Get a MYSQL structure
Func _MySQL_Init()
	; MYSQL * mysql_init(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "ptr", "mysql_init", "ptr", 0)[0]
EndFunc

;~ Connect to MySQL server
Func _MySQL_RealConnect($pMYSQL = Null, $sHost = Null, $sUser = Null, $sPassword = Null, $sDB = Null, $iPort = 0, $sUnixSocket = Null, $iFlags = 0)
	; MYSQL * mysql_init(MYSQL *mysql)
	If Not $pMYSQL Then $pMYSQL = DllCall($__gMySQL_hDLL, "ptr", "mysql_init", "ptr", 0)[0] ; allocate a new MYSQL struct, that will be freed by mysql_close

	; MYSQL * mysql_real_connect(MYSQL *mysql, const char *host, const char *user, const char *passwd, const char *db, unsigned int port, const char *unix_socket, unsigned long client_flag)
	Local $pRet = DllCall($__gMySQL_hDLL, "ptr", "mysql_real_connect", _
		"ptr", $pMYSQL, _
		"struct*", __mySQL_strToUtf8Buf($sHost), _
		"struct*", __mySQL_strToUtf8Buf($sUser), _
		"struct*", __mySQL_strToUtf8Buf($sPassword), _
		"struct*", __mySQL_strToUtf8Buf($sDB), _
		"uint", $iPort, _
		"struct*", __mySQL_strToUtf8Buf($sUnixSocket), _
		"ulong", $iFlags _
	)[0]

	If $pRet Then _MySQL_CharacterSet($pRet, "utf8mb4")

	Return $pRet ? $pRet : SetError(__mySQL_outputError($pMYSQL, "mysql_real_connect"), 0, Null)
EndFunc

;~ Close connection to server
Func _MySQL_Close($pMYSQL)
	; void mysql_close(MYSQL *mysql)
	DllCall($__gMySQL_hDLL, "none", "mysql_close", "ptr", $pMYSQL)
EndFunc

;~ Reset the connection to clear session state
Func _MySQL_ResetConnection($pMYSQL)
	; int mysql_reset_connection(MYSQL *mysql)
	If DllCall($__gMySQL_hDLL, "int", "mysql_reset_connection", "ptr", $pMYSQL)[0] <> 0 Then
		Return SetError(__mySQL_outputError($pMYSQL, "mysql_reset_connection"), 0, False)
	EndIf
	Return True
EndFunc

;~ Change user and database on an open connection
Func _MySQL_ChangeUser($pMYSQL, $sUser, $sPassword, $sDB)
	; my_bool mysql_change_user(MYSQL *mysql, const char *user, const char *password, const char *db)
	If DllCall($__gMySQL_hDLL, "boolean", "mysql_change_user", _
		"ptr", $pMYSQL, _
		"struct*", __mySQL_strToUtf8Buf($sUser), _
		"struct*", __mySQL_strToUtf8Buf($sPassword), _
		"struct*", __mySQL_strToUtf8Buf($sDB) _
	)[0] <> 0 Then
		Return SetError(__mySQL_outputError($pMYSQL, "mysql_change_user"), 0, False)
	EndIf
	Return True
EndFunc

#EndRegion

#Region : options & configuration =================================================================

;~ Set option prior to connecting
Func _MySQL_Options($pMYSQL, $iOption, $vArg1, $vArg2 = Default)
	; int mysql_options(MYSQL *mysql, enum mysql_option option, const void *arg)
	; int mysql_options4(MYSQL *mysql, enum mysql_option option, const void *arg1, const void *arg2)
	Local $iRet
	Switch $iOption
		Case _
			$MYSQL_OPT_COMPRESS, _
			$MYSQL_OPT_CONNECT_ATTR_RESET, _
			$MYSQL_OPT_GUESS_CONNECTION, _
			$MYSQL_OPT_NAMED_PIPE, _
			$MYSQL_OPT_USE_EMBEDDED_CONNECTION, _
			$MYSQL_OPT_USE_REMOTE_CONNECTION, _
			$MYSQL_OPT_USE_RESULT
			Return DllCall($__gMySQL_hDLL, "int", "mysql_options", "ptr", $pMYSQL, "int", $iOption, "ptr", 0)[0] = 0
		Case _
			$MYSQL_ENABLE_CLEARTEXT_PLUGIN, _
			$MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS, _
			$MYSQL_OPT_GET_SERVER_PUBLIC_KEY, _
			$MYSQL_OPT_RECONNECT, _
			$MYSQL_OPT_SSL_ENFORCE, _
			$MYSQL_OPT_SSL_VERIFY_SERVER_CERT, _
			$MYSQL_REPORT_DATA_TRUNCATION, _
			$MYSQL_SECURE_AUTH
			Return DllCall($__gMySQL_hDLL, "int", "mysql_options", "ptr", $pMYSQL, "int", $iOption, "boolean*", $vArg1)[0] = 0
		Case _
			$MYSQL_OPT_MAX_ALLOWED_PACKET, _
			$MYSQL_OPT_NET_BUFFER_LENGTH
			Return DllCall($__gMySQL_hDLL, "int", "mysql_options", "ptr", $pMYSQL, "int", $iOption, "ulong*", $vArg1)[0] = 0
		Case _
			$MYSQL_OPT_CONNECT_TIMEOUT, _
			$MYSQL_OPT_LOCAL_INFILE, _
			$MYSQL_OPT_PROTOCOL, _
			$MYSQL_OPT_READ_TIMEOUT, _
			$MYSQL_OPT_SSL_MODE, _
			$MYSQL_OPT_WRITE_TIMEOUT
			Return DllCall($__gMySQL_hDLL, "int", "mysql_options", "ptr", $pMYSQL, "int", $iOption, "uint*", $vArg1)[0] = 0
		Case _
			$MYSQL_DEFAULT_AUTH, _
			$MYSQL_INIT_COMMAND, _
			$MYSQL_OPT_BIND, _
			$MYSQL_OPT_CONNECT_ATTR_DELETE, _
			$MYSQL_OPT_SSL_CA, _
			$MYSQL_OPT_SSL_CAPATH, _
			$MYSQL_OPT_SSL_CERT, _
			$MYSQL_OPT_SSL_CIPHER, _
			$MYSQL_OPT_SSL_CRL, _
			$MYSQL_OPT_SSL_CRLPATH, _
			$MYSQL_OPT_SSL_KEY, _
			$MYSQL_OPT_TLS_VERSION, _
			$MYSQL_PLUGIN_DIR, _
			$MYSQL_READ_DEFAULT_FILE, _
			$MYSQL_READ_DEFAULT_GROUP, _
			$MYSQL_SERVER_PUBLIC_KEY, _
			$MYSQL_SET_CHARSET_DIR, _
			$MYSQL_SET_CHARSET_NAME, _
			$MYSQL_SET_CLIENT_IP, _
			$MYSQL_SHARED_MEMORY_BASE_NAME
			Return DllCall($__gMySQL_hDLL, "int", "mysql_options", "ptr", $pMYSQL, "int", $iOption, "str", $vArg1)[0] = 0
		Case $MYSQL_OPT_CONNECT_ATTR_ADD
			Return DllCall($__gMySQL_hDLL, "int", "mysql_options4", "ptr", $pMYSQL, "int", $iOption, "str", $vArg1, "str", $vArg2)[0] = 0
	EndSwitch
	;TODO error handling and reporting
EndFunc

; mysql_getoptions() ; TODO

;~ Sets autocommit mode
Func _MySQL_AutoCommit($pMYSQL, $bEnable = True)
	; my_bool mysql_autocommit(MYSQL *mysql, my_bool mode)
	If DllCall($__gMySQL_hDLL, "boolean", "mysql_autocommit", "ptr", $pMYSQL, "boolean", $bEnable)[0] <> 0 Then
		Return SetError(__mySQL_outputError($pMYSQL, "mysql_autocommit"), 0, False)
	EndIf
	Return True
EndFunc

;~ Character set name for current connection
Func _MySQL_CharacterSet($pMYSQL, $sCSName = Default)
	If $sCSName Then
		; int mysql_set_character_set(MYSQL *mysql, const char *csname)
		If DllCall($__gMySQL_hDLL, "int", "mysql_set_character_set", "ptr", $pMYSQL, "str", $sCSName)[0] <> 0 Then
			Return SetError(__mySQL_outputError($pMYSQL, "mysql_set_character_set"), 0, False)
		EndIf
		Return True
	Else
		; const char * mysql_character_set_name(MYSQL *mysql)
		Return DllCall($__gMySQL_hDLL, "str", "mysql_character_set_name", "ptr", $pMYSQL)[0]
	EndIf
EndFunc

;~ Information about default character set
Func _MySQL_GetCharacterSetInfo($pMYSQL)
	; void mysql_get_character_set_info(MYSQL *mysql, MY_CHARSET_INFO *cs)
	Local $tInfo = DllStructCreate($tagMY_CHARSET_INFO)
	DllCall($__gMySQL_hDLL, "none", "mysql_get_character_set_info", "ptr", $pMYSQL, "struct*", $tInfo)

	Local $aRet[] = [ _
		$tInfo.number, _                     ; character set number
		$tInfo.state, _                      ; character set state
		__mySQL_pstrToStr($tInfo.csname), _  ; character set name
		__mySQL_pstrToStr($tInfo.name), _    ; collation name
		__mySQL_pstrToStr($tInfo.comment), _ ; comment
		__mySQL_pstrToStr($tInfo.dir), _     ; character set directory
		$tInfo.mbminlen, _                   ; min. length for multibyte strings
		$tInfo.mbmaxlen _                    ; max. length for multibyte strings
	]
	Return $aRet
EndFunc

#EndRegion

#Region : server operations =======================================================================

;~ Ping server
Func _MySQL_Ping($pMYSQL)
	; int mysql_ping(MYSQL *mysql)
	If DllCall($__gMySQL_hDLL, "int", "mysql_ping", "ptr", $pMYSQL)[0] <> 0 Then
		Return SetError(__mySQL_outputError($pMYSQL, "mysql_ping"), 0, False)
	EndIf
	Return True
EndFunc

;~ Current server's thread ID for the connection
Func _MySQL_ThreadID($pMYSQL)
	; unsigned long mysql_thread_id(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "ulong", "mysql_thread_id", "ptr", $pMYSQL)[0]

;~ 	This function does not work correctly if thread IDs become larger than
;~ 	32 bits, which can occur on some systems. To avoid problems with
;~ 	mysql_thread_id(), do not use it. To get the connection ID, execute a
;~ 	SELECT CONNECTION_ID() query and retrieve the result.
EndFunc

;~ Return database names matching regular expression
Func _MySQL_ListDBs($pMYSQL, $sWildcard = Null)
	; MYSQL_RES * mysql_list_dbs(MYSQL *mysql, const char *wild)
	Local $pRESULT = DllCall($__gMySQL_hDLL, "ptr", "mysql_list_dbs", "ptr", $pMYSQL, "struct*", __mySQL_strToUtf8Buf($sWildcard))[0]
	If Not $pRESULT Then Return SetError(__mySQL_outputError($pMYSQL, "mysql_list_dbs"), 0, Null)

	Local $aRow, $aRet[0]
	While _MySQL_FetchRow($pRESULT, $aRow)
		ReDim $aRet[UBound($aRet) + 1]
		$aRet[UBound($aRet) - 1] = $aRow[0]
	WEnd
	_MySQL_FreeResult($pRESULT)
	Return $aRet
EndFunc

;~ Return table names matching regular expression
Func _MySQL_ListTables($pMYSQL, $sWildcard = Null)
	; MYSQL_RES * mysql_list_tables(MYSQL *mysql, const char *wild)
	Local $pRESULT = DllCall($__gMySQL_hDLL, "ptr", "mysql_list_tables", "ptr", $pMYSQL, "struct*", __mySQL_strToUtf8Buf($sWildcard))[0]
	If Not $pRESULT Then Return SetError(__mySQL_outputError($pMYSQL, "mysql_list_tables"), 0, Null)

	Local $aRow, $aRet[0]
	While _MySQL_FetchRow($pRESULT, $aRow)
		ReDim $aRet[UBound($aRet) + 1]
		$aRet[UBound($aRet) - 1] = $aRow[0]
	WEnd
	_MySQL_FreeResult($pRESULT)
	Return $aRet
EndFunc

;~ Return field names matching regular expression => DEPRECATED (5.7.11) : use SHOW COLUMNS FROM tbl_name
;~ MYSQL_RES * mysql_list_fields(MYSQL *mysql, const char *table, const char *wild)

;~ List of current server threads => DEPRECATED (5.7.11) : use SHOW PROCESSLIST
;~ MYSQL_RES * mysql_list_processes(MYSQL *mysql)

#EndRegion

#Region : transactions ============================================================================

;~ Commit transaction
Func _MySQL_Commit($pMYSQL)
	; my_bool mysql_commit(MYSQL *mysql)
	If DllCall($__gMySQL_hDLL, "boolean", "mysql_commit", "ptr", $pMYSQL)[0] <> 0 Then
		Return SetError(__mySQL_outputError($pMYSQL, "mysql_commit"), 0, False)
	EndIf
	Return True
EndFunc

;~ Roll back transaction
Func _MySQL_Rollback($pMYSQL)
	; my_bool mysql_rollback(MYSQL *mysql)
	If DllCall($__gMySQL_hDLL, "boolean", "mysql_rollback", "ptr", $pMYSQL)[0] <> 0 Then
		Return SetError(__mySQL_outputError($pMYSQL, "mysql_rollback"), 0, False)
	EndIf
	Return True
EndFunc

#EndRegion

#Region : statements execution ====================================================================

;~ Select database
Func _MySQL_SelectDB($pMYSQL, $sDB)
	; int mysql_select_db(MYSQL *mysql, const char *db)
	If DllCall($__gMySQL_hDLL, "int", "mysql_select_db", "ptr", $pMYSQL, "str", $sDB)[0] <> 0 Then
		Return SetError(__mySQL_outputError($pMYSQL, "mysql_select_db"), 0, False)
	EndIf
	Return True
EndFunc

#include <WinAPIDiag.au3>

;~ Execute statement
Func _MySQL_RealQuery($pMYSQL, $sQuery)
	; int mysql_real_query(MYSQL *mysql, const char *stmt_str, unsigned long length)
	Local $tQuery = __mySQL_strToUtf8Buf($sQuery, False)
	If DllCall($__gMySQL_hDLL, "int", "mysql_real_query", "ptr", $pMYSQL, "struct*", $tQuery, "ulong", @extended)[0] <> 0 Then
		Return SetError(__mySQL_outputError($pMYSQL, "mysql_real_query", $sQuery), 0, False)
	EndIf
	Return True
EndFunc

;~ Information about most recently executed statement
Func _MySQL_Info($pMYSQL)
	; const char * mysql_info(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "str", "mysql_info", "ptr", $pMYSQL)[0]
EndFunc

;~ ID generated for an AUTO_INCREMENT column by previous statement
Func _MySQL_InsertID($pMYSQL)
	; my_ulonglong mysql_insert_id(MYSQL *mysql)
	Local $iRet = DllCall($__gMySQL_hDLL, "uint64", "mysql_insert_id", "ptr", $pMYSQL)[0]
	Return SetError(__mySQL_outputError($pMYSQL, "mysql_insert_id"), 0, $iRet)
EndFunc

;~ Number of rows changed/deleted/inserted by last UPDATE, DELETE, or INSERT statement
Func _MySQL_AffectedRows($pMYSQL)
	; my_ulonglong mysql_affected_rows(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "uint64", "mysql_affected_rows", "ptr", $pMYSQL)[0]
EndFunc

;~ Check whether more results exist
Func _MySQL_MoreResults($pMYSQL)
	; my_bool mysql_more_results(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "boolean", "mysql_more_results", "ptr", $pMYSQL)[0] <> 0
EndFunc

;~ Return/initiate next result in multiple-result execution
Func _MySQL_NextResult($pMYSQL)
	; int mysql_next_result(MYSQL *mysql)
	Local $iRet = DllCall($__gMySQL_hDLL, "int", "mysql_next_result", "ptr", $pMYSQL)[0]
	Switch $iRet
		Case 0
			Return True ; more results
		Case -1
			Return False ; no more results
		Case Else ; > 0
			Return SetError(__mySQL_outputError($pMYSQL, "mysql_next_result"), 0, False) ; error
	EndSwitch
EndFunc

;~ Number of result columns for most recent statement
Func _MySQL_FieldCount($pMYSQL)
	; unsigned int mysql_field_count(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "uint", "mysql_field_count", "ptr", $pMYSQL)[0]
EndFunc

;~ Retrieve and store entire result set
Func _MySQL_StoreResult($pMYSQL)
	; MYSQL_RES * mysql_store_result(MYSQL *mysql)
	Local $pRet = DllCall($__gMySQL_hDLL, "ptr", "mysql_store_result", "ptr", $pMYSQL)[0]
	Return $pRet ? $pRet : SetError(__mySQL_outputError($pMYSQL, "mysql_store_result"), 0, Null)
EndFunc

;~ Initiate row-by-row result set retrieval
Func _MySQL_UseResult($pMYSQL)
	; MYSQL_RES * mysql_use_result(MYSQL *mysql)
	Local $pRet = DllCall($__gMySQL_hDLL, "ptr", "mysql_use_result", "ptr", $pMYSQL)[0]
	Return $pRet ? $pRet : SetError(__mySQL_outputError($pMYSQL, "mysql_use_result"), 0, Null)
EndFunc

#EndRegion

#Region : result processing =======================================================================

;~ Number of columns in result set
Func _MySQL_NumFields($pRESULT)
	; unsigned int mysql_num_fields(MYSQL_RES *result)
	Return DllCall($__gMySQL_hDLL, "uint", "mysql_num_fields", "ptr", $pRESULT)[0]
EndFunc

;~ Number of rows in result set
Func _MySQL_NumRows($pRESULT)
	; my_ulonglong mysql_num_rows(MYSQL_RES *result)
	Return DllCall($__gMySQL_hDLL, "uint64", "mysql_num_rows", "ptr", $pRESULT)[0]
EndFunc

;~ Return array of all field structures
Func _MySQL_FetchFields($pRESULT, $bAllInfo = False)
	; MYSQL_FIELD * mysql_fetch_fields(MYSQL_RES *result)
	Local $iNumFields = _MySQL_NumFields($pRESULT)
	If $iNumFields <= 0 Then Return Null

	Local $pFields = DllCall($__gMySQL_hDLL, "ptr", "mysql_fetch_fields", "ptr", $pRESULT)[0]
	If Not $pFields Then Return Null

	If $bAllInfo Then
		Local $aRet[$iNumFields][13] ; all field informations
	Else
		Local $aRet[$iNumFields] ; only field name
	EndIf

	Local $iFieldSize = DllStructGetSize(DllStructCreate($tagMYSQL_FIELD))
	For $i = 0 To $iNumFields - 1
		$tField = DllStructCreate($tagMYSQL_FIELD, $pFields + ($i * $iFieldSize))
		If $bAllInfo Then
			$aRet[$i][0] = __mySQL_pstrToStr($tField.name, $tField.name_length)
			$aRet[$i][1] = __mySQL_pstrToStr($tField.org_name, $tField.org_name_length)
			$aRet[$i][2] = __mySQL_pstrToStr($tField.table, $tField.table_length)
			$aRet[$i][3] = __mySQL_pstrToStr($tField.org_table, $tField.org_table_length)
			$aRet[$i][4] = __mySQL_pstrToStr($tField.db, $tField.db_length)
			$aRet[$i][5] = __mySQL_pstrToStr($tField.catalog, $tField.catalog_length)
			$aRet[$i][6] = __mySQL_pstrToStr($tField.def, $tField.def_length)
			$aRet[$i][7] = $tField.length
			$aRet[$i][8] = $tField.max_length
			$aRet[$i][9] = $tField.flags
			$aRet[$i][10] = $tField.decimals
			$aRet[$i][11] = $tField.charsetnf
			$aRet[$i][12] = $tField.type
		Else
			$aRet[$i] = __mySQL_pstrToStr($tField.name, $tField.name_length)
		EndIf
	Next
	Return $aRet
EndFunc

;~ Fetch next result set row
Func _MySQL_FetchRow($pRESULT, ByRef $aRow, $bBinary = False)
	; MYSQL_ROW mysql_fetch_row(MYSQL_RES *result)
	Local $iNumFields = _MySQL_NumFields($pRESULT)
	If $iNumFields <= 0 Then Return False

	Local $pData = DllCall($__gMySQL_hDLL, "ptr", "mysql_fetch_row", "ptr", $pRESULT)[0]
	If Not $pData Then
		 ; retreive pMYSQL from pRESULT (will be 0 if mysql_store_result was used)
		Local $pMYSQL = DllStructGetData(DllStructCreate("uint64;ptr;ptr;ptr;ulong;ptr", $pRESULT), 6)
		If Not $pMYSQL Then Return False ; we used mysql_store_result, so no error can be returned by mysql_fetch_row

		Return SetError(__mySQL_outputError($pMYSQL, "mysql_fetch_row"), 0, False)
	EndIf

	Local $pLengths = DllCall($__gMySQL_hDLL, "ptr", "mysql_fetch_lengths", "ptr", $pRESULT)[0]
	If Not $pLengths Then Return False ; should not return error if fetch_row is successfull

	Local $pFields = DllCall($__gMySQL_hDLL, "ptr", "mysql_fetch_fields", "ptr", $pRESULT)[0]
	If Not $pFields Then Return False ; should not return error if fetch_row is successfull

	Local $tDataPtrs = DllStructCreate("ptr[" & $iNumFields & "]", $pData)
	Local $tLengths = DllStructCreate("ulong[" & $iNumFields & "]", $pLengths)

	Dim $aRow[$iNumFields]

	Local $tData, $bData, $tField
	Local $iFieldSize = DllStructGetSize(DllStructCreate($tagMYSQL_FIELD))

	For $i = 0 To $iNumFields - 1
		; check for NULL value (pointer = 0)
		If Not DllStructGetData($tDataPtrs, 1, $i + 1) Then
			$aRow[$i] = Null
			ContinueLoop
		EndIf

		$tField = DllStructCreate($tagMYSQL_FIELD, $pFields + ($i * $iFieldSize))

		If DllStructGetData($tLengths, 1, $i + 1) > 0 Then
			$bData = DllStructGetData( _
				DllStructCreate( _
					"byte[" & DllStructGetData($tLengths, 1, $i + 1) & "]", _
					DllStructGetData($tDataPtrs, 1, $i + 1) _
				), _
				1 _
			)
		Else
			$bData = Binary("")
		EndIf

		If $bBinary Then
			$aRow[$i] = $bData
		Else
			Switch $tField.type
				Case $MYSQL_TYPE_NULL
					$aRow[$i] = Null
				Case _
					$MYSQL_TYPE_TINY, _
					$MYSQL_TYPE_SHORT, _
					$MYSQL_TYPE_LONG, _
					$MYSQL_TYPE_INT24, _
					$MYSQL_TYPE_LONGLONG, _
					$MYSQL_TYPE_DECIMAL, _
					$MYSQL_TYPE_NEWDECIMAL, _
					$MYSQL_TYPE_FLOAT, _
					$MYSQL_TYPE_DOUBLE
					$aRow[$i] = Number(BinaryToString($bData))
				Case _
					$MYSQL_TYPE_STRING, _
					$MYSQL_TYPE_VAR_STRING, _
					$MYSQL_TYPE_BLOB, _ ; TEXT or BLOB
					$MYSQL_TYPE_ENUM, _
					$MYSQL_TYPE_SET
					; because TEXT fields are passed as MYSQL_TYPE_BLOB, we check the Binary flag
					$aRow[$i] = BitAND($tField.flags, $BINARY_FLAG) ? $bData : BinaryToString($bData, 4)
				Case _
					$MYSQL_TYPE_TIMESTAMP, _
					$MYSQL_TYPE_DATE, _
					$MYSQL_TYPE_TIME, _
					$MYSQL_TYPE_DATETIME, _
					$MYSQL_TYPE_YEAR
					; because date fields have BINARY_FLAG, but we want to get them as String
					$aRow[$i] = BinaryToString($bData, 4)
				Case Else
					$aRow[$i] = $bData
			EndSwitch
		EndIf
	Next
	Return True
EndFunc

;~ Seek to arbitrary row number in query result set
Func _MySQL_DataSeek($pRESULT, $iRowOffset)
	; void mysql_data_seek(MYSQL_RES *result, my_ulonglong offset)
	DllCall($__gMySQL_hDLL, "none", "mysql_data_seek", "ptr", $pRESULT, "uint64", $iRowOffset)
EndFunc

;~ Seek to row offset in result set
Func _MySQL_RowSeek($pRESULT, $pRowOffset)
	; MYSQL_ROW_OFFSET mysql_row_seek(MYSQL_RES *result, MYSQL_ROW_OFFSET offset)
	Return DllCall($__gMySQL_hDLL, "ptr", "mysql_row_seek", "ptr", $pRESULT, "ptr", $pRowOffset)[0]
EndFunc

;~ Current position within result set row
Func _MySQL_RowTell($pRESULT)
	; MYSQL_ROW_OFFSET mysql_row_tell(MYSQL_RES *result)
	Return DllCall($__gMySQL_hDLL, "ptr", "mysql_row_tell", "ptr", $pRESULT)[0]
EndFunc

;~ Free result set memory
Func _MySQL_FreeResult($pRESULT)
	; void mysql_free_result(MYSQL_RES *result)
	DllCall($__gMySQL_hDLL, "none", "mysql_free_result", "ptr", $pRESULT)
EndFunc

#EndRegion

#Region : string & blob escaping ==================================================================

Func _MySQL_RealEscapeString($pMYSQL, $sString, $sQuote = '"')
	$sString = StringToBinary($sString, 4)
	Local $iLen = BinaryLen($sString)
	If $iLen <= 0 Then Return $sQuote & $sQuote

	Local $tString = DllStructCreate("byte[" & $iLen & "]")
	DllStructSetData($tString, 1, $sString)

	Local $tBuf = DllStructCreate("byte[" & ($iLen * 2 + 1) & "]")

	; unsigned long mysql_real_escape_string(MYSQL *mysql, char *to, const char *from, unsigned long length)
	; unsigned long mysql_real_escape_string_quote(MYSQL *mysql, char *to, const char *from, unsigned long length, char quote)
	$aRet = DllCall($__gMySQL_hDLL, "ulong", "mysql_real_escape_string_quote", _
		"ptr", $pMYSQL, _
		"struct*", $tBuf, _
		"struct*", $tString, _
		"ulong", $iLen, _
		"byte", Asc(StringLeft($sQuote, 1)) _
	)
	If $aRet[0] <= 0 Then Return $sQuote & $sQuote

	Return $sQuote & BinaryToString(DllStructGetData(DllStructCreate("byte[" & $aRet[0] & "]", DllStructGetPtr($tBuf)), 1), 4) & $sQuote
EndFunc

;~ Encode string in hexadecimal format
Func _MySQL_HexString($sString)
	; unsigned long mysql_hex_string(char *to, const char *from, unsigned long length)
	$sString = StringToBinary($sString, 4)
	Local $iLen = BinaryLen($sString)
	Local $tFrom = DllStructCreate("byte[" & $iLen & "]")
	DllStructSetData($tFrom, 1, $sString)
	Local $tTo = DllStructCreate("char[" & ($iLen * 2 + 1) & "]")
	DllCall($__gMySQL_hDLL, "ulong", "mysql_hex_string", "struct*", $tTo, "struct*", $tFrom, "ulong", $iLen)
	Return DllStructGetData($tTo, 1)
EndFunc

#EndRegion

#Region : errors ==================================================================================

;~ Error number for most recently invoked MySQL function
Func _MySQL_Errno($pMYSQL)
	; unsigned int mysql_errno(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "uint", "mysql_errno", "ptr", $pMYSQL)[0]
EndFunc

;~ Error message for most recently invoked MySQL function
Func _MySQL_Error($pMYSQL)
	; const char * mysql_error(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "str", "mysql_error", "ptr", $pMYSQL)[0]
EndFunc

;~ SQLSTATE value for most recently invoked MySQL function
Func _MySQL_SQLState($pMYSQL)
	; const char * mysql_sqlstate(MYSQL *mysql)
	Return DllCall($__gMySQL_hDLL, "str", "mysql_sqlstate", "ptr", $pMYSQL)[0]
EndFunc

#EndRegion

; =================================================================================================
; Internal helper functions

Func __mySQL_outputError($pMYSQL, $sFunc, $sQuery = "")
	Local $iError = _MySQL_Errno($pMYSQL)
	If $iError And IsFunc($__gMySQL_fnOutput) Then
		Local $sLabel = _MySQL_Au3_SetTraceLabel()
		$__gMySQL_fnOutput( _
			@CRLF & _
			"!	MySQL ERROR " & $iError & " (" & _MySQL_SQLState($pMYSQL) & ") @ " & $sFunc & ($sLabel ? " (" & $sLabel & ")" : "") & @CRLF & _
			"-	" & _MySQL_Error($pMYSQL) & @CRLF & _
			($sQuery ? "	" & (StringInStr($sQuery, @CRLF) ? @CRLF & $sQuery : $sQuery) & @CRLF : "") _
		)
	EndIf
	Return $iError
EndFunc

Func __mySQL_strToUtf8Buf($sText, $bNullTerminate = True)
	If $sText = Null Then Return 0

	Local $bText = StringToBinary($sText, 4)
	Local $iLen = BinaryLen($bText)
	If $iLen <= 0 Then Return SetExtended(0, DllStructCreate("byte[1]")) ; null-terminated empty string

	Local $tText = DllStructCreate("byte[" & ($bNullTerminate ? ($iLen + 1) : $iLen) & "]")
	DllStructSetData($tText, 1, $bText)

	Return SetExtended($iLen, $tText)
EndFunc

Func __mySQL_pstrToStr($pStr, $iLen = -1, $bUTF16 = False)
	If $pStr = 0 Then Return ""
	If $iLen < 0 Then $iLen = DllCall("kernel32.dll", "int", "lstrlen" & ($bUTF16 ? "W" : "A"), "ptr", $pStr)[0]
	If $iLen = 0 Then Return ""

	Local $vRet = DllStructGetData(DllStructCreate(($bUTF16 ? "wchar" : "byte") & "[" & $iLen & "]", $pStr), 1)
	Return $bUTF16 ? $vRet : BinaryToString($vRet, 4)
EndFunc
