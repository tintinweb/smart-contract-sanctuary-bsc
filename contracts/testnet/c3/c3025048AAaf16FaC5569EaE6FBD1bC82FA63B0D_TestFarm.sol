// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//    _____                       ______                   
//   / ___/____  ____ _________  / ____/___ __________ ___ 
//   \__ \/ __ \/ __ `/ ___/ _ \/ /_  / __ `/ ___/ __ `__ \
//  ___/ / /_/ / /_/ / /__/  __/ __/ / /_/ / /  / / / / / /
// /____/ .___/\__,_/\___/\___/_/    \__,_/_/  /_/ /_/ /_/ 
//     /_/                                                 

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

struct User {
    uint256 startDate;
    uint256 divs;
    uint256 totalInits;
    uint256 totalWiths;
    uint256 lastWith;
    uint256 keyCounter;
    uint256 userMax;
    Depo[] depoList;
    address referrer;
    uint256 bonus;
    uint256 totalBonus;
    uint[3] levels;
}
struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 amt;
    address reffy;
    bool initialWithdrawn;
}
struct Main {
    uint256 users;
    uint256 compounds;
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
}
struct DivPercs {
    uint256 daysInSeconds;
    uint256 divsPercentage;
    uint256 feePercentage;
    uint256 feePercentageVip;
}
struct VIP {
    bool member;
}

contract TestFarm is Context, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    // uint256 constant firstlaunch = 1664600400; //fixed to October 1st, 2022
    // uint256 constant secondlaunch = 1664686800; //fixed to October 2nd, 2022
    uint256 constant hardDays = 1 days;
    uint256 constant percentdiv = 1000;
    uint256 constant maxRewards = 2000 ether;
    uint8[] refPercentage = [50, 30, 20];
    uint256 devPercentage = 100;

    uint256 private lastDepositTimeStep = 2 hours;
    uint256 private lastBuyCurrentRound = 1;
    uint256 private lastDepositPoolBalance;
    uint256 private lastDepositLastDrawAction;
    address private lastDepositPotentialWinner;

    address private previousPoolWinner;
    uint256 private previousPoolRewards;

    uint256 private dateLaunched;
    bool private lastDepositEnabled = true;

    mapping(address => User) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping(uint256 => Main) public MainKey;
    mapping(address => VIP) public WhiteList;

    event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
    event Reinvested(address indexed user, uint256 amount);
	event WithdrawnInitial(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
    event LastBuyPayout(uint256 indexed round, address indexed addr, uint256 amount, uint256 timestamp);

    IERC20 private BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    address private immutable dApp;
    address private immutable devOwner;

    constructor(address _devOwner) {
        dateLaunched = block.timestamp;
        
        PercsKey[10] = DivPercs(10 days, 10, 300, 100); // (Unstake Days, Earned Percent, Unstake Fee, Unstake Fee VIP)
        PercsKey[20] = DivPercs(20 days, 10, 280, 90);
        PercsKey[30] = DivPercs(30 days, 20, 260, 80);
        PercsKey[40] = DivPercs(40 days, 30, 240, 70);
        PercsKey[50] = DivPercs(50 days, 40, 220, 60);
        PercsKey[60] = DivPercs(60 days, 50,  200, 50);
        PercsKey[70] = DivPercs(70 days, 60, 180, 40);
        PercsKey[80] = DivPercs(80 days, 70, 160, 30);
        PercsKey[90] = DivPercs(90 days, 80, 140, 20);
        PercsKey[100] = DivPercs(100 days, 90, 120, 10);
        PercsKey[110] = DivPercs(100 days, 100, 100, 0);

        dApp = msg.sender;
        devOwner = _devOwner;
    }

    function UserInfo() external view returns (Depo[] memory depoList) {
        User storage user = UsersKey[msg.sender];

        return (user.depoList);
    }

    function Stake(uint256 amtx, address ref) public payable {
        // require(block.timestamp >= secondlaunch || WhiteList[msg.sender].member == true, "You are not part of whitelist");
        // require(block.timestamp >= firstlaunch, "App did not launch yet.");
        require(ref != msg.sender, "You cannot refer yourself!");

        BUSD.safeTransferFrom(msg.sender, address(this), amtx);

        User storage user = UsersKey[msg.sender];
        User storage userRef = UsersKey[ref];
        Main storage main = MainKey[1];

        if (user.lastWith == 0) {
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }

        uint256 stakeFee = amtx.mul(devPercentage).div(percentdiv);
        uint256 adjustedAmt  = amtx.sub(stakeFee); 

        user.userMax += adjustedAmt * 3;
        user.totalInits += adjustedAmt;

        if (user.referrer == address(0) && msg.sender != devOwner) {
            if(userRef.depoList.length == 0){
                ref = devOwner;
            }
			user.referrer = ref;
			address upline = user.referrer;
			for (uint256 i = 0; i < refPercentage.length; i++) {
				if (upline != address(0)) {
                    UsersKey[upline].levels[i] = UsersKey[upline].levels[i].add(1);
                    upline = UsersKey[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < refPercentage.length; i++) {
				if (upline == address(0)) {
				    upline = devOwner;
				}
                uint256 amount = adjustedAmt.mul(refPercentage[i]).div(percentdiv);
				UsersKey[upline].bonus = UsersKey[upline].bonus.add(amount);
				UsersKey[upline].totalBonus = UsersKey[upline].totalBonus.add(amount);
				upline = UsersKey[upline].referrer;
			}
		}

        user.depoList.push(
            Depo({
                key: user.depoList.length,
                depoTime: block.timestamp,
                amt: adjustedAmt,
                reffy: ref,
                initialWithdrawn: false
            })
        );

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.users += 1;

        BUSD.safeTransfer(devOwner, stakeFee);

        drawLastDepositWinner();
        poolLastDeposit(msg.sender, adjustedAmt);
        
        emit RefBonus(ref, msg.sender, adjustedAmt);
        emit NewDeposit(msg.sender, adjustedAmt);
    }

    function Unstake(uint256 key) public {

        User storage user = UsersKey[msg.sender];
        VIP storage vip = WhiteList[msg.sender];
        Main storage main = MainKey[1];

        if (user.depoList[key].initialWithdrawn) revert("This user stake is already forfeited.");  
        
        uint256 dailyReturn;
        uint256 transferAmt;
        uint256 amount = user.depoList[key].amt;
        uint256 elapsedTime = block.timestamp.sub(user.depoList[key].depoTime);
        
        if (elapsedTime <= PercsKey[10].daysInSeconds){
            dailyReturn = amount.mul(PercsKey[10].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ? 
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[10].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[10].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[10].daysInSeconds && elapsedTime <= PercsKey[20].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[20].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ? 
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[20].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[20].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[20].daysInSeconds && elapsedTime <= PercsKey[30].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[30].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ? 
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[30].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[30].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[30].daysInSeconds && elapsedTime <= PercsKey[40].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[40].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ? 
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[40].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[40].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[40].daysInSeconds && elapsedTime <= PercsKey[50].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[50].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ?
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[50].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[50].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[50].daysInSeconds && elapsedTime <= PercsKey[60].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[60].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ?
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[60].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[60].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[60].daysInSeconds && elapsedTime <= PercsKey[70].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[70].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ? 
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[70].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[70].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[70].daysInSeconds && elapsedTime <= PercsKey[80].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[80].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ? 
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[80].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[80].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[80].daysInSeconds && elapsedTime <= PercsKey[90].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[90].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ? 
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[90].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[90].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[90].daysInSeconds && elapsedTime <= PercsKey[100].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[100].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ?
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[100].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[100].feePercentage).div(percentdiv));
        } else if (elapsedTime > PercsKey[110].daysInSeconds){
          	dailyReturn = amount.mul(PercsKey[110].divsPercentage).div(percentdiv);
            transferAmt = vip.member == true ? 
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[110].feePercentageVip).div(percentdiv)) :
                amount + (dailyReturn.mul(elapsedTime).div(hardDays)) - (amount.mul(PercsKey[110].feePercentage).div(percentdiv));
        } else {
            revert("Cannot calculate user's staked days.");
        }

        BUSD.safeTransfer(msg.sender, transferAmt);
        main.ovrTotalWiths += amount;
        user.totalInits -= amount;
        user.depoList[key].amt = 0;
        user.depoList[key].initialWithdrawn = true;
        user.depoList[key].depoTime = block.timestamp;
        
		emit WithdrawnInitial(msg.sender, transferAmt);
    }

    function Compound() public {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        uint256 y = CalculateEarnings(msg.sender);

        for (uint256 i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].initialWithdrawn == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        user.depoList.push(
            Depo({
                key: user.keyCounter,
                depoTime: block.timestamp,
                amt: y,
                reffy: 0x000000000000000000000000000000000000dEaD,
                initialWithdrawn: false
            })
        );

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.compounds += 1;
        user.lastWith = block.timestamp;
    }

    function Collect() public returns (uint256 withdrawAmount) {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        require(user.userMax > user.totalWiths);

        uint256 x = CalculateEarnings(msg.sender);

        for (uint256 i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].initialWithdrawn == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        if (x + user.totalWiths > user.userMax) {
            x = user.userMax - user.totalWiths;
            user.totalWiths = user.totalWiths + x;
            for (uint256 i = 0; i < user.depoList.length; i++) {
                if (user.depoList[i].initialWithdrawn == false) {
                    user.depoList[i].initialWithdrawn = true;
                }
            }
        }

        main.ovrTotalWiths += x;
        user.totalWiths += x;
        user.lastWith = block.timestamp;

        BUSD.safeTransfer(msg.sender, x);

        emit Withdrawn(msg.sender, x);

        return x;
    }

    function TakeRef() public {
        User storage user = UsersKey[msg.sender];

        uint totalAmount = UsersKey[msg.sender].bonus;

		require(totalAmount > 0, "User has no dividends");
        user.bonus = 0;

        BUSD.safeTransfer(msg.sender, totalAmount);
    }

    function StakeRef() public {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        require(user.bonus > 10);

        uint256 refferalAmount = user.bonus;
        user.bonus = 0;

        address ref = 0x000000000000000000000000000000000000dEaD;

        user.depoList.push(
            Depo({
                key: user.keyCounter,
                depoTime: block.timestamp,
                amt: refferalAmount,
                reffy: ref,
                initialWithdrawn: false
            })
        );

        user.userMax += refferalAmount * 3;
        user.keyCounter += 1;
        main.ovrTotalDeps += 1;

        emit Reinvested(msg.sender, user.bonus);
    }

    function CalculateEarnings(address dy) public view returns (uint256) {
        User storage user = UsersKey[dy];	

        uint256 totalWithdrawable;
        
        for (uint256 i = 0; i < user.depoList.length; i++){	
            uint256 elapsedTime = block.timestamp.sub(user.depoList[i].depoTime);
            uint256 amount = user.depoList[i].amt;

            if (user.depoList[i].initialWithdrawn == false){

                if (elapsedTime <= PercsKey[10].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[10].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[10].daysInSeconds && elapsedTime <= PercsKey[20].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[20].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[20].daysInSeconds && elapsedTime <= PercsKey[30].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[30].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[30].daysInSeconds && elapsedTime <= PercsKey[40].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[40].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[40].daysInSeconds && elapsedTime <= PercsKey[50].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[50].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[50].daysInSeconds && elapsedTime <= PercsKey[60].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[60].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[60].daysInSeconds && elapsedTime <= PercsKey[70].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[70].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[70].daysInSeconds && elapsedTime <= PercsKey[80].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[80].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[80].daysInSeconds && elapsedTime <= PercsKey[90].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[90].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[90].daysInSeconds && elapsedTime <= PercsKey[100].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[100].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
                if (elapsedTime > PercsKey[110].daysInSeconds){
                    totalWithdrawable += (amount.mul(PercsKey[110].divsPercentage).div(percentdiv)).mul(elapsedTime).div(hardDays);
                }
            } 
        }
        return totalWithdrawable;
    }

    function JoinVIP() public payable {
        VIP storage vip = WhiteList[msg.sender];

        // Requires that the current time is after the Whitelist launch date.
        // require(
        //     block.timestamp < firstlaunch,
        //     "You can only join VIP before the VIP launch"
        // );

        require(vip.member == false, "You already have VIP!");
        require(msg.value == 0.1 ether, "VIP launch price is 0.1 BNB");

        payable(devOwner).transfer(msg.value);
        vip.member = true;
    }

    function addVIP (address vipAddy) public onlyOwner {
        // require(block.timestamp < firstlaunch);

        VIP storage vip = WhiteList[vipAddy];
        vip.member = true;
    }

    function switchLastDepositEventStatus() external onlyOwner {
        drawLastDepositWinner();
        lastDepositEnabled = !lastDepositEnabled ? true : false;
        if(lastDepositEnabled) lastDepositLastDrawAction = block.timestamp; // reset the start time everytime feature is enabled.
    }

    function poolLastDeposit(address userAddress, uint256 amount) private {
        if(!lastDepositEnabled) return;

        uint256 poolShare = amount.mul(10).div(percentdiv);

        lastDepositPoolBalance = lastDepositPoolBalance.add(poolShare) > maxRewards ? 
        lastDepositPoolBalance.add(maxRewards.sub(lastDepositPoolBalance)) : lastDepositPoolBalance.add(poolShare);
        lastDepositPotentialWinner = userAddress;
        lastDepositLastDrawAction  = block.timestamp;
    } 

    function drawLastDepositWinner() public {
        if(lastDepositEnabled && block.timestamp.sub(lastDepositLastDrawAction) >= lastDepositTimeStep && lastDepositPotentialWinner != address(0)) {
                        
            uint256 devStakeFee  = lastDepositPoolBalance.mul(devPercentage).div(percentdiv); 
            uint256 adjustedAmt  = lastDepositPoolBalance.sub(devStakeFee);
            BUSD.safeTransfer(lastDepositPotentialWinner, adjustedAmt);
            emit LastBuyPayout(lastBuyCurrentRound, lastDepositPotentialWinner, adjustedAmt, block.timestamp);

            previousPoolWinner         = lastDepositPotentialWinner;
            previousPoolRewards        = adjustedAmt;
            lastDepositPoolBalance     = 0;
            lastDepositPotentialWinner = address(0);
            lastDepositLastDrawAction  = block.timestamp; 
            lastBuyCurrentRound++;
        }
    }

    function lastDepositInfo() view external returns(uint256 currentRound, uint256 currentBalance, uint256 currentStartTime, uint256 currentStep, address currentPotentialWinner, uint256 previousReward, address previousWinner) {
        currentRound = lastBuyCurrentRound;
        currentBalance = lastDepositPoolBalance;
        currentStartTime = lastDepositLastDrawAction;  
        currentStep = lastDepositTimeStep;    
        currentPotentialWinner = lastDepositPotentialWinner;
        previousReward = previousPoolRewards;
        previousWinner = previousPoolWinner;
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}