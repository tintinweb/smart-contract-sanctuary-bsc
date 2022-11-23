/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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
    * @title Counters
    * @author Matt Condon (@shrugs)
    * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
    * of elements in a mapping, issuing BEP721 ids, or counting request ids.
    *
    * Include with `using Counters for Counters.Counter;`
*/
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
    address public _owner;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    *
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
    *
    * - The divisor cannot be zero.
    */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
* @dev Collection of functions related to the address type
*/
library Address {
    /**
    * @dev Returns true if `account` is a contract.
    *
    * [IMPORTANT]
    * ====
    * It is unsafe to assume that an address for which this function returns
    * false is an externally-owned account (EOA) and not a contract.
    *
    * Among others, `isContract` will return false for the following
    * types of addresses:
    *
    *  - an externally-owned account
    *  - a contract in construction
    *  - an address where a contract will be created
    *  - an address where a contract lived, but was destroyed
    * ====
    */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
    * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
    * `recipient`, forwarding all available gas and reverting on errors.
    *
    * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
    * of certain opcodes, possibly making contracts go over the 2300 gas limit
    * imposed by `transfer`, making them unable to receive funds via
    * `transfer`. {sendValue} removes this limitation.
    *
    * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
    *
    * IMPORTANT: because control is transferred to `recipient`, care must be
    * taken to not create reentrancy vulnerabilities. Consider using
    * {ReentrancyGuard} or the
    * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
    */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
    * @dev Performs a Solidity function call using a low level `call`. A
    * plain`call` is an unsafe replacement for a function call: use this
    * function instead.
    *
    * If `target` reverts with a revert reason, it is bubbled up by this
    * function (like regular Solidity function calls).
    *
    * Returns the raw returned data. To convert to the expected return value,
    * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
    *
    * Requirements:
    *
    * - `target` must be a contract.
    * - calling `target` with `data` must not revert.
    *
    * _Available since v3.1._
    */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
    }

    /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
    * `errorMessage` as a fallback revert reason when `target` reverts.
    *
    * _Available since v3.1._
    */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
    * but also transferring `value` wei to `target`.
    *
    * Requirements:
    *
    * - the calling contract must have an ETH balance of at least `value`.
    * - the called Solidity function must be `payable`.
    *
    * _Available since v3.1._
    */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
    * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
    * with `errorMessage` as a fallback revert reason when `target` reverts.
    *
    * _Available since v3.1._
    */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract MultiSaleDBdoge is Ownable{
    using SafeMath for uint256;
    using Address for address;

    bool _pause = false;
    modifier isPausable() {
        require(!_pause, "The Contract is paused. Presale is paused");
        _;
    }

    struct Receivers { 
        address wallet;
        uint256 amount;
    }
    mapping (address => uint) private pendingBalance;

    bool private inTransfer;
    uint256 private  _TRANSACTION_FEE;
    address private _token_Address;    
    address private _withOwner_Address;
    address private _companyAdress;

    uint256 private _DECIMALFACTOR = 10 ** uint256(18);

    constructor (
        address OwnerAddress,
        address token_Address,
        uint256 _transactionFee,
        address companyAddress
    ){
        _owner = OwnerAddress;
        _token_Address = token_Address;
        _TRANSACTION_FEE = _transactionFee;
        _companyAdress = companyAddress;
        _withOwner_Address = OwnerAddress;
    }

    function totalBalance() external view returns(uint256) {
        return payable(address(this)).balance;
    }

    function totalTokens() external view returns(uint256) {
        IBEP20 ContractAdd = IBEP20(_token_Address);
        return ContractAdd.balanceOf(address(this));
    }

    function balanceOf(address account) public view returns (uint256) {
        return pendingBalance[account];
    }

    function ContractStatusPause() public view returns (bool) {
        return _pause;
    }

    function getTransactionFee() public view returns (uint256) {
        return _TRANSACTION_FEE;
    }

    function withdrawAddress() public view returns (address) {
        return _withOwner_Address;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}
    
    function transferFromUser(address recipient, uint256 amount) public isPausable() {
        address sender = _msgSender();
        require(balanceOf(sender) > 0 && amount > 0 && amount <= balanceOf(sender), "You do not have enough balance for this Transaction");
        if(!inTransfer){
            inTransfer = true;
                uint256 fee = amount.mul(_TRANSACTION_FEE).div(100);
                pendingBalance[sender] -= amount;
                pendingBalance[_companyAdress] += fee;
                pendingBalance[recipient] += amount.sub(fee);
                pendingBalance[_companyAdress] += fee;
                emit TransferUser(sender, recipient, amount);
            inTransfer = false;
        }
    }
    
    function transferSwapUser(uint256 amount) public isPausable() {
        address sender = _msgSender();
        require(amount > 0 && balanceOf(sender) > 0 && amount <= balanceOf(sender), "You do not have enough balance for this Transaction");
        if(!inTransfer){
            inTransfer = true;
                pendingBalance[sender] -= amount;
                pendingBalance[address(this)] += amount;
                emit Transfer_Swap_User(sender, address(this), amount);
            inTransfer = false;
        }
    }

    function buyWithToken(string memory tokenName, uint256 tokenPrice,  uint256 TPrice) public isPausable() {
        require(tokenPrice > 0, "Insufficient amount for this transaction");
        IBEP20 ContractToken = IBEP20(_token_Address);
        uint256 dexBalance2 = ContractToken.balanceOf(msg.sender);
        require(TPrice > 0 && TPrice <= dexBalance2, "Insufficient amount for this transaction");
        require(ContractToken.transferFrom(msg.sender, _companyAdress, TPrice), "A transaction error has occurred. Check for approval.");

        emit Received(msg.sender, tokenPrice, TPrice, tokenName);
    }

    /*
    * @dev Update the addres token
    * @param addr of the token address
    */
    function setTokendress(address tokenAddr) external virtual onlyOwner {
        require(tokenAddr.isContract(), "The address entered is not valid");
        _token_Address = tokenAddr;
    }

    /*
    * @dev Update the WithdAdress for Withdraw
    * @param addr of the Wallet address
    */
    function setWithdAdress(address ownerAddress) public onlyOwner() {
        _withOwner_Address = ownerAddress;
    }

    /*
    * @dev Update the WithdAdress for Withdraw
    * @param addr of the Wallet address
    */
    function setCompanyAdress(address companyAddress) public onlyOwner() {
        _companyAdress = companyAddress;
    }
    
    /**
     * @dev Change fee amounts. Reviewed! Enter only the entire fee amount.
     */
	function updateFee(uint256 _transactionFee) public onlyOwner() {
        _TRANSACTION_FEE = _transactionFee; 
	}

    function DepositOwner(address wallet, uint256 amount) public onlyOwner {
        pendingBalance[wallet] += amount;
        emit DepositeUser(wallet, amount);
    }

    function DepositUser(uint256 amount) public isPausable() {
        address wallet = msg.sender;
        require(wallet != address(0), "To make the withdrawal, you need to register a valid address.");

        IBEP20 ContractToken = IBEP20(_token_Address);
        uint256 dexBalance = ContractToken.balanceOf(msg.sender);
        require(amount > 0 && amount <= dexBalance, "Insufficient amount for this transaction");
        require(ContractToken.transferFrom(wallet, address(this), amount), "A transaction error has occurred. Check for approval.");
        pendingBalance[wallet] += amount;

        emit DepositeUser(wallet, amount);
    }

    function multDepositOwner(Receivers[] memory wallets) public onlyOwner {
        for ( uint i = 0; i < wallets.length; i++ ){
            pendingBalance[wallets[i].wallet] += wallets[i].amount;
            emit DepositeUser(wallets[i].wallet, wallets[i].amount);
        }
    }

    function WithdOwner(address wallet, uint256 amount) public onlyOwner {
        require(balanceOf(wallet) > 0 && amount > 0 && amount <= balanceOf(wallet), "You do not have enough balance for this withdrawal");
        if(amount >= balanceOf(wallet))amount = balanceOf(wallet);
        pendingBalance[wallet] -= amount;

        emit WithdrawnUser(wallet, amount);
    }

    function WithdUser(uint256 amount) public isPausable() {
        address wallet = msg.sender;
        require(wallet != address(0), "To make the withdrawal, you need to register a valid address.");
        require(balanceOf(wallet) > 0 && amount > 0 && amount <= balanceOf(wallet), "You do not have enough balance for this withdrawal");
        if(amount >= balanceOf(wallet))amount = balanceOf(wallet);
        
        IBEP20 ContractAdd = IBEP20(_token_Address);
        ContractAdd.transfer(wallet, amount);
        pendingBalance[wallet] -= amount;

        emit WithdrawnUser(wallet, amount);
    }

    function multWithdOwner(Receivers[] memory wallets) public onlyOwner {
        for ( uint i = 0; i < wallets.length; i++ ){
            uint256 amount = wallets[i].amount;
            require(balanceOf(wallets[i].wallet) > 0 && amount > 0 && amount <= balanceOf(wallets[i].wallet), "You do not have enough balance for this withdrawal");
            if(amount >= balanceOf(wallets[i].wallet))amount = balanceOf(wallets[i].wallet);
            pendingBalance[wallets[i].wallet] -= amount;
            emit WithdrawnUser(wallets[i].wallet, amount);
        }
    }

    function withdTokens(address contractAddress) public onlyOwner(){
        require(_withOwner_Address != address(0), "To make the withdrawal, you need to register a valid address.");
        IBEP20 ContractAdd = IBEP20(contractAddress);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        ContractAdd.transfer(_withOwner_Address, dexBalance);
    }

    function withdBalance() public onlyOwner(){
        require(_withOwner_Address != address(0), "To make the withdrawal, you need to register a valid address.");
        require(this.totalBalance() > 0, "You do not have enough balance for this withdrawal");
        payable(_withOwner_Address).transfer(this.totalBalance());
    }

    function setPause() public onlyOwner() {
        if(_pause){
        _pause = false;
        }else{
        _pause = true;
        }
    }

    event DepositeUser(address indexed from, uint256 amount);
    event WithdrawnUser(address indexed from, uint256 amount);
    event TransferUser(address indexed from, address indexed to, uint value);
    event Transfer_Swap_User(address indexed from, address indexed to, uint value);
    event Received(address indexed from, uint256 amount, uint256 TPrice, string token);
}