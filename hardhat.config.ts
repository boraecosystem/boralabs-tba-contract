import conf from "./config/config";
import { HardhatUserConfig } from "hardhat/config";
const config: HardhatUserConfig = {
  ...conf,
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
};
export default config
