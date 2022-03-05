/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/** 
 *  SourceUnit: /Users/steven/Projects/solidity/Chaindex-Bridge/contracts/BridgeGateway.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [////IMPORTANT]
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
     * ////IMPORTANT: because control is transferred to `recipient`, care must be
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




/** 
 *  SourceUnit: /Users/steven/Projects/solidity/Chaindex-Bridge/contracts/BridgeGateway.sol
*/
            
pragma solidity ^0.8.0;

interface IVRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function mint(uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




/** 
 *  SourceUnit: /Users/steven/Projects/solidity/Chaindex-Bridge/contracts/BridgeGateway.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




/** 
 *  SourceUnit: /Users/steven/Projects/solidity/Chaindex-Bridge/contracts/BridgeGateway.sol
*/
            
pragma solidity ^0.8.0;

////import "./Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




/** 
 *  SourceUnit: /Users/steven/Projects/solidity/Chaindex-Bridge/contracts/BridgeGateway.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

////import "./IVRC20.sol";
////import "./Address.sol";

/**
 * @title SafeVRC20
 * @dev Wrappers around VRC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeVRC20 for IVRC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeVRC20 {
    using Address for address;

    function safeTransfer(
        IVRC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IVRC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IVRC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IVRC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeVRC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IVRC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IVRC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeVRC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IVRC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeVRC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeVRC20: VRC20 operation did not succeed");
        }
    }
}



/** 
 *  SourceUnit: /Users/steven/Projects/solidity/Chaindex-Bridge/contracts/BridgeGateway.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import "./Ownable.sol";

contract Privilege is Ownable {

    uint256 public currentDay = 0;
    mapping(address => PrivilegeAccountStruct) private _privilegeAccountMap;
    struct PrivilegeAccountStruct {
        bool isState;
        uint256 dayMoney;
        uint256 dayMoneyLimit;
        uint256 totalMoney;
        address token20Address;
    }

    modifier limitMoneyPrivilegeAccount(uint256 tradeMoney,address token20Address) {
        require(
            _privilegeAccountMap[tx.origin].isState == true,
            "You have no privilege"
        );
        PrivilegeAccountStruct
            memory privilegeAccountStruct = _privilegeAccountMap[tx.origin];
        if (block.timestamp / 86400 > currentDay) {
            currentDay = block.timestamp / 86400;
            privilegeAccountStruct.dayMoney = privilegeAccountStruct
                .dayMoneyLimit;
        }
        require(
            privilegeAccountStruct.dayMoney >= tradeMoney,
            "The quota is exceeded on the day"
        );
        require(
            privilegeAccountStruct.totalMoney >= tradeMoney,
            "The total quota exceeds the limit"
        );
        require(
            privilegeAccountStruct.token20Address == token20Address,
            "Without permission"
        );
        privilegeAccountStruct.dayMoney -= tradeMoney;
        privilegeAccountStruct.totalMoney -= tradeMoney;
        _privilegeAccountMap[tx.origin] = privilegeAccountStruct;
        _;
    }

    function privilegeAccountMap(address privilegeAccount) public view returns (PrivilegeAccountStruct memory){
        PrivilegeAccountStruct memory privilegeAccountStruct = _privilegeAccountMap[privilegeAccount];
        if (block.timestamp / 86400 > currentDay) {
            privilegeAccountStruct.dayMoney = privilegeAccountStruct.dayMoneyLimit;
        }
        return privilegeAccountStruct;
    }

    function setPrivilegeAccount(
        address addr,
        uint256 dayMoneyLimit,
        uint256 totalMoney,
        address token20Address
    ) external onlyOwner returns (bool) {
        require(addr != address(0), "The addr cannot be empty");
        _privilegeAccountMap[addr].isState = true;
        _privilegeAccountMap[addr].dayMoney = dayMoneyLimit;
        _privilegeAccountMap[addr].dayMoneyLimit = dayMoneyLimit;
        _privilegeAccountMap[addr].totalMoney = totalMoney;
        _privilegeAccountMap[addr].token20Address = token20Address;
        return true;
    }

    function removePrivilegeAccount(address addr) external onlyOwner() returns (bool){
        require(addr != address(0), "The addr cannot be empty");
        _privilegeAccountMap[addr].isState = false;
        return true;
    }
}


/** 
 *  SourceUnit: /Users/steven/Projects/solidity/Chaindex-Bridge/contracts/BridgeGateway.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import "./IVRC20.sol";
////import "./Privilege.sol";
////import "./SafeVRC20.sol";

contract BridgeGateway is Privilege {
    using SafeVRC20 for IVRC20;

    mapping(string => SendStruct) public sendMap;

    struct SendStruct {
        address fromAddr;
        address toAddr;
        address token20Addr;
        uint256 fromAmount;
    }

    struct CrossChainBehavior {
        SendBehavior sendBehavior;
        ReceiveBehavior receiveBehavior;
    }

    enum SendBehavior{ Transfer, Mint }
    enum ReceiveBehavior{ Receive, Burn }

    mapping(address => bool) private mintTokens;

    mapping(address => bool) private burnTokens;

    event ReceiveEvent(address indexed fromAddr, uint256 amount,address indexed toAddr,address indexed tokenAddress,string chainName);
    event ExtractEvent(address indexed ownerAddr, address indexed token20Addr, uint256 amount);
    event SendEvent(string indexed txId,address indexed fromAddr,
                    address indexed toAddr,address token20Addr,uint256 fromAmount);

    function setMintToken(address token) public onlyOwner returns(bool) {
        mintTokens[token] = true;
        return true;
    }
    
    function setBurnToken(address token) public onlyOwner returns(bool) {
        burnTokens[token] = true;
        return true;
    }

    function setMintAndBurnToken(address token) public onlyOwner returns(bool) {
        mintTokens[token] = true;
        burnTokens[token] = true;
        return true;
    }

    function resetTokenCorssChainBehavior(address token) public onlyOwner returns(bool) {
        mintTokens[token] = false;
        burnTokens[token] = false;
        return true;
    }

    function tokenCrossChainBehavior(address token) public view returns (CrossChainBehavior memory) {
        CrossChainBehavior memory behavior = CrossChainBehavior(SendBehavior.Transfer, ReceiveBehavior.Receive);
        if (mintTokens[token] != false) {
            behavior.sendBehavior = SendBehavior.Mint;
        }

        if (burnTokens[token] != false) {
            behavior.receiveBehavior = ReceiveBehavior.Burn;
        }
        return behavior;
    }

    function receiveNativeToken(address toAddr,string memory chainName) external payable returns(bool){
        emit ReceiveEvent(msg.sender,msg.value,toAddr,address(0),chainName);
        return true;
    }

    function receiveToken20(address toAddr,uint256 amount,address token20Address,string memory chainName) external returns(bool){
        require(token20Address != address(0), "The token20Address cannot be empty");
        uint balanceOld = IVRC20(token20Address).balanceOf(address(this));
        IVRC20(token20Address).safeTransferFrom(msg.sender, address(this), amount);
        uint balanceNew = IVRC20(token20Address).balanceOf(address(this));
        uint realReceiveAmount = balanceNew-balanceOld;
        
        // CrossChainBehavior memory behavior = tokenCrossChainBehavior(token20Address);
        if (burnTokens[token20Address] == true) {
            IVRC20(token20Address).burn(realReceiveAmount);
        }

        emit ReceiveEvent(msg.sender, realReceiveAmount,toAddr,token20Address,chainName);
        return true;
    }

    function extractToken(uint256 amount) external onlyOwner() returns (bool){
        require(
            address(this).balance >= amount,
            "Insufficient BridgeGateway Balance"
        );
        (bool success, ) = payable(super.owner()).call{value:amount}("");
        require(success, "Transfer failed");
        
        emit ExtractEvent(owner(), address(0), amount);
        return true;
    }

    function extractToken20(address token20Addr, uint256 amount)
        external
        onlyOwner() returns (bool)
    {
        require(token20Addr != address(0), "token20Addr cannot be empty");
        require(
            IVRC20(token20Addr).balanceOf(address(this)) >= amount,
            "Insufficient BridgeGateway Balance"
        );
        IVRC20(token20Addr).safeTransfer(owner(), amount);
        emit ExtractEvent(owner(), token20Addr, amount);
        return true;
    }

    function sendToken(
        string memory txId,
        address fromAddr,
        address payable toAddr,
        uint256 fromAmount
    ) external limitMoneyPrivilegeAccount(fromAmount,address(0)) returns (bool){
        require(
            sendMap[txId].fromAddr == address(0),
            "The transaction has been transferred"
        );
        require(toAddr != address(0), "The toAddr cannot be empty");
        require(
            address(this).balance >= fromAmount,
            "Insufficient BridgeGateway Balance"
        );

        sendMap[txId] = SendStruct({
            fromAddr: fromAddr,
            toAddr: toAddr,
            token20Addr: address(0),
            fromAmount: fromAmount
        });

        (bool success, ) = toAddr.call{value:fromAmount}("");
        require(success, "Transfer failed");

        emit SendEvent(txId,fromAddr,toAddr,address(0),fromAmount);
        return true;
    }

    function sendToken20(
        string memory txId,
        address fromAddr,
        address toAddr,
        address token20Addr,
        uint256 fromAmount
    ) external limitMoneyPrivilegeAccount(fromAmount,token20Addr) returns (bool){
        require(sendMap[txId].fromAddr == address(0), "txId duplication");
        require(toAddr != address(0), "The toAddr cannot be empty");
        require(token20Addr != address(0), "The token20Addr cannot be empty");

        // CrossChainBehavior memory behavior = tokenCrossChainBehavior(token20Addr);

        if (mintTokens[token20Addr] == true) {
            IVRC20(token20Addr).mint(fromAmount);
        }

        require(
            IVRC20(token20Addr).balanceOf(address(this)) >= fromAmount,
            "Insufficient BridgeGateway Balance"
        );

        sendMap[txId] = SendStruct({
            fromAddr: fromAddr,
            toAddr: toAddr,
            token20Addr: address(0),
            fromAmount: fromAmount
        });

        IVRC20(token20Addr).safeTransfer(toAddr, fromAmount);

        emit SendEvent(txId,fromAddr,toAddr,token20Addr,fromAmount);
        return true;
    }
}