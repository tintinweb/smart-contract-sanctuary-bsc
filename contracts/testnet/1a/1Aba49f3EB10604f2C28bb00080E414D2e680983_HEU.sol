/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.8;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




contract HEU is Ownable {
    using SafeMath for uint256;

    uint256 constant public INVEST_MIN_AMOUNT = 0.1 ether;
    uint256 constant public INVEST_MAX_AMOUNT = 3 ether;


    uint256  public LEVEL1 = 50;
    uint256  public LEVEL2 = 100;
    uint256  public LEVEL3 = 200;
    uint256  public LEVEL4 = 300;
    uint256  public FOMOPOOL_START_NUM = 300;
    uint256  public FOMOPOOL_address_num = 50;

    uint256 public STATIC_TIME=60*60*24;
     

    uint256 constant public BASE_PERCENT = 10;
    uint256[] public REFERRAL_PERCENTS = [50, 30, 10];

    uint256[] public LEVEL_FEE = [0, 5, 10,15,20];
    uint256 constant public MARKETING_FEE = 90;
    uint256 constant public DAY_RATE = 20;
    uint256 constant public PERCENTS_DIVIDER = 1000;

    

    uint256 public totalUsers;
    uint256 public totalInvestedRecord;
    uint256 public totalWithdrawn;

    address payable public marketingAddress1;
    address payable public marketingAddress2;

    bool public startFomoPool;

    struct RegisterReward{
        uint256 amount;
        uint256 key;
        uint256 invitation;
        bool isRegister;
    }
    struct StaticE {
        uint256 unlockTime;
        uint256 investTime;
        uint256 staticEarn;
        uint256 investAmount;
        uint256 earnNumber;
        uint256 invitationNumber;
        uint256 invitationAmount;
        uint256 level;
    }
     //注册送现金
    mapping(address=>RegisterReward) public registerEarn;


    //被推荐人=>推荐人
    mapping (address=>address) public  relationship;

    //动态收益
    mapping (address=>uint256) public dynamicEarnings;

    //静态收益
    mapping (address=>StaticE) public staticEarnings;

    //节点收益
    mapping (address=>uint256) public nodeEarnings;


    //提现锁
    mapping (address=>bool) public withdrawLock;

    //复投锁
    mapping (address=>bool) public reInvestLock;


    uint256 public totalFomoPool;
    uint256 private totalInvestPool;

    address[] public investAddress;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address payable _marketingAddr1, address payable _marketingAddr2) public {
        require(!isContract(_marketingAddr1) && !isContract(_marketingAddr2));
        marketingAddress1 = _marketingAddr1;
        marketingAddress2 = _marketingAddr2;
    }

    modifier notContract() {
         require(!isContract(msg.sender),"Investors cannot contract");
        _;
    }


    function setTestParam(uint256 _level1,uint256 _level2,uint256 _level3,uint256 _level4,uint256 fomoPoolNum_,uint256 STATIC_TIME_,uint256 FOMOPOOL_address_num_) external onlyOwner {
        LEVEL1 = _level1;
        LEVEL2 = _level2;
        LEVEL3 = _level3;
        LEVEL4 = _level4;
        FOMOPOOL_START_NUM=fomoPoolNum_;
        STATIC_TIME=STATIC_TIME_;
        FOMOPOOL_address_num=FOMOPOOL_address_num_;
    }

    //投资
    function invest(address _referrer) public payable  {



        address investProple=msg.sender;
        uint256 investAmount=msg.value;
        require(investAmount >= INVEST_MIN_AMOUNT,"The investment amount should not be less than min value");
        require(investAmount <= INVEST_MAX_AMOUNT,"The investment amount should not be greater than max value");

        marketingAddress1.transfer(investAmount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
        marketingAddress2.transfer(investAmount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));



        //重复投可以增加金额
        staticEarnings[investProple].investAmount+=investAmount;

        if ( relationship[investProple] == address(0) &&  _referrer != investProple) {
             relationship[investProple] = _referrer;
        }
        address referrer=relationship[investProple];
        if (referrer != address(0)) {

            address upline = referrer;
            //动态收益
            for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)&&staticEarnings[upline].investAmount>=INVEST_MIN_AMOUNT) {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                    dynamicEarnings[upline]+=amount;
                    upline = relationship[upline];
                } else break;
            }

            reduceLock(investProple,referrer);
            countStaticEarn(referrer);
            initRegister(investProple);
            countRegisterEarn(referrer);
            
            countTeamDividends(referrer,investAmount);
        }

        initStaticE(msg.sender,msg.value);
        totalInvestedRecord = totalInvestedRecord.add(msg.value);
        totalUsers = totalUsers.add(1);
        investAddress.push(msg.sender);
        emit NewDeposit(msg.sender, msg.value);

    }

    function reduceLock(address _investProple,address _referrer) internal{
        if(staticEarnings[_investProple].investAmount >=staticEarnings[_referrer].investAmount){
            StaticE storage st=staticEarnings[_referrer];
            if(st.unlockTime>now&&st.unlockTime-now>STATIC_TIME){
                st.unlockTime=st.unlockTime.sub(STATIC_TIME);

            }else{
                st.unlockTime=0;
            }
        }
    }

    function countLevel(address _referrer,uint256 _invitationAmount)internal{
            staticEarnings[_referrer].invitationNumber+=1;
            staticEarnings[_referrer].invitationAmount+=_invitationAmount;
            if(staticEarnings[_referrer].invitationNumber>=LEVEL4||staticEarnings[_referrer].invitationAmount>=100 ether){
                staticEarnings[_referrer].level=4;
            }else if(staticEarnings[_referrer].invitationNumber>=LEVEL3||staticEarnings[_referrer].invitationAmount>=50 ether){
                staticEarnings[_referrer].level=3;
            }else if(staticEarnings[_referrer].invitationNumber>=LEVEL2||staticEarnings[_referrer].invitationAmount>=30 ether){
                staticEarnings[_referrer].level=2;
            }else if(staticEarnings[_referrer].invitationNumber>=LEVEL1||staticEarnings[_referrer].invitationAmount>=10 ether){
                staticEarnings[_referrer].level=1;
            }
    }

    function initStaticE(address _address ,uint256 _investAmount )internal{
        StaticE storage st=staticEarnings[_address];
        st.unlockTime=now+(STATIC_TIME*3);
        st.investTime=now;
        st.staticEarn=_investAmount.mul(DAY_RATE*3).div(PERCENTS_DIVIDER);
    }
    function initRegister(address _address)internal{
        if(!registerEarn[_address].isRegister){
            RegisterReward memory  rr = RegisterReward(2*10**17 , 0, 0,true);
            registerEarn[_address]=rr;
        }
        
    }
    function countRegisterEarn(address _address)internal{
        if(!registerEarn[_address].isRegister){
            initRegister(_address);
        }
        if(registerEarn[_address].invitation==2){
            registerEarn[_address].key+=1;
            registerEarn[_address].invitation=0;
        }else{
            registerEarn[_address].invitation+=1;
        }

    }
    //页面总信息
    function getTotalInfo()public view returns(uint256,uint256,uint256){
        return(totalUsers,getTotalInvestPool(),totalFomoPool);
    }
    //页面个人总信息
    function getPersonalInfo()public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256){
        (uint256 totalEarn,uint256 lockEarn )=getTotalEarn(msg.sender);
        StaticE memory se=staticEarnings[msg.sender];
        uint256 dynmicEarn=dynamicEarnings[msg.sender];
        uint256 nodeEarn=nodeEarnings[msg.sender];
        return(totalEarn,se.unlockTime,se.staticEarn,se.invitationNumber,se.level,dynmicEarn,nodeEarn);
    }

    function getBlockNumbers()public view returns(uint256){
        return block.number;
    }

    //页面等级信息
    function getLevelInfo()public view returns(uint256,uint256){
        uint256 address_;
        uint256 bnb_;
        StaticE memory se=staticEarnings[msg.sender];
        if(se.level==0){
            address_=uint256(LEVEL1).sub(se.invitationNumber);
            bnb_=uint256(10*10**18).sub(se.invitationNumber);
        }else if(se.level==1){
            address_=uint256(LEVEL2).sub(se.invitationNumber);
            bnb_=uint256(30*10**18).sub(se.invitationNumber);
        }else if(se.level==2){
            address_=uint256(LEVEL3).sub(se.invitationNumber);
            bnb_=uint256(50*10**18).sub(se.invitationNumber);
        }else if(se.level==3){
            address_=uint256(LEVEL4).sub(se.invitationNumber);
            bnb_=uint256(100*10**18).sub(se.invitationNumber);
        }else if(se.level==4){
            address_=0;
            bnb_=0;
        }
        return(address_,bnb_);
    }


    //得到注册收益（页面）
    function getRegistEarn()public view returns (uint256,uint256,uint256){
        if(registerEarn[msg.sender].isRegister) {
            return(registerEarn[msg.sender].amount,registerEarn[msg.sender].key,registerEarn[msg.sender].invitation);
        }else{
            return(2*10**17 , 0, 0);
        }
    }

    //得到总收益
    function getTotalEarn(address _address) private view returns (uint256,uint256){
        uint256 dynamicE=dynamicEarnings[_address];
        StaticE memory _staticE=staticEarnings[_address];
        uint256 teamE=nodeEarnings[_address];
        uint256 InvestAmount=staticEarnings[_address].investAmount;
        uint256 totalEarn=dynamicE.add(_staticE.staticEarn).add(teamE).add(InvestAmount);

        (uint256 registAmount,uint256 keys,uint256 inestAmount )=getRegistEarn();
        totalEarn=totalEarn.add(registAmount);
        
        uint256 lockEarn=0;

        if(registAmount>0&&keys>0){
            uint256 unlock=keys.mul(2*10**16);
            if(unlock>registAmount){
                 lockEarn=0;   
            }else{
                lockEarn= registAmount.sub(unlock);
            }
            
           
        }

        return  (totalEarn,lockEarn);
    }
    function getRegisterEarn()public view returns (uint256){
        return registerEarn[msg.sender].amount;
    }



    //计算静态收益
    function countStaticEarn(address _investProple)internal{
        StaticE storage se=staticEarnings[_investProple];

        if(now<se.unlockTime){
            if(se.unlockTime.sub(now)>STATIC_TIME){
                se.unlockTime=se.unlockTime.sub(STATIC_TIME);
            }else{
                se.unlockTime=now;
            }

        }

    }




    function withdraw() public  {

        require(!withdrawLock[msg.sender], "Don't click twice");
        require(!startFomoPool, "startFomoPool");
        withdrawLock[msg.sender]=true;


        (uint256 totalAmount,uint256 lockEarn)=getTotalEarn(msg.sender);

        deductTotalEarn(msg.sender,lockEarn);
        totalAmount-=lockEarn;
        uint256 fomoPool=totalAmount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER);
        totalAmount-=fomoPool;
        totalFomoPool+=fomoPool;

        msg.sender.transfer(totalAmount);
        if(getTotalInvestPool()<1 ether&&investAddress.length>FOMOPOOL_START_NUM){
            startFomoPool=true;
            uint256 otherLuckAddressAmount;
            for(uint256 i=1;i<=FOMOPOOL_address_num;i++){
                if(i==1){
                    address luckAddress=investAddress[investAddress.length-i];
                    uint256 luckAmount=staticEarnings[luckAddress].investAmount*10;
                    if(totalFomoPool>=luckAmount){
                        totalFomoPool-=luckAmount;
                        payable(luckAddress).transfer(luckAmount);
                        otherLuckAddressAmount=totalFomoPool.mul(1).div(FOMOPOOL_address_num.sub(1));
                    }else{
                        payable(luckAddress).transfer(totalFomoPool);
                        break;
                    }
                    

                }else{
                    address otherluckAddress=investAddress[investAddress.length-i];
                    payable(otherluckAddress).transfer(otherLuckAddressAmount);
                }


                
            }

        }

        withdrawLock[msg.sender]=false;

    }


    function reInvest() public  {

        require(!reInvestLock[msg.sender], "Don't click twice");
        reInvestLock[msg.sender]=true;



       StaticE memory _staticE=staticEarnings[msg.sender];
       if( _staticE.unlockTime>now || _staticE.investAmount==0 ){
           revert("Not open");
       }
       

        (uint256 totalAmount,uint256 lockEarn)=getTotalEarn(msg.sender);

        uint256 reInvestAmount=totalAmount.sub(lockEarn);

        deductTotalEarn(msg.sender,lockEarn);

       if(reInvestAmount>0){

            marketingAddress1.transfer(reInvestAmount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
            marketingAddress2.transfer(reInvestAmount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));




            staticEarnings[msg.sender].investAmount=reInvestAmount;
           
            address referrer=relationship[msg.sender];
            if (referrer != address(0)) {

                address upline = referrer;
                //动态收益
                for (uint256 i = 0; i < 3; i++) {
                    if (upline != address(0)&&staticEarnings[upline].investAmount>=INVEST_MIN_AMOUNT) {
                        uint256 amount = reInvestAmount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                        dynamicEarnings[upline]+=amount;
                        upline = relationship[upline];
                    } else break;
                }

                reduceLock(msg.sender,referrer);
                countStaticEarn(referrer);
                initRegister(msg.sender);
                countRegisterEarn(referrer);
            
                countTeamDividends(referrer,reInvestAmount);
            }

            initStaticE(msg.sender,reInvestAmount);
            totalInvestedRecord = totalInvestedRecord.add(reInvestAmount);
            totalUsers = totalUsers.add(1);
       }



      reInvestLock[msg.sender]=false;
        

    }




    function getTotalInvestPool() private view returns (uint256) {
        return address(this).balance.sub(totalFomoPool);
    }


    function deductTotalEarn(address _address,uint256 _lockEarn) internal{
        registerEarn[_address].key=0;
        registerEarn[_address].amount=_lockEarn;
        dynamicEarnings[_address]=0;
        nodeEarnings[_address]=0;
        staticEarnings[_address].investAmount=0;

    }




    function countTeamDividends(address referrer,uint256 investAmount) internal  returns (uint256) {
        uint256 totalTeamDividendsRate=0;

        for (uint256 i = 0; i < 20; i++) {

                if(referrer == address(0)){
                     break;
                }

                
                StaticE storage se=staticEarnings[referrer];

                if (se.level>0&&LEVEL_FEE[se.level]>totalTeamDividendsRate) {
                    
                
                    uint256 amount = investAmount.mul(LEVEL_FEE[se.level].sub(totalTeamDividendsRate)).div(PERCENTS_DIVIDER);
                    
                    nodeEarnings[referrer]+=amount;
                    
                    totalTeamDividendsRate=LEVEL_FEE[se.level];
                }
                countLevel(referrer,investAmount);
                referrer = relationship[referrer];
                

            }

    }







    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
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