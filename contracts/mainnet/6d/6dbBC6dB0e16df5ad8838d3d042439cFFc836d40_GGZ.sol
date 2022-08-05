/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT

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

contract GGZ is Ownable, IERC20Metadata {
    mapping(address => bool) public _buyed;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;
    uint256 public  _maxsell;
    uint256 public  _maxfist;

    address public _router;
    address public _fist;
    address public _main;
    address public _pair;
    address public _wrap;
    address public _dead;
    address public _fund;
    bool   private _swap;
    

    uint256   public _hold = 100;
    uint256   public _done;
    uint256   public _max;
    uint256   public _index;
    address[] public buyUser;

    //referrer
    mapping(address => address) public referrerOfUser; 
    mapping(address => address[]) public usersOfReferrer;

    uint256  public openTime;
    uint256  public limitTime;

    event RecordReferral(address indexed user, address indexed referrer);

    constructor() {
        _name = "GGZ";
        _symbol = "GGZ";

        _fist = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
        _main = 0x6d0c113886C1e15580fD6e9A7C39Aa7C0078FB49;
        _dead = 0x0000000000000000000000000000000000000000;
        _fund = 0x48e4275eD3f56b6BEDc1b685a7aFaE91169E98cC;


        _max = 600;
        _done = 30;
        _maxfist = 100 * 10 ** 18;                  // 100 fist
        _maxsell = 2 * 10 ** (decimals() - 1 );     // 0.2 GGZ
        _mint(_main, 999 * 10 ** decimals());


        openTime = block.timestamp + 4 hours;
        limitTime= block.timestamp + 5 hours;

    }
    function initData(address _fist_) public onlyOwner {
        _fist = _fist_;
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

    function _isLp(address _addr) internal view returns (bool) {
        return _addr == _pair;
    }
    // 0: normal transfer
    // 1: buy from official LP  or  remove official LP
    // 2: sell to official LP   or  add official LP
    function _getTransferType(address _from, address _to) internal view returns (uint256) {
        if (_isLp(_from) && !_isLp(_to)) {
            return 1;
        }

        if (!_isLp(_from) && _isLp(_to)) {
            return 2;
        }

        return 0;
    }

    function _transfer(
        address sender, address recipient, uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        if (!_buyed[sender] && recipient == _pair && !isContract(sender)) {
            _buyed[sender] = true;
            buyUser.push(sender);
        }

        if (sender == address(this) || recipient == address(this) || sender == _router || recipient == _router) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }

        // 0: normal transfer
        // 1: buy from official LP  or  remove official LP
        // 2: sell to official LP   or  add official LP
        uint256 _transferType = _getTransferType(sender, recipient);

        if (_transferType == 0){
            _balances[recipient] += amount;
            
            emit Transfer(sender, recipient, amount);

            if (amount > 0){
                _recordReferral(recipient, sender);
            }
            return;
        }
        if (_transferType == 1){
            require(openTime < block.timestamp, "wait open");
        }

        // do fistsmoon bonus, burn osk
        uint256 fists = IERC20(_fist).balanceOf(address(this));
        bool isbonus = false;
        if (fists >= _maxfist && !_swap && sender != _pair) {
            _swap = true;
            _doBonusFist(fists);
            _swap = false;
            isbonus = true;
        }

        // do sell and liquidity
        uint256 balance = balanceOf(address(this));
        if (!isbonus && balance >= _maxsell && !_swap && sender != _pair) {
            _swap = true;
            if (IERC20(_fist).allowance(address(this), _router) <= 10 ** 28
                || allowance(address(this), _router) < balance * 10) {
                _approve(address(this), _router, 9 * 10**70);
                IERC20(_fist).approve(_router, 9 * 10**70);
            }
            _swapTokenForFist(balance);
            _swap = false;
        }

        // fund 1%
        _balances[_fund] += amount * 10 / 1000;
        emit Transfer(sender, _fund, amount * 10 / 1000);

        // lp 2.5%
        _balances[address(this)] += amount * 25 / 1000;
        emit Transfer(sender, address(this), amount * 25 / 1000);

        //
        uint256 up1Amount = amount * 10 / 1000;
        uint256 up2Amount = amount * 5 / 1000;
        address _user ;
        if (_transferType == 1) { // buy,remove LP
            _user = recipient;
        }else{ //_transferType == 2  sell,add LP
            _user = sender;
        }

        address _referrer1 = getReferrerByLevel(_user, 1);
        if (_referrer1 == address(0)) {
            _balances[_fund] += up1Amount;
            emit Transfer(sender, _fund, up1Amount);
        }else{
            _balances[_referrer1] += up1Amount;            
            emit Transfer(sender, _referrer1, up1Amount);
        }

        address _referrer2 = getReferrerByLevel(_user, 2);
        if (_referrer2 == address(0)) {
            _balances[_fund] += up2Amount;
            emit Transfer(sender, _fund, up2Amount);
        }else{
            _balances[_referrer2] += up2Amount;            
            emit Transfer(sender, _referrer2, up2Amount);
        }


        amount = amount * 950 / 1000;
        _balances[recipient] += amount;

        if (_transferType == 1){ // 1: buy from official LP  or  remove official LP
            if (limitTime > block.timestamp){
                require(_balances[recipient] <= 5 ether, "The current limit is 10");
            }
        }

        emit Transfer(sender, recipient, amount);
    }

    function _doBonusFist(uint256 amount) private {
        uint256 buySize = buyUser.length;
        uint256 i = _index;
        uint256 done = 0;
        uint256 max = 0;
        IERC20 lp = IERC20(_pair);

        while(i < buySize && done < _done && max < _max) {
            address user = buyUser[i];
            if(lp.balanceOf(user) >= _hold) {
                uint256 bonus = lp.balanceOf(user) * amount / lp.totalSupply();
                //if (bonus > 0 && IERC20(_fist).balanceOf(user)+bonus < 1000*10**18) {
                if (bonus > 0) {
                    IERC20(_fist).transfer(user, bonus);
                    done ++;
                }
            }
            max ++;
            i ++;
        }

        if (i >= buySize) {i = 0;}
        _index = i;
    }

    function _swapTokenForFist(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fist;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _wrap, block.timestamp);
        uint256 amount = IERC20(_fist).balanceOf(_wrap);
        if (IERC20(_fist).allowance(_wrap, address(this)) >= amount) {
            IERC20(_fist).transferFrom(_wrap, address(this), amount);
        }
    }

    function addLiquidityFist(uint256 t1, uint256 t2) private {
        IPancakeRouter02(_router).addLiquidity(address(this), 
            _fist, t1, t2, 0, 0, address(this), block.timestamp);
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


    function _recordReferral(address _user, address _referrer) internal returns(bool) {

        // record referral already
        if (referrerOfUser[_user] != address(0) || referrerOfUser[_referrer] == _user) {
            return false;
        }

        // invalid address
        if (
            _user == _referrer ||
            _user == address(0) ||
            _referrer == address(0) ||
            isContract(_user) ||
            isContract(_referrer)
        ) {
            return false;
        }

        referrerOfUser[_user] = _referrer;
        usersOfReferrer[_referrer].push(_user);
        emit RecordReferral(_user, _referrer);

        return true;
    }

    function _contains(address[] memory _list, address _a) internal pure returns (bool) {
        for (uint256 i = 0; i < _list.length; i++) {
            if (_list[i] == _a) {
                return true;
            }
        }
        return false;
    }
    function getReferrerByLevel(address _user, uint256 _level) public view returns (address) {
        address _referrer = address(0);
        address[] memory _found = new address[](_level + 1);
        _found[0] = _user;

        for (uint256 _l = 1; _l <= _level; _l++) {
            _referrer = referrerOfUser[_user];
            if (_referrer == address(0) || _contains(_found, _referrer)) {
                return address(0);
            }

            _user = _referrer;
            _found[_l] = _referrer;
        }

        return _referrer;
    }

	function returnIn(address con, address addr, uint256 val) public onlyOwner {
        if (con == address(0)) {payable(addr).transfer(val);}
        else {IERC20(con).transfer(addr, val);}
	}

    function setTime(uint256 _openTime,uint256 _limitTime) public onlyOwner {
        openTime = _openTime;
        limitTime = _limitTime;
    }
    function setLimitTime(uint256 _limitTime) public onlyOwner {
        limitTime = _limitTime;
    }

    function setAddrs(address wrap) public onlyOwner {
        _wrap = wrap;
    }
    function setFund(address addr) public onlyOwner {
        _fund = addr;
    }
    function setOpenBuy(uint256 val) public onlyOwner {
        openTime = val;
    }

    function setMaxsell(uint256 val) public onlyOwner {
        _maxsell = val;
    }

    function setMaxFist(uint256 val) public onlyOwner {
        _maxfist = val;
    }

    function setHold(uint256 val) public onlyOwner {
        _hold = val;
    }

    function setDone(uint256 val) public onlyOwner {
        _done = val;
    }

    function setMax(uint256 val) public onlyOwner {
        _max = val;
    }

    function setRouter(address router, address pair, address wrap) public onlyOwner {
        _wrap = wrap;
        _router = router;

        _approve(address(this), _router, 9 * 10**70);
        IERC20(_fist).approve(_router, 9 * 10**70);
        if (pair == address(0)) {
            IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
            _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _fist);
        } else {
            _pair = pair;
        }
    }
}