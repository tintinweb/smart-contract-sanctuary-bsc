/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/Token.sol

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;



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

interface Bank {
    function addRewards(address token, uint256 amount) external;
}

contract Token is IERC20, Ownable {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    uint256 public override totalSupply;

    string public name;
    uint8 public decimals;
    string public symbol;

    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isExcludedFromFee;

    address public BUSD_CONTRACT;
    IUniswapV2Router02 public router;
    address public liquidityPair;
    mapping(address => bool) public isLiquidityPair;

    struct Fees {
        uint8 buy;
        uint8 sale;
        uint8 transfer;
    }

    Fees public fees = Fees({buy: 10, sale: 10, transfer: 10});

    // [rewards, growth, bank]
    address[] public feesReceivers = [
        0x000000000000000000000000000000000000dEaD,
        0x000000000000000000000000000000000000dEaD,
        0x000000000000000000000000000000000000dEaD
    ];

    // [rewards, liqudity, growth, bank]
    uint8[] buyFeesDistribution = [10, 20, 50, 20];
    uint8[] saleFeesDistribution = [10, 20, 50, 20];
    uint8[] transferFeesDistribution = [10, 20, 50, 20];

    // [rewards, liqudity, growth, total]
    uint256[] public feesCounter = [0, 0, 0, 0, 0];

    uint256 public swapThreshold = 100e18;

    bool public executeSwapsActive = true;

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        address _BUSD_CONTRACT,
        address _router
    ) {
        balances[_msgSender()] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;

        BUSD_CONTRACT = _BUSD_CONTRACT;

        router = IUniswapV2Router02(_router);
        liquidityPair = IPancakeFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        isLiquidityPair[liquidityPair] = true;

        _approve(msg.sender, _router, type(uint256).max);
        _approve(address(this), _router, type(uint256).max);

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[_msgSender()] = true;

        emit Transfer(address(0), _msgSender(), _initialAmount);
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function _transferExcluded(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function _transferNoneExcluded(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;

        uint256 feeValue = 0;
        uint8[] memory feesDistribution;

        if (isLiquidityPair[_from]) {
            // buy
            feeValue = (_value * fees.buy) / 100;
            feesDistribution = buyFeesDistribution;
        } else if (isLiquidityPair[_to]) {
            // sell
            feeValue = (_value * fees.sale) / 100;
            feesDistribution = saleFeesDistribution;
        } else {
            // transfer
            feeValue = (_value * fees.transfer) / 100;
            feesDistribution = transferFeesDistribution;
        }

        uint256 receivedValue = _value - feeValue;

        // REWARDS POOL
        uint256 rewardsFee = (feeValue * feesDistribution[0]) / 100;
        feesCounter[0] += rewardsFee;
        balances[feesReceivers[0]] += rewardsFee;
        emit Transfer(_from, feesReceivers[0], rewardsFee);

        // LIQUIDITY AND GROWTH
        for (uint8 i = 1; i < 4; i++) {
            feesCounter[i] += (feeValue * feesDistribution[i]) / 100;
        }
        feesCounter[4] += feeValue - rewardsFee;
        if (feesCounter[4] >= swapThreshold && executeSwapsActive)
            _executeSwaps();

        balances[_to] += receivedValue;
        emit Transfer(_from, _to, receivedValue);
    }

    function _executeSwaps() private {
        uint256 toLiquidity = feesCounter[1] / 2;
        uint256 toGrowth = feesCounter[2];
        uint256 toBank = feesCounter[3];

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            toGrowth + toLiquidity,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 bnbBalance = address(this).balance;

        router.addLiquidityETH{
            value: (bnbBalance * toLiquidity) / feesCounter[4]
        }(address(this), toLiquidity, 0, 0, owner(), block.timestamp);

        (bool sent, ) = feesReceivers[1].call{
            value: (bnbBalance * toGrowth) / feesCounter[4]
        }("");
        require(sent, "Failed to send Ether to growth");

        Bank(feesReceivers[3]).addRewards(address(this), toBank);
        balances[feesReceivers[3]] += toBank;
        emit Transfer(msg.sender, feesReceivers[3], toBank);

        feesCounter[1] = 0;
        feesCounter[2] = 0;
        feesCounter[3] = 0;
        feesCounter[4] = 0;
    }

    function _executeTransfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        if (isExcludedFromFee[_from] || isExcludedFromFee[_to])
            _transferExcluded(_from, _to, _value);
        else _transferNoneExcluded(_from, _to, _value);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(
            _from != address(0),
            "TRANSFER: Transfer from the dead address"
        );
        require(_to != address(0), "TRANSFER: Transfer to the dead address");
        require(_value > 0, "TRANSFER: Invalid amount");
        require(isBlacklisted[_from] == false, "TRANSFER: isBlacklisted");
        require(balances[_from] >= _value, "TRANSFER: Insufficient balance");
        _executeTransfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        _transfer(_msgSender(), _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        if (allowances[_from][_msgSender()] < type(uint256).max) {
            allowances[_from][_msgSender()] -= _value;
        }
        _transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool success)
    {
        _approve(_msgSender(), _spender, _value);
        return true;
    }

    function _approve(
        address _sender,
        address _spender,
        uint256 _value
    ) private returns (bool success) {
        allowances[_sender][_spender] = _value;
        emit Approval(_sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }

    /***********************************|
    |         Owner Functions           |
    |__________________________________*/

    function setIsBlacklisted(address user, bool value) public onlyOwner {
        isBlacklisted[user] = value;
    }

    function setIsExcludedFromFee(address user, bool value) public onlyOwner {
        isExcludedFromFee[user] = value;
    }

    function approveOnRouter() public onlyOwner {
        _approve(address(this), address(router), type(uint256).max);
    }

    function setRouter(address _router) public onlyOwner {
        router = IUniswapV2Router02(_router);
        liquidityPair = IPancakeFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        isLiquidityPair[liquidityPair] = true;

        _approve(address(this), _router, type(uint256).max);

        isExcludedFromFee[address(this)] = true;
    }

    function setFees(
        uint8 buy_,
        uint8 sale_,
        uint8 transfer_
    ) public onlyOwner {
        fees = Fees({buy: buy_, sale: sale_, transfer: transfer_});
    }

    function setFeesReceivers(address[] memory value) public onlyOwner {
        feesReceivers = value;
    }

    function setBuyFeesDistribution(uint8[] memory value) public onlyOwner {
        buyFeesDistribution = value;
    }

    function setSaleFeesDistribution(uint8[] memory value) public onlyOwner {
        saleFeesDistribution = value;
    }

    function setTransferFeesDistribution(uint8[] memory value)
        public
        onlyOwner
    {
        transferFeesDistribution = value;
    }

    function setSwapThreshold(uint256 value) public onlyOwner {
        swapThreshold = value;
    }

    function setExecuteSwapsActive(bool value) public onlyOwner {
        executeSwapsActive = value;
    }
}