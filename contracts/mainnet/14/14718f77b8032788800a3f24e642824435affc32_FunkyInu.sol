/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * Funky INU NFT Based MEME Token
 *Telegram adress: https://t.me/FunkyINU
 *twitter: https://twitter.com/RS25FunkyINU/status/1581262016043692033?t=M2NUVTHsvFlTlqZQuf2_Eg&s=19
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

contract FunkyInu is IERC20, Ownable {
    
    uint8 private _decimals = 18;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private lastTransactionTime;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    string private _name = "FunkyInu";
    string private _symbol = "FNU";

    bool private buying;
    bool private selling;

    uint16 private _rewardFee;
    uint16 private _previousRewardFee;

    uint16 private _burnFee;
    uint16 private _previousBurnFee;

    uint16 private _marketingFee;
    uint16 private _previousMarketingFee;

    uint16 public sellRewardFee = 3;
    uint16 public buyRewardFee = 3;

    uint16 public sellBurnFee = 2;
    uint16 public buyBurnFee = 2;

    uint16 public sellMarketingFee = 5;
    uint16 public buyMarketingFee = 5;

    uint256 public maxWallet;
    uint256 public maxTransactionAmount;

    address public marketingWallet;
    address public teamWallet;

    uint256 contractDeployTime; 

    IPancakeRouter02 public mainRouter;
    address public mainPair;
    mapping(address => bool) public isExcludedFromMaxTransactionAmount;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateBurnFee(
        uint16 newSellBurnFee,
        uint16 newBuyBurnFee,
        uint16 oldSellBurnFee,
        uint16 oldBuyBurnFee
    );
    event UpdateMarketingFee(
        uint16 newSellMarketingFee,
        uint16 newBuyMarketingFee,
        uint16 oldSellMarketingFee,
        uint16 oldBuyMarketingFee
    );
    event UpdateRewardFee(
        uint16 newSellRewardFee,
        uint16 newBuyRewardFee,
        uint16 oldSellRewardFee,
        uint16 oldBuyRewardFee
    );  
    event UpdateMarketingWallet(
        address indexed newMarketingWallet,
        address indexed oldMarketingWallet
    );
    event UpdateTeamWallet(
        address indexed newTeamWallet,
        address indexed oldTeamWallet
    );

    event SetAutomatedMarketMakerPair(address indexed pair, bool value);
    event ExcludedFromFee(address indexed account, bool isEx);
    event UpdatePancakeRouter(address indexed newAddress, address indexed oldRouter);
    event ExcludedFromMaxTransactionAmount(address indexed account, bool isExcluded);
    event UpdateMaxWallet(uint256 newMaxWallet, uint256 oldMaxWallet);
    event UpdateMaxTransactionAmount(uint256 newMaxTransactionAmount, uint256 oldMaxTransactionAmount);

    constructor(
        uint16 _maxWallet,
        uint16 _maxTransactionAmount,
        address _tokenOwner, 
        address _teamWallet,
        address _marketingWallet
    ) {

       _rOwned[_tokenOwner] = _rTotal;
       contractDeployTime = block.timestamp;
       require(_tokenOwner != address(0), "Token owner wallet can not be 0");
       require(_teamWallet != address(0), "Team wallet can not be 0");
       require(_marketingWallet!= address(0), "Marketing wallet can not be 0");
       
       marketingWallet = _marketingWallet;
       teamWallet = _teamWallet;
       mainRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
       mainPair = IPancakeFactory(mainRouter.factory()).createPair(address(this),mainRouter.WETH());
       
       require(_maxTransactionAmount>0, "maxTransactionAmount > 0");
       require(_maxWallet>0, "maxWallet > 0");
       maxWallet = _tTotal * (_maxWallet) / (10**2);
       maxTransactionAmount= _tTotal * (_maxTransactionAmount) / (10**2);
       _isExcluded[address(0xdead)] = true;
       _excluded.push(address(0xdead));
       isExcludedFromFee[address(this)] = true;
       isExcludedFromFee[marketingWallet] = true;
       isExcludedFromFee[teamWallet] = true;
       isExcludedFromFee[_tokenOwner] = true;
       isExcludedFromFee[address(0xdead)] = true;
       isExcludedFromMaxTransactionAmount[address(0xdead)]=true;
       isExcludedFromMaxTransactionAmount[address(this)]=true;
       isExcludedFromMaxTransactionAmount[marketingWallet]=true;
       isExcludedFromMaxTransactionAmount[teamWallet]=true;
       isExcludedFromMaxTransactionAmount[_tokenOwner]=true;
       _setAutomatedMarketMakerPair(mainPair, true);
       emit Transfer(address(0), _tokenOwner, _tTotal);
    }

    function updatePancakePair() external onlyOwner
    {
        mainPair = IPancakeFactory(mainRouter.factory()).createPair(
            address(this),
            mainRouter.WETH()
        );
    }

    function updatePancakeRouter(address newAddress) public onlyOwner {
        require(
            newAddress != address(mainRouter),
            "The router already has that address"
        );
        emit UpdatePancakeRouter(newAddress, address(mainRouter));
        mainRouter = IPancakeRouter02(newAddress);
        address _mainPair = IPancakeFactory(mainRouter.factory())
            .createPair(address(this), mainRouter.WETH());
        mainPair = _mainPair;
    }
    function updateMaxWallet(uint256 _maxWallet) external onlyOwner {
        require(_maxWallet>0, "maxWallet > 0");
        _maxWallet = _tTotal * (_maxWallet) / (10**2);
        emit UpdateMaxWallet(_maxWallet, maxWallet);
        maxWallet = _maxWallet;
    }

    function updateMaxTransactionAmount(uint256 _maxTransactionAmount)
        external
        onlyOwner
    {
        require(_maxTransactionAmount>0, "maxTransactionAmount > 0");
        _maxTransactionAmount = _tTotal * (_maxTransactionAmount) / (10**2);
        emit UpdateMaxTransactionAmount(_maxTransactionAmount, maxTransactionAmount);
        maxTransactionAmount = _maxTransactionAmount;
    }   
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketing,
            uint256 tBurn
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _rOwned[recipient] = _rOwned[recipient]+(rTransferAmount);
        _tTotal = _tTotal - (tBurn);
        _reflectFee(rFee, tFee);
        _takeMarketingFee(tMarketing);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketing,
            uint256 tBurn
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _tOwned[recipient] = _tOwned[recipient]+(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient]+(rTransferAmount);
        _tTotal = _tTotal - (tBurn);
        _reflectFee(rFee, tFee);
        _takeMarketingFee(tMarketing);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketing,
            uint256 tBurn
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender]-(tAmount);
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _rOwned[recipient] = _rOwned[recipient]+(rTransferAmount);
        _tTotal = _tTotal - (tBurn);
        _reflectFee(rFee, tFee);
        _takeMarketingFee(tMarketing);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketing,
            uint256 tBurn
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender]-(tAmount);
        _rOwned[sender] = _rOwned[sender]-(rAmount);
        _tOwned[recipient] = _tOwned[recipient]+(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient]+(rTransferAmount);
        _tTotal = _tTotal - (tBurn);
        _reflectFee(rFee, tFee);
        _takeMarketingFee(tMarketing);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal-(rFee);
        _tFeeTotal = _tFeeTotal+(tFee);
    }

    function _getValues(uint256 tAmount)
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
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tMarketing,
            uint256 tBurn
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tMarketing,
            tBurn,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tMarketing,
            tBurn
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateRewardFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tTransferAmount = tAmount-(tFee)-(tMarketing)-(tBurn);
        return (tTransferAmount, tFee, tMarketing, tBurn);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tMarketing,
        uint256 tBurn,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount*(currentRate);
        uint256 rFee = tFee*(currentRate);
        uint256 rMarketing = tMarketing*(currentRate);
        uint256 rBurn = tBurn*(currentRate);
        uint256 rTransferAmount = rAmount-(rFee)-(rMarketing)-(rBurn); 
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply-(_rOwned[_excluded[i]]);
            tSupply = tSupply-(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal/(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function removeAllFee() private {
        if (_rewardFee == 0 && _burnFee == 0 && _marketingFee == 0) return;

        _previousRewardFee = _rewardFee;
        _previousBurnFee = _burnFee;
        _previousMarketingFee = _marketingFee;

        _marketingFee = 0;
        _rewardFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _rewardFee = _previousRewardFee;
        _burnFee = _previousBurnFee;
        _marketingFee = _previousMarketingFee;
    }

    function calculateRewardFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount*(_rewardFee)/(10 ** 2);
    }

    function calculateBurnFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount*(_burnFee)/(10 ** 2);
    }

    function calculateMarketingFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount*(_marketingFee)/(10 ** 2);
    }

    function _takeMarketingFee(uint256 tMarketing) private {
        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing*(currentRate);
        if(buying){
            _rOwned[marketingWallet] = _rOwned[marketingWallet]+(
            rMarketing
            );
            if (_isExcluded[marketingWallet]){
                _tOwned[marketingWallet] = _tOwned[marketingWallet]+(
                    tMarketing
                );
            }  
            buying = false;
        }
        if(selling){
            _rOwned[teamWallet] = _rOwned[teamWallet]+(
            rMarketing
            );
            if (_isExcluded[teamWallet]){
                _tOwned[teamWallet] = _tOwned[teamWallet]+(
                    tMarketing
                );
            }    
            selling = false;
        }
        
    }

    /////////////////////////////////////////////////////////////////////////////////
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()]-amount
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender]+(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender]-(
                subtractedValue
            )
        );
        return true;
    }

    function isExcludedFromReward(address account)
        external
        view
        returns (bool)
    {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        external
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount/(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        require(
            _excluded.length + 1 <= 50,
            "Cannot exclude more than 50 accounts.  Include a previously excluded address."
        );
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                uint256 prev_rOwned=_rOwned[account];
                _rOwned[account]=_tOwned[account]*_getRate();
                _rTotal=_rTotal+_rOwned[account]-prev_rOwned;
                _isExcluded[account] = false;
                _excluded[i] = _excluded[_excluded.length - 1];
                _excluded.pop();
                break;
            } 
        }
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

    function updateBurnFee(
        uint16 _sellBurnFee,
        uint16 _buyBurnFee
    ) external onlyOwner {
        require(
            _sellBurnFee+(sellMarketingFee)+(sellRewardFee) <= 20,
            "sell fee <= 20%"
        );
        require(
            _buyBurnFee+(buyMarketingFee)+(buyRewardFee) <= 20,
            "buy fee <= 20%"
        );
        emit UpdateBurnFee(
            _sellBurnFee,
            _buyBurnFee,
            sellBurnFee,
            buyBurnFee
        );
        sellBurnFee = _sellBurnFee;
        buyBurnFee = _buyBurnFee;
    }

    function updateMarketingFee(
        uint16 _sellMarketingFee,
        uint16 _buyMarketingFee
    ) external onlyOwner {
        require(
            _sellMarketingFee+(sellBurnFee)+(sellRewardFee) <= 20,
            "sell fee <= 20%"
        );
        require(
            _buyMarketingFee+(buyBurnFee)+(buyRewardFee) <= 20,
            "buy fee <= 20%"
        );
        emit UpdateMarketingFee(
            _sellMarketingFee,
            _buyMarketingFee,
            sellMarketingFee,
            buyMarketingFee
        );
        sellMarketingFee = _sellMarketingFee;
        buyMarketingFee = _buyMarketingFee;        
    }

    function updateRewardFee(
        uint16 _sellRewardFee,
        uint16 _buyRewardFee
    ) external onlyOwner {
        require(
            _sellRewardFee+(sellBurnFee)+(sellMarketingFee) <= 20,
            "sell fee <= 20%"
        );
        require(
            _buyRewardFee+(buyBurnFee)+(buyMarketingFee) <= 20,
            "buy fee <= 20%"
        );
        emit UpdateRewardFee(
            _sellRewardFee, 
            _buyRewardFee,
            sellRewardFee, 
            buyRewardFee
        );
        sellRewardFee = _sellRewardFee;
        buyRewardFee = _buyRewardFee;
    }

    function updateMarketingWallet(
        address _marketingWallet
    ) external onlyOwner {
        require(_marketingWallet != address(0), "marketing wallet can't be 0");
        emit UpdateMarketingWallet(_marketingWallet,
            marketingWallet);
        marketingWallet = _marketingWallet;
        isExcludedFromFee[_marketingWallet] = true;
    }
 
    function updateTeamWallet(
        address _teamWallet
    ) external onlyOwner {
        require(_teamWallet != address(0), "team wallet can't be 0");
        emit UpdateTeamWallet(_teamWallet,
            teamWallet);
        teamWallet = _teamWallet;
        isExcludedFromFee[_teamWallet] = true;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;
        if (value) excludeFromReward(pair);
        else includeInReward(pair);
        isExcludedFromMaxTransactionAmount[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFee(address account, bool isEx) external onlyOwner {
        require(isExcludedFromFee[account] != isEx, "already");
        isExcludedFromFee[account] = isEx;
        emit ExcludedFromFee(account, isEx);
    }
    function excludeFromMaxTransactionAmount(address account, bool isEx)
        external
        onlyOwner
    {
        require(isExcludedFromMaxTransactionAmount[account]!=isEx, "already");
        isExcludedFromMaxTransactionAmount[account] = isEx;
        emit ExcludedFromMaxTransactionAmount(account, isEx);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        // antibot works for the 10 minutes withing the deployment of the contract
        if(contractDeployTime + 10 minutes > block.timestamp){
            if(from != mainPair && from != owner() && to != owner()){
                require(block.timestamp > lastTransactionTime[from] + 5 minutes);
                lastTransactionTime[to] = block.timestamp;
            }
            if(to != mainPair && from != owner() && to != owner()){
                require(block.timestamp > lastTransactionTime[to] + 5 minutes);
                lastTransactionTime[to] = block.timestamp;
            }        
        }   

        if((from != owner() && to != owner()) || !isExcludedFromMaxTransactionAmount[from])
            require(amount <= maxTransactionAmount, "Transfer amount exceeds the maxTxAmount.");

        if(from != owner() && to != owner() && to != address(0) && to != address(0xdead) && to != mainPair){
            uint256 contractBalanceRecepient = balanceOf(to);
            require(contractBalanceRecepient + amount <= maxWallet, "Exceeds maximum wallet amount"); 
        }    

        removeAllFee();

        // If any account belongs to isExcludedFromFee account then remove the fee
        if (
            !isExcludedFromFee[from] &&
            !isExcludedFromFee[to]
        ) {
            // Buy
            if (automatedMarketMakerPairs[from]) {
                _rewardFee = buyRewardFee;
                _burnFee = buyBurnFee;
                _marketingFee = buyMarketingFee;
                buying = true;
            }
            // Sell
            else if (automatedMarketMakerPairs[to]) {
                _rewardFee = sellRewardFee;
                _burnFee = sellBurnFee;
                _marketingFee = sellMarketingFee;
                selling = true;
            }
        }
        _tokenTransfer(from, to, amount);
        restoreAllFee();
        
    }

    receive() external payable {}
}