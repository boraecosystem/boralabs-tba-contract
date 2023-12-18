// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/ERC1155.sol)

pragma solidity 0.8.19;

import "./common/BoralabsBase.sol";
import "./interface/IERC6551Executable.sol";
import "./interface/IERC6551Account.sol";

// ide remix
// import "@openzeppelin/contracts@4.9.3/utils/introspection/IERC165.sol";
// import "@openzeppelin/contracts@4.9.3/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts@4.9.3/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts@4.9.3/interfaces/IERC1271.sol";
// import "@openzeppelin/contracts@4.9.3/interfaces/IERC1155.sol";
// import "@openzeppelin/contracts@4.9.3/utils/cryptography/SignatureChecker.sol";

// yarn
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract BoralabsTBA6551Account is BoralabsBase, IERC165, IERC1271, IERC6551Account, IERC6551Executable {
    uint256 public state;
    bytes4 private constant ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 private constant ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))

    // =========================================================================================== //
    // Account execute : contract send : _isValidSigner 로 6551 을 만든 721 의 owner 인지를 학인한다...
    // =========================================================================================== //
    function execute(address to, uint256 value, bytes calldata data, uint256 operation) external payable onlyOwner returns (bytes memory result) {
        require(operation == 0, "Only call operations are supported");

        ++state;

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    // =========================================================================================== //
    // Support Function : Transfer : owner 가 다른 사람에게 전송한다.
    // =========================================================================================== //
    function transferCoin(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount); // 코인 전송
    }

    function transfer20(address contractAddress, address to, uint256 amount) external onlyOwner {
        IERC20(contractAddress).transfer(to, amount);
    }

    function transfer721(address contractAddress, address to, uint256 tokenId) external onlyOwner {
        IERC721(contractAddress).transferFrom(address(this), to, tokenId);
    }

    function transfer1155(address contractAddress, address to, uint256 tokenId, uint256 amount, bytes memory data) external onlyOwner {
        IERC1155(contractAddress).safeTransferFrom(address(this), to, tokenId, amount, data);
    }

    // =========================================================================================== //
    // isValidSigner
    // =========================================================================================== //
    function isValidSigner(address signer, bytes calldata) external view returns (bytes4) {
        if (_isValidSigner(signer)) {
            return IERC6551Account.isValidSigner.selector;
        }

        return bytes4(0);
    }

    function _isValidSigner(address signer) internal view returns (bool) {
        return signer == owner();
    }

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue) {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    // =========================================================================================== //
    // supportsInterface
    // =========================================================================================== //
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC6551Account).interfaceId || interfaceId == type(IERC6551Executable).interfaceId);
    }

    // =========================================================================================== //
    // token
    // =========================================================================================== //
    function token() public view returns (uint256, address, uint256) {
        bytes memory footer = new bytes(0x60);

        assembly {
            extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
        }

        return abi.decode(footer, (uint256, address, uint256));
    }

    function owner() public view override returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    // =========================================================================================== //
    // NATIVE TOKEN RECEIVE FUNCTION
    // =========================================================================================== //
    receive() external payable {}

    // =========================================================================================== //
    // 20 RECEIVE FUNCTION
    // =========================================================================================== //

    // =========================================================================================== //
    // 721 RECEIVE FUNCTION
    // =========================================================================================== //
    function onERC721Received(address operator, address, uint256 tokenId, bytes calldata data) external pure returns (bytes4) {
        require(operator != address(0) && tokenId > 0 && data.length >= 0, "Invalid parameter");
        return this.onERC721Received.selector;
    }

    // =========================================================================================== //
    // 1155 RECEIVE FUNCTION
    // =========================================================================================== //
    function onERC1155Received(address operator, address, uint256 id, uint256 value, bytes calldata data) external pure returns (bytes4) {
        require(operator != address(0) && id > 0 && value > 0 && data.length >= 0, "Invalid parameter");
        return ERC1155_ACCEPTED;
    }

    /**
     * @notice Implement this method to accept smart contract receive token from batch transfer
     */
    function onERC1155BatchReceived(address operator, address, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external pure returns (bytes4) {
        require(operator != address(0) && ids.length > 0 && values.length > 0 && data.length >= 0, "Invalid parameter");
        return ERC1155_BATCH_ACCEPTED;
    }
}
