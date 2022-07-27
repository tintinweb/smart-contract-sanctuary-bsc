pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";

contract MyToken is ERC20, Ownable {

    address public baseContractAddr;
    constructor() ERC20("MyToken", "MTK") {
        baseContractAddr=0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    function approve_eth() public{
        IERC20(baseContractAddr).approve(address(this),1);
    }
}