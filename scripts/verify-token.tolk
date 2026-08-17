import "@acton/env"
import "utils/common"

fun main() {
    assertTestnetOnly();
    val minter = promptJettonMinter("Enter MYTH Jetton Master address");
    val data = minter.getJettonData();
    val metadata = OnchainMetadataReply.fromCell(data.jettonContent);
    val name = readOnchainMetadataField(metadata, "name".sha256());
    val symbol = readOnchainMetadataField(metadata, "symbol".sha256());
    val decimals = readOnchainMetadataField(metadata, "decimals".sha256());
    val description = readOnchainMetadataField(metadata, "description".sha256());
    val valid = name == JETTON_DEFAULT_NAME &&
        symbol == JETTON_DEFAULT_SYMBOL &&
        decimals == JETTON_DEFAULT_DECIMALS &&
        description == JETTON_DEFAULT_DESCRIPTION;
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
