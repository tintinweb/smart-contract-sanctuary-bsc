/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

/**

            ░█████╗░██╗░░██╗██╗██╗░░░░░██████╗░  ░██████╗██╗░░░██╗██████╗░██████╗░░█████╗░██████╗░████████╗
            ██╔══██╗██║░░██║██║██║░░░░░██╔══██╗  ██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝
            ██║░░╚═╝███████║██║██║░░░░░██║░░██║  ╚█████╗░██║░░░██║██████╔╝██████╔╝██║░░██║██████╔╝░░░██║░░░
            ██║░░██╗██╔══██║██║██║░░░░░██║░░██║  ░╚═══██╗██║░░░██║██╔═══╝░██╔═══╝░██║░░██║██╔══██╗░░░██║░░░
            ╚█████╔╝██║░░██║██║███████╗██████╔╝  ██████╔╝╚██████╔╝██║░░░░░██║░░░░░╚█████╔╝██║░░██║░░░██║░░░
            ░╚════╝░╚═╝░░╚═╝╚═╝╚══════╝╚═════╝░  ╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝░░░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░

*/

interface IBEP20 {
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

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = address(0xC51903550134B4fcC88C554c3A33779bC1edF986);
        emit OwnershipTransferred(address(0), _owner);
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ChildSupport is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;

    address[] private _excluded;
    address public MarketingWallet = 0x6838C79f68549009B1DF65038E0d849c94eb907f;
    address public DevelopmentWallet =
        0xDd46525EA826927d8425E3DFa5a739b0D9526853;
    address public childSupportWallet =
        0xb62C3D54FE046c811339bFE618999015E4A36285;
    address public InfluencerWallet =
        0x156434fDf98bFfD8011C79aF3f4AC4c9714ED08d;
    address public immutable DeadWallet =
        0x000000000000000000000000000000000000dEaD;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 21 * 10**9 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "Child Support";
    string private constant _symbol = "CS";
    uint8 private constant _decimals = 9;

    uint256 public _taxFee = 1;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _MarketingFee = 3;
    uint256 private _previousMarketingFee = _MarketingFee;

    uint256 public _DevelopmentFee = 1;
    uint256 private _previousDevelopmentFee = _DevelopmentFee;

    uint256 public _influencersFee = 1;
    uint256 private _previousinfluencersFee = _influencersFee;

    uint256 public _childSupportFee = 2;
    uint256 private _previouschildSupportFee = _childSupportFee;

    uint256 public _burnFee = 1;
    uint256 private _previousburnFee = _burnFee;

    uint256 public feeDenominator = 100;
    event TaxFeesUpdated(uint256 TatalTaxFee);

    constructor() {
        _rOwned[owner()] = _rTotal;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[DeadWallet] = true;
        _isExcludedFromFee[MarketingWallet] = true;
        _isExcludedFromFee[MarketingWallet] = true;
        _isExcludedFromFee[InfluencerWallet] = true;
        _isExcludedFromFee[childSupportWallet] = true;
         if (_rOwned[owner()] > 0) {
            _tOwned[owner()] = tokenFromReflection(_rOwned[owner()]);
        }
        _isExcluded[owner()] = true;
        _excluded.push(owner());

        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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
                "BEP20: transfer amount exceeds allowance"
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
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , ) = _getValues(tAmount);
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
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
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
            uint256 tFee
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
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
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            _getRate()
        );
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (uint256, uint256)
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
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
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(feeDenominator);
    }

    function removeAllFee() private {
        if (
            _taxFee == 0 &&
            _MarketingFee == 0 &&
            _burnFee == 0 &&
            _influencersFee == 0 &&
            _childSupportFee == 0
        ) return;

        _previousTaxFee = _taxFee;
        _previousburnFee = _burnFee;
        _previousMarketingFee = _MarketingFee;
        _previousDevelopmentFee = _DevelopmentFee;
        _previousinfluencersFee = _influencersFee;
        _previouschildSupportFee = _childSupportFee;

        _taxFee = 0;
        _MarketingFee = 0;
        _burnFee = 0;
        _DevelopmentFee = 0;
        _influencersFee = 0;
        _childSupportFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousburnFee;
        _MarketingFee = _previousMarketingFee;
        _DevelopmentFee = _previousDevelopmentFee;
        _influencersFee = _previousinfluencersFee;
        _childSupportFee = _previouschildSupportFee;
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function UpdateWallets(
        address newMarkeitngWallet,
        address newInfluencerWallet,
        address newChildSupportWallet,
        address newDevelopmentWallet
    ) external onlyOwner {
        require(
            newMarkeitngWallet != address(0) &&
                newInfluencerWallet != address(0) &&
                newChildSupportWallet != address(0) &&
                newDevelopmentWallet != address(0),
            "You can't set Zero Address"
        );
        MarketingWallet = newMarkeitngWallet;
        DevelopmentWallet = newDevelopmentWallet;
        InfluencerWallet = newInfluencerWallet;
        childSupportWallet = newChildSupportWallet;
    }

    function UpdateTaxFee(
        uint256 RewardFee,
        uint256 MarketingFee,
        uint256 DevelopmentFee,
        uint256 InfluencerFee,
        uint256 ChildSupportFee,
        uint256 BurnFee
    ) external onlyOwner {
        uint256 TotalFee = RewardFee
            .add(MarketingFee)
            .add(DevelopmentFee)
            .add(InfluencerFee)
            .add(ChildSupportFee);
        require(
            TotalFee.add(BurnFee) <= 15,
            "You can't set more than 15% TaxFees"
        );

        _taxFee = RewardFee;
        _MarketingFee = MarketingFee;
        _DevelopmentFee = DevelopmentFee;
        _influencersFee = InfluencerFee;
        _childSupportFee = ChildSupportFee;
        _burnFee = BurnFee;

        emit TaxFeesUpdated(TotalFee.add(_burnFee));
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (balanceOf(DeadWallet) >= _tTotal.mul(50).div(100)) {
            _burnFee = 0;
        }

        _tokenTransfer(from, to, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            removeAllFee();
        }
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            restoreAllFee();
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
            uint256 tFee
        ) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = takeburn(
            sender,
            tTransferAmount,
            rTransferAmount,
            tAmount
        );
        (tTransferAmount, rTransferAmount) = takeMarketing(
            tTransferAmount,
            rTransferAmount,
            tAmount
        );

        (tTransferAmount, rTransferAmount) = takeDevelopment(
            sender,
            tTransferAmount,
            rTransferAmount,
            tAmount
        );

        (tTransferAmount, rTransferAmount) = takeinfluencer(
            sender,
            tTransferAmount,
            rTransferAmount,
            tAmount
        );

        (tTransferAmount, rTransferAmount) = takeChildSupport(
            sender,
            tTransferAmount,
            rTransferAmount,
            tAmount
        );
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function takeburn(
        address sender,
        uint256 tTransferAmount,
        uint256 rTransferAmount,
        uint256 tAmount
    ) private returns (uint256, uint256) {
        if (_burnFee == 0) {
            return (tTransferAmount, rTransferAmount);
        }
        uint256 tburn = tAmount.mul(_burnFee).div(feeDenominator);
        uint256 rburn = tburn.mul(_getRate());
        rTransferAmount = rTransferAmount.sub(rburn);
        tTransferAmount = tTransferAmount.sub(tburn);
        _rOwned[DeadWallet] = _rOwned[DeadWallet].add(rburn);
        emit Transfer(sender, DeadWallet, tburn);
        return (tTransferAmount, rTransferAmount);
    }

    function takeMarketing(
        uint256 tTransferAmount,
        uint256 rTransferAmount,
        uint256 tAmount
    ) private returns (uint256, uint256) {
        if (_MarketingFee == 0) {
            return (tTransferAmount, rTransferAmount);
        }
        uint256 tMarketing = tAmount.mul(_MarketingFee).div(feeDenominator);
        uint256 rMarketing = tMarketing.mul(_getRate());
        rTransferAmount = rTransferAmount.sub(rMarketing);
        tTransferAmount = tTransferAmount.sub(tMarketing);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
        return (tTransferAmount, rTransferAmount);
    }

    function takeDevelopment(
        address sender,
        uint256 tTransferAmount,
        uint256 rTransferAmount,
        uint256 tAmount
    ) private returns (uint256, uint256) {
        if (_DevelopmentFee == 0) {
            return (tTransferAmount, rTransferAmount);
        }
        uint256 tDevelopment = tAmount.mul(_DevelopmentFee).div(feeDenominator);
        uint256 rDevelopment = tDevelopment.mul(_getRate());
        rTransferAmount = rTransferAmount.sub(rDevelopment);
        tTransferAmount = tTransferAmount.sub(tDevelopment);
        _rOwned[DevelopmentWallet] = _rOwned[DevelopmentWallet].add(
            rDevelopment
        );
        emit Transfer(sender, DevelopmentWallet, tDevelopment);
        return (tTransferAmount, rTransferAmount);
    }

    function takeinfluencer(
        address sender,
        uint256 tTransferAmount,
        uint256 rTransferAmount,
        uint256 tAmount
    ) private returns (uint256, uint256) {
        if (_influencersFee == 0) {
            return (tTransferAmount, rTransferAmount);
        }
        uint256 tinfluencer = tAmount.mul(_influencersFee).div(feeDenominator);
        uint256 rinfluencer = tinfluencer.mul(_getRate());
        rTransferAmount = rTransferAmount.sub(rinfluencer);
        tTransferAmount = tTransferAmount.sub(tinfluencer);
        _rOwned[DevelopmentWallet] = _rOwned[DevelopmentWallet].add(
            rinfluencer
        );
        emit Transfer(sender, DevelopmentWallet, tinfluencer);
        return (tTransferAmount, rTransferAmount);
    }

    function takeChildSupport(
        address sender,
        uint256 tTransferAmount,
        uint256 rTransferAmount,
        uint256 tAmount
    ) private returns (uint256, uint256) {
        if (_childSupportFee == 0) {
            return (tTransferAmount, rTransferAmount);
        }
        uint256 tchildSupport = tAmount.mul(_childSupportFee).div(
            feeDenominator
        );
        uint256 rchildSupport = tchildSupport.mul(_getRate());
        rTransferAmount = rTransferAmount.sub(rchildSupport);
        tTransferAmount = tTransferAmount.sub(tchildSupport);
        _rOwned[DevelopmentWallet] = _rOwned[DevelopmentWallet].add(
            rchildSupport
        );
        emit Transfer(sender, DevelopmentWallet, tchildSupport);
        return (tTransferAmount, rTransferAmount);
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
            uint256 tFee
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
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
            uint256 tFee
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}