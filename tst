import java.io.*;
import java.util.*;

public class CSVProcessor {
    
    public static void main(String[] args) {
        String inputFile = "input.csv";  // Input file path
        String outputFile = "output.csv";  // Output file path
        
        try (
            BufferedReader reader = new BufferedReader(new FileReader(inputFile));
            BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile))
        ) {
            // Reading the headers
            String headerLine = reader.readLine(); // 1st line has the header of input file
            String[] headers = headerLine.split(",", -1);
            
            // Create a map to store the indices of the headers for easy access
            Map<String, Integer> headerIndex = new LinkedHashMap<>();
            for (int i = 0; i < headers.length; i++) {
                headerIndex.put(headers[i].trim().toLowerCase(), i);
            }
            
            // Output headers (fixed + dynamic fields)
            List<String> outputHeaders = Arrays.asList(
                "ticket", "shortname", "redcode", "tier", "currency", "docclause", "recovery", "compositecurverating",
                "sector", "region", "country", "avrating", "impliedrating",
                "spread1M", "spread6M", "spread1Y", "spread3Y", // Example tenors
                "rating1M", "rating6M", "rating1Y", "rating3Y",  // Example tenors
                "extraField1", "extraField2"  // Extra fields
            );
            
            // Write the output headers to the file
            writer.write(String.join(",", outputHeaders));
            writer.newLine();
            writer.write("Transaction Data Starts from the 3rd Row.");
            writer.newLine();
            
            // Variables for processing transactions
            String currentKey = "";
            Map<String, String> currentTransaction = new HashMap<>();
            
            String line;
            while ((line = reader.readLine()) != null) {
                String[] fields = line.split(",", -1);
                
                // Skip if primaryCoupan is not 'Y'
                String couponFlag = fields[headerIndex.get("primarycoupan")];
                if (!"Y".equalsIgnoreCase(couponFlag)) {
                    continue;
                }
                
                // Generate transaction key using all common fields
                String ticket = fields[headerIndex.get("ticket")];
                String shortName = fields[headerIndex.get("shortname")];
                String redcode = fields[headerIndex.get("redcode")];
                String tier = fields[headerIndex.get("tier")];
                String currency = fields[headerIndex.get("currency")];
                String docclause = fields[headerIndex.get("docclause")];
                String recovery = fields[headerIndex.get("recovery")];
                String compositeCurverating = fields[headerIndex.get("compositecurverating")];
                String sector = fields[headerIndex.get("sector")];
                String region = fields[headerIndex.get("region")];
                String country = fields[headerIndex.get("country")];
                String avrating = fields[headerIndex.get("avrating")];
                String impliedrating = fields[headerIndex.get("impliedrating")];
                
                // Use all 13 common fields to form the transaction key
                String key = String.join("|", ticket, shortName, redcode, tier, currency, docclause, recovery,
                        compositeCurverating, sector, region, country, avrating, impliedrating);
                
                // If the key changes, write the current transaction and reset for new one
                if (!key.equals(currentKey)) {
                    if (currentTransaction != null && !currentTransaction.isEmpty()) {
                        writeTransactionRow(writer, outputHeaders, currentTransaction);
                    }
                    // Reset for new transaction
                    currentTransaction = new HashMap<>();
                    currentKey = key;
                    
                    // Populate common fields
                    currentTransaction.put("ticket", ticket);
                    currentTransaction.put("shortname", shortName);
                    currentTransaction.put("redcode", redcode);
                    currentTransaction.put("tier", tier);
                    currentTransaction.put("currency", currency);
                    currentTransaction.put("docclause", docclause);
                    currentTransaction.put("recovery", recovery);
                    currentTransaction.put("compositecurverating", compositeCurverating);
                    currentTransaction.put("sector", sector);
                    currentTransaction.put("region", region);
                    currentTransaction.put("country", country);
                    currentTransaction.put("avrating", avrating);
                    currentTransaction.put("impliedrating", impliedrating);
                    
                    // Extra fields (can be dynamic or hardcoded)
                    currentTransaction.put("extraField1", "");  // Blank for now, modify as needed
                    currentTransaction.put("extraField2", "");  // Blank for now, modify as needed
                }
                
                // Handle tenor-based fields (spread and rating)
                String tenor = fields[headerIndex.get("tenor")].toUpperCase();  // e.g., 1M, 6M, 1Y
                String parSpreadMid = fields[headerIndex.get("parspreadmid")];
                String compositePriceRating = fields[headerIndex.get("compositepricerating")];
                
                // Add the corresponding spread and rating based on tenor
                if (tenor.equals("1M")) {
                    currentTransaction.put("spread1M", parSpreadMid);
                    currentTransaction.put("rating1M", compositePriceRating);
                } else if (tenor.equals("6M")) {
                    currentTransaction.put("spread6M", parSpreadMid);
                    currentTransaction.put("rating6M", compositePriceRating);
                } else if (tenor.equals("1Y")) {
                    currentTransaction.put("spread1Y", parSpreadMid);
                    currentTransaction.put("rating1Y", compositePriceRating);
                } else if (tenor.equals("3Y")) {
                    currentTransaction.put("spread3Y", parSpreadMid);
                    currentTransaction.put("rating3Y", compositePriceRating);
                }
            }
            
            // Flush the last transaction if any
            if (currentTransaction != null && !currentTransaction.isEmpty()) {
                writeTransactionRow(writer, outputHeaders, currentTransaction);
            }
            
            System.out.println("Processing complete. Output written to: " + outputFile);
            
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Method to write the current transaction as a row in the output file
    private static void writeTransactionRow(BufferedWriter writer, List<String> headers, Map<String, String> data) throws IOException {
        List<String> row = new ArrayList<>();
        for (String col : headers) {
            row.add(data.getOrDefault(col, ""));
        }
        writer.write(String.join(",", row));
        writer.newLine();
    }
}
