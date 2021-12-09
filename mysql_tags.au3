#include-once

; internal use only

Const $tagMYSQL_FIELD = _
	'ptr   name;' & _       ; Name of column
	'ptr   org_name;' & _   ; Name of original column
	'ptr   table;' & _      ; Table of column if column was a field
	'ptr   org_table;' & _  ; Name of original table
	'ptr   db;' & _         ; Table schema
	'ptr   catalog;' & _    ; Table catalog
	'ptr   def;' & _        ; Default value
	'ulong length;' & _     ; Width of column
	'ulong max_length;' & _ ; Max width of selected set
	'uint  name_length;' & _
	'uint  org_name_length;' & _
	'uint  table_length;' & _
	'uint  org_table_length;' & _
	'uint  db_length;' & _
	'uint  catalog_length;' & _
	'uint  def_length;' & _
	'uint  flags;' & _     ; Div flags
	'uint  decimals;' & _  ; Number of decimals in field
	'uint  charsetnf;' & _ ; Char set number
	'int   type;' & _      ; Type of field (enum_field_types)
	'ptr   extension;'

Const $tagMY_CHARSET_INFO = _
	'uint number;' & _   ; character set number
	'uint state;' & _    ; character set state
	'ptr  csname;' & _   ; character set name
	'ptr  name;' & _     ; collation name
	'ptr  comment;' & _  ; comment
	'ptr  dir;' & _      ; character set directory
	'uint mbminlen;' & _ ; min. length for multibyte strings
	'uint mbmaxlen;'     ; max. length for multibyte strings
