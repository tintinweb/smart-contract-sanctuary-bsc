/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.4.26; // solhint-disable-line

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

contract ERC20 {
    function totalSupply() public constant returns (uint256);

    function balanceOf(address tokenOwner) public constant returns (uint256 balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens) public returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract MinesGameOriginalTwo2 {
    address busdt = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //Testnet
    //address busdt = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // Mainnet
    uint256 public MINES_TO_HATCH_1MINERS = 864000; //for final version should be seconds in a day
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256[] public REFERRAL_PERCENTS = [8, 5, 4, 2];
    uint256[] public REFERRAL_MINIMUM = [
        1000000000000000000,
        2000000000000000000,
        3000000000000000000,
        4000000000000000000
    ];
    bool public initialized = false;
    address public ceoAddress;
    // address public ceoAddress1;
    // address public TimerPool;
    ITimerPool timer;

    struct User {
        address referrer;
        uint256 referrals;
        uint256 invest;
        bool l2;
        bool l3;
        bool l4;
    }

    mapping(address => User) internal users;
    mapping(address => uint256) public hatcheryMiners;
    mapping(address => uint256) public claimedMines;
    mapping(address => uint256) public lastHatch;
    uint256 public marketMines;

    constructor(ITimerPool _timer) public {
        ceoAddress = msg.sender;
        // ceoAddress1 = _developer;
        timer = _timer;
    }

    function hatchMines() public {
        require(initialized);

        uint256 minessUsed = getMyMines(msg.sender);
        uint256 bonus = (getMyMines(msg.sender) / 100) * 2;
        uint256 newMiners = SafeMath.div((minessUsed + bonus), MINES_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender], newMiners);
        claimedMines[msg.sender] = 0;
        lastHatch[msg.sender] = now;

        //boost market to nerf miners hoarding
        marketMines = SafeMath.add(marketMines, SafeMath.div(minessUsed, 5));
    }

    function sellMines() public {
        require(initialized); // intilize wefwef
        uint256 hasMines = getMyMines(msg.sender);
        uint256 minesValue = calculateMinesSell(hasMines);
        uint256 fee = devFee(minesValue);
        uint256 fee2 = devFee2(minesValue);
        claimedMines[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        marketMines = SafeMath.add(marketMines, hasMines);
        // ERC20(busdt).transfer(ceoAddress1, fee);
        ERC20(busdt).transfer(timer, fee);
        ERC20(busdt).transfer(ceoAddress, fee2);
        ERC20(busdt).transfer(msg.sender, SafeMath.sub(minesValue, (fee + fee2)));
    }

    function buyMines(address ref, uint256 amount) public payable {
        require(initialized);
        User storage user = users[msg.sender];
        if (ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            user.referrer = ceoAddress;
        } else {
            user.referrer = ref;
        }

        ERC20(busdt).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(busdt).balanceOf(address(this));
        uint256 minessBought = calculateMinesBuy(amount, SafeMath.sub(balance, amount));

        user.invest += amount;

        minessBought = SafeMath.sub(minessBought, SafeMath.add(devFee(minessBought), devFee2(minessBought)));
        uint256 fee = devFee(amount);
        uint256 fee2 = devFee2(amount);
        ERC20(busdt).transfer(timer, fee);
        timer.update(fee2, block.timestamp, msg.sender);
        // ERC20(busdt).transfer(ceoAddress, fee2);
        ERC20(busdt).transfer(ceoAddress, fee2);
        claimedMines[msg.sender] = SafeMath.add(claimedMines[msg.sender], minessBought);

        if (user.referrer != address(0)) {
            bool go = false;
            address upline = user.referrer;
            for (uint256 i = 0; i < 4; i++) {
                if (upline != address(0)) {
                    if (i == 1) {
                        if (users[upline].l2 == true) go = true;
                    } else if (i == 2) {
                        if (users[upline].l3 == true) go = true;
                    } else if (i == 3)
                        if (users[upline].l4 == true) go = true;

                    if (users[upline].invest >= REFERRAL_MINIMUM[i] || go == true) {
                        uint256 amount4 = (amount / 100) * REFERRAL_PERCENTS[i];
                        ERC20(busdt).transfer(upline, amount4);
                    }
                    upline = users[upline].referrer;
                    go = false;
                }
            }

            hatchMines();
        }
    }

    //magic trade balancing algorithm
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

    function calculateMinesSell(uint256 miness) public view returns (uint256) {
        return calculateTrade(miness, marketMines, ERC20(busdt).balanceOf(address(this)));
    }

    function calculateMinesBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketMines);
    }

    function calculateMinesBuySimple(uint256 eth) public view returns (uint256) {
        return calculateMinesBuy(eth, ERC20(busdt).balanceOf(address(this)));
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 10), 100);
    }

    function devFee2(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 2), 100);
    }

    function seedMarket() public payable {
        require(msg.sender == ceoAddress, "invalid call");
        require(marketMines == 0);
        initialized = true;
        marketMines = 86400000000;
    }

    function getBalance() public view returns (uint256) {
        return ERC20(busdt).balanceOf(address(this));
    }

    function getMyMiners(address user) public view returns (uint256) {
        return hatcheryMiners[user];
    }

    function getMyMines(address user) public view returns (uint256) {
        return SafeMath.add(claimedMines[user], getMinesSinceLastHatch(user));
    }

    function getMinesSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(MINES_TO_HATCH_1MINERS, SafeMath.sub(now, lastHatch[adr]));
        return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
    }

    function unlocklevel(
        address userAddr,
        bool l2,
        bool l3,
        bool l4
    ) external {
        require(ceoAddress == msg.sender, "only owner");
        users[userAddr].l2 = l2;
        users[userAddr].l3 = l3;
        users[userAddr].l4 = l4;
    }

    function checkUser(address userAddr) external view returns (uint256 invest, address ref) {
        invest = users[userAddr].invest;
        ref = users[userAddr].referrer;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
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