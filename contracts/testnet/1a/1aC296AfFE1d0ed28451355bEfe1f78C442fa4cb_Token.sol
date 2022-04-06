// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IPancakePair.sol";

contract Token is ERC20, AccessControl, ReentrancyGuard, Pausable {
    /** CONSTANTS **/

    bytes32 public constant DAO = keccak256("DAO");
    bytes32 public constant BRIDGE = keccak256("Bridge");

    /** SEMI-CONSTANTS **/

    IUniswapV2Router02 public pancakeRouter;

    address public dao;
    uint256 public initialSupply = 1_000_000e18;
    address public pancakeBucksBnbPair;
    address payable private feeSafe; // The safe that stores the BNB made from the fees
    uint256 public minimumSafeFeeBalanceToSwap = 100e18; // BUCKS balance required to perform a swap
    uint256 public minimumLiquidityFeeBalanceToSwap = 100e18; // BUCKS balance required to add liquidity
    uint256 public minimumBNBRewardsBalanceToSwap = 100e18; // BUCKS balance required to add liquidity
    bool public swapEnabled = true;

    // Buying and selling fees
    uint256 public buyingFee = 0; // (/1000)
    uint256 public sellingFeeClaimed = 0; // (/1000)
    uint256 public sellingFeeNonClaimed = 500; // (/1000)

    // Buying/Selling Fees Repartition
    uint256 public safeFeePercentage = 900; // Part (/1000) of the fees that will be sent to the safe fee.
    uint256 public liquidityFeePercentage = 100; // (/1000)
    // Not needed because safeFeePercentage + liquidityFeePercentage + BNBRewardsFeePercentage = 1000
    //uint256 public BNBRewardsFeePercentage = 100;

    /** VARIABLES **/
    mapping(address => bool) private _blacklist;
    mapping(address => bool) private _exemptFromFees;
    mapping(address => uint256) public claimedTokens;
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 public safeFeeBalance = 0; // BUCKS balance accumulated from fee safe fees
    uint256 public liquidityFeeBalance = 0; // BUCKS balance accumulated from liquidity fees
    uint256 public BNBRewardsFeeBalance = 0; // BUCKS balance accumulated from liquidity fees

    // Swapping booleans. Here to avoid having two swaps in the same block
    bool private swapping = false;
    bool private swapLiquify = false;
    bool private swapBNBRewards = false;

    /** EVENTS **/

    event SwappedSafeFeeBalance(uint256 amount);
    event AddedLiquidity(uint256 bucksAmount, uint256 bnbAmount);

    /** CONSTRUCTOR **/

    constructor(address _pancakeRouter, address payable _feeSafe)
        ERC20("TNT", "TNT")
    {
        // TODO
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(DAO, msg.sender);

        feeSafe = _feeSafe;
        _mint(msg.sender, initialSupply);
        pancakeRouter = IUniswapV2Router02(_pancakeRouter);
        pancakeBucksBnbPair = IUniswapV2Factory(pancakeRouter.factory())
            .createPair(address(this), pancakeRouter.WETH());

        // Exempt some addresses from fees
        _exemptFromFees[msg.sender] = true;
        _exemptFromFees[address(this)] = true;
        _exemptFromFees[address(0)] = true;

        _setAutomatedMarketMakerPair(address(pancakeBucksBnbPair), true);
    }

    /** MAIN METHODS **/

    receive() external payable {}

    // Transfers claimed tokens from an address to another, allowing the recipient to sell without exposing themselves to high fees
    function transferClaimedTokens(address _recipient, uint256 _amount)
        external
        nonReentrant
    {
        // Safety checks
        _beforeTokenTransfer(msg.sender, _recipient, _amount);
        require(
            claimedTokens[msg.sender] >= _amount,
            "Not enough claimed tokens to send"
        );
        require(
            !automatedMarketMakerPairs[_recipient],
            "Cannot transfer claimed tokens to an AMM pair"
        );

        // Transfer the claimed tokens
        claimedTokens[msg.sender] -= _amount;
        claimedTokens[_recipient] += _amount;
        _transfer(msg.sender, _recipient, _amount);
    }

    /** INTERNAL METHODS **/

    // Overrides ERC20 to implement the blacklist
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override(ERC20) {
        require(
            !_isBlacklisted(_from),
            "You do not have enough BUCKS to sell/send them."
        );
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    // Transfers BUCKS from _from to _to, collects relevant fees, and performs a swap if needed
    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {
        require(_from != address(0), "Cannot transfer from the zero address");
        require(_amount > 0, "Cannot transfer 0 tokens");
        uint256 fees = 0;

        // Only take fees on buys / sells, do not take on wallet transfers
        if (!_exemptFromFees[_from] && !_exemptFromFees[_to]) {
            // On sell
            if (automatedMarketMakerPairs[_to]) {
                // Calculate fees, distinguishing between claimed tokens and non-claimed tokens
                uint256 claimedTokensToSell = (_amount <= claimedTokens[_from])
                    ? _amount
                    : claimedTokens[_from];
                uint256 nonClaimedTokensToSell = _amount - claimedTokensToSell;

                if (sellingFeeClaimed > 0)
                    fees += (claimedTokensToSell * sellingFeeClaimed) / 1000;
                if (sellingFeeNonClaimed > 0)
                    fees +=
                        (nonClaimedTokensToSell * sellingFeeNonClaimed) /
                        1000;

                // Update the value of "claimedTokens" for this account
                claimedTokens[_from] -= claimedTokensToSell;
            }
            // On buy
            else if (automatedMarketMakerPairs[_from] && buyingFee > 0) {
                fees = (_amount * buyingFee) / 1000;
            }

            // Send fees to the BUCKS contract
            if (fees > 0) {
                // Send the BUCKS tokens to the contract
                super._transfer(_from, address(this), fees);

                // Keep track of the BUCKS tokens that were sent
                uint256 safeFees = (fees * safeFeePercentage) / 1000;
                safeFeeBalance += safeFees;

                uint256 liquidityFees = (fees * liquidityFeePercentage) / 1000;
                liquidityFeeBalance += liquidityFees;

                BNBRewardsFeeBalance += fees - safeFees - liquidityFees;
            }

            _amount -= fees;
        }

        // Swapping logic
        if (swapEnabled) {
            // If the one of the fee balances is above a certain amount, swap it for BNB and transfer it to the fee safe
            // Do not do both in one transaction
            if (
                !swapping &&
                !swapLiquify &&
                !swapBNBRewards &&
                safeFeeBalance > minimumSafeFeeBalanceToSwap
            ) {
                // Forbid swapping safe fees
                swapping = true;

                // Perform the swap
                _swapSafeFeeBalance();

                // Allow swapping again
                swapping = false;
            }

            if (
                !swapping &&
                !swapLiquify &&
                !swapBNBRewards &&
                liquidityFeeBalance > minimumLiquidityFeeBalanceToSwap
            ) {
                // Forbid swapping liquidity fees
                swapLiquify = true;

                // Perform the swap
                _liquify();

                // Allow swapping again
                swapLiquify = false;
            }

            if (
                !swapping &&
                !swapLiquify &&
                !swapBNBRewards &&
                BNBRewardsFeeBalance > minimumBNBRewardsBalanceToSwap
            ) {
                // Forbid swapping
                swapBNBRewards = true;

                // Perform the swap
                _swapBucksForBnb(BNBRewardsFeeBalance);

                // Update BNBRewardsFeeBalance
                BNBRewardsFeeBalance = 0;

                // Allow swapping again
                swapBNBRewards = false;
            }
        }
        super._transfer(_from, _to, _amount);
    }

    // Swaps safe fee balance for BNB and sends it to the fee safe
    function _swapSafeFeeBalance() internal {
        require(
            safeFeeBalance > minimumSafeFeeBalanceToSwap,
            "Not enough BUCKS tokens to swap for safe fee"
        );

        uint256 oldBalance = address(this).balance;

        // Swap
        _swapBucksForBnb(safeFeeBalance);

        // Update safeFeeBalance
        safeFeeBalance = 0;

        // Send BNB to fee safe
        uint256 toSend = address(this).balance - oldBalance;
        feeSafe.transfer(toSend);

        emit SwappedSafeFeeBalance(toSend);
    }

    // Swaps "_bucksAmount" BUCKS for BNB
    function _swapBucksForBnb(uint256 _bucksAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        _approve(address(this), address(pancakeRouter), _bucksAmount);

        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _bucksAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    // Swaps liquidity fee balance for BNB and adds it to the BUCKS / BNB pool
    function _liquify() internal {
        require(
            liquidityFeeBalance > minimumLiquidityFeeBalanceToSwap,
            "Not enough BUCKS tokens to swap for adding liquidity"
        );

        uint256 oldBalance = address(this).balance;

        // Sell half of the BUCKS for BNB
        uint256 lowerHalf = liquidityFeeBalance / 2;
        uint256 upperHalf = liquidityFeeBalance - lowerHalf;

        // Swap
        _swapBucksForBnb(lowerHalf);

        // Update liquidityFeeBalance
        liquidityFeeBalance = 0;

        // Add liquidity
        _addLiquidity(upperHalf, address(this).balance - oldBalance);
    }

    // Adds liquidity to the BUCKS / BNB pair on Pancakeswap
    function _addLiquidity(uint256 _bucksAmount, uint256 _bnbAmount) internal {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeRouter), _bucksAmount);

        // Add the liquidity
        pancakeRouter.addLiquidityETH{value: _bnbAmount}(
            address(this),
            _bucksAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            address(0),
            block.timestamp
        );

        emit AddedLiquidity(_bucksAmount, _bnbAmount);
    }

    // Marks an address as an automated market pair / removes that mark
    function _setAutomatedMarketMakerPair(address _pair, bool _value) internal {
        automatedMarketMakerPairs[_pair] = _value;
    }

    // Returns true if "_user" is blacklisted, false instead
    function _isBlacklisted(address _user) internal view returns (bool) {
        return _blacklist[_user];
    }

    /** VIEW METHODS **/

    /** DAO METHODS **/
    function pause() public onlyRole(DAO) {
        _pause();
    }

    function unpause() public onlyRole(DAO) {
        _unpause();
    }

    // Mint new BUCKS tokens to the given address
    function mintDAO(address _to, uint256 _amount) public onlyRole(DAO) {
        _mint(_to, _amount);
    }

    // Burns BUCKS tokens from a given address
    function burnDAO(address _from, uint256 _amount) public onlyRole(DAO) {
        _burn(_from, _amount);
    }

    // Withdraws an amount of BNB stored on the contract
    function withdrawDAO(uint256 _amount) external onlyRole(DAO) {
        payable(msg.sender).transfer(_amount);
    }

    // Withdraws an amount of ERC20 tokens stored on the contract
    function withdrawERC20DAO(address _erc20, uint256 _amount)
        external
        onlyRole(DAO)
    {
        IERC20(_erc20).transfer(msg.sender, _amount);
    }

    // Manually swaps the safe fees
    function manualSafeFeeSwapDAO() external onlyRole(DAO) {
        // Forbid swapping safe fees
        swapping = true;

        // Perform the swap
        _swapSafeFeeBalance();

        // Allow swapping again
        swapping = false;
    }

    // Manually adds liquidity
    function manualLiquifyDAO() external onlyRole(DAO) {
        // Forbid swapping liquidity fees
        swapLiquify = true;

        // Perform the swap
        _liquify();

        // Allow swapping again
        swapLiquify = false;
    }

    // Manually increase BNB reserve
    function manualBNBRewardsDAO() external onlyRole(DAO) {
        // Forbid swapping
        swapBNBRewards = true;

        // Perform the swap
        _swapBucksForBnb(BNBRewardsFeeBalance);

        // Update BNBRewardsFeeBalance
        BNBRewardsFeeBalance = 0;

        // Allow swapping again
        swapBNBRewards = false;
    }

    /** ROLE MANAGEMENT **/

    // Gives the BRIDGE role to an address so it can set the internal variable
    function grantBridgeRoleDAO(address _bridge) external onlyRole(DAO) {
        grantRole(BRIDGE, _bridge);

        // Exempt from fees
        _exemptFromFees[_bridge] = true;
    }

    // Removes the BRIDGE role from an address
    function revokeBridgeRoleDAO(address _bridge) external onlyRole(DAO) {
        revokeRole(BRIDGE, _bridge);

        // Revoke exemption from fees
        _exemptFromFees[_bridge] = false;
    }

    function grantDAORole(address _dao) external onlyRole(DAO) {
        grantRole(DAO, _dao);
    }

    function changeDAO(address _dao) external onlyRole(DAO) {
        revokeRole(DAO, dao);
        grantRole(DAO, _dao);
        dao = _dao;
    }

    function revokeDAO(address _DaoToRevoke) external onlyRole(DAO) {
        revokeRole(DAO, _DaoToRevoke);
    }

    /** SETTERS **/

    function blacklistDAO(address[] calldata _users, bool _state)
        external
        onlyRole(DAO)
    {
        for (uint256 i = 0; i < _users.length; i++) {
            _blacklist[_users[i]] = _state;
        }
    }

    function setFeeSafeDAO(address payable _feeSafe) external onlyRole(DAO) {
        feeSafe = _feeSafe;
    }

    function setAutomatedMarketMakerPairDAO(address _pair, bool _value)
        external
        onlyRole(DAO)
    {
        require(
            _pair != pancakeBucksBnbPair,
            "The BUCKS / BNB pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(_pair, _value);
    }

    function excludeFromFeesDAO(address _account, bool _state)
        external
        onlyRole(DAO)
    {
        _exemptFromFees[_account] = _state;
    }

    function setMinimumSafeFeeBalanceToSwapDAO(
        uint256 _minimumSafeFeeBalanceToSwap
    ) external onlyRole(DAO) {
        minimumSafeFeeBalanceToSwap = _minimumSafeFeeBalanceToSwap;
    }

    function setMinimumLiquidityFeeBalanceToSwapDAO(
        uint256 _minimumLiquidityFeeBalanceToSwap
    ) external onlyRole(DAO) {
        minimumLiquidityFeeBalanceToSwap = _minimumLiquidityFeeBalanceToSwap;
    }

    function setMinimumBNBRewardsBalanceToSwap(
        uint256 _minimumBNBRewardsBalanceToSwap
    ) external onlyRole(DAO) {
        minimumBNBRewardsBalanceToSwap = _minimumBNBRewardsBalanceToSwap;
    }

    function enableSwappingDAO() external onlyRole(DAO) {
        swapEnabled = true;
    }

    function stopSwappingDAO() external onlyRole(DAO) {
        swapEnabled = false;
    }

    // Buying and selling fees
    function setBuyingFeeDAO(uint256 _buyingFee) external onlyRole(DAO) {
        buyingFee = _buyingFee;
    }

    function setSellingFeeClaimedDAO(uint256 _sellingFeeClaimed)
        external
        onlyRole(DAO)
    {
        sellingFeeClaimed = _sellingFeeClaimed;
    }

    function setSellingFeeNonClaimedDAO(uint256 _sellingFeeNonClaimed)
        external
        onlyRole(DAO)
    {
        sellingFeeNonClaimed = _sellingFeeNonClaimed;
    }

    // Buying/Selling Fees Repartition
    function setSafeFeePercentageDAO(uint256 _safeFeePercentage)
        external
        onlyRole(DAO)
    {
        safeFeePercentage = _safeFeePercentage;
    }

    function setLiquidityFeePercentage(uint256 _liquidityFeePercentage)
        external
        onlyRole(DAO)
    {
        liquidityFeePercentage = _liquidityFeePercentage;
    }

    function setClaimedTokens(address _account, uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        claimedTokens[_account] = _amount;
    }

    // Bridge from the Network
    function bridgeTransfert(
        address _from,
        address _to,
        uint256 _amount
    ) external onlyRole(BRIDGE) {
        _transfer(_from, _to, _amount);
    }

    function bridgeAddSafeFeeBalance(uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        safeFeeBalance += _amount;
    }

    function bridgeAddLiquidityFeeBalance(uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        liquidityFeeBalance += _amount;
    }

    function bridgeAddBNBRewardsFeeBalance(uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        BNBRewardsFeeBalance += _amount;
    }

    function bridgeAddClaimedTokens(address _user, uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        claimedTokens[_user] += _amount;
    }

    function bridgeBlackList(address _user, bool _state)
        external
        onlyRole(BRIDGE)
    {
        _blacklist[_user] = _state;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// Uniswap V2
pragma solidity 0.8.4;

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: MIT
// Uniswap V2
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IPancakePair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}