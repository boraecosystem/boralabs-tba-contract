// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/IERC6551Registry.sol";
import "./library/ERC6551BytecodeLib.sol";

// ide remix
// import "@openzeppelin/contracts@4.9.3/utils/Create2.sol";
// import "@openzeppelin/contracts@4.9.3/utils/structs/EnumerableSet.sol";

// yarn
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract BoralabsTBA6551Registry is IERC6551Registry {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => mapping(uint256 => EnumerableSet.AddressSet)) private _tokenList;

    error AccountCreationFailed();

    function createAccount(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt, bytes calldata initData) external returns (address) {
        bytes memory code = ERC6551BytecodeLib.getCreationCode(implementation, chainId, tokenContract, tokenId, salt);

        address _account = Create2.computeAddress(bytes32(salt), keccak256(code));

        if (_account.code.length != 0) return _account;

        emit AccountCreated(_account, implementation, chainId, tokenContract, tokenId, salt);

        assembly {
            _account := create2(0, add(code, 0x20), mload(code), salt)
        }

        if (_account == address(0)) revert AccountCreationFailed();

        _tokenList[tokenContract][tokenId].add(_account);

        if (initData.length != 0) {
            (bool success, bytes memory result) = _account.call(initData);

            if (!success) {
                assembly {
                    revert(add(result, 32), mload(result))
                }
            }
        }

        return _account;
    }

    function account(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt) external view returns (address) {
        bytes32 bytecodeHash = keccak256(ERC6551BytecodeLib.getCreationCode(implementation, chainId, tokenContract, tokenId, salt));

        return Create2.computeAddress(bytes32(salt), bytecodeHash);
    }

    function accountsOf(address tokenContract, uint256 tokenId) external view returns (address[] memory accounts) {
        uint256 count = _tokenList[tokenContract][tokenId].length();
        accounts = new address[](count);
        for (uint256 i = 0; i < count; ++i) {
            accounts[i] = _tokenList[tokenContract][tokenId].at(i);
        }
    }
}
