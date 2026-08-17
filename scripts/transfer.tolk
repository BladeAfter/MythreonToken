import "@acton/io"
import "@acton/prompts"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "utils/common"
import "../wrappers/JettonMinter.gen"
import "../wrappers/JettonWallet.gen"
import "../wrappers/utils"

fun main() {
    assertTestnetOnly();
    val sender = promptJettonWallet("JETTON_SENDER", "Select Jetton Sender ActonWallet");
    val minter = promptJettonMinter("Enter Jetton Minter address");
    val recipient = promptJettonAddressRequired(
        "JETTON_TRANSFER_RECIPIENT",
        "Enter transfer recipient",
    );
    val transferAmount = promptJettonCoins(
        "JETTON_TRANSFER_AMOUNT",
        "Enter transfer amount",
        JETTON_DEFAULT_TRANSFER_AMOUNT,
    );

    println("NETWORK=TESTNET");
    println("SENDER={}", sender.address);
    println("RECIPIENT={}", recipient);
    println("TRANSFER_BASE_UNITS={}", transferAmount);
    if (!confirm("Transfer MYTH on TESTNET?", false, "Explicit confirmation is required")) {
        return;
    }

    val senderWallet = JettonWallet { address: minter.getWalletAddress(sender.address) };
    val res = senderWallet.sendTransferPayloadInline(
        sender.address,
        ton("0.08"),
        transferAmount,
        recipient,
        sender.address,
        null,
        1,
        createEmptySlice(),
    );
    res.waitForFirstTransaction();

    println("TRANSACTION_STATUS=CONFIRMED");

    printJettonMinterInfo(minter, "JETTON");
    printJettonWalletInfo(minter, sender.address, "JETTON_SENDER");
    printJettonWalletInfo(minter, recipient, "JETTON_RECIPIENT");
}
