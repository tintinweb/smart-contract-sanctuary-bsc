/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

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

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

contract WagmiToken is ERC20, Ownable {
    address public  uniswapV2Pair;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => uint256) private _lastBuyBlock;

    uint256 public burnFeeOnBuy;
    uint256 public burnFeeOnSell;

    uint256 public projectFeeOnBuy;
    uint256 public projectFeeOnSell;

    uint256 public walletToWalletBurnFee;

    address public projectWallet;

    bool    public antibotEnabled;
    uint256 public botPriceImpactTreshold;

    event AntibotStatusChanged(bool enabled);
    event BotPriceImpactTresholdChanged(uint256 botPriceImpactTreshold);
    event BuyFeesUpdated(uint256 burnFeeOnBuy, uint256 projectFeeOnBuy);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ProjectWalletChanged(address projectWallet);
    event SellFeesUpdated(uint256 burnFeeOnSell, uint256 projectFeeOnSell);
    event WalletToWalletBurnFeeUpdated(uint256 walletToWalletBurnFee);
    event TokenCreated(address indexed owner, address indexed token);

    struct ConstructorArgument {
        string  name_;
        string  symbol_;
        uint256 totalSupply_;
        address router_;
        uint256 burnFeeOnBuy_;
        uint256 burnFeeOnSell_;
        uint256 projectFeeOnBuy_;
        uint256 projectFeeOnSell_;
        uint256 walletToWalletBurnFee_;
        address projectWallet_;
        bool    antibotEnabled_;
        uint256 botPriceImpactTreshold_;
        uint256 serviceFee_;
        address serviceFeeReceiver_;
    }

    constructor (
        ConstructorArgument memory arg
        ) payable ERC20(arg.name_, arg.symbol_) 
    {   
        require(arg.burnFeeOnBuy_ + arg.projectFeeOnBuy_ <= 5, "Buy fees cannot be more than 5%");
        require(arg.burnFeeOnSell_ + arg.projectFeeOnSell_ <= 5, "Sell fees cannot be more than 5%");
        require(arg.walletToWalletBurnFee_ <= 5, "Wallet to wallet burn fee cannot be more than 5%");
        require(arg.projectWallet_ != address(0), "Project wallet cannot be zero address");
        require(arg.botPriceImpactTreshold_ > 0, "Bot price impact treshold cannot be zero");

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(arg.router_);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Pair = _uniswapV2Pair;

        burnFeeOnBuy  = arg.burnFeeOnBuy_;
        burnFeeOnSell = arg.burnFeeOnSell_;
        
        projectFeeOnBuy  = arg.projectFeeOnBuy_;
        projectFeeOnSell = arg.projectFeeOnSell_;
        
        walletToWalletBurnFee = arg.walletToWalletBurnFee_;

        projectWallet = arg.projectWallet_;

        antibotEnabled = arg.antibotEnabled_;
        botPriceImpactTreshold = arg.botPriceImpactTreshold_;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(0xdead)]  = true;
        _isExcludedFromFees[address(this)] = true;

        _mint(owner(), arg.totalSupply_ * (10 ** 18));

        payable(arg.serviceFeeReceiver_).transfer(arg.serviceFee_);

        emit TokenCreated(owner(), address(this));
    }

    receive ( ) external payable { }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already set to that state");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function getLastBuyBlock(address account) public view returns(uint256) {
        return _lastBuyBlock[account];
    }

    function setBuyFees(uint256 _burnFeeOnBuy, uint256 _projectFeeOnBuy) external onlyOwner {
        require(_burnFeeOnBuy + _projectFeeOnBuy <= 5, "Buy fees cannot be more than 5%");
        
        burnFeeOnBuy    = _burnFeeOnBuy;
        projectFeeOnBuy = _projectFeeOnBuy;

        emit BuyFeesUpdated(burnFeeOnBuy, projectFeeOnBuy);
    }

    function setSellFees(uint256 _burnFeeOnSell, uint256 _projectFeeOnSell) external onlyOwner {
        require(_burnFeeOnSell + _projectFeeOnSell <= 5, "Sell fees cannot be more than 5%");
        
        burnFeeOnSell    = _burnFeeOnSell;
        projectFeeOnSell = _projectFeeOnSell;

        emit SellFeesUpdated(burnFeeOnSell, projectFeeOnSell);
    }

    function setWalletToWalletBurnFee(uint256 _walletToWalletBurnFee) external onlyOwner {
        require(_walletToWalletBurnFee <= 5, "Wallet to wallet burn fee cannot be more than 5%");
        
        walletToWalletBurnFee = _walletToWalletBurnFee;

        emit WalletToWalletBurnFeeUpdated(walletToWalletBurnFee);
    }

    function setProjectWallet(address _projectWallet) external onlyOwner {
        require(_projectWallet != address(0), "Project wallet cannot be zero address");
        require(_projectWallet != projectWallet, "Project wallet is already set to that address");
        
        projectWallet = _projectWallet;

        emit ProjectWalletChanged(projectWallet);
    }

    function setAntibotEnabled(bool _antibotEnabled) external onlyOwner {
        require(antibotEnabled != _antibotEnabled, "Antibot is already set to that state");

        antibotEnabled = _antibotEnabled;

        emit AntibotStatusChanged(antibotEnabled);
    }

    function setAntibotPriceImpactTreshold(uint256 _botPriceImpactTreshold) external onlyOwner {
        require(botPriceImpactTreshold != _botPriceImpactTreshold, "Bot price impact treshold is already set to that value");
        require(_botPriceImpactTreshold > 0, "Bot price impact cannot be zero");

        botPriceImpactTreshold = _botPriceImpactTreshold;

        emit BotPriceImpactTresholdChanged(botPriceImpactTreshold);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal  override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(block.number > _lastBuyBlock[from], "You cannot transfer tokens in the same block after buying");
       
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (from == uniswapV2Pair && antibotEnabled) {
            uint256 _priceImpact = (amount * 100) / (balanceOf(uniswapV2Pair) + amount);
            if(_priceImpact >= botPriceImpactTreshold) {
                _lastBuyBlock[to] = block.number;
            }
        }

        bool takeFee = true;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            if (from == uniswapV2Pair) {
                uint256 burnTokens    = (amount * burnFeeOnBuy) / 100;
                super._burn(from, burnTokens);

                uint256 projectTokens = (amount * projectFeeOnBuy) / 100;                
                super._transfer(from, projectWallet, projectTokens);
                
                amount -= burnTokens + projectTokens;
            } else if (to == uniswapV2Pair) {
                uint256 burnTokens    = (amount * burnFeeOnSell) / 100;
                super._burn(from, burnTokens);

                uint256 projectTokens = (amount * projectFeeOnSell) / 100;
                super._transfer(from, projectWallet, projectTokens);

                amount -= burnTokens + projectTokens;
            } else {
                uint256 burnTokens = (amount * walletToWalletBurnFee) / 100;
                super._burn(from, burnTokens);
                amount -= burnTokens;
            }
        } 

        super._transfer(from, to, amount);
    }
}