/// Simple CSV serializer compatible with the usage in this project.
///
/// Provides `ListToCsvConverter` with a `const` constructor and a
/// `convert(List<List<dynamic>> rows)` method which returns a CSV string.
/// Rules applied:
/// - Fields containing commas, quotes or line breaks are wrapped in double quotes.
/// - Double quotes inside fields are escaped by doubling them (" -> "").
/// - Default field delimiter is `,` and end-of-line is `\n`.
class ListToCsvConverter {
  const ListToCsvConverter();

  /// Convert a 2D list of values to a CSV string.
  /// Each row is joined by [fieldDelimiter] and rows are separated by [eol].
  String convert(List<List<dynamic>> rows, {String fieldDelimiter = ',', String textDelimiter = '"', String eol = '\n'}) {
    return rows.map((row) {
      return row.map((cell) {
        final s = cell?.toString() ?? '';
        // need to escape if contains delimiter, quote or newline/carriage
        if (s.contains(fieldDelimiter) || s.contains(textDelimiter) || s.contains('\n') || s.contains('\r')) {
          final escaped = s.replaceAll(textDelimiter, textDelimiter + textDelimiter);
          return '$textDelimiter$escaped$textDelimiter';
        }
        return s;
      }).join(fieldDelimiter);
    }).join(eol);
  }
}

/// Simple CSV parser that converts a CSV string into a List<List<dynamic>>.
/// Supports quoted fields and doubled-quote escaping.
class CsvToListConverter {
  const CsvToListConverter();

  List<List<dynamic>> convert(String csv, {String fieldDelimiter = ','}) {
    final List<List<dynamic>> rows = [];
    List<dynamic> currentRow = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < csv.length; i++) {
      final ch = csv[i];
      if (inQuotes) {
        if (ch == '"') {
          // Check for escaped quote
          if (i + 1 < csv.length && csv[i + 1] == '"') {
            current.write('"');
            i++; // skip next quote
          } else {
            inQuotes = false;
          }
        } else {
          current.write(ch);
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
        } else if (ch == fieldDelimiter) {
          currentRow.add(current.toString());
          current.clear();
        } else if (ch == '\r') {
          // Handle CRLF
          if (i + 1 < csv.length && csv[i + 1] == '\n') i++;
          currentRow.add(current.toString());
          current.clear();
          rows.add(currentRow);
          currentRow = [];
        } else if (ch == '\n') {
          currentRow.add(current.toString());
          current.clear();
          rows.add(currentRow);
          currentRow = [];
        } else {
          current.write(ch);
        }
      }
    }

    // Add last field/row
    if (inQuotes) {
      // Unterminated quote - we'll treat as end of field
      inQuotes = false;
    }
    currentRow.add(current.toString());
    rows.add(currentRow);
    return rows;
  }
}

