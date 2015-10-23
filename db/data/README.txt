The Testdata must be created in a file for each column with one entry per row. 
The file names follow the convention "#{table_name}_#{column_name}__#{type}" --> books_name__string
Each entry must have the following format:

Don't use time reference primary_key
Type    Format      Example
____________________________________
Binary              01001110110010
Boolean             true
Date     %d-%m-%Y   03-02-2001
Datetime RFC2822    Mon, 1 Jan -4712 00:00:00 +0000
Decimal             2.0225
Float               2.0225
Int                 4
TimestampRFC2822    Mon, 1 Jan -4712 00:00:00 +0000
