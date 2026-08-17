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
    val owner = promptJettonWallet("JETTON_OWNER", "Select MYTH holder wallet");
    val minter = promptJettonMinter("Enter MYTH Jetton Master address");
    val burnAmount = promptJettonCoins(
        "JETTON_BURN_AMOUNT",
        "Enter burn amount in base units",
        JETTON_DEFAULT_BURN_AMOUNT,
    );
    println("NETWORK=TESTNET");
    println("ACTION=BURN");
    println("OWNER={}", owner.address);
    println("BURN_BASE_UNITS={}", burnAmount);
    if (
        !confirm("Confirm MYTH burn on TESTNET?", false, "This reduces holder balance and supply")
    ) {
        return;
    }
    val wallet = JettonWallet { address: minter.getWalletAddress(owner.address) };
    val res = wallet.sendBurn(owner.address, ton("0.08"), burnAmount, owner.address, null);
    res.waitForFirstTransaction();
    println("TRANSACTION_STATUS=CONFIRMED");
    printJettonMinterInfo(minter, "MYTH");
    printJettonWalletInfo(minter, owner.address, "MYTH_HOLDER");
}
