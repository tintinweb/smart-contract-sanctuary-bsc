/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

pragma solidity 0.6.5;

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

contract F2eV2 {
    address public ownerWallet;
    uint256 public currUserID = 0;
    uint256[4] public poolcurrRegisterUserID;
    uint256[4] public poolactiveUserID;
    uint256 public developmentFeeAutopool = 150;
    uint256 public developmentFeeRoi = 100;
    uint256 public totalInvested;
     uint256 public minStake = 5*1e18;//10000 *1e18;
    uint256 public maxStake = 100001 * 1e18;
    uint256 public dailyRoi = 175;
    uint256 public totalWithdrawn;
     uint24 constant day_secs = 60;//86400;
     uint32 constant percent_divide_by = 100000;

    IERC20 busd;

    struct UserStruct {
        bool isExist;
        uint256 id;
        uint256 referrerId;
        uint256 referredUsers;
        uint256 referralEarning;
        uint256 autopoolEarning;
        uint256 roiEarning;
        uint256 paymentReceived;
      
    }

    struct PoolUserStruct {
        bool isExist;
        uint256 id;
        uint256 payment_received;
    }

    struct RoiUser {
        bool isClaimed;
        uint256 earned;
        Deposit[] deposits;
        uint256 invested;
        uint256 last_withdraw;
        uint256 withdrawn;
    }

     struct Deposit {
        uint256 amount;
        uint40 time;
        uint256 withdrawn;
    }

    struct Package {
        uint40 invest_days;
        uint256 dailypercentage;
    }

 mapping(address => RoiUser) public roiUsers;
    mapping(address => UserStruct) public users;
    mapping(uint256 => address) public userList;
    mapping(uint256 => uint256) public referral_Commission;
    mapping(uint256 => uint256) public roi_Referral;
    mapping(uint256 => uint256) public Pool_Entry_fee;
    mapping(uint256 => mapping(address => PoolUserStruct)) public poolusers;
    mapping(uint256 => mapping(uint256 => address)) public pooluserList;
   mapping(address => Package) public packageList;
   

    //  event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);

    event getAutopoolReferralCommissionEvent(
        address _user,
        address _referral,
        uint256 _level,
        uint256 _time,
        uint256 _poolno
    );

    event regPoolEntry(
        address indexed _user,
        uint256 _level,
        uint256 _time,
        uint256 poolid,
        uint256 userid,
        bool paid_entry
    );

 event NewDeposit(address indexed user, uint256 amount, uint16 invest_days);
    event NewWithdrawn(address indexed user, uint256 amount);

    constructor() public {
        busd = IERC20(0x481694ee8EF4f2a516B1Ca7f54b78a42a9452eab);
        ownerWallet = msg.sender;

        Pool_Entry_fee[1] = 15 ether;
        Pool_Entry_fee[2] = 50 ether;
        Pool_Entry_fee[3] = 100 ether;

        referral_Commission[1] = 100;
        referral_Commission[2] = 50;
        referral_Commission[3] = 30;
        referral_Commission[4] = 20;
        referral_Commission[5] = 10;
        referral_Commission[6] = 50;
        referral_Commission[7] = 50;
        referral_Commission[8] = 50;
        referral_Commission[9] = 50;
        referral_Commission[10] = 50;
        referral_Commission[11] = 50;
        referral_Commission[12] = 50;
        referral_Commission[13] = 50;

        roi_Referral[1] = 50;
        roi_Referral[2] = 30;
        roi_Referral[3] = 30;
        roi_Referral[4] = 20;
        roi_Referral[5] = 20;

        UserStruct memory userStruct;

        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerId: 0,
            referredUsers: 0,
            referralEarning: 0,
            autopoolEarning: 0,
            roiEarning: 0,
            paymentReceived: 0
        });

        users[ownerWallet] = userStruct;

        userList[currUserID] = ownerWallet;

        PoolUserStruct memory pooluserStruct;

        /* Pool All */

        for (uint256 i = 1; i <= 3; i++) {
            poolcurrRegisterUserID[i]++;
            pooluserStruct = PoolUserStruct({
                isExist: true,
                id: poolcurrRegisterUserID[i],
                payment_received: 0
            });
            poolactiveUserID[i] = poolcurrRegisterUserID[i];
            poolusers[i][msg.sender] = pooluserStruct;
            pooluserList[i][poolcurrRegisterUserID[i]] = msg.sender;
        }
    }

    function BuyFirstPool(uint256 _referrerID) public payable {
        require(!users[msg.sender].isExist, "User Exist");

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerId: _referrerID,
            referredUsers: 0,
            referralEarning: 0,
            autopoolEarning: 0,
            roiEarning: 0,
            paymentReceived: 0
        });
        users[msg.sender] = userStruct;

        userList[currUserID] = msg.sender;
        //   payReferral(1,msg.sender);
        //    emit regLevelEvent(msg.sender, userList[_referrerID], now);
        buyPool(1);
    }

    function buyPool(uint256 poolId) public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(!poolusers[poolId][msg.sender].isExist, "Already in AutoPool");
        // require(msg.value == Pool_Entry_fee[poolId], "Incorrect Value");

        IERC20(busd).transferFrom(
            msg.sender,
            address(this),
            Pool_Entry_fee[poolId]
        );

        PoolUserStruct memory userStruct;
        poolcurrRegisterUserID[poolId]++;

        userStruct = PoolUserStruct({
            isExist: true,
            id: poolcurrRegisterUserID[poolId],
            payment_received: 0
        });
        poolusers[poolId][msg.sender] = userStruct;
        pooluserList[poolId][poolcurrRegisterUserID[poolId]] = msg.sender;

        levelcommissionDistribution(msg.sender, Pool_Entry_fee[poolId], poolId);

        PoolUserStruct memory pooluserstruct;
        poolcurrRegisterUserID[poolId]++;

        address currentUseraddress = pooluserList[poolId][
            poolactiveUserID[poolId]
        ];
        if (currentUseraddress == address(0)) {
            currentUseraddress = ownerWallet;
        }

        IERC20(busd).transfer(
            currentUseraddress,
            percentage(
                Pool_Entry_fee[poolId],
                percentage(Pool_Entry_fee[poolId], 600)
            )
        );

        poolusers[poolId][currentUseraddress].payment_received += 1;

        if (poolusers[poolId][currentUseraddress].payment_received >= 2) {
            poolcurrRegisterUserID[poolId]++;
            pooluserstruct = PoolUserStruct({
                isExist: true,
                id: poolcurrRegisterUserID[poolId],
                payment_received: 0
            });
            poolusers[poolId][currentUseraddress] = pooluserstruct;
            pooluserList[poolId][
                poolcurrRegisterUserID[poolId]
            ] = currentUseraddress;
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
        // payable((devWallet)).transfer(percentage(Pool_Entry_fee[poolId],5));

        IERC20(busd).transfer(
            ownerWallet,
            percentage(Pool_Entry_fee[poolId], developmentFeeAutopool)
        );
    }

    // function roi(uint256 _amount) public {
    //     require(_amount >= 5, "min investment 5 BUSD");
    //     if (!roiuser[msg.sender].isExist) {
    //         RoiUserStruct memory roiuserstruct;
    //         roiuserstruct = RoiUserStruct({
    //             isExist: true,
    //             referrerId: users[msg.sender].referrerId,
    //             payment_received: _amount,
    //             time: block.timestamp
    //         });

    //         roiuser[msg.sender] = roiuserstruct;
    //         totalInvested += _amount;
    //     } else {
    //         roiuser[msg.sender].payment_received += _amount;
    //         totalInvested += _amount;
    //     }

    //     address referer;
    //     bool sent = false;

    //     for (uint256 i = 1; i <= 5; i++) {
    //         referer = userList[users[msg.sender].referrerId];
    //         sent = address(uint160(referer)).send(
    //             percentage(_amount, roi_Referral[i])
    //         );
    //     }

    //     IERC20(busd).transfer(
    //         ownerWallet,
    //         percentage(_amount, developmentFeeRoi)
    //     );
    // }

    // function withdraw() public {
    //     require(roiuser[msg.sender].isExist, "Invalid user");

    //     users[msg.sender].roiEarning =
    //         (roiuser[msg.sender].time - block.timestamp) *
    //         dailyRoi;
    // }


 function roi(uint16 _amount) external payable {
        
        require(_amount >= minStake && _amount <= maxStake, "Invalid amount");
      //         RoiUserStruct memory roiuserstruct;
    //         roiuserstruct = RoiUserStruct({

RoiUser storage roiUser = roiUsers[msg.sender];
//roiUsers storage roiUsers
roiUser.deposits.push(
            Deposit({
                  amount: _amount,
                time: uint40(block.timestamp),
              withdrawn: 0
            })
        );
        roiUser.invested += _amount;

        totalInvested += _amount;
        
      //  emit NewDeposit(msg.sender, amount, _package);
    }

    function withdraw() external
    {
        
        uint256 amount = revenueOf(msg.sender,block.timestamp);
        require(amount>0,"Nothing to withdraw");
        //user.withdrawn += amount;
        totalWithdrawn += amount;
        payable(msg.sender).transfer(amount);
        emit NewWithdrawn(msg.sender, amount);
    }


 function revenueOf(address _addr, uint256 _at)
        public
        view
        returns (uint256 value)
    {
        RoiUser storage _RoiUser = roiUsers[_addr];

        for (uint256 i = 0; i < _RoiUser.deposits.length; i++) {
            Deposit storage dep = _RoiUser.deposits[i];
         
                Package storage profit_percent = packageList[_addr];

                uint40 time_end = dep.time +
                    profit_percent.invest_days *
                    day_secs;
                uint256 from = _RoiUser.last_withdraw > dep.time
                    ? _RoiUser.last_withdraw
                    : dep.time;
                uint40 to = _at > time_end ? time_end : uint40(_at);

                if (from < to) {
                    value +=
                        ((dep.amount *
                            (to - from) *
                            profit_percent.dailypercentage) / day_secs) /
                        percent_divide_by;
                }
            
        }

        return value;
    }


    function sendBalance() private {
        if (getMaticBalance() > 0) {
            if (!address(uint160(ownerWallet)).send(getMaticBalance())) {
                users[ownerWallet].roiEarning += getMaticBalance();
            }
        }
    }

    function levelcommissionDistribution(
        address _user,
        uint256 _amount,
        uint256 _poolno
    ) internal {
        address newAddress = _user;
        for (uint256 i = 1; i <= 13; i++) {
            address referer = userList[users[newAddress].referrerId];

            if (referer == address(0)) {
                referer = ownerWallet;
            }
            IERC20(busd).transfer(
                referer,
                percentage(_amount, referral_Commission[i])
            );

            newAddress = referer;

            emit getAutopoolReferralCommissionEvent(
                _user,
                referer,
                i,
                block.timestamp,
                _poolno
            );
        }
    }

    function getMaticBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function percentage(uint256 price, uint256 per)
        internal
        pure
        returns (uint256)
    {
        return (price * per) / 1000;
    }

    function viewUserReferral(address _user) public view returns (address) {
        return userList[users[_user].referrerId];
    }

    function checkUserExist(address _user) public view returns (bool) {
        return users[_user].isExist;
    }
}