/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     * 
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
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

interface IUniswapV2Pair {
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

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract BlueDaoToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isBlackList;
    mapping (address => bool) public _isSwapPair;

    string private _name = "bluedao";
    string private _symbol = "bluedao";
    uint8 private _decimals = 18;

    uint256 public _communityFee = 150;
    uint256 private _previousCommunityFee = _communityFee;
    uint256 public _fundFee = 50;
    uint256 private _previousFundFee = _fundFee;
    uint256 public _marketingFee = 50;
    uint256 private _previousMarketingFee = _marketingFee;
    uint256 public _lpFee = 150;
    uint256 private _previousLpFee = _lpFee;
    uint256 public _fomoFee = 50;
    uint256 private _previousFomoFee = _fomoFee;
    uint256 public _burnFee = 50;
    uint256 private _previousBurnFee = _burnFee;
    uint256 public _inviterFee = 200;
    uint256 private _previousInviterFee = _inviterFee;
    uint256[] public _inviterRate = [50, 30, 20, 20, 20, 20, 20, 20];

    uint256 private _tTotal = 10000000000 * 10**_decimals;
    uint256 public _maxTradeAmount = 1000000 * 10**_decimals;
    uint256 public _maxStopFee = 10000000 * 10**_decimals;
    uint256 public _minRemainAmount = 1 * 10**_decimals;
    uint256 public _inviterHolderAmount = 100000 * 10**_decimals;
    uint256 public _fomoAmount = 100 * 10**_decimals;
    uint256 public _minFomoReward = 0 * 10**_decimals;
    uint256 public _fomoRewardRate = 70;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2UsdtPair;
    address public uniswapV2BnbPair;
    address public communityAddress = address(0xe0A81f6A66b47C6c35e9B99Ba5e9850FCd227932);
    address public marketingAddress = address(0xe4C7cf52b03BBf5a7a3948bb76b4719927135DC5);
    address public fundAddress = address(0x0eCE6E70986937664CE84806942762AB87fe4FF9);
    address public fomoAddress = address(0x45Bb0D281584D553A1E58F7771E3B532C2bDFD1e);
    address public remainAddress = address(0xDE4504322ACDf6E8729a766A0824c58E81B96EcC);

    mapping(address => address) public inviter;

    uint256 public fomoIndex = 0;
    uint256 public fomoMinPeriod = 4 hours;
    uint256 public fomoLastTime;
    mapping(uint => address) public fomoRewardAddress;
     
    constructor(address receiveAddress_, address routerAddress_, address usdtAddress_) {
        _tOwned[receiveAddress_] = _tTotal;
        fomoLastTime = block.timestamp + 30 days;
       
        uniswapV2Router = IUniswapV2Router02(routerAddress_);
        uniswapV2UsdtPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdtAddress_);
        uniswapV2BnbPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        
        _isSwapPair[uniswapV2UsdtPair] = true;
        _isSwapPair[uniswapV2BnbPair] = true;
        _isExcludedFromFee[routerAddress_] = true;

        //exclude owner and this contract from fee
        _isExcludedFromFee[receiveAddress_] = true;
        _isExcludedFromFee[communityAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[fundAddress] = true;
        _isExcludedFromFee[fomoAddress] = true;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        
        emit Transfer(address(0), receiveAddress_, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function bind(address addr) public {
        require(inviter[msg.sender] == address(0), 'already bind');
        require(!isContract(addr), 'addr is contract');
        require(checkInviter(msg.sender, addr) == true , 'bad inviter');
        inviter[msg.sender] = addr;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
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
            msg.sender,
            _allowances[sender][msg.sender].sub(
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
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function setInviter(address a1, address a2) public onlyOwner {
        require(a1 != address(0));
        require(!isContract(a2), 'addr is contract');
        require(checkInviter(a1, a2) == true , 'bad inviter');
        inviter[a1] = a2;
    }

   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMarketFee(uint256 fee) public onlyOwner {
        _marketingFee = fee;
    }

    function setBurnFee(uint256 fee) public onlyOwner {
        _burnFee = fee;
    }

    function setFundFee(uint256 fee) public onlyOwner {
        _fundFee = fee;
    }

    function setFomoFee(uint256 fee) public onlyOwner {
        _fomoFee = fee;
    }

    function setCommunityFee(uint256 fee) public onlyOwner {
        _communityFee = fee;
    }

    function setLpFee(uint256 fee) public onlyOwner {
        _lpFee = fee;
    }

    function setInviterFee(uint256 fee) public onlyOwner {
        _inviterFee = fee;
    }

    function setInviteRate(uint256[] memory rate) public onlyOwner {
        require(rate.length > 0);
        _inviterRate = rate;
    }

    function setMaxTradeAmount(uint256 maxTx) external onlyOwner() {
        _maxTradeAmount = maxTx;
    }

    function setMinRemainAmount(uint256 amount) external onlyOwner() {
        _minRemainAmount = amount;
    }

    function setInviterHolderAmount(uint256 amount) external onlyOwner() {
        _inviterHolderAmount = amount;
    }

    function setFomoAmount(uint256 amount) external onlyOwner() {
        _fomoAmount = amount;
    }

    function setMarketingAddres(address marketingAddress_) public onlyOwner {
        marketingAddress = marketingAddress_;
    }

    function setFundAddres(address fundAddress_) public onlyOwner {
        fundAddress = fundAddress_;
    }

    function setRemainAddress(address remainAddress_) public onlyOwner {
        remainAddress = remainAddress_;
    }

    function setFomoAddress(address fomoAddress_) public onlyOwner {
        fomoAddress = fomoAddress_;
    }

    function setCommunityAddres(address communityAddress_) public onlyOwner {
        communityAddress = communityAddress_;
    }

    function setUsdtPairAddress(address uniswapV2Pair_) public onlyOwner {
        uniswapV2UsdtPair = uniswapV2Pair_;
    }

     function setBnbPairAddress(address uniswapV2Pair_) public onlyOwner {
        uniswapV2BnbPair = uniswapV2Pair_;
    }

    function setRouterAddress(address routerAddress_) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(routerAddress_);
    }

    function setFomoMinPeriod(uint256 fomoMinPeriod_) public onlyOwner {
        fomoMinPeriod = fomoMinPeriod_;
    }

    function setMinFomoReward(uint256 amount) public onlyOwner {
        _minFomoReward = amount;
    }

    function setMaxFeeStop(uint256 amount) public onlyOwner {
        _maxStopFee = amount;
    }

    function setFomoRewardRate(uint256 rate) public onlyOwner {
        _fomoRewardRate = rate;
    }

    function setBlacklist(address account, bool state) public onlyOwner() {
        _isBlackList[account] = state;
    }

    function checkInviter(address addr, address parent) public view returns(bool) {
        for(uint i=0; i< _inviterRate.length;i++) {
            if(parent == address(0) ) break;

            if (parent == addr) {
                return false;
            }

            parent = inviter[parent];
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


    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {
        if(_communityFee == 0 && _burnFee == 0 && _fomoFee == 0 && _inviterFee == 0 && _fundFee == 0 && _lpFee == 0) return;

        _previousBurnFee = _burnFee;
        _previousCommunityFee = _communityFee;
        _previousLpFee = _lpFee;
        _previousFomoFee = _fomoFee;
        _previousFundFee = _fundFee;
        _previousMarketingFee = _marketingFee;
        _previousInviterFee = _inviterFee;
        
        _burnFee = 0;
        _communityFee = 0;
        _marketingFee = 0;
        _lpFee = 0;
        _fomoFee = 0;
        _fundFee = 0;
        _inviterFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _communityFee = _previousCommunityFee;
        _marketingFee = _previousMarketingFee;
        _lpFee = _previousLpFee;
        _fomoFee = _previousFomoFee;
        _fundFee = _previousFundFee;
        _inviterFee = _previousInviterFee;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != to, "ERC20: transfer from is the same as to ");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlackList[from] == false, "from is in blacklist");
        require(_isBlackList[to] == false, "to is in blacklist");

         if( _isSwapPair[from] &&  !_isExcludedFromFee[to]   ){
            require(amount <= _maxTradeAmount, "Trade amount too high");
        }

        if( _isSwapPair[to] && !_isExcludedFromFee[from] ){
            require(amount <= _maxTradeAmount, "Trade amount too high");
        }

        if (!isContract(from)) {
            require(amount <= balanceOf(from).sub(_minRemainAmount), 'amount is low');
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee

        if (_tTotal <= _maxStopFee) {
            takeFee = false;
        } else {
            if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
                takeFee = false;
            }
        }
        
        _tokenTransfer(from, to, amount, takeFee);
        
        if(takeFee && _isSwapPair[from]) {
            fomoProcess(amount, to);
        }

    }

    function fomoProcess(uint256 amount, address account) private {
        if (getUsdtValue(amount) >= _fomoAmount) {

            fomoRewardAddress[fomoIndex] = account;

            fomoIndex += 1;
            if(fomoIndex > 2) {
                fomoIndex = 0;
            }
        }

        if (block.timestamp > fomoLastTime) {
            uint256 fomoReward = balanceOf(fomoAddress) * _fomoRewardRate / 100;
            uint256 perFomoReward = fomoReward / 3;
            
            if(perFomoReward >= _minFomoReward) {
                uint256 remainReward = fomoReward;
                for(uint i = 0; i < 3; i++) {
                    address from = fomoAddress;
                    address to = fomoRewardAddress[i];

                    if (to == address(0)) {
                        continue;
                    }

                    fomoRewardAddress[i] = address(0);

                    _tOwned[from] = _tOwned[from].sub(perFomoReward);
                    _tOwned[to] = _tOwned[to].add(perFomoReward);
                    remainReward = remainReward.sub(perFomoReward);
                    emit Transfer(from, to, perFomoReward);
                }

                fomoIndex = 0;

                if (remainReward > 0) {
                    _tOwned[remainAddress] = _tOwned[remainAddress].add(remainReward);
                    emit Transfer(fomoAddress, remainAddress, remainReward);
                }
            }
        } 
        fomoLastTime = block.timestamp + fomoMinPeriod;

    }
    

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if(!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if(!takeFee) restoreAllFee();
    }

    //
    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        _tTotal = _tTotal.sub(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_lpFee == 0) return;
        (uint256 bnbAmount, uint256 usdtAmount) = getLpAmount(tAmount);
        if (bnbAmount > 0) {
            _tOwned[uniswapV2BnbPair] = _tOwned[uniswapV2BnbPair].add(bnbAmount);
            emit Transfer(sender, uniswapV2BnbPair, bnbAmount);
        }

        if (usdtAmount > 0) {
            _tOwned[uniswapV2UsdtPair] = _tOwned[uniswapV2UsdtPair].add(usdtAmount);
            emit Transfer(sender, uniswapV2UsdtPair, usdtAmount);
        }
     
    }

    function getLpAmount(uint256 amount) public view returns(uint256, uint256) {
        uint256 bnbLpBalance = balanceOf(uniswapV2BnbPair);
        uint256 usdtLpBalance = balanceOf(uniswapV2UsdtPair);
        uint256 total = bnbLpBalance.add(usdtLpBalance);
        if (total == 0) {
            return (0, 0);
        }
        return (amount.mul(bnbLpBalance).div(total),amount.mul(usdtLpBalance).div(total));
    }

    function getUsdtValue(uint256 _amount) public view returns(uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2UsdtPair);
        IERC20 token1 = IERC20(pair.token1());
        (uint256 Res0, uint256 Res1,) = pair.getReserves();

        if (Res0 >0 && Res1 > 0) {
            if (address(token1) == address(this)) {
                return _amount.mul(Res0).div(Res1);
            } else {
                return _amount.mul(Res1).div(Res0);
            }     
        }
        
        return 0;
    }

    function _takeMarketingFee(address sender,uint256 tAmount) private {
        if (_marketingFee == 0) return;
        _tOwned[marketingAddress] = _tOwned[marketingAddress].add(tAmount);
        emit Transfer(sender, marketingAddress, tAmount);
    }

    function _takeCommunityFee(address sender,uint256 tAmount) private {
        if (_communityFee == 0) return;
        _tOwned[communityAddress] = _tOwned[communityAddress].add(tAmount);
        emit Transfer(sender, communityAddress, tAmount);
    }

    function _takeFundFee(address sender,uint256 tAmount) private {
        if (_fundFee == 0) return;
        _tOwned[fundAddress] = _tOwned[fundAddress].add(tAmount);
        emit Transfer(sender, fundAddress, tAmount);
    }

    function _takeFomoFee(address sender,uint256 tAmount) private {
        if (_fomoFee == 0) return;
        _tOwned[fomoAddress] = _tOwned[fomoAddress].add(tAmount);
        emit Transfer(sender, fomoAddress, tAmount);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;
        address cur;
        if (_isSwapPair[sender]) {
            cur = recipient;
        } else {
            cur = sender;
        }

        uint256 accurRate;
        for (uint256 i = 0; i < 8; i++) {
            uint256 rate = _inviterRate[i];
            cur = inviter[cur];

            if (cur == address(0)) {
                break;
            }
            uint256 curBalance = balanceOf(cur);
            if(curBalance < _inviterHolderAmount) {
                continue;
            }
            accurRate = accurRate.add(rate);
            uint256 curTAmount = tAmount.div(10000).mul(rate);
            _tOwned[cur] = _tOwned[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }
        uint256 remain = tAmount.div(10000).mul(_inviterFee.sub(accurRate));
        if (remain > 0) {
            _tOwned[remainAddress] = _tOwned[remainAddress].add(remain);
            emit Transfer(sender, remainAddress, remain);
        }  
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _takeCommunityFee(sender, tAmount.div(10000).mul(_communityFee));
        _takeFundFee(sender, tAmount.div(10000).mul(_fundFee));
        _takeMarketingFee(sender, tAmount.div(10000).mul(_marketingFee));
        _takeLPFee(sender, tAmount.div(10000).mul(_lpFee));
        _takeFomoFee(sender, tAmount.div(10000).mul(_fomoFee));
        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));
        _takeInviterFee(sender, recipient, tAmount);
       
        uint256 recipientRate = 10000 - _communityFee - _fundFee - _marketingFee - _lpFee - _fomoFee - _burnFee - _inviterFee;
        _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(10000).mul(recipientRate));
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }

}