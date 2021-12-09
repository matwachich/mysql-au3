#include-once

#Region : enum mysql_option =======================================================================

Const Enum _
	$MYSQL_OPT_CONNECT_TIMEOUT, $MYSQL_OPT_COMPRESS, $MYSQL_OPT_NAMED_PIPE, _
	$MYSQL_INIT_COMMAND, $MYSQL_READ_DEFAULT_FILE, $MYSQL_READ_DEFAULT_GROUP, _
	$MYSQL_SET_CHARSET_DIR, $MYSQL_SET_CHARSET_NAME, $MYSQL_OPT_LOCAL_INFILE, _
	$MYSQL_OPT_PROTOCOL, $MYSQL_SHARED_MEMORY_BASE_NAME, $MYSQL_OPT_READ_TIMEOUT, _
	$MYSQL_OPT_WRITE_TIMEOUT, $MYSQL_OPT_USE_RESULT, _
	$MYSQL_OPT_USE_REMOTE_CONNECTION, $MYSQL_OPT_USE_EMBEDDED_CONNECTION, _
	$MYSQL_OPT_GUESS_CONNECTION, $MYSQL_SET_CLIENT_IP, $MYSQL_SECURE_AUTH, _
	$MYSQL_REPORT_DATA_TRUNCATION, $MYSQL_OPT_RECONNECT, _
	$MYSQL_OPT_SSL_VERIFY_SERVER_CERT, $MYSQL_PLUGIN_DIR, $MYSQL_DEFAULT_AUTH, _
	$MYSQL_OPT_BIND, _
	$MYSQL_OPT_SSL_KEY, $MYSQL_OPT_SSL_CERT, _
	$MYSQL_OPT_SSL_CA, $MYSQL_OPT_SSL_CAPATH, $MYSQL_OPT_SSL_CIPHER, _
	$MYSQL_OPT_SSL_CRL, $MYSQL_OPT_SSL_CRLPATH, _
	$MYSQL_OPT_CONNECT_ATTR_RESET, $MYSQL_OPT_CONNECT_ATTR_ADD, _
	$MYSQL_OPT_CONNECT_ATTR_DELETE, _
	$MYSQL_SERVER_PUBLIC_KEY, _
	$MYSQL_ENABLE_CLEARTEXT_PLUGIN, _
	$MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS, _
	$MYSQL_OPT_SSL_ENFORCE, _
	$MYSQL_OPT_MAX_ALLOWED_PACKET, $MYSQL_OPT_NET_BUFFER_LENGTH, _
	$MYSQL_OPT_TLS_VERSION, _
	$MYSQL_OPT_SSL_MODE, _
	$MYSQL_OPT_GET_SERVER_PUBLIC_KEY

#EndRegion

#Region : _MySQL_RealConnect flags ================================================================

; The client can handle expired passwords. For more information, see Server Handling of Expired Passwords.
$CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS = BitShift(1, -22) ; (1UL << 22)

; Use compression in the client/server protocol.
$CLIENT_COMPRESS = 32

; Return the number of found (matched) rows, not the number of changed rows.
$CLIENT_FOUND_ROWS = 2

; Prevents the client library from installing a SIGPIPE signal handler. This can be used to avoid conflicts with a handler that the application has already installed.
$CLIENT_IGNORE_SIGPIPE = 4096

; Permit spaces after function names. Makes all functions names reserved words.
$CLIENT_IGNORE_SPACE = 256

; Permit interactive_timeout seconds of inactivity (rather than wait_timeout seconds) before closing the connection. The client's session wait_timeout variable is set to the value of the session interactive_timeout variable.
$CLIENT_INTERACTIVE = 1024

; Enable LOAD DATA LOCAL handling.
$CLIENT_LOCAL_FILES = 128

; Tell the server that the client can handle multiple result sets from multiple-statement executions or stored procedures. This flag is automatically enabled if CLIENT_MULTI_STATEMENTS is enabled. See the note following this table for more information about this flag.
$CLIENT_MULTI_RESULTS = BitShift(1, -17) ; (1UL << 17)

; Tell the server that the client may send multiple statements in a single string (separated by ; characters). If this flag is not set, multiple-statement execution is disabled. See the note following this table for more information about this flag.
$CLIENT_MULTI_STATEMENTS = BitShift(1, -16) ; (1UL << 16)

; Do not permit db_name.tbl_name.col_name syntax. This is for ODBC. It causes the parser to generate an error if you use that syntax, which is useful for trapping bugs in some ODBC programs.
$CLIENT_NO_SCHEMA = 16

; Unused.
$CLIENT_ODBC = 64

; Use SSL (encrypted protocol). Do not set this option within an application program; it is set internally in the client library. Instead, use mysql_options() or mysql_ssl_set() before calling mysql_real_connect().
$CLIENT_SSL = 2048

; Remember options specified by calls to mysql_options(). Without this option, if mysql_real_connect() fails, you must repeat the mysql_options() calls before trying to connect again. With this option, the mysql_options() calls need not be repeated.
$CLIENT_REMEMBER_OPTIONS = BitShift(1, -31) ; (1UL << 31)

#EndRegion

#Region : MYSQL_FIELD flags =======================================================================

Const $NOT_NULL_FLAG = 1 ; Field cannot be NULL
Const $PRI_KEY_FLAG = 2 ; Field is part of a primary key
Const $UNIQUE_KEY_FLAG = 4 ; Field is part of a unique key
Const $MULTIPLE_KEY_FLAG = 8 ; Field is part of a nonunique key
Const $UNSIGNED_FLAG = 32 ; Field has the UNSIGNED attribute
Const $ZEROFILL_FLAG = 64 ; Field has the ZEROFILL attribute
Const $BINARY_FLAG = 128 ; Field has the BINARY attribute
Const $AUTO_INCREMENT_FLAG = 512 ; Field has the AUTO_INCREMENT attribute
Const $ENUM_FLAG = 256 ; Field is an ENUM
Const $SET_FLAG = 2048 ; Field is a SET
Const $BLOB_FLAG = 16 ; Field is a BLOB or TEXT (deprecated)
Const $TIMESTAMP_FLAG = 1024 ; Field is a TIMESTAMP (deprecated)
Const $NUM_FLAG = 32768 ; Field is numeric; see additional notes following table
Const $NO_DEFAULT_VALUE_FLAG = 4096 ; Field has no default value; see additional notes following table

#EndRegion

#Region : Enum field types ========================================================================

Const $MYSQL_TYPE_TINY = 1 ; TINYINT field
Const $MYSQL_TYPE_SHORT = 2 ; SMALLINT field
Const $MYSQL_TYPE_LONG = 3 ; INTEGER field
Const $MYSQL_TYPE_INT24 = 9 ; MEDIUMINT field
Const $MYSQL_TYPE_LONGLONG = 8 ; BIGINT field
Const $MYSQL_TYPE_DECIMAL = 0 ; DECIMAL or NUMERIC field
Const $MYSQL_TYPE_NEWDECIMAL = 246 ; Precision math DECIMAL or NUMERIC
Const $MYSQL_TYPE_FLOAT = 4 ; FLOAT field
Const $MYSQL_TYPE_DOUBLE = 5 ; DOUBLE or REAL field
Const $MYSQL_TYPE_BIT = 16 ; BIT field
Const $MYSQL_TYPE_TIMESTAMP = 7 ; TIMESTAMP field
Const $MYSQL_TYPE_DATE = 10 ; DATE field
Const $MYSQL_TYPE_TIME = 11 ; TIME field
Const $MYSQL_TYPE_DATETIME = 12 ; DATETIME field
Const $MYSQL_TYPE_YEAR = 13 ; YEAR field
Const $MYSQL_TYPE_STRING = 254 ; CHAR or BINARY field
Const $MYSQL_TYPE_VAR_STRING = 253 ; VARCHAR or VARBINARY field
Const $MYSQL_TYPE_BLOB = 252 ; BLOB or TEXT field (use max_length to determine the maximum length)
Const $MYSQL_TYPE_SET = 248 ; SET field
Const $MYSQL_TYPE_ENUM = 247 ; ENUM field
Const $MYSQL_TYPE_GEOMETRY = 255 ; Spatial field
Const $MYSQL_TYPE_NULL = 6 ; NULL-type field

#EndRegion
