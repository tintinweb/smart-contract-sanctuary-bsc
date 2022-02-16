/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.7;





contract Cov  {

    mapping(address => uint) public balances; 

    mapping(address => mapping(address =>uint)) public allowance;
    
    
    mapping(address => uint) public infectionTime ; // default is 0

    uint public totalSupply = 10000000000;  ///for every human one and a bit more non divisible 
    string public name = "SARS-CoV-2";
    string public symbol = "COVID-19";
    uint public decimals = 0; // you cannot have half of a covid am I right 


    event Transfer(address indexed from , address indexed to , uint value );

    event Approval(address indexed owner,address indexed spender ,uint value);


        ///activated on first deployement
    constructor() {
        balances[msg.sender]=totalSupply;   
        infectionTime[msg.sender]=157774680; //31 December 2019
        infectionTime[address(this)]=157774680; //31 December 2019
    
    }
                  
    function balanceOf(address owner) public view returns(uint){
    
        return balances[owner] ;///how much money owner has  
    }

    
    function transfer(address to , uint value) public returns(bool) {
      require(value > 0 ,'Cannot send zero');  
      require(balanceOf(msg.sender) >= value ,'balance too low ');
      require(quarantine(msg.sender) == false,'You are still in quarantine you can recive  but not send until the quarantine ends 14 days after your first funding ');
      
      if (infectionTime[to] == 0){infectionTime[to]=block.timestamp ;} 

      
      balances[to] += value;
      balances[msg.sender] -= value ;
      
      
      emit Transfer(msg.sender,to,value);  
      return true ;  

    }

    function transferFrom(address from,address to,uint value) public returns(bool){
        require(value > 0 ,'Cannot send zero');  
        require(balanceOf(from) >= value, 'balance too low ');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        
        require(quarantine(from) == false,'Owner is  still in quarantine he can recive  but cannot send until  quarantine ends 14 days after owners first funding ');
        
        if (infectionTime[to] == 0){infectionTime[to]=block.timestamp ;} 


        balances[to] += value ;
        balances[from] -= value ;
        allowance[from][msg.sender]-= value; 
        emit Transfer(from,to,value);
        return true ;


    }

    function transferAllallowedFrom(address from,address to) public returns(bool){
        require(balanceOf(from) > 0  ,'balance too low');
        require(allowance[from][msg.sender] > 0, 'allowance too low');
        
        require(quarantine(from) == false,'Owner is  still in quarantine he can recive  but cannot send until  quarantine ends 14 days after owners first funding ');
        
        if (infectionTime[to] == 0){infectionTime[to]=block.timestamp ;} 

        if (balanceOf(from) >= allowance[from][msg.sender]){

        balances[to] += allowance[from][msg.sender] ;
        balances[from] -= allowance[from][msg.sender] ;
        allowance[from][msg.sender]= 0; 
        }
        

        else {

        balances[to] += balances[from] ;
        allowance[from][msg.sender]-= balances[from] ;
        balances[from] = 0 ;

        }        



        emit Transfer(from,to,allowance[from][msg.sender]);
        return true ;


    }




    /// 4 approval functions approve adress,increase allowance ,decreaseAllowance and set approval to 0

    function approve(address spender ,uint value) public returns(bool){ 
        allowance[msg.sender][spender]= value ;
        emit Approval(msg.sender,spender,value);
        return true ;

    }


    function decreaseAllowance( address spender,uint subtracteby )public returns (bool){
      require(allowance[msg.sender][spender] > 0,'allowance too low');
      require(subtracteby > 0,'subtracting with zero');

    if (subtracteby > allowance[msg.sender][spender] ){
        allowance[msg.sender][spender]= 0;
        }
        /// if you decrease by more than current  allowance the alowance is set to 0      
    else{
        allowance[msg.sender][spender]-= subtracteby ;
        }

        emit Approval(msg.sender, spender,allowance[msg.sender][spender] );
        return true;
    }


    function increaseAllowance( address spender,uint addby )public returns (bool){
        
        allowance[msg.sender][spender]+= addby ;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function toZeroAllowance( address spender)public returns (bool){
        
        allowance[msg.sender][spender]=0 ;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }





      function printTime(address owner) public  view returns(uint){
        return infectionTime[owner] ;///returns infection time of owner  
    }

    function quarantine(address spender) public view returns (bool){

       /// quarantine defaultly false since  its 0 at the start 
    if (block.timestamp - infectionTime[spender]  >=   1209600){ /// 14 days of quarantine 
        
    return false ; 
    }       
    else {
        return true ;
    }


    }


}