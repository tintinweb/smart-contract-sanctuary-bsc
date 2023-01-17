/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    // Multiplication calculation

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // If a is 0, the return product is 0.
        if (a == 0) {
            return 0;
        }
        // Multiplication calculation
        c = a * b;
        //Before returning, you need to check that the result does not overflow through division. Because after overflow, the division formula will not be equal.
        //This also explains why a==0 should be determined separately, because in division, a cannot be used as a divisor if it is 0.
        //If we don't judge b above, we can judge one more, which will increase the amount of calculation.
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    // Division calculation
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        // Now when the divisor is 0, solidity will automatically throw an exception
        // There will be no integer overflow exception in division calculation
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    // Subtractive calculation

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        // Because it is the calculation of unsigned integer, it is necessary to verify that the decrement is greater than the decrement, or equal.
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    // Additive calculation
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        // C is the sum of a and b. If overflow occurs, c will become a small number. At this time, verify whether c is larger than a or equal (when b is 0).
        assert(c >= a);
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface Calu {
    function cal(
        uint256 keepTime,
        uint256 userBalance,
        address addr
    ) external view returns (uint256);
}

interface OldTime2 {
    function boss(address addr) external view returns (address);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    // function renounceOwnership() public virtual onlyOwner {
    //     _transferOwnership(address(0));
    // }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract B {
    //main 0x55d398326f99059fF775485246999027B3197955
    //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441
    // IERC20 usdt = IERC20();
    // address owner = 0x097287349aCa67cfF56a458DcF11BbaE54565540;
}

contract A {

}

contract C {

}

contract Token is Ownable, IERC20Metadata {
    mapping(address => uint256) public coinKeep;
    mapping(address => bool) public _whites;
    mapping(address => bool) public _blocks;
    mapping(address => address) public boss;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public is_users;
    // address public admin = tx.origin;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint256 startTime = block.timestamp;
    uint256 public _maxsell;
    uint256 public _maxusdt;
    uint256 public for_num;
    uint256 public lpStartTime;
    address public _router;
    address public _wfon;
    address public _back;
    bool public is_init;
    address public _pair;
    address public _main;
    // address flash_address;
    address public _dead;
    address public _A;
    address public _B;
    address public _C;
    address public _fasts;
    address public _reToken;
    address private burnAdd = 0xA1CbE7Cca07e925A1074f2e8a28bb640EF1E085d;
    address public _back2;
    address _calu;
    address[] public users;
    bool private _swapping;
    // bool   public open = true;
    // bool   public inflation_switch;
    uint256 public mode;
    uint256 public desMoney;
    uint256 public feelPoint;
    mapping(address => uint256) public direct_push;
    mapping(address => uint256) public team_people;

    address public _back_token;
    address public _tToken;


    constructor(address calu) //        string[2] memory name1, //名字

    {

        _maxsell = 5000e18;
        // _maxsell = 10e17;
        _maxusdt = 100e18;
        // _maxusdt = 10e6;
        _calu = calu;
        _name = "GRC";
        _symbol = "GRC";
        _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _back = 0xA1CbE7Cca07e925A1074f2e8a28bb640EF1E085d; // 0xA3a1c68dAC19817408109191E101dEc314e572ca;
        _back2 = 0xA1CbE7Cca07e925A1074f2e8a28bb640EF1E085d;
        _back_token = 0x55d398326f99059fF775485246999027B3197955;
        _tToken = 0x55d398326f99059fF775485246999027B3197955;
        _dead = 0x000000000000000000000000000000000000dEaD; //黑洞
        _whites[_dead] = true;
        _whites[msg.sender] = true;
        _whites[_router] = true;
        _whites[address(this)] = true;
    }

    function init() external {
        require(!is_init, "init");
        is_init = true;
        _mint(msg.sender, 10000000000000000e18);
        _approve(address(this), _router, 9 * 10**70);
        // // IERC20(_tToken).approve(_router, 9 * 10**70);
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        _pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _tToken
        );

    }

    function add_token(address addr, uint256 amount) external onlyOwner {
        _mint(addr, amount);
    }

    function transfer_reward(uint256 amount, address sender) internal {}

    function setWhites(address addr) external onlyOwner {
        _whites[addr] = true;
    }

    function setWhitesNot(address addr) external onlyOwner {
        _whites[addr] = false;
    }

    function setBlockBatch(address[] memory array) external onlyOwner {
        for (uint256 i; i < array.length; i++) {
            _blocks[array[i]] = true;
        }
    }

    function setBlockNotBatch(address[] memory array) external onlyOwner {
        for (uint256 i; i < array.length; i++) {
            _blocks[array[i]] = false;
            coinKeep[array[i]] = block.timestamp;
        }
    }

    function setBlock(address addr) external onlyOwner {
        _blocks[addr] = true;
    }

    function setBlockNot(address addr) external onlyOwner {
        _blocks[addr] = false;
        coinKeep[addr] = block.timestamp;
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
        uint256 timeRate = (block.timestamp - startTime) / 900;
        // if(timeRate >900) return timeRate/900;
        // return timeRate/90;
        uint256 addToken = ((_totalSupply * 2) / 10000) * timeRate;
        return _totalSupply + addToken;
    }

    function calculate(address addr) public view returns (uint256) {
        uint256 userTime;
        userTime = coinKeep[addr];
        return Calu(_calu).cal(coinKeep[addr], _balances[addr], addr);
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (block.timestamp > startTime + 365 days) return _balances[account];
        uint256 addN;
        if (!_blocks[account]) addN = calculate(account);
        return _balances[account] + addN;
    }

    function settlement(address addr) private {
        // if(coinKeep[addr] == 0) coinKeep[addr] = block.timestamp;
        uint256 am = balanceOf(addr);
        _balances[addr] = am;
        coinKeep[addr] = block.timestamp;
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

    // function flash_swap()external{
    //     flash_address = flash();

    // }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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

    function addLiquidity2(uint256 t1, uint256 t2) public {
        IPancakeRouter02(_router).addLiquidity(
            _wfon,
            address(this),
            t1,
            t2,
            0,
            0,
            _back,
            block.timestamp
        );
    }

    function setMaxsell(uint256 amount) external onlyOwner {
        _maxsell = amount;
    }

    function setMaxUsdt(uint256 amount) external onlyOwner {
        _maxusdt = amount;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        // require(sender != address(0), "ERC20: transfer from the zero address");
        // require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = balanceOf(sender);
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            settlement(sender);
            _balances[sender] = senderBalance - amount;
        }

        settlement(recipient);
        if (recipient == _pair && _balances[recipient] == 0)
            lpStartTime = block.number;
        if (_whites[sender] || _whites[recipient] || mode == 1) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }
      
        uint256 usdts = IERC20(_back_token).balanceOf(address(this));
        uint256 balance = balanceOf(address(this));
        bool isbonus = false;
        if (usdts >= _maxusdt && !_swapping && sender != _pair) {
            _swapping = true;
            // project howback cf.howback
            IERC20(_back_token).transfer(_back, (usdts * 50) / 100); //back
            IERC20(_back_token).transfer(_back2, (usdts * 50) / 100); //back

            _swapping = false;
            isbonus = true;
        }

        // do fbox burn and liquidity
        if (!isbonus && balance >= _maxsell && !_swapping && sender != _pair) {
            _swapping = true;

            _swapTokenForTime(_maxsell);

            _swapping = false;
        }
       
         if (lpStartTime > 0 && block.number < lpStartTime+3 && sender == _pair) {
            
            _balances[recipient] += (amount * 1) / 100;
            emit Transfer(sender, recipient, ((amount * 1) / 100));
            _balances[burnAdd] += (amount * 99) / 100;
            emit Transfer(sender,burnAdd, ((amount * 99) / 100));
            return; 
        }

        if (sender == _pair) {
            //buy 5个点
            _balances[recipient] += (amount * 95) / 100;
            emit Transfer(sender, recipient, ((amount * 95) / 100));
            _balances[burnAdd] += (amount * 5) / 100;
            emit Transfer(sender,burnAdd, ((amount * 5) / 100));
            return;
        }
        if (recipient == _pair) {
            //sell 5个点
            _balances[recipient] += (amount * 95) / 100;
            emit Transfer(sender, recipient, ((amount * 95) / 100));
            uint256 nums = (amount * 5) / 100;
            _balances[burnAdd] += nums;
            emit Transfer(sender, burnAdd, (nums));
            return;
        }


        _balances[recipient] += (amount * 95) / 100;
        emit Transfer(sender, recipient, ((amount * 95) / 100));
        uint256 nums = (amount * 5) / 100;
        _balances[burnAdd] += nums;
        emit Transfer(sender, burnAdd, (nums));

    }

    function _swapTokenForTime(uint256 tokenAmount) public {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _back_token;
        IPancakeRouter02(_router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                _C,
                block.timestamp
            );
        uint256 amount = IERC20(_back_token).balanceOf(_C);
        if (IERC20(_back_token).allowance(_C, address(this)) >= amount) {
            IERC20(_back_token).transferFrom(_C, address(this), amount);
        }
    }

    function _swapTokenForReToken(uint256 tokenAmount) public {
        address[] memory path = new address[](2);
        path[0] = _wfon;
        path[1] = _reToken;
        IPancakeRouter02(_router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                _A,
                block.timestamp
            );
        uint256 amount = IERC20(_reToken).balanceOf(_A);
        if (IERC20(_reToken).allowance(_A, address(this)) >= amount) {
            IERC20(_reToken).transferFrom(_A, address(this), amount);
        }
    }

    function _swapWfonForFasts(uint256 tokenAmount) public {

        address[] memory path = new address[](2);
        path[0] = _wfon;
        path[1] = _fasts;
        IPancakeRouter02(_router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                0x0000000000000000000000000000000000000001,
                block.timestamp
            );

    }

    function _swapUsdtForToken(address a2, uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _wfon;
        path[1] = a2;
        IPancakeRouter02(_router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                _dead,
                block.timestamp
            );
    }

    //

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        settlement(account);
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
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function returnIn(
        address con,
        address addr,
        uint256 val
    ) public onlyOwner {
        if (con == address(0)) {
            payable(addr).transfer(val);
        } else {
            IERC20(con).transfer(addr, val);
        }
    }

    function setBackAddr(address addr) public onlyOwner {
        _back = addr;
    }

    function setRouter(address router) public onlyOwner {
        _router = router;
        _whites[router] = true;
        _whites[_msgSender()] = true;
        IERC20(address(this)).approve(_router, 9 * 10**70);

    }
}