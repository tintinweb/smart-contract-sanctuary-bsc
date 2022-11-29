/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

abstract contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}


contract ERC20 {

    string  public  name;
    string  public  symbol;
    uint8   public  decimals;
    uint256 public  totalSupply;
    address public  owner = address(0x0);
    address public  factory;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    constructor(){
        factory = msg.sender;
    }
    function initialize(address _owner,string memory _name,string memory _symbol,uint256 _totalSupply,uint8 _decimals)public  {
        
        require(msg.sender == factory);
        owner = _owner;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** decimals;
        balances[msg.sender] = totalSupply;

        emit Transfer(address(0x0),_owner,totalSupply);
    }
    function balanceOf(address tokenOwner) public view returns (uint256)
    {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public returns (bool)
    {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address _owner, address _delegate) public view returns (uint256)
    {
        return allowed[_owner][_delegate];
    }

    function transferFrom(address _owner,address _buyer,uint256 _numTokens) public returns (bool) 
    {
        require(_numTokens <= balances[_owner]);
        require(_numTokens <= allowed[_owner][msg.sender]);

        balances[_owner] = balances[_owner] - _numTokens;
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender] - _numTokens;
        balances[_buyer] = balances[_buyer] + _numTokens;
        emit Transfer(_owner, _buyer, _numTokens);
        return true;
    }
}

contract TokenFactory is Ownable {

    uint256 public  fee     = 0.0002 * 10 ** 18;

    event Created_TOKEN(address contractAddr,address   ownerAddr);
    function Create_TOKEN(string memory _name,string memory _symbol,uint256 _totalSupply,uint8 _decimals)public payable returns(address addr){
        require(msg.value >= fee);
        // payable(owner()).transfer(msg.value);
        bytes memory bytecode= type(ERC20).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender,block.timestamp));
        
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }
        
        ERC20(addr).initialize(msg.sender,_name,_symbol,_totalSupply,_decimals);

        emit Created_TOKEN(addr,msg.sender);
    }
    function withdraw(ERC20 token) public onlyOwner{

        if(address(token) == address(0x0)){
            require(address(this).balance > 0);
            payable(owner()).transfer(address(this).balance);
        }
        else{
            require(token.balanceOf(address(this)) > 0);
            token.transfer(owner(), token.balanceOf(address(this)));
        }
    }

    function setFee(uint256 _fee) public onlyOwner {
        require(_fee > 0);
        fee = _fee;
    }
}