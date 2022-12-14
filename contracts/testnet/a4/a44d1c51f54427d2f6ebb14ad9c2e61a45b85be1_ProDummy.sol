/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.8.7;
 
contract ProDummy {
    string public name = "ProDummy";
    string public symbol = "BPPD";
    uint public totalSupply =10000000000000000000000; 
    uint public decimals = 18;
    
    address public owner;
    address public minControlAccount;

     address public charityAccount;
     address public developerTeamAccount;
     address public ownerCommissionAccount;


    uint public availableformining =0;
    uint public availableforadmin =0;
	
	uint public expendingminebale=0;
    uint public remainingminebale=0;
	
    uint allowTransfer =0;

    uint public charityPerecnt = 0;
	uint public developerTeamCommisionPercnt =0;	
	uint public ownerCommisionPerecnt =0;
	


      
 

    event Transfer(
     address indexed _from,
     address indexed _to, 
     uint256 _value
     );
   
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public TransferControl;
    mapping(address => uint256) public DistributionControl;
    mapping(address => mapping(address => uint256)) public allowance; 
   
  //
  
   // mapping(address => uint256) internal minableBalance;
    //mapping(address => uint256) internal reserveBalance;
    
    constructor(address _minControlacct,address _charityAccount,address _developerTeamAccount,address _ownerCommissionAccount) {

       // balanceOf[msg.sender] = totalSupply;
		owner=msg.sender;
        DistributionControl[owner]=1;
        minControlAccount=_minControlacct;

        availableformining =500000000000000000000;
        availableforadmin =500000000000000000000;
       
     //  balanceOf[msg.sender] =500000000000000000000;
      // balanceOf[_minacct] =500000000000000000000;

      //  minableBalance[mintControlAccount] = 500000000000000000000;
        //
        charityPerecnt = 6;
	    developerTeamCommisionPercnt =6;	
	    ownerCommisionPerecnt =6;
        
        allowTransfer =0;
        //

        charityAccount =_charityAccount;
        developerTeamAccount = _developerTeamAccount;
        ownerCommissionAccount =_ownerCommissionAccount;

        expendingminebale=0;
        remainingminebale=0;
	
    }

     modifier onlyAdmin(){
        
        require(msg.sender == owner ,"Not Owner" );
        _;
    }
       modifier mineController(){        
        require(msg.sender == minControlAccount ,"Not Mine Controller" );
        _;
    }


      function setTransferControl(address addresstocontrol,uint _value) public onlyAdmin returns(bool){
        TransferControl[addresstocontrol] = _value;        
        return true;
    }

    function setDistributionControll(address addresstocontrol,uint _value) public onlyAdmin returns(bool){
        DistributionControl[addresstocontrol] = _value;        
        return true;
    }

    

   function getTransferControlByAccount(address addresstocontrol) public view  returns(uint){
            
        return TransferControl[addresstocontrol] ;
    }


   function setTrans(uint _value) public onlyAdmin{

        allowTransfer=_value;
    }

     function setCharityPerecentage(uint _charityPerecent) public onlyAdmin returns (bool){

        charityPerecnt=_charityPerecent;
       return true;
    
    }

   function setdeveloperTeamCommisionPercnt(uint _developerTeamCommisionPercnt) public onlyAdmin returns (bool){

        developerTeamCommisionPercnt=_developerTeamCommisionPercnt;
       return true;
    
    }

     function setownerCommisionPercnt(uint _ownerCommisionPerecnt) public onlyAdmin returns (bool){

        ownerCommisionPerecnt=_ownerCommisionPerecnt;
       return true;
    
    }

     function setCharityAddress(address _charityAddress) public onlyAdmin returns (bool){

        charityAccount=_charityAddress;
       return true;
    
    }

    function setDeveloperTeamAddress(address _developerTeamAddress) public onlyAdmin returns (bool){

        developerTeamAccount=_developerTeamAddress;
       return true;

    }

    function setownerCommissionAddress(address _setownerCommissionAddress) public onlyAdmin returns (bool){

        ownerCommissionAccount=_setownerCommissionAddress;
       return true;
    
    }

    function IncreaseAvailablesupplyForMining(uint _value) public onlyAdmin returns (bool)
    {
    require(_value > 0);
    availableformining =SafeMath.add(availableformining,_value); 
    totalSupply =SafeMath.add(totalSupply,_value);  
    return true;
    }

    function DecreaseAvailablesupplyForMining(uint _value) public onlyAdmin returns (bool)
    {
    require(_value > 0);
    require(availableformining > 0);
    require(availableformining > _value);
    availableformining =SafeMath.sub(availableformining,_value); 
    totalSupply = SafeMath.sub(totalSupply,_value);  
    return true;
    }

   function IncreaseAvailablesupplyForAdmin(uint _value) public onlyAdmin returns (bool)
    {
    require(_value > 0);
    availableforadmin =SafeMath.add(availableforadmin,_value); 
    totalSupply =SafeMath.add(totalSupply,_value);  
    return true;
    }

    function DecreaseAvailablesupplyForAdmin(uint _value) public onlyAdmin returns (bool)
    {
    require(_value > 0);
    require(availableforadmin > 0);
    require(availableforadmin > _value);
    availableforadmin =SafeMath.sub(availableforadmin,_value); 
    totalSupply = SafeMath.sub(totalSupply,_value);  
    return true;
    }
	
	
	 function  TokenMining(uint _amountOfTokens)
         public returns (bool success)
    {
         remainingminebale =SafeMath.sub(availableformining,expendingminebale);  	     
         require(_amountOfTokens <= remainingminebale,"Limit over"); 
		 
         address payable _customerAddress =payable(msg.sender);
		 require(_amountOfTokens <= allowance[minControlAccount][_customerAddress]*10**18,"Not Approved Amount");    		 
                  
         balanceOf[_customerAddress] = SafeMath.add(balanceOf[_customerAddress], _amountOfTokens); 		 
		 expendingminebale =SafeMath.add(_amountOfTokens, expendingminebale);        
		 
        allowance[minControlAccount][msg.sender] -= _amountOfTokens/10**18;
        
         emit Transfer(minControlAccount, _customerAddress, _amountOfTokens); 
         return true;
    }
   	 function  AdminMining(uint _amountOfTokens)
         public onlyAdmin   returns (bool success){
        	     
         require(_amountOfTokens <= availableforadmin,"Limit over"); 		 
         balanceOf[owner] = SafeMath.add(balanceOf[owner], _amountOfTokens);    	 
        
        availableforadmin =SafeMath.sub(availableforadmin, _amountOfTokens);  
         emit Transfer(address(this), owner, _amountOfTokens); 
          return true;
    }
    
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);

        if( DistributionControl[msg.sender] ==1)
        {

           balanceOf[msg.sender] -= _value;
           balanceOf[_to] += _value;
           emit Transfer(msg.sender, _to, _value);
        }

        if( allowTransfer ==1 && DistributionControl[msg.sender] ==0) 
        {
            uint256 _charityAmount = _value * charityPerecnt/100;
            uint256 _devloperTeamAmount = _value * developerTeamCommisionPercnt/100;
            uint256 _ownerCommisionAmount = _value * ownerCommisionPerecnt/100;

            uint256 totalcommision = SafeMath.addThreeParam(_charityAmount ,_devloperTeamAmount , _ownerCommisionAmount);
            uint256 aftercommision =SafeMath.sub(_value, totalcommision);

        if(TransferControl[msg.sender] ==0)
        {
         balanceOf[msg.sender] -= aftercommision;
         balanceOf[_to] += aftercommision;
         emit Transfer(msg.sender, _to, aftercommision);
        }     


      if(_charityAmount >0)
      {
         
         transferCahrity( _charityAmount);
          
      }
      if(_devloperTeamAmount >0)
      {
         
           transferDeeloperTeamamount( _devloperTeamAmount);
          

      }
      if(_ownerCommisionAmount >0)
        
           transferOwnerCommision(_ownerCommisionAmount);
          
        }
        return true;
    }

  	
 function transferCahrity( uint256 _value)
        internal
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(charityAccount)] += _value;
        emit Transfer(msg.sender, address(charityAccount), _value);
        return true;
    }

 function transferDeeloperTeamamount( uint256 _value)
        internal
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(developerTeamAccount)] += _value;
        emit Transfer(msg.sender, address(developerTeamAccount), _value);
        return true;
    }

  function transferOwnerCommision( uint256 _value)
        internal
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(ownerCommissionAccount)] += _value;
        emit Transfer(msg.sender, address(ownerCommissionAccount), _value);
        return true;
    }
    
	 

 
    function approve(address _spender, uint _value)
        public mineController
        returns (bool success)
    {
        allowance[msg.sender][_spender] = SafeMath.add(allowance[msg.sender][_spender],_value);
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     function getallowance(address _owner, address _spender) public  view returns (uint) {
        return allowance[_owner][_spender];
    }

    // function transferFrom(
    //     address _from,
    //     address _to,
    //     uint256 _value
		
    // ) public returns (bool success) {
    //     require(_value <= balanceOf[_from]);
    //     require(_value <= allowance[_from][msg.sender]*10**18);
    //     balanceOf[_from] -= _value;
    //     balanceOf[_to] += _value;
    //     allowance[_from][msg.sender] -= _value/10**18;
    //     emit Transfer(_from, _to, _value);
    //     return true;
    // }
}

library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      
        uint256 c = a / b;
       
        return c;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

   function addThreeParam(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        uint256 d = a + b +c;
        assert(d >= a);
        return d;
    }
	 
	 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}