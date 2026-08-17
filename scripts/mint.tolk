import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "utils/common"
import "../wrappers/utils"

fun main() {
    assertTestnetOnly();
    val admin = promptJettonWallet("JETTON_ADMIN", "Select Jetton Admin ActonWallet");
    val minter = promptJettonMinter("Enter Jetton Minter address");
    val recipient = promptJettonAddress(
        "JETTON_MINT_RECIPIENT",
        "Enter mint recipient",
        admin.address,
    );
    val mintAmount = promptJettonCoins(
        "JETTON_MINT_AMOUNT",
        "Enter mint amount",
        JETTON_DEFAULT_MINT_AMOUNT,
    );

    println("NETWORK=TESTNET");
    println("TOKEN=Mythreon Token (MYTH)");
    println("ADMIN={}", admin.address);
    println("RECIPIENT={}", recipient);
    println("MINT_BASE_UNITS={}", mintAmount);
    println("ESTIMATED_TON_REQUIRED=~0.08 TON");
    if (!confirm("Mint MYTH on TESTNET?", false, "Explicit confirmation is required")) {
        return;
    }

    val res = minter.sendMint(admin.address, recipient, mintAmount, 1, ton("0.08"));
    res.waitForFirstTransaction();

    println("TRANSACTION_STATUS=CONFIRMED");

    printJettonMinterInfo(minter, "JETTON");
    printJettonWalletInfo(minter, recipient, "JETTON_RECIPIENT");
}
