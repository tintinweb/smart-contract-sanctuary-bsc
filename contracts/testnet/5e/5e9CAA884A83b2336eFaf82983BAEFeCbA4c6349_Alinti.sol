/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

pragma solidity ^0.8.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function vestingApprove(address _to, uint256 _amount) external  ;
}

interface Router {
    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint256[] memory amounts);  

    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address to, 
        uint deadline
    )external payable returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint256[] memory amounts);
}


contract Alinti is Ownable {
    using SafeMath for uint256;

    address private ROUTER;
    address private TOKEN;
    uint256 public distribution;
    uint256 public soldOut;

    // Public sale variables
    mapping (string => address) private tokenAcepted;
    
    struct PublicSale {
        uint256 price;
        uint256 dateInit;
        uint256 dateEnd;
        uint256 min;
        uint256 max;
    }
    mapping(uint256 => PublicSale) public publicSale;

    // Vesting variables (Buyer / Date)
    uint256 private indexVesting;

    struct VestingBuyer{
        address to;
        uint256 amount;
        uint256 total;
    }
    mapping(uint256 => VestingBuyer) public vestingBuyer;
    mapping(address => uint256) public vestingAddress;

    struct VestingDate {
        uint256 timestamp;
        bool status;
    }
    mapping(uint256 => VestingDate) public vestingDate;

    constructor() {
        distribution = ((5 * ((10 ** 8) * (10 ** 8))) * 7 ) / 100;
        soldOut = 0;

        ROUTER =   0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //Panckeswap
        TOKEN =  0x9981B28C0F1F265Faf3C984B1375556A50f32DA9; //Contract ALIINTI

        tokenAcepted["BUSD"] = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        tokenAcepted["USDC"] = 0x8a9424745056Eb399FD19a0EC26A14316684e274;

        publicSale[1] = PublicSale(300, 1653751800, 1653752400, 33333333333, 16666666666667); //0.03$ 15-08-2022 - 15-10-2022 100$ - 50000$
        publicSale[2] = PublicSale(400, 1653752460, 1653753000, 25000000000, 25000000000000); //0.4$ 16-10-2022 - 30-10-2022 100$ - 100000$
        publicSale[3] = PublicSale(500, 1653753060, 1653753600, 20000000000, 40000000000000); //0.5$ 31-10-2022 - 15-11-2022 100$ - 200000$

        indexVesting = 0;
        vestingDate[1] = VestingDate(1653753900, false); //15-01-2023
        vestingDate[2] = VestingDate(1653754200, false); //15-02-2023
        vestingDate[3] = VestingDate(1653754500, false); //15-03-2023
        vestingDate[4] = VestingDate(1653754800, false); //15-04-2023
        vestingDate[5] = VestingDate(1653755400, false); //15-05-2023
        vestingDate[6] = VestingDate(1653756000, false); //15-06-2023
        vestingDate[7] = VestingDate(1653756600, false); //15-07-2023
        vestingDate[8] = VestingDate(1653757200, false); //15-08-2023
        vestingDate[9] = VestingDate(1653757800, false); //15-09-2023
        vestingDate[10] = VestingDate(1653758400, false);//15-10-2023
        vestingDate[11] = VestingDate(1653759000, false); //15-11-2023
    }

    function buyPublicSale(string memory _token, uint256 _amount) public {
        require ((keccak256(abi.encodePacked(_token)) == keccak256(abi.encodePacked("BUSD"))) || 
        (keccak256(abi.encodePacked(_token)) == keccak256(abi.encodePacked("USDC"))), "is not a valid token");
        uint256 _index = getPriceSale();
        uint256 _quantity = getCalculateReceive(_amount);

        requireBuy(_index, _quantity);
        IERC20(tokenAcepted[_token]).transferFrom(msg.sender, address(this), _amount);
        setListVesting(_quantity);
    }

    function buyPublicSaleEth() public payable {
        uint256 _index = getPriceSale();
        address[] memory _path = getPath(Router(ROUTER).WETH());
        uint256[] memory values = getAmountsOut(msg.value, _path);
        uint256 _quantity = getCalculateReceive(values[1]);

        requireBuy(_index, _quantity);
        Router(ROUTER).swapETHForExactTokens{value: msg.value}(values[1], _path, address(this), block.timestamp);
        setListVesting(_quantity);
    }

    function buyPublicSaleToken(address  _address, uint256 _amount) public {
        uint256 _index = getPriceSale();
        address[] memory _path = getPath(_address);
        uint256[] memory values = getAmountsOut(_amount, _path);
        uint256 _quantity = getCalculateReceive(values[2]);

        requireBuy(_index, _quantity);
        IERC20(_address).transferFrom(msg.sender, address(this), _amount);
        IERC20(_address).approve(ROUTER, _amount);
        Router(ROUTER).swapExactTokensForTokens(_amount, 0, _path, address(this), block.timestamp);
        setListVesting(_quantity); 
    }

    function getAmountsOut (uint256 _amount, address[] memory _path) public view returns (uint256[] memory) {
        return Router(ROUTER).getAmountsOut(_amount, _path);
    }

    function getCalculateReceive(uint256 _amount) public view returns(uint256){
        return ((_amount/ 10 ** 10)*100) / publicSale[getPriceSale()].price;
    }


    function getBalance() public view returns(uint256) {
        return IERC20(TOKEN).balanceOf(address(this));
    }

    function getBalanceTotal() public view returns(uint256) {
        uint256 _BUSD = IERC20(tokenAcepted["BUSD"]).balanceOf(address(this));
        uint256 _USDC = IERC20(tokenAcepted["USDC"]).balanceOf(address(this));
        return _BUSD + _USDC;
    }

    function getBalanceToken(string memory _token) public view returns(uint256) {
        return IERC20(tokenAcepted[_token]).balanceOf(address(this));
    }

    function getPath(address _address) internal view returns (address[] memory) {
        address[] memory _path;
        if(Router(ROUTER).WETH() ==_address){
            _path = new address[](2);
            _path[0] = _address;
            _path[1] = tokenAcepted["BUSD"];
        }else {
            _path = new address[](3);
            _path[0] = _address;
            _path[1] = Router(ROUTER).WETH();
            _path[2] = tokenAcepted["BUSD"];
        }
        return  _path;
    }

    function getPriceSale() public view returns (uint256) {
        uint256 _index = 0;
        for(uint256 i = 1; i < 4; i++) {
            if(block.timestamp > publicSale[i].dateInit  &&  block.timestamp < publicSale[i].dateEnd) {
                _index = i;
            }
        }
        return _index;
    }

    function getVestingDate() public view returns (uint256) {
        uint256 _index = 0;
        for(uint256 i = 1; i < 13; i++) {
            if(block.timestamp > vestingDate[i].timestamp  && !vestingDate[i].status){
                 _index = i;
                 break;
            }
        }
        return  _index;
    }

    function requireBuy(uint256 _index, uint256 _quantity ) internal view {
        require (_index > 0, "Public sale is not available");
        require (distribution >= (soldOut + _quantity), "All the tokens of the public sale have already been sold");
        require (_quantity >= publicSale[_index].min, "Enter the minimum amount");
        require (publicSale[_index].max >= vestingBuyer[vestingAddress[msg.sender]].total, "You cannot acquire more tokens");
   }

    function setListVesting(uint256 _quantity) internal{
        uint256 _indexVesting = vestingAddress[msg.sender];
        if(_indexVesting == 0){
             ++indexVesting;
             _indexVesting= indexVesting;
        }
        vestingAddress[msg.sender] = _indexVesting;
        vestingBuyer[_indexVesting] = VestingBuyer(msg.sender, vestingBuyer[_indexVesting].amount + (_quantity/12), vestingBuyer[_indexVesting].total + _quantity);
        IERC20(TOKEN).transfer(vestingBuyer[_indexVesting].to, vestingBuyer[_indexVesting].amount);
        soldOut =  soldOut +_quantity;

    }

    function vesting() external onlyOwner {
        uint256 _index = getVestingDate();
        require (_index > 0, "Not available");
        vestingDate[_index].status = true;

        for(uint256 i = 1;  i<= indexVesting; i++){
            if(vestingBuyer[i].amount > 0) {
                IERC20(TOKEN).transfer(vestingBuyer[i].to, vestingBuyer[i].amount);
            }
        }
    }

    function withdrawAlinti() external onlyOwner{
        IERC20(TOKEN).transfer(TOKEN, getBalance());
    }

    function withdrawTokenAcepted(string memory _token, address _recipient, uint256 _amount) external onlyOwner{
        IERC20(tokenAcepted[_token]).transfer(_recipient, _amount);
    }

    //TESTNET
    function setPublicPrice(uint256 _index, uint256 _price, uint256 _init, uint256 _end, uint256 _priceMin, uint256 _priceMax ) external onlyOwner{
        publicSale[_index] = PublicSale(_price, _init, _end, _priceMin, _priceMax); //0.3$ 15-08-2022 - 15-10-2022 100$ - 50000$
    }

    function setVesting(uint256 _index, uint256 _timestamp, bool _status) external onlyOwner{
        vestingDate[_index] = VestingDate(_timestamp, _status); 
    }

    function resetContract() external onlyOwner {
        for(uint256 i = 1;  i<= indexVesting; i++){
            vestingBuyer[i].amount = 0;
            vestingBuyer[i].total = 0;
        }

        for(uint256 i = 1;  i< 12; i++){
            vestingDate[i].status = false;
        }
    }

}