Yes, we can remove the dependency on the "Done" button and automatically update the selected values whenever the user checks or unchecks a checkbox. This can be achieved by adding an `ActionListener` to each `JCheckBoxMenuItem` so that the selection is updated in real time.

Here’s the updated implementation:

---

### Updated Code Snippet:

```java
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

            // Add an ActionListener to each checkbox to update the selection in real time
            checkBoxMenuItem.addActionListener(new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent e) {
                    updateSelectedBanks();
                }
            });
        }

        // Add action listener to the button
        selectBanksButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // Show the popup menu below the button
                popupMenu.show(selectBanksButton, 0, selectBanksButton.getHeight());
            }
        });

        // Add components to the frame
        add(selectBanksButton);
        add(resultLabel);
    }

    // Method to update the selected banks in real time
    private void updateSelectedBanks() {
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

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            BankSelectionUI ui = new BankSelectionUI();
            ui.setVisible(true);
        });
    }
}
```

---

### Key Changes:
1. **Real-Time Updates**:
   - Each `JCheckBoxMenuItem` has an `ActionListener` attached to it.
   - Whenever a checkbox is checked or unchecked, the `updateSelectedBanks()` method is called to update the selected banks in real time.

2. **No "Done" Button**:
   - The dependency on the "Done" button is removed.
   - The selected banks are automatically displayed as soon as the user interacts with the checkboxes.

---

### How It Works:
1. When the user clicks the **"Select Banks" button**, a popup menu appears with a list of banks and checkboxes.
2. The user can select one or more banks by checking the checkboxes.
3. As soon as a checkbox is checked or unchecked, the `resultLabel` is updated to show the selected banks in a comma-separated format.

---

### Example Output:
- **UI**: A button labeled "Select Banks" and a label below it.
- **Popup Menu**: A list of banks with checkboxes.
- **Result**: As soon as the user checks or unchecks a checkbox, the label updates to show the selected banks, e.g., `Selected Banks: Bank of America, Chase`.

---

### Advantages:
- No need for a "Done" button; the selection is updated in real time.
- Simple and intuitive user interaction.

Let me know if you need further assistance! 😊
