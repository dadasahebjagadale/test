import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;

public class BankSelectionUI extends JFrame {

    private JButton selectBanksButton;
    private JLabel resultLabel;
    private JPopupMenu popupMenu;

    private List<String> banks = List.of("Bank of America", "Chase", "Wells Fargo", "Citibank", "HSBC");

    public BankSelectionUI() {
        setTitle("Bank Selection");
        setSize(400, 200);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new FlowLayout());

        // Initialize components
        selectBanksButton = new JButton("Select Banks");
        resultLabel = new JLabel("Selected Banks: ");
        popupMenu = new JPopupMenu();

        // Add checkboxes to the popup menu
        for (String bank : banks) {
            JCheckBoxMenuItem checkBoxMenuItem = new JCheckBoxMenuItem(bank);
            popupMenu.add(checkBoxMenuItem);
        }

        // Add action listener to the button
        selectBanksButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // Show the popup menu below the button
                popupMenu.show(selectBanksButton, 0, selectBanksButton.getHeight());
            }
        });

        // Add a "Done" button to the popup menu to confirm selection
        JMenuItem doneMenuItem = new JMenuItem("Done");
        doneMenuItem.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                List<String> selectedBanks = new ArrayList<>();
                for (Component component : popupMenu.getComponents()) {
                    if (component instanceof JCheckBoxMenuItem) {
                        JCheckBoxMenuItem checkBoxMenuItem = (JCheckBoxMenuItem) component;
                        if (checkBoxMenuItem.isSelected()) {
                            selectedBanks.add(checkBoxMenuItem.getText());
                        }
                    }
                }
                resultLabel.setText("Selected Banks: " + String.join(", ", selectedBanks));
            }
        });
        popupMenu.addSeparator(); // Add a separator before the "Done" button
        popupMenu.add(doneMenuItem);

        // Add components to the frame
        add(selectBanksButton);
        add(resultLabel);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            BankSelectionUI ui = new BankSelectionUI();
            ui.setVisible(true);
        });
    }
}
