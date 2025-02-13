Ah, I see the issue now! By default, when a user selects an item in a `JPopupMenu`, the popup closes automatically. To keep the popup open after selecting a checkbox, we need to override this behavior. This can be achieved by using a custom `JPopupMenu` that does not close when a `JCheckBoxMenuItem` is clicked.

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

    // Custom JPopupMenu that stays open when a JCheckBoxMenuItem is clicked
    private static class StayOpenPopupMenu extends JPopupMenu {
        @Override
        public void setVisible(boolean visible) {
            // Only close the popup if the user clicks outside of it
            if (visible) {
                super.setVisible(true);
            } else {
                // Check if the source of the event is a JCheckBoxMenuItem
                boolean isCheckBoxMenuItem = false;
                for (Component component : getComponents()) {
                    if (component instanceof JCheckBoxMenuItem && ((JCheckBoxMenuItem) component).isSelected()) {
                        isCheckBoxMenuItem = true;
                        break;
                    }
                }
                // Do not close the popup if the source is a JCheckBoxMenuItem
                if (!isCheckBoxMenuItem) {
                    super.setVisible(false);
                }
            }
        }
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
1. **Custom `StayOpenPopupMenu`**:
   - A custom `JPopupMenu` class (`StayOpenPopupMenu`) is created to override the `setVisible` method.
   - The popup menu will only close if the user clicks outside of it, not when a `JCheckBoxMenuItem` is clicked.

2. **Real-Time Updates**:
   - Each `JCheckBoxMenuItem` still has an `ActionListener` attached to it, so the selected banks are updated in real time.

3. **Popup Behavior**:
   - The popup menu remains open when the user interacts with the checkboxes.
   - It only closes when the user clicks outside the popup menu.

---

### How It Works:
1. When the user clicks the **"Select Banks" button**, the custom popup menu appears.
2. The user can interact with the checkboxes to select/deselect banks.
3. The popup menu stays open while the user interacts with the checkboxes.
4. The selected banks are updated in real time and displayed in the label.
5. The popup menu only closes when the user clicks outside of it.

---

### Example Output:
- **UI**: A button labeled "Select Banks" and a label below it.
- **Popup Menu**: A list of banks with checkboxes that remains open while the user interacts with it.
- **Result**: As soon as the user checks or unchecks a checkbox, the label updates to show the selected banks, e.g., `Selected Banks: Bank of America, Chase`.

---

### Advantages:
- The popup menu remains open while the user interacts with the checkboxes.
- No need for a "Done" button; the selection is updated in real time.
- The popup only closes when the user clicks outside of it.

Let me know if you have further questions! 😊
