// SPDX-License-Identifier: MIT
// Developed by: dxsoftware.net

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ISummitKickstarterFactory.sol";
import "../structs/KickstarterInfo.sol";

contract SummitKickstarter is Ownable {
  mapping(address => bool) public isAdmin;
  mapping(address => uint256) public contributions;
  mapping(address => uint256) public contributorIndexes;

  address[] public contributors;
  address public factory;

  Kickstarter public kickstarter;
  ApprovalStatus public approvalStatus = ApprovalStatus.PENDING;

  uint256 public constant FEE_DENOMINATOR = 10000;
  uint256 public totalContribution;
  uint256 public percentageFeeAmount = 0;
  uint256 public fixFeeAmount = 0;

  string public rejectedReason;

  event Contribute(address indexed contributor, uint256 amount, uint256 timestamp);
  event KickstarterUpdated(Kickstarter kickstarter);
  event KickstarterUpdatedByFactoryAdmin(
    Kickstarter kickstarter,
    ApprovalStatus approvalStatus,
    uint256 percentageFeeAmount,
    uint256 fixFeeAmount
  );

  event TitleUpdated(string title);
  event CreatorUpdated(string creator);
  event ImageUrlUpdated(string imageUrl);
  event ProjectDescriptionUpdated(string projectDescription);
  event RewardDescriptionUpdated(string rewardDescription);
  event MinContributionUpdated(uint256 minContribution);
  event ProjectGoalsUpdated(uint256 projectGoals);
  event RewardDistributionTimestampUpdated(uint256 rewardDistributionTimestamp);
  event StartTimestampUpdated(uint256 startTimestamp);
  event EndTimestampUpdated(uint256 endTimestamp);

  event ApprovalStatusUpdated(ApprovalStatus approvalStatus);
  event PercentageFeeAmountUpdated(uint256 percentageFeeAmount);
  event FixFeeAmountUpdated(uint256 fixFeeAmount);

  event Approved(uint256 percentageFeeAmount, uint256 fixFeeAmount);
  event Rejected(string rejectedReason);

  constructor(address _owner, Kickstarter memory _kickstarter) {
    transferOwnership(_owner);

    factory = msg.sender;
    kickstarter = _kickstarter;
  }

  receive() external payable {}

  modifier onlyFactoryAdmin() {
    require(
      ISummitKickstarterFactory(factory).owner() == msg.sender ||
        ISummitKickstarterFactory(factory).isAdmin(msg.sender),
      "Only factory admin can call this function"
    );
    _;
  }

  modifier onlyFactoryAdminOrAdmin() {
    require(
      ISummitKickstarterFactory(factory).owner() == msg.sender ||
        ISummitKickstarterFactory(factory).isAdmin(msg.sender) ||
        isAdmin[msg.sender],
      "Only admin can call this function"
    );
    _;
  }

  modifier onlyFactoryAdminOrAdminOrOwner() {
    require(
      ISummitKickstarterFactory(factory).owner() == msg.sender ||
        ISummitKickstarterFactory(factory).isAdmin(msg.sender) ||
        isAdmin[msg.sender] ||
        owner() == msg.sender,
      "Only admin or owner can call this function"
    );
    _;
  }

  function getContributors() external view returns (address[] memory) {
    return contributors;
  }

  function contribute(uint256 _amount) external payable {
    require(approvalStatus == ApprovalStatus.APPROVED, "Kickstarter is not Approved");
    if (address(kickstarter.paymentToken) == address(0)) {
      require(msg.value >= _amount, "Insufficient contribution amount");
    } else {
      require(kickstarter.paymentToken.balanceOf(msg.sender) >= _amount, "Insufficient contribution amount");
    }
    require(_amount >= kickstarter.minContribution, "Amount should be greater than minimum contribution");
    require(block.timestamp >= kickstarter.startTimestamp, "You can contribute only after start time");
    require(block.timestamp <= kickstarter.endTimestamp, "You can contribute only before end time");

    totalContribution += _amount;

    if (address(kickstarter.paymentToken) != address(0)) {
      kickstarter.paymentToken.transferFrom(msg.sender, address(this), _amount);
      refundExcessiveFee(msg.value);
    } else {
      uint256 refundAmount = msg.value - _amount;
      refundExcessiveFee(refundAmount);
    }

    contributions[msg.sender] += _amount;

    if ((contributorIndexes[msg.sender] == 0 && contributors.length > 0) || contributors.length == 0) {
      contributorIndexes[msg.sender] = contributors.length;
      contributors.push(msg.sender);
    }

    emit Contribute(msg.sender, _amount, block.timestamp);
  }

  function refundExcessiveFee(uint256 _refundAmount) internal virtual {
    if (_refundAmount > 0) {
      (bool success, ) = address(_msgSender()).call{value: _refundAmount}("");
      require(success, "Unable to refund excess Ether");
    }
  }

  // ** Factory And Admin FUNCTIONS **

  function setTitle(string memory _title) external onlyFactoryAdminOrAdmin {
    require(bytes(_title).length > 0, "Title cannot be empty");
    kickstarter.title = _title;

    emit TitleUpdated(_title);
  }

  function setCreator(string memory _creator) external onlyFactoryAdminOrAdmin {
    require(bytes(_creator).length > 0, "Creator cannot be empty");
    kickstarter.creator = _creator;

    emit CreatorUpdated(_creator);
  }

  function setImageUrl(string memory _imageUrl) external onlyFactoryAdminOrAdmin {
    require(bytes(_imageUrl).length > 0, "Image URL cannot be empty");
    kickstarter.imageUrl = _imageUrl;

    emit ImageUrlUpdated(_imageUrl);
  }

  function setProjectDescription(string memory _projectDescription) external onlyFactoryAdminOrAdmin {
    require(bytes(_projectDescription).length > 0, "Project description cannot be empty");
    kickstarter.projectDescription = _projectDescription;

    emit ProjectDescriptionUpdated(_projectDescription);
  }

  function setRewardDescription(string memory _rewardDescription) external onlyFactoryAdminOrAdmin {
    require(bytes(_rewardDescription).length > 0, "Reward description cannot be empty");
    kickstarter.rewardDescription = _rewardDescription;

    emit RewardDescriptionUpdated(_rewardDescription);
  }

  function setMinContribution(uint256 _minContribution) external onlyFactoryAdminOrAdmin {
    kickstarter.minContribution = _minContribution;

    emit MinContributionUpdated(_minContribution);
  }

  function setProjectGoals(uint256 _projectGoals) external onlyFactoryAdminOrAdmin {
    require(_projectGoals > 0, "Project goals must be greater than 0");
    kickstarter.projectGoals = _projectGoals;

    emit ProjectGoalsUpdated(_projectGoals);
  }

  function setRewardDistributionTimestamp(uint256 _rewardDistributionTimestamp) external onlyFactoryAdminOrAdmin {
    kickstarter.rewardDistributionTimestamp = _rewardDistributionTimestamp;

    emit RewardDistributionTimestampUpdated(_rewardDistributionTimestamp);
  }

  function setStartTimestamp(uint256 _startTimestamp) external onlyFactoryAdminOrAdmin {
    require(_startTimestamp < kickstarter.endTimestamp, "Start timestamp must be before end timestamp");
    kickstarter.startTimestamp = _startTimestamp;

    emit StartTimestampUpdated(_startTimestamp);
  }

  function setEndTimestamp(uint256 _endTimestamp) external onlyFactoryAdminOrAdmin {
    require(_endTimestamp > kickstarter.startTimestamp, "End timestamp must be after start timestamp");
    kickstarter.endTimestamp = _endTimestamp;

    emit EndTimestampUpdated(_endTimestamp);
  }

  function configProjectInfo(Kickstarter calldata _kickstarter) external onlyFactoryAdminOrAdmin {
    require(_kickstarter.startTimestamp < _kickstarter.endTimestamp, "Start timestamp must be before end timestamp");
    require(
      approvalStatus == ApprovalStatus.PENDING || _kickstarter.paymentToken == kickstarter.paymentToken,
      "You can't change payment token after Approval"
    );

    kickstarter = _kickstarter;

    emit KickstarterUpdated(_kickstarter);
  }

  function withdraw(uint256 _amount, address _receiver) external onlyOwner {
    if (address(kickstarter.paymentToken) == address(0)) {
      withdrawBNB(_amount, _receiver);
    } else {
      withdrawToken(_amount, _receiver);
    }
  }

  function withdrawBNB(uint256 _amount, address _receiver) private onlyOwner {
    require(address(this).balance >= _amount, "You cannot withdraw more than you have");

    uint256 withdrawalFee = getWithdrawalFee(_amount, fixFeeAmount, percentageFeeAmount);
    require(address(this).balance > withdrawalFee, "You cannot withraw less than widrawal fee");

    uint256 receiverAmount = _amount - withdrawalFee;

    payable(_receiver).transfer(receiverAmount);
    payable(factory).transfer(withdrawalFee);
  }

  function withdrawToken(uint256 _amount, address _receiver) private onlyOwner {
    require(kickstarter.paymentToken.balanceOf(address(this)) >= _amount, "You cannot withdraw more than you have");

    uint256 withdrawalFee = getWithdrawalFee(_amount, fixFeeAmount, percentageFeeAmount);
    require(
      kickstarter.paymentToken.balanceOf(address(this)) > withdrawalFee,
      "You cannot withraw less than widrawal fee"
    );

    uint256 receiverAmount = _amount - withdrawalFee;

    kickstarter.paymentToken.transfer(_receiver, receiverAmount);
    kickstarter.paymentToken.transfer(factory, withdrawalFee);
  }

  function getWithdrawalFee(
    uint256 _amount,
    uint256 _fixFeeAmount,
    uint256 _percentageFeeAmount
  ) private view returns (uint256) {
    return _fixFeeAmount + ((_amount * _percentageFeeAmount) / FEE_DENOMINATOR);
  }

  // ** FACTORY ADMIN FUNCTIONS **

  function configProjectInfo(
    Kickstarter calldata _kickstarter,
    ApprovalStatus _approvalStatus,
    uint256 _percentageFeeAmount,
    uint256 _fixFeeAmount
  ) external onlyFactoryAdmin {
    require(_kickstarter.startTimestamp < _kickstarter.endTimestamp, "Start timestamp must be before end timestamp");
    require(_percentageFeeAmount <= FEE_DENOMINATOR, "percentageFeeAmount should be less than FEE_DENOMINATOR");
    require(
      approvalStatus == ApprovalStatus.PENDING || _kickstarter.paymentToken == kickstarter.paymentToken,
      "You can't change payment token after Approval"
    );
    require(
      getWithdrawalFee(kickstarter.projectGoals, _fixFeeAmount, _percentageFeeAmount) <= kickstarter.projectGoals,
      "Withdrawal fee should not more than project goals"
    );

    kickstarter = _kickstarter;
    approvalStatus = _approvalStatus;
    percentageFeeAmount = _percentageFeeAmount;
    fixFeeAmount = _fixFeeAmount;

    emit KickstarterUpdatedByFactoryAdmin(_kickstarter, _approvalStatus, _percentageFeeAmount, _fixFeeAmount);
  }

  function approve(uint256 _percentageFeeAmount, uint256 _fixFeeAmount) external onlyFactoryAdmin {
    require(_percentageFeeAmount <= FEE_DENOMINATOR, "percentageFeeAmount should be less than FEE_DENOMINATOR");
    require(
      getWithdrawalFee(kickstarter.projectGoals, _fixFeeAmount, _percentageFeeAmount) <= kickstarter.projectGoals,
      "Withdrawal fee should not more than project goals"
    );

    percentageFeeAmount = _percentageFeeAmount;
    fixFeeAmount = _fixFeeAmount;

    approvalStatus = ApprovalStatus.APPROVED;
    rejectedReason = "";

    emit Approved(_percentageFeeAmount, _fixFeeAmount);
  }

  function reject(string memory _rejectedReason) external onlyFactoryAdmin {
    rejectedReason = _rejectedReason;
    approvalStatus = ApprovalStatus.REJECTED;

    emit Rejected(_rejectedReason);
  }

  function setApprovalStatus(ApprovalStatus _approvalStatus) external onlyFactoryAdmin {
    approvalStatus = _approvalStatus;
    emit ApprovalStatusUpdated(_approvalStatus);
  }

  function setAdmins(address[] calldata _walletsAddress, bool _isAdmin) external onlyFactoryAdmin {
    for (uint256 i = 0; i < _walletsAddress.length; i++) {
      isAdmin[_walletsAddress[i]] = _isAdmin;
    }
  }

  function setPercentageFeeAmount(uint256 _percentageFeeAmount) external onlyFactoryAdmin {
    require(_percentageFeeAmount <= FEE_DENOMINATOR, "percentageFeeAmount should be less than FEE_DENOMINATOR");
    require(
      getWithdrawalFee(kickstarter.projectGoals, fixFeeAmount, _percentageFeeAmount) <= kickstarter.projectGoals,
      "Withdrawal fee should not more than project goals"
    );

    percentageFeeAmount = _percentageFeeAmount;

    emit PercentageFeeAmountUpdated(_percentageFeeAmount);
  }

  function setFixFeeAmount(uint256 _fixFeeAmount) external onlyFactoryAdmin {
    require(
      getWithdrawalFee(kickstarter.projectGoals, _fixFeeAmount, percentageFeeAmount) <= kickstarter.projectGoals,
      "Withdrawal fee should not more than project goals"
    );

    fixFeeAmount = _fixFeeAmount;

    emit FixFeeAmountUpdated(_fixFeeAmount);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: UNLICENSED
// Developed by: dxsoftware.net

pragma solidity 0.8.6;

import "../../structs/KickstarterInfo.sol";

interface ISummitKickstarterFactory {
  function owner() external view returns (address);

  function isAdmin(address _address) external view returns (bool);

  function projects() external view returns (address[] memory);

  function userProjects(address _address) external view returns (address[] memory);

  function serviceFee() external view returns (uint256);

  function createProject(Kickstarter calldata kickstarter) external payable;

  function getProjects() external view returns (address[] memory);

  function getProjectsOf(address _walletAddress) external view returns (address[] memory);

  function setAdmins(address[] calldata _walletAddress, bool _isAdmin) external;

  function withdraw(address _receiver) external;

  function setServiceFee(uint256 _serviceFee) external;
}

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

enum ApprovalStatus {
  PENDING,
  APPROVED,
  REJECTED
}

struct Kickstarter {
  IERC20 paymentToken;
  string title;
  string creator;
  string imageUrl;
  string projectDescription;
  string rewardDescription;
  uint256 minContribution;
  uint256 projectGoals;
  uint256 rewardDistributionTimestamp;
  uint256 startTimestamp;
  uint256 endTimestamp;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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