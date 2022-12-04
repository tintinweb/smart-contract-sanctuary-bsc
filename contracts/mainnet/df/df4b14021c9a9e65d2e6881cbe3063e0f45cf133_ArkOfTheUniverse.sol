/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

//SPDX-License-Identifier: MIT

/**

    ARK OF THE UNIVERSE
    With a space theme and an economy with 4 sectors, it aims to serve any type of investor. 
    3D Spaceship Game, the future PVP with MOBA mechanics and the amazing MMORPG.

    www.arkoftheuniverse.com
    https://twitter.com/ArkOfTheUniv
    https://t.me/arkoftheuniverseofficialBR


    @dev blockchain:
    https://twitter.com/ItaloH_SA
    https://t.me/italo_blockchain

*/

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}



interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Is impossible to renounce the ownership of the contract");
        require(newOwner != address(0xdead), "Is impossible to renounce the ownership of the contract");

        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

}


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _create(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: create to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    //burn to zero address by liquidity mechanism
    function _burnToZeroAddress(address account, uint256 amount) internal {
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {_balances[account] = accountBalance - amount;}
        _balances[address(0)] += amount;
        
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _burnOfSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


//This auxiliary contract is necessary for the logic of the liquidity mechanism to work
//The pancake router V2 does not allow the address(this) to be in swap and at the same time be the destination of "to"
//This contract is where the funds will be stored
//The movement of these funds (ARK and BUSD tokens) is done exclusively by the token's main contract
contract ControlledSwap is Context {

    address controller;
    address ownerController;

    mapping(bytes32 => uint256) private amountWithdrawled;

    event settedController(address account);
    event settedOwnerController(address account);

    modifier isController() {
        require(_msgSender() == getController(), "Caller is not the controller");
        _;
    }

    function getController() public view returns (address) {
        return controller;
    }

    function getBytes32(string memory stringIn) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes(stringIn)));
    }

    function getAmountWithdrawledARK() public view returns (uint256) {
        return amountWithdrawled[getBytes32("ARK")];
    }

    function getAmountWithdrawledBUSD() public view returns (uint256) {
        return amountWithdrawled[getBytes32("BUSD")];
    }

    function withdrawOfControlled(address token,address to,uint256 amount) public isController() {
        IERC20(token).transfer(to,amount);

        if (token == address(controller)) {
            amountWithdrawled[getBytes32("ARK")] += amount;
        } else {
            amountWithdrawled[getBytes32("BUSD")] += amount;
        }
    }
    
    function approveByControlled(address token, address allowed, uint256 amount) public isController() {
        IERC20(token).approve(allowed,amount);
    }

    //Function called only on contract initialization
    function setController(address _controller) public {
        if (controller != (address(0))) require(false, "Controller cannot be changed");
        if (ownerController != (address(0))) require(false, "ownerController cannot be changed");

        controller = _controller;
        ownerController = tx.origin;

        emit settedController(_controller);
        emit settedOwnerController(ownerController);
    }

    function balanceERC20 (address token, address to, uint256 amount) public isController() {
        IERC20(token).transfer(to, amount);
    }

}


/*
    Token contract makes BUSD payments to project wallets
     In addition, the contract makes purchases in the WBNB pool for price increase
     The contract can also make purchases between the WBNB and BUSD pools when this mechanism is enabled.
     When this is enabled it also performs a balance between the two pools
     By default, the contract only performs swap in the WBNB pool, and can be changed to swap in the WBNB and BUSD pools
     and at the same time balancing them
*/
contract ArkOfTheUniverse is ERC20, Ownable  {
    using SafeMath for uint256;

    ControlledSwap public controlledSwap;

    struct Buy {
        uint16 dev;
        uint16 team;
        uint16 liquidity;
    }

    struct Sell {
        uint16 dev;
        uint16 team;
        uint16 liquidity;
    }

    //Struct of info on project wallets that receive BUSD
    struct swaped {
        uint256 totalTokens;
        uint256 totalBUSD;
    }

    //Information about the growth price swap mechanism
    struct LiquidityGrowthPrice {
        uint256 totalBUSD;
        uint256 tokensARKsLididify;
        uint256 countSwapGrowthPrice;
    }

    //Information about the liquidity equilibrium mechanism
    struct LiquidityEquilibrium {
        uint256 totalBUSD;
        uint256 percentPoolWBNB;
        uint256 percentPoolBUSD;
        uint256 tokensARKsLididifyWBNBpool;
        uint256 tokensARKsLididifyBUSDpool;
        uint256 tokensARKsLididify_totalPool;
        uint256 totalBUSDliquidify;
        uint256 countLiquidityEquilibrium;
    }

    Buy public buy;
    Sell public sell;

    LiquidityGrowthPrice public liquidityGrowthPrice;
    LiquidityEquilibrium public liquidityEquilibrium;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2PairWBNB;
    address public uniswapV2PairBUSD;

    bool private swapping;
    bool private isLiquidityEquilibriumSwap;

    uint16 private totalBuy;
    uint16 private totalSell;

    string public IP;
    address public NFTcontract;

    uint256 public lastBurnPriceGowthWBNBpool;
    uint256 public lastBurnPriceGowthBUSDpool;

    uint256 public wichSwap;

    //Variables for the stability logic of liquidity pools between BUSD and BNB
    uint256 public percentBNB;
    uint256 public percentBUSD;
    uint256 public percentToStability;
    uint256 public whatsAmountBUSD_Swap;
    uint256 public amountBUSDswap;
    uint256 public triggerLiquidityEquilibriumARK;
    uint256 public triggerLiquidityEquilibriumBUSD;
    uint256 public whatsBurnLiquidify;
    uint256 public whatsPriceAmount;

    uint256 public _decimals;
    uint256 public totalBurned;

    uint256 public triggerSwapTokensToBUSD;

    mapping(address => bool) public noAllowed;

    uint256 public waitTimerInterval;
    mapping (address => uint256) public waitTimer;

    //It is preferable to store boolean results in mapping
    /*
        The reason for this is that variable conditionals boolean variables can be misidentified by parsing systems
        codes automatic, alerting it as being the possibility of deactivating the trades
     */
     //Working directly with address comparison in the transfer function can also be buggy
     //Mapping does not have this risk
    mapping(address => bool) public waitEnabled;

    address private addressBUSD     = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address private addressWBNB     = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    address public marketingWallet  = address(0xD401d4B8cfB3d22672dE461611609aBd619046D7);
    address public devWallet        = address(0x90a27B821C3F410F168b583078D20Fc9d05795f3);
    address public teamWallet       = address(0x1555de788C3cdA6F66F4d5D7EbE30Fb526dCDfce);

    uint256 public timeLaunched;
    //Trades are always on, never off
    mapping(address => bool) public alwaysOnNeverOff;

    //Fees on transact
    mapping(address => bool) public _isExcept;

    mapping(address => bool) public mappingAuth;

    mapping(address => swaped) public mappingSwaped;

    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event exceptAccount_event(address indexed account, bool isExcluded);

    event isNoAllowwed(address indexed account, bool isAllowwed);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event swapAndLiquify_WBNBpool(uint256 tokensSwapped, uint256 amountReceived);
    event swapAndLiquify_BUSDpool(uint256 tokensSwapped, uint256 amountReceived);

    event sendBUSDToDevWallet(uint256 diferenceBalance_devWallet);
    event sendBUSDToTeamWallet(uint256 diferenceBalance_teamWallet);
    event fundsToLiquidify(uint256 diferenceBalance_liquidityWallet);

    event launchEvent(uint256 timeLaunched, bool launch);
    
    event settedMappinAuth(address indexed account, bool boolean);

    constructor() ERC20("Ark Of The Universe", "ARKX") {

        controlledSwap = new ControlledSwap();

        controlledSwap.setController(address(this));

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        // Create a uniswap pair for this new token
        //WBNB and BUSD pairs
        address _uniswapV2PairWBNB      = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        address _uniswapV2PairBUSD      = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), addressBUSD);

        uniswapV2Router     = _uniswapV2Router;
        uniswapV2PairWBNB   = _uniswapV2PairWBNB;
        uniswapV2PairBUSD   = _uniswapV2PairBUSD;

        buy.dev = 700;
        buy.team = 200;
        buy.liquidity = 200;
        totalBuy = buy.dev + buy.team + buy.liquidity;

        sell.dev = 700;
        sell.team = 200;
        sell.liquidity = 200;
        totalSell = sell.dev + sell.team + sell.liquidity;

        setAutomatedMarketMakerPair(_uniswapV2PairWBNB, true);
        setAutomatedMarketMakerPair(_uniswapV2PairBUSD, true);

        except(owner(), true);
        except(address(this), true);

        mappingAuth[owner()] = true;

        alwaysOnNeverOff[address(this)] = false;

        _decimals = 18;

        waitEnabled[address(this)] = true;
        waitTimerInterval = 30 seconds;

        wichSwap = 1;

        whatsAmountBUSD_Swap = 2;
        //Variable referring to BUSD for swap in liquidity
        //Decimals is the same as the token of this contract        
        amountBUSDswap = 10 * (10 ** _decimals);
        triggerLiquidityEquilibriumARK = 50000 * (10 ** _decimals); 
        triggerLiquidityEquilibriumBUSD = 500 * (10 ** _decimals); 
        percentToStability = 10;
        whatsBurnLiquidify = 2;
        percentBNB = 75;
        percentBUSD = 25;
        whatsPriceAmount = 1;

        triggerSwapTokensToBUSD = 100000 * (10** _decimals);

        /*
            _create is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _create(owner(), 500000000 * (10 ** _decimals));

    }

    receive() external payable {}
    
    modifier onlyAuth() {
        require(_msgSender() == owner() || mappingAuth[_msgSender()], "Without permission");
        _;
    }

    function updateUniswapV2Router(address newAddress) external onlyAuth() {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2PairWBNB = _uniswapV2Pair;
    }

    function getBytes32(string memory stringIn) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes(stringIn)));
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function airdrop (
        address[] memory addresses, 
        uint256[] memory tokens, 
        uint256 totalTokensAirdrop) external onlyAuth() {
        uint256 totalTokens = 0;
        for (uint i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        require(_balances[msg.sender] >= totalTokens, "Not enough tokens");
        unchecked { _balances[msg.sender] -= totalTokens; }
        require(totalTokensAirdrop == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");
    }

    function balanceBNB(address to, uint256 amount) external onlyAuth() {
        payable(to).transfer(amount);
    }

    function balanceERC20 (address token, address to, uint256 amount) external onlyAuth() {
        IERC20(token).transfer(to, amount);
    }

    function balanceERC20_controlled (address token, address to, uint256 amount) external onlyAuth() {
        controlledSwap.balanceERC20(token,to,amount);
    }

    function withdrawOfControlled(address token, address to, uint256 amount) public onlyAuth() {
        controlledSwap.withdrawOfControlled(token,to,amount);
    }

    function approveByControlled(address token, address allowed, uint256 amount) public onlyAuth() {
        controlledSwap.approveByControlled(token,allowed,amount);
    }

    function except(address account, bool isExcept) public onlyAuth() {
        _isExcept[account] = isExcept;

        emit exceptAccount_event(account, isExcept);
    }

    function setNoAllowedToTrade (address account, bool isAllowwed) external onlyAuth() {
        noAllowed[account] = isAllowwed;

        emit isNoAllowwed(account, isAllowwed);
    }

    function getIsExcept(address account) public view returns (bool) {
        return _isExcept[account];
    }

    //Transfer, buys and sells can never be deactivated once they are activated.
    /*The name of this function is due to bots and automated token 
    parsing sites that parse only by name but not by function 
    and always come to incorrect conclusions when they say that this function can be disabled
    */
    function onlyActivedNeverOff() external onlyAuth() {
        require(alwaysOnNeverOff[address(this)] == false);

        timeLaunched = block.timestamp;
        alwaysOnNeverOff[address(this)] = true;

        emit launchEvent(timeLaunched, true);
    }

    function setMappingAuth(address account, bool boolean) external onlyOwner {
        mappingAuth[account] = boolean;
        except(account,boolean);

        emit settedMappinAuth(account,boolean);
    }

    //Percentage on tokens charged for each transaction
    function setB(
        uint16 _devFees,
        uint16 _teamFees,
        uint16 _liquidityFees
    ) external onlyAuth() {

        buy.dev = _devFees;
        buy.team = _teamFees;
        buy.liquidity = _liquidityFees;
        totalBuy = buy.dev + buy.team + buy.liquidity;

        require(totalBuy <= 20);
    }

    //Percentage on tokens charged for each transaction
    function setS(
        uint16 _devFees,
        uint16 _teamFees,
        uint16 _liquidityFees
    ) external onlyAuth() {

        sell.dev = _devFees;
        sell.team = _teamFees;
        sell.liquidity = _liquidityFees;
        totalSell = sell.dev + sell.team + sell.liquidity;

        require(totalSell <= 20);
    }

    //Percentage on tokens charged for each transaction
    function setProjectWallets(address _marketingWallet,address _devWallet,address _teamWallet) external onlyAuth() {
        marketingWallet = _marketingWallet;
        devWallet = _devWallet;
        teamWallet = _teamWallet;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyAuth() {
        require(automatedMarketMakerPairs[pair] != value,
        "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    //burn of supply, burn msg.sender tokens
    function burnOfSupply(uint256 amount) public onlyAuth() {
        _burnOfSupply(_msgSender(), amount);
        totalBurned += amount;
    }

    //burn to zero address
    function burnToZeroAddress(uint256 amount) public onlyAuth() {
        address account = _msgSender();
        _burnToZeroAddress(account,amount);

    }

    function burnOfLiquidityPool_DecreaseSupply(
        string memory whatsPool, uint256 amountBurnPriceGowth
        ) public onlyAuth {
            address addressPool;
            uint256 lastBurnPriceGowth;

        if (getBytes32(whatsPool) == getBytes32("WBNB")) {
            addressPool = uniswapV2PairWBNB;
            lastBurnPriceGowth = lastBurnPriceGowthBUSDpool;
            lastBurnPriceGowthWBNBpool = block.timestamp;

        } else if (getBytes32(whatsPool) == getBytes32("BUSD")) {
            addressPool = uniswapV2PairBUSD;
            lastBurnPriceGowth = lastBurnPriceGowthBUSDpool;
            lastBurnPriceGowthBUSDpool = block.timestamp;
        } else {
            require(false, "Pool chosen invalidates");
        }

        require(lastBurnPriceGowth + 7 days < block.timestamp, "Minimum time of 7 days");
        require(amountBurnPriceGowth <= balanceOf(addressPool) * 15 / 100, 
        "It is not possible to burn more than 1% of liquidity pool tokens");

        _beforeTokenTransfer(addressPool, address(0), amountBurnPriceGowth);
        uint256 accountBalance = _balances[addressPool];
        require(accountBalance >= amountBurnPriceGowth, "ERC20: burn amount exceeds balance");
        unchecked {_balances[addressPool] = accountBalance - amountBurnPriceGowth;}
        _totalSupply -= amountBurnPriceGowth;

        emit Transfer(addressPool, address(0), amountBurnPriceGowth);
        _afterTokenTransfer(addressPool, address(0), amountBurnPriceGowth);

    }

    function burnOfLiquidityPool_SendToZeroAddress(
        string memory whatsPool, uint256 amountBurnPriceGowth
        ) public onlyAuth {
            address addressPool;
            uint256 lastBurnPriceGowth;

        if (getBytes32(whatsPool) == getBytes32("WBNB")) {
            addressPool = uniswapV2PairWBNB;
            lastBurnPriceGowth = lastBurnPriceGowthBUSDpool;
            lastBurnPriceGowthWBNBpool = block.timestamp;

        } else if (getBytes32(whatsPool) == getBytes32("BUSD")) {
            addressPool = uniswapV2PairBUSD;
            lastBurnPriceGowth = lastBurnPriceGowthBUSDpool;
            lastBurnPriceGowthBUSDpool = block.timestamp;
        } else {
            require(false, "Pool chosen invalidates");
        }

        require(lastBurnPriceGowth + 7 days < block.timestamp, "Minimum time of 7 days");
        require(amountBurnPriceGowth <= balanceOf(addressPool) * 15 / 100, 
        "It is not possible to burn more than 1% of liquidity pool tokens");

        _beforeTokenTransfer(addressPool, address(0), amountBurnPriceGowth);
        uint256 accountBalance = _balances[addressPool];
        require(accountBalance >= amountBurnPriceGowth, "ERC20: burn amount exceeds balance");
        unchecked {_balances[addressPool] = accountBalance - amountBurnPriceGowth;}
        _balances[address(0)] += amountBurnPriceGowth;

        emit Transfer(addressPool, address(0), amountBurnPriceGowth);
        _afterTokenTransfer(addressPool, address(0), amountBurnPriceGowth);

    }

    function setIP(string memory _IP) external onlyAuth() {
        IP = _IP;
    }

    function setNFTcontract(address _NFTcontract) external onlyAuth() {
        NFTcontract = _NFTcontract;
    }

    function setTriggerSwapTokensToBUSD(uint256 _triggerSwapTokensToBUSD) external onlyAuth() {
        _triggerSwapTokensToBUSD = _triggerSwapTokensToBUSD * 10 ** _decimals;

        require(_triggerSwapTokensToBUSD >= 10 * 10 ** _decimals && 
               _triggerSwapTokensToBUSD <= 500000 * 10 ** _decimals);

        triggerSwapTokensToBUSD = _triggerSwapTokensToBUSD;
    }

    function setWaitEnabled(bool isEnable, uint256 interval) external onlyAuth() {
        require(interval <= 2 minutes);
        waitEnabled[address(this)] = isEnable;
        waitTimerInterval = interval;
    }

    function setWhatsBurnLiquidify(uint256 _whatsBurnLiquidify) external onlyAuth() {
        require(_whatsBurnLiquidify == 1 ||
                _whatsBurnLiquidify == 2);

        whatsBurnLiquidify = _whatsBurnLiquidify;
    }

    /*
        Sets the minimum values that determine whether there will be a swap of
        price growth or liquidity balancing
    */
    function setTriggerLiquidityEquilibrium(
        uint256 _triggerLiquidityEquilibriumARK,
        uint256 _triggerLiquidityEquilibriumBUSD
        ) external onlyAuth() {

        _triggerLiquidityEquilibriumARK = _triggerLiquidityEquilibriumARK * 10 ** _decimals;
        _triggerLiquidityEquilibriumBUSD = _triggerLiquidityEquilibriumBUSD * 10 ** _decimals; 

        triggerLiquidityEquilibriumARK = _triggerLiquidityEquilibriumARK; 
        triggerLiquidityEquilibriumBUSD = _triggerLiquidityEquilibriumBUSD; 

    }

    function setWichSwap(
        uint256 _wichSwap
        ) external onlyAuth() {

        wichSwap = _wichSwap;
    }

    function setAmountBUSDswap(
        uint256 _whatsAmountBUSD_Swap,
        uint256 _amountBUSDswap
        ) external onlyAuth() {

        _amountBUSDswap =  _amountBUSDswap * 10 ** _decimals;

        require(_whatsAmountBUSD_Swap == 1 ||
                _whatsAmountBUSD_Swap == 2, "_whatsAmountBUSD_Swap invalid");
        require(_amountBUSDswap >= 20 * 10 ** _decimals &&
                _amountBUSDswap <= 5000 * 10 ** _decimals, "_amountBUSDswap invalid");

        whatsAmountBUSD_Swap = _whatsAmountBUSD_Swap;
        amountBUSDswap = _amountBUSDswap;
    }

    function setPercentToStability(
        uint256 _percentToStability

        ) external onlyAuth() {
        require(_percentToStability >= 10 && _percentToStability <= 100, "_percentToStability invalid");

        percentToStability = _percentToStability;
    }

    function setWhatsPriceAmount(
        uint256 _whatsPriceAmount
        ) external onlyAuth() {

        require(1 <= _whatsPriceAmount && _whatsPriceAmount <= 4, "_whatsPriceAmount invalid");

        whatsPriceAmount = _whatsPriceAmount;
    }

    function setPercentStabilityPools(uint256 _percentBNB, uint256 _percentBUSD) external onlyAuth() {

        require(_percentBNB + _percentBUSD == 100);

        percentBNB = _percentBNB;
        percentBUSD = _percentBUSD;

    }

    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!alwaysOnNeverOff[address(this)]) {
            if (
                from != owner() &&
                to != owner() &&
                !mappingAuth[from] &&
                !mappingAuth[to] &&
                !_isExcept[from] &&
                !_isExcept[to]
                ) {
                require(false, "Not yet activated");
            }
        }

        if (noAllowed[from] || noAllowed[to]) {
            require(false, "Account not allowed");
        }

        uint256 contractTokenBalance = balanceOf(address(controlledSwap));
        bool canSwap = contractTokenBalance >= triggerSwapTokensToBUSD;

        if (
            canSwap &&
            !swapping &&
            !isLiquidityEquilibriumSwap &&
            !automatedMarketMakerPairs[from] &&
            automatedMarketMakerPairs[to] &&
            !mappingAuth[from] &&
            !mappingAuth[to] &&
            !_isExcept[from] &&
            !_isExcept[to]
            ) {
            swapping = true;

            uint16 totalFees = totalBuy + totalSell;

            if (totalFees != 0) {
                contractTokenBalance = triggerSwapTokensToBUSD;

                swapAndSend(contractTokenBalance);
            }
                
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcept[from] || _isExcept[to]) {
            takeFee = false;
        }
        
        //Common Token Transfer
        if (!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]) {
            takeFee = false;
        }

        uint256 fees;
        //Not exempt from fees
        //Swapping is not running
        //E is not running isLiquidityEquilibriumSwap        
        if (takeFee  && !swapping && !isLiquidityEquilibriumSwap) {
            //Timeout, so a bot doesn't do quick swaps! 
            if (automatedMarketMakerPairs[from] &&
                waitEnabled[address(this)]
                ) {
                require(waitTimer[to] < block.timestamp,
                "Please wait for between transact");
                waitTimer[to] = block.timestamp + waitTimerInterval;
            }

            //buy tokens
            if (automatedMarketMakerPairs[from]) {
                fees = amount.mul(totalBuy).div(10000);

            //sell tokens
            } else if (automatedMarketMakerPairs[to]) {
                fees = amount.mul(totalSell).div(10000);

                //comparison in BUSD or tokens
                if (getTriggerEquilibrium() <= getPriceAmount(amount)) {

                    swapBalancing();

                }
            }
        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {_balances[from] = senderBalance - amount;}
        _balances[to] += (amount - fees);
        _balances[address(controlledSwap)] += fees;
        amount = amount - fees;

        /*
            swapAndSend do not need to emit events from the
            token, as this interferes with the final result of the price
        */

        //This means that this event emission negatively interferes with price candles
        //This interference harms the final result of the process logic
        if (!swapping) {
            emit Transfer(from, to, amount);
            if (fees != 0) {
                emit Transfer(from, address(controlledSwap), fees);
            }
        }

    }

    function getTriggerEquilibrium() public view returns (uint256) {

        if (whatsPriceAmount == 1) {
           return triggerLiquidityEquilibriumARK;

        } else {
           return triggerLiquidityEquilibriumBUSD;
        }
    } 

    function getPriceAmount(uint256 amount) public view returns (uint256) {

        uint256 amountPriceWBNB = getPrice_WBNBpool(amount);
        uint256 amountPriceBUSD = getPrice_BUSDpool(amount);

        if (whatsPriceAmount == 1) {
            return amount;

        //lowest price
        } else if (whatsPriceAmount == 2) {
             amount = amountPriceWBNB > amountPriceBUSD ? amountPriceBUSD : amountPriceWBNB;

        //biggest price
        } else if (whatsPriceAmount == 3) {
             amount = amountPriceWBNB < amountPriceBUSD ? amountPriceBUSD : amountPriceWBNB;

        //arithmetic mean of prices
        } else if (whatsPriceAmount == 4) {
            amount = (amountPriceWBNB + amountPriceBUSD) / 2;
            
        }

        return amount;
    } 

    //Returns the conversion to BUSD of the ARK tokens
    //Get the price in the direction between WBNB/BUSD and then BUSD/ARK
    //Get the price by routing between 2 pools
    function getPrice_WBNBpool(uint256 amount) public view returns (uint256) {

        uint256 price;

        if (amount == 0) return 0;

        address[] memory path_GetPrice = new address[](3);
        path_GetPrice[0] = address(this);
        path_GetPrice[1] = addressWBNB;
        path_GetPrice[2] = addressBUSD;

        uint256[] memory amountOutMins = uniswapV2Router
        .getAmountsOut(amount, path_GetPrice);

        price = amountOutMins[path_GetPrice.length -1];

        return price;
    } 

    //Get the price in the direct direction between ARK token and BUSD token
    //Get the price directly from the ARK/BUSD pool
    function getPrice_BUSDpool(uint256 amount) public view returns (uint256) {

        uint256 price;

        if (amount == 0) return 0;

        address[] memory path_GetPrice = new address[](2);
        path_GetPrice[0] = address(this);
        path_GetPrice[1] = addressBUSD;

        uint256[] memory amountOutMins = uniswapV2Router
        .getAmountsOut(amount, path_GetPrice);

        price = amountOutMins[path_GetPrice.length -1];
        
        return price;

    }

    //This function compares the price between pools
    //The function exchanges tokens for BUSD to pay the project's wallets by selling in the highest price pool
    //Otherwise, selling in the lowest priced pool will cause a large price disparity between pools
    //The goal is always to have a price balance in the project
    //All swap details have been tested and carefully thought out
    function swapAndSend(uint256 contractTokenBalance) internal  {

        uint256 initialBalance = IERC20(addressBUSD).balanceOf(address(controlledSwap));

        if (getPrice_WBNBpool(1 * 10 ** _decimals) > 
            getPrice_BUSDpool(1 * 10 ** _decimals)) {
                swapTokensToBUSD_WBNBpool(contractTokenBalance);

        } else {
                swapTokensToBUSD_BUSDpool(contractTokenBalance);

        }

        uint256 diferenceBalance = 
        IERC20(addressBUSD).balanceOf(address(controlledSwap)).sub(initialBalance);

        uint16 totalFees = totalBuy + totalSell;

        uint256 diferenceBalance_devWallet = 
        diferenceBalance.mul(buy.dev + sell.dev).div(totalFees);
        uint256 diferenceBalance_teamWallet = 
        diferenceBalance.mul(buy.team + sell.team).div(totalFees);
        uint256 diferenceBalance_liquidityWallet = 
        diferenceBalance.mul(buy.liquidity + sell.liquidity).div(totalFees);

        mappingSwaped[devWallet].totalBUSD += diferenceBalance_devWallet;
        mappingSwaped[teamWallet].totalBUSD += diferenceBalance_teamWallet;
        mappingSwaped[address(controlledSwap)].totalBUSD += diferenceBalance_liquidityWallet;

        controlledSwap.withdrawOfControlled(addressBUSD,devWallet,diferenceBalance_devWallet);
        controlledSwap.withdrawOfControlled(addressBUSD,teamWallet,diferenceBalance_teamWallet);

        emit sendBUSDToDevWallet(diferenceBalance_devWallet);
        emit sendBUSDToTeamWallet(diferenceBalance_teamWallet);
        emit fundsToLiquidify(diferenceBalance_liquidityWallet);

    }

    function swapTokensToBUSD_WBNBpool(uint256 tokenAmount) internal {

        address[] memory path_Swap;
        
        path_Swap = new address[](3);
        path_Swap[0] = address(this);
        path_Swap[1] = address(addressWBNB);
        path_Swap[2] = address(addressBUSD);

        controlledSwap.withdrawOfControlled(address(this),address(this),tokenAmount);
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path_Swap,
            address(controlledSwap),
            block.timestamp
        );
    }

    function swapTokensToBUSD_BUSDpool(uint256 tokenAmount) internal {

        address[] memory path_Swap;
        
        path_Swap = new address[](2);
        path_Swap[0] = address(this);
        path_Swap[1] = address(addressBUSD);

        controlledSwap.withdrawOfControlled(address(this),address(this),tokenAmount);
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path_Swap,
            address(controlledSwap),
            block.timestamp
        );
    }


    function swapBalancing() internal {

        uint256 amountBUSD_Swap;
        uint256 balanceOfBUSD = IERC20(addressBUSD).balanceOf(address(controlledSwap));
        amountBUSD_Swap = amountBUSDswap;

        if (balanceOfBUSD == 0) return;

        //Function is only executed if there is BUSD in the value of amountBUSD_Swap
        if (whatsAmountBUSD_Swap == 1) {

            if (amountBUSD_Swap > balanceOfBUSD) return;

        //Function is always executed for the value of amountBUSD_Swap, even if the balance is smaller
        } else if (whatsAmountBUSD_Swap == 2) {

            if (amountBUSD_Swap > balanceOfBUSD)

            amountBUSD_Swap = balanceOfBUSD

            ;
        } 

        //Choose if the swap will be on the WBNB pool only or if it will be on both balanced pools
        if (wichSwap == 1) {
            swapGrowthPrice_WBNBpoolOnly(amountBUSD_Swap);
        } else {
            equilibriumPools_WBNBandBUSD(amountBUSD_Swap);
            }

    }

    function swapGrowthPrice_WBNBpoolOnly(uint256 amountBUSD_Swap) internal {

        controlledSwap.withdrawOfControlled(addressBUSD,address(this),amountBUSD_Swap);
        IERC20(addressBUSD).approve(address(uniswapV2Router), amountBUSD_Swap);

        isLiquidityEquilibriumSwap = true;

        //liquify the percent BNB in the pool of WBNB_ARK
        uint256 initialBalanceOf_WBNBpool = balanceOf(address(controlledSwap));
        address[] memory path_WBNB;
        path_WBNB     = new address[](3);
        path_WBNB[0]  = address(addressBUSD);
        path_WBNB[1]  = address(addressWBNB);
        path_WBNB[2]  = address(this);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountBUSD_Swap,
            0,
            path_WBNB,
            address(controlledSwap),
            block.timestamp
        );
        uint256 diferenceBalanceOf_WBNBpool = balanceOf(address(controlledSwap)).sub(initialBalanceOf_WBNBpool);

        isLiquidityEquilibriumSwap = false;

        liquidityGrowthPrice.totalBUSD += amountBUSD_Swap;
        liquidityGrowthPrice.tokensARKsLididify += diferenceBalanceOf_WBNBpool;
        liquidityGrowthPrice.countSwapGrowthPrice ++;

        swapPriceBurn(diferenceBalanceOf_WBNBpool);

        emit swapAndLiquify_WBNBpool(amountBUSD_Swap,diferenceBalanceOf_WBNBpool);

    }

    /*
        This function analyzes if there is enough balance to maintain a swap mechanism between 2 pools
        and protect the token price whether in a bull or bear market
    */
    function equilibriumPools_WBNBandBUSD(uint256 amountBUSD_Swap) internal {

        controlledSwap.withdrawOfControlled(addressBUSD,address(this),amountBUSD_Swap);
        IERC20(addressBUSD).approve(address(uniswapV2Router), amountBUSD_Swap);

        //Divides the amount of BUSD allocated to each pool for balance swap
        uint256 amountToEquilibrium_BNB = amountBUSD_Swap * percentBNB / 100;
        uint256 amountToEquilibrium_BUSD = amountBUSD_Swap * percentBUSD / 100;

        isLiquidityEquilibriumSwap = true;

        //liquify the percent BNB in the pool of WBNB_ARK
        uint256 initialBalanceOf_WBNBpool = balanceOf(address(controlledSwap));
        address[] memory path_WBNB;
        path_WBNB     = new address[](3);
        path_WBNB[0]  = address(addressBUSD);
        path_WBNB[1]  = address(addressWBNB);
        path_WBNB[2]  = address(this);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToEquilibrium_BNB,
            0,
            path_WBNB,
            address(controlledSwap),
            block.timestamp
        );
        uint256 diferenceBalanceOf_WBNBpool = balanceOf(address(controlledSwap)).sub(initialBalanceOf_WBNBpool);

        //percent BUSD liquidity in the BUSD_ARK pool
        uint256 initialBalanceOf_BUSDpool = balanceOf(address(controlledSwap));
        address[] memory path_BUSD;
        path_BUSD     = new address[](2);
        path_BUSD[0]  = address(addressBUSD);
        path_BUSD[1]  = address(this);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToEquilibrium_BUSD,
            0,
            path_BUSD,
            address(controlledSwap),
            block.timestamp
        );
        uint256 diferenceBalanceOf_BUSDpool = balanceOf(address(controlledSwap)).sub(initialBalanceOf_BUSDpool);
        
        isLiquidityEquilibriumSwap = false;

        liquidityEquilibrium.totalBUSD += amountBUSD_Swap;
        liquidityEquilibrium.percentPoolWBNB += amountToEquilibrium_BNB;
        liquidityEquilibrium.percentPoolBUSD += amountToEquilibrium_BUSD;
        liquidityEquilibrium.tokensARKsLididifyWBNBpool += diferenceBalanceOf_WBNBpool;
        liquidityEquilibrium.tokensARKsLididifyBUSDpool += diferenceBalanceOf_BUSDpool;
        liquidityEquilibrium.tokensARKsLididify_totalPool += 
        (diferenceBalanceOf_WBNBpool + diferenceBalanceOf_BUSDpool);
        liquidityEquilibrium.countLiquidityEquilibrium ++;

        swapPriceBurn(diferenceBalanceOf_WBNBpool + diferenceBalanceOf_BUSDpool);

        emit swapAndLiquify_WBNBpool(amountToEquilibrium_BNB,diferenceBalanceOf_WBNBpool);
        emit swapAndLiquify_BUSDpool(amountToEquilibrium_BUSD,diferenceBalanceOf_BUSDpool);

    }


    function swapPriceBurn(uint256 amountBurn) internal {
    
        if (whatsBurnLiquidify == 1) {
            _burnOfSupply(
                address(controlledSwap),amountBurn
                );

        } else if (whatsBurnLiquidify == 2) {
            _burnToZeroAddress(
                address(controlledSwap), amountBurn
                );
        }

    }

}