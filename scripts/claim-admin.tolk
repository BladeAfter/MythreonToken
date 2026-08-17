import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/prompts"
import "utils/common"
import "../wrappers/utils"

fun main() {
    assertTestnetOnly();
    val claimer = promptJettonWallet("JETTON_PENDING_ADMIN", "Select Pending Admin ActonWallet");
    val minter = promptJettonMinter("Enter Jetton Minter address");

    if (!confirm("Claim MYTH admin on TESTNET?", false, "This changes active admin authority")) {
        return;
    }

    val res = minter.sendClaimAdmin(claimer.address);
    res.waitForFirstTransaction();

    println("JETTON CLAIM_SENDER={}", claimer.address);
    printJettonMinterInfo(minter, "JETTON");
}
