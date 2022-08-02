/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

pragma solidity ^0.5.0;

interface IDataToken {
    function lpRewardOwner() external view returns (address);
    function lpRewardToken() external view returns (address);
    function nodeRewardOwener() external view returns(address);
    function nodeRewardToken() external view returns (address);
    function marketingWalletAddress() external view returns (address);
    function liquidityReceiveAddress() external view returns (address);
    function asLpAddress() external view returns (address);
    function contractAddress() external view returns (address);

    function deadFee() external view returns (uint256);
    function reFee() external view returns (uint256);
    function liquidityFee() external view returns (uint256);
    function lpRewardFee() external view returns (uint256);
    function marketingFee() external view returns (uint256);
    function swapTokensAtAmount() external view returns (uint256);
    function asLpFee() external view returns (uint256);

    function excludedFromFees(address _addr) external view returns (uint256);
}

contract Context {

    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}



contract Ownable is Context {
    address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
  constructor () internal {
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
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract AToken is Context, IDataToken, Ownable{
    constructor() public {
        
    }
    address private _lpRewardOwner;
    address private _lpRewardOwnerToken;
    address private _nodeRewardOwener;
    address private _nodeRewardToken;
    address private _marketingWalletAddress;
    address private _liquidityReceiveAddress;
    address private _asLpAddress;
    address private _contractAddress;

    uint256 private _deadFee;
    uint256 private  _liquidityFee;
    uint256 private _lpRewardFee;
    uint256 private _marketingFee;
    uint256 private _swapTokensAtAmount;
    uint256 private _asLpFee;
    uint256 private _nodeFee;
    mapping(address => uint256) private _isExcludedFromFee;

    function excludedFromFees(address addr) external view returns (uint256){
        return _isExcludedFromFee[addr];
    }

    function lpRewardOwner() external view returns (address){
      return _lpRewardOwner;
    }
    function lpRewardToken() external view returns (address){
      return _lpRewardOwnerToken;
    }
    function nodeRewardOwener() external view returns(address){
      return _nodeRewardOwener;
    }
    function nodeRewardToken() external view returns (address){
      return _nodeRewardToken;
    }
    function marketingWalletAddress() external view returns (address){
      return _marketingWalletAddress;
    }
    function liquidityReceiveAddress() external view returns (address){
       return _liquidityReceiveAddress;
    }
    function asLpAddress() external view returns (address){
      return _asLpAddress;
    }

    function contractAddress() external view returns (address){
      return _contractAddress;
    }

    function deadFee() external view returns (uint256){
      return _deadFee;
    }
    function reFee() external view returns (uint256){
      return _nodeFee;
    }
    function liquidityFee() external view returns (uint256){
      return _liquidityFee;
    }
    function lpRewardFee() external view returns (uint256){
      return _lpRewardFee;
    }

    function marketingFee() external view returns (uint256){
      return _marketingFee;
    }
    function swapTokensAtAmount() external view returns (uint256){
      return _swapTokensAtAmount;
    }
    function asLpFee() external view returns (uint256){
      return _asLpFee;
    }

    function setLpRewardOwner(address addr) public onlyOwner{
        _lpRewardOwner = addr;
    }
    function setLpRewardToken(address addr) public onlyOwner{
      _lpRewardOwnerToken = addr;
    } 
    function setNodeRewardOwener(address addr) public onlyOwner{
      _nodeRewardOwener = addr;
    }
    function setNodeRewardToken(address addr) public onlyOwner{
      _nodeRewardToken = addr;
    }
    function setMarketingWalletAddress(address addr) public onlyOwner{
      _marketingWalletAddress = addr;
    }
    function setLiquidityReceiveAddress(address addr) public onlyOwner{
      _liquidityReceiveAddress = addr;
    }
    function setAsLpAddress(address addr) public onlyOwner{
      _asLpAddress = addr;
    }
    function setContractAddress(address addr) public onlyOwner{
      _contractAddress = addr;
    }
    function setDeadFee(uint256 amount) public onlyOwner{
      _deadFee = amount;
    }
    function setNodeFee(uint8 amount) public onlyOwner{
      _nodeFee = amount;
    }
    function setLiquidityFee(uint256 amount) public onlyOwner{
      _liquidityFee = amount;
    }
    function setLpRewardFee(uint256 amount) public onlyOwner{
      _lpRewardFee = amount;
    }
    function setMarketingFee(uint256 amount) public onlyOwner{
      _marketingFee = amount;
    }
    function setSwapTokensAtAmount(uint256 amount) public onlyOwner{
      _swapTokensAtAmount = amount;
    }
    function setAsLpFee(uint256 amount) public onlyOwner{
      _asLpFee = amount;
    }
    function setExcludedFromFees(address addr) public onlyOwner{
        _isExcludedFromFee[addr] = 1;
    }
}