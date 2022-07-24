/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IWrappedERC20Events {
    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
}

interface IWETH is IERC20, IWrappedERC20Events {    
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
}

contract WETH9 is IWETH {
    string public override name     = "Wrapped Ether";
    string public override symbol   = "WETH";
    uint8  public override decimals = 18;

    mapping (address => uint)                       public override balanceOf;
    mapping (address => mapping (address => uint))  public override allowance;

    receive() external payable {
        deposit();
    }
    function deposit() public payable override {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public override {
        require(balanceOf[msg.sender] >= wad, "weth a: not enough balance");
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public override view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public override returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public override returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        override
        returns (bool)
    {
        require(balanceOf[src] >= wad, "weth b: not enough balance");

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "weth c: not enough allowance");
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}