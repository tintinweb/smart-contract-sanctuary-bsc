/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.16; 
  
contract Randomness{ 
    uint256 internal randNonce = 0; 
    address private _owner;
    mapping(address => bool) internal _isAdmin;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event GenerateRandomNumbers(uint256[] randomNumbers);
    constructor(){
        _owner = msg.sender;
    }
  
  function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner{
      require(owner() == msg.sender, "Accesible limit: caller is not the owner");
      _;
  }
  modifier onlyOwnerAndAdmin() {
      require(owner() == msg.sender || _isAdmin[msg.sender], "Accesible limit: caller is not the owner or admin");
      _;
  }
  function addAdmin(address _address) external onlyOwner{
      _isAdmin[_address] = true;
  }
  function removeAdmin(address _address) external onlyOwner{
    _isAdmin[_address] = false;
  }
  function isAdmin(address _address) external view onlyOwnerAndAdmin returns (bool){
      return _isAdmin[_address];
  }
  function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
         address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

function randMod(uint256 _modulus,uint256 _currentLoop) internal returns(uint256){ 
   randNonce++;  
   return uint256(keccak256(abi.encodePacked(msg.sender,randNonce,block.timestamp,_currentLoop, block.basefee, block.gaslimit,tx.gasprice,gasleft()))) % _modulus; 
 } 
 function randomNumber(uint256[] calldata _nums, uint256 _randLength) external onlyOwnerAndAdmin returns(uint256[] memory){
    uint256 length = _nums.length;
    require(length >= _randLength, "_randLength cannot over limit length of input _nums");
    uint256[] memory res = new uint256[](_randLength); 
    for(uint256 i=0;i<_randLength;++i){ 
        uint256 num = randMod(length,i); 
        res[i] = _nums[num]; 
    } 
    emit GenerateRandomNumbers(res);
    return res; 
 } 
 function randomDefault(uint256 _randLength)external onlyOwnerAndAdmin returns(uint256[] memory) {
    require(_randLength < 10, "invalid _randLength");
    uint256[10] memory _nums = [uint256(0),1,2,3,4,5,6,7,8,9];
    uint256[] memory res = new uint256[](_randLength); 
    for(uint256 i=0;i<_randLength;++i){ 
        uint256 num = randMod(10,i); 
        res[i] = _nums[num]; 
    } 
    emit GenerateRandomNumbers(res);
    return res;
 }
}