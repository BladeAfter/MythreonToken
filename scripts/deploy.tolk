import "@acton/emulation/scripts"
import "@acton/io"
import "@acton/prompts"
import "utils/common"

fun main() {
    assertTestnetOnly();
    val deployer = promptJettonWallet("JETTON_DEPLOYER", "Select Jetton Deployer");
    val admin = promptJettonAddress(
        "JETTON_ADMIN_ADDRESS",
        "Enter admin address",
        deployer.address,
    );
    val storage = promptJettonMinterStorage(admin);

    println("Network: TESTNET");
    println("Token Name: {}", JETTON_DEFAULT_NAME);
    println("Symbol: {}", JETTON_DEFAULT_SYMBOL);
    println("Decimals: {}", JETTON_DEFAULT_DECIMALS);
    println("Admin Wallet: {}", admin);
    println("Initial Mint: {} base units", storage.totalSupply);
    println("Estimated TON required: ~0.05 TON");
    if (!confirm("Deploy MYTH to TESTNET?", false, "Explicit confirmation is required")) {
        return;
    }

    val minter = deployJettonMinter(deployer, storage);

    println("JETTON MASTER ADDRESS={}", minter.address);
    printJettonMinterInfo(minter, "JETTON");
    printJettonWalletInfo(minter, admin, "JETTON_ADMIN");
}
