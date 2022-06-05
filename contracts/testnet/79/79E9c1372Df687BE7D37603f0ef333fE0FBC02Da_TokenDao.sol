/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

//SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at BscScan.com on 2022-03-13     
 */

pragma solidity 0.6.12;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender)
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


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value:amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value:weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address SwapPair);
}

interface IPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);

    function token1() external view returns (address);

    function factory() external view returns (address);
}

contract SwapTool {
    address public SwapPair;
    IRouter internal SwapV2Router;

    function initIRouter(address _router) internal {
        SwapV2Router = IRouter(_router);
        SwapPair = IFactory(SwapV2Router.factory()).createPair(
            address(this),
            SwapV2Router.WETH()
        );
    }

    function swapTokensForTokens(
        uint256 tokenAmount,
        address tokenDesireAddress
    ) internal {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = SwapV2Router.WETH();
        path[2] = tokenDesireAddress;
        SwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 amountDesire, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = SwapV2Router.WETH();
        SwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountDesire,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function getPoolInfo()
        public
        view
        returns (uint112 WETHAmount, uint112 TOKENAmount)
    {
        (uint112 _reserve0, uint112 _reserve1, ) = IPair(SwapPair)
            .getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPair(SwapPair).token0() == SwapV2Router.WETH()) {
            WETHAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }

    function getPrice4ETH(uint256 amountDesire)
        internal
        view
        returns (uint256)
    {
        (uint112 WETHAmount, uint112 TOKENAmount) = getPoolInfo();
        return (WETHAmount * amountDesire) / TOKENAmount;
    }

    function getLPTotal(address user) internal view returns (uint256) {
        return IBEP20(SwapPair).balanceOf(user);
    }

    function getTotalSupply() internal view returns (uint256) {
        return IBEP20(SwapPair).totalSupply();
    }
}

contract TokenDao is Context, IBEP20, Ownable, SwapTool {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    address private _SwapRouter;
    address[] private _lockAddress;
    address private _making;

    uint256 private cPercent;
    uint256 private burnFee;

    uint256 private divBase;
    uint256 private size;

    uint256 private _maxDeals;
    uint256 private _maxHold;

    uint256 private rewardMin;
    uint256 private totalReward;
    uint256 private mustRemain;

    mapping(address => bool) private tokenHold;
    address[] private tokenHolders;

    address internal manager;
    uint256 internal managerFee;
    // uint256 preRewardTime;
    uint256 nextRewardTime;
    uint256 uRewardsInterval;

    mapping(address => bool) public isRouter;
    mapping(address => bool) public checkedIsNotRouter;

    mapping(address => bool) public checkedIsNotPair;
    mapping(address => uint256) public _totalLp;
    mapping(address => bool) public isPair;
    mapping(address => address) public otherToken;

    event RewardLogs(address indexed account, uint256 amount);

    constructor(
        string memory __name,
        string memory __symbol,
        uint8 __decimals,
        address _manager,    // 基金地址 
        address _router   // fst mainmetrouter: 0x1B6C9c20693afDE803B27F8782156c0f892ABC2d
    ) public {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
        size = 1 * 10**uint256(_decimals);
        _maxDeals = 130000 * size;    // 最大交易数
        _maxHold = 130000 * size;    // 最大持有数
        rewardMin = 500 * size;    // 达到才进行lp分红
        _totalSupply = 130000 * size;
        divBase = 1000;    // 以下所有扣费费率之和不能高于这个数值

        cPercent = 15;  // 买卖添加移除转账扣费1.5% 
        burnFee = 15;   // 销毁费率 1.5%        

        manager = _manager;
        managerFee = 5;    // 基金费率 从买卖添加移除转账扣费中扣除，不能高于cPercent
        uRewardsInterval = 28800;   // 每次分红后间隔多长时间才可以再次进行lp分红

        mustRemain = 1;    // 账户必须保留 0.1%


        _balances[msg.sender] = _totalSupply;
        tokenHold[msg.sender] = true;
        _making = msg.sender;

        _SwapRouter = _router;
        initIRouter(_SwapRouter);
        _approve(address(this), _SwapRouter, ~uint256(0));
        _approve(owner(), _SwapRouter, ~uint256(0));
        emit Transfer(address(0), msg.sender, _totalSupply);

        checkedIsNotPair[msg.sender] = true;
        checkedIsNotPair[manager] = true;
        checkedIsNotPair[address(this)] = true;
        checkedIsNotPair[_router] = true;
        checkedIsNotRouter[msg.sender] = true;
        checkedIsNotRouter[manager] = true;
        checkedIsNotRouter[address(this)] = true;
        isRouter[_router] = true;
    }

        modifier checkIsRouter(address _sender) {
        {
            if (!isRouter[_sender] && !checkedIsNotRouter[_sender]) {
                if (address(_sender).isContract()) {
                    IRouter _routerCheck = IRouter(
                        _sender
                    );
                    try _routerCheck.WETH() returns (address) {
                        try _routerCheck.factory() returns (address) {
                            isRouter[_sender] = true;
                        } catch {
                            checkedIsNotRouter[_sender] = true;
                        }
                    } catch {
                        checkedIsNotRouter[_sender] = true;
                    }
                } else {
                    checkedIsNotRouter[_sender] = true;
                }
            }
        }

        _;
    }

    modifier checkIsPair(address _sender) {
        {
            if (!isPair[_sender] && !checkedIsNotPair[_sender]) {
                if (_sender.isContract()) {
                    IPair _pairCheck = IPair(_sender);
                    try _pairCheck.token0() returns (address) {
                        try _pairCheck.token1() returns (address){
                            try _pairCheck.factory() returns (address) {
                                address _token0 = _pairCheck.token0();
                                address _token1 = _pairCheck.token1();
                                address this_token = address(this) == _token0 ? _token0 : address(this) == _token1 ? _token1 : address(0);
                                if(this_token != address(0)) {
                                    otherToken[_sender] = address(this) == _token0 ? _token1 : address(this) == _token1 ? _token0: address(0);
                                } else{
                                   checkedIsNotPair[_sender] = true; 
                                }

                            } catch {
                                checkedIsNotPair[_sender] = true;
                            }
                        } catch {
                            checkedIsNotPair[_sender] = true;
                        }

                    } catch {
                        checkedIsNotPair[_sender] = true;
                    }
                } else {
                    checkedIsNotPair[_sender] = true;
                }
            }
        }

        _;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */

    //The token Swap  5%
    //Increased liquidity and transaction number is 5
    function transfer(address recipient, uint256 amount)
        external override checkIsPair(msg.sender) checkIsPair(recipient)
        returns (bool)
    {
        if (!Address.isContract(address(msg.sender)) && address(msg.sender) != owner()) {
            require(
                amount <= _balances[address(msg.sender)].mul(divBase.sub(mustRemain)).div(divBase)
            );
        }      
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) 
    external override checkIsPair(msg.sender) checkIsPair(sender) checkIsPair(recipient) 
    returns (bool) {
        if (!address(sender).isContract() && Address.isContract(address(msg.sender)) && sender != owner()) {
            require(amount <= _balances[sender].mul(divBase.sub(mustRemain)).div(divBase));
        }

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
 
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }


    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal 
    checkIsRouter(msg.sender) checkIsRouter(msg.sender) checkIsRouter(recipient)
    {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTransfer(sender, recipient, amount);

        address user = isRouter[sender] || isPair[sender]  // 如果转出方为router或者pair
        ?isRouter[recipient] || isPair[recipient]   // 转出方为router或者pair，如果接受方为router 或者 pair
        ? address(0) : recipient                    // 转出方为router 或者 pair 同时接受方为router 或者 pair ，用户为空地址，否则用户为接受方
        : sender;                                  // 转出方不为router或者pair， 用户为sender

        uint256 _cFee = user == address(0) || user == owner() ? 0 : (amount / divBase) * uint256(cPercent);
        uint256 _bFee = user == address(0) || user == owner() ? 0 : (amount / divBase) * uint256(burnFee);
        uint256 totalFee = _cFee.add(_bFee);

        if(user == sender && totalFee > 0){
            require(_balances[user] >= amount.add(totalFee), "BEP20: transfer amount exceeds balance");
        } 

        _customTransfer(sender, recipient, amount);

        if(_bFee >0 && user != address(0)) {
            _burn(user, _bFee);
        }
        
        if(_cFee>0 && user != address(0) ){ 
            _customTransfer(user, address(this), _cFee); 
            totalReward = totalReward.add(_cFee);
        } 

        if(isPair[sender]){
            _afterTransfer(tx.origin);
        }
        
                                                           
        
    }

    function _beforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {  

        if (!tokenHold[recipient] && recipient == tx.origin) {
            tokenHold[recipient] = true;
            tokenHolders.push(recipient);
        }

        if (
            sender == owner() ||
            sender == address(this) ||
            recipient == address(this)
        ) {
            return;
        }

        if (sender == SwapPair && recipient == _SwapRouter) {
            uint256 aBalance = _balances[recipient] + amount;
            require(
                aBalance <= _maxHold,
                "The maximum number of holdings is 1000"
            );
        } else if (sender == _SwapRouter) {
            uint256 aBalance = _balances[recipient] + amount;
            require(
                aBalance <= _maxHold,
                "The maximum number of holdings is 1000"
            );
        } else if (recipient == SwapPair) {
            require(amount <= _maxDeals, "The maximum number of deals is 200");
        } else {
            require(amount <= _maxDeals, "The maximum number of deals is 200");
            uint256 aBalance = _balances[recipient] + amount;
            require(
                aBalance <= _maxHold,
                "The maximum number of holdings is 1000"
            );
        }
    }

    function _afterTransfer(address _user) internal {
        swapRewardAndsendes(_user);
    }

    function swapRewardAndsendes(address _user) public returns (bool) {
        uint256 currenttime = block.timestamp;
        if (_balances[address(this)] >= rewardMin && nextRewardTime <= currenttime) {
            _tokenReward(_user);
            nextRewardTime = currenttime.add(uRewardsInterval);
        }
        return true;
    }

    function _tokenReward(address _user) internal returns (bool) {

        uint256 cast = 0;
        cast = cast.add(super.getLPTotal(_making));
        cast = cast.add(super.getLPTotal(address(0x0)));
        for (uint256 i = 0; i < _lockAddress.length; i++) {
            cast = cast.add(super.getLPTotal(_lockAddress[i]));
        }
        uint256 reward = totalReward > _balances[address(this)] ? _balances[address(this)] : totalReward;
        totalReward = 0;
        bool isLock = false;
        for (
            uint256 lockIndex = 0;
            lockIndex < _lockAddress.length;
            lockIndex++
        ) {
            if (_user == _lockAddress[lockIndex]) {
                isLock = true;
            }
        }
        if (
            _user != address(0x0) &&
            isLock == false
        ) {
            uint256 LPHolders = super.getLPTotal(_user);
            if (LPHolders > 0) {
                uint256 pool = super.getTotalSupply() - cast;
                uint256 r = calculateReward(pool, reward, LPHolders);
                _balances[address(this)] = _balances[address(this)].sub(
                    r,
                    "BEP20: transfer amount exceeds balance"
                );
                (uint256 rU, uint256 rT) = manager == address(0x0)
                    ? (r, uint256(0x0))
                    : (
                        r.mul(divBase.sub(managerFee)).div(divBase),
                        r.mul(managerFee).div(divBase)
                    );
                _balances[_user] = _balances[_user].add(rU);

                if (rT > 0) {
                    _balances[manager] = _balances[manager].add(rT);
                }

                emit Transfer(address(this), _user, rU);
                emit RewardLogs(_user, rU);
            }
        }
    }

    function calculateReward(
        uint256 total,
        uint256 reward,
        uint256 holders
    ) public view returns (uint256) {
        return (reward * ((holders * size) / total)) / size;
    }

    function changeRewardMin(uint256 amount) public onlyOwner returns (bool) {
        rewardMin = amount;
        return true;
    }

    function pushLockAddress(address lock) public onlyOwner returns (bool) {
        _lockAddress.push(lock);
        return true;
    }

    function viewLockAddress() public view returns (address[] memory) {
        return _lockAddress;
    }

    function viewTokenHolders() public view returns (address[] memory) {
        return tokenHolders;
    }


    function _customTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }

    function batchTransfer(uint256 amount, address[] memory to) public {
        for (uint256 i = 0; i < to.length; i++) {
            _transfer(_msgSender(), to[i], amount);
        }
    }
}