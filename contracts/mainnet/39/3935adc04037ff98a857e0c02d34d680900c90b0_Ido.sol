/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
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


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract HasNoEther is Ownable {

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
    function reclaimEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
  
    function reclaimTokenByAmount(address tokenAddress,uint amount) external onlyOwner {
        require(tokenAddress != address(0),'tokenAddress can not a Zero address');
        TransferHelper.safeTransfer(tokenAddress, owner(),amount);
    }
}

contract Ido is HasNoEther{
    using SafeMath for uint256;

    event Buy(address indexed sender,address _level,uint256 id);
    event ReciveToken(address indexed sender,uint256 amount);

    mapping(address =>mapping(uint256=>bool)) public _hasBuy;
    mapping(address =>uint256) public totalToken;
    mapping(address =>uint256) public lockToken;
    mapping(address => uint256) public hasReciveToken;
    mapping(uint256 => uint256) public idoAmount;


    address public _revice = address(0x6C015fdb6a388D5Ff25848bE695aFd4007B3e4d7);
    address public _star ;
    bool    public _start;
    uint256 public _startTime;
    uint256 public _time ;
    uint256 public _relaseRate = 3;
    uint256 public _relaseTime = 1 days;
    uint256 public _realseCount = 90;
    uint256 public _starAmount = 20000 ;
    uint256 public _totalAmount = 100000000 ether;
    uint256 public _remainAmount = 100000000 ether;
    uint256 public _hasReciveBnb;
    uint256 private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, "FLASH: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        idoAmount[1] = 1 * 1e18 ;idoAmount[2] = 10 * 1e18; idoAmount[3] = 30 * 1e18;
    }
    
    function info() external view returns(bool,uint,uint,uint,uint,uint){
        return (_start,_time,_totalAmount,_remainAmount,_starAmount,_hasReciveBnb);
    }

    function addTotalAmount(uint256 _amount) external onlyOwner {
        TransferHelper.safeTransferFrom(_star,msg.sender,address(this),_amount);
        _totalAmount+=_amount;
        _remainAmount+=_amount;
    }

    //start IDO
    function start(uint _beginTime,uint _endTime) external onlyOwner{
        _start = true;
        _startTime = _beginTime;
        _time = _endTime;
    }

    function endTime() external view returns(uint256) {
        uint256 _end = _startTime.add(_time);
        if(_end > block.timestamp){
            return _end.sub(block.timestamp);
        }
        return 0;
    }

    // set EndTime
    function setTime(uint256 _minutes) external onlyOwner{
        _time = _minutes;
    }
    //set StarToken Address
    function setStar(address _value) external onlyOwner {
        _star = address(_value);
    }

    function canReciveToken() public view returns(bool _state){
        return (block.timestamp >= _startTime.add(_time) || _remainAmount==0);
    }

    function getLockToken() external view returns(uint){
        uint256 _total = totalToken[msg.sender] ;
        if(_total == 0 ) return 0;
        return _total.sub(activeToken()).sub(hasReciveToken[msg.sender]);
    }

    function activeToken() public view returns(uint){
        uint256 _total = totalToken[msg.sender] ;
        if(_total == 0 ) return 0;
        uint256 _endTime = _startTime + _time;
        if(block.timestamp < _endTime) return 0;

        uint256 count = (block.timestamp.sub(_endTime)).div(_relaseTime);
        uint256 _totalRelase;
        if(count > 0){
            count = Math.min(count,_realseCount);
            uint256 _number =  lockToken[msg.sender].div(_realseCount);
            _totalRelase = count * _number;
        }
        uint256 _hasRecive = hasReciveToken[msg.sender];
        uint256 _init = _total.mul(_relaseRate).div(10);
        uint256 _actual = _init.add(_totalRelase).sub(_hasRecive);
        if(_hasRecive.add(_actual) >= _total){
            _actual = _total.sub(_hasRecive);
        }
        return _actual;
    }

    function reciveToken() external lock{
        require(canReciveToken(),'Star: IDO is in progress');
        uint _relase = activeToken();
        require(_relase > 0,'Insufficient quantity available');
        hasReciveToken[msg.sender] = hasReciveToken[msg.sender].add(_relase);
        TransferHelper.safeTransfer(_star,msg.sender,_relase);
        emit ReciveToken(msg.sender,_relase);
    }

    function buy(uint256 id,address _level) external payable{
        require(_start,'Star: IDO is not start');
        require(!_hasBuy[msg.sender][id],'has been buy this channel');
        _hasBuy[msg.sender][id]=true;
        require(!canReciveToken(),'Star: IDO is ended');
        require(msg.sender!=_level,'Star: level can not yourself');
        uint256 _bnb = idoAmount[id];
        require(_bnb == msg.value,'invalid amount');
        payable(_revice).transfer(msg.value);
       
        uint starAmount = _starAmount.mul(_bnb);
        _remainAmount = _remainAmount.sub(starAmount);

        _hasReciveBnb = _hasReciveBnb.add(_bnb);
        totalToken[msg.sender] = totalToken[msg.sender].add(starAmount);
        uint256 _relase = starAmount.mul(_relaseRate).div(10);
        lockToken[msg.sender] = starAmount.sub(_relase);
        emit Buy(msg.sender,_level,id);
    }

 }