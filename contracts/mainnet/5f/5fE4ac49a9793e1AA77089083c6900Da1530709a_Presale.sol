/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Presale is Ownable {

    using SafeERC20 for IERC20;

    uint256 public BUSDPerToken = 15;
    uint256 private price_denominator = 100;
    uint256 public totalCollected;
    uint256 public amountOfTokensNeeded;

    struct walletLimit {
        bool validKey;
        uint256 maxWalletAmount;
        bool secondRound;
    }

    struct PresaleWallet {
        bool isWhiteListed;
        uint256 depositAmount;
        uint8 txCount;
        uint256 tokenAmount;
        uint256 tgeCollect;
        uint256 normalCollect;
        uint256 numOfCollectTX;
        uint256 secondRoundDepAmount;
    }

    struct PresalePool {
        uint256 maxClaimTX;
    }

    PresalePool[] public presalePool;

    mapping(uint256 => mapping (string => walletLimit)) private walletLimMap;

    uint256 public hardCap = 200000*10**18;

    uint256 tgeCollect = 12000;
    uint256 seedTGECollect = 10000;
    uint256 normalCollect = 11000;
    uint256 seedNormalCollect = 10000;
    uint256 private denominator = 100000;

    /// @notice ALL TIMES BELOW ARE IN UTC

    /// @dev Presale timings
    uint256 firstRound = 1647525600; // 17MAR22 @ 1400
    uint256 secondRound = 1647612000; // 18MAR22 @ 1400
    uint256 presaleEnd = 1647630000; // 18MAR22 @ 1900

    uint256 ONE_MONTH = 30*24*60*60;

    /// @dev Unlock times
    uint256 tgeTime = 1649430000;
    uint256 firstCollect = 1650294000;
    uint256 secondCollect = 1652886000;
    uint256 thirdCollect = 1655564400;
    uint256 fourthCollect = 1658156400;
    uint256 fifthCollect = 1660834800;
    uint256 sixthCollect = 1663513200;
    uint256 seventhCollect = 1666105200;
    uint256 eighthCollect = 1668783600;

    /// @dev Seed
    uint256 seedFirst = 1650639600;
    uint256 seedSecond = 1653231600;
    uint256 seedThird = 1655910000;
    uint256 seedFourth = 1658502000;
    uint256 seedFifth = 1661180400;
    uint256 seedSixth = 1663858800;
    uint256 seedSeventh = 1666450800;
    uint256 seedEighth = 1669129200;
    uint256 seedNinth = 1671721200;

    IERC20 private _oracula = IERC20(0x85f3ec4EC49aB6a5901278176235957ef521970d);

    mapping(uint256 => mapping(address => PresaleWallet)) public presaleWallet;

    constructor () {
        
        presalePool.push(PresalePool({
            maxClaimTX: 10
        }));

        presalePool.push(PresalePool({
            maxClaimTX: 9
        }));
    }

    function checkIfInSeed(address _address) external view returns (bool) {
        return presaleWallet[0][_address].isWhiteListed;
    }

    function checkIfInPrivate(address _address) external view returns (bool) {
        return presaleWallet[1][_address].isWhiteListed;
    }
    
    function oraculaToken() public view virtual returns (IERC20) {
        return _oracula;
    }


    function checkIfICanClaim(uint256 _pid, address _address) external view returns (bool) {
        (uint256 _withdrawableAmount,) = getWithdrawableAmount(_pid, _address);
        if (_withdrawableAmount > 0) {
            return true;
        } else {
            return false;
        }
    }

    function getCurrectCycle(uint256 _pid) internal view returns (uint256 _currentCycle) {
        if (_pid == 1) {
            if (block.timestamp >= tgeTime) {
                if (block.timestamp >= firstCollect) {
                    if (block.timestamp >= secondCollect) {
                        if (block.timestamp >= thirdCollect) {
                            if (block.timestamp >= fourthCollect) {
                                if (block.timestamp >= fifthCollect) {
                                    if (block.timestamp >= sixthCollect) {
                                        if (block.timestamp >= seventhCollect) {
                                            if (block.timestamp >= eighthCollect) {
                                                return 9;
                                            } else {
                                                return 8;
                                            }
                                        } else {
                                            return 7;
                                        }
                                    } else {
                                        return 6;
                                    }
                                } else {
                                    return 5;
                                }
                            } else {
                                return 4;
                            }
                        } else {
                            return 3;
                        }
                    } else {
                        return 2;
                    }
                } else {
                    return 1;
                } 
            } else {
                return 0;
            }
        } else if (_pid == 0) {
             if (block.timestamp >= tgeTime) {
                if (block.timestamp >= seedFirst) {
                    if (block.timestamp >= seedSecond) {
                        if (block.timestamp >= seedThird) {
                            if (block.timestamp >= seedFourth) {
                                if (block.timestamp >= seedFifth) {
                                    if (block.timestamp >= seedSixth) {
                                        if (block.timestamp >= seedSeventh) {
                                            if (block.timestamp >= seedEighth) {
                                                if (block.timestamp >= seedNinth) {
                                                    return 10;
                                                } else {
                                                    return 9;
                                                }
                                            } else {
                                                return 8;
                                            }
                                        } else {
                                            return 7;
                                        }
                                    } else {
                                        return 6;
                                    }
                                } else {
                                    return 5;
                                }
                            } else {
                                return 4;
                            }
                        } else {
                            return 3;
                        }
                    } else {
                        return 2;
                    }
                } else {
                    return 1;
                } 
            } else {
                return 0;
            }
        }
        
    }

    function getWithdrawableAmount(uint256 _pid, address _address) public view returns (uint256 _withdrawableAmount, uint256 _numOfCollectTX) {
        uint256 numOfCollectTX_ = presaleWallet[_pid][_address].numOfCollectTX;
        uint256 _currentCycle = getCurrectCycle(_pid);
        if (block.timestamp < tgeTime || !presaleWallet[_pid][_address].isWhiteListed || numOfCollectTX_ >= _currentCycle) {
            _withdrawableAmount = 0;
            _numOfCollectTX = numOfCollectTX_;
        } else {
            if (numOfCollectTX_ == 0) {
                _withdrawableAmount = presaleWallet[_pid][_address].tgeCollect + presaleWallet[_pid][_address].normalCollect * 
                    (_currentCycle - numOfCollectTX_ - 1);
                _numOfCollectTX = _currentCycle;
            } else {
                _withdrawableAmount = presaleWallet[_pid][_address].normalCollect * (_currentCycle - numOfCollectTX_);
                _numOfCollectTX = _currentCycle - numOfCollectTX_;
            }
        }
    } 

    function claimTokens(uint256 _pid) public {
        require(block.timestamp >= tgeTime, "Unable to claim yet");
        require(presaleWallet[_pid][_msgSender()].isWhiteListed, "Address not Whitelisted");
        (uint256 _withdrawableAmount, uint256 _numOfCollectTX) = getWithdrawableAmount(_pid, _msgSender());

        presaleWallet[_pid][_msgSender()].numOfCollectTX += _numOfCollectTX;
        oraculaToken().safeTransfer(_msgSender(), _withdrawableAmount);
    }

    function changeAddress(uint256 _pid, address _address, bool _isWhitelisted, uint256 _depositAmount, uint256 _numOfCollectTX) external onlyOwner {
        presaleWallet[_pid][_address].isWhiteListed = _isWhitelisted;
        presaleWallet[_pid][_address].depositAmount = _depositAmount;
        presaleWallet[_pid][_address].tokenAmount = _depositAmount * price_denominator / BUSDPerToken;
        presaleWallet[_pid][_address].tgeCollect = presaleWallet[_pid][_address].tokenAmount * tgeCollect / denominator;
        presaleWallet[_pid][_address].normalCollect = presaleWallet[_pid][_address].tokenAmount * normalCollect / denominator;
        presaleWallet[_pid][_address].numOfCollectTX = _numOfCollectTX;
    }

    function addAddresses(uint256 _pid, address[] calldata _address, uint256[] calldata _depositAmount) external onlyOwner {
        require(_address.length == _depositAmount.length);
        for (uint256 i; i < _address.length; i++) {
            presaleWallet[_pid][_address[i]].isWhiteListed = true;
            presaleWallet[_pid][_address[i]].depositAmount = _depositAmount[i];
            presaleWallet[_pid][_address[i]].tokenAmount = _depositAmount[i] * price_denominator / BUSDPerToken;
            if (_pid == 0) {
                presaleWallet[_pid][_address[i]].tgeCollect = presaleWallet[_pid][_address[i]].tokenAmount * seedTGECollect / denominator;
                presaleWallet[_pid][_address[i]].normalCollect = presaleWallet[_pid][_address[i]].tokenAmount * seedNormalCollect / denominator;
            } else {
                presaleWallet[_pid][_address[i]].tgeCollect = presaleWallet[_pid][_address[i]].tokenAmount * tgeCollect / denominator;
                presaleWallet[_pid][_address[i]].normalCollect = presaleWallet[_pid][_address[i]].tokenAmount * normalCollect / denominator;
            }
            
        }
    }


    function setTokenAddress(IERC20 _token) external onlyOwner {
        _oracula = _token;
    }
    
    function withdrawAnyToken(IERC20 _address) external onlyOwner {
        _address.safeTransfer(msg.sender, _address.balanceOf(address(this)));
    }

    function rescue() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {
    }
}