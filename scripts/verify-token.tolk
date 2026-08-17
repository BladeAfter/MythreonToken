import "@stdlib/strings"
import "@acton/io"
import "utils/common"
import "../contracts/storage"
import "../wrappers/JettonMinter.gen"

fun main() {
    assertTestnetOnly();
    val minter = promptJettonMinter("Enter MYTH Jetton Master address");
    val data = minter.getJettonData();
    val metadata = OnchainMetadataReply.fromCell(data.jettonContent);
    val name = readOnchainMetadataField(metadata, "name".sha256());
    val symbol = readOnchainMetadataField(metadata, "symbol".sha256());
    val decimals = readOnchainMetadataField(metadata, "decimals".sha256());
    val description = readOnchainMetadataField(metadata, "description".sha256());
    val valid = name != null && name.equalTo(JETTON_DEFAULT_NAME) && symbol != null &&
    symbol.equalTo(JETTON_DEFAULT_SYMBOL) &&
    decimals != null &&
    decimals.equalTo(JETTON_DEFAULT_DECIMALS) &&
    description != null &&
    description.equalTo(JETTON_DEFAULT_DESCRIPTION);
    println("Token: {}", name);
    println("Symbol: {}", symbol);
    println("Decimals: {}", decimals);
    println("Total Supply: {}", data.totalSupply);
    println("Mintable: {}", data.mintable);
    println("Admin: {}", data.adminAddress);
    println("Jetton Master: {}", minter.address);
    println("Network: TESTNET");
    println("Metadata: {}", valid ? "OK" : "INVALID");
}
