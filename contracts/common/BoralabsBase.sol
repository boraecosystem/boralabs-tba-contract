// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3)

pragma solidity 0.8.19;

// ide remix
// import "@openzeppelin/contracts@4.9.3/utils/Context.sol";
// import "@openzeppelin/contracts@4.9.3/access/Ownable.sol";

// yarn
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BoralabsBase is Context, Ownable {

    function owner() public view virtual override returns (address){
        return super.owner();
    }

}
