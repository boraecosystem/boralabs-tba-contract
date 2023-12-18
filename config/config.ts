import {HardhatUserConfig, task, types} from "hardhat/config";
import {TASK_DEPLOY} from "hardhat-deploy";
import "hardhat-contract-sizer";

import dotenv from "dotenv";

if (!process.env.DEPLOYER_KEY || process.env.DEPLOYER_KEY === "") {
    dotenv.config({path: "./.env"});
}
if (!process.env.DEPLOYER_KEY || process.env.DEPLOYER_KEY === "") {
    dotenv.config({path: "../.env"});
}
if (!process.env.DEPLOYER_KEY || process.env.DEPLOYER_KEY === "") {
    dotenv.config({path: "../../.env"});
}
if (!process.env.DEPLOYER_KEY || process.env.DEPLOYER_KEY === "") {
    dotenv.config({path: "../../../.env"});
}

// tasks
task(TASK_DEPLOY)
    .addOptionalParam("name", "name of the contract", "", types.string)
    .addOptionalParam("args", "comma separated list of optional arguments to pass to the constructor", "", types.string)
    .setAction(async (args, hre, runSuper) => {
        return runSuper(args);
    });

// networks
const deplkey = process.env.DEPLOYER_KEY || "";
const config: HardhatUserConfig = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
            hardfork: "istanbul",
            allowUnlimitedContractSize: true,
        },
        ganache_network: {
            url: "http://127.0.0.1:7545",
            accounts: [process.env.DEPLOYER_KEY || ""],
            gas: 99999999,
          },
    },
    namedAccounts: {
        deployer: 0,
    },
    contractSizer: {
        alphaSort: true,
        runOnCompile: true,
        disambiguatePaths: true,
    },
};

export default config;
