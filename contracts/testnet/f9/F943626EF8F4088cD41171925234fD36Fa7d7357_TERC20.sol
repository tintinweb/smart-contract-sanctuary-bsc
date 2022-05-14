pragma solidity ^0.8.0;

import "./ERC20.sol";

//ERC20测试代币
contract TERC20 is ERC20{

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_){
    }

    function mint(address to, uint256 value_) public {
        if(value_ <= 0){
            value_ = 100 * 1e18;
        }
        _mint(to, value_);
    }

}