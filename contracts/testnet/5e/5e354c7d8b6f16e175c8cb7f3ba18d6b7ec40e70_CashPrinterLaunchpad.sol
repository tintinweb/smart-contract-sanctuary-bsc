/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity 0.8.9;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity 0.8.9;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract CashPrinterLaunchpad is Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string public name;
    uint256 public maxCap;
    uint256 public saleStart;
    uint256 public saleEnd;
    uint256 public totalTokenReceivedInallLevel;
    uint256 public noOfLevels;
    uint256 public totalUsers;
    address public projectOwner;
    address public igoTokenAddress;
    address public paidTokenAddress;
    IERC20 public ERC20Interface_paid;
    IERC20 public ERC20Interface_IGO;
    uint256 public priceRate = 10000;
    uint256 public claimPeriod = 5 minutes;
    bool public claimable;

    struct Level {
        uint256 maxLevelCap;
        uint256 minUserCap;
        uint256 maxUserCap;
        uint256 amountRaised;
        uint256 users;
        uint8 claimPercent;
    }

    struct user {
        uint256 level;
        uint256 investedAmount;
        uint256 firstClaimTime;
        bool bought;
        bool claimed;
    }

    event UserInvestment (
        address indexed user,
        uint256 amount
    );

    event UserClaimed ( 
        address indexed user, 
        uint256 tokenAmount);

    event Redeem (
        address indexed user, 
        uint256 tokenAmount);

    mapping(uint256 => Level) public levelDetails;
    mapping(address => user) public userDetails;

    constructor(
        string memory _name,
        uint256 _maxCap,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _noOfLevels,
        address _projectOwner,
        address _igoTokenAddress,
        address _paidTokenAddress,
        uint256 _totalUsers
    ) {
        name = _name;
        require(_maxCap > 0, "Zero max cap");
        maxCap = _maxCap;
        require(
            _saleStart >  block.timestamp && _saleEnd > _saleStart, "Invalid timings"
        );
        saleStart = _saleStart;
        saleEnd = _saleEnd;
        require(_noOfLevels > 0, "Zero tiers");
        noOfLevels = _noOfLevels;
        require(_projectOwner != address(0), "Zero project owner address");
        projectOwner = _projectOwner;
        require(_igoTokenAddress != address(0), "Zero token address");
        require(_paidTokenAddress != address(0), "Zero token address");
        igoTokenAddress = _igoTokenAddress;
        paidTokenAddress = _paidTokenAddress;
        ERC20Interface_paid = IERC20(paidTokenAddress);
        ERC20Interface_IGO = IERC20(igoTokenAddress);
        require(_totalUsers > 0, "Zero users");
        totalUsers = _totalUsers;
    }

    function updateMaxCap(uint256 _maxCap) public onlyOwner {
        require(_maxCap > 0, "Zero max cap");
        maxCap = _maxCap;
    }

    function updateStartTime(uint256 newsaleStart) public onlyOwner {
        require(block.timestamp < saleStart, "Sale already started");
        saleStart = newsaleStart;
    }

    function updateClaimStatus(bool _claimable) public onlyOwner {
        claimable = _claimable;
    }

    function updateEndTime(uint256 newSaleEnd) public onlyOwner {
        require(
            newSaleEnd > saleStart && newSaleEnd > block.timestamp,
            "Sale end can't be less than sale start"
        );
        saleEnd = newSaleEnd;
    }

    function updateTokenAddress(address _paidTokenAddress, address _igoTokenAddress) public onlyOwner {
        require(_igoTokenAddress != address(0), "Zero token address");
        require(_paidTokenAddress != address(0), "Zero token address");
        igoTokenAddress = _igoTokenAddress;
        paidTokenAddress = _paidTokenAddress;
        ERC20Interface_paid = IERC20(paidTokenAddress);
        ERC20Interface_IGO = IERC20(igoTokenAddress);
    }

    function updateTotalUsers(uint256 _totalUsers) public onlyOwner {
        require(_totalUsers > 0, "Zero users");
        totalUsers = _totalUsers;
    } 

    function updatePriceRateAndClaimPeriod(uint8  _priceRate, uint256  _claimPeriod) public onlyOwner {
        require(_priceRate > 0, "Zero Rate");
        priceRate = _priceRate;
        require(_claimPeriod > 0, "Zero claimPeriod");
        _claimPeriod = _claimPeriod;
    }

    function updateProjectOwnerAddress(address _projectOwner) public onlyOwner {
        projectOwner = _projectOwner;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function updateLevels(
        uint256[] memory _level,
        uint256[] memory _maxLevelCap,
        uint256[] memory _minUserCap,
        uint256[] memory _maxUserCap,
        uint256[] memory _levelUsers,
        uint8[] memory _levelclaimPercent
    ) external onlyOwner {
        require(
            _level.length == _maxLevelCap.length &&
                _maxLevelCap.length == _minUserCap.length &&
                _minUserCap.length == _maxUserCap.length &&
                _maxUserCap.length == _levelUsers.length &&
                _levelclaimPercent.length == _levelUsers.length,
            "Lengths mismatch"
        );

        for (uint256 i = 0; i < _level.length; i++) {
            require(
                _level[i] > 0 && _level[i] <= noOfLevels,
                "Invalid level number"
            );
            require(_maxLevelCap[i] > 0, "Invalid max level cap amount");
            require(_maxUserCap[i] > 0, "Invalid max user cap amount");
            require(_levelUsers[i] > 0, "Zero users in level");
            levelDetails[_level[i]] = Level(
                _maxLevelCap[i],
                _minUserCap[i],
                _maxUserCap[i],
                0,
                _levelUsers[i],
                _levelclaimPercent[i]
            );
        }
    }

    function updateUsers(address[] memory _users, uint256[] memory _levels)
        external
        onlyOwner
    {
        require(_users.length == _levels.length, "Array length mismatch");
        for (uint256 i = 0; i < _users.length; i++) {
            require(_levels[i] > 0 && _levels[i] <= noOfLevels, "Invalid level");
            userDetails[_users[i]].level = _levels[i];
        }
    }

    function buyTokens(uint256 amount)
        external
        whenNotPaused
        _hasAllowance(msg.sender, amount)
        returns (bool)
    {
        require(block.timestamp >= saleStart, "Sale not started yet");
        require(block.timestamp <= saleEnd, "Sale Ended");
        require(
            totalTokenReceivedInallLevel.add(amount) <= maxCap,
            "Exceeds pool max cap"
        );
        uint256 userLevel = userDetails[msg.sender].level;
        require(userLevel > 0 && userLevel <= noOfLevels, "User not whitelisted");
        require(
            amount >= levelDetails[userLevel].minUserCap,
            "Amount less than user min cap"
        );
        require(
            amount <= levelDetails[userLevel].maxUserCap,
            "Amount greater than user max cap"
        );
        bool bought = userDetails[msg.sender].bought;
        require(bought == false, "User already bought");

        // require(
        //     amount <= levelDetails[userLevel].maxLevelCap,
        //     "Amount greater than the level max cap"
        // );

        totalTokenReceivedInallLevel = totalTokenReceivedInallLevel.add(amount);
        levelDetails[userLevel].amountRaised = levelDetails[userLevel]
            .amountRaised
            .add(amount);
        userDetails[msg.sender].investedAmount = amount;
        userDetails[msg.sender].bought = true;
        ERC20Interface_paid.safeTransferFrom(msg.sender, address(this), amount);
        emit UserInvestment(msg.sender, amount);
        return true;
    }

    function claim(uint256 amount)
        external
        returns (bool)
    {   
        require(claimable == true, "User can not claim yet"); 
        bool userClaimed = userDetails[msg.sender].claimed;
        require(userClaimed == false, "User have already claimed");
        uint256 userInvestedAmount = userDetails[msg.sender].investedAmount;
        uint256 userLevel = userDetails[msg.sender].level;
        uint256 userlevelClaimPercent = levelDetails[userLevel].claimPercent;
        uint256 claimableAmount = userInvestedAmount.mul(userlevelClaimPercent).div(100);
        require(claimableAmount >= amount, "User only can claim smaller amount than investedAmount");
        uint256 tokenAmount = amount.mul(priceRate).div(10000);
        require(
            ERC20Interface_IGO.balanceOf(address(this)) > tokenAmount,
            "No tokens available in the contract"
        );
        userDetails[msg.sender].claimed = true;
        userDetails[msg.sender].firstClaimTime = block.timestamp;
        userDetails[msg.sender].investedAmount = userDetails[msg.sender].investedAmount.sub(amount);
        ERC20Interface_IGO.safeTransfer(msg.sender, tokenAmount);
        emit UserClaimed(msg.sender, tokenAmount);
        return true;
    }

    function withdraw()
        external
        onlyOwner
        returns(bool)
    {
        require(msg.sender == projectOwner, "Caller should be project Owner");
        uint256 amount = ERC20Interface_paid.balanceOf(address(this));
        ERC20Interface_paid.safeTransfer(projectOwner, amount);
        return  true;
    }    

    function redeem()
        external
        returns(bool)
    {   
        bool userClaimed = userDetails[msg.sender].claimed;
        require(userClaimed == true, "User have not first claimed yet");
        uint256 userClaimedTime = userDetails[msg.sender].firstClaimTime;
        require (userClaimedTime + claimPeriod >= block.timestamp, "User does not redeem yet.");
        uint256 tokenAmount = userDetails[msg.sender].investedAmount.mul(priceRate).div(10000);
        require(
            ERC20Interface_IGO.balanceOf(address(this)) > tokenAmount,
            "No tokens available in the contract"
        );
        userDetails[msg.sender].investedAmount = 0;
        ERC20Interface_IGO.safeTransfer(msg.sender, tokenAmount);
        emit Redeem(msg.sender, tokenAmount);
        return true;
    }

    function finalize() 
        external
        onlyOwner 
    {
        claimable = false;
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = ERC20Interface_paid.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }
}