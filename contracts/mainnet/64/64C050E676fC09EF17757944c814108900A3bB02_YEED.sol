/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

contract YEED is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isVip;
    mapping(address => bool) private _isSwapPair;

    string private _name = "YEED";
    string private _symbol = "YEED";       
    uint8 private _decimals = 18;

    uint256 public _rewardFee = 50;
    uint256 private _previousRewardFee;

    address public _rewardAddress;

    uint256 public _burnFee = 50;
    uint256 private _previousBurnFee;

    uint256 public activateTime;

    mapping(address => address) public inviter;
    mapping(address => int256) public inviterNumber;

    address public ownerAddress =
        address(0xE581611D043562B5490A62e0fc218998c443DBB5);
    address public zeedAddress =
        address(0xB2F53069E1555793481aAfe639F8E274f4Ec8435);
    address public usdtAddress =
        address(0x55d398326f99059fF775485246999027B3197955);
    // address public zeedAddress =
    //     address(0x351e45E4346e95e1BB44A2BCEf9518cC8CE32113);
    // address public usdtAddress =
    //     address(0xD90d62B71558b118431a6d8B426F891F7b66B01D);
    address public poolAddress =
        address(0xa9CC5Ff506D905217EFFeC3C686F329e3613Ac75);

    IPancakeRouter02 public swapRouter;
    address public swapPair;
    address public swapPairZeed;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() {
        _decimals = 18;
        IPancakeRouter02 _router = IPancakeRouter02(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E)
        );

        address swapPairBNB = IPancakeFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        swapPairZeed = IPancakeFactory(_router.factory()).createPair(
            address(this),
            zeedAddress
        );
        swapPair = IPancakeFactory(_router.factory()).createPair(
            address(this),
            usdtAddress
        );

        _isSwapPair[swapPairBNB] = true;
        _isSwapPair[swapPairZeed] = true;
        _isSwapPair[swapPair] = true;
        swapRouter = _router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0x10e39D33355Df648d069cF130A17999C459E7d56)] = true;
        _balances[address(0x10e39D33355Df648d069cF130A17999C459E7d56)] = 998000 * 10**18;
        _totalSupply = 998000 * 10**18;

        transferOwnership(ownerAddress);

        emit Transfer(address(0), address(0x10e39D33355Df648d069cF130A17999C459E7d56), 998000 * 10**18);
    }

    function setRewardAddress(address addr) external onlyOwner {
        _rewardAddress = addr;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
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

    function activate(bool _activate) public onlyOwner {
        if (_activate) {
            activateTime = block.timestamp;
        } else {
            activateTime = 0;
        }
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

    function setVip(address account, bool state) public onlyOwner {
        _isVip[account] = state;
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
        if (_rewardFee == 0 && _burnFee == 0) return;

        _previousRewardFee = _rewardFee;
        _previousBurnFee = _burnFee;

        _rewardFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _rewardFee = _previousRewardFee;
        _burnFee = _previousBurnFee;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != spender, "ERC20: transfer to self");
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
        require(from != to, "ERC20: transfer to self");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        bool vipTime = activateTime == 0 || block.timestamp < activateTime + 10 minutes;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (!takeFee) {
            removeAllFee();
        }

        if (vipTime && takeFee) {
            require(isSwapPair(from) && _isVip[to], "Can not buy");
        }

        //transfer amount, it will take tax, burn, liquidity fee
        if (isSwapPair(to)) {
            _transferSell(from, to, amount);
        } else {
            _transferStandard(from, to, amount);
        }

        if (!takeFee) {
            restoreAllFee();
        }
    }

    function _transferSell(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 transferAmount = amount;

        uint256 burnFee = calculateBurnFee(amount);
        uint256 rewardFee = calculateRewardFee(amount);

        if (_totalSupply > 99800 * 10**18) {
            transferAmount = transferAmount.sub(burnFee);
        }
        transferAmount = transferAmount.sub(rewardFee);

        require(transferAmount > 0, "_transferSwap add is zero");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: _transferSwap amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(transferAmount);

        emit Transfer(sender, recipient, transferAmount);

        _takeReward(sender, rewardFee);
        if (_totalSupply > 99800 * 10**18) {
            _takeBurn(sender, burnFee);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(amount > 0, "_transferSwap add is zero");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: _transferStandard amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _takeReward(
        address sender,
        uint256 rewardFee
    ) private {
        if (rewardFee == 0) return;
        uint256 zeedReward = rewardFee.div(3);
        uint256 poolReward = rewardFee.div(3);
        uint256 usdtReward = rewardFee.sub(zeedReward).sub(poolReward);

        _balances[_rewardAddress] = _balances[_rewardAddress].add(usdtReward);
        emit Transfer(sender, _rewardAddress, usdtReward);

        _balances[_rewardAddress] = _balances[_rewardAddress].add(zeedReward);
        emit Transfer(sender, _rewardAddress, zeedReward);

        _balances[poolAddress] = _balances[poolAddress].add(poolReward);
        emit Transfer(sender, poolAddress, poolReward);
    }

    function _takeBurn(
        address sender,
        uint256 burnFee
    ) private {
        if (burnFee == 0) return;
        _totalSupply = _totalSupply.sub(burnFee);
        emit Transfer(sender, address(0), burnFee);
    }
}