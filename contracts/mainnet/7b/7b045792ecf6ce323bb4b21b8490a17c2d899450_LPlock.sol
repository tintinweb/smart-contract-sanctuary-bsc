// SPDX-License-Identifier: MIT

//lock LP

pragma solidity ^0.8.11;

import "./IERC20.sol";
import "./IERC721.sol";
import "./Ownable.sol";

contract LPlock is Ownable {

    mapping (address => uint256) public locktime;

    function lockLP(IERC20 token, uint256 amount, uint256 decimals, uint256 endtime) public onlyOwner returns(bool){
        locktime[address(token)] = endtime;
        token.transferFrom(msg.sender, address(this), amount*10**decimals);
        return true;
    }

    function withdrawLP(IERC20 token, address to, uint256 amount) public onlyOwner returns(bool){
        require(locktime[address(token)] <= block.timestamp);
        token.transfer(to, amount);
        return true;
    }

    function withdrawETH(address to, uint256 amount) public onlyOwner returns(bool){
        (bool success,) = payable(to).call{
            value: amount
        }("");
        return success;
    }

    function withdrawOtherToken(IERC20 token, address to, uint256 amount) public onlyOwner returns(bool){
        require(locktime[address(token)] <= block.timestamp);
        token.transfer(to, amount);
        return true;
    }

    function withdrawNFT(IERC721 token, address to,uint256 tokenId) public onlyOwner returns(bool){
        token.transferFrom(address(this), to, tokenId);
        return true;
    }

    receive() external payable {}

    fallback() external payable {}
}