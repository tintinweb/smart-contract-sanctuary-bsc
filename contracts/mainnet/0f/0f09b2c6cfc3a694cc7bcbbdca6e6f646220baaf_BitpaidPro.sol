/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.8.7;
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
contract BitpaidPro {
    string public name = "Bitpaid Pro";
    string public symbol = "BTPP";
    uint public totalSupply =210000000000000000000000000; 
    uint public decimals = 18;
    
    address public owner;
   

     address public charityAccount;
     address public developerTeamAccount;
     address public ownerCommissionAccount;


    
    uint public availableforadmin =0;
	
	uint public expendingminebale=0;
    uint public remainingminebale=0;
	
    uint public allowTransfer =0;
    uint public allowCharityDistribution =0;

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
    // mapping(address => uint256) public TransferControl;
    // mapping(address => uint256) public DistributionControl;
    mapping(address => uint256) public fullytransferControl;
    mapping(address => uint256) public chrityDistributionControl;
    mapping(address => uint256) public chrityDistributionControlPNK;
    
    mapping(address => mapping(address => uint256)) public allowance; 
   
  //
  
  
    
    constructor(address _charityAccount,address _developerTeamAccount,address _ownerCommissionAccount) {

 
		owner=msg.sender;
        
        chrityDistributionControl[owner]=1;    
        chrityDistributionControlPNK[owner]=0;    

       
	    balanceOf[owner] = totalSupply;
        //
        charityPerecnt = 0;
	    developerTeamCommisionPercnt =0;	
	    ownerCommisionPerecnt =0;
        
        allowTransfer =1;
        
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
     


      function setFullyTransferControl(address addresstocontrol,uint _value) public onlyAdmin returns(bool){
        fullytransferControl[addresstocontrol] = _value;        
        return true;
    }

    function setchrityDistributionControl(address addresstocontrol,uint _value) public onlyAdmin returns(bool){
        chrityDistributionControl[addresstocontrol] = _value;        
        return true;
    }
function setchrityDistributionControlPNK(address addresstocontrol,uint _value) public onlyAdmin returns(bool){
        chrityDistributionControlPNK[addresstocontrol] = _value;        
        return true;
    }

    

   function getTransferControlByAccount(address addresstocontrol) public view  returns(uint){
            
        return fullytransferControl[addresstocontrol] ;
    }


   function setAllowTransferAll(uint _value) public onlyAdmin returns(bool){

        allowTransfer=_value;
        return true;
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

  
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        if(msg.sender != owner )
        {
         require(allowTransfer == 1 );
        }
        
        require(balanceOf[msg.sender] >= _value);
        require(fullytransferControl[msg.sender] == 0);
        
        

        if(fullytransferControl[msg.sender] ==0 && chrityDistributionControl[msg.sender] ==1)
        {

           balanceOf[msg.sender] -= _value;
           balanceOf[_to] += _value;
           emit Transfer(msg.sender, _to, _value);
        }


       if( fullytransferControl[msg.sender] ==0  && chrityDistributionControl[msg.sender] ==0) 
        {
            uint256 _charityAmount = _value * charityPerecnt/100;
            uint256 _devloperTeamAmount = _value * developerTeamCommisionPercnt/100;
            uint256 _ownerCommisionAmount = _value * ownerCommisionPerecnt/100;

            uint256 totalcommision = SafeMath.addThreeParam(_charityAmount ,_devloperTeamAmount , _ownerCommisionAmount);
            uint256 aftercommision =SafeMath.sub(_value, totalcommision);

       
             balanceOf[msg.sender] -= aftercommision;
             balanceOf[_to] += aftercommision;
             emit Transfer(msg.sender, _to, aftercommision);
           


      if(_charityAmount >0)
      {         
         transferCahrity( _charityAmount);          
      }
      if(_devloperTeamAmount >0)
      {        
           transferDeeloperTeamamount( _devloperTeamAmount);          

      }
      if(_ownerCommisionAmount >0)
        {
           transferOwnerCommision(_ownerCommisionAmount);
          
        }
        return true;
    }
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
    
	 

 
   function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     function getallowance(address _owner, address _spender) public  view returns (uint) {
        return allowance[_owner][_spender];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
         
         _transfer(_from, _to,  _value);

        
        return true;
    }

     function _transfer(address _from,address _to, uint256 _value)
        private
        returns (bool success)
    {
        if(_from != owner )
        {
         require(allowTransfer == 1 );
        }
        
        require(balanceOf[_from] >= _value);
        require(fullytransferControl[_from] == 0);
        
        

        if(fullytransferControl[_from] ==0 && chrityDistributionControlPNK[_from] ==0)
        {

           balanceOf[_from] -= _value;
           balanceOf[_to] += _value;
           emit Transfer(_from, _to, _value);
        }


       if( fullytransferControl[_from] ==0  && chrityDistributionControlPNK[_from] ==1) 
        {
            uint256 _charityAmount = _value * charityPerecnt/100;
            uint256 _devloperTeamAmount = _value * developerTeamCommisionPercnt/100;
            uint256 _ownerCommisionAmount = _value * ownerCommisionPerecnt/100;

            uint256 totalcommision = SafeMath.addThreeParam(_charityAmount ,_devloperTeamAmount , _ownerCommisionAmount);
            uint256 aftercommision =SafeMath.sub(_value, totalcommision);

       
             balanceOf[_from] -= aftercommision;
             balanceOf[_to] += aftercommision;
             emit Transfer(_from, _to, aftercommision);
           


      if(_charityAmount >0)
      {         
         transferCahrity( _charityAmount);          
      }
      if(_devloperTeamAmount >0)
      {        
           transferDeeloperTeamamount( _devloperTeamAmount);          

      }
      if(_ownerCommisionAmount >0)
        {
           transferOwnerCommision(_ownerCommisionAmount);
          
        }
       
    }
     return true;
    }
}