// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/*
 *Demetra.finance
 *Security Provider
 *Inheritance protocol eliminates concerns about loss of crypto assets even after the death with assigning backup wallet or setup a will
 *Private sale contract with 3 Tiers with different allocation
 *Tier 0.0 -> public
 *Tier 1.0 -> 0.1 - 5 BNB
 *Tier 2.0 -> 5 - 20 BNB
 */

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DemetraPresale is Ownable {
    
    bool public isPublic;
    //token attributes
    string public constant NAME = "DMT Private Sale"; //name of the contract
    uint256 public  maxCap = 500 * (10**18); // Max cap in BNB

    uint256 public saleStartTime; // start sale time
    uint256 public saleEndTime; // end sale time in tier 1

    uint256 public totalBnbReceivedInAllTier; // total bnd received

    uint256 public totalBnbInTierZero; // total bnb for tier Zero
    uint256 public totalBnbInTierOne; // total bnb for tier one
    uint256 public totalBnbInTierTwo; // total bnb for tier two

    uint256 public totalparticipants; // total participants
    address payable public projectOwner; // project Owner

    // max cap per tier

    uint256 public tierZeroMaxCap;
    uint256 public tierOneMaxCap;
    uint256 public tierTwoMaxCap;

    //max allocations per user in a tier

    uint256 public maxAllocaPerUserTierZero;
    uint256 public maxAllocaPerUserTierOne;
    uint256 public maxAllocaPerUserTierTwo;

    //min allocation per user in a tier

    uint256 public minAllocaPerUserTierZero;
    uint256 public minAllocaPerUserTierOne;
    uint256 public minAllocaPerUserTierTwo;

    //tier 1 is public no whitelist
    // address array for tier one whitelist
    //address[] private whitelistTierOne;
    address[] private whitelistTierOne;
    address[] private whitelistTierTwo;

    //mapping the user purchase per tier

    mapping(address => uint256) public buyInTierZero;
    mapping(address => uint256) public buyInTierOne;
    mapping(address => uint256) public buyInTierTwo;

    address[] public tierZeroParticipants;
    address[] public tierOneParticipants;
    address[] public tierTwoParticipants;
    

    // CONSTRUCTOR
    constructor(
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        address payable _projectOwner,
        uint256 _tierOneValue, //percentage eg = 30
        uint256 _tierTwoValue //percentage eg = 70
      ) {
        isPublic = false; //whitelist

        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;

        projectOwner = _projectOwner;

        tierOneMaxCap = _tierOneValue * (maxCap / 100);
        tierTwoMaxCap = _tierTwoValue * (maxCap / 100);
        tierZeroMaxCap = maxCap - tierOneMaxCap - tierTwoMaxCap; //public

        minAllocaPerUserTierZero = 10 **17;
        minAllocaPerUserTierOne = 10**17;
        minAllocaPerUserTierTwo = 5 * (10**18);

        maxAllocaPerUserTierZero = 20 * 10**18;
        maxAllocaPerUserTierOne = 5 * 10**18;
        maxAllocaPerUserTierTwo = 20 * 10**18;

        totalparticipants = 0;
    }

    

     //function to set tier manually
    function changeTier(
        bool _isPublic,
        uint256 _tierOneValue,
        uint256 _tierTwoValue
    ) external onlyOwner {
        isPublic = _isPublic;
        if(isPublic){
            tierZeroMaxCap = maxCap - totalBnbReceivedInAllTier;
            tierOneMaxCap = totalBnbInTierOne;
            tierTwoMaxCap=totalBnbInTierTwo;
        }
        else{
            tierZeroMaxCap = 0;
            tierOneMaxCap = _tierOneValue * (maxCap / 100);
            tierTwoMaxCap = _tierTwoValue * (maxCap / 100);
        }
    }

    function setStartTime(uint256 start) external onlyOwner{
        saleStartTime = start;
    }
    function setEndTime(uint256 end) external onlyOwner{
        saleEndTime = end;
    }
    //add the address in Whitelist tier one to invest
    function addWhitelistOne(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        whitelistTierOne.push(_address);
    }

    //add the address in Whitelist tier two to invest
    function addWhitelistTwo(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        whitelistTierTwo.push(_address);
    }

   

    // check the address in whitelist tier two
    function getWhitelistOne(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTierOne.length;
        for (i = 0; i < length; i++) {
            if (whitelistTierOne[i] == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier three
    function getWhitelistTwo(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTierTwo.length;
        for (i = 0; i < length; i++) {
            if (whitelistTierTwo[i] == _address) {
                return true;
            }
        }
        return false;
    }

    

    // send bnb to the contract address
    receive() external payable {
        require(
            block.timestamp >= saleStartTime,
            "The sale is not started yet "
        ); // solhint-disable
        require(block.timestamp <= saleEndTime, "The sale is closed"); // solhint-disable
        require(
            totalBnbReceivedInAllTier + msg.value <= maxCap,
            "buyTokens: purchase would exceed max cap"
        );

        if (isPublic) {
            require(
                buyInTierZero[msg.sender] + msg.value >= minAllocaPerUserTierZero,
                "your purchasing Power is so Low"
            );
            require(
                buyInTierZero[msg.sender] + msg.value <= maxAllocaPerUserTierZero,
                "you are investing more than your Tier 0.0 limit!"
            );
            require(
                totalBnbInTierZero + msg.value <= tierZeroMaxCap,
                "buyTokens: purchase would exceed Tier one max cap"
            );
            require(
                buyInTierZero[msg.sender] +buyInTierOne[msg.sender] +buyInTierTwo[msg.sender] + msg.value <= maxAllocaPerUserTierZero,
                "buyTokens:You are investing more than your all Tiers limit!"
            );

            

            buyInTierZero[msg.sender] += msg.value;
            tierZeroParticipants.push(msg.sender);
            totalBnbReceivedInAllTier += msg.value;
            totalBnbInTierZero += msg.value;
            
             //payable(projectOwner).transfer(address(this).balance);
             Address.sendValue(payable(projectOwner), address(this).balance);
             //payable(projectOwner).sendValue(projectOwner,address(this).balance);
        } else if (getWhitelistOne(msg.sender)) {
            require(
                buyInTierOne[msg.sender] + msg.value >= minAllocaPerUserTierOne,
                "your purchasing Power is so Low"
            );
            require(
                totalBnbInTierOne + msg.value <= tierOneMaxCap,
                "buyTokens: purchase would exceed Tier 1.0 max cap"
            );
            require(
                buyInTierOne[msg.sender] + msg.value <= maxAllocaPerUserTierOne,
                "buyTokens:You are investing more than your Tier 1.0 limit!"
            );
            require(
                buyInTierZero[msg.sender] +buyInTierOne[msg.sender] +buyInTierTwo[msg.sender] + msg.value <= maxAllocaPerUserTierOne,
                "buyTokens:You are investing more than your all Tiers limit!"
            );

            buyInTierOne[msg.sender] += msg.value;
            tierOneParticipants.push(msg.sender);
            totalBnbReceivedInAllTier += msg.value;
            totalBnbInTierOne += msg.value;
            //sendValue(projectOwner, address(this).balance);
            //payable(projectOwner).transfer(address(this).balance);
            Address.sendValue(payable(projectOwner), address(this).balance);
        } else if (getWhitelistTwo(msg.sender)) {
            require(
                buyInTierTwo[msg.sender] + msg.value >=
                    minAllocaPerUserTierTwo,
                "your purchasing Power is so Low"
            );
            require(
                buyInTierTwo[msg.sender] + msg.value <=
                    maxAllocaPerUserTierTwo,
                "buyTokens:You are investing more than your tier-3 limit!"
            );
            require(
                totalBnbInTierTwo + msg.value <= tierTwoMaxCap,
                "buyTokens: purchase would exceed Tier three max cap"
            );
            require(
                buyInTierZero[msg.sender] +buyInTierOne[msg.sender] +buyInTierTwo[msg.sender] + msg.value <= maxAllocaPerUserTierTwo,
                "buyTokens:You are investing more than your all Tiers limit!"
            );
            buyInTierTwo[msg.sender] += msg.value;
            tierTwoParticipants.push(msg.sender);
            totalBnbReceivedInAllTier += msg.value;
            totalBnbInTierTwo += msg.value;
            //payable(projectOwner).transfer(address(this).balance);
            Address.sendValue(payable(projectOwner), address(this).balance);
        } else {
            revert();
        }
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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