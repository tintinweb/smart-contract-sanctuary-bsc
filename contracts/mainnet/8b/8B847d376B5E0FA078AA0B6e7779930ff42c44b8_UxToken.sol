/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

pragma solidity >=0.6.0 <0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}





pragma solidity >=0.6.0 <0.8.0;


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





pragma solidity >=0.6.0 <0.8.0;


library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        
        
        
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}





pragma solidity >=0.6.0 <0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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





pragma solidity >=0.6.0 <0.8.0;

interface IUniswapRouter01 {
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





pragma solidity >=0.6.0 <0.8.0;


interface IUniswapRouter02 is IUniswapRouter01 {
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





pragma solidity >=0.6.0 <0.8.0;

interface IUniswapFactory {
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





pragma solidity >=0.6.0 <0.8.0;


interface IUxRefer {

    function referee(address account) external view returns (address);

    function refers(address account) external view returns (address[] memory);
}


pragma solidity >=0.6.0 <0.8.0;

contract UxToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public constant MAX = ~uint256(0);
    address public constant HOLE =
        address(0x000000000000000000000000000000000000dEaD);

    
    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) private _fromBlackList;
    mapping(address => bool) private _fromWhiteList;
    mapping(address => bool) private _toBlackList;
    mapping(address => bool) private _toWhiteList;

    
    uint256 public constant RATE_PRECISION = 1000;
    uint256 private _tradeRewardLpRate = 30; 
    uint256 private _tradeDaoRate = 15; 
    uint256 private _tradeRewardRate = 5; 
    uint256 private _transferFeeRate = 20; 
    
    address private _tradeFeeRewardLpAddr;
    
    address private _tradeFeeDaoAddr;
    
    address private _transferFeeAddr =
        address(0x000000000000000000000000000000000000dEaD);

    address private _root;

    
    uint256 private _minTransfer = 0;
    
    uint256 private _sellRateLimit = 1000;

    uint256 private _rebateRewardRequireAmount; 

    address private _usdt;
    address private _router;
    address private _defaultPair;

    address private _iuxRefer;

    
    mapping(address => bool) private _automatedMarketMakerPairs;

    
    constructor(
        string memory name_,
        string memory symbol_,
        address tradeFeeRewardLpAddr_,
        address tradeFeeDaoAddr_,
        address root_,
        address usdt_,
        address router_
    ) public {
        _name = name_;
        _symbol = symbol_;
        _tradeFeeRewardLpAddr = tradeFeeRewardLpAddr_;
        _tradeFeeDaoAddr = tradeFeeDaoAddr_;
        _root = root_;
        _decimals = 18;
        _usdt = usdt_;
        _router = router_;

        _defaultPair = IUniswapFactory(IUniswapRouter02(_router).factory())
            .createPair(address(this), _usdt);

        _mint(_msgSender(), 21 * 10**(uint256(_decimals) + 5));

        _setAutomatedMarketMakerPair(_defaultPair, true);
        _ctl(_defaultPair, 3);
        addFeeWhiteList(address(this), true);
    }

    function _ctl(address pair, uint256 mode) private {
        if (mode == 0) {
            
            _fromBlackList[pair] = true;
            _toBlackList[pair] = true;
        } else if (mode == 1) {
            
            _fromBlackList[pair] = false;
            _toBlackList[pair] = false;
        } else if (mode == 2) {
            
            _fromBlackList[pair] = true;
            _toBlackList[pair] = false;
        } else if (mode == 3) {
            
            _fromBlackList[pair] = false;
            _toBlackList[pair] = true;
        }
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        if (_automatedMarketMakerPairs[pair] == value) {
            return;
        }
        _automatedMarketMakerPairs[pair] = value;
    }

    function automatedMarketMakerPairs(address pair)
        public
        view
        returns (bool)
    {
        return _automatedMarketMakerPairs[pair];
    }

    
    function name() public view virtual returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount >= _minTransfer, "less than min transfer limit");

        
        require(
            !_fromBlackList[sender] || _toWhiteList[recipient],
            "ERC20: transfer refuse by sender"
        );
        require(
            !_toBlackList[recipient] || _fromWhiteList[sender],
            "ERC20: transfer refuse by recipient"
        );

        uint256 fee = 0;
        bool takeFee = !isFeeWhiteList(sender) && !isFeeWhiteList(recipient);

        if (
            automatedMarketMakerPairs(sender) ||
            automatedMarketMakerPairs(recipient)
        ) {
            if (takeFee) {
                if (automatedMarketMakerPairs(recipient)) {
                    if (_sellRateLimit < RATE_PRECISION) {
                        require(
                            amount <=
                                balanceOf(sender).mul(_sellRateLimit).div(
                                    RATE_PRECISION
                                ),
                            "ERC20: sell limit"
                        );
                    }
                }
                uint256 tradeRewardLpFee = amount.mul(_tradeRewardLpRate).div(RATE_PRECISION);
                uint256 tradeDaoFee = amount.mul(_tradeDaoRate).div(RATE_PRECISION);
                uint256 tradeRewardFee = amount.mul(_tradeRewardRate).div(RATE_PRECISION);
                fee = tradeRewardLpFee.add(tradeDaoFee).add(tradeRewardFee);
                
                _tokenTransfer(sender, _tradeFeeDaoAddr, tradeDaoFee);
                _tokenTransfer(sender, _tradeFeeRewardLpAddr, tradeRewardLpFee);
                
                _tokenTransfer(sender, address(this), tradeRewardFee);
                address user = _automatedMarketMakerPairs[sender] ? recipient : sender;
                _rebate(user, tradeRewardFee);
            }
        } else {
            if (takeFee) {
                fee = amount.mul(_transferFeeRate).div(RATE_PRECISION);
                _tokenTransfer(sender, _transferFeeAddr, fee);
            }
        }
        _tokenTransfer(sender, recipient, amount.sub(fee));
    }

    
    function _rebate(address user, uint256 amount) private {
        if (_iuxRefer == address(0)) {
            
            _tokenTransfer(address(this), _root, amount);
            return;
        }

        address index = IUxRefer(_iuxRefer).referee(user);
        uint256 use = 0;
        for (uint256 i = 1; i <= 2; i++) {
            if (index == address(0)) {
                break;
            }
            if (balanceOf(index) < _rebateRewardRequireAmount || _fromBlackList[index] || _toBlackList[index])
            {
                index = IUxRefer(_iuxRefer).referee(index);
                continue;
            }
            uint256 reward = amount.div(2);
            _tokenTransfer(address(this), index, reward);
            use = use.add(reward);
            index = IUxRefer(_iuxRefer).referee(index); 
        }
        if (amount > use) {
            uint256 tmp = amount.sub(use);
            _tokenTransfer(address(this), _root, tmp);
        }
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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

    
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function tradeRewardLpRate() public view returns (uint256) {
        return _tradeRewardLpRate;
    }
    function setTradeRewardLpRate(uint256 tradeRewardLpRate_) public onlyOwner {
        _tradeRewardLpRate = tradeRewardLpRate_;
    }

    function tradeDaoRate() public view returns (uint256) {
        return _tradeDaoRate;
    }
    function setTradeDaoRate(uint256 tradeDaoRate_) public onlyOwner {
        _tradeDaoRate = tradeDaoRate_;
    }

    function tradeRewardRate() public view returns (uint256) {
        return _tradeRewardRate;
    }
    function setTradeRewardRate(uint256 tradeRewardRate_) public onlyOwner {
        _tradeRewardRate = tradeRewardRate_;
    }

    function transferFeeRate() public view returns (uint256) {
        return _transferFeeRate;
    }

    function setTransferFeeRate(uint256 transferFeeRate_) public onlyOwner {
        _transferFeeRate = transferFeeRate_;
    }

    function minTransfer() public view returns (uint256) {
        return _minTransfer;
    }

    function setMinTransfer(uint256 minTransfer_) public onlyOwner {
        _minTransfer = minTransfer_;
    }

    
    function addToWhiteList(address who, bool status) public onlyOwner {
        _toWhiteList[who] = status;
    }

    function isToWhiteList(address who) public view returns (bool) {
        return _toWhiteList[who];
    }

    function addMultipleToWhiteList(address[] calldata accounts, bool status)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _toWhiteList[accounts[i]] = status;
        }
    }

    function addFromBlackList(address who, bool status) public onlyOwner {
        _fromBlackList[who] = status;
    }

    function isFromBlackList(address who) public view returns (bool) {
        return _fromBlackList[who];
    }

    function addMultipleFromBlackList(address[] calldata accounts, bool status)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _fromBlackList[accounts[i]] = status;
        }
    }

    function addToBlackList(address who, bool status) public onlyOwner {
        _toBlackList[who] = status;
    }

    function isToBlackList(address who) public view returns (bool) {
        return _toBlackList[who];
    }

    function addMultipleToBlackList(address[] calldata accounts, bool status)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _toBlackList[accounts[i]] = status;
        }
    }

    function addFromWhiteList(address who, bool status) public onlyOwner {
        _fromWhiteList[who] = status;
    }

    function isFromWhiteList(address who) public view returns (bool) {
        return _fromWhiteList[who];
    }

    function addMultipleFromWhiteList(address[] calldata accounts, bool status)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _fromWhiteList[accounts[i]] = status;
        }
    }

    function addFeeWhiteList(address who, bool status) public onlyOwner {
        _feeWhiteList[who] = status;
    }

    function isFeeWhiteList(address who) public view returns (bool) {
        return _feeWhiteList[who];
    }

    function addMultipleFeeWhiteList(address[] calldata accounts, bool status)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = status;
        }
    }

    function rebateRewardRequireAmount() public view returns (uint256) {
        return _rebateRewardRequireAmount;
    }
    function setRebateRewardRequireAmount(uint256 rebateRewardRequireAmount_) public onlyOwner {
        _rebateRewardRequireAmount = rebateRewardRequireAmount_;
    }

    function sellRateLimit() public view returns (uint256) {
        return _sellRateLimit;
    }
    function setSellRateLimit(uint256 sellRateLimit_) external onlyOwner {
        _sellRateLimit = sellRateLimit_;
    }

    function tradeFeeRewardLpAddr() public view returns (address) {
        return _tradeFeeRewardLpAddr;
    }
    function setTradeFeeRewardLpAddr(address tradeFeeRewardLpAddr_) external onlyOwner {
        _tradeFeeRewardLpAddr = tradeFeeRewardLpAddr_;
    }

    function tradeFeeDaoAddr() public view returns (address) {
        return _tradeFeeDaoAddr;
    }
    function setTradeFeeDaoAddr(address tradeFeeDaoAddr_) external onlyOwner {
        _tradeFeeDaoAddr = tradeFeeDaoAddr_;
    }

    function root() public view returns (address) {
        return _root;
    }
    function setRoot(address root_) public onlyOwner {
        _root = root_;
    }

    function transferFeeAddr() public view returns (address) {
        return _transferFeeAddr;
    }

    function setTransferFeeAddr(address transferFeeAddr_) external onlyOwner {
        _transferFeeAddr = transferFeeAddr_;
    }

    function ctl(address pair, uint256 mode) external onlyOwner {
        _ctl(pair, mode);
    }

    function defaultPair() public view returns (address) {
        return _defaultPair;
    }

    function setDefaultPair(address defaultPair_) external onlyOwner {
        _defaultPair = defaultPair_;
    }

    function setIUxRefer(address iuxRefer_) external onlyOwner {
        _iuxRefer = iuxRefer_;
    }

    function iuxRefer() external view returns (address) {
        return _iuxRefer;
    }
}