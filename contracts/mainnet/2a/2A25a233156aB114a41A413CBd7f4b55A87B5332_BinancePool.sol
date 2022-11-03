/**
 *Submitted for verification at BscScan.com on 2022-11-03
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

contract BinancePool {
    address public ownerWallet;
    address public devWallet;
    uint256 public currUserID = 0;
    IERC20 USDTAddress;

    uint256[11] public  poolcurrRegisterUserID;
    uint256[11] public  poolactiveUserID;

    struct UserStruct {
        bool isExist;
        uint256 id;
        uint256 referrerID;
        uint256 referredUsers;
        uint256 referralEarning;
        uint256 autopoolInvestEarning;
        uint256 incomeOnIncome;
        uint256 fastCashBonus;
        uint256 availableToWithdraw;
    }
    

    struct PoolUserStruct {
        bool isExist;
        uint256 id;
        uint256 payment_received;
        uint256 reEntry;
        bool paid_entry;
    }

    mapping(address => UserStruct) public users;
    mapping(uint256 => address) public userList;

    mapping(uint256 => mapping(address => PoolUserStruct)) public poolusers;
    mapping(uint256 => mapping(uint256 => address)) public pooluserList;

    mapping(uint256 => uint256) public Pool_Entry_fee;

    mapping(uint256 => uint256) public Payment_Received_List_Pool;
    uint256[] ref_earnings = [10, 5, 5, 3, 1, 1];

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
    event getMoneyForPoolLevelEventReinvest(
        address indexed _user,
        address indexed _referral,
        uint256 _level,
        uint256 _time,
        uint256 poolid,
        uint256 poolno
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
    event fastcashbonusevent(address indexed _user, uint256 _level);
    event Claim(address indexed _user,uint256 amount);

    constructor(address _ownerWallet,address _devWallet,address firstId) {
        ownerWallet = _ownerWallet;
        devWallet = _devWallet;

        Pool_Entry_fee[1] = 10 ether;
        for (uint256 i = 2; i <= 10; i++) {
            Pool_Entry_fee[i] = Pool_Entry_fee[i - 1] * 2;
        }

        UserStruct memory userStruct;

        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 1,
            referredUsers: 0,
            referralEarning: 0,
            autopoolInvestEarning: 0,
            incomeOnIncome: 0,
            fastCashBonus: 0,
            availableToWithdraw:0
        });

        users[firstId] = userStruct;

        userList[currUserID] = firstId;

        PoolUserStruct memory pooluserStruct;

        USDTAddress = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

        /* Pool All */

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
            poolusers[i][firstId] = pooluserStruct;
            pooluserList[i][poolcurrRegisterUserID[i]] = firstId;
        }
    }

    function regUser(uint256 _referrerID) public payable {
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
            incomeOnIncome: 0,
            fastCashBonus: 0,
            availableToWithdraw:0
        });
        users[msg.sender] = userStruct;

        userList[currUserID] = msg.sender;
        users[userList[_referrerID]].referredUsers +=1;

        emit regLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
        buyPool(1); 
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
            uint256 amount = percentage(
                Pool_Entry_fee[_poolno],
                ref_earnings[i]
            );
            // USDTAddress.transfer(referer, amount);
            users[referer].referralEarning += amount;
            users[referer].availableToWithdraw += amount;
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

    function payPoolPaymentReferral(
        uint256 _level,
        address _user,
        uint256 _poolno
    ) internal {
        if (users[_user].referrerID > 0) {
            address referer;
            referer = userList[users[_user].referrerID];
            // USDTAddress.transfer(referer, (Pool_Entry_fee[_poolno] * 5) / 100);
            users[referer].availableToWithdraw +=(Pool_Entry_fee[_poolno] * 5) /100;
            users[referer].incomeOnIncome +=(Pool_Entry_fee[_poolno] * 5) /100;
            emit getMoneyForPoolLevelEventReinvest(
                referer,
                _user,
                _level,
                block.timestamp,
                users[_user].referrerID,
                _poolno
            );
        }
    }

    function buyPool(uint256 poolId) public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(!poolusers[poolId][msg.sender].isExist, "Already in AutoPool");
        USDTAddress.transferFrom(
            msg.sender,
            address(this),
            Pool_Entry_fee[poolId]
        );
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

        if (
            poolusers[poolId][
                pooluserList[poolId][poolcurrRegisterUserID[poolId] - 1]
            ].paid_entry
        ) {
            // USDTAddress.transfer((pooluserList[poolId][poolcurrRegisterUserID[poolId] - 1]),percentage(Pool_Entry_fee[poolId], 10));
            users[pooluserList[poolId][poolcurrRegisterUserID[poolId] - 1]].availableToWithdraw += percentage(Pool_Entry_fee[poolId], 10);
            users[pooluserList[poolId][poolcurrRegisterUserID[poolId] - 1]].fastCashBonus += percentage(Pool_Entry_fee[poolId], 10);
            emit fastcashbonusevent(
                pooluserList[poolId][poolcurrRegisterUserID[poolId] - 1],
                poolId
            );
        } else {
            // USDTAddress.transfer((pooluserList[poolId][poolcurrRegisterUserID[poolId] - 2]),percentage(Pool_Entry_fee[poolId], 10));
            users[pooluserList[poolId][poolcurrRegisterUserID[poolId] - 2]].availableToWithdraw += percentage(Pool_Entry_fee[poolId], 10);
            users[pooluserList[poolId][poolcurrRegisterUserID[poolId] - 2]].fastCashBonus += percentage(Pool_Entry_fee[poolId], 10);
            emit fastcashbonusevent(
                pooluserList[poolId][poolcurrRegisterUserID[poolId] - 2],
                poolId
            );
        }
        // USDTAddress.transfer((pooluserList[poolId][poolactiveUserID[poolId]]),percentage(Pool_Entry_fee[poolId], 50));
        users[pooluserList[poolId][poolactiveUserID[poolId]]].availableToWithdraw +=percentage(Pool_Entry_fee[poolId], 50);
        address currentUseraddress = pooluserList[poolId][
            poolactiveUserID[poolId]
        ];
        users[currentUseraddress].autopoolInvestEarning += percentage(
            Pool_Entry_fee[poolId],
            50
        );
        emit getPoolPayment(
            msg.sender,
            pooluserList[poolId][poolactiveUserID[poolId]],
            poolId
        );
        /* Payment referral for pool payment   */

        payPoolPaymentReferral(1, currentUseraddress, poolId);

        poolusers[poolId][currentUseraddress].payment_received += 1;

        if (poolusers[poolId][currentUseraddress].payment_received >= 4) {
            poolcurrRegisterUserID[poolId]++;
            poolusers[poolId][currentUseraddress].id = poolcurrRegisterUserID[poolId];
            poolusers[poolId][currentUseraddress].payment_received = 0;
            poolusers[poolId][currentUseraddress].paid_entry = false;
            pooluserList[poolId][
                poolcurrRegisterUserID[poolId]
            ] = currentUseraddress;
            poolusers[poolId][currentUseraddress].reEntry++;
            emit regPoolEntry(
                currentUseraddress,
                poolId,
                block.timestamp,
                poolcurrRegisterUserID[poolId],
                users[currentUseraddress].id,
                false
            );
            poolactiveUserID[poolId] += 1;
        }
  
        USDTAddress.transfer(ownerWallet, percentage(Pool_Entry_fee[poolId], 5));
        USDTAddress.transfer(devWallet, percentage(Pool_Entry_fee[poolId], 5));
    }

    function getMaticBalance() public view returns (uint256) {
        return USDTAddress.balanceOf(address(this));
    }

    function percentage(uint256 price, uint256 per)
        internal
        pure
        returns (uint256)
    {
        return (price * per) / 100;
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
        uint256[] memory count = new uint256[](11);
        for (uint256 i = 1; i <= 10; i++) {
            count[i] = poolcurrRegisterUserID[i];
        }

        return count;
    }

    function claim() public
    {
         require(users[msg.sender].isExist, "User Not Registered");
         require(users[msg.sender].availableToWithdraw>0,"Nothing to withdraw");
         require(users[msg.sender].referredUsers>3,"Need 4 referral to claim amount");
         USDTAddress.transfer(msg.sender,users[msg.sender].availableToWithdraw);
         users[msg.sender].availableToWithdraw=0;
         emit Claim(msg.sender,users[msg.sender].availableToWithdraw);
    }
}