/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
}

interface EscroeLike {
    function getHostingInfo(uint256 order) external view returns (address partyA,address partyB,uint256 assetAmount);
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
        uint256 id;              //仲裁订单编号
        address escroeControct;  //托管合约地址
        uint256 escroeId;        //托管订单号
        address partyA;          //甲方
        address partyB;          //乙方
        uint256 assetAmount;     //托管金额
        uint256 arbStatus;       //仲裁状态
        uint256 numberApplicants;  //第二轮报名人数
        address votePartyA;        //为甲方投票的投票仲裁员
        address votePartyB;        //为乙方投票的投票仲裁员
                                   ///仲裁时间参数，
        uint256 time0;           //0：第一轮仲裁启动时间，
        uint256 time1;           //1:第二轮报名启动时间，
        uint256 time2;           //2:第二轮报名结束时间，
        uint256 time3;           //3:方案被当事一方采纳的时间，同时是另一方上诉窗口启动时间
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
        uint256 appealLength;           //我申述的订单
        uint256 inviteLength;           //我第一轮被邀请的订单数量
        uint256 EnrollmentsLength;      //我第二轮报名的订单数量
        uint256 succeedLength;          //我成功仲裁的订单数量
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
    mapping(uint256 =>mapping(address =>uint256))       public isSuccess;                  //第二轮报名成功标志
    mapping(uint256 =>mapping(address =>uint256))       public appealFee;                  //每个订单当事缴纳的申诉费
    mapping(uint256 =>mapping(address =>address[]))     public numberOfInviteesn;          //第一轮仲裁邀请的仲裁员数组
    mapping(uint256 =>mapping(address =>address))       public invitingParty;              //第一轮仲裁被邀请方
    mapping(uint256 =>mapping(address =>uint256[2]))    public appealComp;                 //第一论仲裁当事人设置的仲裁方案
    mapping(uint256 =>mapping(uint256 =>uint256[5]))    public scheme;                     //第二轮仲裁方案数组
    mapping(uint256 =>mapping(uint256 =>uint256))       public selectedScheme;             //投票通过的仲裁方案编号
    mapping(address =>mapping(uint256 =>uint256))       public idForEscroe;                //资产托管平台对应订单的仲裁编号
    mapping(uint256 => uint256[])                       public randomForOrder;             //第二轮仲裁入选仲裁员的随机数
    mapping(uint256 => OrderInfo)                       public orderInfo;                  //仲裁订单信息
    mapping(address => UserInfo)                        public userInfo;                   //参与者信息
    mapping(uint256 => address)                         public arbFroId;                   //仲裁员编号对应的地址
    mapping(uint256 => uint256)                         public schemeNumber;               //仲裁方案数量
    mapping(uint256 => address)                         public addressForRandom;           //随机数对应的地址
    mapping(bytes32 => address)                         public repeatEnrollmentCheck;      //第二轮报名查重
    mapping(bytes32 => uint256)                         public schemeCheck;                //仲裁方案查重
    TokenLike                                           public mar = TokenLike(0xe4A05741ed522c578615bd97c1f9347d96a395C9);  // 保证金合约地址
    SBTLike                                             public SBT;                       // 特邀仲裁员识别地址
    address                                             public foundsAddress;             //惩罚款接收地址
   //人数相关
    uint256                                             public maxPeople = 10;                 // 第二轮报名最多人数
    uint256                                             public quorum = 5;             //仲裁员法定人数
    uint256                                             public numberRange =7;         //合格仲裁员范围的最小编号
    uint256                                             public maxnum = 2;              //第一轮每一方能邀请的最多人数
    uint256                                             public minVote = 3;             //方案通过的最少投票
   //金额相关
    uint256                                             public arbitrationBond = 1000*1E18;     //每仲裁一单释放的保证金
    uint256                                             public minMar = 1000*1E18;              //申请仲裁员要求的最低保证金
    uint256                                             public minFee = 10*1E18;                //申诉要支付的最低申诉费
   //时间相关
    uint256                                             public voteCycle = 3600;           //仲裁员投票的最长时间
    uint256                                             public communityVoteCycle = 3600;  //等待社区投票的最长时间
    uint256                                             public firstRoundInterval = 3600;           // 第一轮仲裁等待另一方投票的最短时间
    uint256                                             public secondRegistrationWaitingTime = 3600; //第二轮报名等待时间

    uint256                                             public arbId;               //仲裁员总数
    uint256                                             public order;               //仲裁订单总数

    constructor() {
        wards[msg.sender] = 1;
    }
   ///设置参数
	function setAddress(uint256 what, address ust) external auth{
	    if (what == 1) foundsAddress = ust;
        if (what == 2) mar = TokenLike(ust);
        if (what == 3) SBT = SBTLike(ust);
	}
	function setVariable(uint256 what,  uint256 data) external auth{
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
        if (what == 11) minVote = data;
        if (what == 12) minMar = data;
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
        if ((user.idForArb <= numberRange || isInvited(usr)) && !user.lock) qualified = true;
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
        (address partyA,address partyB,uint256 assetAmount) = EscroeLike(escroeControct).getHostingInfo(i);
        order +=1;
        idForEscroe[escroeControct][i] = order;
        OrderInfo storage arbOrder = orderInfo[order]; 
        arbOrder.escroeControct = escroeControct;
        arbOrder.escroeId = i;
        arbOrder.partyA = partyA;
        arbOrder.partyB = partyB;
        arbOrder.assetAmount = assetAmount;
        userInfo[partyA].appeal.push(order);
        userInfo[partyA].appeal.push(order);
        emit Init(order,escroeControct,i,partyA,partyB);
        return order;
    }
    //支付仲裁费
    function payAppealFee(uint256 _order,uint256 _appealFee) public{ 
        OrderInfo storage arbOrder = orderInfo[_order];
        require(arbOrder.partyA == msg.sender || arbOrder.partyB == msg.sender, "arb/not-swapper");
        mar.transferFrom(msg.sender, address(this), _appealFee);
        appealFee[_order][msg.sender] += _appealFee;
    }

    //邀请仲裁员
    function inviteArbitrator(uint256 _order,address usr) external  { 
        require(appealFee[_order][msg.sender] >= minFee, "arb/not-swapper");
        require(invitingParty[_order][usr] == address(0),"arb/Has-been-invited");
        require(numberOfInviteesn[_order][msg.sender].length < maxnum,"arb/Has-been-invited");
        require(isQualified(usr),"arb/not-qualified arbitrator");
        invitingParty[_order][usr] = msg.sender;
        numberOfInviteesn[_order][msg.sender].push(usr);
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
        require((arbOrder.partyA == msg.sender && (arbOrder.arbStatus == 0 || arbOrder.arbStatus == 2)) || (arbOrder.partyB == msg.sender && (arbOrder.arbStatus == 0 || arbOrder.arbStatus == 1)), "arb/not-swapper");
        require(arbOrder.assetAmount == amountOfpartyA + amountOfpartyB, "arb/Quantity does not match");
        appealComp[_order][msg.sender] = [amountOfpartyA,amountOfpartyB];
    }
    //双方和解，甲方执行乙方方案，或乙方执行甲方方案
    function reconciliation(uint256 _order,uint256 amountOfpartyA, uint256 amountOfpartyB) external  {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(arbOrder.arbStatus < 4, "arb/relTime-not");
        if(arbOrder.partyA == msg.sender) {
            require(appealComp[_order][arbOrder.partyB][0] == amountOfpartyA && appealComp[_order][arbOrder.partyB][1] == amountOfpartyB, "arb/Allocation quantity does not match");
        }
        if(arbOrder.partyB == msg.sender) {
            require(appealComp[_order][arbOrder.partyA][0] == amountOfpartyA && appealComp[_order][arbOrder.partyA][1] == amountOfpartyB, "arb/Allocation quantity does not match");
        }
        EscroeLike(arbOrder.escroeControct).arbitration(arbOrder.escroeId, amountOfpartyA, amountOfpartyB);
        arbitrationFeeAllocation(_order);
        arbOrder.arbStatus = 5;
    }

    //仲裁员弃权或投赞成票，各方只有第一个仲裁员的投票有效
    function firstRoundOfArbitration(uint256 _order,uint256 amountOfpartyA, uint256 amountOfpartyB) external {
        OrderInfo storage arbOrder = orderInfo[_order];
        UserInfo storage user = userInfo[msg.sender];
        if (arbOrder.time0 == 0) arbOrder.time0 = block.timestamp;
        require(firstRoundInterval > block.timestamp - arbOrder.time0, "arb/relTime-not");
        require(isQualified(msg.sender),"arb/Insufficient-conditions");
        user.balanceMar -= arbitrationBond;
        if (user.balanceMar < minMar) cover(user.idForArb);
        if (invitingParty[_order][msg.sender] == arbOrder.partyA && (arbOrder.arbStatus == 0 || arbOrder.arbStatus == 2)) {
            require(appealComp[_order][arbOrder.partyA][0] == amountOfpartyA && appealComp[_order][arbOrder.partyA][1] == amountOfpartyB, "arb/Allocation quantity does not match");
            arbOrder.arbStatus += 1;
            arbOrder.votePartyA = msg.sender;
        }
        else if (invitingParty[_order][msg.sender] == arbOrder.partyB && (arbOrder.arbStatus == 0 || arbOrder.arbStatus == 1)) {
            require(appealComp[_order][arbOrder.partyB][0] == amountOfpartyA && appealComp[_order][arbOrder.partyB][1] == amountOfpartyB, "arb/Allocation quantity does not match");
            arbOrder.arbStatus += 2;
            arbOrder.votePartyB = msg.sender;       
        } else revert("arb/Invalid-arbitration");
        emit Asse(_order,arbOrder.arbStatus,block.timestamp);
    } 
    //执行第一轮仲裁结果
    function executeFirstRoundOfArbitration(uint256 _order) external  {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(firstRoundInterval < block.timestamp - arbOrder.time0, "arb/relTime-not");
        require(arbOrder.arbStatus == 1 || arbOrder.arbStatus == 2, "arb/relTime-not");
        if (arbOrder.arbStatus == 1) EscroeLike(arbOrder.escroeControct).arbitration(arbOrder.escroeId, appealComp[_order][arbOrder.partyA][0], appealComp[_order][arbOrder.partyA][1]);
        if (arbOrder.arbStatus == 2) EscroeLike(arbOrder.escroeControct).arbitration(arbOrder.escroeId, appealComp[_order][arbOrder.partyB][0], appealComp[_order][arbOrder.partyB][1]);
        arbitrationFeeAllocation(_order);
        arbOrder.arbStatus = 5;
    }
    //执行第一轮仲裁费分配
    function arbitrationFeeAllocation(uint256 _order) internal  {
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256 partyAfee = appealFee[_order][arbOrder.partyA];
        uint256 partyBfee = appealFee[_order][arbOrder.partyB];
        address arbiter;
        uint256 wad;
        //@ara==1 User wins，
        //The arbitration fee paid by the user plus the deposit paid by the arbitrator voting for the user shall be returned to the arbitrator
        if (arbOrder.arbStatus ==1){
            arbiter = arbOrder.votePartyA;
            wad = partyAfee + arbitrationBond;
            if (partyBfee >0 ) mar.transfer(arbOrder.partyA, partyBfee);
        }
        // @ara==2 Merchant wins，
        // The arbitration fee paid by the merchant and the deposit paid by the arbitrator voting for the merchant shall be returned to the arbitrator
        if(arbOrder.arbStatus ==2) {
            arbiter = arbOrder.votePartyB;
            wad = partyBfee + arbitrationBond;
            if (partyAfee >0 ) mar.transfer(arbOrder.partyB, partyAfee);
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
        require(arbOrder.time2 == 0, "arb/Register-already-end");
        require(isQualified(msg.sender),"arb/not-meet-requirements");
        user.NumberOfEnrollments.push(_order);
        uint256  people = arbOrder.numberApplicants;
        if (people == 0) arbOrder.time1 = block.timestamp;
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, _order, arbOrder.time1));
        require(repeatEnrollmentCheck[hash] == address(0), "arb/signer-already-exists");
        repeatEnrollmentCheck[hash] = msg.sender;
        people += 1;
        if (people >= quorum && secondRegistrationWaitingTime < block.timestamp-arbOrder.time1) arbOrder.time2 = block.timestamp;
        if (people == maxPeople)  arbOrder.time2 = block.timestamp; 
        arbOrder.numberApplicants = people;
        uint256 random = uint256(keccak256(abi.encodePacked(msg.sender, blockhash(block.number-1))));
        if (random > randomForOrder[_order][0]) {
            address addressForMin = addressForRandom[randomForOrder[_order][0]];
            
            //Release the frozen status of the replaced arbitrator in the first round of arbitration contract
            if (addressForMin != address(0)) {
                userInfo[addressForMin].lock = false;
                isSuccess[_order][addressForMin] = 0 ;
            }
            randomForOrder[_order][0] = random;
            addressForRandom[random] = msg.sender;
            isSuccess[_order][msg.sender] = 1;
            userInfo[msg.sender].lock = true;
            //Re ranking of candidates
            for (uint n = 0; n < quorum-1; n++) {
                 if (randomForOrder[_order][n] > randomForOrder[_order][n+1]) {
                     random = randomForOrder[_order][n+1]; 
                     randomForOrder[_order][n+1] = randomForOrder[_order][n]; 
                     randomForOrder[_order][n] = random;
                 }
            }
        }
        emit Register(_order,people,arbOrder.time2,arbOrder.time3);
    }

    //第二轮仲裁员设置仲裁方案
    function setScheme(uint256 _order, uint256 amountOfpartyA, uint256 amountOfpartyB,uint256 marForA, uint256 marForB,uint256 fine) external returns(uint256){
       OrderInfo storage arbOrder = orderInfo[_order];
       require(voteCycle > block.timestamp - arbOrder.time2 && arbOrder.time2 != 0 , "arb/arbitration-not-end");
       require(arbOrder.assetAmount == amountOfpartyA + amountOfpartyB, "arb/Allocation quantity does not match");
       if(arbOrder.arbStatus !=4) require(2*arbitrationBond == marForA + marForB + fine, "arb/margin quantity does not match");
       require(isSuccess[_order][msg.sender] == 1, "arb/Not selected");
       bytes32 hash = keccak256(abi.encodePacked(_order,amountOfpartyA,amountOfpartyB));
       if (schemeCheck[hash] == 0) {
           schemeNumber[_order] += 1;                     
           schemeCheck[hash] = schemeNumber[_order];             
           scheme[_order][schemeNumber[_order]] = [amountOfpartyA,amountOfpartyB,marForA,marForB,fine];
           vote(order,schemeNumber[_order]);
           return  schemeNumber[_order];
       }else {
           return schemeCheck[hash];
       }
    }
    //投票
    function vote(uint256 _order, uint256 schemeId) public returns(uint256){
       OrderInfo storage arbOrder = orderInfo[_order];
       require(voteCycle > block.timestamp - arbOrder.time2 && arbOrder.time2 != 0 , "arb/arbitration-not-end");
       uint256 timc = arbOrder.time1;
       require(isSuccess[_order][msg.sender] == 1 && voteMark[_order][timc][msg.sender] == 0, "arb/voter-not");
       weight[_order][timc][schemeId] += 1; // Cumulative voting weight of arbitration scheme
       if(weight[_order][timc][schemeId] == minVote) selectedScheme[_order][timc] = schemeId;         
       voteMark[_order][timc][msg.sender] = schemeId;       // Voting mark
       emit Vote(_order,schemeId,weight[_order][timc][schemeId],msg.sender);
       return weight[_order][timc][schemeId];
    }  
     //取消投票
    function cancelVote(uint256 _order, uint256 schemeId) external {
       OrderInfo storage arbOrder = orderInfo[_order];
       uint256 timc = arbOrder.time1;
       require(arbOrder.time3 == 0 , "arb/schem-been-adopted");
       require(voteMark[_order][timc][msg.sender] == schemeId, "arb/schem-been-adopted");
       weight[_order][timc][schemeId] -= 1;  // Deduction of voting weight of arbitration scheme
       if(weight[_order][timc][schemeId] == minVote-1) selectedScheme[_order][timc] = 0;          
       voteMark[_order][timc][msg.sender] = 0;                                      // Restoration of voting rights
       emit Vote(_order,schemeId,weight[_order][timc][schemeId],msg.sender);
    }
    //仲裁结果超过时间未被采纳，可以重新申请组建仲裁庭，申请一方需要重新支付仲裁费
    function restartForParty(uint256 _order) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        //The arbitration scheme has not been adopted and the voting waiting time has passed
        require(arbOrder.time3 == 0, "arb/already-accept");
        require(selectedScheme[_order][arbOrder.time1] != 0, "arb/NotEnoughVotes");
        require(voteCycle < block.timestamp - arbOrder.time2 && arbOrder.time2 != 0 , "arb/Voting time has expired");
        
        //Except for both parties, the arbitrators selected in this round may cancel the arbitration panel
        require(arbOrder.partyA == msg.sender || arbOrder.partyB == msg.sender, "arb/not-swapper");
        uint256 fee = appealFee[_order][arbOrder.partyA] + appealFee[_order][arbOrder.partyB];
        arbitrationFeeAllocationForTwo(_order);
        appealFee[_order][arbOrder.partyA] = 0;
        appealFee[_order][arbOrder.partyB] = 0;
        payAppealFee(_order,2*fee);
        cancelTribunal(_order);
        if(arbOrder.arbStatus != 4) marAllocationForOne(_order,selectedScheme[_order][arbOrder.time1]);
    }
    //投票时间结束，未达到法定票数，任何人可以撤销仲裁庭,仲裁员没有仲裁费，当事人也不需要再支付申诉费
    function restartForPartyNotEnoughVotes(uint256 _order) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        //The arbitration scheme has not been adopted and the voting waiting time has passed
        require(selectedScheme[_order][arbOrder.time1] == 0, "arb/have Enough Votes");
        require(voteCycle < block.timestamp - arbOrder.time2 && arbOrder.time2 != 0 , "arb/Voting time has expired");
        cancelTribunal(_order);
    }
    //撤销仲裁结果
    function cancelTribunal(uint256 _order) internal {
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256[] memory randoms = randomForOrder[_order];
        for (uint n = 0; n < quorum; n++) {
             address arbiter = addressForRandom[randomForOrder[_order][n]];
             isSuccess[_order][arbiter] = 0;
             userInfo[arbiter].lock = false;
             randoms[n] = 0;
        }
        
        //Clear arbitration data
        randomForOrder[_order] = randoms;
        arbOrder.time1 = 0;
        arbOrder.time2 = 0;
        arbOrder.numberApplicants = 0;
        emit Rest(_order, msg.sender);
    }
    //仲裁结果要被采纳后才会生效
    function accept(uint256 _order, uint256 schemeId) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(arbOrder.partyA == msg.sender || arbOrder.partyB == msg.sender, "arb/not-swapper");
        require(weight[_order][arbOrder.time1][schemeId] >= minVote, "arb/Agreement-not-votes");
        require(arbOrder.time3 == 0, "arbtwo/already-accept");
        arbOrder.time3 = block.timestamp;
        if(arbOrder.arbStatus != 4) marAllocationForOne(_order,schemeId);
        emit Acce(_order,schemeId,block.timestamp);
    }
    //一方采纳后，另一方可以上诉至社区（需要支付更高的上诉费），社区要么维持原判，要么否决仲裁结果，并可弹劾作恶的仲裁员
    function notAccept(uint256 _order) public auth {
        OrderInfo storage arbOrder = orderInfo[_order];
        require(communityVoteCycle > block.timestamp - arbOrder.time3, "arb/not-time");
        arbOrder.time3 = 0;
        cancelTribunal(_order);
    }

    //执行第二轮仲裁结果
    function executeFroTwo(uint256 _order, uint256 schemeId) public {
        OrderInfo storage arbOrder = orderInfo[_order];
        //The arbitration scheme has been adopted by one of the traders and the waiting time has passed
        require(weight[_order][arbOrder.time1][schemeId] >= minVote, "arbtwo/The number of votes did not meet the statutory requirements");
        require(arbOrder.time3 != 0 && communityVoteCycle < block.timestamp - arbOrder.time3, "arbtwo/not-accept or Community appeal not over");
        require(arbOrder.arbStatus != 5, "arbtwo/already-execute");
        EscroeLike(arbOrder.escroeControct).arbitration(arbOrder.escroeId,scheme[_order][schemeId][0],scheme[_order][schemeId][1]);
        arbitrationFeeAllocationForTwo(_order); 
        arbOrder.arbStatus = 5;
        //emit Exec(i,schemeId,msg.sender);
    }
    //第一轮仲裁员保证金分配
     function marAllocationForOne(uint256 _order,uint256 schemeId) internal{
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256 marForA = scheme[_order][schemeId][2];
        uint256 marForB = scheme[_order][schemeId][3];
        uint256 fine = scheme[_order][schemeId][4];
        address arbiterA = arbOrder.votePartyA;
        address arbiterB = arbOrder.votePartyB;
        mar.transfer(arbiterA, marForA);
        mar.transfer(arbiterB, marForB);
        mar.transfer(foundsAddress, fine);
        arbOrder.arbStatus = 4;
        }
    //第二轮仲裁员分配仲裁费
    function arbitrationFeeAllocationForTwo(uint256 _order) internal{
        OrderInfo storage arbOrder = orderInfo[_order];
        uint256 fee = appealFee[_order][arbOrder.partyA] + appealFee[_order][arbOrder.partyB];
        uint256 average = fee/quorum;
        uint256[] memory randoms = randomForOrder[_order];
        for (uint n = 0; n < quorum; n++) {
             address arbiter = addressForRandom[randoms[n]];
             mar.transfer(arbiter, average);
             userInfo[arbiter].succeed.push(_order);
        }
    }
    function commun(string memory data) public  {
        userInfo[msg.sender].message = data;
    }
    function communForUsr(address usr,string memory data) public auth{
        require(tx.origin == usr,"1");
        userInfo[usr].message = data;
    }

  ///前端接口
    //仲裁员列表
    function listArbitrators() external view returns (UserInfo[] memory) {
        uint length = numberRange;
        if (arbId < length) length = arbId;
        UserInfo[] memory users = new UserInfo[](length);
        for (uint i = 1; i <=length ; ++i) {
            address arbitrators = arbFroId[i];
            UserInfo memory user = userInfo[arbitrators];
            user.owner = arbitrators;
            user.appealLength = user.appeal.length;
            user.inviteLength = user.invite.length;
            user.EnrollmentsLength = user.NumberOfEnrollments.length;
            user.succeedLength = user.succeed.length;
            users[i-1] = user;
        }
        return users;
    }
    //仲裁订单列表
    function listArbOrder(uint256 count) external view returns (OrderInfo[] memory) {
        uint length = order;
        if (count !=0 && count < length) length = count;
        OrderInfo[] memory Orders = new OrderInfo[](length);
        if(length == 0) return Orders;
        uint max = order;
        uint j; 
        for (uint i = max; i >=1; --i) {
            OrderInfo memory One = orderInfo[i];
            One.id = i;
            Orders[j] = One;
            j +=1;
            if (i == max + 1-length) break;
        }
        return Orders;
    }

    //我被第一轮邀请的订单
    function inviDeal(address usr, uint256 count) external view returns (OrderInfo[] memory) {
        UserInfo storage user = userInfo[usr];
        uint length = user.invite.length;
        if (count !=0 && count < length) length = count;
        OrderInfo[] memory Orders = new OrderInfo[](length);
        if(length == 0) return Orders;
        uint max = user.invite.length - 1;
        uint j;
        for (uint i = max; i >=0 ; --i) {
            uint n = user.invite[i];
            OrderInfo memory One = orderInfo[n];
            One.id = n;
            Orders[j] = One;
            j +=1;
            if (i == max + 1-length) break;
        }
        return Orders;
    }

    //我参与的第二轮仲裁订单
    function secondRoundParticipation(address usr, uint256 count) external view returns (OrderInfo[] memory) {
        UserInfo storage user = userInfo[usr];
        uint length = user.NumberOfEnrollments.length;
        if (count !=0 && count < length) length = count;
        OrderInfo[] memory Orders = new OrderInfo[](length);
        if(length == 0) return Orders;
        uint max = user.NumberOfEnrollments.length - 1;
        uint j;
        for (uint i = max; i >=0 ; --i) {
            uint n = user.NumberOfEnrollments[i];
            OrderInfo memory One = orderInfo[n];
            One.id = n;
            Orders[j] = One;
            j +=1;
            if (i == max + 1-length) break;
        }
        return Orders;
    }

    //我成功仲裁的订单
    function arbsucc(address usr, uint256 count) external view returns (OrderInfo[] memory) {
        UserInfo storage user = userInfo[usr];
        uint length = user.succeed.length;
        if (count !=0 && count < length) length = count;
        OrderInfo[] memory Orders = new OrderInfo[](length);
        if(length == 0) return Orders;
        uint max = user.succeed.length -1;
        uint j;
        for (uint i = max; i >=0 ; --i) {
            uint n = user.succeed[i];
            OrderInfo memory One = orderInfo[n];
            One.id = n;
            Orders[j] = One;
            j +=1;
            if (i == max + 1-length) break;
        }
        return Orders;
    }

    //我申述的订单
    function ownerappeal(address usr, uint256 count) external view returns (OrderInfo[] memory) {
        UserInfo storage user = userInfo[usr];
        uint length = user.appeal.length;
        if (count !=0 && count < length) length = count;
        OrderInfo[] memory Orders = new OrderInfo[](length);
        if(length == 0) return Orders;
        uint max = user.appeal.length - 1;
        uint j;
        for (uint i = max; i >=1 ; --i) {
            uint n = user.appeal[i];
            OrderInfo memory One = orderInfo[n];
            One.id = n;
            Orders[j] = One;
            j +=1;
            if (i == max + 1-length) break;
        }
        return Orders;
    }

    //第二轮报名的成功入选者
    function applySuceed(uint256 _order) external view returns (address[] memory,uint256[] memory) {
        uint length = quorum;
        address[] memory addr = new address[](length);
        uint256[] memory _pau = new uint256[](length);
        for (uint j = 0; j < length ; ++j) {
            address arbitrators = addressForRandom[randomForOrder[_order][j]];
            addr[j] = arbitrators;
            _pau[j] = voteMark[_order][orderInfo[_order].time1][arbitrators];
        }
        return (addr, _pau);
    }
    //订单方案对应的投票者
    function voteSuceed(uint256 _order,uint256 pau) external view returns (address[] memory) {
        uint256 timc = orderInfo[_order].time1;
        uint256 k;
        uint256 length = weight[_order][timc][pau];
        address[] memory addr = new address[](length);
        for (uint j = 0; j < quorum ; ++j) {
            address arbitrators = addressForRandom[randomForOrder[_order][j]];
            if (voteMark[_order][timc][arbitrators] == pau) {
                addr[k] = arbitrators;
                k += 1;
            }if (k == length) break;
        }
        return addr;
    }

    //批量返回参与者注册信息
    function listName(address[] calldata usr) external view returns (string[] memory) {
        string[] memory nickname = new string[](usr.length); 
        for (uint i = 0; i <usr.length ; ++i) {
            nickname[i] = userInfo[usr[i]].message;
        }
        return nickname;
    }
}