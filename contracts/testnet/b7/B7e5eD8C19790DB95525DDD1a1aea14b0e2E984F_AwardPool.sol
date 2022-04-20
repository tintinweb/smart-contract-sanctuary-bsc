// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";

contract AwardPool  is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    mapping (address => mapping (address => uint256)) private tokenAmount;

    address public feeAddress;
    address public burnAddress;
    struct Config {
        uint256 fee;
        uint256 minAmount;
        uint256 maxAmount;
        bool status;
    }
    mapping (address => Config) private configMap;

    event Claim(address indexed currency,address indexed _user, uint256 _value,uint256 fee);
    event ClaimAll(address indexed _user, uint256 _value);
    event AddUserAmount(address indexed currency,address indexed _user,uint256 _value);
    event Burn(address indexed currency,uint256 _value,string destroyType);

    function changeAddress(address _feeAddress,address _burnAddress) public onlyOwner {
      feeAddress=_feeAddress;
      burnAddress=_burnAddress;
    }

    function changeConfig(address currency,uint256 _fee,uint256 _minAmount,uint256 _maxAmount,bool _status) public onlyOwner {
        configMap[currency]=Config(_fee,_minAmount,_maxAmount,_status);
    }

    function getConfig(address currency) external view returns(uint256 _fee,uint256 _minAmount,uint256 _maxAmount,bool _status)  {
       return (configMap[currency].fee,configMap[currency].minAmount,configMap[currency].maxAmount,configMap[currency].status);
    }

    function getUserTokenAmount(address currency,address _userAddress) external view returns(uint256)  {
       return tokenAmount[currency][_userAddress];
    }
  
    function addUserAmount(address currency,address _userAddress,  uint256 _amount) public onlyOwner{
        require(_amount > 0, "_amount > 0");
        tokenAmount[currency][_userAddress]=tokenAmount[currency][_userAddress].add(_amount);
        emit AddUserAmount(currency,_userAddress, _amount);
    }
   
    function claim(address currency,uint256 _amount) public {
        require(tokenAmount[currency][msg.sender] >0, "claim: userAmount must > 0");
        require(tokenAmount[currency][msg.sender] >= _amount, "claim: userAmount must > realamount");        
        Config memory config  =configMap[currency];
        require(config.minAmount <= _amount&&config.maxAmount >= _amount, "claim: _amount error!");  
        require(config.status, "claim: status is error!");   
        uint256 fee=SafeMath.div(SafeMath.mul(_amount,config.fee),100);
        uint256 realamount=SafeMath.sub(_amount,fee);
        safeRewardTokenTransfer(currency,address(msg.sender), realamount);
        if(fee>0){
           claimBurn(currency,fee);
        }
        tokenAmount[currency][msg.sender] = tokenAmount[currency][msg.sender].sub(_amount);
        emit Claim(currency,msg.sender, _amount,fee);
    }

    function claimBurn(address currency,uint256 _amount)  private {
        if(feeAddress == address(0)){
            IERC20(currency).burn(_amount);
        }else{
            safeRewardTokenTransfer(currency,feeAddress, _amount);  
        }
    }

    function claimAll(address currency) public onlyOwner{
       uint256 tokenBal = IERC20(currency).balanceOf(address(this));
       safeRewardTokenTransfer(currency,address(msg.sender), tokenBal);
       emit ClaimAll(msg.sender, tokenBal);
    }
    
    function safeRewardTokenTransfer(address currency,address _to, uint256 _amount) internal {
        uint256 tokenBal = IERC20(currency).balanceOf(address(this));
        require(tokenBal >0 , "pool not balance"); 
        require(tokenBal >= _amount , "_amount too large"); 
        IERC20(currency).transfer(_to, _amount);    
    }

    function burn( address currency,uint256 _amount,string memory destroyType)  public onlyOwner {
        if(burnAddress == address(0)){
            IERC20(currency).burn(_amount);
        }else{
            safeRewardTokenTransfer(currency,burnAddress, _amount); 
        }
        emit Burn(currency, _amount,destroyType);
    }



 

}