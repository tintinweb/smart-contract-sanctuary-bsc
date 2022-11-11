/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract IDO is Ownable{
    using SafeMath for uint256;
    mapping(address=>uint256) private _invest;
    mapping(address=>uint256) private _draw;
    uint256 public minBalance = 1e16;
    uint256 public oneTokenReturn = 4;
    uint256 public conts = 0;
    uint256 public total = 0;
    bool public startInvest = false;
    bool public startChange = false;
    address internal receiver;
    IERC20 public coin;


    event setReturnLog (uint256);
    event setMinBalanceLog(uint256);
    event addInvestLog (address,uint256);
    event setCoinLog (address);
    event getCoinLog(address,uint256);
    event transferReceiverLog(address,uint256);
    event editUserInvestLog(address,uint256);
    event setReceiverLog(address,address);

    constructor(){}
    
    function editUserInvest(address _address, uint256 _amount) public onlyOwner returns(address,uint256){
        require(_address!=address(0),'Can not set 0x0');
        _invest[_address] = _amount;
        emit editUserInvestLog(_address,_amount);
        return(_address,_amount);
    }
    function getCoin() public returns (bool){
        require(startChange,'Change not start');
        uint256 _q=queryCoin(msg.sender);
        require(_q>0,'Not Coin');
        require(coin.balanceOf(address(this))>=_q,'Contract not coin');
        _draw[msg.sender]=_draw[msg.sender].add(_q);
        coin.transfer(msg.sender,_q);
        emit getCoinLog(msg.sender,_q);
        return true;
    }
    function invest() public payable returns(bool){
        require(startInvest==true,'Invest not start');
        require(msg.value>=minBalance,'The Invest Fail');
        setUserInvest(msg.sender,msg.value);
        emit addInvestLog(msg.sender,msg.value);
        return true;
    }
    function kill() public onlyOwner{
        address owners = owner();
        selfdestruct(payable(owners));
    }
    function setCoin (address _token) public onlyOwner returns(bool){
        require(_token!=address(0),'Can not set 0x0');
        coin = IERC20(_token);
        emit setCoinLog(_token);
        return true;
    }
    function setMinBalance(uint256 _amount) public onlyOwner returns (bool){
        require(_amount>=1e16,'Cannot set');
        minBalance = _amount;
        emit setMinBalanceLog(_amount);
        return true;
    }
    function setReceiver(address _address) public onlyOwner returns(bool){
        require(_address!=address(0),'Can not set 0x0');
        address _receiver=receiver;
        receiver = _address;
        emit setReceiverLog(_receiver,_address);
        return true;
    }
    function setReturn (uint256 _number) public onlyOwner returns(bool){
        require(_number>0,'Cannot set');
        oneTokenReturn = _number;
        emit setReturnLog(_number);
        return true;
    }
    function setStartChange () public onlyOwner returns(bool){
        startChange = !startChange;
        return startChange;
    }
    function setStartInvest () public onlyOwner returns(bool){
        startInvest = !startInvest;
        return startInvest;
    }
    function balanceOf(address _address) public view returns(uint256){
        return coin.balanceOf(_address);
    }
    function drawed(address _address) public view returns(uint256){
        return _draw[_address];
    }
    function getBalanceOfContract () public view returns(uint256){
        return address(this).balance;
    }
    function getUserBlance(address _user) public view returns(uint256){
        return _invest[_user];
    }
    function queryCoin(address _user) public view returns(uint256){
        uint256 _b = _invest[_user];
        _b = _b.mul(oneTokenReturn).sub(_draw[msg.sender]);
        return _b;
    }
    function queryReceiver() public view onlyOwner returns(address){
        return receiver;
    }

    function setUserInvest(address _user,uint256 _amount) internal returns(bool){
        _invest[_user]=_invest[_user].add(_amount);
        total = total.add(_amount);
        uint256 _b = address(this).balance;
        payable(receiver).transfer(_b);
        emit transferReceiverLog(receiver,_b);
        conts++;
        return true;
    }
    function toWei(uint256 _amount) public pure returns(uint256){
        return _amount*1e18;
    }
    fallback () external payable{
        require(startInvest,'Invest not start');
        require(msg.value>=minBalance,'The Invest Fail');
        setUserInvest(msg.sender,msg.value);
        emit addInvestLog(msg.sender,msg.value);
    }
    receive () external payable{
        require(startInvest,'Invest not start');
        require(msg.value>=minBalance,'The Invest Fail');
        setUserInvest(msg.sender,msg.value);
        emit addInvestLog(msg.sender,msg.value);
    }
}