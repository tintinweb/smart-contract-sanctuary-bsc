/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

pragma solidity ^0.4.18;

contract FakeWETH {
    string public name     = "Fake Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    uint256 public totalSupply;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() public payable {
        
    }

    // Mint 10 'Fake WETH' to caller
    function deposit() public {
        balanceOf[msg.sender] += 10000000000000000000;
        totalSupply += 10000000000000000000;

        Deposit(msg.sender, 10000000000000000000);
    }

    // Withdraw 'Fake WETH' - does nothing, gives nothing
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        
        balanceOf[msg.sender] -= wad;
        totalSupply -= wad;

        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return totalSupply;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        Transfer(src, dst, wad);

        return true;
    }
}