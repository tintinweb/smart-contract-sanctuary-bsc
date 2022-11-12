/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

pragma solidity ^0.8.4;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

enum TokenType {
    standard,
    antiBotStandard,
    liquidityGenerator,
    antiBotLiquidityGenerator,
    baby,
    antiBotBaby,
    buybackBaby,
    antiBotBuybackBaby
}

abstract contract BaseToken {
    event TokenCreated(
        address indexed owner,
        address indexed token,
        TokenType tokenType,
        uint256 version
    );
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract StandardToken is IERC20, Ownable, BaseToken {
    using SafeMath for uint256;

    uint256 public constant VERSION = 1;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    address public _burnTaxAddr = address(0x000000000000000000000000000000000000dEaD);  

    address public _glTaxAddr = address(0x6E215e9785a31C08996905d96048Ddd11318938e);  

    address public _lcTaxAddr = address(0x69cb04C9CFb7d8eE0E06d1CEdFc4F99BD85749C0);

    address public _nftTaxAddr = address(0xC893C932106687f81470CaEfCB60ED6BCD83986f);

    address public _yxTaxAddr = address(0x7541638AaaBb7cD0902Eac661C75eB4F57448984);

    address public _jxTaxAddr = address(0xc063c3E8EbcDB4BA3944ed7DE7D7cc9381A96dCF);

    mapping (address => address) public inviter;




    uint256 private _burnTaxFee = 2;  

    uint256 private _glTaxFee = 2;  

    uint256 private _lcTaxFee = 1;

    uint256 private _nftTaxFee = 1;

    uint256 private _yxTaxFee = 1;

    uint256 private _jxTaxFee = 2;

    address public uniswapPair;
    IUniswapV2Router02 public uniswapV2Router;
    address public liquid_contract = 0x55d398326f99059fF775485246999027B3197955;
    address public swapRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public First;
    uint256 public kill = 300;

    mapping(address => bool) public _isWklisted;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    )  {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(owner(), totalSupply_);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(swapRouterAddr);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), liquid_contract);
        uniswapV2Router = _uniswapV2Router;
        uniswapPair = _uniswapV2Pair;

        emit TokenCreated(owner(), address(this), TokenType.standard, VERSION);

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

    function calculateburnTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnTaxFee).div(100);
    }

    function calculateglTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_glTaxFee).div(100);
    }

    function calculatelcTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lcTaxFee).div(100);
    }

    function calculatenftTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_nftTaxFee).div(100);
    }

    function calculateyxTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_yxTaxFee).div(100);
    }

    function calculatejxTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_jxTaxFee).div(100);
    }    

    function excludeFromWklisted(address  account) public onlyOwner {
        _isWklisted[account] = false;            
    }
    
    function includeFromWklisted(address  account) public onlyOwner {
        _isWklisted[account] = true;     
    }

    function setKings(uint256 _kill) external onlyOwner {
        kill = _kill;
    }

    function wklistedType(address account) public view returns(bool) {
        return _isWklisted[account];
    }

    function setInviter(address a1, address a2) public onlyOwner{
        require(a1 != address(0));
        inviter[a1] = a2;
    }

     function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(recipient == uniswapPair && balanceOf(address(uniswapPair)) == 0){
            First = block.number;
        }
        if(block.number < First + kill && balanceOf(address(uniswapPair)) != 0){
            if( sender == uniswapPair  && !_isWklisted[recipient]){
                require(sender == address(0), "ERC20: error");
            }
            if( recipient == uniswapPair  && !_isWklisted[sender]){
                require(sender == address(0), "ERC20: error");
            }
        }

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );


        //计算手续费
        uint256 tTransferAmount = amount;
        if (!_isWklisted[sender] &&  !_isWklisted[recipient]){
            uint256 burnFee  = calculateburnTaxFee(amount);
            uint256 glFee  = calculateglTaxFee(amount);
            uint256 lcFee  = calculatelcTaxFee(amount);
            uint256 nftFee  = calculatenftTaxFee(amount);
            uint256 yxFee  = calculateyxTaxFee(amount);
            uint256 jxFee  = calculatejxTaxFee(amount);


            tTransferAmount = tTransferAmount.sub(burnFee).sub(glFee).sub(lcFee);
            tTransferAmount = tTransferAmount.sub(nftFee).sub(yxFee).sub(jxFee);
            _balances[_burnTaxAddr] = _balances[_burnTaxAddr].add(burnFee);
            _balances[_glTaxAddr] = _balances[_glTaxAddr].add(glFee);
            _balances[_lcTaxAddr] = _balances[_lcTaxAddr].add(lcFee);
            _balances[_nftTaxAddr] = _balances[_nftTaxAddr].add(nftFee);
            _balances[_yxTaxAddr] = _balances[_yxTaxAddr].add(yxFee);
            _balances[_jxTaxAddr] = _balances[_jxTaxAddr].add(jxFee);
            emit Transfer(sender, _burnTaxAddr, burnFee);
            emit Transfer(sender, _glTaxAddr, glFee);
            emit Transfer(sender, _lcTaxAddr, lcFee);
            emit Transfer(sender, _nftTaxAddr, nftFee);
            emit Transfer(sender, _yxTaxAddr, yxFee);
            emit Transfer(sender, _jxTaxAddr, jxFee);
        }
        

        _balances[recipient] = _balances[recipient].add(tTransferAmount);

        
        bool shouldInvite = (balanceOf(recipient) == 0 && inviter[recipient] == address(0) 
            && !isContract(sender) && !isContract(recipient));


        if (shouldInvite) {
            inviter[recipient] = sender;
        }

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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
}