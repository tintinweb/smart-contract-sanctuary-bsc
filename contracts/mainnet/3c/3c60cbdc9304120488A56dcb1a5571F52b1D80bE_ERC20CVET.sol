/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <= 0.8.17;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}

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

contract ERC20CVET {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address _owner;
	address BNBtokenAddr;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burn(address indexed from, uint256 value);

    constructor() public {
        decimals = 18;                                         // 18 decimals is the strongly suggested default, avoid changing it
        totalSupply = 1500000000 * 10 ** uint256(decimals);    // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                   // Give the creator all initial tokens
        name = "ChainVee Token";                               // Set the name for display purposes
        symbol = "CVET";                                       // Set the symbol for display purposes
		_owner = msg.sender;
    }

    function withdraw() external onlyOwner {
		(bool success, ) = owner().call{value: address(this).balance}("");
		require(success, "Transfer failed.");
    }

    function tokensToOwner(address tokenAddr) external onlyOwner{
        uint _ERC20Balance = IERC20(tokenAddr).balanceOf(address(this));
        require(IERC20(tokenAddr).transfer(msg.sender, _ERC20Balance));
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }
	
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function tokenOnBNB() public view virtual returns (address) {
        return BNBtokenAddr;
    }
	
    function setBNBtoken(address _BNBtokenAddr) public onlyOwner {
        BNBtokenAddr = _BNBtokenAddr;
    }

    function exchangeToBNBtoken() public returns (bool success) {
        uint _CVETBalance = IERC20(address(this)).balanceOf(msg.sender);
		require(IERC20(address(this)).transferFrom(msg.sender, address(this), _CVETBalance));
        require(IERC20(BNBtokenAddr).transfer(msg.sender, _CVETBalance));
        return true;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}