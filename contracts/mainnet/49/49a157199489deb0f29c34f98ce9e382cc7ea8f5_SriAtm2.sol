/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

pragma solidity ^0.8.2;

contract SriAtm2 {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000000 * 10 ** 18;
    string public name = "Sriatm2";
    string public symbol = "SIT";
    uint public decimals = 18;

    uint256 public _taxFee = 20;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 0;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _burnFee = 0;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _charityFee = 30;
    address public charityWallet = 0xC130f64E4e2986B4D4Adfa19c28282AcB517E4fd;
    uint256 private _previouscharityFee = _charityFee;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}