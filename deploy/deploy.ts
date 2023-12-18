import {HardhatRuntimeEnvironment} from "hardhat/types";
import {DeployFunction} from "hardhat-deploy/types";
import {deployAndLog} from "../config/deploy";
import * as fs from 'fs';
import * as path from 'path';


/**
 * @shell yarn hardhat deploy --network ganache_network --tags TBA   
 */
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

    const TBA_avocado = await deployAndLog("BoralabsTBA20_Avocado", "BoralabsTBA20", hre, "BoralabsTBA20", "BoralabsTBA20_Avocado");
    const TBA_721 = await deployAndLog("BoralabsTBA721","BoralabsTBA721", hre,  "BASE_PLAYER", "BPLY");
    const TBA_1155 = await deployAndLog("BoralabsTBA1155", "BoralabsTBA1155", hre);
    const TBA_6551Account = await deployAndLog("BoralabsTBA6551Account", "BoralabsTBA6551Account", hre);
    const TBA_6551Registry = await deployAndLog("BoralabsTBA6551Registry", "BoralabsTBA6551Registry", hre);
    
    const currentScriptPath = __filename;
    const repository = path.dirname(path.dirname(currentScriptPath));

    var updatedEnvFileContent = ""
    updatedEnvFileContent = 
`# Dev chain info
VITE_BORACHAIN_CHAIN_ID=1337
VITE_BORACHAIN_CHAIN_NAME=Ganache Testnet
VITE_BORACHAIN_RPC_URL=http://127.0.0.1:7545
VITE_BORACHAIN_EXPLORER_URL=https://www.boralabs.com/
VITE_BORALABS_MAINPAGE_URL=https://www.boralabs.com/
VITE_BORAPORTAL_MAIN_URL=https://www.boraportal.com
#Contracts
VITE_BORALABS_TKN_CONTRACT=${TBA_avocado?.address}
VITE_BORALABS_NFT_CONTRACT=${TBA_721?.address}
VITE_BORALABS_MTS_CONTRACT=${TBA_1155?.address}
VITE_BORALABS_TACC_CONTRACT=${TBA_6551Account?.address}
VITE_BORALABS_TREG_CONTRACT=${TBA_6551Registry?.address}`
    fs.writeFileSync(repository+'/.env.export',updatedEnvFileContent
)
};

func.tags = ["TBA", "TBA"];
export default func;


