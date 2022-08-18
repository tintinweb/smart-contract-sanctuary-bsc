// Copyright (C) 2015, 2016, 2017 Dapphub
pragma solidity =0.6.6;

interface IERC20 {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external view returns (string memory);

	function symbol() external view returns (string memory);

	function decimals() external view returns (uint8);

	function totalSupply() external view returns (uint);

	function balanceOf(address owner) external view returns (uint);

	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);

	function transfer(address to, uint value) external returns (bool);

	function transferFrom(address from, address to, uint value) external returns (bool);
}

contract WETH {
	string public name = "Wrapped Ether";
	string public symbol = "WETH";
	uint8  public decimals = 18;
	address public owner;

	event  Approval(address indexed src, address indexed guy, uint wad);
	event  Transfer(address indexed src, address indexed dst, uint wad);
	event  Deposit(address indexed dst, uint wad);
	event  Withdrawal(address indexed src, uint wad);

	mapping(address => uint)                       public  balanceOf;
	mapping(address => mapping(address => uint))  public  allowance;

	constructor() public {
		owner = msg.sender;
	}

	function setNewOwner(address _newOwner) public {
		require(msg.sender == owner, "you are not owner");
		owner = _newOwner;
	}

	/**
	Clear unknown token
	*/
	function clearUnknownToken(address _tokenAddress) public {
		require(msg.sender == owner, "you are not owner");
		uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
	}

	function deposit() public payable {
		balanceOf[msg.sender] += msg.value;
		emit Deposit(msg.sender, msg.value);
	}

	function withdraw(uint wad) public {
		require(balanceOf[msg.sender] >= wad, "");
		balanceOf[msg.sender] -= wad;
		msg.sender.transfer(wad);
		emit Withdrawal(msg.sender, wad);
	}

	function totalSupply() public view returns (uint) {
		return address(this).balance;
	}

	function approve(address guy, uint wad) public returns (bool) {
		allowance[msg.sender][guy] = wad;
		emit Approval(msg.sender, guy, wad);
		return true;
	}

	function transfer(address dst, uint wad) public returns (bool) {
		return transferFrom(msg.sender, dst, wad);
	}

	function transferFrom(address src, address dst, uint wad)
	public
	returns (bool)
	{
		require(balanceOf[src] >= wad, "");

		if (src != msg.sender && allowance[src][msg.sender] != uint(- 1)) {
			require(allowance[src][msg.sender] >= wad, "");
			allowance[src][msg.sender] -= wad;
		}

		balanceOf[src] -= wad;
		balanceOf[dst] += wad;

		emit Transfer(src, dst, wad);

		return true;
	}
}