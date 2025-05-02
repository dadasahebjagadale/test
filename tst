Absolutely! Here's an enhanced version of the parser that processes a list of log files (not just one), applying the same logic to each file and collecting all the JavaCommand objects into a single list.


---

Updated Method to Handle Multiple Files

import java.io.*;
import java.nio.file.*;
import java.time.LocalDate;
import java.util.*;
import java.util.regex.*;

public class MultiFileLogParser {

    private static final Pattern JAVA_LINE_PATTERN = Pattern.compile("java\\s+((?:-D[^\\s]+\\s+)*).*?\\s+([\\w\\.]+)\\s*(.*)");
    private static final Pattern SUCCESS_PATTERN = Pattern.compile("\"quote found.*?(\\d{4}-\\d{2}-\\d{2})");
    private static final Pattern FAILURE_PATTERN = Pattern.compile("could not retrieve quote.*?(\\d{4}-\\d{2}-\\d{2})");

    public static List<JavaCommand> parseMultipleLogFiles(List<String> filePaths) throws IOException {
        List<JavaCommand> allCommands = new ArrayList<>();

        for (String path : filePaths) {
            List<JavaCommand> commandsFromFile = parseSingleLogFile(path);
            allCommands.addAll(commandsFromFile);
        }

        return allCommands;
    }

    private static List<JavaCommand> parseSingleLogFile(String filePath) throws IOException {
        List<JavaCommand> commands = new ArrayList<>();
        JavaCommand currentCommand = null;
        String currentLatestResponse = null;
        LocalDate currentLatestDate = null;

        try (BufferedReader reader = Files.newBufferedReader(Paths.get(filePath))) {
            String line;

            while ((line = reader.readLine()) != null) {
                Matcher javaMatcher = JAVA_LINE_PATTERN.matcher(line);

                if (javaMatcher.find()) {
                    if (currentCommand != null) {
                        currentCommand.setLatestResponse(currentLatestResponse);
                        commands.add(currentCommand);
                    }

                    // Start new command
                    String dParams = javaMatcher.group(1).trim();
                    String mainClass = javaMatcher.group(2).trim();
                    String argsPart = javaMatcher.group(3).trim();

                    Map<String, String> systemProperties = new HashMap<>();
                    for (String token : dParams.split("\\s+")) {
                        if (token.startsWith("-D")) {
                            String[] keyValue = token.substring(2).split("=", 2);
                            if (keyValue.length == 2) {
                                systemProperties.put(keyValue[0], keyValue[1]);
                            }
                        }
                    }

                    List<String> args = argsPart.isEmpty() ? new ArrayList<>() : Arrays.asList(argsPart.split("\\s+"));

                    currentCommand = new JavaCommand();
                    currentCommand.setMainClass(mainClass);
                    currentCommand.setArgs(args);
                    currentCommand.setSystemProperties(systemProperties);

                    currentLatestDate = null;
                    currentLatestResponse = null;

                } else if (currentCommand != null) {
                    Matcher successMatcher = SUCCESS_PATTERN.matcher(line);
                    Matcher failureMatcher = FAILURE_PATTERN.matcher(line);
                    LocalDate date = null;

                    if (successMatcher.find()) {
                        date = LocalDate.parse(successMatcher.group(1));
                        if (currentLatestDate == null || date.isAfter(currentLatestDate)) {
                            currentLatestDate = date;
                            currentLatestResponse = line;
                        }
                    } else if (failureMatcher.find()) {
                        date = LocalDate.parse(failureMatcher.group(1));
                        if (currentLatestDate == null || date.isAfter(currentLatestDate)) {
                            currentLatestDate = date;
                            currentLatestResponse = line;
                        }
                    }
                }
            }
        }

        if (currentCommand != null) {
            currentCommand.setLatestResponse(currentLatestResponse);
            commands.add(currentCommand);
        }

        return commands;
    }
}


---

Usage Example

public class Main {
    public static void main(String[] args) throws IOException {
        List<String> files = List.of("log1.txt", "log2.txt", "log3.txt");
        List<JavaCommand> allCommands = MultiFileLogParser.parseMultipleLogFiles(files);

        for (JavaCommand command : allCommands) {
            System.out.println("Main Class: " + command.getMainClass());
            System.out.println("System Properties: " + command.getSystemProperties());
            System.out.println("Args: " + command.getArgs());
            System.out.println("Latest Response: " + command.getLatestResponse());
            System.out.println("------------");
        }
    }
}

Would you like this packaged into a Maven or Gradle project structure?





public class JavaCommand {
    private String mainClass;
    private List<String> args;
    private Map<String, String> systemProperties;
    private String latestResponse; // The latest success/failure line

    // Getters and Setters
}
