/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

pragma solidity 0.5.9;

contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;
 
    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }


    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



//*******************************************************************//
//------------------         token interface        -------------------//
//*******************************************************************//

 interface tokenInterface
    {
        function transfer(address _to, uint256 _amount) external returns (bool);
        function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);     
        function balanceOf(address _addr) external returns(uint);
    
    }

        interface contractInterface{

        function userInfos(address _user) external returns(bool,uint32,uint32,uint8);
        function netTotalUserWithdrawn_(address _user) external returns(uint);
        function joinDate(address _user ) external returns(uint);

        }


contract billionMoney is owned {

    // Replace below address with main token token
    address public tokenAddress;

    uint public pullLimit;
	
    bool Pausable;
    
    struct userInfo {
        bool joined;
        uint32 parentID;
        uint32 referrerID;
        uint8 levelInfos;
        uint64 joinDate;
    }

    struct payInfo{
        bool lockWithdraw;
        uint64 netTotalUserWithdrawn_;
        uint64 netTotalWithdrawable;
        uint64 withTimeLimit;

    }


    mapping (address => userInfo) public userInfos;
    mapping (address => payInfo) public payInfos;
    mapping(uint => uint) public priceOfLevel;

    address OldContract;
    bool public CashbackPause;

     struct setValue {
       uint32 txCost;
       uint32 cashBackAmount;//cashback Amount
       uint64 cbgraceTime;//after limit to proseed your cashback
       uint32 cbcAmountLimit;//cashback contract limit amount(cbc)
       uint32 setWithTime;//set withdrwal time within this limit
    }
    setValue public setPram;

    uint CashbackUnlockIdRange;


    constructor() public {
        owner = msg.sender;

        priceOfLevel[1] = 25000000;
        priceOfLevel[2] = 25000000;
        priceOfLevel[3] = 50000000;
        priceOfLevel[4] = 140000000;
        priceOfLevel[5] = 600000000;
        priceOfLevel[6] = 2500000000;
        priceOfLevel[7] = 3000000000;
        priceOfLevel[8] = 5000000000;
        priceOfLevel[9] = 8000000000;
        priceOfLevel[10] = 15000000000;        

    }

    function () payable external {
        
    }

    function lockMyWithdraw() public returns(bool)
    {
        payInfos[msg.sender].lockWithdraw = true;
        return true;
    }

    function unLockWithdraw(address _user) public onlyOwner returns(bool)
    {
       payInfos[_user].lockWithdraw = false;
        return true;
    }

    function pauseUnpause() public onlyOwner returns(bool)
    {
       Pausable= !Pausable;
        return true;
    }

    function CashBackPauseUnpause() public onlyOwner returns(bool){

        CashbackPause=!CashbackPause;

        return true;
    }
	
	function setDate(address _user, uint _joinDate) public onlyOwner returns(bool)
    {
		require(msg.sender == owner, "invalid caller");
        userInfos[_user].joinDate = uint64 (_joinDate);
        return true;
    }

    event cashBackEv(address _user, uint amount);
    function cashBack(uint64 _userID) public payable returns(bool)
    {
        require(Pausable==false,"Contract is paused");
        require(CashbackPause==false , "CashbackP Puase");

        require(_userID>CashbackUnlockIdRange,"your id is not in shortlist ");

        validateCashback();

        require(msg.value == setPram.txCost, "please paid correct cost");
        userInfos[msg.sender].joined = false;
	    require(tokenInterface(tokenAddress).transfer(msg.sender,setPram.cashBackAmount - payInfos[msg.sender].netTotalUserWithdrawn_ ),"token transfer failed");
        emit cashBackEv( msg.sender, setPram.cashBackAmount - payInfos[msg.sender].netTotalUserWithdrawn_ );
        return true;
    }


    function validateCashback() internal {
        // check the contract balance > cashBackRelese amount
        uint contractBalance= tokenInterface(tokenAddress).balanceOf(address(this));
        require(contractBalance>setPram.cbcAmountLimit,"balance is loww");
         //check income eligibilty and time eligibilty
        require((payInfos[msg.sender].netTotalUserWithdrawn_  < setPram.cashBackAmount) && (userInfos[msg.sender].joinDate + setPram.cbgraceTime < now),"cashback time or amount failed");
        require(userInfos[msg.sender].joined == true,"Your cashback is alredy done");
        
    }

    function setOldContract(address _oldContract) external onlyOwner returns(bool){

        OldContract= _oldContract;
        return true;

    }


    function setCashbackUnlockIdRange(uint _id) public onlyOwner returns(bool){

        CashbackUnlockIdRange= _id;

        return true;

    }

    function setParams(uint32 _txCost, uint32 _cashBackAmount, uint64 _graceTime, uint32 _cbclimit, uint32 _setWithTime ) public onlyOwner returns (bool)
    {
        setPram.txCost = _txCost;
        setPram.cashBackAmount = _cashBackAmount;
		setPram.cbgraceTime = _graceTime;
        setPram.cbcAmountLimit=_cbclimit;
        setPram.setWithTime=_setWithTime;
        return true;
    }
   
    event connectMyDataEv(address user);
    function connectMyData() public payable returns(bool)
    {
        require(Pausable==false,"Contract is paused");
        require(msg.value == setPram.txCost, "please paid correct cost");
        (bool joined,,,)=contractInterface(OldContract).userInfos(msg.sender);
        if(userInfos[msg.sender].joined == false && joined == true){
            _migrateUser(msg.sender);
        }
        emit connectMyDataEv(msg.sender);
        return true;
    }

    event regUserEv(address _user, uint _referrer, uint _parent);
    function regUser(uint32 _referrer, uint32 _parent) public payable returns(bool)
    {   require(Pausable==false,"Contract is paused");
        require(tokenAddress!=address(0),"token contract not set");
        require(setPram.txCost==msg.value,"invalid amount");
        uint prc = priceOfLevel[1];
        uint userBalance=tokenInterface(tokenAddress).balanceOf(msg.sender);
        require(userBalance>=prc, "your balance is not sufficient to transact this");
        require(userInfos[msg.sender].joined == false, "already registered");
        require(_parent>0 && _referrer>0,"invalid ref or parent");
 
        userInfos[msg.sender].joined=true;
        userInfos[msg.sender].parentID=_parent;
        userInfos[msg.sender].referrerID=_referrer;
        userInfos[msg.sender].levelInfos=1;
        userInfos[msg.sender].joinDate=uint64(now);

        address(uint160(owner)).transfer(msg.value);
        require( tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), prc),"token transfer failed");

        emit regUserEv(msg.sender, _referrer, _parent);
		emit buyLevelEv(msg.sender,1);
        return true;
    }


   
    event regUserOldEv(address _user, uint _referrer, uint _parent, uint _level);
    function regUserOldAdmin(address  _user, uint32 _parent, uint32 _referrer,  uint8 _level) public onlySigner returns(bool) 
    {
        uint _joinedDate = contractInterface(OldContract).joinDate(_user);
        require (_joinedDate != 3496879763 , "cashback is done");
         userInfo memory UserInfo;
            UserInfo = userInfo({
            joined:true,
            parentID:_parent,
            referrerID:_referrer,
			levelInfos:_level,
            joinDate:userInfos[_user].joinDate
         });


        

        userInfos[_user]= UserInfo;
          
        emit regUserOldEv(_user, _referrer,_parent, _level);
        return true;
    }

    function migrateUser(address  _user) public payable returns(bool) 
    {
        require(msg.value ==setPram.txCost && setPram.txCost>0,"No cost set for migration");
        _migrateUser( _user);
        return true;
    }


    //migrate user call for internal 

    function _migrateUser(address  _user) internal 
    {
        require(OldContract!=address(0),"please set old contract");
        
        (bool _userJoin,uint32 _parent,uint32 _referral,uint8 _level)=contractInterface(OldContract).userInfos(_user);
        uint _joinedDate = contractInterface(OldContract).joinDate(_user);
        uint64 _withdrawn = uint64(contractInterface(OldContract).netTotalUserWithdrawn_(_user));
        require (_joinedDate != 3496879763 , "cashback is done");
        require(_userJoin==true,"user is not regiseterd in Oldcontract" );

         userInfo memory UserInfo;
            UserInfo = userInfo({
            joined:_userJoin,
            parentID:_parent,
            referrerID:_referral,
			levelInfos:_level,
            joinDate:uint64(_joinedDate)
         });
        
        payInfos[_user].netTotalUserWithdrawn_=_withdrawn;
        userInfos[_user]= UserInfo;
          
        emit regUserOldEv(_user, _referral,_parent, _level);
        
    }

    event buyLevelEv(address _user, uint _level);
    function buyLevel(uint8 _level) public payable returns(bool){
        require(Pausable==false,"Contract is paused");
        (bool joined,,,)=contractInterface(OldContract).userInfos(msg.sender);
        if(userInfos[msg.sender].joined == false && joined==true){
            migrateUser(msg.sender);
        }
        require(setPram.txCost==msg.value,"invalid amount");
        require(userInfos[msg.sender].joined == true, "Please register first");
       
        uint prc = priceOfLevel[_level];
        uint userBalance=tokenInterface(tokenAddress).balanceOf(msg.sender);
        require(userBalance>=prc, "your balance is not sufficient to transact this");
        
        require(_level >0  && _level < 11, "not valid level");
        require(userInfos[msg.sender].levelInfos >= _level -1 , "Invalid Level");
        

        if( userInfos[msg.sender].levelInfos < _level ) userInfos[msg.sender].levelInfos = _level;        
        address(uint160(owner)).transfer(msg.value);
        
        userInfos[msg.sender].levelInfos = _level;
        require( tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), prc),"token transfer failed");
		
        emit buyLevelEv(msg.sender, _level);
        return true;
    }

    function fillSigner(uint amount) public onlyOwner returns(bool){
        address(uint160(signer)).transfer(amount);
        return true;        
    }

    event withdrawEv(address _user, uint _amount);
    function withdrawMyGainAndAll() public payable returns(bool)
    
    {
       
        require(Pausable==false,"Contract is paused");
        require(payInfos[msg.sender].withTimeLimit>now && payInfos[msg.sender].netTotalWithdrawable >0,"You dont have any pending amount");
        require(payInfos[msg.sender].lockWithdraw==false,"Withdraw is locked");
        require(userInfos[msg.sender].joined == true,"User is not exisit");

        uint64 amt = payInfos[msg.sender].netTotalWithdrawable;

        if (amt>0 && setPram.txCost>0 ){

            if(amt<50000000){

            require(setPram.txCost==msg.value,"invalid amount");

            }else if(amt>=50000000){

                require(setPram.txCost*2==msg.value,"invalid amount");
            }

        }

        payInfos[msg.sender].netTotalWithdrawable=0;

        address(uint160(signer)).transfer(msg.value);
        payInfos[msg.sender].netTotalUserWithdrawn_ += amt;
        if(amt > 0)require(tokenInterface(tokenAddress).transfer(msg.sender, amt),"token transfer failed");
        
        emit withdrawEv(msg.sender,amt);
        return true;
    }

   
    

    function updateAddress( address _tokenAddress) public onlyOwner returns(bool)
    {
        require(tokenAddress!=_tokenAddress,"Same token address");
        tokenAddress = _tokenAddress;
        return true;
    }

    function changeUserAddress(address oldUserAddress, address newUserAddress) public onlyOwner returns(bool){
        require(userInfos[oldUserAddress].joined==true,"Invalid old User");
        require(userInfos[newUserAddress].joined==false,"newUserAddress is alrady registered");
        userInfos[newUserAddress] = userInfos[oldUserAddress];
        
        userInfo memory UserInfo;
            UserInfo = userInfo({
            joined:false,
            parentID:0,
            referrerID:0,
			levelInfos:0,
            joinDate:0

         });
        
        userInfos[oldUserAddress] = UserInfo;


        payInfos[newUserAddress].netTotalUserWithdrawn_=payInfos[oldUserAddress].netTotalUserWithdrawn_;
        payInfos[oldUserAddress].netTotalUserWithdrawn_=0;
      
        payInfos[newUserAddress].lockWithdraw =payInfos[oldUserAddress].lockWithdraw;
        payInfos[oldUserAddress].lockWithdraw = false;      


	return true;     
    }
    
    
    	function pramsLimit(uint32 _pullLimit) public onlyOwner returns(bool)
    {
		pullLimit = _pullLimit;
		return true;
    }

	
	event updateWithdrawEv(address _user, uint amount);
    function updateWithdraw(address _userAdd, uint32 _amount) public onlySigner returns(bool)
    {
        require(Pausable==false,"Contract is paused");
        (bool joined,,,)=contractInterface(OldContract).userInfos(_userAdd);
        if(userInfos[_userAdd].joined == false && joined==true){
            _migrateUser(_userAdd);
        }
        // adress checking
		require( _amount <= pullLimit && now >= payInfos[_userAdd].withTimeLimit);
        require(payInfos[_userAdd].lockWithdraw==false,"Withdraw is locked");
        require(userInfos[_userAdd].joined == true,"User is not exisit");

        payInfos[_userAdd].netTotalWithdrawable=_amount;
        payInfos[_userAdd].withTimeLimit= uint64(now)+setPram.setWithTime;


		emit updateWithdrawEv( _userAdd, _amount);
        return true;
    }
	


}