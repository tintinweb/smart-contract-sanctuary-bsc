// SPDX-License-Identifier: Unlisenced
// Developed by: dxsoftware.net

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SummitKickstarter.sol";

pragma solidity ^0.8.6;

contract SummitKickstarterFactory is Ownable {
  address[] public projects;
  mapping(address => address[]) public userProjects;

  uint256 public serviceFee;

  event ProjectCreated(
    address indexed _owner,
    address indexed _projectAddress,
    string _title,
    string _creator,
    string _projectDescription,
    string _rewardDescription,
    uint256 _minContribution,
    uint256 _projectGoals,
    uint256 _rewardDistributionTimestamp,
    uint256 _startTimestamp,
    uint256 _endTimestamp,
    uint256 timestamp
  );

  constructor(uint256 _serviceFee) {
    serviceFee = _serviceFee;
  }

  receive() external payable {}

  function createProject(
    string memory _title,
    string memory _creator,
    string memory _projectDescription,
    string memory _rewardDescription,
    uint256 _minContribution,
    uint256 _projectGoals,
    uint256 _rewardDistributionTimestamp,
    uint256 _startTimestamp,
    uint256 _endTimestamp
  ) external payable {
    require(msg.value >= serviceFee, "Service Fee is not enough");
    refundExcessiveFee();

    SummitKickstarter project = new SummitKickstarter(
      _msgSender(),
      _title,
      _creator,
      _projectDescription,
      _rewardDescription,
      _minContribution,
      _projectGoals,
      _rewardDistributionTimestamp,
      _startTimestamp,
      _endTimestamp
    );

    address projectAddress = address(project);

    projects.push(projectAddress);
    userProjects[_msgSender()].push(projectAddress);

    emit ProjectCreated(
      _msgSender(),
      projectAddress,
      _title,
      _creator,
      _projectDescription,
      _rewardDescription,
      _minContribution,
      _projectGoals,
      _rewardDistributionTimestamp,
      _startTimestamp,
      _endTimestamp,
      block.timestamp
    );
  }

  function getProjects() external view returns (address[] memory) {
    return projects;
  }

  function getProjectsOf(address _walletAddress) external view returns (address[] memory) {
    return userProjects[_walletAddress];
  }

  function refundExcessiveFee() internal virtual {
    uint256 refund = msg.value - serviceFee;
    if (refund > 0) {
      (bool success, ) = address(_msgSender()).call{value: refund}("");
      require(success, "Unable to refund excess Ether");
    }
  }

  // ** OWNER FUNCTIONS **

  function setServiceFee(uint256 _serviceFee) external onlyOwner {
    serviceFee = _serviceFee;
  }

  function withdraw(address _receiver) external onlyOwner {
    (bool success, ) = address(_receiver).call{value: address(this).balance}("");
    require(success, "Unable to withdraw Ether");
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

// SPDX-License-Identifier: MIT
// Developed by: dxsoftware.net

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SummitKickstarter is Ownable {
  mapping(address => uint256) public contributions;
  mapping(address => uint256) public contributorIndexes;

  address[] public contributors;

  uint256 public totalContribution;

  // ProjectInfo
  string public title;
  string public creator;
  string public projectDescription;
  string public rewardDescription;

  uint256 public minContribution;
  uint256 public projectGoals;

  uint256 public rewardDistributionTimestamp;
  uint256 public startTimestamp;
  uint256 public endTimestamp;

  bool public hasDistributedRewards = false;

  event Contribute(address indexed contributor, uint256 amount, uint256 timestamp);
  event Refund(address indexed contributor, uint256 amount, uint256 timestamp);

  constructor(
    address _owner,
    string memory _title,
    string memory _creator,
    string memory _projectDescription,
    string memory _rewardDescription,
    uint256 _minContribution,
    uint256 _projectGoals,
    uint256 _rewardDistributionTimestamp,
    uint256 _startTimestamp,
    uint256 _endTimestamp
  ) {
    transferOwnership(_owner);

    title = _title;
    creator = _creator;
    projectDescription = _projectDescription;
    rewardDescription = _rewardDescription;

    minContribution = _minContribution;
    projectGoals = _projectGoals;

    rewardDistributionTimestamp = _rewardDistributionTimestamp;
    startTimestamp = _startTimestamp;
    endTimestamp = _endTimestamp;
  }

  receive() external payable {}

  function setTitle(string memory _title) external onlyOwner {
    require(bytes(_title).length > 0, "Title cannot be empty");
    title = _title;
  }

  function setCreator(string memory _creator) external onlyOwner {
    require(bytes(_creator).length > 0, "Creator cannot be empty");
    creator = _creator;
  }

  function setProjectDescription(string memory _projectDescription) external onlyOwner {
    require(bytes(_projectDescription).length > 0, "Project description cannot be empty");
    projectDescription = _projectDescription;
  }

  function setRewardDescription(string memory _rewardDescription) external onlyOwner {
    require(bytes(_rewardDescription).length > 0, "Reward description cannot be empty");
    rewardDescription = _rewardDescription;
  }

  function setMinContribution(uint256 _minContribution) external onlyOwner {
    minContribution = _minContribution;
  }

  function setProjectGoals(uint256 _projectGoals) external onlyOwner {
    require(_projectGoals > 0, "Project goals must be greater than 0");
    projectGoals = _projectGoals;
  }

  function setRewardDistributionTimestamp(uint256 _rewardDistributionTimestamp) external onlyOwner {
    rewardDistributionTimestamp = _rewardDistributionTimestamp;
  }

  function setStartTimestamp(uint256 _startTimestamp) external onlyOwner {
    require(_startTimestamp < endTimestamp, "Start timestamp must be before end timestamp");
    startTimestamp = _startTimestamp;
  }

  function setEndTimestamp(uint256 _endTimestamp) external onlyOwner {
    require(_endTimestamp > startTimestamp, "End timestamp must be after start timestamp");
    endTimestamp = _endTimestamp;
  }

  function setHasDistributedRewards(bool _hasDistributedRewards) external onlyOwner {
    hasDistributedRewards = _hasDistributedRewards;
  }

  function configProjectInfo(
    string memory _title,
    string memory _creator,
    string memory _projectDescription,
    string memory _rewardDescription,
    uint256 _minContribution,
    uint256 _projectGoals,
    uint256 _rewardDistributionTimestamp,
    uint256 _startTimestamp,
    uint256 _endTimestamp
  ) external onlyOwner {
    title = _title;
    creator = _creator;
    projectDescription = _projectDescription;
    rewardDescription = _rewardDescription;

    minContribution = _minContribution;
    projectGoals = _projectGoals;

    rewardDistributionTimestamp = _rewardDistributionTimestamp;
    startTimestamp = _startTimestamp;
    endTimestamp = _endTimestamp;
  }

  function getContributors() external view returns (address[] memory) {
    return contributors;
  }

  function contribute() external payable {
    require(msg.value >= minContribution, "Contribution must be greater than or equal to minContribution");
    require(block.timestamp >= startTimestamp, "You can contribute only after start time");
    require(block.timestamp <= endTimestamp, "You can contribute only before end time");

    totalContribution += msg.value;

    contributions[msg.sender] += msg.value;
    contributorIndexes[msg.sender] = contributors.length;
    contributors.push(msg.sender);

    emit Contribute(msg.sender, msg.value, block.timestamp);
  }

  function refund(address _contributor, uint256 _amount) external onlyOwner {
    require(contributions[_contributor] >= _amount, "You cannot refund more than you have contributed");
    require(address(this).balance >= _amount, "You cannot withdraw more than you have");

    totalContribution -= _amount;
    contributions[_contributor] -= _amount;

    if (contributions[_contributor] == 0) {
      removeContributor(_contributor);
    }

    payable(_contributor).transfer(_amount);
    emit Refund(_contributor, _amount, block.timestamp);
  }

  function withdrawBNB(uint256 _amount, address _receiver) external onlyOwner {
    require(address(this).balance >= _amount, "You cannot withdraw more than you have");

    payable(_receiver).transfer(_amount);
  }

  function removeContributor(address _address) private {
    uint256 index = contributorIndexes[_address];
    if (contributors[index] == _address) {
      contributorIndexes[_address] = 0;

      uint256 lastIndex = contributors.length - 1;
      address lastContributor = contributors[lastIndex];

      contributors[index] = lastContributor;
      contributorIndexes[lastContributor] = index == lastIndex ? 0 : index;
      contributors.pop();
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