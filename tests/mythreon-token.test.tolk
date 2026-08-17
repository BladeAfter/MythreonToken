import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "test-utils"
import "../contracts/errors"
import "../contracts/messages"
import "../wrappers/JettonMinter.gen"
import "../wrappers/JettonWallet.gen"
import "../wrappers/utils"

const ONE_MYTH = 1000000000
const TENTH_MYTH = 100000000
const THOUSANDTH_MYTH = 1000000
const PLANNED_MYTH_SUPPLY = 100000000000000000

get fun `test MYTH decimals use exact 9-decimal base units`() {
    expect(ton("1")).toEqual(ONE_MYTH);
    expect(ton("0.1")).toEqual(TENTH_MYTH);
    expect(ton("0.001")).toEqual(THOUSANDTH_MYTH);
    expect(100000000 * ONE_MYTH).toEqual(PLANNED_MYTH_SUPPLY);
}

get fun `test MYTH transfer moves exactly 10 tokens and emits notification`() {
    val (minter, walletAOwner, walletBOwner) = setupTest();
    val walletA = mintTo(minter, walletAOwner, walletAOwner.address, ton("100"));
    val walletB = userWallet(minter, walletBOwner.address);

    val result = walletA.sendTransferPayloadInline(
        walletAOwner.address,
        ton("0.08"),
        ton("10"),
        walletBOwner.address,
        walletAOwner.address,
        null,
        1,
        createEmptySlice(),
    );

    expect(result).toHaveSuccessfulTx<AskToTransfer>({
        from: walletAOwner.address,
        to: walletA.address,
    });
    expect(result).toHaveTx<TransferNotificationForRecipient>({
        from: walletB.address,
        to: walletBOwner.address,
        value: 1,
    });
    expect(walletA.getJettonBalance()).toEqual(ton("90"));
    expect(walletB.getJettonBalance()).toEqual(ton("10"));
}

get fun `test MYTH burn reduces holder and total supply by exactly 10 tokens`() {
    val (minter, holder, _) = setupTest();
    val wallet = mintTo(minter, holder, holder.address, ton("100"));

    val result = wallet.sendBurn(holder.address, ton("0.08"), ton("10"), holder.address, null);

    expect(result).toHaveSuccessfulTx<AskToBurn>({ from: holder.address, to: wallet.address });
    expect(result).toHaveSuccessfulTx<BurnNotificationForMinter>({
        from: wallet.address,
        to: minter.address,
    });
    expect(wallet.getJettonBalance()).toEqual(ton("90"));
    expect(minter.getTotalSupply()).toEqual(ton("90"));
}

get fun `test MYTH wallet derivation agrees with deployed recipient wallet`() {
    val (minter, admin, recipient) = setupTest();
    val derived = minter.getWalletAddress(recipient.address);
    val wallet = mintTo(minter, admin, recipient.address, ton("1"));
    val walletData = wallet.getWalletData();
    expect(wallet.address).toEqual(derived);
    expect(walletData.minterAddress).toEqual(minter.address);
    expect(walletData.ownerAddress).toEqual(recipient.address);
}

get fun `test MYTH admin B gains authority and former admin A loses it after claim`() {
    val (minter, adminA, adminB) = setupTest();
    minter.sendChangeAdmin(adminA.address, adminB.address);
    minter.sendClaimAdmin(adminB.address);

    val rejected = minter.sendMint(
        adminA.address,
        adminA.address,
        ton("1"),
        ton("0.05"),
        ton("0.3"),
    );
    expect(rejected).toHaveFailedTx<MintNewJettons>({
        from: adminA.address,
        to: minter.address,
        exitCode: ERROR_NOT_OWNER,
    });

    val accepted = minter.sendMint(
        adminB.address,
        adminB.address,
        ton("1"),
        ton("0.05"),
        ton("0.3"),
    );
    expect(accepted).toHaveSuccessfulTx<MintNewJettons>({
        from: adminB.address,
        to: minter.address,
    });
    expect(userWallet(minter, adminB.address).getJettonBalance()).toEqual(ton("1"));
}
