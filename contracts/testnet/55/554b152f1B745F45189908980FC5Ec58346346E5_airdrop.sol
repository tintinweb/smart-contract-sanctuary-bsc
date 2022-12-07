/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
   
       _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
  
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
interface Token{
    function transfer(address _to, uint256 _value) external  returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address from,address _to, uint256 _value) external  returns (bool);
}

contract airdrop is Ownable,ReentrancyGuard
 {
      Token token;
    uint256 public airdropToken;
    uint256 public amountPerAddress = 10000000000000000000;  
    address payable public _owner;
    bool airdrop_active = false;    
    mapping(address => bool) public result;

     modifier onlyActive {
      require(airdrop_active == true, "Airdrop is active!");
      _;
    }  
    constructor()
     {    
        _owner = payable(msg.sender);       
    }
    function initializeAirDrop(Token token_,uint256 _airdropToken) public onlyOwner
    {
        require(_airdropToken != 0,"amount should be greater than zero");
        require(_airdropToken >= amountPerAddress,"amount should be greater than per user");
        require(address(token_) != address(0), "address must be available"); //airdrop tokeN address not = to 0
        require(msg.sender == _owner , "only owner can call");
        token = token_;
        airdropToken = _airdropToken;
        airdrop_active = true; 
        transferToken(_airdropToken);
    } 
    function transferToken(uint256 amount) internal returns(bool)
    {
        token.transferFrom(msg.sender, address(this),amount);
        return true;
    }
    function claimToken() public onlyActive
    {
       require(payable(msg.sender) != _owner, "owner can not claim tokens");              
       require(token.balanceOf(address(this)) >= amountPerAddress,"balance must be greater than require amount"  );
       require(result[msg.sender] == false , "user has already taken airdrop");
       token.transferFrom(address(this),msg.sender,amountPerAddress);
       result[msg.sender] = true;                       
    }
    function cancel() external  onlyOwner
     {        
        airdrop_active = false;
    }
     function Paused() external onlyOwner
    {
       airdrop_active = false;
    }  
    function updateTokenAdress(Token newTokenAdres) public onlyOwner
    {
        require(msg.sender == _owner , "only owner can call");
        token = newTokenAdres;
    }    
    function update_tokensPeraddres(uint256 newPerAddres) public onlyOwner
     {
        require(msg.sender == _owner , "only owner can call");
        amountPerAddress = newPerAddres;
    } 
     function getAirdropAmount() external view returns (uint256) {
      return token.balanceOf(address(this));
   }
   function getAmountPerUser()public view returns (uint256)
   {
     return amountPerAddress;
   }  
}