/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-07
 */

// SPDX-License-Identifier: UNLICENCED
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity 0.8.16;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

// File: contracts/UniswapV2ERC20.sol

abstract contract Context {
    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns(bytes calldata) {
        return msg.data;
    }
}

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
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer { }

    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns(bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address public _owner;

    event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns(address) {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    uint256[49] private __gap;
}

contract Cryptopump is ContextUpgradeable, OwnableUpgradeable {
    using SafeMath for uint256;

        struct UserStruct {
        bool isExist;
        uint256 id;
        uint256 referrerID;
        uint256 currentLevel;
        uint256 totalEarningEth;
        address[] referral;
    }

    address public ownerAddress;
    uint256 public adminFee;
    uint256 public currentId;
    uint256 referrer1Limit;
    bool public lockStatus;

    uint256 public totalAmount;
    uint256 public adminEarn;

    mapping(uint256 => uint256) public LEVEL_PRICE;
    mapping(address => UserStruct) public users;
    mapping(uint256 => address) public userList;
    mapping(address => mapping(uint256 => uint256)) public EarnedEth;
    mapping(address => uint256) public loopCheck;
    mapping(address => uint256) public createdDate;

    event regLevelEvent(address indexed UserAddress, address indexed ReferrerAddress, uint256 Time);
    event buyLevelEvent(address indexed UserAddress, uint256 Levelno, uint256 Time);
    event getMoneyForLevelEvent(address indexed UserAddress, uint256 UserId, address indexed ReferrerAddress, uint256 ReferrerId, uint256 Levelno, uint256 LevelPrice, uint256 Time, uint256 Adminfee);
    event lostMoneyForLevelEvent(address indexed UserAddress, uint256 UserId, address indexed ReferrerAddress, uint256 ReferrerId, uint256 Levelno, uint256 LevelPrice, uint256 Time, uint256 Adminfee);

    function initialize(address _ownerAddress) public initializer {
        ownerAddress = _ownerAddress;

        adminFee = 10 ether; //10 %
        referrer1Limit = 2;
        totalAmount = 0;
        adminEarn = 0;

        LEVEL_PRICE[1] = 0.0000001 ether;
        LEVEL_PRICE[2] = 0.0000002 ether;
        LEVEL_PRICE[3] = 0.0000003 ether;
        LEVEL_PRICE[4] = 0.0000004 ether;
        LEVEL_PRICE[5] = 0.0000005 ether;

        UserStruct storage userStruct = users[_ownerAddress];
        currentId++;

        userStruct.isExist = true;
        userStruct.id = currentId;
        userStruct.referrerID = 0;
        userStruct.currentLevel = 5;
        userStruct.totalEarningEth = 0;
        userStruct.referral = new address[](0);

        userList[currentId] = _ownerAddress;

        loopCheck[_ownerAddress] = 0;
        createdDate[_ownerAddress] = block.timestamp;

        __Ownable_init();
    }

    /**
     * @dev User registration
     */
    function regUser(uint256 _referrerID) external payable {
        require(lockStatus == false, "Contract Locked");
        require(users[msg.sender].isExist == false, "User exist");
        require(
            _referrerID > 0 && _referrerID <= currentId,
            "Incorrect referrer Id"
        );
        require(msg.value == LEVEL_PRICE[1], "Incorrect Value");

        if (users[userList[_referrerID]].referral.length >= referrer1Limit)
            _referrerID = users[findFreeReferrer(userList[_referrerID])].id;

        currentId++;
        UserStruct storage userStruct = users[msg.sender];
        userStruct.isExist = true;
        userStruct.id = currentId;
        userStruct.referrerID = _referrerID;
        userStruct.currentLevel = 1;
        userStruct.totalEarningEth = 0;
        userStruct.referral = new address[](0);

        userList[currentId] = msg.sender;
        users[userList[_referrerID]].referral.push(msg.sender);
        loopCheck[msg.sender] = 0;
        createdDate[msg.sender] = block.timestamp;

        payForLevel(
            0,
            1,
            msg.sender,
            ((LEVEL_PRICE[1].mul(adminFee)).div(10 ** 20)),
            msg.value
        );

        emit regLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
    }

    /**
     * @dev To buy the next level by User
     */
    function buyLevel(uint256 _level) external payable {
        require(lockStatus == false, "Contract Locked");
        require(users[msg.sender].isExist, "User not exist");
        require(_level > 0 && _level <= 5, "Incorrect level");

        if (_level == 1) {
            require(msg.value == LEVEL_PRICE[1], "Incorrect Value");
            users[msg.sender].currentLevel = 1;
        } else {
            require(msg.value == LEVEL_PRICE[_level], "Incorrect Value");
            uint256 nextlevel = users[msg.sender].currentLevel.add(1);
            require(nextlevel == _level, "Already  purchased");
            require(nextlevel == _level, "Incorrect level");
            users[msg.sender].currentLevel = _level;
        }
        loopCheck[msg.sender] = 0;

        payForLevel(0, _level, msg.sender, ((LEVEL_PRICE[_level].mul(adminFee)).div(10 ** 20)), msg.value);

        emit buyLevelEvent(msg.sender, _level, block.timestamp);
    }

    /**
     * @dev Internal function for payment
     */
    function payForLevel(uint256 _flag, uint256 _level, address _userAddress, uint256 _adminPrice, uint256 _amt) internal {
        address[5] memory referer;

        if (_flag == 0) {
            if (_level == 1) {
                referer[0] = userList[users[_userAddress].referrerID];
            } else if (_level == 2) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[0] = userList[users[referer[1]].referrerID];
            } else if (_level == 3) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[2] = userList[users[referer[1]].referrerID];
                referer[0] = userList[users[referer[2]].referrerID];
            } else if (_level == 4) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[2] = userList[users[referer[1]].referrerID];
                referer[3] = userList[users[referer[2]].referrerID];
                referer[0] = userList[users[referer[3]].referrerID];
            } else if (_level == 5) {
                referer[1] = userList[users[_userAddress].referrerID];
                referer[2] = userList[users[referer[1]].referrerID];
                referer[3] = userList[users[referer[2]].referrerID];
                referer[4] = userList[users[referer[3]].referrerID];
                referer[0] = userList[users[referer[4]].referrerID];
            }
        } else if (_flag == 1) {
            referer[0] = userList[users[_userAddress].referrerID];
        }
        if (!users[referer[0]].isExist) referer[0] = userList[1];

        if (loopCheck[msg.sender] >= 5) {
            referer[0] = userList[1];
        }
        if (users[referer[0]].currentLevel >= _level) {
            payable(referer[0]).transfer(LEVEL_PRICE[_level].sub(_adminPrice));
            payable(ownerAddress).transfer(_adminPrice);
            totalAmount = totalAmount.add(LEVEL_PRICE[_level]);
            adminEarn = adminEarn.add(_adminPrice);
            users[referer[0]].totalEarningEth = users[referer[0]].totalEarningEth.add(LEVEL_PRICE[_level]);
            EarnedEth[referer[0]][_level] = EarnedEth[referer[0]][_level].add(LEVEL_PRICE[_level]);
            emit getMoneyForLevelEvent(msg.sender, users[msg.sender].id, referer[0], users[referer[0]].id, _level, LEVEL_PRICE[_level], block.timestamp, _adminPrice);
        } else {
            if (loopCheck[msg.sender] < 5) {
                loopCheck[msg.sender] = loopCheck[msg.sender].add(1);
                emit lostMoneyForLevelEvent(msg.sender, users[msg.sender].id, referer[0], users[referer[0]].id, _level, LEVEL_PRICE[_level], block.timestamp, _adminPrice);
                payForLevel(1, _level, referer[0], _adminPrice, _amt);
            }
        }
    }

    /**
     * @dev Contract balance withdraw
     */
    function failSafe(address payable _toUser, uint256 _amount) public returns(bool)
    {
        require(msg.sender == ownerAddress, "only Owner Wallet");
        require(_toUser != address(0), "Invalid Address");
        require(address(this).balance >= _amount, "Insufficient balance");

        (_toUser).transfer(_amount);
        return true;
    }

    /**
     * @dev Update admin fee percentage
     */
    function updateFeePercentage(uint256 _adminFee) public returns(bool) {
        require(msg.sender == ownerAddress, "only OwnerWallet");

        adminFee = _adminFee;
        return true;
    }

    /**
     * @dev Update admin address
     */
    function changeAdmin(address _ownerAddress) public returns(bool) {
        require(msg.sender == ownerAddress, "only OwnerWallet");
        ownerAddress = _ownerAddress;
        return true;
    }

    /**
     * @dev Update level price
     */
    function updatePrice(uint256 _level, uint256 _price) public returns(bool) {
        require(msg.sender == ownerAddress, "only OwnerWallet");

        LEVEL_PRICE[_level] = _price;
        return true;
    }

    /**
     * @dev Update contract status
     */
    function contractLock(bool _lockStatus) public returns(bool) {
        require(msg.sender == ownerAddress, "only OwnerWallet");

        lockStatus = _lockStatus;
        return true;
    }

    /**
     * @dev View free Referrer Address
     */
    function findFreeReferrer(address _userAddress) public view returns(address)
    {
        if (users[_userAddress].referral.length < referrer1Limit)
            return _userAddress;

        address[] memory referrals = new address[](500);
        referrals[0] = users[_userAddress].referral[0];
        referrals[1] = users[_userAddress].referral[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 500; i++) {
            if (users[referrals[i]].referral.length == referrer1Limit) {
                referrals[(i + 1) * 2] = users[referrals[i]].referral[0];
                referrals[(i + 1) * 2 + 1] = users[referrals[i]].referral[1];
            } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }
        require(!noFreeReferrer, "No Free Referrer");
        return freeReferrer;
    }

    /**
     * @dev View referrals
     */
    function viewUserReferral(address _userAddress)external view returns(address[] memory)
    {
        return users[_userAddress].referral;
    }

    // fallback
    fallback() external payable {
        revert("Invalid Transaction");
    }

}