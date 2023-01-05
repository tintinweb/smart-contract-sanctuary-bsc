/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

/**
 *Submitted for verification at polygonscan.com on 2022-08-28
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

contract F2EMaticPool {
    address public ownerWallet;
    address public devWallet;
    uint256 public currUserID = 0;
    IERC20 busd = IERC20(0x481694ee8EF4f2a516B1Ca7f54b78a42a9452eab);

    uint256[11] poolcurrRegisterUserID;
    uint256[11] poolactiveUserID;

    struct UserStruct {
        bool isExist;
        uint256 id;
        uint256 referrerID;
        uint256 referredUsers;
        uint256 referralEarning;
        uint256 autopoolInvestEarning;
        uint256 managerBonus;
    }

    struct PoolUserStruct {
        bool isExist;
        uint256 id;
        uint256 payment_received;
        uint256 reEntry;
        bool paid_entry;
    }

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


    mapping(address => UserStruct) public users;
    mapping(address => RoiUser) public roiUsers;
    mapping(uint256 => address) public userList;



    mapping(uint256 => mapping(address => PoolUserStruct)) public poolusers;
    mapping(uint256 => mapping(uint256 => address)) public pooluserList;

    mapping(uint256 => uint256) public Pool_Entry_fee;

    mapping(uint256 => uint256) public Payment_Received_List_Pool;
    uint256[13] ref_earnings = [100, 50, 30, 20, 10, 5, 5, 5, 5, 5, 5, 5, 5];

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;

    uint8 constant BONUS_LINES_COUNT = 5;
    uint16 constant PERCENT_DIVIDER = 1000;
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [50, 30, 20, 10, 5];
    uint40 constant total_days = 200;
    uint40 constant total_returns = 350;

    event regLevelEvent(
        address indexed _user,
        address indexed _referrer,
        uint256 _time
    );
    event getMoneyForPoolLevelEvent(
        address indexed _user,
        address indexed _referral,
        uint256 _level,
        uint256 _time,
        uint256 poolid,
        uint256 poolno,
        uint8 treeLevel,
        uint256 amount
    );

    event regPoolEntry(
        address indexed _user,
        uint256 _level,
        uint256 _time,
        uint256 poolid,
        uint256 userid,
        bool paid_entry
    );

    event getPoolPayment(
        address indexed _user,
        address indexed _receiver,
        uint256 _level
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

    constructor(address _ownerWallet, address _devWallet) {
        ownerWallet = _ownerWallet;
        devWallet = _devWallet;

        Pool_Entry_fee[1] = 25 ether;
        Pool_Entry_fee[2] = 50 ether;
        Pool_Entry_fee[3] = 100 ether;

        UserStruct memory userStruct;

        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 0,
            referredUsers: 0,
            referralEarning: 0,
            autopoolInvestEarning: 0,
            managerBonus: 0
        });

        users[ownerWallet] = userStruct;

        userList[currUserID] = ownerWallet;

        PoolUserStruct memory pooluserStruct;

        for (uint256 i = 1; i <= 10; i++) {
            poolcurrRegisterUserID[i]++;
            pooluserStruct = PoolUserStruct({
                isExist: true,
                id: poolcurrRegisterUserID[i],
                payment_received: 0,
                reEntry: 0,
                paid_entry: true
            });
            poolactiveUserID[i] = poolcurrRegisterUserID[i];
            poolusers[i][msg.sender] = pooluserStruct;
            pooluserList[i][poolcurrRegisterUserID[i]] = msg.sender;
        }
    }

    function regUser(uint256 _referrerID) public {
        require(!users[msg.sender].isExist, "User Exist");
        require(userList[_referrerID] != address(0), "Invalid referrer id");
        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            referredUsers: 0,
            referralEarning: 0,
            autopoolInvestEarning: 0,
            managerBonus: 0
        });
        users[msg.sender] = userStruct;
        users[userList[_referrerID]].referredUsers++;
        userList[currUserID] = msg.sender;
        sendManagerBonus(_referrerID);
        emit regLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
        buyPool(1);
    }

    function sendManagerBonus(uint256 id) internal{
        address managerBonus = userList[id];
        UserStruct memory  _user = users[managerBonus];
        
        if(_user.referredUsers==50){
            busd.transfer(managerBonus,250 ether);
            _user.managerBonus +=250 ether;
        }
        else if(_user.referredUsers==100)
        {
            busd.transfer(managerBonus,500 ether);
            _user.managerBonus +=500 ether;
        }
        else if(_user.referredUsers==200)
        {
            busd.transfer(managerBonus,1000 ether);
            _user.managerBonus +=1000 ether;
        }
        else if(_user.referredUsers==300)
        {
            busd.transfer(managerBonus,1500 ether);
            _user.managerBonus +=1500 ether;
        }
        else if(_user.referredUsers==400)
        {
            busd.transfer(managerBonus,2000 ether);
            _user.managerBonus +=2000 ether;
        }
        else if(_user.referredUsers==500)
        {
            busd.transfer(managerBonus,2500 ether);
            _user.managerBonus +=2500 ether;
        }
        else if(_user.referredUsers==600)
        {
            busd.transfer(managerBonus,3000 ether);
            _user.managerBonus +=3000 ether;
        }
        else if(_user.referredUsers==700)
        {
            busd.transfer(managerBonus,3500 ether);
            _user.managerBonus +=3500 ether;
        }
        else if(_user.referredUsers==800)
        {
            busd.transfer(managerBonus,4000 ether);
            _user.managerBonus +=4000 ether;
        }
        else if(_user.referredUsers==900)
        {
            busd.transfer(managerBonus,4500 ether);
            _user.managerBonus +=4500 ether;
        }
        else if(_user.referredUsers==1000)
        {
            busd.transfer(managerBonus,5000 ether);
            _user.managerBonus +=5000 ether;
        }
    }

    function payPoolReferral(
        uint256 _level,
        address _user,
        uint256 _poolno
    ) internal {
        address referer;
        for (uint8 i = 0; i < ref_earnings.length; i++) {
            referer = userList[users[_user].referrerID];
            if (referer == address(0)) {
                break;
            }
            uint256 amount = Pool_Entry_fee[_poolno]*ref_earnings[i]/1000;
            busd.transfer(referer,amount);
            users[referer].referralEarning += amount;
            emit getMoneyForPoolLevelEvent(
                referer,
                _user,
                _level,
                block.timestamp,
                users[_user].referrerID,
                _poolno,
                i + 1,
                amount
            );
            _user = referer;
        }
    }

    

    function buyPool(uint256 poolId) public {
        require(users[msg.sender].isExist, "User Not Registered");
        require(!poolusers[poolId][msg.sender].isExist, "Already in AutoPool");
        busd.transferFrom(msg.sender,address(this),Pool_Entry_fee[poolId]);
        PoolUserStruct memory userStruct;
        poolcurrRegisterUserID[poolId]++;

        userStruct = PoolUserStruct({
            isExist: true,
            id: poolcurrRegisterUserID[poolId],
            payment_received: 0,
            reEntry: 0,
            paid_entry: true
        });
        poolusers[poolId][msg.sender] = userStruct;
        pooluserList[poolId][poolcurrRegisterUserID[poolId]] = msg.sender;

        payPoolReferral(1, msg.sender, poolId);
        emit regPoolEntry(
            msg.sender,
            poolId,
            block.timestamp,
            poolcurrRegisterUserID[poolId],
            users[msg.sender].id,
            true
        );

        address currentUseraddress = pooluserList[poolId][
            poolactiveUserID[poolId]
        ];

        poolusers[poolId][currentUseraddress].payment_received += 1;
        if (poolusers[poolId][currentUseraddress].payment_received < 3) {

            busd.transfer(currentUseraddress,Pool_Entry_fee[poolId]*60/100);

            users[currentUseraddress].autopoolInvestEarning += Pool_Entry_fee[poolId]*60/100;
            emit getPoolPayment(msg.sender, currentUseraddress, poolId);
        } else if (
            poolusers[poolId][currentUseraddress].payment_received == 3
        ) {
            poolcurrRegisterUserID[poolId]++;
            
            poolusers[poolId][currentUseraddress].id = poolcurrRegisterUserID[poolId];
            poolusers[poolId][currentUseraddress].payment_received = 0;
            poolusers[poolId][currentUseraddress].paid_entry = false;

            pooluserList[poolId][
                poolcurrRegisterUserID[poolId]
            ] = currentUseraddress;
            poolusers[poolId][currentUseraddress].reEntry += 1;
            emit regPoolEntry(
                currentUseraddress,
                poolId,
                block.timestamp,
                poolcurrRegisterUserID[poolId],
                users[currentUseraddress].id,
                false
            );
            poolactiveUserID[poolId] += 1;
            _deposit(
                currentUseraddress,
                Pool_Entry_fee[poolId]*60/100
            );
        }
        busd.transfer(devWallet,(Pool_Entry_fee[poolId] * 50) / 1000);
        busd.transfer(ownerWallet,(Pool_Entry_fee[poolId] * 50) / 1000);
    }

    

    function deposit(uint256 amount) external {
        require(amount >= 5 ether, "Minimum deposit amount is 0.01 BNB");
        require(busd.transferFrom(msg.sender, address(this), amount));
        _deposit(msg.sender, amount);
    }

    function _deposit(address _user, uint256 amount) internal {
        RoiUser storage player = roiUsers[_user];

        require(player.deposits.length < 100, "Max 100 deposits per address");

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

            uint40 time_end = dep.time + total_days * 86400;
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
                    8640000;
            }
        }

        return value;
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = userList[users[_addr].referrerID];

        for (uint8 i = 0; i < ref_bonuses.length; i++) {
            if (up == address(0)) break;

            uint256 bonus = (_amount * ref_bonuses[i]) / PERCENT_DIVIDER;

            roiUsers[up].match_bonus += bonus;
            roiUsers[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = userList[users[up].referrerID];
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

    function viewUserReferral(address _user) public view returns (address) {
        return userList[users[_user].referrerID];
    }

    function checkUserExist(address _user) public view returns (bool) {
        return users[_user].isExist;
    }

    function getPoolUserPoolDetails(address _user)
        public
        view
        returns (
            uint256[] memory _paymentReceived,
            uint256[] memory _reEntry,
            bool[] memory _activePool_List
        )
    {
        //uint256[11] memory Payment_Received_List;
        uint256[] memory payment_Received_List = new uint256[](11);
        uint256[] memory reEntry_List = new uint256[](11);
        bool[] memory activePool_List = new bool[](11);

        for (uint256 i = 1; i <= 10; i++) {
            payment_Received_List[i] = poolusers[i][_user].payment_received;
            reEntry_List[i] = poolusers[i][_user].reEntry;
            activePool_List[i] = poolusers[i][_user].isExist;
        }
        return (payment_Received_List, reEntry_List, activePool_List);
    }

    function getPoolUserPoolDetailsPoolWise(address _user, uint256 pool_id)
        public
        view
        returns (
            uint256 _paymentReceived,
            uint256 _reEntry,
            bool _activePool_List
        )
    {
        return (
            poolusers[pool_id][_user].payment_received,
            poolusers[pool_id][_user].reEntry,
            poolusers[pool_id][_user].isExist
        );
    }

    function totalUserCount() external view returns (uint256[] memory counts) {
        uint256[] memory count = new uint256[](4);
        for (uint256 i = 1; i <= 3; i++) {
            count[i] = poolcurrRegisterUserID[i];
        }

        return count;
    }

    function getDepositeList(address _user) external view returns(Deposit[] memory deposits)
    {
        return roiUsers[_user].deposits;
    }
}