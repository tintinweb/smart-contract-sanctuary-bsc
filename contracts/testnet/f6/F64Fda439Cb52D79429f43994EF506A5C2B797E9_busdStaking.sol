// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract busdStaking is Ownable {
    address public Owner;
    IERC20 token;
    uint256 public minimumDeposit;
    uint256 public maxDeposit;
    address public marketAddress;
    address public developerAddress;
    uint256 public lotteryAmount;
    uint256 public TVLDropLimit;
    bool public stopclaiming;
    uint256 public accomulationCutoff;
    uint256 public lockedPeriod;
    uint256 public timePeriod;
    uint256 public TeamNonce;
    uint256 public deployeTime;
    address internal zeroAddress;
    uint256 internal lotteryTime;
    uint256[] internal totalNonce;
    uint256 public lotteryNonce;

    constructor() {
        token = IERC20(0x3E3dd26c2cf50f2b7E5AaB86B0eb916502034c13);
        Owner = msg.sender;
        minimumDeposit = 50 * 10**token.decimals();
        maxDeposit = 100_000 * 10**token.decimals();
        TVLDropLimit = 5000 * 10**token.decimals();
        accomulationCutoff = 10 minutes;
        lockedPeriod = 15 minutes;
        timePeriod = 7 minutes;
        TeamNonce = 1;
        lotteryNonce=1;
        deployeTime = block.timestamp;
        zeroAddress = address(0);
        lotteryTime = 7 minutes;
        marketAddress = (0x153B1f632596687e84D7b6fC0C4a2586cB0D5373);
        developerAddress = (0x153B1f632596687e84D7b6fC0C4a2586cB0D5373);
    }

    struct stakerINfo {
        uint256 amount;
        uint256 rewardIn7Days;
        uint256 rewadPerDay;
        uint256 startTime;
        uint256 totalReward;
        uint256[] claimedAt;
        uint256 profit_withdrawn;
        address upliner;
        bool timeStarted;
        bool isDeposit;
        bool stopReward;
        uint256 _teamNumber;
        uint256 bonusReward;
        
    }

    struct Teams {
        address _owner;
        uint256 teamDeposit;
        uint256 teamMembersCount;
        address[] teamMember;
        bool ivalidReferrel;
        // mapping(address =>_owner) _memberUpliner;
    }
    struct Lottery{
        address[] winerOwner;
        uint256[] winerNonce;
        uint256 lotteryNumber;
        bool isClaimLotteryReward;
        uint256 winerOwnerIndex;
        uint256 thisLotteryAmount;
    }
    mapping(uint256 => Lottery) public LotteryInfo;
    mapping(address => stakerINfo) stakes;
    // mapping(address=>address[]) public referrer ;
    // mapping(address=>Teams._owner) public _teamNonce;
    mapping(uint256 => Teams) public TeamInfo;
    mapping(address => Teams) public TeamInfoWithaddress;

    function stake(address _upliner, uint256 _amount) external {
        require(
            _amount >= minimumDeposit,
            "You cannot deposit below minimum amount"
        );
        require(
            _amount <= maxDeposit,
            "You cannot deposit greater than maxDeposit amout"
        );
        require(_upliner != msg.sender, "You cannot refer yourself");
        uint256 refferalAmount = (_amount * 15) / 1000;

        if (
            (stakes[_upliner].isDeposit || _upliner == Owner) &&
            _upliner != address(0) &&
            TeamInfo[TeamNonce]._owner == address(0)
        ) {
            if (Owner == _upliner) {
                token.transfer(Owner, refferalAmount);
                stakes[msg.sender].upliner = Owner;
            } else {
                TeamInfo[TeamNonce]._owner = _upliner;
                TeamInfo[TeamNonce].teamDeposit += _amount;
                TeamInfo[TeamNonce].teamMembersCount++;
                TeamInfo[TeamNonce].teamMember.push(msg.sender);
                stakes[msg.sender]._teamNumber = TeamNonce;
                token.transfer(_upliner, refferalAmount);
                totalNonce.push(TeamNonce);
                TeamNonce++;
            }
        } else {
            uint256 teamNumber = stakes[msg.sender]._teamNumber;
            if (TeamInfo[teamNumber]._owner == _upliner) {
                TeamInfo[teamNumber].teamDeposit += _amount;
                TeamInfo[teamNumber].teamMembersCount++;
                TeamInfo[teamNumber].teamMember.push(msg.sender);
                TeamInfo[teamNumber].ivalidReferrel = true;
                token.transfer(_upliner, refferalAmount);
            }
            require(
                TeamInfo[teamNumber].ivalidReferrel == true,
                "Invalid referrel! if you don't want TO make anyone referrel than pass owner address=0x153B1f632596687e84D7b6fC0C4a2586cB0D5373"
            );
        }
        TeamInfo[stakes[msg.sender]._teamNumber].ivalidReferrel == false;

        uint256 TeamNumber = stakes[msg.sender]._teamNumber;

        if (
            TeamInfo[TeamNumber].teamMember.length >= 10 &&
            TeamInfo[TeamNumber].teamDeposit >= 5_000
        ) {
            uint256 rewardAmount = (_amount * 1) / 1000;
            for (
                uint256 i = 1;
                i <= TeamInfo[TeamNumber].teamMember.length;
                i++
            ) {
                address member = TeamInfo[TeamNumber].teamMember[i];
                stakes[member].rewadPerDay += rewardAmount;
            }
        }
        if (
            TeamInfo[TeamNumber].teamMember.length >= 20 &&
            TeamInfo[TeamNumber].teamDeposit >= 10_000
        ) {
            uint256 rewardAmount = (_amount * 2) / 1000;
            for (
                uint256 i = 1;
                i <= TeamInfo[TeamNumber].teamMember.length;
                i++
            ) {
                address member = TeamInfo[TeamNumber].teamMember[i];
                stakes[member].rewadPerDay += rewardAmount;
            }
        }
        if (
            TeamInfo[TeamNumber].teamMember.length >= 30 &&
            TeamInfo[TeamNumber].teamDeposit >= 15_000
        ) {
            uint256 rewardAmount = (_amount * 3) / 1000;
            for (
                uint256 i = 1;
                i <= TeamInfo[TeamNumber].teamMember.length;
                i++
            ) {
                address member = TeamInfo[TeamNumber].teamMember[i];
                stakes[member].rewadPerDay += rewardAmount;
            }
        }
        if (
            TeamInfo[TeamNumber].teamMember.length >= 40 &&
            TeamInfo[TeamNumber].teamDeposit >= 20_000
        ) {
            uint256 rewardAmount = (_amount * 4) / 1000;
            for (
                uint256 i = 1;
                i <= TeamInfo[TeamNumber].teamMember.length;
                i++
            ) {
                address member = TeamInfo[TeamNumber].teamMember[i];
                stakes[member].rewadPerDay += rewardAmount;
            }
        }
        if (
            TeamInfo[TeamNumber].teamMember.length >= 50 &&
            TeamInfo[TeamNumber].teamDeposit >= 25_000
        ) {
            uint256 rewardAmount = (_amount * 5) / 1000;
            for (
                uint256 i = 1;
                i <= TeamInfo[TeamNumber].teamMember.length;
                i++
            ) {
                address member = TeamInfo[TeamNumber].teamMember[i];
                stakes[member].rewadPerDay += rewardAmount;
            }
        }
        if (
            TeamInfo[TeamNumber].teamMember.length >= 60 &&
            TeamInfo[TeamNumber].teamDeposit >= 30_000
        ) {
            uint256 rewardAmount = (_amount * 6) / 1000;
            for (
                uint256 i = 1;
                i <= TeamInfo[TeamNumber].teamMember.length;
                i++
            ) {
                address member = TeamInfo[TeamNumber].teamMember[i];
                stakes[member].rewadPerDay += rewardAmount;
            }
        }
        if (
            TeamInfo[TeamNumber].teamMember.length >= 70 &&
            TeamInfo[TeamNumber].teamDeposit >= 35_000
        ) {
            uint256 rewardAmount = (_amount * 7) / 1000;
            for (
                uint256 i = 1;
                i <= TeamInfo[TeamNumber].teamMember.length;
                i++
            ) {
                address member = TeamInfo[TeamNumber].teamMember[i];
                stakes[member].rewadPerDay += rewardAmount;
            }
        }
        if (
            TeamInfo[TeamNumber].teamMember.length >= 80 &&
            TeamInfo[TeamNumber].teamDeposit >= 40_000
        ) {
            uint256 rewardAmount = (_amount * 8) / 1000;
            for (
                uint256 i = 1;
                i <= TeamInfo[TeamNumber].teamMember.length;
                i++
            ) {
                address member = TeamInfo[TeamNumber].teamMember[i];
                stakes[member].rewadPerDay += rewardAmount;
            }
        }
        uint256 marketFee = (_amount * 30) / 1000;
        uint256 devFee = (_amount * 30) / 1000;
        uint256 ownerFee = (_amount * 30) / 1000;
        uint256 lotteryFee = (_amount * 10) / 1000;
        uint256 amount = _amount -
           (marketFee + devFee + ownerFee + lotteryFee + refferalAmount);
        token.transferFrom(msg.sender, marketAddress, marketFee);
        token.transferFrom(msg.sender, developerAddress, devFee);
        token.transferFrom(msg.sender, Owner, ownerFee);
        token.transfer(address(this), lotteryFee);
        lotteryAmount += lotteryFee;

        token.transfer(address(this), amount);
        stakes[msg.sender].startTime = block.timestamp;
        stakes[msg.sender].timeStarted = true;
        stakes[msg.sender].isDeposit = true;
        stakes[msg.sender].stopReward = false;
        stakes[msg.sender].claimedAt.push(block.timestamp);
        stakes[msg.sender].amount = (_amount);
        stakes[msg.sender].rewadPerDay = (_amount * 10) / 1000;
        stakes[msg.sender].rewardIn7Days = (stakes[msg.sender].rewadPerDay * 7);
    }

    function enableClaiming() external onlyOwner {
        stopclaiming = false;
    }

    function claimReward() external {
        require(
            stakes[msg.sender].isDeposit == true,
            "You are not stake any amount"
        );
        if (token.balanceOf(address(this)) <= TVLDropLimit) {
            stopclaiming = true;
        }
        require(
            stopclaiming == false,
            "Contract balance is less than TVLDropLimit its work when enableClaiming function called by owner "
        );
        if (
            block.timestamp >= stakes[msg.sender].startTime + accomulationCutoff
        ) {
            stakes[msg.sender].stopReward = true;
        }
        require(
            stakes[msg.sender].stopReward == false,
            "Your reward is stop due to accomulation cutoff"
        );

        if (
            stakes[msg.sender].totalReward >=
            stakes[msg.sender].profit_withdrawn
        ) {
            require(
                block.timestamp - stakes[msg.sender].startTime >= timePeriod,
                "you trying to withdraw before 7 days "
            );
            uint256 timeCalculation = (block.timestamp -
                stakes[msg.sender].startTime) / timePeriod;
            uint256 _profit = stakes[msg.sender].rewardIn7Days *
                timeCalculation;
            _profit = _profit - stakes[msg.sender].profit_withdrawn;
            token.transferFrom(Owner, msg.sender, _profit);
            stakes[msg.sender].profit_withdrawn =
                stakes[msg.sender].profit_withdrawn +
                _profit;
        }
    }

    function ClaimStakingAmount() external {
        require(
            stakes[msg.sender].isDeposit == true,
            "You are not stake any amount"
        );
        require(
            block.timestamp >= stakes[msg.sender].startTime + lockedPeriod,
            "You cannot unlock before lock period"
        );
        token.transfer(msg.sender, stakes[msg.sender].amount);
        stakes[msg.sender].amount = 0;
    }



   function runLottery() external onlyOwner returns (uint256 LotteryWiner,address WinerTeamOwner) {
        require(
            block.timestamp >= block.timestamp - deployeTime / lotteryTime,
            "You cannot run lottery before Time"
        );
        uint256 winer;
        for (uint256 i = 1; i <= totalNonce.length; i++) {
            uint256 nonce = totalNonce[i];
            uint256 lastnonce = totalNonce[i - 1];
            if (TeamInfo[nonce].teamDeposit > TeamInfo[lastnonce].teamDeposit) {
                winer = nonce;
            }
        }

        deployeTime = block.timestamp;
        address winerTeamOwner=TeamInfo[winer]._owner;
        LotteryInfo[lotteryNonce].winerOwner.push(winerTeamOwner);
        LotteryInfo[lotteryNonce].winerOwnerIndex = LotteryInfo[lotteryNonce].winerOwner.length-1;
        LotteryInfo[lotteryNonce].winerNonce.push(winer);
        LotteryInfo[lotteryNonce].thisLotteryAmount=lotteryAmount;
        LotteryInfo[lotteryNonce].lotteryNumber=lotteryNonce;
        lotteryNonce ++;
        lotteryAmount=0;
        return (winer,winerTeamOwner);
    
    }

    function claimLotteryRewad() external {
       uint256 isMember=stakes[msg.sender]._teamNumber;
       uint256 index= LotteryInfo[lotteryNonce - 1].winerOwnerIndex;
       uint256 _thisLotteryAmount=LotteryInfo[lotteryNonce - 1].thisLotteryAmount;
       require(LotteryInfo[lotteryNonce-1].isClaimLotteryReward==false,"You already claim rewad!");
       require(TeamInfo[isMember]._owner == LotteryInfo[lotteryNonce - 1].winerOwner[index] ,"You are not winer team member");
       uint256 rewardCalculate =   (stakes[msg.sender].amount * 100) / TeamInfo[isMember].teamDeposit ;
       uint256 rewardtoSend =  (_thisLotteryAmount * rewardCalculate ) /100;
       token.transfer(address(this), rewardtoSend);
       LotteryInfo[lotteryNonce-1].isClaimLotteryReward=true;

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