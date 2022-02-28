/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.11;

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
     *
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: @pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol

pragma solidity ^0.6.11;

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

pragma solidity ^0.6.11;

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
        bytes32 accountHash =
            0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) =
            target.call{value: weiValue}(data);
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

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(
                value,
                "SafeBEP20: decreased allowance below zero"
            );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeBEP20: low-level call failed"
            );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}



contract Earnchain {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    address public owner;
    IBEP20 public busdToken;
    struct User {
        bool isExist;
        uint id;
        uint referrerID;
        uint originalReferrer;
        uint directCount;
        uint256 gainAmount;
        address[] referral;
        address[] directUsers;
        bool isbronze;
        bool issilver;
        bool isgold;
        uint256 levelIncome;
        uint256 memberIncome;
        uint256 referralIncome;
        uint256 leaderIncome;
    }
    uint256[] public memberChain;
    uint256[] public referralChainFirst;
    uint256[] public referralChainTwo;
    uint256[] public referralChainThree;
    uint256[] public leaderBronze;
    uint256[] public leaderSilver;
    uint256[] public leaderGold;
    mapping(address => User) public users;
    mapping (uint => address) public userAddressByID;
    mapping (address => uint) public userAddress;
    uint256 public activateAmount = 30000000000000000000;
    uint256 public referralBonus =  30;
    uint256 public maxDownLimit = 3;
    uint8[] public ref_bonuses;
    uint256 public currUserID;
    constructor(IBEP20 _busdToken,address _ownerAddress) public {
        owner = _ownerAddress;
        busdToken = _busdToken;
        ref_bonuses.push(6);
        ref_bonuses.push(4);
        ref_bonuses.push(4);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        currUserID++;
        User memory user;
        user = User({
            isExist : true,
            id : currUserID,
            referrerID: 0,
            originalReferrer: 0,
            directCount: 0,
            gainAmount : 0,
            referral : new address[](0),
            directUsers : new address[](0),
            isbronze : false,
            issilver : false,
            isgold : false,
            levelIncome :0,
            referralIncome :0,
            memberIncome :0,
            leaderIncome:0
        });
        users[owner] = user;
        memberChain.push(currUserID);
        userAddressByID[currUserID] = owner;
        userAddress[owner] = currUserID;
    } 
    
     function activatePlan(address _referrer, uint256 amount) public {
        require(!users[msg.sender].isExist, 'User exist');
        uint _referrerID;
        busdToken.safeTransferFrom(address(msg.sender), address(this), amount);
         if (users[_referrer].isExist){
            _referrerID = users[_referrer].id;
            uint256 referAmount = activateAmount.mul(referralBonus)/100;
            busdToken.transfer(_referrer,referAmount);
            users[_referrer].gainAmount = referAmount;
        }
        uint ownerAmount = activateAmount.mul(2)/100;
        busdToken.transfer(owner,ownerAmount);
        uint originalReferrer = userAddress[_referrer];
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');
        if(users[userAddressByID[_referrerID]].referral.length >= maxDownLimit) _referrerID = users[findFreeReferrer(userAddressByID[_referrerID])].id;
          User memory user;
         currUserID++;
         user = User({
            isExist : true,
            id : currUserID,
            referrerID : _referrerID,
            originalReferrer : originalReferrer,
            directCount : 0,
            gainAmount : 0,
            referral : new address[](0),
            directUsers : new address[](0),
            isbronze : false,
            issilver : false,
            isgold : false,
            levelIncome : 0,
            referralIncome :0,
            memberIncome :0,
            leaderIncome:0
        });
        users[msg.sender] = user;
        memberChain.push(currUserID);
        userAddressByID[currUserID] = msg.sender;   
        userAddress[msg.sender] = currUserID;
        users[userAddressByID[_referrerID]].referral.push(msg.sender);
        users[userAddressByID[originalReferrer]].directUsers.push(msg.sender);
        users[userAddressByID[originalReferrer]].directCount++;
        if(users[userAddressByID[originalReferrer]].directCount == 3){
            referralChainFirst.push(originalReferrer);
        }
        if(users[userAddressByID[originalReferrer]].directCount == 12){
            referralChainTwo.push(originalReferrer);
        }  
        if(users[userAddressByID[originalReferrer]].directCount == 39){
            referralChainThree.push(originalReferrer);
        }   
        //find Level
         checklevelandpush(_referrerID,1);   
         payReferral(_referrerID,0); //levelincome
         payForMember();    //memberIncome 
         payforChains();    // Referral Chain Income 
         payforLeaders();  // Referral Chain Leader
     }

     function checklevelandpush(
        uint _referrerID,
        uint inc
      ) internal {
         address referAddress = userAddressByID[_referrerID];
          uint upliner =  users[referAddress].referrerID;
          if(users[userAddressByID[upliner]].isExist && users[userAddressByID[upliner]].directCount >= 12){
              if(inc == 1 && users[userAddressByID[upliner]].isbronze == false){
                  users[userAddressByID[upliner]].isbronze = true;
                  leaderBronze.push(upliner);
              }
              if(inc == 3 && users[userAddressByID[upliner]].issilver == false){
                  users[userAddressByID[upliner]].issilver = true;
                  leaderSilver.push(upliner);
              }
              if(inc == 5 && users[userAddressByID[upliner]].isgold == false){
                  users[userAddressByID[upliner]].isgold = true;
                  leaderGold.push(upliner);
              }
              checklevelandpush(upliner,inc++);
          }
      }

    
     
      function payReferral(
        uint _referrerID,
        uint inc
      ) internal {
           address referAddress = userAddressByID[_referrerID];
          if(inc < 5){
              uint levelAmount = activateAmount.mul(ref_bonuses[inc])/100;
              busdToken.transfer(referAddress,levelAmount);
              users[referAddress].gainAmount += levelAmount;
              users[referAddress].levelIncome += levelAmount;
          }
          if(referAddress != owner){
            uint upliner =  users[referAddress].referrerID;
            inc++;
            payReferral(upliner,inc);
          }
      }

    function payForMember() internal {
        uint amountTransfer = activateAmount.mul(1)/100;
        for(uint i=0; i< memberChain.length;i++){
            address useraddress = userAddressByID[memberChain[i]];
            if(users[useraddress].isExist && i < 4 && useraddress != msg.sender){
                busdToken.transfer(useraddress,amountTransfer); 
                users[useraddress].gainAmount += amountTransfer; 
                users[useraddress].memberIncome += amountTransfer;
            }
        }
        for (uint i = memberChain.length-1; i >= 4; i--) {
            address useraddress = userAddressByID[memberChain[i]];
            if(users[useraddress].isExist && useraddress != msg.sender){
                busdToken.transfer(useraddress,amountTransfer); 
                users[useraddress].gainAmount += amountTransfer; 
                users[useraddress].memberIncome += amountTransfer;
            }

        }
    }

    function payforChains() internal {
      uint amountTransferR1R2 = activateAmount.mul(2)/100;
      uint amountTransferR3 = activateAmount.mul(3)/100;
       if(referralChainFirst.length > 0){
           address topreferOne = userAddressByID[referralChainFirst[0]];
           busdToken.transfer(topreferOne,amountTransferR1R2); 
           users[topreferOne].gainAmount += amountTransferR1R2;
           address lastAddress = userAddressByID[referralChainFirst[referralChainFirst.length-1]];
           if(topreferOne != lastAddress){
               busdToken.transfer(lastAddress,amountTransferR1R2); 
               users[lastAddress].gainAmount += amountTransferR1R2;
           }
       }
       if(referralChainTwo.length > 0){
           address topreferTwo = userAddressByID[referralChainTwo[0]];
           busdToken.transfer(topreferTwo,amountTransferR1R2); 
           users[topreferTwo].gainAmount += amountTransferR1R2;
           address lastAddressTwo = userAddressByID[referralChainTwo[referralChainTwo.length-1]];
           if(topreferTwo != lastAddressTwo){
               busdToken.transfer(lastAddressTwo,amountTransferR1R2); 
               users[lastAddressTwo].gainAmount += amountTransferR1R2;
           }
       }
       if(referralChainThree.length > 0){
           address topreferOne = userAddressByID[referralChainThree[0]];
           busdToken.transfer(topreferOne,amountTransferR3); 
           users[topreferOne].gainAmount += amountTransferR3;
           address lastAddress = userAddressByID[referralChainThree[referralChainThree.length-1]];
           if(topreferOne != lastAddress){
               busdToken.transfer(lastAddress,amountTransferR3); 
               users[lastAddress].gainAmount += amountTransferR3;
           }
       }
    }

    function payforLeaders() internal { 
      uint amountTransferR1R2 = activateAmount.mul(2)/100;
      uint amountTransferR3 = activateAmount.mul(4)/100;
       if(leaderBronze.length > 0){
           address topreferOne = userAddressByID[leaderBronze[0]];
           busdToken.transfer(topreferOne,amountTransferR1R2); 
           users[topreferOne].gainAmount += amountTransferR1R2;
            users[topreferOne].leaderIncome += amountTransferR1R2;
           address lastAddress = userAddressByID[leaderBronze[leaderBronze.length-1]];
           if(topreferOne != lastAddress){
               busdToken.transfer(lastAddress,amountTransferR1R2); 
               users[lastAddress].gainAmount += amountTransferR1R2;
               users[lastAddress].leaderIncome += amountTransferR1R2;
           }
       }
       if(leaderSilver.length > 0){
           address topreferOne = userAddressByID[leaderSilver[0]];
           busdToken.transfer(topreferOne,amountTransferR1R2); 
           users[topreferOne].gainAmount += amountTransferR1R2;
            users[topreferOne].leaderIncome += amountTransferR1R2;
           
           address lastAddress = userAddressByID[leaderSilver[leaderSilver.length-1]];
           if(topreferOne != lastAddress){
               busdToken.transfer(lastAddress,amountTransferR1R2); 
               users[lastAddress].gainAmount += amountTransferR1R2;
               users[lastAddress].leaderIncome += amountTransferR1R2;
           }
       }
       if(leaderGold.length > 0){
           address topreferOne = userAddressByID[leaderGold[0]];
           busdToken.transfer(topreferOne,amountTransferR3); 
           users[topreferOne].gainAmount += amountTransferR3;
          users[topreferOne].leaderIncome += amountTransferR1R2;

           address lastAddress = userAddressByID[leaderGold[leaderGold.length-1]];
           if(topreferOne != lastAddress){
               busdToken.transfer(lastAddress,amountTransferR3); 
               users[lastAddress].gainAmount += amountTransferR3;
               users[lastAddress].leaderIncome += amountTransferR1R2;
           }
       }
    }

    
     function findFreeReferrer(address _user) public view returns(address) {
        if(users[_user].referral.length < maxDownLimit) return _user;
        address[] memory referrals = new address[](500);
        referrals[0] = users[_user].referral[0];
        referrals[1] = users[_user].referral[1];
        referrals[2] = users[_user].referral[2];
        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 500; i++) {
            if(users[referrals[i]].referral.length == maxDownLimit) {
                //if(i < 62) {
                    referrals[(i+1)*3] = users[referrals[i]].referral[0];
                    referrals[(i+1)*3+1] = users[referrals[i]].referral[1];
                    referrals[(i+1)*3+2] = users[referrals[i]].referral[2];
                //}
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }
     
   function getreferral(address useraddress)
        public
        view
        returns (address[] memory)
    {
        require(users[useraddress].isExist, "User Not Exists");
       
        return users[useraddress].referral;
    }
}