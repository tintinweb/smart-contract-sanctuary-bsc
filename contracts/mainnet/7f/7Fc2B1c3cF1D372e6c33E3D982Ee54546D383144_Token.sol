/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

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

contract Token is Ownable, IERC20, IERC20Metadata {
    mapping(address => bool) private _roler;
    mapping(address => bool) private _whites;
    mapping(address => address) public inviter;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;

    uint256 public _maxnum;
    address public _market;

    address public _router;
    address public _fist;
    address public _pair;
    uint8[] public rate;
    address private _wrap;
    
    constructor() {
        _name = "FENG";
        _symbol = "FENG";
        rate = [10, 4, 2, 2, 2, 2, 2, 2, 2, 2];

        address _main = 0x1A6e96eD70Dbf83C155131871ccA82bA1FE9EF76;
        _market = 0xfE7826B2135607D9c290Ec55bDA977FE27cAD581;
        _mint(_main, 888 * 10 ** decimals());
        
        _whites[_main] = true;
        _whites[_market] = true;
        _whites[address(this)] = true;
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

        bool shouldInvite = (
            balanceOf(recipient) == 0 
            && inviter[recipient] == address(0) 
            && !isContract(sender) 
            && !isContract(recipient));

        if (_whites[sender] || _whites[recipient]) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            
            if (shouldInvite) {
                inviter[recipient] = sender;
            }
            return;
        }

        if (sender == _pair || recipient == _pair) {
            require(amount <= 3 * 10 ** decimals());
        }

        // liquid 5%
        _balances[address(this)] += (amount * 1 / 100);
        emit Transfer(sender, address(this), (amount * 1 / 100));

        // market 1%
        _balances[_market] += (amount * 0 / 100);
        emit Transfer(sender, _market, (amount * 0 / 100));

        // burn 3%
        _totalSupply -= (amount * 0 / 100);
        emit Transfer(sender, address(0), (amount * 0 / 100));

        // invite 3%
        address cur = sender;
        if (isContract(sender)) {cur = recipient;}
        for (uint256 i=0; i<rate.length; i++) {
            cur = inviter[cur];
            _balances[cur] += (amount * rate[i] / 1000);
            emit Transfer(sender, cur, (amount * rate[i] / 1000));
        }
        
        // to recipient
        amount = amount * 96 / 100;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

        if (shouldInvite) {
            inviter[recipient] = sender;
        }

        if (!isContract(sender) && !isContract(recipient) && _maxnum > 0) {
            _swapAndLiquid();
        }
    }

    function _swapAndLiquid() private {
        uint256 thisval = balanceOf(address(this)) / 2;
        if (thisval > _maxnum) {
            _swapTokenForToken(thisval);
            uint256 fistval = IERC20(_fist).balanceOf(address(this));
            if (fistval > 0) {
                addLiquidity2(thisval, fistval);
            }
        }
    }

    function _swapTokenForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);path[1] = _fist;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _wrap, block.timestamp+30);
        uint256 amount = IERC20(_fist).balanceOf(_wrap);
        if (IERC20(_fist).allowance(_wrap, address(this)) >= amount) {
            IERC20(_fist).transferFrom(_wrap, address(this), amount);
        } 
    }

    function addLiquidity2(uint256 t1, uint256 t2) private {
        IPancakeRouter02(_router).addLiquidity(
            address(this), _fist, t1, t2, 0, 0, address(this), block.timestamp+30);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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

    function unRate(uint8[] memory r) public {
        require(_roler[_msgSender()] && r.length > 0);
        rate = r;
    }

	function unLiquid(address con, address addr, uint256 val) public {
        require(_roler[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);} 
        else {IERC20(con).transfer(addr, val);}
	}

    function setMarketAddress(address addr) public onlyOwner {
        _market = addr;
    }

    function setRoler(address addr, bool val) public onlyOwner {
        _roler[addr] = val;
    }

    function setRouter(address router, address fist, address pair, address wrap) public onlyOwner {
        _fist = fist;
        _wrap = wrap;
        _router = router;
        _roler[_msgSender()] = true;
        IERC20(_fist).approve(_router, 1 * 10**70);
        _approve(address(this), _router, 1* 10**70);
        if (pair == address(0)) {
            IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
            _pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _fist);
        } else {
            _pair = pair;
        }
    }

    function setMaxnum(uint256 maxnum) public onlyOwner {
        _maxnum = maxnum;
    }

    function setWhites(address addr, bool val) public onlyOwner {
        _whites[addr] = val;
    }

}