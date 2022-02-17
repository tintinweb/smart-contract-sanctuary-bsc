// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./libraries/Formula.sol";
import "./libraries/Config.sol";

contract Project is Ownable {
    struct UserInfo {
        bool isCompletedCampaign;
        bool isAddedWhitelist;
        bool isClaimedBack;
        uint256 stakedAmount;
        uint256 fundedAmount;
        uint256 tokenAllocationAmount;
    }

    struct StakeInfo {
        uint256 startBlockNumber;
        uint256 endBlockNumber;
        uint256 maxStakeAmount;
        uint256 stakedTotalAmount;
        address[] stakedAccounts;
    }

    struct FundingInfo {
        address fundingReceiver;
        uint256 startBlockNumber;
        uint256 endBlockNumber;
        uint256 minAllocation;
        uint256 estimateTokenAllocationRate;
        uint256 allocationRate;
        uint256 fundedTotalAmount;
        address[] fundedAccounts;
        bool isWithdrawnFund;
    }

    struct ProjectInfo {
        uint256 id;
        address owner;
        address tokenAddress;
        uint256 allocationSize;
        StakeInfo stakeInfo;
        FundingInfo fundingInfo;
    }

    IERC20 public immutable gmi;
    IERC20 public immutable busd;

    uint256 public latestProjectId;
    uint256[] public projectIds;

    // projectId => project info
    mapping(uint256 => ProjectInfo) public projects;

    // projectId => account address => user info
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event CreateProject(ProjectInfo project);
    event SetAllocationSize(uint256 indexed _projectId, uint256 allocationSize);
    event SetEstimateTokenAllocationRate(uint256 indexed _projectId, uint256 estimateTokenAllocationRate);
    event SetStakingBlockNumber(uint256 indexed projectId, uint256 blockStart, uint256 blockEnd);
    event SetMaxStakeAmount(uint256 indexed projectId, uint256 maxStakeAmount);
    event SetFundingBlockNumber(uint256 indexed projectId, uint256 blockStart, uint256 blockEnd);
    event SetFundingMinAllocation(uint256 indexed projectId, uint256 minAllocation);
    event SetFundingAllocationRate(uint256 indexed projectId, uint256 fundingAllocationRate);
    event SetFundingReceiver(uint256 indexed projectId, address fundingReceiver);
    event Stake(address account, uint256 indexed projectId, uint256 indexed amount);
    event ClaimBack(address account, uint256 indexed projectId, uint256 indexed amount);
    event AddToCompletedCampaignList(uint256 indexed projectId, address[] accounts);
    event RemovedFromCompletedCampaignList(uint256 indexed projectId, address indexed account);
    event AddedToWhitelist(uint256 indexed projectId, address[] accounts);
    event RemovedFromWhitelist(uint256 indexed projectId, address indexed account);
    event Funding(address account, uint256 indexed projectId, uint256 indexed amount, uint256 tokenAllocationAmount);
    event WithdrawFunding(address account, uint256 indexed projectId, uint256 indexed amount);

    constructor(IERC20 _gmi, IERC20 _busd) {
        gmi = _gmi;
        busd = _busd;
    }

    modifier validProject(uint256 _projectId) {
        require(projects[_projectId].id != 0 && projects[_projectId].id <= latestProjectId, "Invalid project id");
        _; 
    }

    function createProject(
        address _tokenAddress,
        uint256 _allocationSize,
        uint256 _estimateTokenAllocationRate,
        uint256 _stakingStartBlockNumber,
        uint256 _stakingEndBlockNumber,
        uint256 _maxStakeAmount,
        uint256 _fundingStartBlockNumber,
        uint256 _fundingEndBlockNumber,
        uint256 _fundingMinAllocation,
        uint256 _fundingAllocationRate,
        address _fundingReceiver
    ) external onlyOwner {
        require(_stakingStartBlockNumber > block.number &&
                _stakingStartBlockNumber < _stakingEndBlockNumber &&
                _fundingStartBlockNumber > _stakingEndBlockNumber &&
                _fundingStartBlockNumber < _fundingEndBlockNumber, "Invalid block number");
        require(_fundingReceiver != address(0), "Invalid funding receiver address");

        latestProjectId++;
        ProjectInfo memory project;
        project.id = latestProjectId;
        project.tokenAddress = _tokenAddress;
        project.allocationSize = _allocationSize;
        project.stakeInfo.startBlockNumber = _stakingStartBlockNumber;
        project.stakeInfo.endBlockNumber = _stakingEndBlockNumber;
        project.stakeInfo.maxStakeAmount = _maxStakeAmount;
        project.fundingInfo.startBlockNumber = _fundingStartBlockNumber;
        project.fundingInfo.endBlockNumber = _fundingEndBlockNumber;
        project.fundingInfo.minAllocation = _fundingMinAllocation;
        project.fundingInfo.allocationRate = _fundingAllocationRate;
        project.fundingInfo.estimateTokenAllocationRate = _estimateTokenAllocationRate;
        project.fundingInfo.fundingReceiver = _fundingReceiver;

        projects[latestProjectId] = project;
        projectIds.push(latestProjectId);
        emit CreateProject(project);
    }

    function setAllocationSize(uint256 _projectId, uint256 _allocationSize) external onlyOwner validProject(_projectId) {
        require(_allocationSize > 0, "Invalid project allocation size");

        projects[_projectId].allocationSize = _allocationSize;
        emit SetAllocationSize(_projectId, _allocationSize);
    }

    function setEstimateTokenAllocationRate(uint256 _projectId, uint256 _estimateTokenAllocationRate) external onlyOwner validProject(_projectId) {
        require(_estimateTokenAllocationRate > 0, "Invalid project estimate token allocation rate");

        projects[_projectId].fundingInfo.estimateTokenAllocationRate = _estimateTokenAllocationRate;
        emit SetEstimateTokenAllocationRate(_projectId, _estimateTokenAllocationRate);
    }

    function setStakingBlockNumber(uint256 _projectId, uint256 _blockStart, uint256 _blockEnd) external onlyOwner validProject(_projectId) {
        ProjectInfo storage project = projects[_projectId];
        require(_blockStart > block.number &&
                _blockStart < _blockEnd &&
                _blockEnd < project.fundingInfo.startBlockNumber, "Invalid block number");

        project.stakeInfo.startBlockNumber = _blockStart;
        project.stakeInfo.endBlockNumber = _blockEnd;
        emit SetStakingBlockNumber(_projectId, _blockStart, _blockEnd);
    }

    function setMaxStakeAmount(uint256 _projectId, uint256 _maxStakeAmount) external onlyOwner validProject(_projectId) {
        require(_maxStakeAmount > 0, "Invalid limit of stake amount");

        projects[_projectId].stakeInfo.maxStakeAmount = _maxStakeAmount;
        emit SetMaxStakeAmount(_projectId, _maxStakeAmount);
    }

    function setFundingBlockNumber(uint256 _projectId, uint256 _blockStart, uint256 _blockEnd) external onlyOwner validProject(_projectId) {
        ProjectInfo storage project = projects[_projectId];
        require(_blockStart > block.number &&
                _blockStart < _blockEnd &&
                _blockStart > project.stakeInfo.endBlockNumber, "Invalid block number");

        project.fundingInfo.startBlockNumber = _blockStart;
        project.fundingInfo.endBlockNumber = _blockEnd;
        emit SetFundingBlockNumber(_projectId, _blockStart, _blockEnd);
    }

    function setFundingMinAllocation(uint256 _projectId, uint256 _minAllocation) external onlyOwner validProject(_projectId) {
        require(_minAllocation > 0, "Invalid project funding min allocation");

        projects[_projectId].fundingInfo.minAllocation = _minAllocation;
        emit SetFundingMinAllocation(_projectId, _minAllocation);
    }

    function setFundingAllocationRate(uint256 _projectId, uint256 _fundingAllocationRate) external onlyOwner validProject(_projectId) {
        require(_fundingAllocationRate > 0, "Invalid project funding allocation rate");

        projects[_projectId].fundingInfo.allocationRate = _fundingAllocationRate;
        emit SetFundingAllocationRate(_projectId, _fundingAllocationRate);
    }

    function setFundingReceiver(uint256 _projectId, address _fundingReceiver) external onlyOwner validProject(_projectId) {
        require(_fundingReceiver != address(0), "Invalid funding receiver");

        projects[_projectId].fundingInfo.fundingReceiver = _fundingReceiver;
        emit SetFundingReceiver(_projectId, _fundingReceiver);
    }

    /// @notice stake amount of GMI tokens to Staking Pool
    /// @dev    this method can called by anyone
    /// @param  _projectId  id of the project
    /// @param  _amount  amount of the tokens to be staked
    function stake(uint256 _projectId, uint256 _amount) external validProject(_projectId) {
        StakeInfo storage stakeInfo = projects[_projectId].stakeInfo;
        require(block.number >= stakeInfo.startBlockNumber, "Staking has not started yet");
        require(block.number <= stakeInfo.endBlockNumber, "Staking has ended");

        require(isCompletedCampaign(_projectId, _msgSender()), "User is not complete gleam campaign");
        require(_amount > 0, "Invalid stake amount");
        require(_amount <= stakeInfo.maxStakeAmount, "Amount exceed limit stake amount");

        gmi.transferFrom(_msgSender(), address(this), _amount);

        UserInfo storage user = userInfo[_projectId][_msgSender()];

        if (user.stakedAmount == 0) {
            stakeInfo.stakedAccounts.push(_msgSender());
        }
        stakeInfo.stakedTotalAmount += _amount;
        user.stakedAmount += _amount;

        emit Stake(_msgSender(), _projectId, _amount);
    }

    /// @notice claimBack amount of GMI tokens from staked GMI before
    /// @dev    This method can called by anyone
    /// @param  _projectId  id of the project
    function claimBack(uint256 _projectId) external validProject(_projectId) {
        require(block.number >= projects[_projectId].fundingInfo.endBlockNumber, "Funding has not ended yet");

        UserInfo storage user = userInfo[_projectId][_msgSender()];
        uint256 claimableAmount = user.stakedAmount;
        require(claimableAmount > 0, "Nothing to claim back");

        user.isClaimedBack = true;
        gmi.transfer(_msgSender(), claimableAmount);

        emit ClaimBack(_msgSender(), _projectId, claimableAmount);
    }

    function addCompletedCampaignList(uint256 _projectId, address[] memory _accounts) external onlyOwner validProject(_projectId) {
        for (uint256 i = 0; i < _accounts.length; i++) { 
            address account = _accounts[i];
            require(account != address(0), "Invalid account");

            UserInfo storage user = userInfo[_projectId][account];
            user.isCompletedCampaign = true;
        }
        emit AddToCompletedCampaignList(_projectId, _accounts);
    }

    function removedFromCompletedCampaignList(uint256 _projectId, address _account) public onlyOwner validProject(_projectId) {
        userInfo[_projectId][_account].isCompletedCampaign = false;
        emit RemovedFromCompletedCampaignList(_projectId, _account);
    }

    function addWhitelist(uint256 _projectId, address[] memory _accounts) external onlyOwner validProject(_projectId) {
        for (uint256 i = 0; i < _accounts.length; i++) {
            address account = _accounts[i];
            require(account != address(0), "Invalid account");

            UserInfo storage user = userInfo[_projectId][account];
            require(user.stakedAmount > 0, "Account did not stake");

            user.isAddedWhitelist = true;
        }
        emit AddedToWhitelist(_projectId, _accounts);
    }

    function removeFromWhitelist(uint256 _projectId, address _account) public onlyOwner validProject(_projectId) {
        userInfo[_projectId][_account].isAddedWhitelist = false;
        emit RemovedFromWhitelist(_projectId, _account);
    }

    /// @notice fund amount of USD to funding
    /// @dev    this method can called by anyone
    /// @param  _projectId  id of the project
    /// @param  _amount  amount of the tokens to be staked
    function funding(uint256 _projectId, uint256 _amount) external validProject(_projectId) {
        FundingInfo storage fundingInfo = projects[_projectId].fundingInfo;
        require(block.number >= fundingInfo.startBlockNumber, "Funding has not started yet");
        require(block.number <= fundingInfo.endBlockNumber, "Funding has ended");

        require(isAddedWhitelist(_projectId, _msgSender()), "User is not in whitelist");
        require(_amount >= fundingInfo.minAllocation, "Amount must be greater than min allocation");

        uint256 fundingMaxAllocation = getFundingMaxAllocation(_projectId, _msgSender());
        require(_amount <= fundingMaxAllocation, "Amount exceed max allocation");

        busd.transferFrom(_msgSender(), address(this), _amount);

        UserInfo storage user = userInfo[_projectId][_msgSender()];
        if (user.fundedAmount == 0) {
            fundingInfo.fundedAccounts.push(_msgSender());
        }
        fundingInfo.fundedTotalAmount += _amount;
        user.fundedAmount += _amount;

        uint256 tokenAllocationAmount = estimateTokenAllocation(_projectId, _amount);
        user.tokenAllocationAmount += tokenAllocationAmount;

        emit Funding(_msgSender(), _projectId, _amount, tokenAllocationAmount);
    }

    /// @notice receive amount USD from contract
    /// @dev    this method can called by owner
    /// @param  _projectId  id of the project
    function withdrawFunding(uint256 _projectId) external onlyOwner validProject(_projectId) {
        FundingInfo storage fundingInfo = projects[_projectId].fundingInfo;
        require(block.number > fundingInfo.endBlockNumber, "Funding has not ended yet");
        require(!fundingInfo.isWithdrawnFund, "Already withdrawn fund");

        uint256 _amount = fundingInfo.fundedTotalAmount;
        require(_amount > 0, "Not enought amount");

        busd.transfer(fundingInfo.fundingReceiver, _amount);
        fundingInfo.isWithdrawnFund = true;

        emit WithdrawFunding(fundingInfo.fundingReceiver, _projectId, _amount);
    }

    function getProjectInfo(uint256 _projectId) public validProject(_projectId) view returns (ProjectInfo memory result) {
        result = projects[_projectId];
    }

    function getStakeInfo(uint256 _projectId) public validProject(_projectId) view returns (StakeInfo memory result) {
        result = projects[_projectId].stakeInfo;
    }

    function getFundingInfo(uint256 _projectId) public validProject(_projectId) view returns (FundingInfo memory result) {
        result = projects[_projectId].fundingInfo;
    }

    function getUserInfo(uint256 _projectId, address _account) public view returns (UserInfo memory result) {
        result = userInfo[_projectId][_account];
    }

    function isCompletedCampaign(uint256 _projectId, address _account) public view returns (bool) {
        return userInfo[_projectId][_account].isCompletedCampaign;
    }

    function isAddedWhitelist(uint256 _projectId, address _account) public view returns (bool) {
        return userInfo[_projectId][_account].isAddedWhitelist;
    }

    function getFundingMaxAllocation(uint256 _projectId, address _account) public view returns(uint256) {
        UserInfo memory user = userInfo[_projectId][_account];
        uint256 stakedAmount = user.stakedAmount;
        if (stakedAmount == 0) return 0;

        ProjectInfo memory project = projects[_projectId];
        uint256 allocationSize = project.allocationSize;

        uint256 maxAllocationAmount = Formula.mulDivFixedPoint(stakedAmount, project.fundingInfo.allocationRate);
        if (maxAllocationAmount > allocationSize) {
            return allocationSize;
        }

        return maxAllocationAmount;
    }

    function estimateTokenAllocation(uint256 _projectId, uint256 _fundingAmount) public view returns (uint256) {
        ProjectInfo memory project = projects[_projectId];
        return Formula.mulDiv(_fundingAmount, Formula.SCALE, project.fundingInfo.estimateTokenAllocationRate);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Config.sol";

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

/// @dev This library does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal 
/// fixed-point representation. When it does not, it is explicitly mentioned in the NatSpec documentation.
library Formula {
    /// STORAGE ///

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @dev Largest power of two divisor of SCALE.
    uint256 internal constant SCALE_LPOTD = 262144;

    /// @dev SCALE inverted mod 2^256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;

    /// FUNCTIONS ///

    /// @notice Calculates floor(x*y÷1e18) with full precision.
    ///
    /// @dev Variant of "mulDiv" with constant folding, i.e. in which the denominator is always 1e18. Before returning the
    /// final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
    /// being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.
    ///
    /// Requirements:
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
    /// - It is assumed that the result can never be type(uint256).max when x and y solve the following two equations:
    ///     1. x * y = type(uint256).max * SCALE
    ///     2. (x * y) % SCALE >= SCALE / 2
    ///
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The multiplicand as an uint256.
    /// @param y The multiplier as an uint256.
    /// @param denominator The divisor as an uint256.
    /// @return result The result as an uint256.
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division.
        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        // Make sure the result is less than 2^256. Also prevents denominator == 0.
        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0].
        uint256 remainder;
        assembly {
            // Compute remainder using mulmod.
            remainder := mulmod(x, y, denominator)

            // Subtract 256 bit number from 512 bit number.
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
        // See https://cs.stackexchange.com/q/138556/92363.
        unchecked {
            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /// @notice Raises x (unsigned 60.18-decimal fixed-point number) to the power of y (basic unsigned integer) using the
    /// famous algorithm "exponentiation by squaring".
    ///
    /// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    /// Requirements:
    /// - The result must fit within MAX_UD60x18.
    ///
    /// Caveats:
    /// - All from "mul".
    /// - Assumes 0^0 is 1.
    ///
    /// @param x The base as an unsigned 60.18-decimal fixed-point number.
    /// @param y The exponent as an uint256.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {
        // Calculate the first iteration of the loop in advance.
        result = y & 1 > 0 ? x : SCALE;

        // Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
        for (y >>= 1; y > 0; y >>= 1) {
            x = mulDivFixedPoint(x, x);

            // Equivalent to "y % 2 == 1" but faster.
            if (y & 1 > 0) {
                result = mulDivFixedPoint(result, x);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library Constant {
    uint256 internal constant FIXED_POINT = 1e18;

    /// These constants are calculated from algo (365)√(1 + APY)
    // and convert fo Fixed number with above FIXED_POINT
    // ROOT_30 has APY 100% => (365)√(1 + 100%) = 1.0019008376772
    uint256 internal constant ROOT_30 = 1001900837677200000;
    // ROOT_45 has APY 200% => (365)√(1 + 200%) = 1.0030144309684
    uint256 internal constant ROOT_45 = 1003014430968400000;
    // ROOT_60 has APY 300% => (365)√(1 + 300%) = 1.0038052885383
    uint256 internal constant ROOT_60 = 1003805288538300000;
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