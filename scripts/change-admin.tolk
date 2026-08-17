import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/prompts"
import "utils/common"
import "../wrappers/utils"

fun main() {
    assertTestnetOnly();
    val admin = promptJettonWallet("JETTON_ADMIN", "Select Current Admin ActonWallet");
    val minter = promptJettonMinter("Enter Jetton Minter address");
    val nextAdmin = promptJettonAddress(
        "JETTON_NEXT_ADMIN",
        "Enter next admin address",
        admin.address,
    );

    if (!confirm("Start two-step MYTH admin change on TESTNET?", false, "New admin must claim separately")) {
        return;
    }

    val res = minter.sendChangeAdmin(admin.address, nextAdmin);
    res.waitForFirstTransaction();

    println("JETTON NEXT_ADMIN_REQUESTED={}", nextAdmin);
    printJettonMinterInfo(minter, "JETTON");
}
