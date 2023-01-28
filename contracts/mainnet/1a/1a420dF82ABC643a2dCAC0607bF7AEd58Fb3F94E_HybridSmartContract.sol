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

interface ROIContract{
    function depositByPoolPayment(address user,uint256 amount) external;
}

contract HybridSmartContract {
    address public ownerWallet;
    address public devWallet;
    uint256 public currUserID = 0;
    address public roiContract;
    IERC20 busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256[4] public poolcurrRegisterUserID;
    uint256[4] public poolactiveUserID;

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
    uint256[11] leaderCounts = [50,100,200,300,400,500,600,700,800,900,1000];
    uint256[11] managerBonus = [250 ether,500 ether,1000 ether,1500 ether,2000 ether,2500 ether,3000 ether,3500 ether,4000 ether,4500 ether,5000 ether];
    

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

    event ManagerBonus(
        address indexed _user,
        uint256 amount
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
            referrerID: 1,
            referredUsers: 0,
            referralEarning: 0,
            autopoolInvestEarning: 0,
            managerBonus: 0
        });

        users[ownerWallet] = userStruct;

        userList[currUserID] = ownerWallet;

        PoolUserStruct memory pooluserStruct;

        for (uint256 i = 1; i <= 3; i++) {
            poolcurrRegisterUserID[i]++;
            pooluserStruct = PoolUserStruct({
                isExist: true,
                id: poolcurrRegisterUserID[i],
                payment_received: 0,
                reEntry: 0,
                paid_entry: true
            });
            poolactiveUserID[i] = poolcurrRegisterUserID[i];
            poolusers[i][ownerWallet] = pooluserStruct;
            pooluserList[i][poolcurrRegisterUserID[i]] = ownerWallet;
        }
    }

    function setRoiContract(address _roiContract) external {
        require(ownerWallet==msg.sender,"invalid user");
        roiContract = _roiContract;
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
        address user = userList[id];
        UserStruct storage  _user = users[user];
        for(uint8 i=0;i<11;i++){
            if(_user.referredUsers==leaderCounts[i])
            {
                _user.managerBonus +=managerBonus[i];
            }
        }
    }

    function withdrawManagerBonus() external {
        UserStruct storage  _user = users[msg.sender];
        require(_user.managerBonus>0,"0 amount");
        busd.transfer(msg.sender, _user.managerBonus);
        emit ManagerBonus(msg.sender,_user.managerBonus);
        _user.managerBonus = 0;
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
            
            busd.transfer(roiContract, Pool_Entry_fee[poolId]*60/100);
            ROIContract(roiContract).depositByPoolPayment(currentUseraddress,Pool_Entry_fee[poolId]*60/100);
        }
        busd.transfer(devWallet,(Pool_Entry_fee[poolId] * 5) / 100);
        busd.transfer(ownerWallet,(Pool_Entry_fee[poolId] * 5) / 100);
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
        uint256[] memory payment_Received_List = new uint256[](4);
        uint256[] memory reEntry_List = new uint256[](4);
        bool[] memory activePool_List = new bool[](4);

        for (uint256 i = 1; i <= 3; i++) {
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
}