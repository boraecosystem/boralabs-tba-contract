import {DeployResult} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";
import {network} from "hardhat";
import readlineSync from "readline-sync";

async function hreDeploy(
    name: string,
    contract: string,
    hre: HardhatRuntimeEnvironment,
    logEnable: boolean,
    waitConfirmations: number | undefined,
    ...args: any[]
): Promise<DeployResult> {
    const {
        deployments: {deploy},
        getNamedAccounts,
    } = hre;
    const {deployer} = await getNamedAccounts();

    return await deploy(name, {
        contract,
        from: deployer,
        args,
        log: logEnable,
    });
}

async function deployAndLog(name: string, contract: string, hre: HardhatRuntimeEnvironment, ...args: any[]): Promise<DeployResult | undefined> {
    const {
        deployments: {log},
        getNamedAccounts,
    } = hre;
    const {deployer} = await getNamedAccounts();

    log(`\n[${name}]`);
    log(`  arguments: ${args}`);
    log(`  deployer: ${deployer}`);

    if (!readlineSync.keyInYN("Proceed?")) {
        log("cancelled");
        return;
    }

    try {
        const deployResult = await hreDeploy(name, contract, hre, false, getBlockConfirmations(), ...args);

        log(`  deploy: ${deployResult.newlyDeployed ? "new" : "reused"}`);
        log(`  status: ${deployResult.receipt?.status ? "OK" : "FAIL"}`);
        log(`  contractAddress: ${deployResult.receipt?.contractAddress}`);
        log(`  transactionHash: ${deployResult.receipt?.transactionHash}`);
        log(`  block: ${deployResult.receipt?.blockNumber}`);
        log(`  deployer: ${deployResult.receipt?.from}`);
        log(`  gas: ${deployResult.receipt?.gasUsed}`);
        log(`  bytecode: ${(deployResult.deployedBytecode?.length || 0) / 2} bytes\n`);

        return deployResult;
    } catch (err) {
        log("\nerror raised:");
        console.dir(err, {depth: 5});
    }
}

const developmentChains = ["hardhat", "local"];
const VERIFICATION_BLOCK_CONFIRMATIONS = 6;

function getBlockConfirmations(): number {
    return developmentChains.includes(network.name) ? 1 : VERIFICATION_BLOCK_CONFIRMATIONS;
}

export {hreDeploy, deployAndLog, getBlockConfirmations};
