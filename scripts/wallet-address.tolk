import "@acton/io"
import "utils/common"
import "../wrappers/JettonMinter.gen"

fun main() {
    assertTestnetOnly();
    val minter = promptJettonMinter("Enter MYTH Jetton Master address");
    val owner = promptJettonAddressRequired("JETTON_OWNER_ADDRESS", "Enter TON owner address");
    val wallet = minter.getWalletAddress(owner);
    println("NETWORK=TESTNET");
    println("JETTON_MASTER={}", minter.address);
    println("TON_OWNER_ADDRESS={}", owner);
    println("MYTH_JETTON_WALLET_ADDRESS={}", wallet);
    println("DERIVATION_SOURCE=get_wallet_address");
}
