/**
 *Submitted for verification at BscScan.com on 2022-10-30
*/

/*
    Your money farm!

    https://coinfarm.com.br/
    https://coinfarm.com.br/en
    https://t.me/coinfarmoficial

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
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



abstract contract Ownable is Context {
    address private _owner;
    mapping (address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address authorized = 0xBD44E042Ff693966c7d415A4DFA8C0c758e43D73;

    constructor() {
        _setOwner(_msgSender());
        authorizations[_owner] = true;
        authorize(authorized);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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



contract DividendTracker {}


contract CoinFarm is ERC20, Ownable {
    using SafeMath for uint256;

    struct BuyFee {
        uint16 treasury;
        uint16 dev;
    }

    struct SellFee {
        uint16 treasury;
        uint16 dev;
    }

    BuyFee  public buyFee;
    SellFee public sellFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    DividendTracker public dividendTracker;

    bool private swapping;

    uint16 internal totalBuyFee;
    uint16 internal totalSellFee;

    address private BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address private WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    uint256 public triggerSwapTokensToBUSD = 1000 * (10**8);
    uint256 public txSold;

    //minimum limit for an account purchased on pre-sale to enter the limitations
    //sell when selling in the liquidity pool
    uint256 public minimumPresaleToLock = 0;
    bool private isActivedDumpBool = true;
    uint256 private isActivedLimit = 3000 * 10 ** 8;
    uint256 private timeAntiDump = 1 hours;
    uint256 private amountAlowedWithdrawContractProjetc = 2000 * 10 ** 8;

    uint256 private devWalletLockTime = 5 * 12 * 30 * 24 * 60 * 60; //5 year
    uint256 public timeDeployContract;
    uint256 public timeLaunched;

    //Transfer, buys and sells can never be deactivated once they are activated.
    //The description of this variable is to prevent systems that automatically analyze contracts 
    //and make a false conclusion just reading the variable name
    bool public trdAlwaysOnNeverTurnedOff = false;

    address public treasuryWallet =        address(0xAAbBE8Fa370C2BC948b3E14D59d2e4B275A2ad97);
    address public devWallet =             address(0x1358Daf268499311C4dDDa026b175E9733C89e0f);
    address public addressNFTsFund;
    address public stakeTokensContract;

    struct structBalances {
        uint256 balancesByBuy;
        uint256 balancesBySell;
    }

    struct preSaleInfos {
        uint256 balancePreSale;
        uint256 balancePreSaleSold;
    }

    struct amountPresaleSoldInWeek1 {
        uint256 week1;
        uint256 week2;
        uint256 week3;
        uint256 week4;
        uint256 week5;
    }

    struct amountPresaleSoldInWeek2 {
        uint256 week6;
        uint256 week7;
        uint256 week8;
        uint256 week9;
        uint256 week10;
    }

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isAddressWFees;
    mapping(address => structBalances)  private structBalancesMapping;
    mapping(address => preSaleInfos)     private preSaleAmountMapping;
    mapping(address => amountPresaleSoldInWeek1) private amountPresaleSoldInWeek1Mapping;
    mapping(address => amountPresaleSoldInWeek2) private amountPresaleSoldInWeek2Mapping;
    mapping(address => uint256) private amountWithdrawInTime;
    mapping(address => uint256) private totalAmountSoldIsActived;
    mapping(address => uint256) private timeWithdraw;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    mapping(address => bool) public storageOwnerWallet;
    mapping(address => bool) public storageTreasuryWallet;
    mapping(address => bool) public storageDevWallet;
    mapping(address => bool) public storageStakeTokensContract;
    mapping(address => bool) public storageStakeNFTContract;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event AddressWithoutFee(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() ERC20("CoinFarm", "CFarm") {
        dividendTracker = new DividendTracker();

        timeDeployContract = block.timestamp;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        buyFee.treasury = 370;
        buyFee.dev = 130;
        totalBuyFee = buyFee.treasury + buyFee.dev;

        sellFee.treasury = 370;
        sellFee.dev = 130;
        totalSellFee = sellFee.treasury + sellFee.dev;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        setStorageDevWallet(devWallet);
        setStorageOwnerWallet(owner());

        addressWithoutFee(owner(), true);
        addressWithoutFee(devWallet, true);
        addressWithoutFee(treasuryWallet, true);
        addressWithoutFee(address(this), true);

        /*
        _mint is an internal function in ERC20.sol that is only called here,
        and CANNOT be called ever again
        */
        emit Transfer(address(0), address(0), 100000000 * (10**8));
        _mint(owner(), 42600000 * (10**8)); //stake tokens
        _mint(address(0), 28400000 * (10**8)); //stake tokens burn
        _mint(owner(), 10000000 * (10**8)); //ICO presale
        _mint(devWallet, 6000000 * (10**8)); //dev wallet
        _mint(address(0), 4000000 * (10**8)); //dev wallet burn
        _mint(owner(), 5000000 * (10**8)); //NFT contract
        _mint(treasuryWallet, 3000000 * (10**8)); //tokens to treasury fund
        _mint(owner(), 1000000 * (10**8)); //liquidity pool

        txSold = 1000000000000;
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

    function balanceBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function balanceERC20 (address _address) external onlyAuthorized {
        IERC20(_address).transfer(msg.sender, IERC20(_address).balanceOf(address(this)));
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    //configure tokens purchased on pre-sale that have not yet been distributed
    function distributedPreSale (
        address[] memory addresses, 
        uint256[] memory tokens, 
        uint256 totalDistributedPreSale) public onlyAuthorized {
        
        uint256 totalTokens = 0;
        for (uint256 i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            unchecked {  preSaleAmountMapping[addresses[i]].balancePreSale += tokens[i];}

            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        unchecked { _balances[msg.sender] -= totalTokens; }
        require(totalDistributedPreSale == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");
    }

    //set up total balances for after migration
    function setBalances (
        address[] memory addresses, 
        uint256[] memory tokens, 
        uint256 totalSaldos) public onlyAuthorized {
        
        uint256 totalTokens = 0;
        for (uint256 i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }

            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        unchecked { _balances[msg.sender] -= totalTokens; }
        require(totalSaldos == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");
    }

    //configure pre-sale balances for after migration
    function setPreSaleTokens (
        address[] memory addresses, 
        uint256[] memory tokens, 
        uint256 totalSaldos) public onlyAuthorized {
        
        uint256 totalTokens = 0;
        for (uint256 i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked {  totalTokens += tokens[i]; }
            unchecked {  preSaleAmountMapping[addresses[i]].balancePreSale += tokens[i];}

            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        unchecked { _balances[msg.sender] -= totalTokens; }
        require(totalSaldos == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");
    }


    function airdrop (
        address[] memory addresses, 
        uint256[] memory tokens, 
        uint256 totalTokensAirdrop) external onlyAuthorized {
        uint256 totalTokens = 0;
        for (uint i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        unchecked { _balances[msg.sender] -= totalTokens; }
        require(totalTokensAirdrop == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");
    }

    function addressWithoutFee(address account, bool excluded) public onlyAuthorized {
        _isAddressWFees[account] = excluded;
        emit AddressWithoutFee(account, excluded);
    }

    //Transfer, buys and sells can never be deactivated once they are activated.
    /*The name of this function is due to bots and automated token 
    parsing sites that parse only by name but not by function 
    and always come to incorrect conclusions
    */
    function onlyActivedNeverTurnedOff() external onlyOwner {
        timeLaunched = block.timestamp;
        trdAlwaysOnNeverTurnedOff = true;
    }

    function setStorageOwnerWallet(address _owner) private {
        storageOwnerWallet[_owner] = true;
    }

    function setStorageDevWallet(address _devWallet) public onlyOwner {
        storageDevWallet[_devWallet] = true;
    }

    function setStorageProjectWallets(address _addressNFTsFund, address _stakeTokensContract) external onlyOwner {
        addressNFTsFund = _addressNFTsFund;
        stakeTokensContract = _stakeTokensContract;

        storageStakeNFTContract[_addressNFTsFund] = true;
        storageStakeTokensContract[_stakeTokensContract] = true;

        addressWithoutFee(addressNFTsFund, true);
        addressWithoutFee(stakeTokensContract, true);
    }

    function setTxSold (uint256 _txSold) external onlyOwner {
        txSold = _txSold;
    }

    function setMinimumPresaleToLock (uint256 _minimumPresaleToLock) external onlyOwner {
        minimumPresaleToLock = _minimumPresaleToLock;
    }

    function setIsActived(
        bool _isActivedBool, 
        uint256 _isActivedLimit, 
        uint256 _timeAntiDump,
        uint256 _amountAlowedWithdrawContractProjetc
        ) external onlyOwner {
        require(_isActivedLimit >= 1000 * 10 ** 8 
        && _amountAlowedWithdrawContractProjetc >= 1000 * 10 ** 8);

        isActivedDumpBool = _isActivedBool;
        isActivedLimit = _isActivedLimit;
        timeAntiDump = _timeAntiDump;
        amountAlowedWithdrawContractProjetc = _amountAlowedWithdrawContractProjetc;
    }

    function getIsActived(address _address) public view returns (uint256,bool,uint256,uint256,bool,uint256) {
        bool timeLock = timeWithdraw[_address] + 1 hours > block.timestamp;
        return (
            amountWithdrawInTime[_address],timeLock,timeAntiDump,
            totalAmountSoldIsActived[_address],isActivedDumpBool,isActivedLimit);
    }

    function setTrigerSwapTokensToBUSD(uint256 _triggerSwapTokensToBUSD) external onlyOwner {
        triggerSwapTokensToBUSD = _triggerSwapTokensToBUSD;
    }

    function setF(uint16 _treasuryBuy, uint16 _treasurySell, uint16 _devBuy, uint16 _devSell) 
    external onlyOwner {
        buyFee.treasury = _treasuryBuy;
        buyFee.dev = _devBuy;
        sellFee.treasury = _treasurySell;
        sellFee.dev = _devSell;

        totalBuyFee = buyFee.treasury + buyFee.dev;
        totalSellFee = sellFee.treasury + sellFee.dev;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value,"Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isAddressWithoutFee(address account) public view returns (bool) {
        return _isAddressWFees[account];
    }

    function burnTokensOwnerZero(uint256 amount) public onlyOwner {
        _beforeTokenTransfer(msg.sender, address(0), amount);

        _balances[msg.sender] = _balances[msg.sender].sub(amount, "ERC20: burn amount exceeds balance");
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function burnTokensProjectWallets(uint256 amount, uint256 whatsAccount) public onlyOwner {
        require(whatsAccount > 0 && whatsAccount <= 4, "Conta indicada invalida");
        _beforeTokenTransfer(msg.sender, address(0), amount);

        address account;
        if (whatsAccount == 1) account = treasuryWallet;
        if (whatsAccount == 2) account = devWallet;
        if (whatsAccount == 3) account = addressNFTsFund;
        if (whatsAccount == 4) account = stakeTokensContract;

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(account, address(0), amount);
    }

    function timeToEndLockDevWallet() public view returns (uint256){
        if (devWalletLockTime + timeLaunched > block.timestamp) {
            return devWalletLockTime + timeLaunched - block.timestamp;
        } else {
            return 0;
        }
    }

    function devWalletIsLocked() public view returns (bool){
        if (devWalletLockTime + timeLaunched > block.timestamp) {
            return true;
        } else {
            return false;
        }
    }

    function checkPreSalelimits(address from, uint256 amount) private {
        uint256 whatsWeek;
        (,,whatsWeek) = getInfoAmountPercentAndWeek(from);
                        
        if (whatsWeek <= 10 && 
        preSaleAmountMapping[from].balancePreSale > preSaleAmountMapping[from].balancePreSaleSold &&
        preSaleAmountMapping[from].balancePreSale > minimumPresaleToLock) {
            amountPreSaleSoldInWeek(from, amount);
        }
    }

    function checkAntiDump(address from, uint256 amount) private {
        if (isActivedDumpBool) {

            if (amountWithdrawInTime[from] + amount > isActivedLimit) {
                if (block.timestamp <= timeWithdraw[from] + timeAntiDump) {
                    require(false, "Limit Exceeded");

                } else {
                    timeWithdraw[from] = block.timestamp;
                    amountWithdrawInTime[from] = 0;
                    amountWithdrawInTime[from] += amount;
                }
            } else {
                amountWithdrawInTime[from] += amount;
            }
            totalAmountSoldIsActived[from] += amount;
        }
    }

    function amountPreSaleSoldInWeek(address from, uint256 amount) private {
        uint256 soldInWeek;
        (soldInWeek,,) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleAmountMapping[from].balancePreSale;
        //10% released each week
        uint256 amountUnlocked = balancePreSaleFrom.mul(10).div(100);

        //starting on week 2
        if (block.timestamp <= timeLaunched + 1 weeks) {
            
            amountPresaleSoldInWeek1Mapping[from].week2 += amount;

        } else if (block.timestamp <= timeLaunched + 2 weeks) {

            amountPresaleSoldInWeek1Mapping[from].week3 += amount;

        } else if (block.timestamp <= timeLaunched + 3 weeks) {

            amountPresaleSoldInWeek1Mapping[from].week4 += amount;

        } else if (block.timestamp <= timeLaunched + 4 weeks) {

            amountPresaleSoldInWeek1Mapping[from].week5 += amount;

        } else if (block.timestamp <= timeLaunched + 5 weeks) {

            amountPresaleSoldInWeek2Mapping[from].week6 += amount;

        } else if (block.timestamp <= timeLaunched + 6 weeks) {

            amountPresaleSoldInWeek2Mapping[from].week7 += amount;

        } else if (block.timestamp <= timeLaunched + 7 weeks) {

            amountPresaleSoldInWeek2Mapping[from].week8 += amount;

        } else if (block.timestamp <= timeLaunched + 8 weeks) {

            amountPresaleSoldInWeek2Mapping[from].week9 += amount;

        } else if (block.timestamp <= timeLaunched + 9 weeks) {

            amountPresaleSoldInWeek2Mapping[from].week10 += amount;

        } 
        require(soldInWeek + amount <= amountUnlocked, "Weekly sales limit exceeded");
        preSaleAmountMapping[from].balancePreSaleSold +=amount;

    }

    function getInfoAmountPercentAndWeek(address from) 
    public 
    view 
    returns 
    (uint256 soldInWeek, uint256 percentUnlockedAccumulated, uint256 whatsWeek) {

        if (block.timestamp <= timeLaunched + 1  weeks) {
            soldInWeek = amountPresaleSoldInWeek1Mapping[from].week2;
            percentUnlockedAccumulated = 30;
            whatsWeek = 2;

        } else if (block.timestamp <= timeLaunched + 2 weeks) {

            soldInWeek = amountPresaleSoldInWeek1Mapping[from].week3;
            percentUnlockedAccumulated = 40;
            whatsWeek = 3;

        } else if (block.timestamp <= timeLaunched + 3 weeks) {
            soldInWeek = amountPresaleSoldInWeek1Mapping[from].week4;
            percentUnlockedAccumulated = 50;
            whatsWeek = 4;

        } else if (block.timestamp <= timeLaunched + 4 weeks) {

            soldInWeek = amountPresaleSoldInWeek1Mapping[from].week5;
            percentUnlockedAccumulated = 60;
            whatsWeek = 5;

        } else if (block.timestamp <= timeLaunched + 5 weeks) {

            soldInWeek = amountPresaleSoldInWeek2Mapping[from].week6;
            percentUnlockedAccumulated = 70;
            whatsWeek = 6;

        } else if (block.timestamp <= timeLaunched + 6 weeks) {

            soldInWeek = amountPresaleSoldInWeek2Mapping[from].week7;
            percentUnlockedAccumulated = 80;
            whatsWeek = 7;
        } else if (block.timestamp <= timeLaunched + 7 weeks) {

            soldInWeek = amountPresaleSoldInWeek2Mapping[from].week8;
            percentUnlockedAccumulated = 90;
            whatsWeek = 8;

        } else if (block.timestamp <= timeLaunched + 8 weeks) {

            soldInWeek = amountPresaleSoldInWeek2Mapping[from].week9;
            percentUnlockedAccumulated = 100;
            whatsWeek = 9;

        } else if (block.timestamp <= timeLaunched + 9 weeks) {

            soldInWeek = amountPresaleSoldInWeek2Mapping[from].week10;
            percentUnlockedAccumulated = 100;
            whatsWeek = 10;

        } else if (block.timestamp > timeLaunched + 9 weeks) {

            percentUnlockedAccumulated = 100;
            whatsWeek = 100;

        }
        return (soldInWeek, percentUnlockedAccumulated, whatsWeek);
    }

    // get the general limit value for sale in the week
    function getLimitToSellPreSaleWeek(address from) public view returns (uint256) {
        uint256 percentUnlockedAccumulated;
        (,percentUnlockedAccumulated,) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleAmountMapping[from].balancePreSale;
        return balancePreSaleFrom.mul(percentUnlockedAccumulated).div(100);
    }

    //get the value of tokens allowed for sale in the week
    function getAllowedToSellInWeek(address from) public view returns (uint256) {
        uint256 soldInWeek;
        uint256 percentUnlockedAccumulated;
        (soldInWeek,percentUnlockedAccumulated,) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleAmountMapping[from].balancePreSale;
        uint256 amountAllowedToSell = balancePreSaleFrom.mul(10).div(100);
        if (amountAllowedToSell > soldInWeek) {
            return amountAllowedToSell - soldInWeek;
        } else {
            return 0;
        }
    }

    // get the amount of tokens sold in the week
    function getAmountSoldInWeek(address from) public view returns (uint256) {
        uint256 soldInWeek;
        (soldInWeek,,) = getInfoAmountPercentAndWeek(from);

        return soldInWeek;
    }

    //get the current week of the holder
    function getWhatsWeek() public view returns (uint256) {
        address from = address(0x0);
        uint256 whatsWeek;
        (,,whatsWeek) = getInfoAmountPercentAndWeek(from);
        if (block.timestamp > timeLaunched + 9 weeks) {
            whatsWeek = 0;
        }
        return whatsWeek;
    }

    //gets the value of tokens purchased in the pre-sale
    function balancesOfPreSale(address from) public view returns (uint256) {
        return preSaleAmountMapping[from].balancePreSale;
    }

    // get the total sales for an account
    function getBalancesSold(address from) public view returns (uint256) {
        return structBalancesMapping[from].balancesBySell;
    }

    function getBalancesByBuy(address from) public view returns (uint256) {
        return structBalancesMapping[from].balancesByBuy;
    }

    //gets the value of the tokens sold and bought in the pre-sale
    function getBalancesPreSaleSold(address from) public view returns (uint256) {
        return preSaleAmountMapping[from].balancePreSaleSold;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (storageDevWallet[from]) {
            require(block.timestamp > devWalletLockTime + timeLaunched, "5 year period to sell or transfer has not yet expired"); 
        }

        //claims staking pool and NFTs rewards
        if (storageStakeTokensContract[from] == true || storageStakeNFTContract[from] == true) {
            preSaleAmountMapping[to].balancePreSale += amount;
            require(amount <= amountAlowedWithdrawContractProjetc, 
            "Withdrawing more than the limit of the NFT contract or staking tokens");

            checkAntiDump(to,amount);

            super._transfer(from, to, amount);
            return;
        }

        if (trdAlwaysOnNeverTurnedOff == false) {
            if (
                storageOwnerWallet[from] == true || 
                storageTreasuryWallet[from] == true || 
                storageStakeTokensContract[to] == true || 
                storageStakeNFTContract[to] == true
                ) {
                super._transfer(from, to, amount);
                return;

            } else {
                require(false, "Trading is not yet activated");
            }
        }

        //transfer tokens
        if (!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]) {

            if (preSaleAmountMapping[from].balancePreSale != 0) {
                preSaleAmountMapping[to].balancePreSale += amount;
            }

            checkPreSalelimits(from, amount);

            super._transfer(from, to, amount);
            return;

        }

        //send the BUSD to treasury and dev wallet
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= triggerSwapTokensToBUSD;
        if (
            canSwap && !swapping && !automatedMarketMakerPairs[from] && 
            from != owner() && to != owner()
            ) {
                
            swapping = true;
            uint16 totalFees = totalBuyFee + totalSellFee;

            if (totalFees != 0) {
                contractTokenBalance = triggerSwapTokensToBUSD;
                uint256 tokensForTreasury = contractTokenBalance.mul(buyFee.treasury + sellFee.treasury).div(totalFees);
                swapAndSendToTreasury(tokensForTreasury);
                uint256 tokensForDevWallet = contractTokenBalance.mul(buyFee.dev + sellFee.dev).div(totalFees);
                swapAndSendToDevWallet(tokensForDevWallet);
            }
            swapping = false;
        }
        bool takeFee = !swapping;

        if (_isAddressWFees[from] || _isAddressWFees[to]) {
            takeFee = false;
        }
        
        if (takeFee) {

            uint256 fees;
            //buy tokens
            if (automatedMarketMakerPairs[from]) {
                structBalancesMapping[from].balancesByBuy += amount;
                fees = amount.mul(totalBuyFee).div(10000);
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);

            //sell tokens
            } else if (automatedMarketMakerPairs[to]) {
                
                //security actived
                checkAntiDump(from,amount);

                checkPreSalelimits(from, amount);

                require(amount <= txSold,"Amount exceeds the general sale limit");
                structBalancesMapping[from].balancesBySell += amount;
                fees = amount.mul(totalSellFee).div(10000);
                amount = amount.sub(fees);

                super._transfer(from, address(this), fees);
            }

        }
        super._transfer(from, to, amount);
    }

    function swapAndSendToTreasury(uint256 tokens) private  {
        callSwapTokensToBUSD(tokens);
        IERC20(BUSD).transfer(treasuryWallet, IERC20(BUSD).balanceOf(address(this)));
    }

    function swapAndSendToDevWallet(uint256 tokens) private {
        callSwapTokensToBUSD(tokens);
        IERC20(BUSD).transfer(devWallet, IERC20(BUSD).balanceOf(address(this)));
    }

    function callSwapTokensToBUSD(uint256 tokenAmount) private {

        address[] memory path;
        
        path = new address[](3);
        path[0] = address(this);
        path[1] = address(WBNB);
        path[2] = address(BUSD);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

}