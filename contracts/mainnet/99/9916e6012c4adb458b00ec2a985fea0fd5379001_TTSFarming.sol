/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-04
 */

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

// ████████╗░█████╗░  ████████╗██╗░░██╗███████╗  ░██████╗███╗░░░███╗░█████╗░██████╗░████████╗
// ╚══██╔══╝██╔══██╗  ╚══██╔══╝██║░░██║██╔════╝  ██╔════╝████╗░████║██╔══██╗██╔══██╗╚══██╔══╝
// ░░░██║░░░██║░░██║  ░░░██║░░░███████║█████╗░░  ╚█████╗░██╔████╔██║███████║██████╔╝░░░██║░░░
// ░░░██║░░░██║░░██║  ░░░██║░░░██╔══██║██╔══╝░░  ░╚═══██╗██║╚██╔╝██║██╔══██║██╔══██╗░░░██║░░░
// ░░░██║░░░╚█████╔╝  ░░░██║░░░██║░░██║███████╗  ██████╔╝██║░╚═╝░██║██║░░██║██║░░██║░░░██║░░░
// ░░░╚═╝░░░░╚════╝░  ░░░╚═╝░░░╚═╝░░╚═╝╚══════╝  ╚═════╝░╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░

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

    function burn(uint256 amount) public;
    function burnFrom(address account, uint256 amount) public;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract TTSFarming {
    address tts;
    address tts2;
    uint256 public SECONDS_WORK_MINER = 300;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256 public countUsers = 0;
    uint256 public deals = 0;
    uint256 public volume = 0;
    address public burnWallet = 0x000000000000000000000000000000000000dEaD;

    uint256[] public REFERRAL_PERCENTS_BUY = [5, 4, 3, 2, 3, 4, 5];
    uint256[] public REFERRAL_PERCENTS_SELL = [0, 0, 0, 1, 1, 1, 1];

    uint256[] public REFERRAL_MINIMUM = [
        0,
        10000000000000000000000000000,
        25000000000000000000000000000,
        50000000000000000000000000000,
        100000000000000000000000000000,
        150000000000000000000000000000,
        200000000000000000000000000000
    ];
    bool public initialized = false;
    address public Delevoper;

    ITimerPool timer;

    struct  User  {
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
    mapping(address => bool) public OneGetFree;
    mapping(address => bool) public BUY_MINERS;
    

    uint256 public marketTokens;
    event Action(address user, address referrer, uint256 lvl, uint256 amount);

    constructor(ITimerPool _timer) public {
        Delevoper = msg.sender;
        timer = _timer;
    }



    function reinvest() public {
        require(initialized);

        uint256 tokensUsed = getMyTokens(msg.sender);
        uint256 bonus = (getMyTokens(msg.sender) / 100) * 5; // bonus
        uint256 newMiners = SafeMath.div((tokensUsed + bonus), SECONDS_WORK_MINER);
        usersMiner[msg.sender] = SafeMath.add(usersMiner[msg.sender], newMiners);
        claimedTokens[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        deals += 1;

        marketTokens = SafeMath.add(marketTokens, SafeMath.div(tokensUsed, 5));
    }

    function sellTokens() public {
        require(initialized);
        User storage user = users[msg.sender];
        uint256 userTokens = getMyTokens(msg.sender);
        uint256 amountSell = calculateTokensSell(userTokens);
        claimedTokens[msg.sender] = 0;


        if (amountSell > user.invest / 2) {

            uint256 InReinvest = amountSell - (user.invest / 2);
            amountSell = (user.invest / 2);

            buy(InReinvest);
        }
        volume += amountSell;

        uint256 fee = devFee(amountSell); // timer
        uint256 fee2 = devFee2(amountSell); // team
        uint256 fee3 = BurnFee(amountSell); // burn
        lastHatch[msg.sender] = now;
        marketTokens = SafeMath.add(marketTokens, userTokens);


        if (user.referrer != address(0)) {
            bool go = false;
            address upline = user.referrer;
            for (uint256 i = 0; i < 7; i++) {
                if (upline != address(0)) {
                    if (users[upline].invest >= REFERRAL_MINIMUM[i] || go == true) {
                        uint256 amount4 = (amountSell / 100) * REFERRAL_PERCENTS_SELL[i];
                        emit Action(msg.sender, upline, i, amount4);
                        if (amount4 > 0) {
                            ERC20(tts).transfer(upline, amount4);
                        }
                    }
                    upline = users[upline].referrer;
                    go = false;
                }
            }
        }

        deals += 1;

        ERC20(tts).transfer(timer, fee);
        ERC20(tts).transfer(Delevoper, fee2);
        ERC20(tts).transfer(msg.sender, SafeMath.sub(amountSell, (fee2 + fee3)));
        ERC20(tts).transfer(burnWallet, fee3);
        usersMiner[msg.sender] = SafeMath.mul(SafeMath.div(usersMiner[msg.sender], 95), 100);
    }


    function buyAirdrop(uint256 amount) public {
        User storage user = users[msg.sender];
        user.invest += amount;
        uint256 balance = ERC20(tts).balanceOf(address(this));
        uint256 tokensBought2 = calculateTokensBuy(amount, balance);
        ERC20(tts2).transferFrom(address(msg.sender), burnWallet, amount);
        claimedTokens[msg.sender] = tokensBought2;
        reinvest();
    }

    function buy(uint256 amount) private {
        uint256 balance = ERC20(tts).balanceOf(address(this));
        uint256 tokensBought2 = calculateTokensBuy(amount, balance);
        claimedTokens[msg.sender] = tokensBought2;
        reinvest();
    }

    function buyMiners(address ref, uint256 amount) public {
        require(initialized);
        countUsers += 1;
        deals += 1;
        volume += amount;
        BUY_MINERS[msg.sender] = true;

        User storage user = users[msg.sender];
        if (checkUser(msg.sender) == address(0)) {
            if (ref == msg.sender || ref == address(0) || usersMiner[ref] == 0) {
                user.referrer = Delevoper;
            } else {
                user.referrer = ref;
            }
        } else {
            user.referrer = checkUser(msg.sender);
        }

        ERC20(tts).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(tts).balanceOf(address(this));
        uint256 tokensBought = calculateTokensBuy(amount, SafeMath.sub(balance, amount));

        user.invest += amount;

        tokensBought = SafeMath.sub(tokensBought, SafeMath.add(devFee(tokensBought), devFee2(tokensBought)));
        uint256 fee = devFee(amount);
        uint256 fee2 = devFee2(amount);
        uint256 fee3 = BurnFee(amount); // burn
        ERC20(tts).transfer(burnWallet, fee3);
        ERC20(tts).transfer(timer, fee);
        timer.update(fee, block.timestamp, msg.sender);
        ERC20(tts).transfer(Delevoper, fee2);
        claimedTokens[msg.sender] = SafeMath.add(claimedTokens[msg.sender], tokensBought);

        if (user.referrer != address(0)) {
            bool go = false;
            address upline = user.referrer;
            for (uint256 i = 0; i < 7; i++) {
                if (upline != address(0)) {
                    if (users[upline].invest >= REFERRAL_MINIMUM[i] || go == true) {
                        uint256 amount4 = (amount / 100) * REFERRAL_PERCENTS_BUY[i];
                        emit Action(msg.sender, upline, i, amount4);
                        ERC20(tts).transfer(upline, amount4);
                    }
                    upline = users[upline].referrer;
                    go = false;
                }
            }

        reinvest();

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
        return calculateTrade(tokens, marketTokens, ERC20(tts).balanceOf(address(this)));
    }

    function calculateTokensBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketTokens);
    }

    function calculateTokensBuySimple(uint256 eth) public view returns (uint256) {
        return calculateTokensBuy(eth, ERC20(tts).balanceOf(address(this)));
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 1), 100); //timer
    }

    function BurnFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 3), 100); //timer
    }

    function devFee2(uint256 amount) public pure returns (uint256) {
        //Delevoper
        return SafeMath.div(SafeMath.mul(amount, 5), 100);
    }

    function seedMarket(address _tts, address _tts2) public payable {
        require(msg.sender == Delevoper, "invalid call");
        require(marketTokens == 0);
        tts = _tts;
        tts2 = _tts2;
        initialized = true;
        marketTokens = 333000000000;
    }

    function getBalance() public view returns (uint256) {
        return ERC20(tts).balanceOf(address(this));
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

    function getTokensSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(SECONDS_WORK_MINER, SafeMath.sub(now, lastHatch[adr]));
        return SafeMath.mul(secondsPassed, usersMiner[adr]);
    }

    function checkUser(address userAddr) public view returns (address ref) {
        return users[userAddr].referrer;
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