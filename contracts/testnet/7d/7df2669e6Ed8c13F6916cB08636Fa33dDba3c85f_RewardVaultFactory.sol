//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IVaultFactory.sol";
import "./Vault.sol";

/// @title  RewardVaultFactory
/// @author Christian B. Martinez
/// @notice This contract will deploy a RewardVault contract.

contract RewardVaultFactory is IRewardVaultFactory, Ownable {
    using SafeERC20 for IERC20;
    bool internal locked;

    /// @notice Launching other contracts can be pausd by the owner of this contract.
    bool public launchRewardSchedulePaused;

    /// @notice The public relayer address that refers back to the Relayer contract.
    address public relayerAddress;

    /// @notice All launched assets will be added to this array for quick lookup.
    address[] public allRewardVaults;

    /// @notice Each vault should point to an asset or wallet where swap/transactions will be made.
    mapping(address => address) public vaultAsset;

    /// @notice Event to be captured.
    event RewardScheduleLaunched(
        address indexed clientAddress,
        address indexed assetAddress,
        address indexed vaultAddress
    );

    modifier noReentrant() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    /// @notice can only launch schedules with the correct set paramets.
    /// @dev only used when launching a schedule with a pre-deployed token.
    modifier canLaunchRewardSchedule(
        address assetAddress,
        uint256 totalRewardsFunds
    ) {
        require(!launchRewardSchedulePaused);
        require(relayerAddress != address(0));
        require(assetAddress != address(this));
        require(assetAddress != address(0));
        require(totalRewardsFunds > 0);
        require(
            totalRewardsFunds <=
                IERC20(assetAddress).allowance(msg.sender, address(this))
        );
        _;
    }

    constructor() {}

    /// @notice helper function to return the vault's asset
    /// @param vaultAddress - The address where the recipient/project funds are being held.
    function getVaultAsset(address vaultAddress)
        external
        view
        override
        returns (address)
    {
        return vaultAsset[vaultAddress];
    }

    /// @notice helper function to return all the vault contracts created.
    /// @return Array of addresses of all vaults created by this contract.
    function getAllRewardVaults() public view returns (address[] memory) {
        return allRewardVaults;
    }

    /// @notice helper function to return the count of all the vault contracts created.
    /// @return Count of all reward vaults created by this contract.
    function getAllRewardVaultsCount() public view returns (uint256) {
        return allRewardVaults.length;
    }

    /// @notice owner can change the relayer address to accomodate new versions/new exchanges.
    function setRelayerAddress(address newRelayerAddress) external onlyOwner {
        require(relayerAddress != newRelayerAddress);
        require(newRelayerAddress != address(this));
        require(newRelayerAddress != address(0));
        relayerAddress = newRelayerAddress;
    }

    function pauseLaunches() external onlyOwner {
        require(!launchRewardSchedulePaused);
        launchRewardSchedulePaused = true;
    }

    function resumeLaunches() external onlyOwner {
        require(launchRewardSchedulePaused);
        launchRewardSchedulePaused = false;
    }

    /// @notice main function that handles the creation of vault contracts.
    /// @dev will be called for all shedules with pre/post deployed tokens.
    /// @return address the address of the newly creaty vault contract.
    function createRewardVault(
        address assetAddress,
        address clientAddress,
        address currencyToAccept,
        uint256 minimumInvestmentAmount,
        uint256 maximumInvestmentAmount,
        bool whitelistOnly,
        uint8 maxRewardRounds
    ) internal returns (address) {
        bytes memory bytecode = type(RewardVault).creationCode;

        bytes32 salt = keccak256(
            abi.encodePacked(
                assetAddress,
                clientAddress,
                allRewardVaults.length
            )
        );

        address vaultAddress;

        assembly {
            vaultAddress := create2(
                0,
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )
            if iszero(extcodesize(vaultAddress)) {
                revert(0, 0)
            }
        }

        allRewardVaults.push(vaultAddress);

        RewardVault(vaultAddress).initialize(
            owner(),
            clientAddress,
            assetAddress,
            relayerAddress,
            currencyToAccept,
            minimumInvestmentAmount,
            maximumInvestmentAmount,
            maxRewardRounds,
            whitelistOnly
        );

        return vaultAddress;
    }

    /// @notice launch a schedule with token to reward at launch
    /// @dev maybe used for tokens with no taxes as initiator will have to send tokens in order for this function to run succssesfully.
    function launchRewardSchedule(
        bool whitelistOnly,
        address assetAddress,
        uint256 totalRewardsFunds,
        uint256 minimumInvestmentAmount,
        uint256 maximumInvestmentAmount,
        uint8 maxRewardRounds
    )
        external
        noReentrant
        canLaunchRewardSchedule(assetAddress, totalRewardsFunds)
    {
        address vaultAddress = createRewardVault(
            assetAddress,
            msg.sender,
            address(0),
            minimumInvestmentAmount,
            maximumInvestmentAmount,
            whitelistOnly,
            maxRewardRounds
        );

        vaultAsset[vaultAddress] = assetAddress;

        IERC20(assetAddress).safeTransferFrom(
            msg.sender,
            vaultAddress,
            totalRewardsFunds
        );

        emit RewardScheduleLaunched(msg.sender, assetAddress, vaultAddress);
    }

    /// @notice launch a schedule with no token to reward. Token will be added later.
    /// @dev used for tokens that have taxes. once launched, get the address, whitelist it in token contract, and set/initiate schedule.
    function launchRewardScheduleNoRewardSet(
        bool whitelistOnly,
        address clientAddress,
        address currencyToAccept,
        uint256 minimumInvestmentAmount,
        uint256 maximumInvestmentAmount,
        uint8 maxRewardRounds
    ) external noReentrant {
        require(!launchRewardSchedulePaused);

        address vaultAddress = createRewardVault(
            clientAddress,
            msg.sender,
            currencyToAccept,
            minimumInvestmentAmount,
            maximumInvestmentAmount,
            whitelistOnly,
            maxRewardRounds
        );

        vaultAsset[vaultAddress] = clientAddress;

        emit RewardScheduleLaunched(msg.sender, clientAddress, vaultAddress);
    }

    /// @notice update the asset listed under the vault.
    /// @dev can be called individually or by another contract.
    /// @dev will be called by the Vault contract whenever the assets needs changing.
    function updateVaultAsset(address newAssetAddress) external override {
        require(vaultAsset[msg.sender] != address(0));
        require(vaultAsset[msg.sender] != newAssetAddress);
        vaultAsset[msg.sender] = newAssetAddress;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

/// @title  RewardVaultFactory Interface
/// @author Christian B. Martinez
/// @notice Interface with exposed methods that can be used by outside contracts.

interface IRewardVaultFactory {
    function getVaultAsset(address vaultAddress)
        external
        view
        returns (address);

    function updateVaultAsset(address newAssetAddress) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IVault.sol";
import "./IVaultFactory.sol";

/// @title  RewardVault
/// @author Christian B. Martinez
/// @notice This contract is deployed by the Reaward Factory contract for each client.

contract RewardVault is IRewardVault, Ownable {
    bool internal locked;

    /// @notice struct holding the overall vault info.
    VaultInfo private vaultInfo;

    /// @notice struct holding only info related to the rewards.
    RewardInfo public rewardInfo;

    /// @notice mapping per refereer holding their reward specific info.
    mapping(address => ReferrerInfo) public referrerInfo;

    modifier noReentrant() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    modifier onlyClient() {
        require(msg.sender == vaultInfo.clientAddress);
        _;
    }

    modifier onlyOwnerOrClient() {
        require(msg.sender == vaultInfo.clientAddress || msg.sender == owner());
        _;
    }

    modifier onlyApprovedRelayers() {
        require(vaultInfo.relayers[msg.sender], "EQR: Not a vaild relayer");
        _;
    }

    modifier isClaimable(address referrer) {
        require(vaultInfo.assetAddress != address(0));
        require(getCurrentRewardsFunds() > 0);
        require(rewardInfo.canClaimRewards);
        require(canAccountClaim(referrer));
        _;
    }

    modifier properAddress(address addressToCheck) {
        require(addressToCheck != address(0));
        require(addressToCheck != address(this));
        _;
    }

    constructor() {
        vaultInfo.rewardFactory = msg.sender;
    }

    /// @notice after contract is deployed, it will then have to be initialized with the correct values.
    /// @dev allowed to be re-initialized by owner at a later date.
    function initialize(
        address accountManagerAddress,
        address clientAddressToSet,
        address assetAddressToSet,
        address relayer,
        address currency,
        uint256 minInvestmentAmount,
        uint256 maxInvestmentAmount,
        uint8 maxRounds,
        bool isWhitelistOnly
    ) external {
        require(msg.sender == vaultInfo.rewardFactory);
        vaultInfo.clientAddress = clientAddressToSet;
        vaultInfo.assetAddress = assetAddressToSet;
        vaultInfo.relayers[relayer] = true;
        vaultInfo.currencyToRecieve = currency;
        vaultInfo.minimumInvestmentAmount = minInvestmentAmount;
        vaultInfo.maximumInvestmentAmount = maxInvestmentAmount;
        rewardInfo.finalRewardRound = maxRounds;
        vaultInfo.whitelistOnly = isWhitelistOnly;
        transferOwnership(accountManagerAddress);
    }

    /// @notice for schedules with no active token, i.e. those seeking investment - this is the currency their prospects are allowd to invest in.
    /// @dev only used for schedule with no active reward system: those with no token deployed.
    /// @return address of the currency to receive. (busd, usdc, usdt, etc).
    function getCurrencyToReceive() public view override returns (address) {
        return vaultInfo.currencyToRecieve;
    }

    /// @notice amount of tokens available in the contract to reward.
    /// @dev only valid for contracts with that were funded with a reward token.
    /// @return amount of tokens available in the contract for rewards.
    function getCurrentRewardsFunds() public view override returns (uint256) {
        return IERC20(vaultInfo.assetAddress).balanceOf(address(this));
    }

    /// @notice get the status of the vault contract and the prospect.
    /// @dev will be called by relayer on every transaction to check whether prospect is eligble to transact and vault min/max.
    /// @return minAmount the min amount acceptable to credit reward.
    /// @return maxAmount the max amount acceptable to credit reward.
    /// @return canInvest whether the prospect can invest (is whitelisted).
    /// @return currencyToRecieve the address of the allowed currency the prospect can invest in.
    function getVaultStatus(address prospect)
        public
        view
        override
        properAddress(prospect)
        returns (
            uint256 minAmount,
            uint256 maxAmount,
            bool canInvest,
            address currencyToRecieve
        )
    {
        return (
            vaultInfo.minimumInvestmentAmount,
            vaultInfo.maximumInvestmentAmount,
            canAccountInvest(prospect),
            vaultInfo.currencyToRecieve
        );
    }

    /// @notice the rewards unlocked and ready to be claimed by the referrer.
    /// @dev only valid for use when there is an active token to reward.
    /// @dev for instances where these is no token, this function will return 0 or just return the amount that could be rewarded if there were an active token.
    /// @return tokensToReward
    function getClaimableRewards(address referrer)
        public
        view
        override
        properAddress(referrer)
        returns (uint256)
    {
        if (
            getCurrentRewardsFunds() > 0 &&
            rewardInfo.canClaimRewards &&
            canAccountClaim(referrer)
        ) {
            return calculateClaimableRewards(referrer);
        } else {
            return 0;
        }
    }

    /// @notice the info related to the referrer.
    /// @dev can be called internally/extarnally. Used to calculate how much rewards a referrer should receive.
    /// @return prorataShare the amount the referrer has brought in per round.
    /// @return totalShare the total amount brought in by all referrers in that round.
    /// @return notionalBase the base amount of tokens available for rewards in that round.
    /// @return tokensToReceive the amount of tokens to receive based on the share of tokens brough in for that round.
    /// @return roundsToClaim the amount of rounds to claim
    function getReferralStats(address referrer)
        public
        view
        returns (
            uint256 prorataShare,
            uint256 totalShare,
            uint256 notionalBase,
            uint256 tokensToReceive,
            uint8 roundsToClaim
        )
    {
        uint8 index = referrerInfo[referrer].currentRoundToClaim;
        uint256 rata = 0;
        uint256 total = 0;
        uint256 notional = 0;
        if (index == 0 && index == rewardInfo.nextRoundToReward) {
            (
                uint256 amountInvested,
                uint256 totalInvested,
                uint256 notionalAmtToRewards
            ) = getValidInvestmentAmount(
                    referrerInfo[referrer].shareOfAmountReferredPerRound[index],
                    index
                );
            return (
                amountInvested,
                totalInvested,
                notionalAmtToRewards,
                totalInvested != 0
                    ? (notionalAmtToRewards * amountInvested) / totalInvested
                    : 0,
                0
            );
        }
        for (index; index < rewardInfo.nextRoundToReward; index++) {
            (
                uint256 amountInvested,
                uint256 totalInvested,
                uint256 notionalAmtToRewards
            ) = getValidInvestmentAmount(
                    referrerInfo[referrer].shareOfAmountReferredPerRound[index],
                    index
                );
            rata += amountInvested;
            total += totalInvested;
            notional += notionalAmtToRewards;
        }

        return (
            rata,
            total,
            notional,
            total != 0 ? (notional * rata) / total : 0,
            rewardInfo.nextRoundToReward -
                referrerInfo[referrer].currentRoundToClaim
        );
    }

    /// @notice internal function to get the vailid investment amount.
    /// @dev used to calculate how much has been invested.
    /// @dev if in that current round saw no investedments credited to referrer, it will return 0.
    /// @return shareInvested the amount credited to the referrer for the round.
    /// @return totalInvested the total amount invested in that round.
    /// @return notionalAmtToReward the base amount of tokens available for rewards in that round.
    function getValidInvestmentAmount(uint256 amountInvested, uint8 index)
        internal
        view
        returns (
            uint256 shareInvested,
            uint256 totalInvested,
            uint256 notionalAmtToReward
        )
    {
        if (amountInvested == 0) {
            return (amountInvested, 0, 0);
        } else {
            return (
                amountInvested,
                rewardInfo.totalAmountReferredPerRound[index],
                rewardInfo.notionalAmountPerRound[index]
            );
        }
    }

    /// @notice can the prospect invest.
    /// @dev valid for schedules that make use of the whitelist mechanism.
    /// @return bool true if whitelited or whitelist not being used; false if not whitelisted.
    function canAccountInvest(address prospect)
        public
        view
        override
        properAddress(prospect)
        returns (bool)
    {
        if (vaultInfo.whitelistOnly) {
            return vaultInfo.whitelistedAddress[prospect];
        } else {
            return true;
        }
    }

    /// @notice can the referrer calim rewards
    /// @return bool true if account can claim
    function canAccountClaim(address prospect)
        public
        view
        override
        properAddress(prospect)
        returns (bool)
    {
        return ((referrerInfo[prospect].isActive &&
            !referrerInfo[prospect].isBlacklisted) &&
            (referrerInfo[prospect].currentRoundToClaim <
                rewardInfo.nextRoundToReward) &&
            (referrerInfo[prospect].currentRoundToClaim <
                rewardInfo.finalRewardRound));
    }

    /// @notice used to calculate the rewards unlocked and claimable.
    /// @return amountToReward the total tokens that will be sent to the referrer.
    function calculateClaimableRewards(address prospect)
        internal
        view
        returns (uint256)
    {
        uint256 amountToReward = 0;
        uint8 currRound = referrerInfo[prospect].currentRoundToClaim;
        for (currRound; currRound < rewardInfo.nextRoundToReward; currRound++) {
            (
                uint256 amountInvested,
                uint256 totalInvested,
                uint256 notionalAmtToRewards
            ) = getValidInvestmentAmount(
                    referrerInfo[prospect].shareOfAmountReferredPerRound[
                        currRound
                    ],
                    currRound
                );

            if (amountInvested != 0) {
                amountToReward +=
                    (notionalAmtToRewards * amountInvested) /
                    totalInvested;
            }
        }
        return amountToReward;
    }

    /// @notice if the referrer attracted investments, this function will credit the referrer.
    /// @dev should only be called by the relayer contract upon successful investment.
    /// @return bool whether or not the credit was a success/fail.
    function creditReferrer(address referrerAddress, uint256 referrerAmount)
        external
        override
        onlyApprovedRelayers
        returns (bool)
    {
        uint8 globalCurrentRoundToCredit = rewardInfo.nextRoundToReward;
        referrerInfo[referrerAddress].isActive = true;
        rewardInfo.totalAmountReferredPerRound[
            globalCurrentRoundToCredit
        ] += referrerAmount;
        referrerInfo[referrerAddress].shareOfAmountReferredPerRound[
                globalCurrentRoundToCredit
            ] += referrerAmount;
        return true;
    }

    /// @notice When rewards are unlocked, referrers will call this function to claim their share of rewards.
    function claimRewards()
        external
        override
        properAddress(msg.sender)
        isClaimable(msg.sender)
        noReentrant
    {
        uint256 rewardsToClaim = getClaimableRewards(msg.sender);
        require(rewardsToClaim > 0);
        referrerInfo[msg.sender].currentRoundToClaim = rewardInfo
            .nextRoundToReward;
        IERC20(vaultInfo.assetAddress).transfer(msg.sender, rewardsToClaim);
    }

    /// @notice used to updated relayer.
    function updateRelayers(address newRelayer, bool update)
        external
        override
        properAddress(newRelayer)
        onlyOwner
    {
        if (update) {
            require(!vaultInfo.relayers[newRelayer], "EQR: Relayer Set");
            vaultInfo.relayers[newRelayer] = true;
        } else {
            require(vaultInfo.relayers[newRelayer], "EQR: Relayer Set");
            vaultInfo.relayers[newRelayer] = false;
        }
    }

    /// @notice used to updated relayer.
    /// @dev will call the factory contract to ensure proper asset is listed in the vaultAsset mapping.
    function updateAssetAddress(address newAssetAddress)
        external
        override
        properAddress(newAssetAddress)
        onlyOwnerOrClient
    {
        require(newAssetAddress != vaultInfo.assetAddress);
        vaultInfo.assetAddress = newAssetAddress;
        IRewardVaultFactory(vaultInfo.rewardFactory).updateVaultAsset(
            newAssetAddress
        );
    }

    /// @notice update the address of the client
    function updateClientAddress(address newClientAddress)
        external
        override
        properAddress(newClientAddress)
        onlyOwnerOrClient
    {
        require(newClientAddress != vaultInfo.clientAddress);
        require(newClientAddress != owner());
        vaultInfo.clientAddress = newClientAddress;
    }

    /// @notice skip to a round to unlock rewards as opposed to 1 step incremental increases.
    /// @dev used for projects that want to accelarate rewards.
    function skipRoundtoReward(uint8 roundToReward)
        external
        override
        onlyOwnerOrClient
    {
        require(
            roundToReward > rewardInfo.nextRoundToReward &&
                roundToReward <= rewardInfo.finalRewardRound
        );
        if (rewardInfo.nextRoundToReward == 0) {
            rewardInfo.notionalAmountPerRound[rewardInfo.nextRoundToReward] =
                getCurrentRewardsFunds() /
                (rewardInfo.finalRewardRound - rewardInfo.nextRoundToReward);
        } else {
            rewardInfo.notionalAmountPerRound[rewardInfo.nextRoundToReward] =
                (getCurrentRewardsFunds() -
                    rewardInfo.notionalAmountPerRound[
                        rewardInfo.nextRoundToReward
                    ]) /
                (rewardInfo.finalRewardRound - rewardInfo.nextRoundToReward);
        }
        rewardInfo.nextRoundToReward = roundToReward;
    }

    /// @notice 1 step increment reward round.
    /// @dev should be used on default. every week/month will be used to unlock rewards.
    function incrementRoundToReward() external override onlyOwnerOrClient {
        require(rewardInfo.nextRoundToReward < rewardInfo.finalRewardRound);
        rewardInfo.canClaimRewards = true;
        if (rewardInfo.nextRoundToReward == 0) {
            rewardInfo.notionalAmountPerRound[rewardInfo.nextRoundToReward] =
                getCurrentRewardsFunds() /
                (rewardInfo.finalRewardRound - rewardInfo.nextRoundToReward);
        } else {
            rewardInfo.notionalAmountPerRound[rewardInfo.nextRoundToReward] =
                (getCurrentRewardsFunds() -
                    rewardInfo.notionalAmountPerRound[
                        rewardInfo.nextRoundToReward - 1
                    ]) /
                (rewardInfo.finalRewardRound - rewardInfo.nextRoundToReward);
        }

        rewardInfo.nextRoundToReward++;
    }

    /// @notice update the final reward round. can only be increased.
    /// @dev increasing the final reward round, while keeping amount of tokens available for reward constant, will  leave less rewards per round per referrer.
    /// @dev can only be increased to prevent ending schedule prematurely.
    function updateFinalRewardRound(uint8 newFinalRound)
        external
        override
        onlyOwnerOrClient
    {
        require(newFinalRound > rewardInfo.nextRoundToReward);
        rewardInfo.finalRewardRound = newFinalRound;
    }

    function pauseRewards() external override onlyOwnerOrClient {
        require(rewardInfo.canClaimRewards);
        rewardInfo.canClaimRewards = false;
    }

    function startRewards() external override onlyOwnerOrClient {
        require(!rewardInfo.canClaimRewards);
        rewardInfo.canClaimRewards = true;
    }

    /// @notice whitelist accounts that can invest
    /// @dev only used for schedules where they are seeking investment. No token on dex available for purchase.
    function setWhitelistedAccounts(address[] memory whitelistedAddresses)
        external
        override
        onlyOwnerOrClient
    {
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            require(whitelistedAddresses[i] != address(0));
            require(whitelistedAddresses[i] != address(this));
            vaultInfo.whitelistedAddress[whitelistedAddresses[i]] = true;
        }
    }

    /// @notice remove whitelisted accounts
    /// @dev only used for schedules where they are seeking investment. No token on dex available for purchase.
    function removeWhitelistedAccounts(address[] memory whitelistedAddresses)
        external
        override
        onlyOwnerOrClient
    {
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            require(whitelistedAddresses[i] != address(0));
            require(whitelistedAddresses[i] != address(this));
            vaultInfo.whitelistedAddress[whitelistedAddresses[i]] = false;
        }
    }

    /// @notice adding more tokens available for rewards.
    /// @dev should only be called by the client (the project owner).
    function addRewardFunds(uint256 totalRewardsFunds)
        external
        override
        noReentrant
        onlyClient
    {
        require(vaultInfo.assetAddress != address(0));
        require(totalRewardsFunds > 0);
        require(
            IERC20(vaultInfo.assetAddress).allowance(
                msg.sender,
                address(this)
            ) >= totalRewardsFunds
        );
        IERC20(vaultInfo.assetAddress).transferFrom(
            msg.sender,
            address(this),
            totalRewardsFunds
        );
    }

    /// @notice removing reward funds from the schedule.
    /// @dev should only be called by the client (the project owner).
    function withdrawRewardFunds(uint256 amountToWithdraw)
        external
        override
        noReentrant
        onlyClient
    {
        require(vaultInfo.assetAddress != address(0));
        uint256 rewardBalance = IERC20(vaultInfo.assetAddress).balanceOf(
            address(this)
        );
        require(amountToWithdraw > 0);
        require(rewardBalance > 0 && amountToWithdraw <= rewardBalance);
        IERC20(vaultInfo.assetAddress).transfer(
            vaultInfo.clientAddress,
            amountToWithdraw
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

/// @title  RewardVault Interface
/// @author Christian B. Martinez
/// @notice Interface with exposed methods that can be used by outside contracts.

interface IRewardVault {
    struct VaultInfo {
        bool rewardsDistributor;
        bool whitelistOnly;
        address rewardFactory;
        address clientAddress;
        address assetAddress;
        address currencyToRecieve;
        uint256 minimumInvestmentAmount;
        uint256 maximumInvestmentAmount;
        mapping(address => bool) relayers;
        mapping(address => bool) whitelistedAddress;
    }

    struct RewardInfo {
        bool canClaimRewards;
        uint8 nextRoundToReward;
        uint8 finalRewardRound;
        mapping(uint8 => uint256) totalAmountReferredPerRound;
        mapping(uint8 => uint256) notionalAmountPerRound;
    }

    struct ReferrerInfo {
        bool isActive;
        bool isBlacklisted;
        uint8 currentRoundToClaim;
        mapping(uint8 => uint256) shareOfAmountReferredPerRound;
    }

    function getCurrencyToReceive() external view returns (address);

    function getCurrentRewardsFunds() external view returns (uint256);

    function getVaultStatus(address prospect)
        external
        view
        returns (
            uint256 minAmount,
            uint256 maxAmount,
            bool canInvest,
            address currencyToRecieve
        );

    function getClaimableRewards(address referrer)
        external
        view
        returns (uint256);

    function canAccountInvest(address prospect) external view returns (bool);

    function canAccountClaim(address prospect) external view returns (bool);

    function creditReferrer(address referrerAddress, uint256 referrerAmount)
        external
        returns (bool);

    function claimRewards() external;

    function updateRelayers(address newRelayer, bool update) external;

    function updateAssetAddress(address newAssetAddress) external;

    function updateClientAddress(address newClientAddress) external;

    function skipRoundtoReward(uint8 roundToReward) external;

    function incrementRoundToReward() external;

    function updateFinalRewardRound(uint8 newFinalRound) external;

    function pauseRewards() external;

    function startRewards() external;

    function setWhitelistedAccounts(address[] memory whitelistedAddresses)
        external;

    function removeWhitelistedAccounts(address[] memory whitelistedAddresses)
        external;

    function addRewardFunds(uint256 totalRewardsFunds) external;

    function withdrawRewardFunds(uint256 amountToWithdraw) external;
}