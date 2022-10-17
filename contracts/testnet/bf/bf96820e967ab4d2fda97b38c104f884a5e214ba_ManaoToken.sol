/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// File: libs/SafeMath.sol



pragma solidity ^0.8.17;



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

     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.

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
// File: libs/IBEP20.sol



pragma solidity ^0.8.17;



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

    function transfer(address recipient, uint256 amount) external returns (bool);



    /**

     * @dev Returns the remaining number of tokens that `spender` will be

     * allowed to spend on behalf of `owner` through {transferFrom}. This is

     * zero by default.

     *

     * This value changes when {approve} or {transferFrom} are called.

     */

    function allowance(address _owner, address spender) external view returns (uint256);



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

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



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
// File: libs/Context.sol



pragma solidity ^0.8.17;







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
// File: libs/Ownable.sol



pragma solidity ^0.8.17;




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
// File: BEP20Token.sol



pragma solidity ^0.8.17;







abstract contract BEP20Token is Context, IBEP20, Ownable {

    using SafeMath for uint256;



    mapping(address => uint256) private _balances;



    mapping(address => mapping(address => uint256)) private _allowances;



    uint256 private _totalSupply;

    uint8 private _decimals;

    string private _symbol;

    string private _name;



    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

        _decimals = 18;

        _totalSupply = 100000000000 * 10**18; // 100k million

        _balances[msg.sender] = _totalSupply;



        emit Transfer(address(0), msg.sender, _totalSupply);

    }



    /**

     * @dev Returns the bep token owner.

     */

    function getOwner() external view returns (address) {

        return owner();

    }



    /**

     * @dev Returns the token decimals.

     */

    function decimals() external view returns (uint8) {

        return _decimals;

    }



    /**

     * @dev Returns the token symbol.

     */

    function symbol() external view returns (string memory) {

        return _symbol;

    }



    /**

     * @dev Returns the token name.

     */

    function name() external view returns (string memory) {

        return _name;

    }



    /**

     * @dev See {BEP20-totalSupply}.

     */

    function totalSupply() external view returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev See {BEP20-balanceOf}.

     */

    function balanceOf(address account) public view returns (uint256) {

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

    function transfer(address recipient, uint256 amount)

        external

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

    function approve(address spender, uint256 amount) external returns (bool) {

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

    ) external returns (bool) {

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

     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing

     * the total supply.

     *

     * Requirements

     *

     * - `msg.sender` must be the token owner

     */

    function mint(uint256 amount) public onlyOwner returns (bool) {

        _mint(_msgSender(), amount);

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



        _balances[sender] = _balances[sender].sub(

            amount,

            "BEP20: transfer amount exceeds balance"

        );

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }



    /** @dev Creates `amount` tokens and assigns them to `account`, increasing

     * the total supply.

     *

     * Emits a {Transfer} event with `from` set to the zero address.

     *

     * Requirements

     *

     * - `to` cannot be the zero address.

     */

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "BEP20: mint to the zero address");



        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

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

}


// File: Manao.sol



pragma solidity ^0.8.17;




contract ManaoToken is BEP20Token {



    bytes32 private _rootHash;

    uint8 private constant DECIMALS = 18;

    uint256 private constant DECIMALFACTOR = 10**uint256(DECIMALS);

    uint256 public REWARD_AMOUNT = 1 * uint256(DECIMALFACTOR);

    uint256 public REWARD_AMOUNT_DAILY = 1 * uint256(DECIMALFACTOR);

    uint256 public REWARD_AMOUNT_WEEKLY = 2 * uint256(DECIMALFACTOR);

    uint256 public REWARD_AMOUNT_MONTHLY = 3 * uint256(DECIMALFACTOR);

    uint256 public REWARD_AMOUNT_SPECIALDAY = 5 * uint256(DECIMALFACTOR);

    struct LimitTimeToken 

    {

        uint startAt;

        uint expiresAt;

        uint256 amount;

    }



    address[] public allAddresses;

    string[] public allSpecialDays;

    // admins

    uint8 private constant CREATOR = 99;

    uint8 private constant ADMIN = 88;

    mapping(address => uint8) private _adminAddresses;

    address[] private ArrayAdminAddresses;    

    

    enum ClaimType {

        ByExpire,

        ByTransfer,

        ByMint

    }



    mapping(address => bool) public _oneTimeClaimed;



    mapping(address => LimitTimeToken) public _dailyClaimed;

    mapping(address => bool) public _dailyClaimedFlag; 



    mapping(address => LimitTimeToken) public _weeklyClaimed;

    mapping(address => bool) public _weeklyClaimedFlag;  



    mapping(address => mapping(string => LimitTimeToken)) public _specialClaimed; 

    mapping(address => mapping(string => bool)) public _specialClaimedFlag; 



    constructor() BEP20Token("Tae Token","TAE"){  

        _adminAddresses[msg.sender] = CREATOR;      

    }



    /* Wallet */

    function getAllBalance(address account) external view returns (uint256) {

        if(_dailyClaimed[account].expiresAt >= block.timestamp) {

           return _dailyClaimed[account].amount + balanceOf(account);

        }        

        return balanceOf(account);

    }



    /* ADMIN */

    modifier onlyAuthorized() {

        bool isAuthorized = msg.sender == owner() || _adminAddresses[msg.sender] == CREATOR || _adminAddresses[msg.sender] == ADMIN;

        require(isAuthorized, "Only creator/admin can perform");

        _;

    }



    function setAdmin(address userAddress) external onlyAuthorized {

        _adminAddresses[userAddress] = ADMIN;

        ArrayAdminAddresses.push(userAddress);

    }



    function revokeAdmin(address userAddress) external onlyAuthorized {

        delete _adminAddresses[userAddress];



        uint256 length = ArrayAdminAddresses.length;

        for(uint256 i = 0; i < length -1; i++) {

            if(ArrayAdminAddresses[i] == userAddress) {                

                ArrayAdminAddresses[i] = ArrayAdminAddresses[length-1];

                ArrayAdminAddresses.pop();

                break;

            }

        }

    }



    function getAdminAddresses() external view onlyAuthorized returns(address[] memory) {

        return ArrayAdminAddresses;

    }



    function pushAddresses(address _account) private {

        bool isPushAddress = false;

        for(uint i = 0; i < allAddresses.length; i ++) {

            if(allAddresses[i] == _account) {

                isPushAddress = true;

                break;

            }

        }

        if(!isPushAddress) {

            allAddresses.push(_account);

        }        

    }



    function pushSpecialdays(string storage _day) private {

        bool isPushDay = false;

        for(uint i = 0; i < allSpecialDays.length; i ++) {                       

            if(keccak256(abi.encodePacked(allSpecialDays[i])) == keccak256(abi.encodePacked(_day))) {

                isPushDay = true;

                break;

            }

        }

        if(!isPushDay) {

            allSpecialDays.push(_day);

        }        

    }    



    function pullBackLimitTimeToken() external onlyAuthorized {

        for(uint i = 0; i < allAddresses.length; i ++) {

            address account = allAddresses[i];



            /* daily */

            uint256 amount = _dailyClaimed[account].amount;

            if(_dailyClaimed[account].amount > 0) {                                

                _transfer(account, owner(),  amount);

                _dailyClaimed[account].amount = 0;

            }



            /* weekly */

            amount = _weeklyClaimed[account].amount;

            if(_weeklyClaimed[account].amount > 0) {

                _transfer(account, owner(),  amount);

                _weeklyClaimed[account].amount = 0;

            }

        }

    }



    /* One Time Claim */



    function setOneTimeClaimAmount(uint256 _amount) external onlyAuthorized {

        REWARD_AMOUNT = _amount  * uint256(DECIMALFACTOR);

    }



    function oneTimeClaimByTransfer(address _to) private onlyAuthorized {    

        _transfer(owner(), _to, REWARD_AMOUNT);

    }



    function oneTimeClaimByMint(address _to) private onlyAuthorized {        

        _mint(_to, REWARD_AMOUNT);

    }      

    

    function oneTimeClaim(address _to, ClaimType claimType) external onlyAuthorized {

        require(claimType != ClaimType.ByExpire, "Do not claim with expire");

        require(!_oneTimeClaimed[_to], "Already claimed 1 time bonus");



        pushAddresses(_to);

        _oneTimeClaimed[_to] = true;        



        if(claimType != ClaimType.ByTransfer) {

            oneTimeClaimByTransfer(_to);

        }

        else {

            oneTimeClaimByMint(_to);

        }

    } 



    /* Daily Time Claimed */



    function setDailyClaimAmount(uint256 _amount) external onlyAuthorized {

        REWARD_AMOUNT_DAILY = _amount  * uint256(DECIMALFACTOR);

    }    



    function dailyClaimeWithExpire(address _to) private onlyAuthorized {   

        _transfer(_to, owner(), _dailyClaimed[_to].amount); /* transfer back to owner */

        _transfer(owner(), _to, REWARD_AMOUNT_DAILY);



        _dailyClaimed[_to] = LimitTimeToken(block.timestamp, block.timestamp + 2 minutes, REWARD_AMOUNT_DAILY); 

    }



    function dailyClaimeByTransfer(address _to) private onlyAuthorized { 

        _transfer(owner(), _to, REWARD_AMOUNT_DAILY);

    }    



    function dailyClaimeByMint(address _to) private onlyAuthorized {  

        _mint(_to, REWARD_AMOUNT_DAILY);

    } 



    function dailyClaimed(address _to, ClaimType claimType) public onlyAuthorized {

        require(_dailyClaimedFlag[_to] == false, "Daily claim can only perform once.");



        pushAddresses(_to);

        _dailyClaimedFlag[_to] = true;   

        if(claimType == ClaimType.ByExpire) {

            dailyClaimeWithExpire(_to);

        }

        else if(claimType == ClaimType.ByTransfer) {

            dailyClaimeByTransfer(_to);

        }

        else {

            dailyClaimeByMint(_to);

        }

    }           



    function resetDailyClaimed() external onlyAuthorized {

        uint256 length = allAddresses.length;

        for (uint256 i = 0; i < length; i++) {

            _dailyClaimedFlag[allAddresses[i]] = false;

        }

    }



    /* Weekly Time Claimed */



    function setWeeklyClaimAmount(uint256 _amount) external onlyAuthorized {

        REWARD_AMOUNT_WEEKLY = _amount  * uint256(DECIMALFACTOR);

    } 



    function weeklyClaimeWithExpire(address _to) private onlyAuthorized {    

        _transfer(_to, owner(), _weeklyClaimed[_to].amount); /* transfer back to owner */

        _transfer(owner(), _to, REWARD_AMOUNT_WEEKLY);    



        _weeklyClaimed[_to] = LimitTimeToken(block.timestamp, block.timestamp + 7 days, REWARD_AMOUNT_WEEKLY); 

    }



    function weeklyClaimeByTransfer(address _to) private onlyAuthorized { 

        _transfer(owner(), _to, REWARD_AMOUNT_WEEKLY);

    }    



    function weeklyClaimeByMint(address _to) private onlyAuthorized {  

        _mint(_to, REWARD_AMOUNT_WEEKLY);

    } 



    function weeklyClaimed(address _to, ClaimType claimType) external onlyAuthorized {

        require(_weeklyClaimedFlag[_to] == false, "Weekly claim can only perform once.");



        pushAddresses(_to);

        _weeklyClaimedFlag[_to] = true;   

        if(claimType == ClaimType.ByExpire) {

            weeklyClaimeWithExpire(_to);

        }

        else if(claimType == ClaimType.ByTransfer) {

            weeklyClaimeByTransfer(_to);

        }

        else {

            weeklyClaimeByMint(_to);

        }

    }  



    /* Special Claimed */



    // function setSpecialClaimAmount(uint256 _amount) external onlyAuthorized {

    //     REWARD_AMOUNT_SPECIALDAY = _amount  * uint256(DECIMALFACTOR);

    // } 



    // // function specialClaimeWithExpire(address _to, string memory day) private onlyAuthorized {    

    // //     _transfer(owner(), _to, REWARD_AMOUNT_SPECIALDAY);    



    // //     _specialClaimed[_to][day] = LimitTimeToken(block.timestamp, block.timestamp + 7 days, REWARD_AMOUNT_SPECIALDAY); 

    // // }



    // function specialClaimeByTransfer(address _to) private onlyAuthorized { 

    //     _transfer(owner(), _to, REWARD_AMOUNT_SPECIALDAY);

    // }    



    // function specialClaimeByMint(address _to) private onlyAuthorized {  

    //     _mint(_to, REWARD_AMOUNT_SPECIALDAY);

    // } 



    // function specialClaimed(address _to, string storage day, ClaimType claimType) external onlyAuthorized {

    //     require(_specialClaimedFlag[_to][day] == false, "Sepcial claim can only perform once.");



    //     pushSpecialdays(day);

    //     _specialClaimedFlag[_to][day] = true;   

    //     if(claimType == ClaimType.ByExpire) {

    //         //specialClaimeWithExpire(_to,day);

    //     }

    //     else if(claimType == ClaimType.ByTransfer) {

    //         specialClaimeByTransfer(_to);

    //     }

    //     else {

    //         specialClaimeByMint(_to);

    //     }

    // }               



    // function resetSpecialClaimed(string memory day) external onlyAuthorized {

    //     uint256 length = allAddresses.length;

    //     for (uint256 i = 0; i < length; i++) {

    //         _specialClaimedFlag[allAddresses[i]][day] = false;

    //     }

    // }



    /* Merkle proof AirDrop with Whilelist Array */

    function setMerkleRoot(bytes32 root) external onlyAuthorized { 

        _rootHash = root;

    }



    /* Bulk AirDrop by Admin */

    function airdrop(address[] calldata recipients, uint256 amount) external onlyAuthorized  {  

        require(amount > 0, "Airdrop amount must greater than zero");

        uint256 airdropAmount = amount * uint256(DECIMALFACTOR);



        uint256 length = recipients.length;

        for (uint256 index = 0; index < length; index++) {

            address _to = recipients[index];

            _transfer(owner(), _to, airdropAmount);

        }

    }



    // /* WidthDraw to External */

    // function withdraw(address payable payee, uint256 amount) public virtual {

    //     _transfer(payee, owner(), amount); //transfer back to owner

    // }

}