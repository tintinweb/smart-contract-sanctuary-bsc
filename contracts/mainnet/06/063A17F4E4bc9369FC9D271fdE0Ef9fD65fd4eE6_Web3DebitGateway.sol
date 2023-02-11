// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ReentrancyGuard.sol";


interface ERC20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);

}


contract Web3DebitGateway is ReentrancyGuard {

    address public owner;
    uint public fee;
    uint public transactionid;
    bool public locked;
    address public router;

event Payment(
    address indexed store,
    address indexed sender,
    address tokenin,
    address tokenout,
    uint amountin,
    uint amountout,
    uint source,
    uint memo,
    uint fee,
    uint amountnet);


struct DataPayment {
    address thestore;
    address thesender;
    address thetokenin;
    address thetoken;
    uint theamountin;
    uint theamount;
    uint thesource;
    uint thememo;
}


constructor(address _owner) {

    require(_owner != address(0));
    owner = _owner;

}


modifier onlyOwner() {

    require(msg.sender == owner);
    _;

}


function transferOwner(address _newowner) external onlyOwner {

    require(_newowner != address(0));
    owner = _newowner;

}


function changeFee(uint _newfee) external onlyOwner {
    
    fee = _newfee;

}


function lockGateway() external onlyOwner {
    
    if (locked) {
        locked = false;
    }

    if (!locked) {
        locked = true;
    }

}


function changeRouter(address _router) external onlyOwner {
    
    require(_router != address(0));
    router = _router;

}


function payment(
     address _store,
     address _token,
     uint _amount,
     uint _memo,
     address _sender,
     uint _source,
     address _tokenin,
     uint _amountin) external nonReentrant returns (bool) {

    require(msg.sender == router);
    require(!locked);
    require(_amount > 0);
    require(_memo > 0);
    require(_store != address(0));
    require(_token != address(0));
    require(_source > 0);
    require(_sender != address(0));
    require(_tokenin != address(0));
    require(_amountin > 0);

    DataPayment memory _datapayment = DataPayment(
        _store,
        _sender,
        _tokenin,
        _token,
        _amountin,
        _amount,
        _source,
        _memo);

    _payment(_datapayment);

    return true;

}


function _payment(DataPayment memory _datapayment) internal {

    uint decimals = ERC20(_datapayment.thetoken).decimals();
    transactionid += 1;

    require(ERC20(_datapayment.thetoken).balanceOf(msg.sender) >= _datapayment.theamount);
    require(ERC20(_datapayment.thetoken).allowance(msg.sender, address(this)) >= _datapayment.theamount);
    require(ERC20(_datapayment.thetoken).transferFrom(msg.sender, address(this), _datapayment.theamount));
    
    uint feeamount = _datapayment.theamount * ((fee) * 10 ** decimals / 10000);
    feeamount = feeamount / 10 ** decimals;

    uint netamount = _datapayment.theamount - feeamount;
        
    require(ERC20(_datapayment.thetoken).transfer(_datapayment.thestore, netamount));

    if (feeamount > 0) {
    require(ERC20(_datapayment.thetoken).transfer(owner, feeamount));
    }
       
    emit Payment(
        _datapayment.thestore,
        _datapayment.thesender,
        _datapayment.thetokenin,
        _datapayment.thetoken,
        _datapayment.theamountin,
        _datapayment.theamount,
        _datapayment.thesource,
        _datapayment.thememo,
        feeamount,
        netamount);

}


}