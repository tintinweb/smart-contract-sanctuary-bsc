// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "../Interfaces/ILiquidityProvider.sol";
import "../Interfaces/IReceipt.sol";
import "../Interfaces/IEvents.sol";
import "../Interfaces/IAdmin.sol";
import "../Interfaces/IWhitelist.sol";
import "../Interfaces/IUSDyBUSDRebalancer.sol";
import "../Interfaces/ITreasury.sol";

/**
@dev BUSD Vault 
Note This contract is for BUSD vault which receives USDy at a reward rate of 0.2% per epoch
 */
 
contract BUSDVault is Initializable,ReentrancyGuard, Pausable, IEvents, AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR"); // Byte for operator role 

    IAdmin public Admin;// Address for Admin contract  
    IUniswapV2Router02 public router; 
    address public BUSDs; // reciept 
    uint256 public epoch; // epoch time
    uint256 public currentReward;
    bool public completePause;

    
    mapping(address => uint) public lastTimeStamp; // timestamp for each user when user called the withdrawl or deposit function
    mapping (address => uint) public UserDeposit; // lp share of each user 
    mapping (address => uint) public restrictTransfer; // last block number when interacted
    mapping (address=>uint256) public ss;
    
    function initialize(address _admin) external initializer {
        Admin = IAdmin(_admin);
        BUSDs = Clones.clone(Admin.masterNTT());
        IReceipt(BUSDs).initialize(_admin, address(this), "BUSDs", "BUSDs");
        IReceipt(BUSDs).setMinter(address(this));
        router = IUniswapV2Router02(Admin.ApeswapRouter());
        epoch = 40 seconds;
    }

    /**
    @dev modifier for operator role
    **/
    
    modifier _isOperator(){
        require(Admin.hasRole(OPERATOR_ROLE, msg.sender));
        _;
    }

    modifier _isAdmin() {
        require(Admin.hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        _;
    }

    modifier _completePause(){
        require(completePause == false,"completely Paused");
        _;
    }

    /**
    @dev used to deposit BUSD in the vault
    @param user address of the user who wants to deposit BUSD in the vault
    @param amount amount of BUSD the user wants to deposit
    @param isBUSD bool value to check user deposits only BUSD
    */

    function deposit(address user, uint amount, bool isBUSD) external nonReentrant _completePause whenNotPaused() {
        require(user != address(0), "BUSDVault: User address can not be empty");
        require(amount > 0, 'BUSDVault: Amount must be greater than zero');
        require(isBUSD, "BUSDVault: Can deposit BUSD only");
        if(UserDeposit[user] > 0){
            _claimRebaseReward(user);
        }else{
            ss[user] = currentReward;
        }
        if(_isContract(msg.sender)){
            require(IWhitelist(Admin.whitelist()).getAddresses(msg.sender),"YSLBUSDVault: No external contract interaction");
        }
        if(!IWhitelist(Admin.whitelist()).getAddresses(user)) {
            require(restrictTransfer[user] != block.number, "YSLBUSDVault: you can't interact in same block");
        }

        IUniswapV2Pair pair = IUniswapV2Pair(IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(Admin.USDy(), Admin.BUSD()));
        uint r1 = IERC20(Admin.USDy()).balanceOf(address(pair));
        uint r2 = IERC20(Admin.BUSD()).balanceOf(address(pair));
        
        if(r1 != r2) { // price of USDy-BUSD pool should be $1.00 else rebalance
            bool success = IUSDyBUSDRebalancer(Admin.USDyBUSDRebalancer()).rebalance(); // to rebalance price before adding liquidity
            require(success, "BUSDVault: Rebalancing failed");
        }
        
        address[] memory path = new address[](2);
        path[0] = Admin.USDy();
        path[1] = Admin.BUSD();
        
        IReceipt(Admin.USDy()).mint(address(this), amount); // mint USDy equal to BUSD user wants to deposit 
        IERC20(Admin.BUSD()).safeTransferFrom(user, address(this), amount); // transfer BUSD to contract for adding liquidity
        if(IERC20(Admin.USDy()).allowance(address(this),address(router)) > 0){
        IReceipt(Admin.USDy()).decreaseAllowance(address(router),IERC20(Admin.USDy()).allowance(address(this),address(router)));
        }
        if(IERC20(Admin.BUSD()).allowance(address(this),address(router)) > 0){
        IReceipt(Admin.BUSD()).decreaseAllowance(address(router),IERC20(Admin.BUSD()).allowance(address(this),address(router)));
        }
        uint lpAmount = _convertBUSDToLP(Admin.USDy(), Admin.BUSD(), amount, amount, address(this)); // add liquidity
        UserDeposit[user] += lpAmount; // update user's lp share after user adds liquidity
        IReceipt(BUSDs).mint(address(this), lpAmount);  // minting reciept token equivalent to LP token amount returned from add liquidity (_convertBUSDToLP) 
        lastTimeStamp[user] = block.timestamp; 
    }

    function setPause(bool _isPaused) external nonReentrant _isAdmin{
        _isPaused == true? _pause() : _unpause();
    }

    function setCompletePause(bool _completePause) external nonReentrant _isAdmin{
        completePause = _completePause;
    }

    function withdraw(address user, uint256 amount, address sendTo) external whenNotPaused(){
        IUniswapV2Pair pair = IUniswapV2Pair(IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(Admin.USDy(), Admin.BUSD()));
        uint r1 = IERC20(Admin.USDy()).balanceOf(address(pair));
        uint r2 = IERC20(Admin.BUSD()).balanceOf(address(pair));
        if(r1 != r2) {
            bool success = IUSDyBUSDRebalancer(Admin.USDyBUSDRebalancer()).rebalance(); // to rebalance price before removing liquidity
            require(success, "BUSDVault: Rebalancing failed");
        }
        _withdraw(user, amount, sendTo);
    }

    function distribute(uint256 _rebaseReward) external nonReentrant{
        require(msg.sender == Admin.USDyVault(),"You cannot interact");
        if(IERC20(BUSDs).totalSupply() != 0){
            currentReward = currentReward + ((_rebaseReward * 10 ** 18)/(IERC20(BUSDs).totalSupply()));
        }
    }

    function emergencyWithdraw() external{
        require(!Admin.buyBackActivation(),"BUSDVault: Can't withdraw");
        require(UserDeposit[msg.sender] != 0,"BUSDVault: Nothing to withdraw");
        _withdraw(msg.sender, UserDeposit[msg.sender], msg.sender);
    }
    /**
    @dev used to withdraw BUSD in the vault
    @param user address of the user who wants to deposit BUSD in the vault
    @param amount amount of BUSD the user wants to withdraw
    @param sendTo address where withdrawn BUSD should be sent
    */

    function _withdraw(address user, uint256 amount, address sendTo) internal nonReentrant _completePause{
        require(user != address(0), "BUSDVault: User address can not be empty");
        require(amount > 0, 'BUSDVault: Amount must be greater than zero');  
        require(UserDeposit[user] >= amount, "BUSDVault: Insufficient receipt tokens");
        require(block.timestamp - lastTimeStamp[user]  >= 4 * epoch, "BUSDVault: You can withdraw after 4 epochs"); // 4 * epoch 
        lastTimeStamp[user] = block.timestamp;
        address lp = address(IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(Admin.USDy(), Admin.BUSD()));
        if(UserDeposit[user] > 0){
            _claimRebaseReward(user);
        }
        if(_isContract(msg.sender)){
            require(IWhitelist(Admin.whitelist()).getAddresses(msg.sender),"YSLBUSDVault: No external contract interaction");
        }
        if(!IWhitelist(Admin.whitelist()).getAddresses(user)) {
            require(restrictTransfer[user] != block.number, "YSLBUSDVault: you can't interact in same block");
        }
        
        IERC20(lp).safeApprove(Admin.liquidityProvider(), amount);
        ILiquidityProvider(Admin.liquidityProvider()).removeLiquidity(lp, amount); // remove liquidity to get USDy and BUSD
        uint amountUSDy = IERC20(Admin.USDy()).balanceOf(address(this));
        uint amountBUSD = IERC20(Admin.BUSD()).balanceOf(address(this));
        UserDeposit[user] -= amount; // reduce user's lp share 
        IReceipt(Admin.USDy()).burn(address(this), amountUSDy); // burn USDy received after removing liquidity
        IERC20(Admin.BUSD()).safeTransfer(sendTo, amountBUSD); // transfer BUSD to the user
        IReceipt(BUSDs).burn(address(this), amount); // burn receipt tokens
    }

    /**
    @dev Function for Pause by an Operator
    **/
     function pause() external nonReentrant _isOperator{
        _pause();
    }

    /**
    @dev Function for UnPause by an Operator
    **/
    function unpause() external nonReentrant _isOperator{
        _unpause();
    }

    /**
    @dev add liquidity to pool
    @param tokenA address of token A
    @param tokenB address of token B
    @param amountA amount of token A to be added as liquidity
    @param amountB amount of token B to be added as liquidity
    @param sendTo address of user who will receive lp tokens
    */

    function _convertBUSDToLP(address tokenA, address tokenB, uint amountA, uint amountB, address sendTo) internal returns(uint lpAmount) {
        IERC20(tokenA).safeApprove(Admin.ApeswapRouter(), amountA);
        IERC20(tokenB).safeApprove(Admin.ApeswapRouter(), amountB);
        (,,lpAmount) = IUniswapV2Router02(router).addLiquidity(
            tokenA,
            tokenB,
            amountA,
            amountB,
            1,
            1,
            sendTo,
            block.timestamp + 1678948210);
        return lpAmount;
    }

    /**
    @dev The user will get his rewards through this function 
    @param user, address of user 
    */
    function rewards(address user) public view returns (uint reward){
       reward = ((UserDeposit[user] * (currentReward - ss[user])) / 10 ** 18);
         if(Admin.PhoenixNFT() != address(0) && IReceipt(Admin.PhoenixNFT()).balanceOf(user) >= 1){
            reward = (reward + (reward / 4));
         }
    }

    /**
    @dev Function that returns the address of BUSD
    **/

    function receiptToken() public view returns(address) {
        return BUSDs;
    }


    function claimRebaseReward(address user) public nonReentrant whenNotPaused {
        if(_isContract(msg.sender)){
            require(IWhitelist(Admin.whitelist()).getAddresses(msg.sender),"YSLBUSDVault: No external contract interaction");
        }
        if(!IWhitelist(Admin.whitelist()).getAddresses(user)) {
            require(restrictTransfer[user] != block.number, "YSLBUSDVault: you can't interact in same block");
        }
        _claimRebaseReward(user);
    }

    function _claimRebaseReward(address user) internal  {
        uint reward = ((UserDeposit[user] * (currentReward - ss[user])) / 10 ** 18);
        if(msg.sender != address(this)){
        require(reward > 0,"BUSDVault: Please claim after rebase");
        }
        if(Admin.PhoenixNFT() != address(0) && IReceipt(Admin.PhoenixNFT()).balanceOf(user) >= 1){
            IERC20(Admin.USDy()).safeTransfer(user, reward + (reward/ 4));
        }else{
            IERC20(Admin.USDy()).safeTransfer(user, reward);
        }
        ss[user] = currentReward;
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ILiquidityProvider {
    function initialize( 
    address _router, 
    address _Admin
    ) external;
    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB, uint256 amountAmin, uint256 amountBmin, address to) external;
    function addLiquidityEth(address token, uint amount, address to) external payable;
    function removeLiquidity(address lp, uint amount) external returns(uint amountA, uint amountB);
    function removeLiquidityEth(address token, uint amount) external;
    function depositBUSDToLP(address user,uint amount,address lp) external  returns(uint);
    function lpDollarValue(address lp,address tokenA, address tokenB) external view returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IReceipt {
    function mint(address account, uint amount) external;
    function burn(address account, uint amount) external;
    function setMinter(address _operator) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function mintByPrice() external  returns(uint);
    function initialize(address _admin, address operator, string memory name_, string memory symbol_) external;
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) ;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IEvents{
    event Deposit(string Vault,address receiver,address user,uint amount, uint blocknumber,uint blockTimestamp);
    event Withdraw(string Vault,address receiver,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event PurchaseORSell(string Vault,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event OptDeposit(string Vault,address receiver,address user,uint amount,uint32 level,uint blocknumber,uint blockTimestamp);
    event Optwithdraw(string Vault,address receiver,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event OptAdd(address token, bool isLptoken, bool isAuto, address smartchef,address strat,address instance,uint blocknumber,uint blockTimestamp);
    event OptAddCustomVaults(address token,address vault,uint blocknumber,uint blockTimestamp);
    event CalculateAPR(address vault, uint value,uint blocknumber,uint blockTimestamp);
    event BUSDcollected(uint busdCollected,uint blocknumber,uint blockTimestamp);
    event ControllerFee(address vault,uint amount,uint blocknumber,uint blockTimestamp);
    event OptimizationRewards(address optvault, address user, uint reward,uint blocknumber,uint blockTimestamp);
    event LottoDeposit(string Vault,address user, uint amount,uint blocknumber,uint blockTimestamp);
    event SetterForUint(string contractName,address contractAddress,uint previousValue, uint currentValue,uint blocknumber,uint blockTimestamp);
    event SetterForAddress(string contractName,address contractAddress,address previousAddress, address currentAddress,uint blocknumber,uint blockTimestamp);
    event SetterForReferrer(address user,address RefferAddress,uint blocknumber,uint blockTimestamp);
    event TaxAllocation(string contractName,address contractAddress,uint previousTax,uint currentTax, uint[] perviousAllocationTax,uint[] currentAllocationTax,uint blocknumber,uint blockTimestamp);
    event SetterForMultiplierLevel(string contractName,address contractAddress,uint level,uint multiplierLevel,uint amount, uint blocknumber,uint blockTimestamp);
    event OptMultiplier(string contractName, uint pid, uint32[] number,uint blocknumber,uint blockTimestamp);
    event OptMultiplierLevel(string contractName, address token, uint32[] multiplier,uint32[] deductionValue,uint blocknumber,uint blockTimestamp);
    event SetterForOptimizationTaxFee(string contractName,address contractAddress,uint[3] previousArray,uint[3] currentArray,uint blocknumber,uint blockTimestamp);
    event BiddingNFT(string contractName,address user, uint amount,uint totalAmount,uint blocknumber,uint blockTimestamp);
    event ClaimBID(string contractName, address user, uint wonAddress, uint totalAmount,uint blocknumber,uint blockTimestamp);
    event EndAuction(string contractName, bool rank, address TopofAuction,uint tokenId,uint blocknumber,uint blockTimestamp);
    event ResetNewAuction(string contractName, uint highestbid, address winnerofTokenID,uint biddingArray,uint blocknumber,uint blockTimestamp);
    event Buy(string contractName, uint counter,uint lockPeriod,uint blocknumber,uint blockTimestamp);
    event ReactivateNFT(string contractName, address user,uint userTokenID,uint blocknumber,uint blockTimestamp);
    event RewardDistribute(string contractName,address user, uint reward,uint TotalRewardPercentage,address UserReferrer, uint Leftamount,uint blocknumber,uint blockTimestamp);
    event RewardPercentage(string contractName, address user, uint128[3] amount,uint blocknumber,uint blockTimestamp);
    event Reward_Earning(address user, address beneficiary, uint amount, uint level,uint volume,uint blocknumber,uint blockTimestamp);
    event ReferralEarned(address user,uint blocknumber,uint blockTimestamp);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/IAccessControl.sol";
interface IAdmin is IAccessControl{
    function lpDeposit() external view returns(bool);
    function admin() external view returns(address);
    function operator() external view returns(address);
    function Trigger() external view returns(address);
    function POL() external  view returns(address);
    function Treasury() external view returns(address);
    function BShareBUSDVault() external view returns(address);
    function bYSLVault() external view returns(address);
    function USDyBUSDVault() external view returns(address);
    function USDyVault() external view returns(address);
    function xYSLBUSDVault() external view returns(address);
    function xYSLVault() external view returns(address);
    function xBUSDVault() external view returns(address);
    function YSLBUSDVault() external view returns(address);
    function YSLVault() external view returns(address);
    function BShare() external view returns(address);
    function bYSL() external view returns(address);
    function USDs() external view returns(address);
    function USDy() external view returns(address);
    function YSL() external view returns(address);
    function xYSL() external view returns(address); 
    function USDyBUSD() external view returns(address);
    function xBUSD() external view returns(address);
    function xYSLS() external view returns(address);
    function YSLS() external view returns(address);
    function swapPage() external view returns(address);
    function PhoenixNFT() external view returns(address);
    function Opt1155() external view returns(address);
    function EarlyAccess() external view returns(address);
    function helperSwap() external view returns(address);
    function optVaultFactory() external view returns(address);
    function swap() external view returns(address);
    function temporaryHolding() external view returns(address);
    function whitelist() external view returns(address);
    function Blacklist() external view returns(address);
    function BUSD() external view returns(address);
    function WBNB() external view returns(address);
    function BShareVault() external view returns(address);
    function masterNTT() external view returns (address);
    function biswapRouter() external view returns (address);
    function ApeswapRouter() external view returns (address);
    function pancakeRouter() external view returns (address);
    function TeamAddress() external view returns (address);
    function MasterChef() external view returns (address);
    function Refferal() external view returns (address);
    function liquidityProvider() external view returns(address);
    function temporaryReferral() external view returns(address);
    function initialize(address owner) external;
    function setLpDeposit(bool deposit) external;
    function setRefferal(address _refferal)  external;
    function setWBNB(address _WBNB) external;
    function setBUSD(address _BUSD) external;
    function setLiquidityProvider(address _liquidityProvider) external;
    function setWhitelist(address _whitelist) external;
    function setBlacklist(address _blacklist) external;
    function sethelperSwap(address _helperSwap) external;
    function setTemporaryHolding(address _temporaryHolding) external;
    function setSwap(address _swap) external;
    function setOptVaultFactory(address _optVaultFactory) external;
    function setEarlyAccess(address _EarlyAccess) external;
    function setOpt1155(address _Opt1155) external;
    function setPhoenixNFT(address _PhoenixNFT) external;
    function setSwapPage(address _swapPage) external;
    function setYSL(address _YSL) external;
    function setYSLS(address _YSLS) external;
    function setxYSLs(address _xYSLS) external;
    function setxYSL(address _xYSL) external;
    function setxBUSD(address _xBUSD) external;
    function setUSDy(address _USDy) external;
    function setUSDs(address _USDs) external;
    function setbYSL(address _bYSL) external;
    function setBShare(address _BShare) external;
    function setYSLVault(address _YSLVault) external;
    function setYSLBUSDVault(address _YSLBUSDVault) external;
    function setxYSLVault(address _xYSLVault) external;
    function setxBUSDVault(address _xBUSDVault) external;
    function setxYSLBUSDVault(address _xYSLBUSDVault) external;
    function setUSDyVault(address _USDyVault) external;
    function setUSDyBUSDVault(address _USDyBUSDVault) external;
    function setbYSLVault(address _bYSLVault) external;
    function setBShareBUSD(address _BShareBUSD) external;
    function setPOL(address setPOL) external;
    function setBShareVault(address _BShareVault) external;
    function setTrigger(address _Trigger) external;
    function setmasterNTT(address _masterntt) external;
    function setbiswapRouter(address _biswapRouter)external;
    function setApeswapRouter(address _ApeswapRouter)external;
    function setpancakeRouter(address _pancakeRouter)external;
    function setTeamAddress(address _TeamAddress)external;
    function setMasterChef(address _MasterChef)external;
    function setTemporaryReferral(address _temporaryReferral)external;
    function USDyBUSDRebalancer()external returns(address);
    function BSHAREBUSDRebalancer()external returns(address);
    function BUSDVault()external returns(address);
    function setUSDyBUSDRebalancer(address _USDyBUSDRebalancer)external;
    function setBSHAREBUSDRebalancer(address _BSHAREBUSDRebalancer)external;
    function setBUSDVault(address _BUSDVault)external;
    function setBuyBackActivation(bool _value) external;
    function buyBackActivation() external view returns(bool);
    function buyBackActivationEpoch() external view returns(uint);
    function epochDuration() external view returns(uint);
    function lastEpoch() external view returns(uint);
    function setLastEpoch() external;
    function setEpochDuration(uint _time) external;
    function setUSDyBUSD(address _usdyBusd) external;
    function setBuyBackActivationEpoch() external;
    function vaultsAddresses() external view returns(address[] memory);
    function customVaultMaster() external view returns(address);
    function buyBackOwnerActivation() external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IWhitelist {
    function getAddresses(address _protocol) external view returns(bool);
    function getAddressesOfSwap(address _protocol) external view returns(bool);

    // function getUserAddresses(address _user) external view returns(bool);
    function addWhiteList(address[] calldata _protocol) external;
    function addWhiteListForSwap(address[] calldata _protocol) external;

    // function addUserWhiteList(address[] calldata _user) external;
    function revokeWhiteList(address[] calldata _protocol) external;
    function revokeWhiteListOfSwap(address[] calldata _protocol) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../Interfaces/ILiquidityProvider.sol";

interface IUSDyBUSDRebalancer {
    function lastTimeStamp() external;
    function epoch() external;
    function currentTimestamp() external;
    function isEnabled() external;
    function impactPercentageLimit() external;
    function Admin() external;
    function router() external;
    function factory() external;
    function pair() external;
    function lProvider() external;
    function lp() external;
    function initialize(address _admin, IUniswapV2Router02 _router, ILiquidityProvider _lProvider) external;
    function rebalance() external returns(bool);
    function sqrt(uint x) external pure returns (uint y);
    function rebalancerState() external returns(bool);
    function setImpactPercentageLimit(uint _impactPercentageLimit) external;
    function setMode(uint _mode) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ITreasury {
    function owner() external;
    function Admin() external;
    function initialize(address _owner,address _admin) external;
    function withdraw(uint256 _amount) external;
    function emergencyWithdraw() external;
    function removeLiquidity(address _lpToken,address _router) external;
    function swapLiquidity(address _lpToken, address _prevRouter, address _newRouter) external;
    function setRebalancerRole(address _rebalancer) external;
    function getLpFromTreasury(address _contractAddress, address _lpToken, uint _amount) external;   
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}