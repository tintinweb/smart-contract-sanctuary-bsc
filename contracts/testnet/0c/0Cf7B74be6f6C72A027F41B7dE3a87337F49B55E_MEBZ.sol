// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MEBZ is IERC20 {
    using SafeMath for uint256;

    uint256 private _totalSupply = uint256(300000000 * 1 ether);

    string public constant name = "Metabotz";
    string public constant symbol = "MEBZ";
    uint8 public constant decimals = 18;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address payable public _admin;

    address public _saleContract;
    uint256 public _saleAmountCap = uint256(90000000 * 1 ether);

    bool public _isPaused;
    mapping(address => bool) public _isPausedAddress;

    string[] public _groups;
    uint256[] public _dates;
    mapping(string => uint256) public _groupsAmountCap;
    mapping(string => address) public _groupsAddress;
    mapping(string => mapping(uint256 => uint256)) public _tokenAllocation;
    mapping(string => mapping(uint256 => mapping(uint256 => bool))) public _tokenAllocationStatus;

    event OutOfMoney(string group);

    //Wallet Addresses
    address public _deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public _Staking = 0xA145E144eB6c728D34FA8a3a34f10250F8f95942;
    address public _Development = 0x4E19DdD417a34b1CE5C6fA46e91bdb02142F6bB4;
    address public _Marketing = 0xFb7d961af7bF791fc949B1F40b79430f6360C77e;
    address public _Liquidity = 0x82C6B2a0894eFAe767B4464b1bfF703733843157;
    address public _GameRewards = 0xDA91c1315D4D6a93340f62b8E1A68D40F836B5E5;
    address public _Team = 0xC3283FD53cc09465fB4b0C6AC73BbA1Ad1b37302;
    address public _Reserve = 0xB2caFeC7a4F98817DC7F4848Ec25Af10fd6f1aF2;

    //Vesting Dates
    uint256 public constant AUGUST_19_2022 = 1660867200; 
    uint256 public constant FEBRUARY_19_2023 = 1695081600;     
    uint256 public constant SEPTEMBER_19_2022 = 1663545600;   
    uint256 public constant OCTOBER_19_2022 = 1666137600;
    uint256 public constant NOVEMBER_19_2022 = 1668816000;
    uint256 public constant DECEMBER_19_2022 = 1671408000;
    uint256 public constant JANUARY_19_2023 = 1674086400;
    uint256 public constant AUGUST_19_2025 = 1660867200;    
   
    constructor() {
        _admin = payable(msg.sender);
        _balances[address(this)] = _totalSupply;

        _groupsAddress["Staking"] = _Staking;
        _groupsAddress["Development"] = _Development;
        _groupsAddress["Marketing"] = _Marketing;
        _groupsAddress["Liquidity"] = _Liquidity;
        _groupsAddress["GameRewards"] = _GameRewards;
        _groupsAddress["Team"] = _Team;
        _groupsAddress["Reserve"] = _Reserve;

        setValues();
        setTokenVesting();
        initialTransfer();
    }

    function setValues() private {

        _groups.push("Staking");
        _groups.push("Development");
        _groups.push("Marketing");		
        _groups.push("Liquidity");
        _groups.push("GameRewards");				
        _groups.push("Team");
        _groups.push("Reserve");       

        _groupsAmountCap["Staking"] = uint256(36000000 * 1 ether);
        _groupsAmountCap["Development"] = uint256(15000000 * 1 ether);
        _groupsAmountCap["Marketing"] = uint256(3000000 * 1 ether);
        _groupsAmountCap["Liquidity"] = uint256(9000000 * 1 ether);
        _groupsAmountCap["GameRewards"] = uint256(135000000 * 1 ether);
        _groupsAmountCap["Team"] = uint256(6000000 * 1 ether);
        _groupsAmountCap["Reserve"] = uint256(6000000 * 1 ether);

        _dates.push(AUGUST_19_2022);
        _dates.push(SEPTEMBER_19_2022);
        _dates.push(OCTOBER_19_2022);
        _dates.push(NOVEMBER_19_2022);
        _dates.push(DECEMBER_19_2022);
        _dates.push(JANUARY_19_2023);
        _dates.push(FEBRUARY_19_2023);

    }

    function setTokenVesting() private {

        //Staking
        _tokenAllocation["Staking"][FEBRUARY_19_2023] = uint256(36000000 * 1 ether); 

        //Development
        _tokenAllocation["Development"][AUGUST_19_2022] = uint256(1500000 * 1 ether);

        _tokenAllocation["Development"][SEPTEMBER_19_2022] = uint256(2250000 * 1 ether);
        _tokenAllocation["Development"][OCTOBER_19_2022] = uint256(2250000 * 1 ether);
        _tokenAllocation["Development"][NOVEMBER_19_2022] = uint256(2250000 * 1 ether);
        _tokenAllocation["Development"][DECEMBER_19_2022] = uint256(2250000 * 1 ether);
        _tokenAllocation["Development"][JANUARY_19_2023] = uint256(2250000 * 1 ether);
        _tokenAllocation["Development"][FEBRUARY_19_2023] = uint256(2250000 * 1 ether);

        //Team
        _tokenAllocation["Team"][AUGUST_19_2025] = uint256(6000000 * 1 ether);

        //Reserve
        _tokenAllocation["Reserve"][FEBRUARY_19_2023] = uint256(6000000 * 1 ether);
    
	}

    function initialTransfer() private {

        _transfer(address(this),_groupsAddress["Marketing"],uint256(3000000 * 1 ether)); // Marketing
        _transfer(address(this),_groupsAddress["Liquidity"],uint256(9000000 * 1 ether)); // Liquidity
        _transfer(address(this),_groupsAddress["GameRewards"],uint256(135000000 * 1 ether)); // GameRewards

    }

    /**
     * Modifiers
     */
    modifier onlyAdmin() {
        // Is Admin?
        require(_admin == msg.sender);
        _;
    }

    modifier isSaleContract() {
        require(msg.sender == _saleContract);
        _;
    }

    modifier whenPaused() {
        // Is pause?
        require(_isPaused, "Pausable: not paused Erc20");
        _;
    }

    modifier whenNotPaused() {
        // Is not pause?
        require(!_isPaused, "Pausable: paused Erc20");
        _;
    }

    // Transfer ownernship
    function transferOwnership(address payable admin) external onlyAdmin {
        require(admin != address(0), "Zero address");
        _admin = admin;
    }

    /**
     * Update sale contract
     */
    function _setSaleContract(address saleContractAddress)
        external
        onlyAdmin
    {
        require(saleContractAddress != address(0), "Zero address");
        _saleContract = saleContractAddress;
    }

    /**
     * ERC20 functions
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
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
    ) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    /**
     * @dev Automically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC20-approve}.
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
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Automically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC20-approve}.
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
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(!_isPaused, "ERC20Pausable: token transfer  le paused");
        require(
            !_isPausedAddress[sender],
            "ERC20Pausable: token transfer while paused on address"
        );
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            recipient != address(this),
            "ERC20: transfer to the token contract address"
        );

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

    /**
     * External contract transfer functions
     */
    // Allow sale external contract to trigger transfer function
    function transferSale(address recipient, uint256 amount)
        external
        isSaleContract
        returns (bool)
    {
        require(
            _saleAmountCap.sub(amount) >= 0,
            "No more amount allocated for sale"
        );
        _saleAmountCap = _saleAmountCap.sub(amount);
        _transfer(address(this), recipient, amount);
        return true;
    }

	//Token Vesting
    function tokenVesting() external {
        for (uint256 i = 0; i < _groups.length; i++) {
            address groupAddress = _groupsAddress[_groups[i]];
            for (uint256 y = 0; y < _dates.length; y++) {
                uint256 amount = _tokenAllocation[_groups[i]][_dates[y]];
                if (block.timestamp >= _dates[y]) {
                    bool hasDistributed = _tokenAllocationStatus[_groups[i]][_dates[y]][amount];
                    if (!hasDistributed) {
                        bool canTransfer = _groupsTransfer(groupAddress,amount,_groups[i]);
                        if (canTransfer) {
                            _tokenAllocationStatus[_groups[i]][_dates[y]][amount] = true;
                        }
                    }
                }
            }
        }
    }

    function _groupsTransfer(
        address recipient,
        uint256 amount,
        string memory categories
    ) private returns (bool) {
        if (_groupsAmountCap[categories] < amount) {
            emit OutOfMoney(categories);
            return false;
        }
        _groupsAmountCap[categories] = _groupsAmountCap[categories].sub(amount);
        _transfer(address(this), recipient, amount);
        return true;
    }

    function pause() external onlyAdmin whenNotPaused {
        _isPaused = true;
    }

    function unpause() external onlyAdmin whenPaused {
        _isPaused = false;
    }

    function pausedAddress(address sender) external onlyAdmin {
        _isPausedAddress[sender] = true;
    }

    function unPausedAddress(address sender) external onlyAdmin {
        _isPausedAddress[sender] = false;
    }

    function burnToken(uint256 amount) external onlyAdmin {
        _transfer(address(this), _deadAddress, amount);
    }

    receive() external payable {
        revert();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

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
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}