/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
}

interface EscroeLike {
    function getHostingInfo(uint256 order) external view returns (address partyA,address partyB,uint256 assetAmount,bool lock);
    function arbitration(uint256 order,uint256 partyAAmount,uint256 partyBAmount) external;
}
interface SBTLike {
    function isAbitrator(address) external view returns (bool);
}

contract Arbitration {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "arb/not-authorized");
        _;
    }
    // --- Data ---
    struct OrderInfo {
        uint256 id;                 //仲裁订单编号
        address escroeControct;     //托管合约地址
        uint256 escroeId;           //托管订单号
        address[4] party;           //party[0]:甲方,party[1]:乙方,party[2]:甲方仲裁员,party[3]:乙方仲裁员
        uint256 assetAmount;        //托管金额
        uint256 arbStatus;          //仲裁状态
        uint256 numberApplicants;   //第二轮报名人数
        uint256[4] time;            ///仲裁时间参数，
                                        //0：第一轮仲裁启动时间，
                                        //1:第二轮报名启动时间，
                                        //2:第二轮报名结束时间，
                                        //3:方案被当事一方采纳的时间，同时是另一方上诉窗口启动时间
        uint256[2] appealFee;              //每个订单当事人缴纳的申诉费
        address[]  inviteesnForA;          //第一轮仲裁甲方邀请的仲裁员数组
        address[]  inviteesnForB;          //第一轮仲裁乙方邀请的仲裁员数组
        uint256[5] appealComp;             //0-3:第一论仲裁当事人设置的仲裁方案,4:arbitrationBond
        uint256[5][] scheme;               //第二轮仲裁方案数组
        uint256[] randomForOrder;          //第二轮仲裁入选仲裁员的随机数
        address[] successer;               //第二轮仲裁入选仲裁员的地址
    }
    struct UserInfo {
        address owner;                  //仲裁员地址
        string message;                 //注册信息
        uint256 balanceMar;             //我的保证金余额
        uint256 idForArb;               //我的仲裁员编号
        uint256[] appeal;               //我申述的订单
        uint256[] invite;               //我第一轮被邀请的订单
        uint256[] NumberOfEnrollments;  //我第二轮报名的订单
        uint256[] succeed;              //我成功仲裁的订单
        bool      lock;                 //我的锁定状态
    }
    event Rest(uint256  indexed  order,
               address  indexed  usr);

    event Init(uint256  indexed   order, 
               address            escroeControct,
               uint256            escroeId,
               address  indexed   partyA,
               address  indexed   partyB);

    event Asse(uint256  indexed  order, 
               uint256  indexed  arbStatus,
               uint256  indexed  time);   

    event Hope(uint256  indexed  order, 
               address  indexed  owner,
               address  indexed  usr);   

    event Register(uint256  indexed  order, 
                   uint256           people,
                   uint256  indexed  time1,
                   uint256  indexed  time2);

    event Vote(uint256  indexed  order,
               uint256  indexed  pau,
               uint256           weight,
               address           usr);

    event Acce(uint256  indexed  order, 
               uint256  indexed  pau,
               uint256          time);

    mapping(uint256 =>mapping(uint256 =>mapping(uint256 =>uint256)))      public weight;             //仲裁方案投票权重
    mapping(uint256 =>mapping(uint256 =>mapping(address =>uint256)))      public voteMark;           //投票状态
    
    mapping(uint256 =>mapping(address =>address))       public invitingParty;                        //第一轮仲裁被邀请方
    mapping(uint256 =>mapping(uint256 =>uint256))       public selectedScheme;                       //投票通过的仲裁方案编号
    mapping(address =>mapping(uint256 =>uint256))       public idForEscroe;                          //资产托管平台对应订单的仲裁编号   
    

    mapping(uint256 =>mapping(address =>bool))       public isSuccess;                               //第二轮报名成功标志
    mapping(uint256 => address)                         public addressForRandom;                     //随机数对应的地址

    mapping(bytes32 => address)                         public repeatEnrollmentCheck;                //第二轮报名查重
    mapping(bytes32 => uint256)                         public schemeCheck;                          //仲裁方案查重

    mapping(uint256 => address)                         public arbFroId;                             //仲裁员编号对应的地址
    mapping(uint256 => OrderInfo)                       public orderInfo;                            //仲裁订单信息
    mapping(address => UserInfo)                        public userInfo;                             //参与者信息
    TokenLike                                           public mar = TokenLike(0xe4A05741ed522c578615bd97c1f9347d96a395C9);  // 保证金合约地址
    SBTLike                                             public SBT;                                  //特邀仲裁员识别地址
    address                                             public foundsAddress;                        //惩罚款接收地址
   //人数相关
    uint256                                             public maxPeople = 12;                       // 第二轮报名最多人数的系数
    uint256                                             public quorum = 5;                           //仲裁员法定人数
    uint256                                             public numberRange = 7;                      //合格仲裁员范围的最小编号
    uint256                                             public maxnum = 2;                           //第一轮每一方能邀请的最多人数
 
   //金额相关
    uint256                                             public arbitrationBond = 100*1E18;           //每仲裁一单释放的保证金
    uint256                                             public minMar = 1000*1E18;                   //申请仲裁员要求的最低保证金
    uint256                                             public minFee = 10*1E18;                     //申诉要支付的最低申诉费

   //时间相关
    uint256                                             public voteCycle = 3600;                     //仲裁员投票的最长时间
    uint256                                             public communityVoteCycle = 3600;            //等待社区投票的最长时间
    uint256                                             public firstRoundInterval = 60;              // 第一轮仲裁等待另一方投票的最短时间
    uint256                                             public secondRegistrationWaitingTime = 3600; //第二轮报名等待时间

    uint256                                             public arbId;                                //仲裁员总数
    uint256                                             public order;                                //仲裁订单总数

    constructor() {
        wards[msg.sender] = 1;
    }
   ///设置参数
	function setAddress(uint256 what, address ust) external auth{
	    if (what == 1) foundsAddress = ust;
        if (what == 2) mar = TokenLike(ust);
        if (what == 3) SBT = SBTLike(ust);
	}
	function setVariable(uint256 what, uint256 data) external auth{
        if (what == 1) firstRoundInterval = data;
        if (what == 2) secondRegistrationWaitingTime = data;
        if (what == 3) voteCycle = data;
        if (what == 4) communityVoteCycle = data;
        if (what == 5) arbitrationBond = data;
        if (what == 6) minFee = data;
        if (what == 7) numberRange = data;
        if (what == 8) maxnum = data;
        if (what == 9) maxPeople = data;
        if (what == 10) quorum = data;
        if (what == 11) minMar = data;
	}
   ///仲裁员资格
    //通过抵押代币成为仲裁员
    function arbRegister(string memory data,uint256 arbFee) external { 
        UserInfo storage user = userInfo[msg.sender];
        if(bytes(data).length != 0) commun(data);
        require(user.idForArb == 0 ,"arb/already-apply");
        require(arbFee >= minMar,"arb/Less-minimum");
        arbId +=1;
        arbFroId[arbId] = msg.sender;
        user.idForArb = arbId;
        mar.transferFrom(msg.sender, address(this), arbFee);
        user.balanceMar += arbFee;
    }
    //判断是否为合格仲裁员  
    function isQualified(address usr) public view returns(bool qualified) { 
        UserInfo storage user = userInfo[usr];
        if (((user.idForArb <= numberRange && user.idForArb != 0) || isInvited(usr) && userInfo[usr].balanceMar >= minMar) && !user.lock) qualified = true;
        else qualified = false;
    } 
    //社区投票弹劾仲裁员，可以罚没部分保证金
    function Recall(address usr,uint256 fine) external auth {
        UserInfo storage user = userInfo[usr];
        if (user.idForArb != 0 ) {
            if(user.balanceMar > fine) {
               user.balanceMar -= fine;
               mar.transfer(foundsAddress,fine);
            }
            uint256 id =  user.idForArb;
            cover(id);
        }
    }   
    // 仲裁员赎回保证金
    function exitArbSelf(uint256 wad) public { 
        exitArb(msg.sender, wad);
    } 
    function exitArb(address usr, uint256 wad) internal { 
        UserInfo storage user = userInfo[usr];
        require(!user.lock,"arb/Suspend-withdrawal");
        require(user.balanceMar >= wad,"arb/balance-not");
        user.balanceMar -= wad;
        mar.transfer(usr, wad);
        if (user.idForArb != 0 && user.balanceMar < minMar) {
            uint256 id =  user.idForArb;
            cover(id);
        }
    }
    //仲裁员补位算法
    function cover(uint256 id) internal  {
        address usr = arbFroId[id];
        arbFroId[id] = address(0);
        userInfo[usr].idForArb = 0;
        while (arbFroId[id+numberRange] != address(0)) {
               arbFroId[id] = arbFroId[id+numberRange];
               userInfo[arbFroId[id+numberRange]].idForArb = id ;   
               id += numberRange;
        }   
        if (arbId != id) {
            arbFroId[id] = arbFroId[arbId];
            userInfo[arbFroId[arbId]].idForArb = id;
        }   
        arbFroId[arbId] = address(0);
        arbId -= 1;
    }
    // 特邀仲裁员不受位置限制
    function isInvited(address sender) public view returns (bool) {
        if (address(SBT) == address(0)) return false;
        else return SBT.isAbitrator(sender);
     }
    ///第一轮仲裁 
    //初始化订单信息
    function init(address escroeControct,uint256 i) public returns(uint256) { 
        require(idForEscroe[escroeControct][i] == 0, "arb/has been initialized");
        (address partyA,address partyB,uint256 assetAmount,bool lock) = EscroeLike(escroeControct).getHostingInfo(i);
        require(lock, "arb/Assets are not locked");
        order +=1;
        idForEscroe[escroeControct][i] = order;
        OrderInfo storage arbOrder = orderInfo[order]; 
        arbOrder.escroeControct = escroeControct;
        arbOrder.escroeId = i;
        arbOrder.party[0] = partyA;
        arbOrder.party[1] = partyB;
        arbOrder.assetAmount = assetAmount;
        userInfo[partyA].appeal.push(order);
        userInfo[partyB].appeal.push(order);
        emit Init(order,escroeControct,i,partyA,partyB);
        return order;
    }
    //支付仲裁费
    function payAppealFee(uint256 _order,uint256 _appealFee) public{ 
        OrderInfo storage arbOrder = orderInfo[_order];
        mar.transferFrom(msg.sender, address(this), _appealFee);
        if (arbOrder.party[0] == msg.sender ) arbOrder.appealFee[0] += _appealFee;
        else if (arbOrder.party[1] == msg.sender ) arbOrder.appealFee[1] += _appealFee;
        else revert("arb/not-swapper");
    }

    //邀请仲裁员
    function inviteArbitrator(uint256 _order,address usr) external  { 
        OrderInfo storage arbOrder = orderInfo[_order];
        if (arbOrder.party[0] == msg.sender ) {
           require(arbOrder.appealFee[0] >= minFee, "arb/Party A's appeal fee is insufficient");
           require(arbOrder.inviteesnForA.length < maxnum,"arb/Has-been-MAX");
           arbOrder.inviteesnForA.push(usr);
        }else if (arbOrder.party[1] == msg.sender ) {
           require(arbOrder.appealFee[1] >= minFee, "arb/Party B's appeal fee is insufficient");
           require(arbOrder.inviteesnForB.length < maxnum,"arb/Has-been-MAX");
           arbOrder.inviteesnForB.push(usr);
        }else revert("arb/not-swapper");   
        require(invitingParty[_order][usr] == address(0),"arb/Has-been-invited");    
        require(isQualified(usr),"arb/not-qualified arbitrator");
        invitingParty[_order][usr] = msg.sender;
        userInfo[usr].invite.push(_order);
        emit Hope(_order,msg.sender,usr);
    } 
    //当事双方设置仲裁诉求
    function setComp(string memory data,uint256 _appealFee,address escroeControct, uint256 i, uint256 amountOfpartyA, uint256 amountOfpartyB) external {
        if(idForEscroe[escroeControct][i] == 0) init(escroeControct,i);
        if(bytes(data).length != 0) commun(data);
        uint256 _order = idForEscroe[escroeControct][i];
        if(_appealFee !=0) payAppealFee(_order,_appealFee);
        OrderInfo storage arbOrder = orderInfo[_order];
        require(arbOrder.assetAmount == amountOfpartyA + amountOfpartyB, "arb/Quantity does not match");
        if(arbOrder.party[0] == msg.sender ) {
            require(arbOrder.arbStatus == 0 || arbOrder.arbStatus == 2,"arb/1-Quantity ccan not be modified"); 
            arbOrder.appealComp[0] = amountOfpartyA;
            arbOrder.appealComp[1] = amountOfpartyB;
        }else if(arbOrder.party[1] == msg.sender ) {
            require(arbOrder.arbStatus == 0 || arbOrder.arbStatus == 1,"arb/2-Quantity ccan not be modified"); 
            arbOrder.appealComp[2] = amountOfpartyA;
            arbOrder.appealComp[3] = amountOfpartyB;
        }else revert("arb/not-swapper");   
    }
    //双方和解，甲方执行乙方方案，或乙方执行甲方方案
    function reconciliation(uint256 _order,uint256 amountOfpartyA, uint256 amountOfpartyB) external  {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(arbOrder.arbStatus < 3, "arb/relTime-not");
        if(arbOrder.party[0] == msg.sender) {
            require(arbOrder.appealComp[2] == amountOfpartyA && arbOrder.appealComp[3] == amountOfpartyB, "arb/1-Allocation quantity does not match");
        }
        else if(arbOrder.party[1] == msg.sender) {
            require(arbOrder.appealComp[0] == amountOfpartyA && arbOrder.appealComp[1] == amountOfpartyB, "arb/2-Allocation quantity does not match");
        }else revert("arb/not-swapper");
        try EscroeLike(arbOrder.escroeControct).arbitration(arbOrder.escroeId, amountOfpartyA, amountOfpartyB) {} catch {}
        if(arbOrder.arbStatus !=0) arbitrationFeeAllocation(_order);
        arbOrder.arbStatus = 5;
    }

    //仲裁员弃权或投赞成票，各方只有第一个仲裁员的投票有效
    function firstRoundOfArbitration(uint256 _order,uint256 amountOfpartyA, uint256 amountOfpartyB) external {
        OrderInfo storage arbOrder = orderInfo[_order];
        UserInfo storage user = userInfo[msg.sender];
        if (arbOrder.time[0] == 0) arbOrder.time[0] = block.timestamp;
        require(firstRoundInterval > block.timestamp - arbOrder.time[0], "arb/relTime-not");
        require(isQualified(msg.sender),"arb/Insufficient-conditions");
        if(arbOrder.appealComp[4] == 0 ) arbOrder.appealComp[4] = arbitrationBond;
        user.balanceMar -= arbOrder.appealComp[4];
        if (user.balanceMar < minMar) cover(user.idForArb);
        if (invitingParty[_order][msg.sender] == arbOrder.party[0] && (arbOrder.arbStatus == 0 || arbOrder.arbStatus == 2)) {
            require(arbOrder.appealComp[0] == amountOfpartyA && arbOrder.appealComp[1] == amountOfpartyB, "arb/1-Allocation quantity does not match");
            arbOrder.arbStatus += 1;
            arbOrder.party[2] = msg.sender;
        }
        else if (invitingParty[_order][msg.sender] == arbOrder.party[1] && (arbOrder.arbStatus == 0 || arbOrder.arbStatus == 1)) {
            require(arbOrder.appealComp[2] == amountOfpartyA && arbOrder.appealComp[3] == amountOfpartyB, "arb/2-Allocation quantity does not match");
            arbOrder.arbStatus += 2;
            arbOrder.party[3] = msg.sender;       
        } else revert("arb/Invalid-arbitration");
        if(arbOrder.arbStatus == 3) {
            arbOrder.randomForOrder = new uint256[](quorum);
            arbOrder.successer = new address[](quorum);
        }
        emit Asse(_order,arbOrder.arbStatus,block.timestamp);
    } 
    //执行第一轮仲裁结果
    function executeFirstRoundOfArbitration(uint256 _order) external {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(firstRoundInterval < block.timestamp - arbOrder.time[0], "arb/relTime-not");
        if (arbOrder.arbStatus == 1) try EscroeLike(arbOrder.escroeControct).arbitration(arbOrder.escroeId, arbOrder.appealComp[0], arbOrder.appealComp[1]) {} catch {}
        else if (arbOrder.arbStatus == 2)  try EscroeLike(arbOrder.escroeControct).arbitration(arbOrder.escroeId, arbOrder.appealComp[2], arbOrder.appealComp[3]) {} catch {}
        else revert("arb/Invalid-arbitration");
        arbitrationFeeAllocation(_order);
        arbOrder.arbStatus = 5;
    }
    //执行第一轮仲裁费分配
    function arbitrationFeeAllocation(uint256 _order) internal {
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256 partyAfee = arbOrder.appealFee[0];
        uint256 partyBfee = arbOrder.appealFee[1];
        address arbiter;
        uint256 wad;
        //@ara==1 User wins，
        //The arbitration fee paid by the user plus the deposit paid by the arbitrator voting for the user shall be returned to the arbitrator
        if (arbOrder.arbStatus ==1){
            arbiter = arbOrder.party[2];
            wad = partyAfee + arbOrder.appealComp[4];
            if (partyBfee >0 ) mar.transfer(arbOrder.party[0], partyBfee);
        }
        // @ara==2 Merchant wins，
        // The arbitration fee paid by the merchant and the deposit paid by the arbitrator voting for the merchant shall be returned to the arbitrator
        if(arbOrder.arbStatus ==2) {
            arbiter = arbOrder.party[3];
            wad = partyBfee + arbOrder.appealComp[4];
            if (partyAfee >0 ) mar.transfer(arbOrder.party[1], partyAfee);
        }
        userInfo[arbiter].succeed.push(_order);
        mar.transfer(arbiter, wad);
     } 
    /// 第二轮仲裁
    // 第二轮报名
    function arbTwoRegister(uint256 _order) external  {
        OrderInfo storage arbOrder = orderInfo[_order];
        UserInfo storage user = userInfo[msg.sender];
        require(arbOrder.arbStatus >= 3, "arb/itration-not-end");
        require(arbOrder.time[2] == 0, "arb/Register-already-end");
        require(isQualified(msg.sender),"arb/not-meet-requirements");
        user.NumberOfEnrollments.push(_order);
        uint256  people = arbOrder.numberApplicants;
        if (people == 0) arbOrder.time[1] = block.timestamp;
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, _order, arbOrder.time[1]));
        require(repeatEnrollmentCheck[hash] == address(0), "arb/signer-already-exists");
        repeatEnrollmentCheck[hash] = msg.sender;
        people += 1;
        uint256 rum = arbOrder.randomForOrder.length;
        if (people >= rum && secondRegistrationWaitingTime < block.timestamp-arbOrder.time[1]) arbOrder.time[2] = block.timestamp;
        if (people == rum*maxPeople/10)  arbOrder.time[2] = block.timestamp; 
        arbOrder.numberApplicants = people;
        uint256 random = uint256(keccak256(abi.encodePacked(msg.sender, blockhash(block.number-1))));
        if (random > arbOrder.randomForOrder[0]) {
            address addressForMin = addressForRandom[arbOrder.randomForOrder[0]];
            
            //Release the frozen status of the replaced arbitrator in the first round of arbitration contract
            if (addressForMin != address(0)) {
                userInfo[addressForMin].lock = false;
                isSuccess[_order][addressForMin] = false ;
            }
            arbOrder.randomForOrder[0] = random;
            addressForRandom[random] = msg.sender;
            isSuccess[_order][msg.sender] = true;
            userInfo[msg.sender].lock = true;
            //Re ranking of candidates
            for (uint n = 0; n < rum-1; n++) {
                 if (arbOrder.randomForOrder[n] > arbOrder.randomForOrder[n+1]) {
                     random = arbOrder.randomForOrder[n+1]; 
                     arbOrder.randomForOrder[n+1] = arbOrder.randomForOrder[n]; 
                     arbOrder.randomForOrder[n] = random;
                 }
            }
        }
        emit Register(_order,people,arbOrder.time[1],arbOrder.time[2]);
    }

    //第二轮仲裁员设置仲裁方案
    function setScheme(uint256 _order, uint256 amountOfpartyA, uint256 amountOfpartyB,uint256 marForA, uint256 marForB,uint256 fine) external returns(uint256){
       OrderInfo storage arbOrder = orderInfo[_order];
       require(voteCycle > block.timestamp - arbOrder.time[2] && arbOrder.time[2] != 0 , "arb/arbitration-not-end");
       require(arbOrder.assetAmount == amountOfpartyA + amountOfpartyB, "arb/Allocation quantity does not match");
       if(arbOrder.arbStatus !=4) require(2*arbOrder.appealComp[4] == marForA + marForB + fine, "arb/margin quantity does not match");
       require(isSuccess[_order][msg.sender], "arb/Not selected");
       bytes32 hash = keccak256(abi.encodePacked(_order,amountOfpartyA,amountOfpartyB));
       if (schemeCheck[hash] == 0) {          
           arbOrder.scheme.push([amountOfpartyA,amountOfpartyB,marForA,marForB,fine]);
           schemeCheck[hash] = arbOrder.scheme.length;
           vote(order,arbOrder.scheme.length);
           return  arbOrder.scheme.length;
       }else {
           return schemeCheck[hash];
       }
    }
    //投票
    function vote(uint256 _order, uint256 schemeId) public returns(uint256){
       OrderInfo storage arbOrder = orderInfo[_order];
       require(voteCycle > block.timestamp - arbOrder.time[2] && arbOrder.time[2] != 0 , "arb/arbitration-not-end");
       uint256 timc = arbOrder.time[1];
       require(isSuccess[_order][msg.sender] && voteMark[_order][timc][msg.sender] == 0, "arb/voter-not");
       weight[_order][timc][schemeId] += 1; // Cumulative voting weight of arbitration scheme
       uint256 minVote = arbOrder.randomForOrder.length/2 + 1;
       if(weight[_order][timc][schemeId] == minVote) selectedScheme[_order][timc] = schemeId;         
       voteMark[_order][timc][msg.sender] = schemeId;       // Voting mark
       emit Vote(_order,schemeId,weight[_order][timc][schemeId],msg.sender);
       return weight[_order][timc][schemeId];
    }  
     //取消投票
    function cancelVote(uint256 _order, uint256 schemeId) public {
       OrderInfo storage arbOrder = orderInfo[_order];
       require(voteCycle > block.timestamp - arbOrder.time[2] && arbOrder.time[2] != 0 , "arb/arbitration-not-end");
       uint256 timc = arbOrder.time[1];
       require(arbOrder.time[3] == 0 , "arb/schem-been-adopted");
       require(voteMark[_order][timc][msg.sender] == schemeId, "arb/schem-been-unadopted");
       weight[_order][timc][schemeId] -= 1;  // Deduction of voting weight of arbitration scheme
       uint256 minVote = arbOrder.randomForOrder.length/2 + 1;
       if(weight[_order][timc][schemeId] == minVote-1) selectedScheme[_order][timc] = 0;          
       voteMark[_order][timc][msg.sender] = 0;                                      // Restoration of voting rights
       emit Vote(_order,schemeId,weight[_order][timc][schemeId],msg.sender);
    }
    function voteOrcancel(uint256 _order, uint256 schemeId) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256 timc = arbOrder.time[1];
        if(voteMark[_order][timc][msg.sender] == schemeId) cancelVote(_order,schemeId);
        else if(voteMark[_order][timc][msg.sender] != schemeId) vote(_order,schemeId);
    }

    //仲裁结果超过时间未被采纳，可以重新申请组建仲裁庭，申请一方需要重新支付仲裁费
    function restartForParty(uint256 _order) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        //The arbitration scheme has not been adopted and the voting waiting time has passed
        require(arbOrder.time[3] == 0, "arb/already-accept");
        require(selectedScheme[_order][arbOrder.time[1]] != 0, "arb/NotEnoughVotes");
        require(voteCycle < block.timestamp - arbOrder.time[2] && arbOrder.time[2] != 0 , "arb/Voting time has expired");
        
        //Except for both parties, the arbitrators selected in this round may cancel the arbitration panel
        require(arbOrder.party[0] == msg.sender || arbOrder.party[1] == msg.sender, "arb/not-swapper");
        uint256 fee = arbOrder.appealFee[0] + arbOrder.appealFee[1];
        arbitrationFeeAllocationForTwo(_order);
        arbOrder.appealFee = [0,0];
        payAppealFee(_order,2*fee);
        cancelTribunal(_order);
        if(arbOrder.arbStatus < 4) marAllocationForOne(_order,selectedScheme[_order][arbOrder.time[1]]);
    }
    //投票时间结束，未达到法定票数，任何人可以撤销仲裁庭,仲裁员没有仲裁费，当事人也不需要再支付申诉费
    function restartForPartyNotEnoughVotes(uint256 _order) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        //The arbitration scheme has not been adopted and the voting waiting time has passed
        require(selectedScheme[_order][arbOrder.time[1]] == 0, "arb/have Enough Votes");
        require(voteCycle < block.timestamp - arbOrder.time[2] && arbOrder.time[2] != 0 , "arb/Voting time has expired");
        cancelTribunal(_order);
    }
    function reboot(uint256 _order) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(voteCycle < block.timestamp - arbOrder.time[2] && arbOrder.time[2] != 0 , "arb/Voting time has expired");
        if(selectedScheme[_order][arbOrder.time[1]] == 0) restartForPartyNotEnoughVotes(_order);
        else if(selectedScheme[_order][arbOrder.time[1]] != 0) restartForParty(_order);
    }
    //撤销仲裁结果
    function cancelTribunal(uint256 _order) internal {
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256[] memory randoms = arbOrder.randomForOrder;
        uint256 rum = arbOrder.randomForOrder.length;
        for (uint n = 0; n < rum; n++) {
             address arbiter = addressForRandom[arbOrder.randomForOrder[n]];
             isSuccess[_order][arbiter] = false;
             userInfo[arbiter].lock = false;
             randoms[n] = 0;
        }
        
        //Clear arbitration data
        arbOrder.randomForOrder = randoms;
        arbOrder.time[1] = 0;
        arbOrder.time[2] = 0;
        arbOrder.numberApplicants = 0;
        emit Rest(_order, msg.sender);
    }
    //仲裁结果要被采纳后才会生效
    function accept(uint256 _order, uint256 schemeId) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(arbOrder.party[0] == msg.sender || arbOrder.party[1] == msg.sender, "arb/not-swapper");
        uint256 minVote = arbOrder.randomForOrder.length/2 + 1;
        require(weight[_order][arbOrder.time[1]][schemeId] >= minVote, "arb/Agreement-not-votes");
        require(arbOrder.time[3] == 0, "arb/already-accept");
        arbOrder.time[3] = block.timestamp;
        if(arbOrder.arbStatus < 4) marAllocationForOne(_order,schemeId);
        emit Acce(_order,schemeId,block.timestamp);
    }
    //一方采纳后，另一方可以上诉至社区（需要支付更高的上诉费），社区要么维持原判，要么否决仲裁结果，并可弹劾作恶的仲裁员
    function notAccept(uint256 _order) public auth {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(communityVoteCycle > block.timestamp - arbOrder.time[3], "arb/not-time");
        arbOrder.time[3] = 0;
        cancelTribunal(_order);
    }

    //执行第二轮仲裁结果
    function executeFroTwo(uint256 _order, uint256 schemeId) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(selectedScheme[_order][arbOrder.time[1]] == schemeId, "arb/The number of votes did not meet the statutory requirements");
        require((arbOrder.time[3] != 0 && communityVoteCycle < block.timestamp - arbOrder.time[3]) || block.timestamp > arbOrder.time[2] + voteCycle + communityVoteCycle, "arb/not-accept or Community appeal not over");
        require(arbOrder.arbStatus != 5, "arb/already-execute");
        try EscroeLike(arbOrder.escroeControct).arbitration(arbOrder.escroeId,arbOrder.scheme[schemeId-1][0],arbOrder.scheme[schemeId-1][1]) {} catch {}
        arbitrationFeeAllocationForTwo(_order); 
        if(arbOrder.arbStatus < 4) marAllocationForOne(_order,schemeId);
        arbOrder.arbStatus = 5;
    }
    //第一轮仲裁员保证金分配
     function marAllocationForOne(uint256 _order,uint256 schemeId) internal{
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256 marForA = arbOrder.scheme[schemeId-1][2];
        uint256 marForB = arbOrder.scheme[schemeId-1][3];
        uint256 fine = arbOrder.scheme[schemeId-1][4];
        address arbiterA = arbOrder.party[2];
        address arbiterB = arbOrder.party[3];
        mar.transfer(arbiterA, marForA);
        mar.transfer(arbiterB, marForB);
        mar.transfer(foundsAddress, fine);
        arbOrder.arbStatus = 4;
        }
    //第二轮仲裁员分配仲裁费
    function arbitrationFeeAllocationForTwo(uint256 _order) internal{
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256 fee = arbOrder.appealFee[0] + arbOrder.appealFee[1];
        uint256 rum = arbOrder.randomForOrder.length;
        uint256 average = fee/rum;
        uint256[] memory randoms = arbOrder.randomForOrder;
        for (uint n = 0; n < rum; n++) {
             address arbiter = addressForRandom[randoms[n]];
             mar.transfer(arbiter, average);
             userInfo[arbiter].lock = false;
             exitArb(arbiter, arbOrder.appealComp[4]);
             userInfo[arbiter].succeed.push(_order);
        }
    }
    function commun(string memory data) public  {
        userInfo[msg.sender].message = data;
    }
    function communForUsr(address usr,string memory data) public auth{
        require(tx.origin == usr,"arb/1");
        userInfo[usr].message = data;
    }

    function getUserInfo(address usr) external view returns (UserInfo memory) {
        return userInfo[usr];
    }
    function getOrderInfo(uint256 _order) external view returns (OrderInfo memory) {
        OrderInfo memory arbOrder = orderInfo[_order];
        uint256 length = arbOrder.randomForOrder.length;
        for(uint i = 0; i <length ; ++i) {
            arbOrder.successer[i] = addressForRandom[arbOrder.randomForOrder[i]];
        }
        return arbOrder;
    }
}