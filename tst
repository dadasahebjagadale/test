import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;

public class BankSelectionUI extends JFrame {

    private JComboBox<JCheckBox> bankComboBox;
    private JButton showSelectedButton;
    private JLabel resultLabel;

    private List<String> banks = List.of("Bank of America", "Chase", "Wells Fargo", "Citibank", "HSBC");

    public BankSelectionUI() {
        setTitle("Bank Selection");
        setSize(400, 200);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new FlowLayout());

        // Initialize components
        bankComboBox = new JComboBox<>();
        showSelectedButton = new JButton("Show Selected Banks");
        resultLabel = new JLabel("Selected Banks: ");

        // Populate the combo box with checkboxes
        for (String bank : banks) {
            JCheckBox checkBox = new JCheckBox(bank);
            bankComboBox.addItem(checkBox);
        }

        // Add components to the frame
        add(new JLabel("Select Banks: "));
        add(bankComboBox);
        add(showSelectedButton);
        add(resultLabel);

        // Add action listener to the button
        showSelectedButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                List<String> selectedBanks = new ArrayList<>();
                for (int i = 0; i < bankComboBox.getItemCount(); i++) {
                    JCheckBox checkBox = bankComboBox.getItemAt(i);
                    if (checkBox.isSelected()) {
                        selectedBanks.add(checkBox.getText());
                    }
                }
                resultLabel.setText("Selected Banks: " + String.join(", ", selectedBanks));
            }
        });
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            BankSelectionUI ui = new BankSelectionUI();
            ui.setVisible(true);
        });
    }
}
