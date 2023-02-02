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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IRoxulExpressBasic {
    struct ShrinkWinner {
        uint256 countLevel;
        uint256 levelLastCompression;
        uint256 random;
        uint256 balance;
        uint256 countWinner;
        uint256 countGamer;
        uint256 countClaimReward;
    }

   
    event BuyNewPlace(
        address indexed user,
        address indexed referrer,
        uint256 level,
        uint256 place
    );

    event Shrink(
        address indexed user,
        uint256 shrinkId
    );

    event ClaimShrinkReward(
        address indexed user,
        uint256 shrinkId,
        uint256 amount

    );
    


    function buyNewPlace(address userAddress, address refAddress, uint256 typeRef) external payable;

    function withdrawLostTokens() external returns (bool);

    function claimShrinkReward(address userAddress, uint256 countShrink) external returns(bool);

    function setTimeStart(uint256 _time) external;

    function setLocked(bool _lock) external;

    function setEventTable(bool _eventTable) external;

    // function paymentID(uint256 level) external view returns (uint256 pay_id);

    // function levelReport(uint256 level) external view returns (uint256 paid, uint256 onwait);

    // function AllLevelReport() external view returns (uint256[] memory);

    // function ReferrerIncome(address _user) external view returns (uint256[] memory);

    // function getContractBalance() external view returns (uint256);

    // function usersactiveMainLevels(address userAddress, uint256 level) external view returns (bool);

    // function allLevelUserCount() external view returns (uint256[] memory);

    // function TotalLevelUserCount(uint256 level) external view returns (uint256 count);

    // function isBoughtLevel(address userAddress) external view returns (bool[] memory);

    // function UserRewards(address userAddress) external view returns (uint64[] memory);

    // function ProgressID(address userAddress) external view returns (uint64[] memory);

    // function UserLevelPlace(address userAddress) external view returns (uint256[] memory);

    // function totalIncome() external view returns (uint256 sum);

    // function timeToOpenLevel(uint256 level) external view returns (uint256 time);

    // function timeLeftToOpenLevel(uint256 level) external view returns (uint256 time);

    // function listOfLevelOpenTime() external view returns (uint256[] memory);

    // function userPaymentCount(address _user) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import './interface/IRoxulExpressBasic.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract RoxulExpress is IRoxulExpressBasic, Ownable {
    uint256 public countLevel = 0;
    uint256 public countPlace = 1;
    uint256 public levelCompression;
    uint256 public timeCompression;
    uint256 public timeLastLevel;
    uint256 public shrinkReward;
    uint256 public idShrink = 0;
    uint256 public timeStart;
    uint256 public lastUserId;
    uint256 public BasicPrice;

    bool locked;
    bool eventTable;

    mapping(uint256 => mapping(uint256 => address)) public levelTable;
    mapping(address => mapping(uint256 => uint256)) public userLevel;
    mapping(uint256 => ShrinkWinner) public idShrinkWinner;
    mapping(uint256 => mapping(address => bool)) public isClaimReward;

    mapping(uint256 => uint256) public levelPlaces;

    address public secWallet;
    address public eventWallet;

    uint256[] public paymentPercent;

    constructor(address _secWallet, uint256 _BasicPrice, address _eventWallet) {
        BasicPrice = _BasicPrice;

        secWallet = _secWallet;
        eventWallet = _eventWallet;

        paymentPercent.push((_BasicPrice * 13) / 100);
        paymentPercent.push((_BasicPrice * 8) / 100);
        paymentPercent.push((_BasicPrice * 5) / 100);
        paymentPercent.push((_BasicPrice * 13) / 100);
        paymentPercent.push((_BasicPrice * 17) / 100);
        paymentPercent.push((_BasicPrice * 26) / 100);

        locked = true;
    }

    function setTimeStart(uint256 _time) external override onlyOwner {
        timeStart = _time;
    }

    function setLocked(bool _lock) external override onlyOwner {
        locked = _lock;
    }

    function setEventTable(bool _eventTable) external override onlyOwner {
        eventTable = _eventTable;
    }

    function buyNewPlace(
        address userAddress,
        address refAddress,
        uint256 typeRef
    ) external payable override onlyOwner {
        require(block.timestamp > timeStart, 'Table is locked');
        require(!locked, 'Table is locked');
        if (countLevel > 0) {
            require(!(userLevel[userAddress][countLevel - 1] > 0), 'User at the previous level');
        }
        require(!(userLevel[userAddress][countLevel] > 0), 'User at the level');

        
        levelPlaces[countLevel] = countPlace;
        levelTable[countLevel][countPlace] = userAddress;
        userLevel[userAddress][countLevel] = countPlace;
        sendDividends(countLevel);
        payReferrer(refAddress, typeRef);

        emit BuyNewPlace(userAddress, refAddress, countLevel, countPlace);

        countPlace++;
        
        if (
            (countLevel - levelCompression < 7) ||
            (block.timestamp < timeLastLevel + timeCompression)
        ) {
            if (countPlace > 2 ** (countLevel - levelCompression)) {
                countLevel++;
                countPlace = 1;
                timeCompression = ((block.timestamp - timeLastLevel) * 25) / 10;
                timeLastLevel = block.timestamp;
            }
        } else {
            uint256 countGamer = 2 ** (countLevel - levelCompression - 1) +
                (levelPlaces[countLevel]) /
                2;

            uint256 countWinner = countGamer % 100 > 0 ? countGamer / 100 + 1 : countGamer / 100;
            uint256 randomPlace = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));

            ShrinkWinner storage winner = idShrinkWinner[idShrink];
            winner.balance = shrinkReward;
            winner.countLevel = countLevel;
            winner.levelLastCompression = levelCompression;
            winner.countGamer = countGamer;
            winner.random = randomPlace;
            winner.countWinner = countWinner;
            shrinkReward = 0;
            levelCompression = countLevel + 1;

            if (!eventTable) {
                countLevel++;
                countPlace = 1;
                timeCompression = ((block.timestamp - timeLastLevel) * 25) / 10;
                timeLastLevel = block.timestamp;
                levelPlaces[countLevel] = countPlace;
                levelTable[countLevel][countPlace] = userAddress;
                userLevel[userAddress][countLevel] = countPlace;
                emit BuyNewPlace(userAddress, refAddress, countLevel, countPlace);
            } else {
                countPlace = 1;
                locked = true;
            }
            countLevel++;
            emit Shrink(userAddress, idShrink);
            idShrink++;

        }
        
    }

    function sendDividends(uint256 level) internal returns (bool success) {
        address userSend = ((level - levelCompression) < 1)
            ? secWallet
            : levelTable[level - 1][(countPlace + 1) / 2];
        uint256 mainPercent = (BasicPrice * 72) / 100;
        (success, ) = (userSend).call{value: mainPercent}('');
        (success, ) = (eventWallet).call{value: BasicPrice / 100}('');
        shrinkReward += BasicPrice / 100;
        return success;
    }

    function withdrawLostTokens() public override onlyOwner returns (bool) {
        uint256 conbalance = address(this).balance;

        (bool success, ) = (secWallet).call{value: conbalance}('');

        return success;
    }

    function payReferrer(
        address referalAddress,
        uint256 typeRef
    ) internal returns (bool success) {
        if (referalAddress != address(secWallet)) {
            if (typeRef < 1) {
                uint256 countPay = countLevel - levelCompression < 3 ? countLevel - levelCompression : 3;
                uint256 unpaidRef = 0;
                for (uint256 index = 1; index < countPay + 1; index++) {
                    if (userLevel[referalAddress][countLevel - index] > 0) {
                        unpaidRef += paymentPercent[index - 1];
                        (success, ) = referalAddress.call{value: paymentPercent[index - 1]}('');
                    }                    
                }
                (success, ) = secWallet.call{value: BasicPrice * 26 / 100 - unpaidRef}('');
            } else {
                (success, ) = referalAddress.call{value: paymentPercent[2 + typeRef]}('');
                (success, ) = secWallet.call{
                    value: ((BasicPrice * 26) / 100 - paymentPercent[2 + typeRef])
                }('');
            }
        } else {
            (success, ) = secWallet.call{value: (BasicPrice * 26) / 100}('');
        }

        return success;
    }

    function claimShrinkReward(address userAddress, uint256 countShrink) external onlyOwner returns(bool success) {
        ShrinkWinner storage winner = idShrinkWinner[countShrink];
        require(!isClaimReward[countShrink][userAddress], 'User Alredy claimed reward!!!');
        // require((winner.countClaimReward < winner.countWinner), 'All Alredy claim reward!!!');
        require(checkWinner(userAddress, winner.countLevel, winner.levelLastCompression, winner.countGamer, winner.countWinner, winner.random), 'User don`t winner');
        (success, ) = (userAddress).call{value: winner.balance / winner.countWinner}('');
        isClaimReward[countShrink][userAddress] = true;
        winner.countClaimReward++;
        if (winner.countClaimReward > winner.countWinner - 1) {
            winner.balance = 0;
        }

        return success;
    }

    function checkWinner(
        address userAddress,
        uint256 level,
        uint256 levelLastComp,
        uint256 countGamer,
        uint256 countWinner,
        uint256 rand
    ) public view returns (bool success) {
        uint256 levelUser;

        if (userLevel[userAddress][level] > 0) {
            levelUser = level;
        } else if (userLevel[userAddress][level- 1] > (levelPlaces[level]) / 2)  {
            levelUser = level- 1;
        } else {
            return false;
        }

        uint256 step = countGamer / countWinner;

        uint256 random = rand % step;

        if (level- levelLastComp - 1 == levelUser ) {
            
            uint256 placeUser = userLevel[userAddress][levelUser] - (levelPlaces[levelUser + 1]) / 2 - 1;

            if( placeUser >= random) {
                success =
                    (placeUser - random)  % step == 0;
            }else {
                success = false;
            }
        } else {
            uint256 placeUser = 2 ** (level- levelLastComp - 1) +
                                userLevel[userAddress][levelUser] -
                                (levelPlaces[levelUser]) / 2 - 1;

            if( placeUser >= random) {
                success = (placeUser - random) % step == 0;
            }else {
                success = false;
            }
            
        }

        return success;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

}