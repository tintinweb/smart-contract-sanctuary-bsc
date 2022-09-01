/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20{
    function transferFrom(address, address, uint256) external;
}

interface INFT{
    function mint(address, uint256) external;
}

contract Mint{
    struct Info{
        INFT nft;
        IERC20 currency;
        uint256 price;
        uint256 startTime;
        uint256 supply;
        uint256 reserve;
    }
    
    Info public info;
    address public owner;
    address public blackHole;
    
    constructor(INFT nft, IERC20 currency, uint256 price, uint256 startTime, uint256 supply, address _blackHole){
        owner = msg.sender;
        blackHole = _blackHole;
        info = Info(nft, currency, price, startTime, supply, supply);
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "MINT:onlyOwner");
        _;
    }
    
    function _setOwner(address _owner) external onlyOwner{
        owner = _owner;
    }
    
    function _setblackHole(address _blackHole) external onlyOwner{
        blackHole = _blackHole;
    }
    
    function _setPrice(uint256 price) external onlyOwner{
        info.price = price;
    }
    
    function _setStartTime(uint256 startTime) external onlyOwner{
        info.startTime = startTime;
    }
    
    function _increaseSupply(uint256 supply) external onlyOwner{
        info.supply += supply;
        info.reserve += supply;
    }
    
    function _decreaseSupply(uint256 supply) external onlyOwner{
        info.supply -= supply;
        info.reserve -= supply;
    }
    
    function mint(uint256 quantity) external {
        IERC20(info.currency).transferFrom(msg.sender, blackHole, info.price * quantity);
        info.nft.mint(msg.sender, quantity);
        info.reserve -= quantity;
    }
}