import java.io.*;
import java.util.*;

public class TransactionCsvProcessor {

    public static void main(String[] args) throws IOException {
        File inputFile = new File("input.csv");
        File outputFile = new File("output.csv");

        Map<String, File> txnFiles = new HashMap<>();
        Set<String> tenors = new TreeSet<>(); // Sorted order

        // First Pass: Split into temp files & collect tenors
        try (BufferedReader reader = new BufferedReader(new FileReader(inputFile))) {
            String header = reader.readLine(); // Skip header
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",", -1);
                String txnKey = parts[0] + "|" + parts[1] + "|" + parts[2]; // txnid|currency|docclause
                String tenor = parts[3].trim();

                tenors.add(tenor);

                File tempFile = txnFiles.computeIfAbsent(txnKey, k -> {
                    try {
                        return File.createTempFile("txn_" + k.replace("|", "_"), ".tmp");
                    } catch (IOException e) {
                        throw new UncheckedIOException(e);
                    }
                });

                try (BufferedWriter writer = new BufferedWriter(new FileWriter(tempFile, true))) {
                    writer.write(line);
                    writer.newLine();
                }
            }
        }

        // Second Pass: Write output
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile))) {
            // Write header
            writer.write("txnid,currency,docclause");
            for (String tenor : tenors) {
                writer.write(",tq_" + tenor + ",pq_" + tenor);
            }
            writer.newLine();

            // Process each temp file
            for (Map.Entry<String, File> entry : txnFiles.entrySet()) {
                String txnKey = entry.getKey();
                File file = entry.getValue();

                Map<String, String[]> tenorMap = new HashMap<>();

                try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        String[] parts = line.split(",", -1);
                        String tenor = parts[3].trim();
                        String tq = parts[4].trim();
                        String pq = parts[5].trim();
                        tenorMap.put(tenor, new String[]{tq, pq});
                    }
                }

                // Write output line
                String[] txnParts = txnKey.split("\\|");
                writer.write(String.join(",", txnParts)); // txnid, currency, docclause

                for (String tenor : tenors) {
                    String[] values = tenorMap.getOrDefault(tenor, new String[]{"", ""});
                    writer.write("," + values[0] + "," + values[1]);
                }
                writer.newLine();

                file.delete(); // Clean up temp file
            }
        }

        System.out.println("Done! Output written to: " + outputFile.getAbsolutePath());
    }
}
