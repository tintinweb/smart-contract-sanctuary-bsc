/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

abstract contract tokenContract {    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    function balanceOf(address account) public view virtual returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
    
contract CrowdSale is Context {
    
    struct generalConfig {
        uint256 rate;
        address tokenContractAddress;
        address admin;
        address owner;
        uint256 maxLimit;
        uint256 minBuy;
        uint256 maxBuy;
        uint256 sold;
        uint256 funded;
        uint256 balance;
        bool paused;
        bool whitelistStatus;
        uint256 arrKey;
        bool claimStatus;       
    }

    struct UserDetails {
        uint256 balance;
        uint256 sold;
        uint256 funded;
        uint256 arrKey;
        bool arrStatus;
        bool status;
        uint256 claimed;
    }    
    

    address[] participants;
    uint256[] tokenSold;
    uint256[] bnbFunded;     
    generalConfig _general;
    mapping(address =>  UserDetails) private _user;
    
    constructor () {
        _general.tokenContractAddress = 0x04892c91d296764189A47d88680B2F2eeFd5f2E9;
        _general.admin = _msgSender();
        _general.owner = 0x34c7936c916A82B89d1bA6897c8C01fB7aA0eDCd;
        _general.rate =  8100000000; 
        _general.maxLimit = 1234.5679 * 1e18; 
        _general.minBuy = 0.1 * 1e18;
        _general.maxBuy = 3 * 1e18;
        _general.paused = true;
        _general.whitelistStatus = true;       
    }
    
    event Bought(address indexed buyer, uint256 token);
        
    function generalDetails() public view returns (generalConfig memory) {
        generalConfig memory genConf = _general;
        genConf.balance = address(this).balance;
        return genConf;
    }
    
    function userDetails(address account) public view returns (UserDetails memory) {
        UserDetails memory tempUser = _user[account];
        tempUser.balance = tokenContract(_general.tokenContractAddress).balanceOf(account);
        return tempUser;
    }  
    
    function allUser() public view returns (address[] memory, uint256[] memory, uint256[] memory) {
        return (participants, tokenSold, bnbFunded);
    }
   
    function buy() public payable virtual returns (bool) {
        uint256 token;
        uint256 funded;
        uint256 refund;        
        require(!_general.paused, _general.claimStatus ? "PreSale already completed" : "PreSale not started yet" );
        if(_general.whitelistStatus){
           require(_user[_msgSender()].status, "Your address is not whitelisted"); 
        }        
        require((_general.maxLimit - _general.funded) > 0, "PreSale already completed");
        require(msg.value >= _general.minBuy, "Send payment greater or equal to Minimum Buy");
        require((_general.maxBuy -  _user[_msgSender()].funded) > 0, "Maximum Buy Limit Reached");
        funded = msg.value;
        if(funded > (_general.maxBuy -  _user[_msgSender()].funded)) {
            refund = funded - (_general.maxBuy -  _user[_msgSender()].funded);
            funded = msg.value - refund;
        }
        if(funded > (_general.maxLimit - _general.funded)){
            refund += funded - (_general.maxLimit - _general.funded);
            funded = msg.value - refund;
        }
        token = funded * _general.rate;
        if(refund > 0){
            payable(_msgSender()).transfer(refund);
        }
        _user[_msgSender()].sold += token;
        _user[_msgSender()].funded += funded;
        _general.sold += token;
        _general.funded += funded;
        if(!_user[_msgSender()].arrStatus){
            _user[_msgSender()].arrKey = _general.arrKey;
            _user[_msgSender()].arrStatus = true;
            participants.push(_msgSender());
            tokenSold.push(_user[_msgSender()].sold);
            bnbFunded.push(_user[_msgSender()].funded);  
            _general.arrKey += 1;         
        } else {
            tokenSold[_user[_msgSender()].arrKey] = _user[_msgSender()].sold;
            bnbFunded[_user[_msgSender()].arrKey] = _user[_msgSender()].funded;              
        }        
        emit Bought(_msgSender(), token);
        return true;
    }
    
    function claimToken() public virtual returns (bool) {
        require(_general.claimStatus, "Claiming token not allowed until sale ends");
        uint256 remain = _user[_msgSender()].sold - _user[_msgSender()].claimed;
        require(remain > 0, "Zero token left to claim");
        tokenContract(_general.tokenContractAddress).transferFrom(_general.owner, _msgSender(), remain);   
        _user[_msgSender()].claimed += remain;  
        return true;
    }

    function whitelist(address[] memory accounts) public virtual returns (bool) {
        require(_msgSender() == _general.admin, "Only admin can update");
		for (uint8 i; i < accounts.length; i++) {
		    _user[accounts[i]].status = true;
		}         
        return true;
    }
    
    function blacklist(address[] memory accounts) public virtual returns (bool) {
        require(_msgSender() == _general.admin, "Only admin can update");
		for (uint8 i; i < accounts.length; i++) {
		    _user[accounts[i]].status = false;
		}         
        return true;
    }    
    
    function claimFunding() public virtual returns (bool) {
        require(_msgSender() == _general.owner, "Only Owner can claim");
        require(address(this).balance > 0, "Zero Balance Left");
        payable(_general.owner).transfer(address(this).balance);
        return true;
    }   
    
    function update(uint256[7] memory info, address owner) public virtual returns (bool) {
        require(_msgSender() == _general.admin, "Only admin can update");
        _general.rate = (info[0] > 0)?info[0]:_general.rate;
        _general.maxLimit = (info[1] > 0)?info[1]:_general.maxLimit;
        _general.minBuy = (info[2] > 0)?info[2]:_general.minBuy;
        _general.maxBuy = (info[3] > 0)?info[3]:_general.maxBuy;
        if(owner != address(0)){
            _general.owner = owner;
        }
        if(info[4] > 0){
            _general.paused = (info[4] == 1)?true:false;
        }
        if(info[5] > 0){
            _general.whitelistStatus = (info[5] == 1)?true:false;
        }
        if(info[6] > 0){
            _general.claimStatus = (info[6] == 1)?true:false;
        }         
        return true;
    }
    
}