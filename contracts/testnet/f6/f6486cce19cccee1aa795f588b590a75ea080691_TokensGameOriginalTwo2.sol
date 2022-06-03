/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-26
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

contract TokensGameOriginalTwo2 {
    address busdt = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //Testnet
    //address busdt = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // Mainnet
    uint256 public TOKENS_TO_HATCH_1TOKENS = 600; //for final version should be seconds in a day
    uint256 public allUsers = 0;
    uint256 public userAday = 0;
    uint256 public TotalBuy = 0;
    uint256 public deals = 0;
    uint256 public dealsAday = 0;
    uint256 public starProject = 0;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256 BONUS_10_BUSD = 10000000000000000000; //bonus
    uint256 private mDep = 5000000000000000000;  // Минимальный деп для вывода
    uint256 private Dop = 500000000000000000000000; // ТВЛ контракта до 500к$    

    uint256[] public REFERRAL_PERCENTS = [5, 4, 3, 2, 3, 4, 5];
    uint256[] public REFERRAL_PERCENTS_SELL = [1, 0, 2, 0, 3, 0, 4];

    uint256[] public REFERRAL_MINIMUM = [
        1000000000000000000,
        2000000000000000000,
        3000000000000000000,
        4000000000000000000,
        5000000000000000000,
        6000000000000000000,
        7000000000000000000
    ];
    bool public initialized = false;
    address public ceoAddress;
    address public TimerPool;
    ITimerPool timer;

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
    mapping(address => bool) public buyuser;
    mapping(address => uint256) public hatcheryMiners;
    mapping(address => uint256) public claimedTokens;
    mapping(address => uint256) public lastHatch;
    mapping (address => bool) private OneGetFree;
    mapping (address => bool) private BUY_TOKEN_SUM;

    uint256 public marketTokens;

    constructor(ITimerPool _timer) public {
        ceoAddress = msg.sender;
        // ceoAddress1 = _developer;
        timer = _timer;
    }    


    function hatchTokens() public {
        require(initialized);

        uint256 tokensUsed = getMyTokens(msg.sender);
        uint256 bonus = (getMyTokens(msg.sender) / 100) * 2;
        uint256 newTokenrs = SafeMath.div((tokensUsed + bonus), TOKENS_TO_HATCH_1TOKENS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender], newTokenrs);
        claimedTokens[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        deals+=1;

        //boost market to nerf miners hoarding
        marketTokens = SafeMath.add(marketTokens, SafeMath.div(tokensUsed, 5));
    }

    function sellTokens(address ref, uint256 amountSell) public {
        require(initialized); // intilize wefwef
//        require(AllDep[msg.sender] >= mDep);
        User storage user = users[msg.sender];
        if (ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            user.referrer = ceoAddress;
        } else {
            user.referrer = ref;
        }
        require(user.invest >= mDep);
        //uint256 hasTokens = getMyTokens(msg.sender);
        amountSell = calculateTokensSell(getMyTokens(msg.sender));
        uint256 fee = devFee(amountSell); // комса таймера
        uint256 fee2 = devFee2(amountSell); // комса овнера
        claimedTokens[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        marketTokens = SafeMath.add(marketTokens, getMyTokens(msg.sender));
        // проверка реерала
        if (user.referrer != address(0)) {
            bool go = false;
            address upline = user.referrer;
            for (uint256 i = 0; i < 7; i++) {
                if (upline != address(0)) {
                    if (i == 1) {
                        if (users[upline].l2 == true) go = true;
                    } else if (i == 2) {
                        if (users[upline].l3 == true) go = true;
                    } else if (i == 3) {
                        if (users[upline].l4 == true) go = true;
                    } else if (i == 4) {
                        if (users[upline].l5 == true) go = true;
                    } else if (i == 5) {
                        if (users[upline].l5 == true) go = true;
                    } else if (i == 6) {
                        if (users[upline].l6 == true) go = true;
                    } else if (i == 7) {
                        if (users[upline].l7 == true) go = true;
                    }

                    if (users[upline].invest >= REFERRAL_MINIMUM[i] || go == true) {
                        uint256 amount4 = (amountSell / 100) * REFERRAL_PERCENTS_SELL[i];
                        ERC20(busdt).transfer(upline, amount4);
                    }
                    upline = users[upline].referrer;
                    go = false;
                }
            }

        }
    




        // ERC20(busdt).transfer(ceoAddress1, fee);
        amountSell -= amount4;
        ERC20(busdt).transfer(timer, fee);
        ERC20(busdt).transfer(ceoAddress, fee2);
        ERC20(busdt).transfer(msg.sender, SafeMath.sub(amountSell, (fee + fee2)));
        deals+=1;
    }

    function buyTokens(address ref, uint256 amount) public payable {
        require(initialized);
        User storage user = users[msg.sender];
        if (ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            user.referrer = ceoAddress;
        } else {
            user.referrer = ref;
        }

        ERC20(busdt).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(busdt).balanceOf(address(this));
        uint256 tokensBought = calculateTokensBuy(amount, SafeMath.sub(balance, amount));

        user.invest += amount;
        TotalBuy += amount;
        buyuser[msg.sender] = true;

        tokensBought = SafeMath.sub(tokensBought, SafeMath.add(devFee(tokensBought), devFee2(tokensBought)));
        uint256 fee = devFee(amount);
        uint256 fee2 = devFee2(amount);
        ERC20(busdt).transfer(timer, fee);
        timer.update(fee, block.timestamp, msg.sender);
        ERC20(busdt).transfer(ceoAddress, fee2);
        claimedTokens[msg.sender] = SafeMath.add(claimedTokens[msg.sender], tokensBought);

        if (user.referrer != address(0)) {
            bool go = false;
            address upline = user.referrer;
            for (uint256 i = 0; i < 7; i++) {
                if (upline != address(0)) {
                    if (i == 1) {
                        if (users[upline].l2 == true) go = true;
                    } else if (i == 2) {
                        if (users[upline].l3 == true) go = true;
                    } else if (i == 3) {
                        if (users[upline].l4 == true) go = true;
                    } else if (i == 4) {
                        if (users[upline].l5 == true) go = true;
                    } else if (i == 5) {
                        if (users[upline].l5 == true) go = true;
                    } else if (i == 6) {
                        if (users[upline].l6 == true) go = true;
                    } else if (i == 7) {
                        if (users[upline].l7 == true) go = true;
                    }

                    if (users[upline].invest >= REFERRAL_MINIMUM[i] || go == true) {
                        uint256 amount4 = (amount / 100) * REFERRAL_PERCENTS[i];
                        ERC20(busdt).transfer(upline, amount4);
                    }
                    upline = users[upline].referrer;
                    go = false;
                }
            }

            hatchTokens();
                    if (user.invest >= mDep) {

            BUY_TOKEN_SUM[msg.sender] = true;

        }
        
        if (Dop <= amount) {
            Dop = 0;
        }
        else {
            Dop -= amount;    
        }

        if (OneGetFree[msg.sender] == false) {

            allUsers += 1;

        }
        deals += 1;

        }
    }

    function getFreeEgs() public {    
        require (initialized); 
        require (OneGetFree[msg.sender] == false);
        lastHatch[msg.sender] = now; 
        hatcheryMiners[msg.sender] = SafeMath.add(SafeMath.div(calculateTokensBuySimple(BONUS_10_BUSD),TOKENS_TO_HATCH_1TOKENS),hatcheryMiners[msg.sender]);
        OneGetFree[msg.sender] = true;
        if (buyuser[msg.sender] == true) {
            allUsers += 1;
        }
        deals += 1;
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

    function calculateTokensSell(uint256 tokens) public view returns (uint256) {
        return calculateTrade(tokens, marketTokens, ERC20(busdt).balanceOf(address(this)));
    }

    function calculateTokensBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketTokens);
    }

    function calculateTokensBuySimple(uint256 eth) public view returns (uint256) {
        return calculateTokensBuy(eth, ERC20(busdt).balanceOf(address(this)));
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 11), 100);
    }

    function devFee2(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 5), 100);
    }

    function seedMarket() public payable {
        require(msg.sender == ceoAddress, "invalid call");
        require(marketTokens == 0);
        initialized = true;
        marketTokens = 86400000000;
        starProject = now;
    }

    function getBalance() public view returns (uint256) {
        return ERC20(busdt).balanceOf(address(this));
    }

    function getMyTokenrs(address user) public view returns (uint256) {
        return hatcheryMiners[user];
    }

    function MyReward(address user) public view returns (uint256) {
        return calculateTokensSell(getMyTokens(user));
    }

    function getMyTokens(address user) public view returns (uint256) {
        return SafeMath.add(claimedTokens[user], getTokensSinceLastHatch(user));
    }

    function getTokensSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(TOKENS_TO_HATCH_1TOKENS, SafeMath.sub(now, lastHatch[adr]));
        return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
    }

    function unlocklevel(
        address userAddr,
        bool l2,
        bool l3,
        bool l4,
        bool l5,
        bool l6,
        bool l7
    ) external {
        require(ceoAddress == msg.sender, "only owner");
        users[userAddr].l2 = l2;
        users[userAddr].l3 = l3;
        users[userAddr].l4 = l4;
        users[userAddr].l5 = l5;
        users[userAddr].l6 = l6;
        users[userAddr].l7 = l7;
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