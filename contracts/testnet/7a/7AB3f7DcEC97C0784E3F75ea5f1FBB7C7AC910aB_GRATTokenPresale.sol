/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

//SPDX-License-Identifier:Unlicensed
pragma solidity 0.8.13;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    
}

interface IERC20 {

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

abstract contract Context {

    function _msgSender() internal view returns(address){
        return(msg.sender);
    }

    function _msgData() internal pure returns(bytes memory){
        return(msg.data);
    }

}

abstract contract Ownable is Context{

    address private _owner;

    event TransferOwnerShip(address oldOwner, address newOwner);

    constructor () {
        _owner = _msgSender();
        emit TransferOwnerShip(address(0), _owner);
    }

    function owner() public view returns(address){
        return _owner;
    }

    modifier onlyOwner {
        require(_owner == _msgSender(),"Only allowed to Owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"ZEROADDRESS");
        require(newOwner != _owner, "Entering OLD_OWNER_ADDRESS");
        emit TransferOwnerShip(_owner, newOwner);
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal onlyOwner {
        _owner = newOwner;
    }

    function renonceOwnerShip() public onlyOwner {
        _owner = address(0);
    }

}

contract GRATTokenPresale is Ownable{

    using SafeMath for uint256;

    IERC20 private token;

    uint256 private _rate = 1;
    uint256 private _weiRaised;
    uint256 public pendingTokens;
    uint256 private breakTime;

    bool private saleStatus;

    mapping(address => uint256) preSaleToken;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 indexed amount);
    event TokenClaim(address indexed purchaser, uint256 indexed amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function rate() external view returns(uint256){
        return _rate;
    }

    function weiRaised() external view returns(uint256){
        return _weiRaised;
    }

    function startSale() external onlyOwner{
        require(!saleStatus,"SALE_ALREADY_STARTED");
        saleStatus = true;
    }

    function stopSale() external onlyOwner{
        require(saleStatus,"SALE_ALREADY_STOPPED");
        saleStatus = false;
        breakTime = block.timestamp + 30;
    }

    function updateRate(uint256 rate_) external onlyOwner returns(bool) {
        require(!saleStatus,"UPDATE IS AVAILABLE ONLY SALE_STOPPED");
        _rate = rate_;
        return true;
    }

    function buyToken(address _receiver) external payable returns(bool){
        require(_receiver != address(0),"RECEIVER_IS_ZEROADDRESS");
        require(msg.value > 0,"INVALID_ETHER");
        require(saleStatus,"SALE_STOPED");

        uint256 _msgValue = msg.value;
        bool success = _transferFund(_msgValue);
        require(success,"TransferFund failed!!!");
        
        uint256 _tokenAmount = _getTokenAmount(_msgValue);
        pendingTokens += _tokenAmount;
        preSaleToken[_receiver] = preSaleToken[_receiver].add(_tokenAmount);
        _weiRaised = _weiRaised.add(_msgValue);

        emit TokenPurchase(_msgSender(), _receiver, _msgValue, _tokenAmount);
        return true;
    }

    function claimPreSaleToken() external returns(bool){
        require(preSaleToken[_msgSender()] > 0,"INSUFFICIENT_PRESALETOKEN");
        require(!saleStatus,"PRESALE_IS_NOT_COMPLETED");
        require(block.timestamp > breakTime, "MAINTAINENCE_BREAK");

        uint256 _tokenAmount = preSaleToken[_msgSender()];
        preSaleToken[_msgSender()] = preSaleToken[_msgSender()].sub(_tokenAmount);
        token.transfer(_msgSender(),_tokenAmount);

        emit TokenClaim(_msgSender(), _tokenAmount);
        return true;
    }

    function _transferFund(uint256 _msgValue) internal returns(bool success){
        (success) = payable(owner()).send(_msgValue);
    }

    function _getTokenAmount(uint256 _amount) internal view returns(uint256){
        return _amount.mul(_rate);
    }

    function deposit() external onlyOwner {
        require(!saleStatus, "SALE_IS_NOT_ENDED");
        _transfer(pendingTokens);
        _reAllocatingPending();
    }

    function _transfer(uint256 _amount) internal {
        token.transferFrom(_msgSender(),address(this),_amount);
    }

    function _reAllocatingPending() internal {
        pendingTokens = 0;
    }

    function preSaleBalanceOf(address _account) external view returns(uint256){
        return preSaleToken[_account];
    }

    function balanceOf(address _address) external view returns(uint256){
        return token.balanceOf(_address);
    }

    function statusOfPreSale() public view returns(bool){
        return saleStatus;
    }

}