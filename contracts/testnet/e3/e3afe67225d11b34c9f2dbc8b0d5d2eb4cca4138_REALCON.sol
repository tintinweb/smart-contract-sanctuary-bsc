/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: UNLISCENSED
pragma solidity 0.8.7;
contract REALCON {
    string public name = "MetaFinanceToken";
    string public symbol = "MFT";
    uint256 public totalSupply =1100000*10**18; // 11 lack token
    uint8 public decimals = 18;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    address private admin;
    bool public istransfer = true;
    mapping (address => bool) public isBlocklisted;
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() {
        admin=msg.sender;
        balanceOf[admin] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    function manageTransfer() public {
        require(msg.sender==admin,"Only contract owner"); 
        istransfer = !istransfer;
    }
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
         require(istransfer, "Transfer token disabled!");
        require(!isBlocklisted[msg.sender], "Address is blocklisted!");
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function depositToken(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function addToBlocklist(address[] memory _addresses) external {
        if (msg.sender != admin) {revert("Access Denied");}
        for (uint256 i = 0;i < _addresses.length;i++) {
            isBlocklisted[_addresses[i]] = true;
        }
    }

    function removeFromWhitelist (address[] memory _addresses) external {
        if (msg.sender != admin) {revert("Access Denied");}
        for (uint256 i = 0;i < _addresses.length;i++) {
            isBlocklisted[_addresses[i]] = false;
        }
    }
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
         require(istransfer, "Transfer token disabled!");
        require(!isBlocklisted[msg.sender], "Address is blocklisted!");
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function burn(uint256 amount) public returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    function _burn(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balanceOf[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        require(totalSupply>=amount, "Invalid amount of tokens!");
        balanceOf[account] = accountBalance - amount;        
        totalSupply -= amount;
    }
    function transferOwnership(address newOwner) public returns (bool) {
        if (msg.sender != admin) {revert("Access Denied");}
        admin = newOwner;
        return true;
    }
    function withdraw(address payable _receiver, uint256 _amount) public {
		if (msg.sender != admin) {revert("Access Denied");}
		_receiver.transfer(_amount);  
    }
}