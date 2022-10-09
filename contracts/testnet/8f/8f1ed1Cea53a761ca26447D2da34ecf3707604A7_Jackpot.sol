//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../contracts/interfaces/IHashGame.sol";

contract Jackpot is Initializable, ReentrancyGuardUpgradeable {
    IERC20 public LVGC;
    I_HashGame public IHashGame;

    struct UserInfo {
        uint256 gameMode;
        bool jpActive;      
        bool gjpActive;
        uint256 jpPurchaseTimestamp;
        uint256 jpClaimTimestamp;
        uint256 gjpClaimTimestamp;
        bool wonJackpot;
        bool wonGrandJackpot;
    }

    mapping (address => UserInfo) public userInfo;
    mapping (address => bool) private operator;

    uint256 public DENOM;
    uint256[] public jackpotAllocation;
    uint256[] public grandJackpotAllocation;

    bool private inDistribution;
    uint256 private jackpotFee; 
    uint256 private grandJackpotFee; 
    uint256 private cooldownInterval;

    modifier onlyOperator {
        require(isOperator(msg.sender), "Only operator can perform this action");
        _;
    }

    function initialize(address _lvgc, uint256 _jackpotFee, uint256 _grandJackpotFee, uint256 _DENOM, uint256 _cooldownInterval) public initializer {
        LVGC = IERC20(_lvgc);
        jackpotFee = _jackpotFee;
        grandJackpotFee = _grandJackpotFee;

        DENOM = _DENOM;
        cooldownInterval = _cooldownInterval;
        
        operator[msg.sender] = true;
        __ReentrancyGuard_init();
    }

    function purchaseJackpot(uint256 _gid, address _userAddress) external onlyOperator {
        UserInfo storage _userInfo = userInfo[_userAddress];

        require(_gid != 0, "Invalid game ID");
        require(!wonJackpot(_userAddress), "Please claim jackpot first");
        require(!wonGrandJackpot(_userAddress), "Please claim grand jackpot first");
        require(!isValidJackpot(_userAddress), "Valid jackpot found, cannot purchase again");
        require(_userInfo.jpPurchaseTimestamp + cooldownInterval <= block.timestamp, "Jackpot is in cooldown");
        require(LVGC.balanceOf(_userAddress) >= jackpotFee, "Insufficient LVGC");

        // Check allowance
        uint256 _allowance = LVGC.allowance(_userAddress, address(this));
        require(_allowance >= jackpotFee, "Insufficient allowance");

        bool _status = LVGC.transferFrom(_userAddress, address(this), jackpotFee);
        require(_status, "Faled to transfer fund");

        _userInfo.gameMode = _gid;
        _userInfo.jpActive = true;
        _userInfo.gjpActive = false;
        _userInfo.jpPurchaseTimestamp = block.timestamp;

        emit PurchaseJackpot(_gid, _userAddress, jackpotFee);
    }

    function purchaseGrandJackpot() external {
        UserInfo storage _userInfo = userInfo[msg.sender];

        require(_userInfo.gameMode != 0, "Invalid game ID");
        require(isValidJackpot(msg.sender), "No valid jackpot found");
        require(!isValidGrandJackpot(msg.sender), "Valid grand jackpot found, cannot purchase again");

        // Check user current Lvgr game status
        bool _gameActive = IHashGame.isUserLvgrGameActive(msg.sender);
        require(!_gameActive, "Cannot purchase grand jackpot after game started");

        // Check user consecutive burst count 
        uint256 _burstCount = IHashGame.getUserLvgrBurstCount(msg.sender);
        require(_burstCount == 1, "Consecutive burst count must be 1");

        // Check allowance
        uint256 _allowance = LVGC.allowance(msg.sender, address(this));
        require(_allowance >= grandJackpotFee, "Insufficient allowance");

        require(LVGC.balanceOf(msg.sender) >= grandJackpotFee, "Insufficient LVGC");
        bool _status = LVGC.transferFrom(msg.sender, address(this), grandJackpotFee);
        require(_status, "Faled to transfer fund");

        _userInfo.gjpActive = true;

        emit PurchaseGrandJackpot(_userInfo.gameMode, msg.sender, grandJackpotFee);
    }

    function claimJackpot() external nonReentrant {
        UserInfo storage _userInfo = userInfo[msg.sender];

        require(!wonGrandJackpot(msg.sender), "Grand jackpot rewards found");
        require(_userInfo.wonJackpot, "No jackpot rewards found");

        uint256 _rewardAmount = getCurrentJackpotReward(_userInfo.gameMode);
        require(LVGC.balanceOf(address(this)) >= _rewardAmount, "Insufficient LVGC in contract");

        // Reset all jackpot after claim
        resetJackpot(msg.sender);

        _userInfo.jpClaimTimestamp = block.timestamp;

        // Transfer rewards to user
        LVGC.transfer(msg.sender, _rewardAmount);

        emit ClaimJackpot(_userInfo.gameMode, msg.sender, _rewardAmount);
    }

    function claimGrandJackpot() external nonReentrant {
        UserInfo storage _userInfo = userInfo[msg.sender];

        require(wonGrandJackpot(msg.sender), "No grand jackpot rewards found");

        uint256 _rewardAmount = getCurrentGrandJackpotReward(_userInfo.gameMode);
        require(LVGC.balanceOf(address(this)) >= _rewardAmount, "Insufficient LVGC in contract");

        // Reset all jackpot after claim
        resetJackpot(msg.sender);

        _userInfo.gjpClaimTimestamp = block.timestamp;

        // Transfer rewards to user
        LVGC.transfer(msg.sender, _rewardAmount);

        emit ClaimGrandJackpot(_userInfo.gameMode, msg.sender, _rewardAmount);
    }

    function resetJackpot(address _userAddress) internal {
        UserInfo storage _userInfo = userInfo[_userAddress];

        _userInfo.jpActive = false;
        _userInfo.gjpActive = false;
        _userInfo.wonJackpot = false;
        _userInfo.wonGrandJackpot = false;

        // Reset user consecutive burst count
        IHashGame.resetUserLvgrBurstCount(_userAddress);

        emit ResetJackpot(_userAddress);
    }

    function voidJackpot(address _userAddress) external onlyOperator {
        UserInfo storage _userInfo = userInfo[_userAddress];
        _userInfo.jpActive = false;
        _userInfo.gjpActive = false;

        emit VoidJackpot(_userAddress);
    }

    function rescueToken(address _token, address _to, uint256 _amount) external onlyOperator {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        require(_amount <= _contractBalance, "Insufficient token");

        IERC20(_token).transfer(_to, _amount);

        emit RescueToken(_token, _to, _amount);
    }

    // ===================================================================
    // GETTERS
    // ===================================================================
    
    function isOperator(address _userAddress) public view returns(bool) {
        return operator[_userAddress];
    }

    function isValidJackpot(address _userAddress) public view returns(bool) {
        if(userInfo[_userAddress].jpActive && userInfo[_userAddress].jpPurchaseTimestamp + cooldownInterval > block.timestamp) {
            return true;
        } 
        return false;
    }

    function isValidGrandJackpot(address _userAddress) public view returns(bool) {
        if(userInfo[_userAddress].gjpActive && userInfo[_userAddress].jpPurchaseTimestamp + cooldownInterval > block.timestamp) {
            return true;
        } 
        return false;
    }
    
    function wonJackpot(address _userAddress) public view returns(bool) {
        return userInfo[_userAddress].wonJackpot;
    }

    function wonGrandJackpot(address _userAddress) public view returns(bool) {
        return userInfo[_userAddress].wonGrandJackpot;
    }

    function getUserInfo(address _userAddress) external view returns(UserInfo memory) {
        return userInfo[_userAddress];
    }

    function getCurrentJackpotReward(uint256 _gid) public view returns(uint256) {
        uint256 _contractBalance = LVGC.balanceOf(address(this));
        if(_contractBalance == 0) return 0;

        uint256 rewardAmount = _contractBalance * jackpotAllocation[_gid] / DENOM;
        return rewardAmount;
    }

    function getCurrentGrandJackpotReward(uint256 _gid) public view returns(uint256) {
        uint256 _contractBalance = LVGC.balanceOf(address(this));
        if(_contractBalance == 0) return 0;

        uint256 rewardAmount = _contractBalance * grandJackpotAllocation[_gid] / DENOM;
        return rewardAmount;
    }

    function getPurchaseGrandJackpotFlag(address _userAddress) external view returns(bool) {
        bool _gameActive = IHashGame.isUserLvgrGameActive(_userAddress);
        uint256 _burstCount = IHashGame.getUserLvgrBurstCount(_userAddress);

        if(isValidJackpot(_userAddress) && !isValidGrandJackpot(_userAddress) && !_gameActive && _burstCount == 1)
            return true;
        else
            return false;
    } 

    function getJackpotFee() external view returns(uint256) {
        return jackpotFee;
    }

    function getGrandJackpotFee() external view returns(uint256) {
        return grandJackpotFee;
    }

    function getCooldownInterval() external view returns(uint256) {
        return cooldownInterval;
    }

    // ===================================================================
    // SETTERS
    // ===================================================================
    function setWonJackpot(address _userAddress) external onlyOperator {
        require(_userAddress != address(0), "Address zero");
        UserInfo storage _userInfo = userInfo[_userAddress];
        _userInfo.wonJackpot = true;

        emit SetWonJackpot(_userAddress);
    }

    function setWonGrandJackpot(address _userAddress) external onlyOperator {
        require(_userAddress != address(0), "Address zero");
        UserInfo storage _userInfo = userInfo[_userAddress];
        _userInfo.wonGrandJackpot = true;

        emit SetWonGrandJackpot(_userAddress);
    }

    function setOperator(address _userAddress, bool _bool) external onlyOperator {
        require(_userAddress != address(0), "Address zero");
        operator[_userAddress] = _bool;

        emit SetOperator(_userAddress, _bool);
    }

    function setFee(uint256 _jackpotFee, uint256 _grandJackpotFee) external onlyOperator {
        require(_jackpotFee != 0, "jackpotFee value zero");
        require(_grandJackpotFee != 0, "grandJackpotFee value zero");

        jackpotFee = _jackpotFee;
        grandJackpotFee = _grandJackpotFee;

        emit SetFee(_jackpotFee, _grandJackpotFee);
    }

    function setJackpotAllocation(uint256[] memory _allocation) external onlyOperator {
        require(_allocation.length != 0, "array empty");
        jackpotAllocation = _allocation;

        emit SetJackpotAllocation(_allocation);
    }

    function setGrandJackpotAllocation(uint256[] memory _allocation) external onlyOperator {
        require(_allocation.length != 0, "array empty");
        jackpotAllocation = _allocation;

        emit SetGrandJackpotAllocation(_allocation);
    }

    function setHashgameAddress(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        IHashGame = I_HashGame(_newAddress);
        operator[_newAddress] = true;

        emit SetHashGameAddress(_newAddress);
    }

    function setLvgcAddress(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        LVGC = IERC20(_newAddress);

        emit SetLvgcAddress(_newAddress);
    }

    function setCooldownInterval(uint256 _cooldownInterval) external onlyOperator {
        cooldownInterval = _cooldownInterval;

        emit SetCooldownInterval(_cooldownInterval);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================

    event PurchaseJackpot(uint256 gid, address userAddress, uint256 jackpotFee);
    event PurchaseGrandJackpot(uint256 gid, address userAddress, uint256 grandJackpotFee);
    event ClaimJackpot(uint256 gid, address userAddress, uint256 rewards);
    event ClaimGrandJackpot(uint256 gid, address userAddress, uint256 rewards);

    event ResetJackpot(address userAddress);
    event VoidJackpot(address userAddress);
    event RescueToken(address token, address to, uint256 amount);

    event SetWonJackpot(address userAddress);
    event SetWonGrandJackpot(address userAddress);
    event SetOperator(address userAddress, bool boolValue);
    event SetFee(uint256 jackpotFee, uint256 grandJackpotFee);
    event SetJackpotAllocation(uint256[] allocation);
    event SetGrandJackpotAllocation(uint256[] allocation);
    event SetHashGameAddress(address newAddress);
    event SetLvgcAddress(address newAddress);
    event SetCooldownInterval(uint256 cooldownInterval);
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface I_HashGame {
    function resetUserLvgrBurstCount(address) external;
    function getUserLvgrBurstCount(address) external view returns(uint256); 
    function isUserLvgrGameActive(address _userAddress) external view returns(bool);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

abstract contract Initializable {

    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}