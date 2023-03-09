/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IPancakeSwapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeSwapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract SHIBO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFeeWallet;
    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 10000000 * 10**_decimals;
    uint256 private constant minSwap = 100 * 10**_decimals; //0.03% from 
    uint256 private constant onePercent = 100000 * 10**_decimals; //1% from 
    uint256 public maxTxAmount = onePercent * 2; //max Tx for first mins after launch
    uint256 private _tax;
    uint256 public buyTax = 5;
    uint256 public sellTax = 5;
    uint256 private launchBlock;
    uint256 private blockDelay = 2;
    string private constant _name = "Shibosis";
    string private constant _symbol = "SHIBO";

    IPancakeSwapV2Router02 private pancakeswapV2Router;
    address public pancakeswapV2Pair;
    address payable public marketingWallet;
    //Marketing Wallet = [0x69747664318Fa5AA21f178374b288be88CA3F50D] : Marketing wallet to be used when deploying , 

    bool private launch = false;

    constructor(address[] memory wallets) {
        //@ES: PancakeSwap V2 Router BSC mainnet address: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // @ES: PancakeSwap V2 Router BSC testnet address: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        

        pancakeswapV2Router = IPancakeSwapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        pancakeswapV2Pair = IPancakeSwapV2Factory(pancakeswapV2Router.factory()).createPair(address(this), pancakeswapV2Router.WETH());
        marketingWallet = payable(wallets[0]);
        _balance[msg.sender] = _totalSupply;
        for (uint256 i = 0; i < wallets.length; i++) {
            _isExcludedFromFeeWallet[wallets[i]] = true;
        }
        _isExcludedFromFeeWallet[msg.sender] = true;
        _isExcludedFromFeeWallet[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableTrading() external onlyOwner {
        launch = true;
        launchBlock = block.number;
    }

    function addExcludedWallet(address wallet) external onlyOwner {
        _isExcludedFromFeeWallet[wallet] = true;
    }

    function removeLimits() external onlyOwner {
        maxTxAmount = _totalSupply;
    }

    function newBlockDelay(uint256 number) external onlyOwner {
        blockDelay = number;
    }

    function changeTax(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }
    
    function _tokenTransfer(address from, address to, uint256 amount) private {
        uint256 taxTokens = (amount * _tax) / 100;
        uint256 transferAmount = amount - taxTokens;

        _balance[from] = _balance[from] - amount;
        _balance[to] = _balance[to] + transferAmount;
        _balance[address(this)] = _balance[address(this)] + taxTokens;
        emit Transfer(from, to, transferAmount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");

        if (_isExcludedFromFeeWallet[from] || _isExcludedFromFeeWallet[to]) {
            _tax = 0;
        } else {
            require(launch, "Wait till launch");
            require(amount <= maxTxAmount, "Max TxAmount 2% at launch");
            if (block.number < launchBlock + blockDelay) {_tax=99;} else {
                if (from == pancakeswapV2Pair) {
                    _tax = buyTax;
                } else if (to == pancakeswapV2Pair) {
                    uint256 tokensToSwap = balanceOf(address(this));
                    if (tokensToSwap > minSwap) {
                        if (tokensToSwap > onePercent) {
                            tokensToSwap = onePercent;
                        }
                        swapTokensForEth(tokensToSwap);
                    }
                    _tax = sellTax;
                } else {
                    _tax = 0;
                }
            }
        }
        _tokenTransfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);
        pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketingWallet,
            block.timestamp
        );
    }
    receive() external payable {}
}