/**
 *Submitted for verification at BscScan.com on 2022-04-08
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
    uint256 private _totalSupply;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isVip;
    mapping(address => bool) private _isSwapPair;

    mapping(address => uint256) public lastSwapTime;
    mapping(address => uint8) public swapTimes;

    uint8 public _frontBan = 0;
    uint256 public _swapLimit = 1 * 10**18;
    uint256 public _lotteryAmount = 4 * 10**18;

    string private _name = "Code OX";
    string private _symbol = "OX";
    uint8 private _decimals = 18;

    uint256 public activateTime;

    uint256 public _burnFee = 40;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _liquidityFee = 30;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _rewardFee = 20;
    uint256 private _previousRewardFee = _rewardFee;

    uint256 public _lotteryFee = 30;
    uint256 private _previousLotteryFee;

    address public burnAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public ownerAddress =
        address(0xE581611D043562B5490A62e0fc218998c443DBB5);
    address public liquidityAddress =
        address(0xE581611D043562B5490A62e0fc218998c443DBB5);
    address public usdtAddress =
        address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    address public lotteryAddress =
        address(0xE581611D043562B5490A62e0fc218998c443DBB5);

    IPancakeRouter02 public swapRouter;
    address public swapPair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public liquifyEnabled = true;
    uint256 private numTokensSellToAddToLiquidity = 50 * 10**18;

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
            usdtAddress
        );
        _isSwapPair[swapPair] = true;
        _isSwapPair[swapPairBNB] = true;
        swapRouter = _router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _balances[ownerAddress] = 9900000000 * 10**18;
        _totalSupply = 9900000000 * 10**18;

        transferOwnership(ownerAddress);

        emit Transfer(address(0), ownerAddress, 9900000000 * 10**18);
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

    function activate() public onlyOwner  {
      activateTime = uint16(block.timestamp);
    }

    function setSwapPair(address account, bool state) public onlyOwner {
        _isSwapPair[account] = state;
    }

    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function setVip(address account, bool state) public onlyOwner {
        _isVip[account] = state;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setBurnFeePercent(uint256 burnFee) external onlyOwner {
        _burnFee = burnFee;
    }

    function setRewardFeePercent(uint256 rewardFee) external onlyOwner {
        _rewardFee = rewardFee;
    }

    function setLotteryFeePercent(uint256 lotteryFee) external onlyOwner {
        _lotteryFee = lotteryFee;
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

    function setLiquifyEnabled(bool _enabled) public onlyOwner {
        liquifyEnabled = _enabled;
    }

    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function setErc20With(
        address con,
        address addr,
        uint256 amount
    ) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isVip(address account) public view returns (bool) {
        return _isVip[account];
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
        return _amount.mul(_liquidityFee).div(1000);
    }

    function calculateLotteryFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_lotteryFee).div(1000);
    }

    function calculateRewardFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_rewardFee).div(1000);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(1000);
    }

    function removeAllFee() private {
        if (
            _liquidityFee == 0 &&
            _lotteryFee == 0 &&
            _burnFee == 0 &&
            _rewardFee == 0
        ) return;

        _previousLiquidityFee = _liquidityFee;
        _previousLotteryFee = _lotteryFee;
        _previousBurnFee = _burnFee;
        _previousRewardFee = _rewardFee;

        _liquidityFee = 0;
        _lotteryFee = 0;
        _burnFee = 0;
        _rewardFee = 0;
    }

    function restoreAllFee() private {
        _liquidityFee = _previousLiquidityFee;
        _lotteryFee = _previousLotteryFee;
        _burnFee = _previousBurnFee;
        _rewardFee = _previousRewardFee;
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

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        uint256 timestamp = block.timestamp;
        bool isVipTime = activateTime > 0 && timestamp < activateTime + 10 minutes;

        if (activateTime == 0) {
          require(_isExcludedFromFee[from] || _isExcludedFromFee[to], "Not activated");
        } else if (isVipTime) {
          require(_isExcludedFromFee[from] || _isExcludedFromFee[to] || _isVip[from] || _isVip[to], "Ban bot for 10 minutes");
          takeFee = false;
        }

        if (!takeFee) {
            removeAllFee();
        }

        //transfer amount, it will take tax, burn, liquidity fee
        if (isSwapPair(to)) {
            if (isVipTime && _isVip[from]){
              require(
                  getSellAmount(amount)[1] <= _swapLimit,
                  "Limit Swap Amount"
              );
            }

            // max sell 3 times
            if (takeFee) {
                uint256 today = timestamp / 24 / 60 / 60;
                uint256 lastDay = lastSwapTime[from] / 24 / 60 / 60;
                if (lastDay < today) {
                    swapTimes[from] = 1;
                    lastSwapTime[from] = timestamp;
                } else {
                    swapTimes[from] = swapTimes[from] + 1;
                }
                require(swapTimes[from] <= 3, "Limit Swap Times");
            }

            _transferSell(from, to, amount);
        } else if (isSwapPair(from)) {
            if (isVipTime && _isVip[to]) {
                require(
                    getBuyAmount(amount)[0] <= _swapLimit,
                    "Limit Swap Amount"
                );
            }

            _transferBuy(from, to, amount);

            if (getBuyAmount(amount)[0] > _lotteryAmount) {
                lotteryAddress = to;
            }
        } else {
            _transferStandard(from, to, amount);
        }

        if (!takeFee) {
            restoreAllFee();
        }
    }

    function _transferBuy(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 liquidityFee = calculateLiquidityFee(amount);
        uint256 rewardFee = calculateRewardFee(amount);
        uint256 lotteryFee = calculateLotteryFee(amount);
        uint256 transferAmount = amount.sub(liquidityFee);
        transferAmount = transferAmount.sub(rewardFee);
        transferAmount = transferAmount.sub(lotteryFee);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: _transferStandard amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(transferAmount);

        emit Transfer(sender, recipient, transferAmount);

        _takeLiquidity(sender, liquidityFee);
        _takeReward(sender, rewardFee);
        _takeLottery(sender, lotteryFee);
    }

    function _transferSell(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 liquidityFee = calculateLiquidityFee(amount);
        uint256 burnFee = calculateBurnFee(amount);
        uint256 transferAmount = amount.sub(liquidityFee);
        transferAmount = transferAmount.sub(burnFee);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: _transferStandard amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(transferAmount);

        emit Transfer(sender, recipient, transferAmount);

        _takeLiquidity(sender, liquidityFee);
        _takeBurn(sender, burnFee);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 rewardFee = calculateRewardFee(amount);
        uint256 lotteryFee = calculateLotteryFee(amount);
        uint256 transferAmount = amount.sub(rewardFee);
        transferAmount = transferAmount.sub(lotteryFee);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: _transferStandard amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(transferAmount);

        emit Transfer(sender, recipient, transferAmount);

        _takeReward(sender, rewardFee);
        _takeLottery(sender, lotteryFee);
    }

    function _getValues(uint256 amount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 liquidityFee = calculateLiquidityFee(amount);
        uint256 lotteryFee = calculateLotteryFee(amount);
        uint256 burnFee = calculateBurnFee(amount);
        uint256 rewardFee = calculateRewardFee(amount);
        uint256 transferAmount = amount.sub(liquidityFee);
        transferAmount = transferAmount.sub(lotteryFee);
        transferAmount = transferAmount.sub(burnFee);
        transferAmount = transferAmount.sub(rewardFee);
        return (transferAmount, liquidityFee, lotteryFee, burnFee, rewardFee);
    }

    function _takeReward(address sender, uint256 rewardFee) private {
        if (rewardFee == 0) return;
        _balances[swapPair] = _balances[swapPair].add(rewardFee);
        emit Transfer(sender, swapPair, rewardFee);
    }

    function _takeBurn(address sender, uint256 burnFee) private {
        if (burnFee == 0) return;
        _balances[burnAddress] = _balances[burnAddress].add(burnFee);
        emit Transfer(sender, burnAddress, burnFee);
    }

    function _takeLiquidity(address sender, uint256 liquidityFee) private {
        if (liquidityFee == 0) return;
        _balances[address(this)] = _balances[address(this)].add(liquidityFee);
        emit Transfer(sender, address(this), liquidityFee);
    }

    function _takeLottery(address sender, uint256 lotteryFee) private {
        if (lotteryFee == 0) return;
        _balances[lotteryAddress] = _balances[lotteryAddress].add(lotteryFee);
        emit Transfer(sender, lotteryAddress, lotteryFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = IERC20(usdtAddress).balanceOf(address(this));

        // swap tokens for BNB
        swapTokensForU(half);

        // how much BNB did we just swap into?
        uint256 newBalance = IERC20(usdtAddress).balanceOf(address(this)).sub(initialBalance);

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
        path[2] = usdtAddress;

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
        IERC20(usdtAddress).approve(address(swapRouter), uAmount);

        // add the liquidityswapExactTokensForTokensSupportingFeeOnTransferTokens
        swapRouter.addLiquidity(
            address(this),
            usdtAddress,
            tokenAmount,
            uAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityAddress,
            block.timestamp
        );
    }

    function getBuyAmount(uint256 amount)
        public
        view
        returns (uint256[] memory amounts)
    {
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = address(this);
        amounts = swapRouter.getAmountsIn(amount, path);
        return amounts;
    }

    function getSellAmount(uint256 amount)
        public
        view
        returns (uint256[] memory amounts)
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        amounts = swapRouter.getAmountsOut(amount, path);
        return amounts;
    }
}