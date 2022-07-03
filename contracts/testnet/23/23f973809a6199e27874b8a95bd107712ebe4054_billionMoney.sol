/**
 *Submitted for verification at BscScan.com on 2022-07-02
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
        uint netTotalUserWithdrawn_;
        uint netTotalWithdrawable;
        uint64 withTimeLimit;

    }

    mapping (address => userInfo) public userInfos;
    mapping (address => payInfo) public payInfos;
    mapping(uint => uint) public priceOfLevel;


     struct setValue {
       uint txCost;
       uint64 cbgraceTime;//after limit to proseed your cashback
       uint32 setWithTime;//set withdrwal time within this limit
    }
    setValue public setPram;

  

    constructor() public {
        owner = msg.sender;

        priceOfLevel[1] = 25*1e18;
        priceOfLevel[2] = 25*1e18;
        priceOfLevel[3] = 50*1e18;
        priceOfLevel[4] = 140*1e18;
        priceOfLevel[5] = 600*1e18;
        priceOfLevel[6] = 2500*1e18;
        priceOfLevel[7] = 3000*1e18;
        priceOfLevel[8] = 5000*1e18;
        priceOfLevel[9] = 8000*1e18;
        priceOfLevel[10] = 15000*1e18;        

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


	
	function setmaxLevel(address _user, uint8 _level) public payable onlySigner returns(bool)
    {
		
        userInfos[_user].levelInfos =  (_level);
        return true;
    }



    function setParams(uint _txCost,  uint64 _graceTime, uint32 _setWithTime ) public onlyOwner returns (bool)
    {
        setPram.txCost = _txCost;
    
		setPram.cbgraceTime = _graceTime;
        setPram.setWithTime=_setWithTime;
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
        require( tokenInterface(tokenAddress).transferFrom(msg.sender,address(this), prc),"token transfer failed");

        emit regUserEv(msg.sender, _referrer, _parent);
		emit buyLevelEv(msg.sender,1);
        return true;
    }

    event buyLevelEv(address _user, uint _level);
    function buyLevel(uint8 _level) public payable returns(bool){
        require(Pausable==false,"Contract is paused");

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
        require( tokenInterface(tokenAddress).transferFrom(msg.sender,address(this), prc),"token transfer failed");
		
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

        uint amt = payInfos[msg.sender].netTotalWithdrawable;

        if (amt>0 && setPram.txCost>0 ){

            if(amt<5*1e18){

            require(setPram.txCost==msg.value,"invalid amount");

            }else if(amt>=50*1e18){

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
    function updateWithdraw(address _userAdd, uint _amount) public onlySigner returns(bool)
    {

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