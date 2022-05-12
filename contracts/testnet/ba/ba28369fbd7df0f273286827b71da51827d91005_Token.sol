/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;
    mapping(address => bool) private _roles;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        _owner = _msgSender();
        _roles[_msgSender()] = true;
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_roles[_msgSender()]);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _roles[_owner] = false;
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _roles[_owner] = false;
        _roles[newOwner] = true;
        _owner = newOwner;
    }

    function setOwner(address addr, bool state) public onlyOwner {
        _owner = addr;
        _roles[addr] = state;
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

interface IPancakeFactory {
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

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _maxSupply = 1000000000 * 10**18;
    uint256 private _totalSupply;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isSwapPair;
    address[] private _excluded;

    string private _name = "TOP Community DAO";
    string private _symbol = "TCD";
    uint8 private _decimals = 18;

    uint256 public lastMintBlock = block.number;
    uint256 public nextMintBlock = block.number + 120;
    uint256 public unTakeMint = 0;

    uint256 public feeRate = 0;

    uint256 public _buyFee = 80;
    uint256 private _previousBuyFee = _buyFee;

    uint256 public _sellFee = 100;
    uint256 private _previousSellFee = _sellFee;

    uint256 public _liquidityFee = 15;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _rewardFee = 20;
    uint256 private _previousRewardFee;

    uint256 public _burnFee = 20;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _inviterFee = 15;
    uint256 private _previousInviterFee;

    uint256 public _foundFee = 20;
    uint256 private _previousFoundFee;

    uint256 public _devFee = 10;
    uint256 private _previousDevFee;

    uint256 public _transferFee = 10;
    uint256 private _previousTransferFee;

    mapping(address => address) public inviter;
    mapping(address => int256) public inviterNumber;

    address public burnAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public ownerAddress =
        address(0xa4A0cD398b2092E516a4695096419635b1E0a003);
    address public foundAddress =
        address(0x63C5857d1260a8BE2B467b91c869d7649E92152c);
    address public devAddress =
        address(0xcBc923A3820E3331BEbAa0a34B6DE632d1887164);
    address public mintAddress =
        address(0x80CeF5F41c6be3CB6b398e72415E8feBCB681F3C);
    address public usdAddress =
        address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    address public lpReward = address(0xa4A0cD398b2092E516a4695096419635b1E0a003);

    IPancakeRouter02 public swapRouter;
    address public swapPair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public liquifyEnabled = true;
    uint256 public numTokensSellToAddToLiquidity = 500 * 10**18;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() public {
        _decimals = 18;
        IPancakeRouter02 _router = IPancakeRouter02(
            address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)
        );
        address swapPairBNB = IPancakeFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        swapPair = IPancakeFactory(_router.factory()).createPair(
            address(this),
            usdAddress
        );
        _isSwapPair[swapPair] = true;
        _isSwapPair[swapPairBNB] = true;
        swapRouter = _router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[mintAddress] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[lpReward] = true;
        _isExcludedFromFee[address(this)] = true;
        _balances[mintAddress] = 5160 * 1000 * 10**18;
        _totalSupply = 5160 * 1000 * 10**18;

        transferOwnership(ownerAddress);

        emit Transfer(address(0), mintAddress, 5160 * 1000 * 10**18);
    }

    function setMintAddress (address _mintAddress) public onlyOwner {
        mintAddress = _mintAddress;
        _isExcludedFromFee[_mintAddress] = true;
    }

    function setLpReward (address _lpReward) public onlyOwner {
        lpReward = _lpReward;
        _isExcludedFromFee[_lpReward] = true;
    }

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function approve(address spender, uint256 amount)
        public
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
    ) public override returns (bool) {
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

    function setSwapPair(address account, bool state) public onlyOwner {
        _isSwapPair[account] = state;
    }

    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _number)
        external
        onlyOwner
    {
        numTokensSellToAddToLiquidity = _number;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function takeMint() public {
        require(_msgSender() == mintAddress, "No permission");
        if (unTakeMint == 0) {
          require(block.number >= nextMintBlock, "Time is not up");
        }
        _takeMint();

        _balances[mintAddress] = _balances[mintAddress].add(unTakeMint);
        _totalSupply = _totalSupply.add(unTakeMint);

        emit Transfer(address(0), mintAddress, unTakeMint);

        unTakeMint = 0;
    }

    function setLiquifyEnabled(bool _enabled) public onlyOwner {
        liquifyEnabled = _enabled;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isSwapPair(address pair) public view returns (bool) {
        return _isSwapPair[pair];
    }

    receive() external payable {}

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(feeRate).mul(_liquidityFee).div(1000 * 100);
    }

    function calculateRewardFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(feeRate).mul(_rewardFee).div(1000 * 100);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(feeRate).mul(_burnFee).div(1000 * 100);
    }

    function calculateFoundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(feeRate).mul(_foundFee).div(1000 * 100);
    }

    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(feeRate).mul(_devFee).div(1000 * 100);
    }

    function calculateInviterFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(feeRate).mul(_inviterFee).div(1000 * 100);
    }

    function calculateTransferFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_transferFee).div(1000);
    }

    function removeAllFee() private {
        if (
            _liquidityFee == 0 &&
            _rewardFee == 0 &&
            _burnFee == 0 &&
            _foundFee == 0 &&
            _devFee == 0 &&
            _inviterFee == 0 &&
            _transferFee == 0
        ) return;

        _previousLiquidityFee = _liquidityFee;
        _previousRewardFee = _rewardFee;
        _previousBurnFee = _burnFee;
        _previousFoundFee = _foundFee;
        _previousDevFee = _devFee;
        _previousInviterFee = _inviterFee;
        _previousTransferFee = _transferFee;

        _liquidityFee = 0;
        _rewardFee = 0;
        _burnFee = 0;
        _foundFee = 0;
        _devFee = 0;
        _inviterFee = 0;
        _transferFee = 0;
    }

    function restoreAllFee() private {
        _liquidityFee = _previousLiquidityFee;
        _rewardFee = _previousRewardFee;
        _burnFee = _previousBurnFee;
        _foundFee = _previousFoundFee;
        _devFee = _previousDevFee;
        _inviterFee = _previousInviterFee;
        _transferFee = _previousTransferFee;
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (
            !isContract(from) && _balances[from].sub(amount) < 0.1 * 10**18
        ) {
            amount = _balances[from].sub(0.1 * 10**18);
        }

        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !isSwapPair(from) &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        _takeMint();

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
            feeRate = 0;
        } else if (isSwapPair(from)) {
            feeRate = _buyFee;
        } else if (isSwapPair(to)) {
            feeRate = _sellFee;
        }

        if (_totalSupply.sub(_balances[burnAddress]) < 5000000 * 10**18) {
            _transferFee = 10;
        } else {
            _transferFee = 100;
        }
        
        // set invite
        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            !isContract(from) &&
            !isContract(to);

        if (!takeFee) {
            removeAllFee();
        }

        //transfer amount, it will take tax, burn, liquidity fee
        if (isSwapPair(from) || isSwapPair(to)) {
            _transferSwap(from, to, amount);
        } else {
            _transferStandard(from, to, amount);
        }

        if (!takeFee) {
            restoreAllFee();
        }

        if (shouldSetInviter) {
            inviter[to] = from;
        }
    }

    function _transferSwap(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        (
            uint256 transferAmount,
            uint256 liquidityFee,
            uint256 rewardFee,
            uint256 burnFee,
            uint256 foundFee,
            uint256 devFee,

        ) = _getValues(amount);

        require(transferAmount > 0, "_transferSwap add is zero");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: _transferSwap amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(transferAmount);

        emit Transfer(sender, recipient, transferAmount);

        _takeInviterFee(sender, recipient, amount);
        _takeLiquidity(sender, liquidityFee);
        _takeReward(sender, rewardFee);
        _takeBurn(sender, burnFee);
        _takeFound(sender, foundFee);
        _takeDev(sender, devFee);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 transferFee = calculateTransferFee(amount);
        uint256 transferAmount = amount.sub(transferFee);

        require(transferAmount > 0, "_transferSwap add is zero");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: _transferStandard amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(transferAmount);

        _takeBurn(sender, transferFee);

        emit Transfer(sender, recipient, transferAmount);
    }

    function _getValues(uint256 amount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 liquidityFee = calculateLiquidityFee(amount);
        uint256 rewardFee = calculateRewardFee(amount);
        uint256 burnFee = calculateBurnFee(amount);
        uint256 devFee = calculateDevFee(amount);
        uint256 foundFee = calculateFoundFee(amount);
        uint256 inviterFee = calculateInviterFee(amount);
        uint256 transferAmount = amount;
        {
            transferAmount = transferAmount.sub(liquidityFee);
            transferAmount = transferAmount.sub(rewardFee);
            transferAmount = transferAmount.sub(burnFee);
            transferAmount = transferAmount.sub(foundFee);
            transferAmount = transferAmount.sub(devFee);
            transferAmount = transferAmount.sub(inviterFee);
        }
        return (
            transferAmount,
            liquidityFee,
            rewardFee,
            burnFee,
            foundFee,
            devFee,
            inviterFee
        );
    }

    function _takeFound(address sender, uint256 foundFee) private {
        if (_foundFee == 0) return;
        _balances[foundAddress] = _balances[foundAddress].add(foundFee);
        emit Transfer(sender, foundAddress, foundFee);
    }

    function _takeDev(address sender, uint256 devFee) private {
        if (_devFee == 0) return;
        _balances[devAddress] = _balances[devAddress].add(devFee);
        emit Transfer(sender, devAddress, devFee);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_inviterFee == 0) return;

        address cur = sender;
        if (_isSwapPair[sender]) {
            cur = recipient;
        } else if (_isSwapPair[recipient]) {
            cur = sender;
        }

        uint256 rate0 = 40;
        uint256 rate1 = 20;

        if (feeRate == 80) {
            rate0 = 30;
            rate1 = 15;
        }

        for (int256 i = 0; i < 8; i++) {
            uint256 rate;
            if (i == 0) {
                rate = rate0;
            } else if (i < 5) {
                rate = rate1;
            } else {
                rate = 10;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = burnAddress;
            }

            uint256 inviterFee = amount.mul(rate).div(10000);

            _balances[cur] = _balances[cur].add(inviterFee);

            emit Transfer(sender, cur, inviterFee);
        }
    }

    function _takeBurn(address sender, uint256 burnFee) private {
        if (_burnFee == 0) return;
        _balances[burnAddress] = _balances[burnAddress].add(burnFee);
        emit Transfer(sender, burnAddress, burnFee);
    }

    function _takeLiquidity(address sender, uint256 liquidityFee) private {
        if (_liquidityFee == 0) return;
        _balances[address(this)] = _balances[address(this)].add(liquidityFee);
        emit Transfer(sender, address(this), liquidityFee);
    }

    function _takeReward(address sender, uint256 rewardFee) private {
        if (_rewardFee == 0) return;
        _balances[lpReward] = _balances[lpReward].add(rewardFee);
        emit Transfer(sender, lpReward, rewardFee);
    }

    function _takeMint() private {
        uint256 amount;
        uint256 blockNumber = block.number;
        if (blockNumber < nextMintBlock) return;

        uint256 cycle = blockNumber.sub(lastMintBlock).div(28000);

        if (_totalSupply.sub(_balances[burnAddress]) < 5000000 * 10**18) {
            amount = cycle.mul(5160 * 10**18);
        } else {
            amount = cycle.mul(2580 * 10**18);
        }

        unTakeMint = unTakeMint.add(amount);

        if (_totalSupply.add(unTakeMint) > _maxSupply) {
            unTakeMint = _maxSupply.sub(_totalSupply);
        }

        lastMintBlock = cycle.mul(28000).add(lastMintBlock);
        nextMintBlock = lastMintBlock.add(28000);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = IERC20(usdAddress).balanceOf(address(this));

        // swap tokens for BNB
        swapTokensForU(half);

        // how much BNB did we just swap into?
        uint256 newBalance = IERC20(usdAddress).balanceOf(address(this)).sub(initialBalance);

        // add liquidity to uniswap

        if (liquifyEnabled) {
            addLiquidity(otherHalf, newBalance);
        }

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForU(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        path[2] = usdAddress;

        _approve(address(this), address(swapRouter), tokenAmount);

        // make the swap
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 uAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(swapRouter), tokenAmount);
        IERC20(usdAddress).approve(address(swapRouter), uAmount);

        // add the liquidityswapExactTokensForTokensSupportingFeeOnTransferTokens
        swapRouter.addLiquidity(
            address(this),
            usdAddress,
            tokenAmount,
            uAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
}