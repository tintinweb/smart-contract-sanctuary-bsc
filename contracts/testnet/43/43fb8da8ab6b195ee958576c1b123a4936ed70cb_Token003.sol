/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// Token 003

// testnet
// 

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

contract Token003 {

    string public name = "Token 003";
    string public symbol = "T003";
    uint public decimals = 8;
    uint public totalSupplyAtLaunch = 100_000 * ( 10 ** decimals );
    uint public totalSupply = totalSupplyAtLaunch;
    uint public totalSupplyForLiquidity = 1_000;
    uint public inCirculation = 0;
   
    // TESTNET addresses
    address public addressBurn = payable(0xe5A56BDcb7ef0655D06FB842d8fE8C7ecAf3785D); // TESTNET burn   
    address public addressDev = payable(0x91b50BEA858D8A378F19FBE522cEC08EfF01d4Ca); // TESTNET dev 
    address public addressMarketing = payable(0xBa87f373E1D46e2f2B32deecd90cF2C2002E852a); // TESTNET marketing
    address public addressReward = payable(0xd360A90144a3ea66C35D01E4Ad969Df41f607479); // TESTNET reward

    uint8 public taxDev = 10;
    uint8 public taxMarketing = 5;
    uint8 public taxReward = 0;
    uint8 public taxTransfer = 1;
    
    bool public tradingEnabled = false;
    uint public tradingEnabledTime; 

    address payable public token;
    address payable public owner;

    mapping(address => uint) private balance;
    mapping(address => mapping(address => uint)) private budget;

    mapping(address => bool) private blacklist;
    mapping(address => bool) private exempt; // not taxed and not receiving reward
    /*
    mapping(address => bool) private exemptTax; // not taxed
    mapping(address => bool) private exemptReward; // not receive reward
    */
    
    modifier isAuthorised() { require(msg.sender == owner, "Not authorised"); _; }
    //modifier notBlacklisted() { require(!blacklist[msg.sender], "Is blacklisted"); _; }

    event Approval(address indexed holder, address indexed spender, uint amount);
    event Burn(address indexed from, address indexed to, uint amount); 
    event Transfer(address indexed from, address indexed to, uint amount);
    event TransferFrom(address indexed from, address indexed to, uint amount, address indexed spender);

    receive() external payable {}

    constructor() {

        token = payable(address(this));
        balance[token] = totalSupplyAtLaunch;
        emit Transfer(address(0), token, totalSupplyAtLaunch);

        owner = payable(msg.sender);
        balance[token] -= totalSupplyForLiquidity;
        balance[owner] = totalSupplyForLiquidity;
        emit Transfer(token, owner, totalSupplyForLiquidity);
        
        exempt[token] = true;
        exempt[owner] = true;
        exempt[addressBurn] = true;
        exempt[addressDev] = true;
        exempt[addressMarketing] = true;
        exempt[addressReward] = true;

        /*
        exemptTax[address(this)] = true;
        exemptTax[owner] = true;
        exemptTax[addressBurn] = true;
        exemptTax[addressDev] = true;
        exemptTax[addressMarketing] = true;
        exemptTax[addressReward] = true;
     
        exemptReward[address(this)] = true;
        exemptReward[owner] = true;
        exemptReward[addressBurn] = true;
        exemptReward[addressDev] = true;
        exemptReward[addressMarketing] = true;
        exemptReward[addressReward] = true;
        */
   
    }
  

    function approve(address spender, uint amount) public returns(bool) {
        require(msg.sender != address(0) && spender != address(0), "Null address");
        require(amount != 0, "Zero amount");
        budget[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;   
    }

    function balanceOf(address holder) public returns(uint){
        return balance[holder];
    }

    function blacklistAdd(address holder) public isAuthorised {
        blacklist[holder] = true;
    }
    function blacklistRemove(address holder) public isAuthorised {
        require(blacklist[holder] == true, "Address not blacklisted");
        blacklist[holder] = false;
    } 
    function isBlacklisted(address holder) public isAuthorised returns(bool){
        return blacklist[holder];
    }

    function burn(uint amount) public isAuthorised returns(bool) {
        //require(totalSupply - inCirculation >= amount, "Amount too big: burn()");
        balance[owner] -= amount;
        balance[addressBurn] += amount;
        totalSupply -= amount;         
        emit Burn(msg.sender, addressBurn, amount);
        return true;
    }

    function enableTrading() public isAuthorised {
        require(tradingEnabled == false, "Trading already enabled");
        tradingEnabledTime = block.timestamp;
        tradingEnabled = true;
    }

    function setName(string memory textN, string memory textS ) public isAuthorised {
        name = textN;
        symbol = textS;
    }

    function transfer(address to, uint amount) public returns(bool) {
        require(tradingEnabled == true, "Trading not enabled: transfer()");
        address from = msg.sender;
        require(!blacklist[from], "From address blacklisted: transfer()");
        require(balance[from] >= amount, "From balance too small: transfer()");
        
        balance[from] -= amount;

        uint _taxT;
        if (!exempt[to]){
            _taxT = ( amount * taxTransfer ) / 100;
            balance[addressReward] += _taxT; 
        }

        balance[to] += amount - _taxT;

        emit Transfer(from, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint amount) public returns(bool) {
        require(tradingEnabled == true, "Trading not enabled: transferFrom()");
        require(!blacklist[from], "From address blacklisted: transferFrom()");
        require(balance[from] >= amount, "From balance too small: transferFrom()");
        address spender = msg.sender;
        require(budget[from][spender] >= amount, "Spender budget too small: transferFrom()");
        
        balance[from] -= amount;
        budget[from][spender] -= amount;
  
        uint _taxD;
        uint _taxM;
        uint _taxR;
        if (!exempt[to]){
            _taxD = ( amount * taxDev ) / 100;
            _taxM = ( amount * taxMarketing ) / 100;
            _taxR = ( amount * taxReward ) / 100;
            balance[addressDev] += _taxD;
            balance[addressMarketing] += _taxM;
            balance[addressReward] += _taxR; 
        }

        balance[to] += amount - ( _taxD + _taxM + _taxR );
        
        emit TransferFrom(from, to, amount, spender);
        return true;   
    }

}