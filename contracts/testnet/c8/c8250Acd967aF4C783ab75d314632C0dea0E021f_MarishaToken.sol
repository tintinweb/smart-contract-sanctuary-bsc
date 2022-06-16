/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract MarishaToken is IERC20 {
    address immutable private i_owner;
    string public constant name = "ERC20_Marisha";
    string public constant symbol = "Mar";
    uint8 public constant decimals = 18;

    enum UserType{ NORMAL, PREMIUM, VIP }
    mapping(address => uint256) private balances;
    mapping(address => uint256) private totalEarn;
    mapping(address => uint256) private totalDeduct;
    mapping(address => UserType) private userTypes;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 totalSupply_;

    event AddPoints(address to, uint256 value);
    event DeductPoints(address from, uint256 value);

    constructor (uint256 initialSupply) {
       totalSupply_ = initialSupply;
       balances[msg.sender] = totalSupply_;
       i_owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == i_owner, "You are not an owner!");
        _;
    }

    function totalSupply() public override view returns(uint256) {
        return totalSupply_;
    }

    function increaseTotalSupply(uint256 _newTokensAmount) external onlyOwner {
        totalSupply_ += _newTokensAmount;
        balances[msg.sender] += _newTokensAmount;
    }

    function balanceOf(address _tokenOwner) public override view returns (uint256){
        return balances[_tokenOwner];
    }

    function allowance(address _owner, address _delegate) public override view returns (uint256){
        return allowed[_owner][_delegate];
    }

    function addPoints(address _to, uint256 _value) external onlyOwner {
        if(userTypes[_to] == UserType.PREMIUM) {
            _value *= 2;
        } else if(userTypes[_to] == UserType.VIP) {
            _value *= 5;
        }
        totalEarn[_to] += _value;
        transfer(_to, _value);
    }

    function deductPoints(address _from, uint256 _value) external {
        totalDeduct[_from] += _value;
        transfer(i_owner, _value);
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }

    function getTotalEarn() external view returns(uint256) {
        return totalEarn[msg.sender];
    }

    function getTotalDeduct() external view returns(uint256) {
        return totalDeduct[msg.sender];
    }

    function approve(address _delegate, uint256 _numTokens) public override returns(bool) {
        allowed[msg.sender][_delegate] = _numTokens;
        emit Approval(msg.sender, _delegate, _numTokens);
        return true;
    }

    function transfer(address _recipient, uint256 _numTokens) public override returns(bool) {
        require(_numTokens <= balances[msg.sender]);
        unchecked {
            balances[msg.sender] = balances[msg.sender] - _numTokens;
        }
        balances[_recipient] = balances[_recipient] + _numTokens;
        emit Transfer(msg.sender, _recipient, _numTokens);
        return true;
    }

    function transferFrom(address _owner, address _buyer, uint256 _numTokens) public override returns(bool) {
        require(_numTokens <= balances[_owner]);
        require(_numTokens <= allowed[_owner][msg.sender]);

        unchecked {
           balances[_owner] = balances[_owner] - _numTokens;
           allowed[_owner][msg.sender] = allowed[_owner][msg.sender] - _numTokens;
        }
        balances[_buyer] = balances[_buyer] + _numTokens;
        emit Transfer(_owner, _buyer, _numTokens);
        return true;
    }

}