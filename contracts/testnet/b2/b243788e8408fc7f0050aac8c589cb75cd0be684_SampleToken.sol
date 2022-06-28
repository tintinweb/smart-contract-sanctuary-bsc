pragma solidity 0.6.12;

import "./ERC20.sol";
contract SampleToken is ERC20 {
     constructor() public ERC20("SampleToken", "FAU") {
        _mint(msg.sender, 1000000000000 ether);
    }
}