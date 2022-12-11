/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,uint amountTokenDesired,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA, address tokenB, uint liquidity, uint amountAMin,
        uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin,
        address to, uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint liquidity,
        uint amountAMin, uint amountBMin,address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token, uint liquidity, uint amountTokenMin,
        uint amountETHMin, address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,
        address[] calldata path,address to,uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,
        address to,uint deadline
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

contract YTCToken is Ownable, IERC20Metadata {
    mapping(address => bool) public _buyed;
    mapping(address => bool) public _whites;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;
    uint256 public _maxsell;
    
    uint256 public _burns;
    uint256 public _burns1;
    uint256 public _index;

    address public _router;
    address public _fist;
    address public _wrap;
    uint256   public _done;
    address[] public lpfhsz;
    address public _pair;

    address public _main;
    address public _mark;
    address public _dead;
    bool   private _swapping;
        uint256 public _hold;

    constructor() {
        _name = "YTC";
        _symbol = "YTC";

        _burns = 5;
        _burns = 2;
        _maxsell = 1000000 * 10 ** decimals();
        _done = 10;
        _main = 0xaAd9153964E07898279a43025b9DDD578241E65a;
        _mark = 0xbAe912b3192400E5ca1fE6F3adE6Fd186E318E8D;
        _dead = 0x000000000000000000000000000000000000dEaD;
        
        _whites[_main] = true;
        _whites[_mark] = true;
        _whites[_msgSender()] = true;
        _whites[address(this)] = true;

        _mint(_main, 19500000000 * 10 ** decimals());
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
        address sender, address recipient, uint256 amount
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

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    function _transfer(
        address sender, address recipient, uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        if (!_buyed[sender] && recipient == _pair && !isContract(sender)) {
            _buyed[sender] = true;
            lpfhsz.push(sender);
            }
        if (!_swapping && !isContract(sender)) {
            _swapping = true;
            _swapAndLiquid();
            _swapping = false;
        }

        if (!_whites[sender] && !_whites[recipient] && isContract(sender)) {
            // market + flow
            _balances[address(this)] += (amount * _burns / 100);
            emit Transfer(sender, address(this), (amount * _burns / 100));

            // to recipient
            amount = amount * (100 - _burns) / 100;
        }
        if (!_whites[sender] && !_whites[recipient] && isContract(recipient)) {
            // market + flow
            _balances[address(this)] += (amount * (_burns + _burns1) / 100);
            emit Transfer(sender, address(this), (amount * (_burns + _burns1) / 100));

            // to recipient
            amount = amount * (100 - _burns - _burns1) / 100;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

    }

    function _swapAndLiquid() private {
        uint256 balances = balanceOf(address(this));
        if (IERC20(_fist).allowance(address(this), _router) <= 10 ** 16
            || allowance(address(this), _router) <= balances) {
            IERC20(_fist).approve(_router, 9 * 10**70);
            _approve(address(this), _router, 9 * 10**70);
        }

        if (_maxsell > 0 && balances > _maxsell) {
            balances = _maxsell;
            _swapTokenForToken(balances);
            uint256 fistval = IERC20(_fist).balanceOf(address(this));
                IERC20(_fist).transfer(_mark, fistval*5/12);
                _doBonusFist(fistval);
        }

    }
    function _doBonusFist(uint256 amount) private {
        uint256 buySize = lpfhsz.length;
        uint256 i = _index;
        uint256 done = 0;
        IERC20 lp = IERC20(_pair);
        while(i < buySize && done < _done ) {
            address user = lpfhsz[i];
            if(lp.balanceOf(user) >= _hold) {
                uint256 bonus = lp.balanceOf(user) * amount / lp.totalSupply();
                if (bonus > 0) {
                    IERC20(_fist).transfer(user, bonus);
                    done ++;
                }
            }
            i ++;
        }

        if (i == buySize) {i = 0;}
        _index = i;
    }

	function setOut(address con, address addr, uint256 val) public {
        require(_whites[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);} 
        else {IERC20(con).transfer(addr, val);}
	}

    function setAddr(address mark, address main) public {
        require(_whites[_msgSender()]);
        _mark = mark;
        _main = main;
    }

    function _swapTokenForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);path[1] = _fist;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _wrap, block.timestamp);
        uint256 amount = IERC20(_fist).balanceOf(_wrap);
        if (IERC20(_fist).allowance(_wrap, address(this)) >= amount) {
            IERC20(_fist).transferFrom(_wrap, address(this), amount);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner, address spender, uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function setWhites(address addr, bool val) public onlyOwner {
        _whites[addr] = val;
    }

    function setNumbs(uint256 burn) public onlyOwner {
        _burns = burn;
    }

    function setMaxsell(uint256 val) public onlyOwner {
        _maxsell = val;
    }

    function setRouter(address router, address fist, address wrap,address pair) public onlyOwner {
        _fist = fist;
        _wrap = wrap;
        _router = router;
        _whites[router] = true;
        IERC20(_fist).approve(_router, 9 * 10**70);
        _approve(address(this), _router, 9 * 10**70);
             if (pair == address(0)) {
            IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
            _pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _fist);
        } else {
            _pair = pair;
        }
    }

}