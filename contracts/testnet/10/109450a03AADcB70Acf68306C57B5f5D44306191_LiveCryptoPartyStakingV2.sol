/**
 *Submitted for verification at BscScan.com on 2022-06-04
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;



// Treat people with kindness: Rosie
// All copyrights, trademarks and patents belongs to Live Crypto Party livecryptoparty.com


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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

interface IERC20Upgradeable {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

     /**
     * @dev Returns the amount of token decimals`.
     */

     
    function decimals() external view returns (uint256);

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
}

interface IERC721Upgradeable  {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


interface oldStaking {
    struct Stake {
        uint256 plan;
        uint256 withdrawtime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 persecondreward;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalWithdrawanTokenUser;
        uint256 totalUnStakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        bool alreadyExists;
    }

    function stakersRecord(address staker, uint256 index)
        external
        view
        returns (Stake memory stakeData);

    function Stakers(address staker) external view returns (User memory user);
}

contract LiveCryptoPartyStakingV2 is Initializable {
    using SafeMath for uint256;
    IERC20Upgradeable public stakeToken;
    oldStaking public oldStakingAddress;
    IERC721Upgradeable goldNFT;
    IERC721Upgradeable silverNFT;

    address payable public owner;
    address payable public feeReciever;
    uint256 public unstakePenaltyFee ;
    uint256 public claimFee ;

    uint256 public totalStakedLCP;
    uint256 public totalUnStakedLCP;
    uint256 public totalWithdrawanLCP;
    uint256 public totalClaimedRewardLCP;
    uint256 public totalStakersLCP;
    uint256 public percentDivider;
    bool public pauseStaking;

    mapping(address => bool) public _isExcludedFromReward;

    uint256[100] public Duration;
    uint256[100] public Bonus;
    uint256[100] public totalStakedPerPlanLCP;
    uint256[100] public totalStakersPerPlanLCP;
    uint256 public counter;

    uint256 public goldMaxStakingAmount;
    uint256 public silverMaxStakingAmount;

    struct StakeLCP {
        uint256 planLCP;
        uint256 withdrawtimeLCP;
        uint256 staketimeLCP;
        uint256 amountLCP;
        uint256 rewardLCP;
        uint256 persecondrewardLCP;
        bool withdrawanLCP;
        bool unstakedLCP;
    }

    struct UserLCP {
        uint256 totalStakedTokenUserLCP;
        uint256 totalTokensCurrentlyStaked;
        uint256 totalWithdrawanTokenUserLCP;
        uint256 totalUnStakedTokenUserLCP;
        uint256 remainingPendingAmount;
        uint256 totalClaimedRewardTokenUserLCP;
        uint256 stakeCountLCP;
        bool alreadyExistsLCP;
    }

    struct NFTRecord {
        bool exists;
        address owner;
    }

    mapping(address => UserLCP) public StakersLCP;
    mapping(uint256 => address) public StakersIDLCP;
    mapping(address => mapping(uint256 => StakeLCP)) public stakersRecordLCP;
    mapping(address => mapping(uint256 => uint256)) public userStakedPerPlanLCP;
    mapping(uint256 => mapping(uint256 => NFTRecord)) public stakedNFTData;
    mapping(address => mapping(uint256 => uint256)) public stakedNFTCount;

    event STAKE(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    event RESTAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    function initialize() public initializer {
        owner = payable(0xFA8FA2Ef81A7931fC97F7617FDFE81585B5F735E);
        stakeToken = IERC20Upgradeable(0x892bbD570cbC0Ab54Ad1b4618c8680Fadc38AFFb);
        oldStakingAddress = oldStaking(
            0x201d598EDc3e5150581DC87f3D7689Ecdc3293e6
        );
        goldNFT = IERC721Upgradeable(0x013Cb7bCdE5070920034FFA7883eA2a8751292d9);
        silverNFT = IERC721Upgradeable(0x013Cb7bCdE5070920034FFA7883eA2a8751292d9);
        feeReciever = payable(0xFA8FA2Ef81A7931fC97F7617FDFE81585B5F735E);


        Bonus = [75, 150, 300];
        Duration = [3 minutes, 6 minutes, 9 minutes];
        counter = 3;
        percentDivider = 1000;

        unstakePenaltyFee = 0.005 ether;
        claimFee = 0.002 ether;

        goldMaxStakingAmount = 2_000 * (10**stakeToken.decimals());
        silverMaxStakingAmount = 5_00 * (10**stakeToken.decimals());
    }

    function stakeNFT(uint256 _nft, uint256 _id) external {
        require(
            _nft == 0 || _nft == 1,
            "Please  add '0' for Gold Nft & '1' for silver NFT"
        );

        if (_nft == 0) {
            goldNFT.transferFrom(msg.sender, address(this), _id);
            stakedNFTCount[msg.sender][0]++;
            stakedNFTData[0][_id].exists = true;
            stakedNFTData[0][_id].owner = msg.sender;
        }
        if (_nft == 1) {
            silverNFT.transferFrom(msg.sender, address(this), _id);
            stakedNFTCount[msg.sender][1]++;
            stakedNFTData[1][_id].exists = true;
            stakedNFTData[1][_id].owner = msg.sender;
        }
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex >= 0 && planIndex <= 9, "Invalid Time Period");
        require(amount >= 0, "stake more than 0");
        require(!pauseStaking, "staking is paused");

        uint256 goldNFTStaked = stakedNFTCount[msg.sender][0];
        uint256 silverNFTStaked = stakedNFTCount[msg.sender][1];
        // uint256 silverNFTBalance = silverNFT.balanceOf(msg.sender);
        require(
            goldNFTStaked >= 1 || silverNFTStaked >= 1,
            "Please hold LCP NFT first, At this moment you are unable to stake !"
        );

        uint256 allowedAmount;
        if (goldNFTStaked >= 1) {
            allowedAmount = allowedAmount.add(
                goldNFTStaked.mul(goldMaxStakingAmount)
            );
        }
        if (silverNFTStaked >= 1) {
            allowedAmount = allowedAmount.add(
                silverNFTStaked.mul(silverMaxStakingAmount)
            );
        }

        require(
            StakersLCP[msg.sender].totalTokensCurrentlyStaked.add(amount) <=
                allowedAmount,
            "You cannot stake amount greater than Max Limit !"
        );

        if (!StakersLCP[msg.sender].alreadyExistsLCP) {
            StakersLCP[msg.sender].alreadyExistsLCP = true;
            StakersIDLCP[totalStakersLCP] = msg.sender;
            totalStakersLCP++;
        }

        storeData(msg.sender, amount, planIndex);
        stakeToken.transferFrom(msg.sender, address(this), amount);

        emit STAKE(msg.sender, amount);
    }

    function unstakeNFT(uint256 _nft, uint256 _id) external {
        require(
            _nft == 0 || _nft == 1,
            "Please  add '0' for Gold Nft & '1' for silver NFT"
        );

        require(
            stakedNFTCount[msg.sender][0] > 0 || stakedNFTCount[msg.sender][1] > 0,
            "Currently you dont have any staked NFT"
        );

        require(
            StakersLCP[msg.sender].remainingPendingAmount == 0,
            "Please unstake all your stakings first !"
        );

        require(
            stakedNFTData[_nft][_id].exists &&
                stakedNFTData[_nft][_id].owner == msg.sender,
            "Currently this token is not stake !"
        );

        if (_nft == 0) {
            goldNFT.transferFrom(address(this), msg.sender, _id);
            delete stakedNFTData[1][_id];
            stakedNFTCount[msg.sender][0]--;
        }

        if (_nft == 1) {
            silverNFT.transferFrom(address(this), msg.sender, _id);
            delete stakedNFTData[1][_id];
            stakedNFTCount[msg.sender][1]--;
        }
    }

    function storeData(
        address user,
        uint256 amount,
        uint256 planIndex
    ) internal {
        uint256 index = StakersLCP[user].stakeCountLCP;
        StakersLCP[user].totalStakedTokenUserLCP = StakersLCP[user]
            .totalStakedTokenUserLCP
            .add(amount);

        totalStakedLCP = totalStakedLCP.add(amount);
        stakersRecordLCP[user][index].withdrawtimeLCP = block.timestamp.add(
            Duration[planIndex]
        );
        stakersRecordLCP[user][index].staketimeLCP = block.timestamp;
        stakersRecordLCP[user][index].amountLCP = amount;
        stakersRecordLCP[user][index].rewardLCP = amount
            .mul(Bonus[planIndex])
            .div(percentDivider);
        stakersRecordLCP[user][index].persecondrewardLCP = stakersRecordLCP[
            user
        ][index].rewardLCP.div(Duration[planIndex]);
        stakersRecordLCP[user][index].planLCP = planIndex;
        StakersLCP[user].stakeCountLCP++;
        userStakedPerPlanLCP[user][planIndex] = userStakedPerPlanLCP[user][
            planIndex
        ].add(amount);
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].add(
            amount
        );

        StakersLCP[user].remainingPendingAmount = StakersLCP[user]
            .remainingPendingAmount
            .add(
                stakersRecordLCP[user][index].rewardLCP.add(
                    stakersRecordLCP[msg.sender][index].amountLCP
                )
            );

        StakersLCP[user].totalTokensCurrentlyStaked = StakersLCP[user]
            .totalTokensCurrentlyStaked
            .add(stakersRecordLCP[msg.sender][index].amountLCP);
        totalStakersPerPlanLCP[planIndex]++;
    }

    function unstake(uint256 index) public payable {
        require(msg.value >= unstakePenaltyFee, "Insufficient Funds");
        require(
            !stakersRecordLCP[msg.sender][index].withdrawanLCP,
            "already withdrawan"
        );
        require(
            !stakersRecordLCP[msg.sender][index].unstakedLCP,
            "already unstaked"
        );
        require(index < StakersLCP[msg.sender].stakeCountLCP, "Invalid index");

        stakersRecordLCP[msg.sender][index].unstakedLCP = true;

        stakeToken.transfer(
            msg.sender,
            stakersRecordLCP[msg.sender][index].amountLCP
        );

        StakersLCP[msg.sender].totalTokensCurrentlyStaked = StakersLCP[
            msg.sender
        ].totalTokensCurrentlyStaked.sub(
                stakersRecordLCP[msg.sender][index].amountLCP
            );
        totalUnStakedLCP = totalUnStakedLCP.add(
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        feeReciever.transfer(msg.value);
        StakersLCP[msg.sender].totalUnStakedTokenUserLCP = StakersLCP[
            msg.sender
        ].totalUnStakedTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            );
        uint256 planIndex = stakersRecordLCP[msg.sender][index].planLCP;
        userStakedPerPlanLCP[msg.sender][planIndex] = userStakedPerPlanLCP[
            msg.sender
        ][planIndex].sub(
                stakersRecordLCP[msg.sender][index].amountLCP,
                "user stake"
            );
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].sub(
            stakersRecordLCP[msg.sender][index].amountLCP,
            "total stake"
        );

        StakersLCP[msg.sender].remainingPendingAmount = StakersLCP[msg.sender]
            .remainingPendingAmount
            .sub(
                stakersRecordLCP[msg.sender][index].rewardLCP.add(
                    stakersRecordLCP[msg.sender][index].amountLCP
                )
            );

        totalStakersPerPlanLCP[planIndex]--;

        emit UNSTAKE(msg.sender, stakersRecordLCP[msg.sender][index].amountLCP);
    }

    function withdraw(uint256 index) public payable {
        require(msg.value >= claimFee, "Insufficient Funds");
        require(!_isExcludedFromReward[msg.sender], "excluded from reward");
        require(
            !stakersRecordLCP[msg.sender][index].withdrawanLCP,
            "already withdrawan"
        );
        require(
            !stakersRecordLCP[msg.sender][index].unstakedLCP,
            "already unstaked"
        );
        require(
            stakersRecordLCP[msg.sender][index].withdrawtimeLCP <
                block.timestamp,
            "cannot withdraw before stake duration"
        );
        require(index < StakersLCP[msg.sender].stakeCountLCP, "Invalid index");

        stakersRecordLCP[msg.sender][index].withdrawanLCP = true;
        stakeToken.transfer(
            msg.sender,
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        stakeToken.transferFrom(
            owner,
            msg.sender,
            stakersRecordLCP[msg.sender][index].rewardLCP
        );
        feeReciever.transfer(msg.value);
        totalWithdrawanLCP = totalWithdrawanLCP.add(
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        totalClaimedRewardLCP = totalClaimedRewardLCP.add(
            stakersRecordLCP[msg.sender][index].rewardLCP
        );
        StakersLCP[msg.sender].totalWithdrawanTokenUserLCP = StakersLCP[
            msg.sender
        ].totalWithdrawanTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            );
        StakersLCP[msg.sender].totalClaimedRewardTokenUserLCP = StakersLCP[
            msg.sender
        ].totalClaimedRewardTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].rewardLCP
            );

        StakersLCP[msg.sender].remainingPendingAmount = StakersLCP[msg.sender]
            .remainingPendingAmount
            .sub(
                stakersRecordLCP[msg.sender][index].amountLCP.add(
                    stakersRecordLCP[msg.sender][index].rewardLCP
                )
            );

        StakersLCP[msg.sender].totalTokensCurrentlyStaked = StakersLCP[
            msg.sender
        ].totalTokensCurrentlyStaked.sub(
                stakersRecordLCP[msg.sender][index].amountLCP
            );

        uint256 planIndex = stakersRecordLCP[msg.sender][index].planLCP;
        userStakedPerPlanLCP[msg.sender][planIndex] = userStakedPerPlanLCP[
            msg.sender
        ][planIndex].sub(
                stakersRecordLCP[msg.sender][index].amountLCP,
                "user stake"
            );
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].sub(
            stakersRecordLCP[msg.sender][index].amountLCP,
            "total stake"
        );
        totalStakersPerPlanLCP[planIndex]--;

        emit WITHDRAW(
            msg.sender,
            stakersRecordLCP[msg.sender][index].rewardLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            )
        );
    }

    function reStake() public {
        require(!StakersLCP[msg.sender].alreadyExistsLCP, "already restaked");
        StakersLCP[msg.sender].alreadyExistsLCP = true;
        StakersIDLCP[totalStakersLCP] = msg.sender;
        totalStakersLCP++;

        uint256 totalOldStaked;
        oldStaking.User memory userOldData = oldStakingAddress.Stakers(
            msg.sender
        );
        uint256 oldStakeCount = userOldData.stakeCount;

        for (uint256 i = 0; i < oldStakeCount; i++) {
            oldStaking.Stake memory userOldStake = oldStakingAddress
                .stakersRecord(msg.sender, i);
            uint256 planIndex = userOldStake.plan;
            if (!userOldStake.unstaked && !userOldStake.withdrawan) {
                uint256 rewardTime;
                if (block.timestamp >= userOldStake.withdrawtime) {
                    rewardTime =
                        userOldStake.withdrawtime -
                        userOldStake.staketime;
                } else {
                    rewardTime = block.timestamp - userOldStake.staketime;
                }
                uint256 rewardAmount = rewardTime.mul(
                    userOldStake.persecondreward
                );
                uint256 amountBefore = userOldStake.amount;
                uint256 totalrestaked = amountBefore.add(rewardAmount);
                totalOldStaked += totalrestaked;
                storeData(msg.sender, totalrestaked, planIndex);
            }
        }

        stakeToken.transferFrom(owner, address(this), totalOldStaked);

        emit RESTAKE(msg.sender, totalOldStaked);
    }

    function SetStakeDuration(uint256 index, uint256 duration)
        external
        onlyowner
    {
        Duration[index] = duration;
    }

    function SetFees(
        address payable _feeReciever,
        uint256 _penaltyFee,
        uint256 _claimFee
    ) external onlyowner {
        feeReciever = _feeReciever;
        unstakePenaltyFee = _penaltyFee;
        claimFee = _claimFee;
    }

    function SetStakeBonus(uint256 index, uint256 bonus) external onlyowner {
        Bonus[index] = bonus;
    }

    function addNewStakePlan(uint256 duration, uint256 bonus)
        external
        onlyowner
    {
        require(counter <= 100, "plan exceeds limit");
        Duration[counter] = duration;
        Bonus[counter] = bonus;
        counter++;
    }

    function PauseStaking(bool _pause) external onlyowner {
        pauseStaking = _pause;
    }

    function setSilverMaxStakingAmount(uint256 _amount) external onlyowner {
        silverMaxStakingAmount = _amount;
    }

    function setGoldMaxStakingAmount(uint256 _amount) external onlyowner {
        goldMaxStakingAmount = _amount;
    }

    function setStakingToken(IERC20Upgradeable _token) external onlyowner {
        stakeToken = _token;
    }

    function setGoldNFT(IERC721Upgradeable _goldNFT) external onlyowner {
        goldNFT = _goldNFT;
    }

    function setSilverNFT(IERC721Upgradeable _silverNFT) external onlyowner {
        silverNFT = _silverNFT;
    }

    function ExcludeFromReward(address staker, bool _state) external onlyowner {
        _isExcludedFromReward[staker] = _state;
    }

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < StakersLCP[user].stakeCountLCP; i++) {
            if (
                !stakersRecordLCP[user][i].withdrawanLCP &&
                !stakersRecordLCP[user][i].unstakedLCP
            ) {
                uint256 val;
                val = block.timestamp - stakersRecordLCP[user][i].staketimeLCP;
                val = val.mul(stakersRecordLCP[user][i].persecondrewardLCP);
                if (val < stakersRecordLCP[user][i].rewardLCP) {
                    ret += val;
                } else {
                    ret += stakersRecordLCP[user][i].rewardLCP;
                }
            }
        }
        return ret;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}