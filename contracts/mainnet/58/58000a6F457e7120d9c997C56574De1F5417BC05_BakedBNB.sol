/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT

/*
*    ██████╗  █████╗ ██╗  ██╗███████╗██████╗     ██████╗ ███╗   ██╗██████╗ 
*    ██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗    ██╔══██╗████╗  ██║██╔══██╗
*    ██████╔╝███████║█████╔╝ █████╗  ██║  ██║    ██████╔╝██╔██╗ ██║██████╔╝
*    ██╔══██╗██╔══██║██╔═██╗ ██╔══╝  ██║  ██║    ██╔══██╗██║╚██╗██║██╔══██╗
*    ██████╔╝██║  ██║██║  ██╗███████╗██████╔╝    ██████╔╝██║ ╚████║██████╔╝
*    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝     ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
*/                                                                      

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */ address private _manager;
    constructor() {
        _owner = msg.sender;
        _manager = msg.sender;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }
        function manager() internal view virtual returns (address) {
        return _manager;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
        modifier onlyManager() {
        require(manager() == msg.sender, "Ownable: ownership could not be transfered anymore");
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
    function transferOwnership(address newOwner) public virtual onlyManager {
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

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface ITimerPool {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function update(
        uint256 _amount,
        uint256 _time,
        address _user
    ) external;
}

contract BakedBNB is Ownable {
    uint256 public SECONDS_WORK_MINER = 1295000; 
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256 tax1 = 1;
    uint256 tax2 = 10;
    uint256 compound_for_claim = 6;
    uint256 BONUS_BNB = 1e17; // 0.1 BNB Bonus
    uint256 private mDep = 1e16;  // min dep 0.01BNB
    uint256 public Dop = 2e20; // tvl to 2000BNB 
    uint256 public countUsers = 0;
    uint256 public deals = 0;
    uint256 public volume = 0;

    bool public initialized = false;
    address public Developer; 
    
    ITimerPool public timer;

    struct User {
            address referrer;
            uint256 referrals;
            uint256 invest;
            bool l2;
            bool l3;
            bool l4;
            bool l5;
            bool l6;
            bool l7;
        }

    mapping(address => User) internal users;
    mapping(address => uint256) public usersMiner;
    mapping(address => uint256) public claimedTokens;
    mapping(address => uint256) public lastHatch;
    mapping(address => uint8) public compoundCounter;
    mapping(address => bool) public OneGetFree; 
    mapping(address => bool) public BUY_MINERS;

    uint256 public marketTokens;

    constructor(ITimerPool _timer) {
        Developer = msg.sender;
        timer = _timer;
    }

    function reinvest() public {
        require(initialized);

        uint256 tokensUsed = getMyTokens(msg.sender);

        uint256 bonus = tokensUsed * 5 / 100; // bonus
        uint256 newMiners = SafeMath.div((tokensUsed + bonus), SECONDS_WORK_MINER);

        usersMiner[msg.sender] = SafeMath.add(usersMiner[msg.sender], newMiners);
        if (lastHatch[msg.sender] + 1 days <= block.timestamp) {
            compoundCounter[msg.sender] = compoundCounter[msg.sender] + 1;
        }
        claimedTokens[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        deals +=1;
        marketTokens = SafeMath.add(marketTokens, SafeMath.div(tokensUsed, 5));
    }

    function claimRewards() public {
        require(initialized);
        require(lastHatch[msg.sender] + 1 days < block.timestamp, "You can do action every 24 hours");
        require(compoundCounter[msg.sender] >= compound_for_claim, "You need to reinvest 6 times to claim");

        User storage user = users[msg.sender];
        require(user.invest >= mDep);
        uint256 amountSell = calculateTokensSell(getMyTokens(msg.sender));
        amountSell = amountSell > getBalance() ? getBalance() : amountSell;
        uint256 fee = devFee(amountSell); // timer
        uint256 fee2 = devFee2(amountSell); // team
        claimedTokens[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        compoundCounter[msg.sender] = 0;
        marketTokens = SafeMath.add(marketTokens, getMyTokens(msg.sender));

        deals +=1;

        payable(address(timer)).transfer(fee);
        payable(Developer).transfer(fee2);
        payable(msg.sender).transfer(SafeMath.sub(amountSell, (fee + fee2)));
        usersMiner[msg.sender] = SafeMath.mul(SafeMath.div(usersMiner[msg.sender],100),95);
    }

    function buyMiners(address ref) payable public {
        require(initialized);
        require(msg.value >= 1e16, "Mininum investment is 0.01 BNB");

        countUsers += 1;
        deals +=1;
        volume += msg.value;
        BUY_MINERS[msg.sender] = true;
        
        User storage user = users[msg.sender];
        if (checkUser(msg.sender) == address(0)) {
            if (ref == msg.sender || ref == address(0) || usersMiner[ref] == 0) {
                user.referrer = Developer;
            } else {
                user.referrer = ref;
            }
        } else {
            user.referrer = checkUser(msg.sender);
        }
        
        uint256 balance = getBalance();
        uint256 tokensBought = calculateTokensBuy(msg.value, SafeMath.sub((balance + Dop), msg.value));

        user.invest += msg.value;

        tokensBought = SafeMath.sub(tokensBought, SafeMath.add(devFee(tokensBought), devFee2(tokensBought)));
        uint256 fee = devFee(msg.value);
        uint256 fee2 = devFee2(msg.value);
        
        payable(address(timer)).transfer(fee);
        timer.update(fee, block.timestamp, msg.sender);

        payable(Developer).transfer(fee2);
        claimedTokens[msg.sender] = SafeMath.add(claimedTokens[msg.sender], tokensBought);

        if (user.referrer != address(0)) {
            payable(address(user.referrer)).transfer(msg.value * 12 / 100);

            reinvest();
    
            if (Dop <= msg.value) {
                Dop = 0;
            }
            else {
                Dop -= msg.value;
            }
        }
    }  

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public view returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt))
            );
    }

    function calculateTokensSell(uint256 tokens) public view returns (uint256) {
        return calculateTrade(tokens, marketTokens, getBalance());
    }

    function calculateTokensBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketTokens);
    }

    function calculateTokensBuySimple(uint256 eth) public view returns (uint256) {
        return calculateTokensBuy(eth, getBalance());
    }

    function devFee(uint256 amount) public view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, tax1), 100); //timer
    }

    function devFee2(uint256 amount) public view returns (uint256) { //Developer
        return SafeMath.div(SafeMath.mul(amount, tax2), 100);
    }

    function seedMarket() public payable {
        require(msg.sender == Developer, "invalid call");
        require(marketTokens == 0);
        initialized = true;
        marketTokens = 333000000000;
    }

    function fundContract() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners(address user) public view returns (uint256) {
        return usersMiner[user];
    }

    function MyReward(address user) public view returns (uint256) {
        return calculateTokensSell(getMyTokens(user));
    }

    function getMyTokens(address user) public view returns (uint256) {
        return SafeMath.add(claimedTokens[user], getTokensSinceLastHatch(user));
    }

    function Giveaway(address _account, uint256 _amount) external onlyOwner {
        claimedTokens[_account] = claimedTokens[_account] + _amount;
    }

    function getTokensSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(SECONDS_WORK_MINER, SafeMath.sub(block.timestamp, lastHatch[adr]));
        return SafeMath.mul(secondsPassed, usersMiner[adr]);
    }

    function checkUser(address userAddr) public view returns (address ref) {
        return users[userAddr].referrer;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function setTax1(uint256 _value) onlyOwner external {
        require(_value <= 10);
        tax1 = _value;
    }

    function setTax2(uint256 _value) external onlyOwner {
        require(_value <= 10);
        tax2 = _value;
    }

    function setCompoundForClaim(uint256 _value) external onlyOwner {
        require(_value <= 12);
        compound_for_claim = _value;
    }

    function Change_Developer(address _newDeveloper) external {
        require(msg.sender == Developer);
        Developer = _newDeveloper;
    }
}