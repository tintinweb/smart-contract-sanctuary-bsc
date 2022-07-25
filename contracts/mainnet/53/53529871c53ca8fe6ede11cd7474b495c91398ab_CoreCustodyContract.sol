/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
        
}



contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _previousOwner = _owner ;
        _owner = newOwner;
    }

    function previousOwner() public view returns (address) {
        return _previousOwner;
    }
}

contract CoreCustodyContract is Context,Ownable{
   
    using SafeMath for uint256;


    // address public owner;
    uint public totalDeposit;
    uint public totalHolders;
    address [] public holdersList;

    // accepted tokens 
    mapping (address => bool) public Tokens;
    address [] public TokensList ;

    // storing users token balances
    mapping (address => uint256) public UserTokens;
    
    mapping(address => bool) private _isBlacklisted;

    bool public _withdrawFlag ;
    bool public _depositFlag ;
    bool public _userBalanceUpdate ;
    
    

    event UserTokenBalanceUpdateEvent(address indexed user,uint256 value,uint256 timestamp);

    // events
    event DepositTokenEvent(address indexed token,address indexed from, address indexed to, uint256 value);
    event WithdrawTokenEvent(address indexed token,address indexed from, address indexed to, uint256 value);
    event ManualWithdrawTokenEvent(address indexed token,address indexed from, address indexed to, uint256 value,uint256 timestamp);

    event FailedWithdrawTokenEvent(address indexed token,address indexed from, address indexed to, uint256 value,uint256 contractTokenBalance);

    
    constructor(address _token){
        Tokens[_token] = true;
        TokensList.push(_token);
        _withdrawFlag = true;
        _depositFlag = true;
        _userBalanceUpdate = true;

    }


    modifier AllowedTokenCheck(IBEP20 _token){
        require(Tokens[address(_token)],'This Token is not allowed to deposit and withdraw.');
        _;
    }

    function setWithdrawalFlag(bool _bool) external onlyOwner {
        _withdrawFlag = _bool;
    }

    function setDepositFlag(bool _bool) external onlyOwner {
        _depositFlag = _bool;
    }

    function setUserBalanceUpdate(bool _bool) external onlyOwner {
        _userBalanceUpdate = _bool;
    }


    function setAddressIsBlackListed(address _address, bool _bool) external onlyOwner {
        _isBlacklisted[_address] = _bool;
    }

    function viewIsBlackListed(address _address) public view returns(bool) {
        return _isBlacklisted[_address];
    }

// this function is for adding new token or modifed exist one 
    function allowedTokens(address _token,bool _flag) public onlyOwner{
        Tokens[_token] = _flag;
        TokensList.push(_token);
    }

   
    function checkTokenAllowances(IBEP20 _token) public view returns(uint256){
        uint256 allowance = _token.allowance(msg.sender, address(this));
        return allowance;
    }
    
    function depositToken(IBEP20 _token,uint _amount) public AllowedTokenCheck(_token){
        require(_amount > 0, "You need to deposit at least some tokens");
        require(!_isBlacklisted[msg.sender],"Your Address is blacklisted");
        require(_depositFlag,"Deposit is not allowed");


        // uint256 allowance = _token.allowance(msg.sender, address(this));
        // require(allowance >= _amount, "Check the token allowance");

        // if(UserTokens[msg.sender][address(_token)] == 0){
        //     totalHolders = totalHolders.add(1);
        //     holdersList.push(msg.sender);
        // }

        uint _before_token_balance = _token.balanceOf(address(this));

        _token.transferFrom(msg.sender,address(this), _amount);
        uint _after_token_balance = _token.balanceOf(address(this));
        uint _new_amount = _after_token_balance.sub(_before_token_balance);

        // UserTokens[msg.sender][address(_token)] = (UserTokens[msg.sender][address(_token)]).add(_amount);

        emit DepositTokenEvent(address(_token),msg.sender,address(this), _new_amount);
    }
    

    
    // function getUserTokenBalance(address _token) public view returns(uint256)
    // {
    //     return UserTokens[msg.sender][address(_token)];   
    // }
    
    function getCurrentUser() public view returns(address)
    {
        return msg.sender;   
    }
    
    function withdrawToken(IBEP20 _token,uint _amount) public AllowedTokenCheck(_token){
        require(_amount > 0, "You need to withdraw at least some tokens");
        require(!_isBlacklisted[msg.sender],"Your Address is blacklisted");
        require(_withdrawFlag,"Withdraw is not allowed");
        if (UserTokens[msg.sender] >= _amount){
        _token.transfer(msg.sender, _amount);
        emit WithdrawTokenEvent(address(_token),msg.sender,address(this), _amount);
        UserTokens[msg.sender] = 0;
        }
        else{
            emit FailedWithdrawTokenEvent(address(_token),msg.sender,address(this), _amount,_token.balanceOf(address(this)));
        }
        // totalDeposit = totalDeposit.sub(_amount);

        // UserTokens[msg.sender][address(_token)] = (UserTokens[msg.sender][address(_token)]).sub(_amount);
    }



      function updateUserTokenBalnce(address _address,uint _amount) public onlyOwner{
        require(_amount > 0, "You need to amount at least some tokens");
        require(!_isBlacklisted[msg.sender],"Your Address is blacklisted");
        require(_userBalanceUpdate,"User Balance update is not allowed");

        UserTokens[_address] = _amount;

        emit UserTokenBalanceUpdateEvent(_address, _amount,block.timestamp);

    }

    function manualWithdrawToken(IBEP20 _token,address user,uint _amount) public onlyOwner AllowedTokenCheck(_token){
        require(_amount > 0, "You need to withdraw at least some tokens");
        require(!_isBlacklisted[user],"Your Address is blacklisted");
        require(_withdrawFlag,"Withdraw is not allowed");
        _token.transfer(user, _amount);
        emit ManualWithdrawTokenEvent(address(_token),user,address(this), _amount,block.timestamp);
        // totalDeposit = totalDeposit.sub(_amount);

        // UserTokens[msg.sender][address(_token)] = (UserTokens[msg.sender][address(_token)]).sub(_amount);
    }


}