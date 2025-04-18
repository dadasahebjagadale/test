
import java.io.*;
import java.util.*;

public class CaseInsensitiveCSVProcessor {

    static class TransactionData {
        Map<String, String> allValues = new HashMap<>();
    }

    public static void processCSV(String inputPath, String outputPath, List<String> outputHeader) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(inputPath));
        Map<String, Integer> headerIndex = new HashMap<>();
        Map<String, TransactionData> transactionMap = new LinkedHashMap<>();

        // Read the header line
        String headerLine = reader.readLine();
        if (headerLine == null) {
            reader.close();
            throw new IOException("Empty input file");
        }

        String[] headers = headerLine.split(",");
        for (int i = 0; i < headers.length; i++) {
            headerIndex.put(headers[i].trim().toLowerCase(), i);
        }

        // Read and process each data row
        String line;
        while ((line = reader.readLine()) != null) {
            String[] tokens = line.split(",", -1); // -1 to preserve empty fields

            if (!"y".equalsIgnoreCase(tokens[headerIndex.get("primarycoupan")])) continue;

            // Build a unique key for the transaction
            String transactionKey = tokens[headerIndex.get("ticket")] + "|" +
                                    tokens[headerIndex.get("shortname")] + "|" +
                                    tokens[headerIndex.get("redcode")] + "|" +
                                    tokens[headerIndex.get("tier")] + "|" +
                                    tokens[headerIndex.get("currency")] + "|" +
                                    tokens[headerIndex.get("docclause")] + "|" +
                                    tokens[headerIndex.get("recovery")] + "|" +
                                    tokens[headerIndex.get("compositecurverating")] + "|" +
                                    tokens[headerIndex.get("sector")] + "|" +
                                    tokens[headerIndex.get("region")] + "|" +
                                    tokens[headerIndex.get("country")] + "|" +
                                    tokens[headerIndex.get("avrating")] + "|" +
                                    tokens[headerIndex.get("impliedrating")];

            TransactionData txn = transactionMap.computeIfAbsent(transactionKey, k -> new TransactionData());

            // Populate fixed values
            for (String header : headerIndex.keySet()) {
                if (!header.equals("tenor") &&
                    !header.equals("parspreadmid") &&
                    !header.equals("compositepricerating") &&
                    !header.equals("primarycoupan")) {

                    txn.allValues.putIfAbsent(header, tokens[headerIndex.get(header)]);
                }
            }

            // Handle dynamic tenor-based fields
            String tenor = tokens[headerIndex.get("tenor")].toLowerCase();
            String spread = tokens[headerIndex.get("parspreadmid")];
            String rating = tokens[headerIndex.get("compositepricerating")];

            txn.allValues.put("spread" + tenor, spread);
            txn.allValues.put("rating" + tenor, rating);
        }

        reader.close();

        // Write output file
        BufferedWriter writer = new BufferedWriter(new FileWriter(outputPath));
        writer.write("\n\n"); // Two blank lines
        writer.write(String.join(",", outputHeader));
        writer.newLine();

        for (TransactionData txn : transactionMap.values()) {
            List<String> row = new ArrayList<>();
            for (String col : outputHeader) {
                row.add(txn.allValues.getOrDefault(col.toLowerCase(), ""));
            }
            writer.write(String.join(",", row));
            writer.newLine();
        }

        writer.close();
    }

    public static void main(String[] args) throws IOException {
        // Example: You must provide all possible output columns including spread/rating columns
        List<String> outputHeader = Arrays.asList(
            "ticket", "shortname", "redcode", "tier", "currency", "docclause", "recovery",
            "compositecurverating", "sector", "region", "country", "avrating", "impliedrating",
            "spread1m", "spread6m", "spread1y", "spread3y",
            "rating1m", "rating6m", "rating1y", "rating3y",
            "customfield1", "customfield2"
        );

        String inputPath = "input.csv";
        String outputPath = "output.csv";

        processCSV(inputPath, outputPath, outputHeader);
    }
}
