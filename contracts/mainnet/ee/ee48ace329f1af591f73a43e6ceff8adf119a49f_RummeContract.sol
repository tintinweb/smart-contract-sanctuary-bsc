/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

/*
╔■□■□■■□■□■■□■□■□■■■□■□■□■■■□■□■□■■■□■□■□■□■■□■□■■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■╗
║                                                                                                               ║
║  ██████  ██    ██ ███    ███ ███    ███ ███████ ██    ██ ███████ ████████  ██████  ██   ██ ███████ ███    ██  ║
║  ██   ██ ██    ██ ████  ████ ████  ████ ██      ██    ██ ██         ██    ██    ██ ██  ██  ██      ████   ██  ║
║  ██████  ██    ██ ██ ████ ██ ██ ████ ██ █████   ██    ██ ███████    ██    ██    ██ █████   █████   ██ ██  ██  ║
║  ██   ██ ██    ██ ██  ██  ██ ██  ██  ██ ██      ██    ██      ██    ██    ██    ██ ██  ██  ██      ██  ██ ██  ║
║  ██   ██  ██████  ██      ██ ██      ██ ███████  ██████  ███████    ██     ██████  ██   ██ ███████ ██   ████  ║
║                                                                                                               ║
╚■□■□■■□■□■■□■□■□■■■□■□■□■■■□■□■□■■■□■□■□■□■■□■□■■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■╝
╔■□■□■■□■□■■□■□■□■■■□■□■□■■■□■□■□■■■□■□■□■□■■□■□■■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■╗

                         | RUMMEUS Token / RUMME |   ↳ New World of Future CryptoCurrency ⚡️                    
                                                                                                                
         🔰║🌐〚 rummeustoken.com 〛 💻 ║🔰   💬 [email protected] 📧 📱 Telegram: https://t.me/rummeustoken     
                                                                                                               
╚■□■□■■□■□■■□■□■□■■■□■□■□■■■□■□■□■■■□■□■□■□■■□■□■■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■□■□■□■■□■□■■□■□■╝
*/

// SPDX-License-Identifier: MIT


pragma solidity >=0.6.2;

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


pragma solidity >=0.6.2;

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


pragma solidity >=0.5.0;

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


pragma solidity ^0.8.0;

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

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
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

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


pragma solidity ^0.8.0;

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

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

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


pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

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
        return 9;
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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
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


pragma solidity ^0.8.6;

contract RummeContract is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    
    struct BuyFee{
        uint16 projectFee;
        uint16 teamFee;
    }

    struct SellFee{
        uint16 projectFee;
        uint16 teamFee;
    }

    BuyFee public buyFee;
    SellFee public sellFee;

    bool private swapping;
    bool private isTradingEnabled;
    bool public swapEnabled;

    address private constant deadWallet = address(0xdead);

    uint256 public swapTokensAtAmount = 1 * 10**6 * (10**9);

    uint256 public _maxTxAmount = 5000000 * 10**6 * 10**9;

    uint16 private totalBuyFee;
    uint16 private totalSellFee;

    address public _teamWalletAddress = address(0xD674d84Ba733FFf434422f8737c7E4F1bFaBE2B4); // Team 
    address public _projectWalletAddress = address(0x4E231e5C49D9a584f34841Aeb99EFAfD683ab849); //Project 

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isBlacklisted;

    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event SwapAndSend(
        uint256 tokens,
        uint256 balance,
        uint256 projectShare
    );


    constructor() ERC20("RummeusToken", "RUMME") {

    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PCS V2 ROUTER
 
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        buyFee.projectFee = 80; // 8%
        buyFee.teamFee = 30;  // 3% 
        totalBuyFee = buyFee.projectFee + buyFee.teamFee;

        sellFee.projectFee = 90; // 9% 
        sellFee.teamFee = 70;   // 7% 
        totalSellFee = sellFee.projectFee + sellFee.teamFee;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        excludeFromFees(owner(), true);
        excludeFromFees(_teamWalletAddress, true);
        excludeFromFees(address(this), true);

        swapEnabled = true;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */

        _mint(owner(),   100000 * 10**9 * 10**9);
    
    }

    receive() external payable {

  	}

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function setSwapTokensAmt(uint256 amt) external onlyOwner{
        swapTokensAtAmount = amt;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }

    function setTeamWallet(address payable wallet) external onlyOwner{
        _teamWalletAddress = wallet;
    }

    function setProjectWallet(address payable wallet) external onlyOwner{
        _projectWalletAddress = wallet;
    }

    function setBuyFee(uint16 liqFee, uint16 team) external onlyOwner {
        buyFee.projectFee = liqFee;
        buyFee.teamFee = team;
        totalBuyFee = buyFee.projectFee + buyFee.teamFee;
    }

    function setSellFee(uint16 liqFee, uint16 team) external onlyOwner {
        sellFee.projectFee = liqFee;
        sellFee.teamFee = team;
        totalSellFee = sellFee.projectFee + sellFee.teamFee;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function setSwapEnabled(bool value) external onlyOwner{
        swapEnabled = value;
    }

   function setMaxTxMount(uint256 maxTxValue) external onlyOwner() {
        _maxTxAmount = maxTxValue;      
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        
         if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

	    
        uint256 contractTokenBalance = balanceOf(address(this));

        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
    
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            swapEnabled &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;

            swapAndSend(contractTokenBalance);

            swapping = false;
        }

        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {

            uint16 totalFee;

            if(automatedMarketMakerPairs[from]){
                totalFee = totalBuyFee;
            }else if(automatedMarketMakerPairs[to]){
                totalFee = totalSellFee;
            }

        	uint256 fees = amount.mul(totalFee).div(1000);
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);

        }

        super._transfer(from, to, amount);

    }

    function swapAndSend(uint256 tokens) private {

        uint256 totalFees = totalBuyFee + totalSellFee;

  
        swapTokensForEth(tokens); 

        uint256 newBalance = address(this).balance;

        uint256 projectShare = newBalance.mul(buyFee.projectFee + sellFee.projectFee).div(totalFees);

        payable(_projectWalletAddress).transfer(projectShare);

        payable(_teamWalletAddress).transfer(address(this).balance);

        emit SwapAndSend(tokens, newBalance, projectShare);
    }


    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

       
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );

    }

}