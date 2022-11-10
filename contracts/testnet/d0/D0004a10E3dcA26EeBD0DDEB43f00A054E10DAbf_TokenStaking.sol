/**
 *Submitted for verification at BscScan.com on 2022-10-31
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address newOwner) {
        _setOwner(newOwner);
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
        _setOwner(address(0));
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
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

contract TokenStaking is Ownable {
    using SafeMath for uint256;
    IERC20 public token;
    uint256 public depositeTax = 0;
    uint256 public unStakeTax = 20;
    uint256 devTax = 10;
    address public treasuryWallet;
    address public devWallet;
    address marketingWallet;

    constructor() Ownable(msg.sender) {
        treasuryWallet = 0x68e1b506f5211D4913fCef18Ba19d64908111A77;
        devWallet = 0x1Fb0C631dF78c4Bb723e293D04d687bc0cEfc869;
        marketingWallet = 0xE99650448Fa274c929cfCC45dC283986E23f4c73;
        token = IERC20(0xF56e11E82E886317538716C635677529C1A0603D);
    }

    function addToken(address _token) public onlyOwner {
        token = IERC20(_token);
    }

    function setTax(uint256 withdrawfees, uint256 dipositefees)
        public
        onlyOwner
    {
        require(
            withdrawfees >= 0 && withdrawfees <= 20,
            "you can set withdraw fees maximum 20 %"
        );
        require(
            dipositefees >= 0 && dipositefees <= 20,
            "you can set diposite fees maximum 20 %"
        );
        depositeTax = dipositefees;
        unStakeTax = withdrawfees;
    }

    function getContractBalacne() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function setWallet(address _treasury, address _devWallet) public onlyOwner {
        require(
            _treasury != address(0),
            "treasury address is the zero address."
        );
        require(
            _devWallet != address(0),
            "devWallet address is the zero address."
        );
        treasuryWallet = _treasury;
        devWallet = _devWallet;
    }

    struct deposite {
        uint256 amount;
        uint256 depositeTime;
    }
    struct boost {
        address userAddress;
        uint256 ratePerDay;
        uint256 boostCount;
        uint256 boostTime;
    }

    struct user {
        boost boostlaval;
        deposite[] deposites;
        address refferaladdress;
        uint256 refferReward;
        uint256 userStoreReward;
        uint256 timeForCalculateReward;
        uint256 withdrawReward;
        uint256 lastWithdrawReward;
    }
    mapping(address => user) public investment;

    function invest(uint256 _amount, address refferAddress) public {
        user storage users = investment[msg.sender];
        require(_amount > 0, "Please enter greater then value");
        require(
            _amount <= token.allowance(msg.sender, address(this)),
            "Insufficient Allowence to the contract"
        );
        uint256 tax = _amount.mul(devTax).div(100);
        token.transferFrom(msg.sender, devWallet, tax.div(3));
        token.transferFrom(msg.sender, treasuryWallet, tax.div(3));
        token.transferFrom(msg.sender, marketingWallet, tax.div(3));
        token.transferFrom(msg.sender, address(this), _amount.sub(tax));
        if (refferAddress == address(0) || refferAddress == msg.sender) {
            investment[msg.sender].refferaladdress = treasuryWallet;
        } else {
            investment[msg.sender].refferaladdress = refferAddress;
        }
        if (users.boostlaval.userAddress != msg.sender) {
            users.boostlaval.ratePerDay = 100;
            users.boostlaval.userAddress = msg.sender;
        } else {
            users.userStoreReward += calculateReward(msg.sender);
        }
        users.deposites.push(deposite(_amount, block.timestamp));
        users.timeForCalculateReward = block.timestamp;

        if (
            block.timestamp + 5 minutes - users.boostlaval.boostTime > 5 minutes
        ) {
            users.boostlaval.boostTime = 0;
            users.boostlaval.boostCount = 0;
            users.boostlaval.ratePerDay = 100;
        } else if (
            (users.boostlaval.boostTime != 0) &&
            (block.timestamp + 5 minutes - users.boostlaval.boostTime) <
            5 minutes
        ) {
            users.boostlaval.boostTime = 0;
            users.boostlaval.boostCount = 0;
            users.boostlaval.ratePerDay = 100;
        }
    }

    function booster(uint256 boostAmount) public {
        user storage users = investment[msg.sender];
        require(
            boostAmount <= token.allowance(msg.sender, address(this)),
            "Insufficient Allowence to the contract"
        );
        require(
            users.boostlaval.userAddress == msg.sender,
            "please invest first then you can booster earning"
        );
        require(
            users.boostlaval.boostCount < 6,
            "Not enough the boost chance."
        );

        uint256 depositAmount = getUserdipositAddamount(msg.sender);
        if (depositAmount > 0 ether && depositAmount <= 40 ether) {
            require(
                boostAmount >= 1 ether,
                "Please enter the minimum value 1 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            users.timeForCalculateReward = block.timestamp;
            if (users.boostlaval.boostTime + 5 minutes > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            }
        } else if (depositAmount > 40 ether && depositAmount <= 80 ether) {
            require(
                boostAmount >= 2 ether,
                "Please enter the minimum value 2 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            users.timeForCalculateReward = block.timestamp;
            if (users.boostlaval.boostTime + 5 minutes > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            }
        } else if (depositAmount > 80 ether && depositAmount <= 120 ether) {
            require(
                boostAmount >= 3 ether,
                "Please enter the minimum value 3 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            users.timeForCalculateReward = block.timestamp;
            if (users.boostlaval.boostTime + 5 minutes > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            }
        } else if (depositAmount > 120 ether && depositAmount <= 160 ether) {
            require(
                boostAmount >= 4 ether,
                "Please enter the minimum value 4 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            users.timeForCalculateReward = block.timestamp;
            if (users.boostlaval.boostTime + 5 minutes > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            }
        } else if (depositAmount > 160 ether) {
            require(
                boostAmount >= 5 ether,
                "Please enter the minimum value 5 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            users.timeForCalculateReward = block.timestamp;
            if (users.boostlaval.boostTime + 5 minutes > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostTime = block.timestamp + 5 minutes;
            }
        }
    }

    function remove(uint256 index) internal {
        for (
            uint256 i = index;
            i < investment[msg.sender].deposites.length - 1;
            i++
        ) {
            investment[msg.sender].deposites[i] = investment[msg.sender]
                .deposites[i + 1];
        }
        investment[msg.sender].deposites.pop();
    }

    function withdrawToken(uint256 id) public {
        uint256 duration = block.timestamp -
            investment[msg.sender].timeForCalculateReward;
        require(duration >= 10 minutes, "Please wait sometime ");
        require(id <= investment[msg.sender].deposites.length, "Invalid Id");
        uint256 totalAmount = investment[msg.sender].deposites[id].amount;
        investment[msg.sender].userStoreReward += calculateReward(msg.sender);
        uint256 withdrawTax = totalAmount.mul(unStakeTax).div(100);
        token.transfer(treasuryWallet, withdrawTax.div(2));
        token.transfer(address(this), withdrawTax.div(2));
        token.transfer(msg.sender, totalAmount.sub(withdrawTax));
        remove(id);
        investment[msg.sender].timeForCalculateReward = block.timestamp;
    }

    function compound() public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp -
            investment[msg.sender].timeForCalculateReward;
        require(duration >= 10 minutes, "Please wait sometime");
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards found");
        uint256 treasuryTax = reward.mul(10).div(100);
        token.transfer(treasuryWallet, treasuryTax);
        users.deposites.push(deposite(reward.sub(treasuryTax), block.timestamp));
        investment[msg.sender].timeForCalculateReward = block.timestamp;
        investment[msg.sender].lastWithdrawReward = block.timestamp;
        users.userStoreReward = 0;
        if (
            block.timestamp + 5 minutes - users.boostlaval.boostTime > 5 minutes
        ) {
            users.boostlaval.boostTime = 0;
            users.boostlaval.boostCount = 0;
            users.boostlaval.ratePerDay = 100;
        } else if (
            (users.boostlaval.boostTime != 0) &&
            (block.timestamp + 5 minutes - users.boostlaval.boostTime) <
            5 minutes
        ) {
            users.boostlaval.boostTime = 0;
            users.boostlaval.boostCount = 0;
            users.boostlaval.ratePerDay = 100;
        }
    }

    function claimReward(address _refferraladdress) public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp -
            investment[msg.sender].timeForCalculateReward;
        require(duration >= 10 minutes, "Please wait sometime");
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards found");
        uint256 treasuryTax = reward.mul(10).div(100);
        uint256 refferTax = reward.mul(5).div(100);
        uint256 leftReward = reward.sub(treasuryTax).sub(refferTax);
        token.transfer(treasuryWallet, treasuryTax);
        token.transfer(users.refferaladdress, leftReward);
        investment[_refferraladdress].refferReward += refferTax;
        token.transfer(msg.sender, leftReward);
        investment[msg.sender].withdrawReward += leftReward;
        investment[msg.sender].lastWithdrawReward = block.timestamp;
        investment[msg.sender].timeForCalculateReward = block.timestamp;
        users.userStoreReward = 0;
        if (
            block.timestamp + 5 minutes - users.boostlaval.boostTime > 5 minutes
        ) {
            users.boostlaval.boostTime = 0;
            users.boostlaval.boostCount = 0;
            users.boostlaval.ratePerDay = 100;
        } else if (
            (users.boostlaval.boostTime != 0) &&
            (block.timestamp + 5 minutes - users.boostlaval.boostTime) <
            5 minutes
        ) {
            users.boostlaval.boostTime = 0;
            users.boostlaval.boostCount = 0;
            users.boostlaval.ratePerDay = 100;
        }
    }

    function withdrawRefferalReward() public {
        uint256 totalRefferReward = investment[msg.sender].refferReward;
        require(totalRefferReward > 0, "No refferal rewards found");
        token.transfer(msg.sender, totalRefferReward);
        investment[msg.sender].withdrawReward += totalRefferReward;
        investment[msg.sender].refferReward = 0;
    }

    function reStakeRefferalReward() public {
        user storage users = investment[msg.sender];
        uint256 totalRefferReward = investment[msg.sender].refferReward;
        require(totalRefferReward > 0, "No refferal rewards found");
        investment[msg.sender].deposites.push(
            deposite(totalRefferReward, block.timestamp)
        );
        if (users.boostlaval.userAddress != msg.sender) {
            users.boostlaval.ratePerDay = 100;
            users.boostlaval.userAddress = msg.sender;
            users.timeForCalculateReward = block.timestamp;
        }
        investment[msg.sender].refferReward = 0;
    }

    function getUserdipositAddamount(address _user)
        public
        view
        returns (uint256)
    {
        user memory users = investment[_user];
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < users.deposites.length; i++) {
            totalAmount += users.deposites[i].amount;
        }

        return totalAmount;
    }

    function calculateReward(address _user) public view returns (uint256) {
        user memory users = investment[_user];
        uint256 storeReward = users.userStoreReward;
        uint256 boostedReward = 0;
        uint256 normalReward = 0;

        uint256 depositTimestamp = users.timeForCalculateReward;
        uint256 boostTimestamp = users.boostlaval.boostTime;

        if (users.boostlaval.boostTime == 0) {
            uint256 normalRewardDuration = block.timestamp - depositTimestamp;
            normalReward = getUserdipositAddamount(_user)
                .mul(100)
                .mul(normalRewardDuration)
                .div(1 days);
            normalReward = normalReward.div(10000);
        } else if ((block.timestamp + 5 minutes - boostTimestamp) < 5 minutes) {
            uint256 boostRewardtime = block.timestamp +
                5 minutes -
                boostTimestamp;
            boostedReward = getUserdipositAddamount(_user)
                .mul(users.boostlaval.ratePerDay)
                .mul(boostRewardtime)
                .div(1 days);
            boostedReward = boostedReward.div(10000);
        } else if (block.timestamp + 5 minutes - boostTimestamp > 5 minutes) {
            uint256 normalRewardtime = block.timestamp - boostTimestamp;
            boostedReward = getUserdipositAddamount(_user)
                .mul(users.boostlaval.ratePerDay)
                .mul(5 minutes)
                .div(1 days);
            boostedReward = boostedReward.div(10000);
            normalReward = getUserdipositAddamount(_user)
                .mul(100)
                .mul(normalRewardtime)
                .div(1 days);
            normalReward = normalReward.div(10000);
        }
        return (boostedReward + normalReward + storeReward);
    }

    function minimumWithdrawDuration(address _user)
        public
        view
        returns (uint256)
    {
        uint256 check15days = investment[_user].timeForCalculateReward +
            10 minutes;
        return check15days;
    }

    function userRefferAddress(address _user) public view returns (address) {
        return investment[_user].refferaladdress;
    }

    function getUserTotalRefferalRewards(address _user)
        public
        view
        returns (uint256)
    {
        return investment[_user].refferReward;
    }

    function getUserTotalWithdrawRewards(address _user)
        public
        view
        returns (uint256)
    {
        return investment[_user].withdrawReward;
    }

    function getUserlastWithdrawRewardTime(address _user)
        public
        view
        returns (uint256)
    {
        return investment[_user].lastWithdrawReward;
    }

    function getUserDepositeHistory(address _user)
        public
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256[] memory amount = new uint256[](
            investment[_user].deposites.length
        );
        uint256[] memory time = new uint256[](
            investment[_user].deposites.length
        );
        for (uint256 i = 0; i < investment[_user].deposites.length; i++) {
            amount[i] = investment[_user].deposites[i].amount;
            time[i] = investment[_user].deposites[i].depositeTime;
        }
        return (amount, time);
    }

    function currentRate(address _user) public view returns (uint256) {
        return investment[_user].boostlaval.ratePerDay;
    }
}