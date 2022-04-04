/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        returns (address PancakePair);
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
}

contract PancakeTool {
    address public PancakePair;
    IRouter internal PancakeV2Router;

    function initIRouter(address _router) internal {
        PancakeV2Router = IRouter(_router);
        PancakePair = IFactory(PancakeV2Router.factory()).createPair(
            address(this),
            PancakeV2Router.WETH()
        );
    }

    function swapTokensForTokens(
        uint256 tokenAmount,
        address tokenDesireAddress
    ) internal {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = PancakeV2Router.WETH();
        path[2] = tokenDesireAddress;
        PancakeV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
        path[1] = PancakeV2Router.WETH();
        PancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        (uint112 _reserve0, uint112 _reserve1, ) = IPair(PancakePair)
            .getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPair(PancakePair).token0() == PancakeV2Router.WETH()) {
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
        return IBEP20(PancakePair).balanceOf(user);
    }

    function getTotalSupply() internal view returns (uint256) {
        return IBEP20(PancakePair).totalSupply();
    }
}


contract Ohhilol is IBEP20, Ownable, PancakeTool {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => address) private recommender;//child=>father
    mapping(address => uint256) private recommendNum;

    uint256 private _totalSupply;
    uint256 private _finalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address private _PancakeRouter; 
    address private _defaultReco = 0xc53347ccA6096cE2ded9CbE4DD27810Ae460BCF4;
    address private _lockAddress = 0x000000000000000000000000000000000000dEaD;
    address private _making;

    uint8 private _buyPercent = 4;
    uint8 private _sellPercent = 4;

    uint256 private _maxDeals = 10 ether;
    uint256 private _maxHold = 50 ether;

    uint256 private rewardMin = 10 ether;

    mapping(address => bool) private tokenHold;
    address[] private tokenHolders;

    event RewardLogs(address indexed account, uint256 amount);

    mapping(address => bool) private blackList;

    constructor() {
        _name = "Oh hi lol";
        _symbol = "Oh hi lol";
        _decimals = 18;
        _totalSupply = 10000 ether;
        _finalSupply = 1000 ether;
        _balances[msg.sender] = _totalSupply;
        tokenHold[msg.sender] = true;
        _making = msg.sender;
        _PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        initIRouter(_PancakeRouter);
        _approve(address(this), _PancakeRouter, ~uint256(0));
        _approve(owner(), _PancakeRouter, ~uint256(0));
        emit Transfer(address(0), msg.sender, _totalSupply);
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

    //The token pancake  5%
    //Increased liquidity and transaction number is 5
    function transfer(address recipient, uint256 amount)
        external
        override 
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        override 
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
    ) external override returns (bool) {
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
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount,"BEP20: transfer amount exceeds balance");

        uint256 _cPercent = 0;
        if(recipient == PancakePair){
            _cPercent = _sellPercent;
        }else if(sender == PancakePair){
            _cPercent = _buyPercent;
        }
        uint256 _cFee = 0;
        if (sender != owner() && _cPercent > 0) {
            _cFee = (amount / 100) * _cPercent;
            //_cFee
            uint256 bonusAmount = 0;
            uint256 recoAmount = 0;
            uint256 burnAmount =  _cFee * 25 /100;
            if(!(_totalSupply>_finalSupply)){
                burnAmount = 0;
                bonusAmount = _cFee * 50 / (50+25);
                recoAmount = _cFee - bonusAmount;                
            }else if(_totalSupply-burnAmount<_finalSupply){
                burnAmount = _totalSupply - _finalSupply;
                bonusAmount = (_cFee-burnAmount) * 50 / (50+25);
                recoAmount = (_cFee-burnAmount) - bonusAmount;
            }else{
                burnAmount = _cFee * 25 / 100;
                bonusAmount = _cFee * 50 / 100;
                recoAmount = _cFee - burnAmount - bonusAmount;
            }
            // burn
            if(burnAmount>0){
                _balances[address(0x0)] = _balances[address(0x0)].add(burnAmount);
                _totalSupply = _totalSupply.sub(burnAmount);
                emit Transfer(sender, address(0x0), burnAmount);
            }
            // bonus
            _balances[address(this)] = _balances[address(this)].add(bonusAmount);
            emit Transfer(sender, address(this), bonusAmount);
            // reco
            address recoSender;
            if(sender == PancakePair){
                recoSender = recommender[recipient];
            }else{
                recoSender = recommender[sender];
            }
            if(recoSender == address(0x0)){
                recoSender = _defaultReco;
            }
            _balances[recoSender] = _balances[recoSender].add(recoAmount);            
            
            emit Transfer(sender, recoSender, recoAmount);
        }

        _balances[recipient] = _balances[recipient].add(amount - _cFee);
        emit Transfer(sender, recipient, amount - _cFee);

        // recommender
        uint256 sizeRecipient;
        assembly { sizeRecipient := extcodesize(recipient) }
        if(sizeRecipient == 0 && recommender[recipient] == address(0x0) && !(amount < 5 * 10**15)){
            uint256 sizeSender;
            assembly { sizeSender := extcodesize(sender) }
            address reco;
            if(sizeSender>0){
                reco = _defaultReco;
            }else{
                reco = sender;
            }
            recommender[recipient] = reco;
            recommendNum[reco] += 1;
        }

        _afterTransfer();
    }

    function _beforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(!blackList[sender], "You're banned");
        if (!tokenHold[recipient] && recipient == tx.origin) {
            tokenHold[recipient] = true;
            tokenHolders.push(recipient);
        }

        if (sender == owner() || sender == address(this) || recipient == address(this)) {
            return;
        }

        if (sender == PancakePair && recipient == _PancakeRouter) {
            uint256 aBalance = _balances[recipient] + amount;
            require(aBalance <= _maxHold,"The maximum number of holdings is 50");
        } else if (sender == _PancakeRouter) {
            uint256 aBalance = _balances[recipient] + amount;
            require(aBalance <= _maxHold,"The maximum number of holdings is 50");
        } else if (recipient == PancakePair) {
            require(amount <= _maxDeals, "The maximum number of deals is 10");
        } else {
            require(amount <= _maxDeals, "The maximum number of deals is 10");
            uint256 aBalance = _balances[recipient] + amount;
            require(aBalance <= _maxHold,"The maximum number of holdings is 50");
        }

    }

    function _afterTransfer() internal {
        swapRewardAndsendes();
    }

    function swapRewardAndsendes() public returns (bool) {
        if (_balances[address(this)] >= rewardMin) {
            _tokenReward();
        }
        return true;
    }

    function _tokenReward() internal returns (bool) {
        uint256 cast = 0;
        cast = cast.add(super.getLPTotal(_making));
        cast = cast.add(super.getLPTotal(address(0x0)));
        cast = cast.add(super.getLPTotal(_lockAddress));

        uint256 reward = _balances[address(this)];
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            bool isLock = false;
            if (tokenHolders[i] == _lockAddress) {
                isLock = true;
            }
            if (tokenHolders[i] != address(0x0) && isLock == false) {
                uint256 LPHolders = super.getLPTotal(tokenHolders[i]);
                if (LPHolders > 0) {
                    uint256 pool = super.getTotalSupply() - cast;
                    uint256 r = calculateReward(pool, reward, LPHolders);
                    _balances[address(this)] = _balances[address(this)].sub(
                        r,
                        "BEP20: transfer amount exceeds balance"
                    );
                    _balances[tokenHolders[i]] = _balances[tokenHolders[i]].add(
                        r
                    );
                    emit Transfer(address(this), tokenHolders[i], r);
                    emit RewardLogs(tokenHolders[i], r);
                }
            }
        }
        return true;
    }

    function calculateReward(
        uint256 total,
        uint256 reward,
        uint256 holders
    ) public view returns (uint256) {
        return (reward * ((holders * 10**_decimals) / total)) / 10**_decimals;
    }

    function changeBad(address account, bool isBack)
        public
        onlyOwner
        returns (bool)
    {
        blackList[account] = isBack;
        return true;
    }

    function changeRewardMin(uint256 amount) public onlyOwner returns (bool) {
        rewardMin = amount;
        return true;
    }

    function viewLockAddress() public view returns (address) {
        return _lockAddress;
    }

    function getRecommender(address account) public view returns (address) {
        return recommender[account];
    }

    function getRecommenderNum(address account) public view returns (uint256) {
        return recommendNum[account];
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