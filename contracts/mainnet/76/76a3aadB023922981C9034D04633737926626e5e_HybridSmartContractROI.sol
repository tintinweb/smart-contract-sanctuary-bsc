/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface POOL_CONTRACT{
    function viewUserReferral(address _user) external  view returns (address);

    function checkUserExist(address _user) external  view returns (bool);
}

contract HybridSmartContractROI {
    address public ownerWallet;
    address public devWallet;
    address public poolContract;
    uint256 public currUserID = 0;
    IERC20 busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

   
    struct Deposit {
        uint256 amount;
        uint40 time;
    }

    struct RoiUser {
        uint256 dividends;
        uint256 match_bonus;
        uint40 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        Deposit[] deposits;
        uint256[5] structure;
    }


    mapping(address => RoiUser) public roiUsers;
    mapping(uint256 => address) public userList;



  
    mapping(uint256 => uint256) public Payment_Received_List_Pool;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;

    uint8 constant BONUS_LINES_COUNT = 5;
    uint16 constant PERCENT_DIVIDER = 1000;
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [50, 30, 30, 20, 20];
    uint40 constant total_days = 200;
    uint40 constant total_returns = 350;
    uint40 public TIME_STEP = 86400;

    event regLevelEvent(
        address indexed _user,
        address indexed _referrer,
        uint256 _time
    );
    
    event NewDeposit(address indexed addr, uint256 amount);
    event MatchPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event Withdraw(address indexed addr, uint256 amount);
    event getMoneyForPoolLevelEventReinvest(
        address indexed _user,
        address indexed _referral,
        uint256 _level,
        uint256 _time,
        uint256 poolid,
        uint256 poolno
    );

    constructor(address _ownerWallet, address _devWallet,address _poolContract) {
        ownerWallet = _ownerWallet;
        devWallet = _devWallet;
        poolContract = _poolContract;
    }

    function depositByPoolPayment(address user,uint256 amount) external
    {
        require(msg.sender==poolContract,"Invalid user");
        _deposit(user, amount);
    }

    function deposit(uint256 amount) external {
        require(amount >= 5 ether, "Minimum deposit amount is 5 BUSD");
        require(checkUserExist(msg.sender),"Please register first");
        require(busd.transferFrom(msg.sender, address(this), amount));
        _deposit(msg.sender, amount);
    }

    function _deposit(address _user, uint256 amount) internal {
        RoiUser storage player = roiUsers[_user];


        player.deposits.push(
            Deposit({amount: amount, time: uint40(block.timestamp)})
        );

        player.total_invested += amount;
        invested += amount;

        _refPayout(_user, amount);

        busd.transfer(devWallet, (amount * 50) / 1000);
        busd.transfer(ownerWallet, (amount * 50) / 1000);
        emit NewDeposit(_user, amount);
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if (payout > 0) {
            roiUsers[_addr].last_payout = uint40(block.timestamp);
            roiUsers[_addr].dividends += payout;
        }
    }

    function withdraw() external {
        RoiUser storage player = roiUsers[msg.sender];

        _payout(msg.sender);

        require(player.dividends > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus;

        player.dividends = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        busd.transfer(msg.sender,amount);

        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) external view returns (uint256 value) {
        RoiUser storage player = roiUsers[_addr];

        for (uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];

            uint40 time_end = dep.time + total_days * TIME_STEP;
            uint40 from = player.last_payout > dep.time
                ? player.last_payout
                : dep.time;
            uint40 to = block.timestamp > time_end
                ? time_end
                : uint40(block.timestamp);

            if (from < to) {
                value +=
                    (dep.amount * (to - from) * total_returns) /
                    total_days /
                    (TIME_STEP*100);
            }
        }

        return value;
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = getUpline(_addr);

        for (uint8 i = 0; i < ref_bonuses.length; i++) {
            if (up == address(0)) break;

            uint256 bonus = (_amount * ref_bonuses[i]) / PERCENT_DIVIDER;

            roiUsers[up].match_bonus += bonus;
            roiUsers[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);
            if(up==ownerWallet){
                break;
            }
            up = getUpline(up);
        }
    }

    function userInfo(address _addr)
        external
        view
        returns (
            uint256 for_withdraw,
            uint256 total_invested,
            uint256 total_withdrawn,
            uint256 total_match_bonus,
            uint256[BONUS_LINES_COUNT] memory structure
        )
    {
        RoiUser storage player = roiUsers[_addr];

        uint256 payout = this.payoutOf(_addr);

        for (uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure
        );
    }

    function contractInfo()
        external
        view
        returns (
            uint256 _invested,
            uint256 _withdrawn,
            uint256 _match_bonus
        )
    {
        return (invested, withdrawn, match_bonus);
    }

    function getUpline(address _user) public view returns (address) {
        return POOL_CONTRACT(poolContract).viewUserReferral(_user);
    }

    function checkUserExist(address _user) public view returns (bool) {
        return POOL_CONTRACT(poolContract).checkUserExist(_user);
    }

    function getDepositeList(address _user) external view returns(Deposit[] memory deposits)
    {
        return roiUsers[_user].deposits;
    }
}