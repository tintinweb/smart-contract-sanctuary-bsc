/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

pragma solidity ^0.5.4;
    
    interface IBEP20 {
      function totalSupply() external view returns (uint256);
      function balanceOf(address who) external view returns (uint256);
      function allowance(address owner, address spender) external view returns (uint256);
      function transfer(address to, uint256 value) external returns (bool);
      function approve(address spender, uint256 value) external returns (bool);
      
      function transferFrom(address from, address to, uint256 value) external returns (bool);
      function burn(uint256 value) external returns (bool);
      function burnFrom(address _from, uint256 _value) external returns (bool success);
      event Transfer(address indexed from,address indexed to,uint256 value);
      event Approval(address indexed owner,address indexed spender,uint256 value);
      event Burn(address indexed from, uint256 value);
                
    }
    
    contract KAIZEN_WORLD {
        uint256 public latestReferrerCode;
        
        address payable private adminAccount_;
     
        mapping(uint256=>address) public idToAddress;
        mapping(address=>uint256) public addresstoUid;
        mapping(address => mapping(uint8 => bool)) public activeLevel;
        event Registration(string waddress,address investor,uint256 investorId,address referrer,uint256 referrerId,uint256 amount,uint256 amt_usd);
        event Reinvest(address investor,uint256 amount,uint256 amt_usd);
        event Upgrade(address indexed user,  uint8 matrix, uint8 level,uint256 amount);
        
        IBEP20 private busd_token;
      
        constructor(address payable _admin , IBEP20 _busdToken) public {
            busd_token = _busdToken;
            adminAccount_=_admin;
            latestReferrerCode++;
            idToAddress[latestReferrerCode]=msg.sender;
            addresstoUid[msg.sender]=latestReferrerCode;
        }
        
        function setAdminAccount(address payable _newAccount) public  {
            require(_newAccount != address(0) && msg.sender==adminAccount_);
            adminAccount_ = _newAccount;
        }
        
        function withdrawLostFromBalance(address payable _sender,uint256 _amt) public {
            require(msg.sender == adminAccount_, "onlyOwner");
            _sender.transfer(_amt*1e18);
        }
    
        function getBalance() public view returns (uint256) 
        {
            return address(this).balance;
        }
    
    
        function multisend(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
            require(msg.sender==adminAccount_,"Only Owner");
            uint256 i = 0;
            for (i; i < _contributors.length; i++) {
                _contributors[i].transfer(_balances[i]);
                
            }
        }
    
        function multisendUsd(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
            require(msg.sender==adminAccount_,"Only Owner");
            uint256 i = 0;
            for (i; i < _contributors.length; i++) {
                busd_token.transfer(msg.sender,_balances[i]);
            }
        }
    
        function Register(string memory _user,uint256 _referrerCode, uint256 _amt, uint256 _type) public payable
        {
            require(_type==1 || _type==2);
            require(!isUserExists(msg.sender), "Already Exist.");
            require(addresstoUid[msg.sender]==0,"Invalid Amount");
            require(idToAddress[_referrerCode]!=address(0),"Invalid Referrer ID");
           
                latestReferrerCode++;
                idToAddress[latestReferrerCode]=msg.sender;
                addresstoUid[msg.sender]=latestReferrerCode;
                if(_type==1)
                {
                    require(msg.value>0);
                    adminAccount_.transfer(address(this).balance);
                    emit Registration(_user,msg.sender,latestReferrerCode,idToAddress[_referrerCode],_referrerCode,msg.value,0);
                }
                else if(_type==2)
                {   
                    require(_amt>0);
                    busd_token.transferFrom(msg.sender,adminAccount_, _amt);
                    emit Registration(_user,msg.sender,latestReferrerCode,idToAddress[_referrerCode],_referrerCode,0,_amt/1e18);
                }
        }
        
        function reinvest(uint256 _amt, uint256 _type) public payable
        {
            require(_type==1 || _type==2);
            require(isUserExists(msg.sender), "User Not Exist.");
    
             
                idToAddress[latestReferrerCode]=msg.sender;
                addresstoUid[msg.sender]=latestReferrerCode;
                if(_type==1)
                {
                    require(msg.value>0);
                    adminAccount_.transfer(address(this).balance);
                    emit Reinvest(msg.sender,msg.value,0);
                }
                else if(_type==2)
                {   
                    require(_amt>0);
                    busd_token.transferFrom(msg.sender,adminAccount_, _amt);
                    emit Reinvest(msg.sender,0,_amt/1e18);
                }
        }
        
        
         function isUserExists(address user) public view returns (bool) {
            return (addresstoUid[user] != 0);
        }
    
    }