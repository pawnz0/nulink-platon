async function main() {

    const constructorArgs = ["0x9795221c5729633EF7cb44De4D82a8B00Cd36e47", "0x8BFD03ecf1F96EE0E16da36B3eb5fa5723f6E10e", 0 , 8000000]
    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Staking = await ethers.getContractFactory("Staking");
    const staking = await Staking.deploy(...constructorArgs);
    // staking.constructor()

    console.log("Staking address:", staking.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
