// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;
//pragma abicoder v2;

import "./Ownable.sol";
import "./IERC20.sol";
import "./ERC20.sol";


contract Token is ERC20, Ownable{


     constructor() public ERC20("Xinguan", "XGB")  {}



    function addToBlacklist(address token, bool state) external onlyOwner returns(bool) {
        require(token != address(0), "token cannot be zero address");
        tokenList[token] = state;
        return true;
    }


    function mint(uint256 amount) external onlyOwner returns(bool){
        _mint(_msgSender(), amount);
        return true;
    }


}