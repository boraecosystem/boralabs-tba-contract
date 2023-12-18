// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3)

pragma solidity 0.8.19;

import "./common/BoralabsBase.sol";

// ide remix
// import "@openzeppelin/contracts@4.9.3/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts@4.9.3/security/ReentrancyGuard.sol";

// yarn
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BoralabsTBA721 is BoralabsBase, ERC721Enumerable, ReentrancyGuard {
    uint256 public availableMintNum = 1;
    uint256 public oneTimeMintNum = 3;
    uint256 public mintBand = 10000000;

    // =========================================================================================== //
    // 721
    // =========================================================================================== //
    string public contractURI = "http://localhost:3000/meta/nft/";
    string public baseURI_ = "http://localhost:3000/meta/nft/tokens/";

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
    function setContractURI(string calldata uri) external onlyOwner {
        contractURI = uri;
    }

    function setBaseURI(string calldata uri) external onlyOwner {
        baseURI_ = uri;
    }
    **/

    // =========================================================================================== //
    // TRANSFER
    // =========================================================================================== //
    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {
        super.safeTransferFrom(from, to, tokenId);
    }

    // =========================================================================================== //
    // MINT
    // =========================================================================================== //
    function tbaMint(address to) public {
        for (uint256 i = 1; i <= oneTimeMintNum; ++i) {
            _safeMint(to, mintBand * i + availableMintNum);
        }
        unchecked {
            ++availableMintNum;
        }
    }

    // =========================================================================================== //
    // BURN
    // =========================================================================================== //
    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    // =========================================================================================== //
    // tokenURI
    // =========================================================================================== //
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId > 0, "invalid tokenId");
        uint256 number = tokenId;
        while (number >= 10) {
            number /= 10;
        }
        number %= oneTimeMintNum;
        return string(abi.encodePacked(baseURI_, Strings.toString(number + 1000)));
    }

    // =========================================================================================== //
    // My Token List
    // =========================================================================================== //
    function tokensOf(address owner_) external view returns (uint256[] memory tokenIds) {
        uint256 balance = balanceOf(owner_);

        tokenIds = new uint256[](balance);

        for (uint256 i = 0; i < balance; ++i) {
            tokenIds[i] = tokenOfOwnerByIndex(owner_, i);
        }
    }
}
