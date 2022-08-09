/**
 *Submitted for verification at BscScan.com on 2022-08-09
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
    function minHolderAmountFee() external view returns (uint256);
    function openState() external view returns (uint256);

    function excludedFromFees(address _addr) external view returns (uint256);
    function wilteAddress(address _addr) external view returns(uint256);
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
        _lpRewardOwner = 0x246827F2f1f7d3195FdEB22cA83a3F1a9922Ff3C;
        _lpRewardOwnerToken = 0x55d398326f99059fF775485246999027B3197955;
        _nodeRewardOwener = 0x479096ACB5d7bcf27Ad0Bd3Be22991C3BCeE583b;
        _lpRewardOwnerToken = 0x55d398326f99059fF775485246999027B3197955;
        _marketingWalletAddress = 0xf76AC02129DA88612ed6F39dFC4cc60fE1d2f6E1;
        _liquidityReceiveAddress = 0xf76AC02129DA88612ed6F39dFC4cc60fE1d2f6E1;
        _asLpAddress = 0xf76AC02129DA88612ed6F39dFC4cc60fE1d2f6E1;
        _contractAddress = 0x55d398326f99059fF775485246999027B3197955;
        _liquidityFee = 1;
        _lpRewardFee = 1;
        _marketingFee = 1;
        _nodeFee = 1;
        _asLpFee = 5;
        _holdMinAmount = 1*10**18;
        _swapTokensAtAmount = 500*10**18;
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
    uint256 private _holdMinAmount;
    uint256 private _openState;
    mapping(address => uint256) private _isExcludedFromFee;
    mapping(address => uint256) private _isWilteAddress;

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
    function openState() external view returns (uint256){
      return _openState;
    }
    function minHolderAmountFee() external view returns (uint256){
      return _holdMinAmount;
    }

    function wilteAddress(address _addr) external view returns(uint256){
      return _isWilteAddress[_addr];
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
    function setExcludedFromFees(address addr,uint256 state) public onlyOwner{
        _isExcludedFromFee[addr] = state;
    }
    
    function setMinHolderAmountFee(uint256 amount) public onlyOwner{
        _holdMinAmount = amount;
    }
    function setOpenState(uint256 state) public onlyOwner{
        _openState = state;
    }
    function setWiltrAddress(address[] memory addrs,uint256 state) public onlyOwner{
      for(uint256 i=0;i<addrs.length;i++){
        _isWilteAddress[addrs[i]] = state;
      }
    }
}