/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.6.12;

interface IBEP20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function approve(address spender, uint256 amount) external returns(bool);
    function burn(address recipient, uint256 amount) external;
    function mint(address recipient, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    function transferFromController(address sender, address recipient, uint256 amount) external returns(bool);
}

contract AccessControl {
    address public owner;
    mapping(address => bool) whitelistController;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    event ControllerAccessChanged(address indexed _controller, bool indexed _access);

    modifier onlyOwner {
        require(msg.sender == owner, "invalid owner");
        _;
    }
    modifier onlyController {
        require(whitelistController[msg.sender] == true, "invalid controller");
        _;
    }
    function TransferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
    
    function WhitelistController(address _controller) public onlyOwner {
        whitelistController[_controller] = true;
        emit ControllerAccessChanged(_controller, true);
    }
    function BlacklistController(address _controller) public onlyOwner {
        whitelistController[_controller] = false;
        emit ControllerAccessChanged(_controller, false);
    }
    
    function Controller(address _controller) public view returns(bool) {
        return whitelistController[_controller];
    }
}

contract TestToken is IBEP20, AccessControl {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed from, address indexed to, uint256 value);

    string public constant name = "Reward Token";
    string public constant symbol = "ABC";
    uint8 public constant decimals = 18;
    uint256 totalSupply_ = (1000000) * (10**18); //1M initial supply for liquidity pool

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    using SafeMath for uint256;
    
    constructor() public {
        AccessControl.owner = msg.sender;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns(uint256) {
        return totalSupply_;
    }

    function balanceOf(address _owner) public override view returns(uint256) {
        return balances[_owner];
    }

    function transfer(address _receiver, uint256 _amount) public override returns(bool) {
        require(_amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(msg.sender, _receiver, _amount);
        return true;
    }

    function approve(address _delegate, uint256 _amount) public override returns(bool) {
        allowed[msg.sender][_delegate] = _amount;
        emit Approval(msg.sender, _delegate, _amount);
        return true;
    }

    function allowance(address _owner, address _delegate) public override view returns(uint) {
        return allowed[_owner][_delegate];
    }

    function transferFrom(address _from, address _recipient, uint256 _amount) public override returns(bool) {
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_recipient] = balances[_recipient].add(_amount);
        emit Transfer(_from, _recipient, _amount);
        return true;
    }

    function transferFromController(address _owner, address _recipient, uint256 _amount) onlyController external override returns(bool) {
        require(_amount <= balances[_owner]);
        balances[_owner] = balances[_owner].sub(_amount);
        balances[_recipient] = balances[_recipient].add(_amount);
        emit Transfer(_owner, _recipient, _amount);
        return true;
    }

    function mint(address _recipient, uint256 _amount) external override onlyController {
        require(_amount != 0);
        balances[_recipient] = balances[_recipient].add(_amount);
        totalSupply_ = totalSupply_.add(_amount);
        emit Mint(address(0), _recipient, _amount);
    }

    function burn(address _recipient, uint256 _amount) external override onlyController {
        require(_amount != 0);
        require(_amount <= balances[_recipient]);
        totalSupply_ = totalSupply_.sub(_amount);
        balances[_recipient] = balances[_recipient].sub(_amount);
        emit Burn(_recipient, address(0), _amount);
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    receive() external payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns(bool success) {
        return IBEP20(tokenAddress).transfer(owner, tokens);
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}