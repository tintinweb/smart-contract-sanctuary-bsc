/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

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
    constructor() {}

    function _msgSender() internal view returns (address) {
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

contract BlackList is Ownable {
    

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

    mapping (address => bool) public isBlackListed;

    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }


}

contract MaxLife is IBEP20, BlackList {
    using SafeMath for uint256;

    event BuyToken(address indexed user, uint256 amount);
    event SellToken(address indexed user, uint256 amount);
    event Registration(address indexed user, address indexed referrer, uint256 amount);

    mapping(address => uint256) private _balances;
    mapping (address => uint256) freezeAccount;
    mapping (address => uint256) public freezeList;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    
    address public liquidityFeeWallet;
    address public developmentFeeWallet;
    address public buyBackLockFeeWallet;
    
    uint256 public liquidityFeePercent = 3 * 10**2; // 3% Percent of liquidity fee;
    uint256 public developmentFeePercent = 1 * 10**2; // 1% Percent of development fee;
    uint256 public buyBackLockFeePercent = 1 * 10**2; // 1% Percent of buyBackLock fee;

    constructor() {
        _name = "MaxLife";
        _symbol = "MLT";
        _decimals = 8;
        _totalSupply = 1000000000 * (10**8);
        
        //excluded from fee
        _isExcludedFromFee[msg.sender] = true;

        
        //Tokenomics                          
       _balances[0x038A44aad9e8AB2D2C53A72e28Bd15368E599BDC] = _totalSupply.mul(5).div(100); // Private Sale	5%
       _balances[0xbb8dFB15573231aDc40e75F4cD29abC483bBFA90] = _totalSupply.mul(15).div(100); // Pre Sale	15%
       _balances[0xE94e0bEE3dCb484aB300EA00E3D827E89e50b3A4] = _totalSupply.mul(20).div(100); // Public Sale	20%
       _balances[0xDC7C2A2a7D2A6690dc7ff2b90b75F1d543724694] = _totalSupply.mul(10).div(100); // Marketing	10%
       _balances[0x9e7D13F75A273f6987b7AdC502e62320De958Ab8] = _totalSupply.mul(4).div(100); // Liquidity	4%
       _balances[0xdB17FccB47BB5F9c3C9d5D7eceBFf934fC953489] = _totalSupply.mul(1).div(100); // R & D	1%
       _balances[0x9Ff11F00C0c9F59aC78fA6426E634bD0800E9cD4] = _totalSupply.mul(1).div(100); // Airdrop	1%
       _balances[0x73F06C693c3357347D1d230D39290d3DCE4BCcEE] = _totalSupply.mul(10).div(100); // Referral & Stacking	10%
       _balances[0x9dB69CF9bA0B55Ab84FE096B95EB4C96D8D255FB] = _totalSupply.mul(7).div(100); // Ecosystem	7%
       _balances[0x7De1a80F3b44cAE8498963565642a0C753899Cf3] = _totalSupply.mul(4).div(100); // Reserve	4%
       _balances[0xe84504aEc55c79a086B858296B1D2a3282da728f] = _totalSupply.mul(18).div(100); // Team	18%
       _balances[0x5a120C9a79510bcB4EA681905D4B62996591c571] = _totalSupply.mul(1).div(100); // Charity	1%
       _balances[0x66a7720B2F0ff4c85b2715fBAd687BeB5B816a06] = _totalSupply.mul(4).div(100); // Advisors	4%



        emit Transfer(address(0), 0x038A44aad9e8AB2D2C53A72e28Bd15368E599BDC, _totalSupply.mul(5).div(100));
        emit Transfer(address(0), 0xbb8dFB15573231aDc40e75F4cD29abC483bBFA90, _totalSupply.mul(15).div(100));
        emit Transfer(address(0), 0xE94e0bEE3dCb484aB300EA00E3D827E89e50b3A4, _totalSupply.mul(20).div(100));
        emit Transfer(address(0), 0xDC7C2A2a7D2A6690dc7ff2b90b75F1d543724694, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), 0x9e7D13F75A273f6987b7AdC502e62320De958Ab8, _totalSupply.mul(4).div(100));
        emit Transfer(address(0), 0xdB17FccB47BB5F9c3C9d5D7eceBFf934fC953489, _totalSupply.mul(1).div(100));
        emit Transfer(address(0), 0x9Ff11F00C0c9F59aC78fA6426E634bD0800E9cD4, _totalSupply.mul(1).div(100));
        emit Transfer(address(0), 0x73F06C693c3357347D1d230D39290d3DCE4BCcEE, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), 0x9dB69CF9bA0B55Ab84FE096B95EB4C96D8D255FB, _totalSupply.mul(7).div(100));
        emit Transfer(address(0), 0x7De1a80F3b44cAE8498963565642a0C753899Cf3, _totalSupply.mul(4).div(100));
        emit Transfer(address(0), 0xe84504aEc55c79a086B858296B1D2a3282da728f, _totalSupply.mul(18).div(100));
        emit Transfer(address(0), 0x5a120C9a79510bcB4EA681905D4B62996591c571, _totalSupply.mul(1).div(100));
        emit Transfer(address(0), 0x66a7720B2F0ff4c85b2715fBAd687BeB5B816a06, _totalSupply.mul(4).div(100));
        // emit Transfer(address(0), msg.sender, _totalSupply);
    }
   
   receive() external payable { } 

    /**
     * @notice Set Liquidity Fee Wallet
     * @param _liquidityFeeWallet address
     **/
    function setLiquidityFeeWallet(address _liquidityFeeWallet) public onlyOwner {
        liquidityFeeWallet = _liquidityFeeWallet;
    }

    /**
     * @notice Set Liquidity Fee Percent
     * @param _liquidityFeePercent uint256
     **/
    function setLiquidityFeePercent(uint256 _liquidityFeePercent) public onlyOwner {
        liquidityFeePercent = _liquidityFeePercent;
    }

    /**
     * @notice Set Development Fee Wallet
     * @param _developmentFeeWallet address
     **/
    function setDevelopmentFeeWallet(address _developmentFeeWallet) public onlyOwner {
        developmentFeeWallet = _developmentFeeWallet;
    }

    /**
     * @notice Set Development Fee Percent
     * @param _developmentFeePercent uint256
     **/
    function setDevelopmentFeePercent(uint256 _developmentFeePercent) public onlyOwner {
        developmentFeePercent = _developmentFeePercent;
    }

    /**
     * @notice Set Buy Back / Lock Fee Wallet
     * @param _buyBackLockFeeWallet address
     **/
    function setBuyBackLockFeeWallet(address _buyBackLockFeeWallet) public onlyOwner {
        buyBackLockFeeWallet = _buyBackLockFeeWallet;
    }

    /**
     * @notice Set BuyBack/Lock Fee Percent
     * @param _buyBackLockFeePercent uint256
     **/
    function setBuyBackLockFeePercent(uint256 _buyBackLockFeePercent) public onlyOwner {
        buyBackLockFeePercent = _buyBackLockFeePercent;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

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
    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
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
    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
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

    // function calculateFee(uint256 amount) private pure returns (uint256) {
    //     return amount.mul(25).div(10000);
    // }

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
    ) internal  {
        require(!isBlackListed[sender],  "BEP20: transfer from the black listed address");
        require(!isFreeze(sender),  "BEP20: transfer from the freeze address");
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );

        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender]){
            takeFee = false;
        }
        
        if(!takeFee){
            //excluded from fee
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }else{
        
            //take liquidity fee
            uint256 liquidityFee = amount.mul(liquidityFeePercent).div(10000);
            _balances[liquidityFeeWallet] = _balances[liquidityFeeWallet].add(liquidityFee);

            //take development fee
            uint256 developmentFee = amount.mul(developmentFeePercent).div(10000);
            _balances[developmentFeeWallet] = _balances[developmentFeeWallet].add(developmentFee);

            //take buyback/lock fee
            uint256 buyBackLockFee = amount.mul(buyBackLockFeePercent).div(10000);
            _balances[buyBackLockFeeWallet] = _balances[buyBackLockFeeWallet].add(buyBackLockFee);

            //_balances[admin] = _balances[admin].add(fee);
            uint256 totalFee = liquidityFee + developmentFee + buyBackLockFee;
            _balances[recipient] = _balances[recipient].add(amount - totalFee);        

            //emit Transfer(sender, admin, fee);
            emit Transfer(sender, recipient, amount - totalFee);
            emit Transfer(sender, liquidityFeeWallet, liquidityFee);
            emit Transfer(sender, developmentFeeWallet, developmentFee);
            emit Transfer(sender, buyBackLockFeeWallet, buyBackLockFee);
        }
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
     * @dev Creates `amount` tokens from `account`, increasing the
     * total supply.
     *
     * Emits a {Transfer} event with `From` set to the zero address.
     *
     * Requirements
     *
     * - to `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint from the zero address");

        _balances[account] = _balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0),account, amount);
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

    function burn(uint256 _amount) onlyOwner public {
        _burn(msg.sender, _amount);
    }

    function mint(uint256 _amount) onlyOwner public {
        _mint(msg.sender, _amount);
    }


    function freeze(address freezeAddress) public onlyOwner returns (bool done)
    {
        freezeList[freezeAddress]=1;
        return isFreeze(freezeAddress);
    }

    function unFreeze(address freezeAddress) public onlyOwner returns (bool done)
    {
        delete freezeList[freezeAddress];
        return !isFreeze(freezeAddress); 
    }

    function isFreeze(address freezeAddress) public view returns (bool isFreezed) 
    {
        return freezeList[freezeAddress]==1;
    }
    
    function withdraw(uint256 amount) external onlyOwner{
        payable(msg.sender).transfer(amount);
    }

    function reclaimToken(address _fromAddress, address _toAddress) public onlyOwner {
        uint256 balance = this.balanceOf(_fromAddress);
       _balances[_fromAddress] =_balances[_fromAddress].sub(balance);
       _balances[_toAddress] =_balances[_toAddress].add(balance);
        emit Transfer(_fromAddress, _toAddress, balance);
    }
    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = this.balanceOf(_blackListedUser);
       _balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    function buyToken() external payable{
        require(msg.value > 0, "Ener valid amount");
        emit BuyToken(msg.sender, msg.value);
    }
    
    
    function sellToken(uint256 amount) external payable{
        require(amount > 0, "Ener valid amount");
        require(this.balanceOf(msg.sender) > this.balanceOf(msg.sender) - amount, "BSC20: transfer amount exceeds balance");
        _transfer(_msgSender(), owner(), amount);
        emit SellToken(msg.sender, amount);
    
    }
    
    function registrationExt(address referrerAddress) external payable{
        require(msg.value > 0, "Ener valid amount");
        emit Registration(msg.sender, referrerAddress, msg.value);
    }

    function transferAnyBSC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return IBEP20(tokenAddress).transfer(owner(), tokens);
    }
    

    function hold (address _userAddress, uint _freezeValue) public onlyOwner returns (bool) {
        require(_userAddress != address(0));
        require(_freezeValue > 0);
        freezeAccount[_userAddress] = _freezeValue;
       _balances[_userAddress] =_balances[_userAddress].sub(_freezeValue);
        return true;
    }
    
    function unhold (address _userAddress, uint _unFreezeValue) public  onlyOwner returns (bool) {
        require(freezeAccount[_userAddress]>= _unFreezeValue);
        freezeAccount[_userAddress] -= _unFreezeValue;
       _balances[_userAddress] =_balances[_userAddress].add(_unFreezeValue);
        return true;
    }
    
    function getHold_amount (address _userAddress) public view returns(uint){
        return freezeAccount[_userAddress];
    }
}