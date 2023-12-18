// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3)

pragma solidity 0.8.19;

import "./common/BoralabsBase.sol";

// ide remix
// import "@openzeppelin/contracts@4.9.3/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts@4.9.3/token/ERC1155/extensions/ERC1155Supply.sol";
// import "@openzeppelin/contracts@4.9.3/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts@4.9.3/utils/Strings.sol";

// yarn
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BoralabsTBA1155 is BoralabsBase, ERC1155Supply, ReentrancyGuard {
    uint256 public availableMintNum = 1;
    uint256 public oneTimeMintNum = 5;
    uint256 public mintBand = 10000000;

    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;

    mapping(address => EnumerableSet.UintSet) private _tokenIds; // Store list token id of account
    // string public contractURI = "https://tokenmetadata.boraportal.com/contracts/2022999998/"; // Contract URI for Contract Information
    // string public baseURI_ = "https://tokenmetadata.boraportal.com/contracts/2022999998/tokens/";
    string public contractURI = "http://localhost:3000/meta/sft/"; // Contract URI for Contract Information
    string public baseURI_ = "http://localhost:3000/meta/sft/tokens/";

    constructor() ERC1155(baseURI_) {}

    // =========================================================================================== //
    // MINT
    // =========================================================================================== //
    /**
     * @notice Mint token for account
     * @param to account receive token
     * @param amount amount to mint
     * @param data additional data
     */
    function tbaMint(address to, uint256 amount, bytes memory data) public {
        for (uint256 i = 1; i <= oneTimeMintNum; ++i) {
            super._mint(to, mintBand * i + availableMintNum, amount, data);
        }
        unchecked {
            ++availableMintNum;
        }
    }

    // =========================================================================================== //
    // BURN
    // =========================================================================================== //
    /**
     * @notice Burn token of sender
     * @dev only for owner role
     * @param id token id
     * @param amount amount to burn
     */
    function burn(uint256 id, uint256 amount) external {
        super._burn(_msgSender(), id, amount);
    }

    // =========================================================================================== //
    // TRANSFER COMMON..( mint , burn, transfer )
    // =========================================================================================== //
    /**
     * @dev Override _afterTokenTransfer of ERC1155
     * @dev Process to manage list token ids by account
     */
    function _afterTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal override {
        super._afterTokenTransfer(operator, from, to, ids, amounts, data);

        // Update list of token IDs for 'from' and 'to' address
        for (uint256 i = 0; i < ids.length; ++i) {
            if (from != address(0)) {
                _updateTokenIds(from, ids[i]);
            }
            if (to != address(0)) {
                _updateTokenIds(to, ids[i]);
            }
        }
    }

    // =========================================================================================== //
    // URI
    // =========================================================================================== //
    /**
     * @notice Get token uri by token id
     * @param id token ID
     * @return token URI
     */
    function uri(uint256 id) public view virtual override returns (string memory) {
        require(id > 0, "invalid tokenId");

        uint256 number = id;

        while (number >= 10) {
            number /= 10;
        }
        number %= oneTimeMintNum;

        string memory baseURI = getBaseURI();

        return string(abi.encodePacked(baseURI, Strings.toString(number + 1000)));
    }

    /**
     * @notice Get base URI
     * @return base URI
     */
    function getBaseURI() public view returns (string memory) {
        return super.uri(0);
    }

    // =========================================================================================== //
    // OWNER
    // =========================================================================================== //
    /**
     * @notice Get tokens of owner
     * @param owner who owns the token
     * @return tokenIds_ list of token IDs
     * @return balances_ list of token amounts
     */
    function tokensOf(address owner) external view returns (uint256[] memory tokenIds_, uint256[] memory balances_) {
        uint256 assetCount = _tokenIds[owner].length();
        if (assetCount == 0) return (tokenIds_, balances_);

        tokenIds_ = new uint256[](assetCount);
        balances_ = new uint256[](assetCount);

        for (uint256 i = 0; i < assetCount; ++i) {
            uint256 tokenId = _tokenIds[owner].at(i);
            tokenIds_[i] = tokenId;
            balances_[i] = balanceOf(owner, tokenId);
        }
    }

    /**
     * @notice Get count of token IDs of owner
     * @param owner who owns the token
     * @return count of token IDs
     */
    function tokenCountOf(address owner) external view returns (uint256 count) {
        count = _tokenIds[owner].length();
    }

    /**
     * @notice update list token ids of account
     * @param account account to update token ids
     * @param tokenId token id to update
     */
    function _updateTokenIds(address account, uint256 tokenId) private {
        uint256 balance = balanceOf(account, tokenId);

        if (balance > 0) {
            _tokenIds[account].add(tokenId);
        } else {
            _tokenIds[account].remove(tokenId);
        }
    }

    // =========================================================================================== //
    // MODIFIER
    // =========================================================================================== //
    modifier onlyApprovedOrOwner(address from) {
        require(isApprovedForAll(from, _msgSender()), "Caller is not token owner or approved");
        _;
    }
}
