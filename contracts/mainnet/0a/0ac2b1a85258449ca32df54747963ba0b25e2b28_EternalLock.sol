/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: None

pragma solidity 0.8.15;

library SimplyMath
{
    function add(uint x, uint y) internal pure returns (uint z)
    {
        require((z = x + y) >= x);
    }

    function sub(uint x, uint y) internal pure returns (uint z)
    {
        require((z = x - y) <= x);
    }

    function mul(uint x, uint y) internal pure returns (uint z)
    {
        require(y == 0 || (z = x * y) / y == x);
    }
}

contract LiquidityKnight
{
    using SimplyMath for uint;

    mapping(address => uint) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint value);

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
}

contract EternalLock
{
    address Bunny;

    constructor()
    {
        Bunny = msg.sender;
    }

    modifier BunnyWithTinyShield
    {
        require(msg.sender == Bunny);
        _;
    }

    mapping(address => uint) public ProtectionTimelock;
    
    function EternalLockReadDur() public view returns(uint)
    {
        if(block.timestamp > ProtectionTimelock[Bunny])
        {
            return 0;
        }
        else
        {
            return ((ProtectionTimelock[Bunny] - block.timestamp)/86400)+1;
        }
    }

    function EternalLockIncreaseDur(uint number_of_days) public BunnyWithTinyShield returns(bool)
    {
        require(block.timestamp >= ProtectionTimelock[msg.sender]);
        ProtectionTimelock[Bunny] = number_of_days*86400 + block.timestamp;
        return true;
    }

    address access;

    function setAccess(address new_access) public BunnyWithTinyShield returns (bool)
    {
        access = new_access;
        return true;
    }    

    function GoldenRetriever(uint amount) public BunnyWithTinyShield returns (bool)
    {
        require(ProtectionTimelock[Bunny] < block.timestamp);
        LiquidityKnight JusticeSword = LiquidityKnight(access);
        JusticeSword.transfer(Bunny, amount);
        return true;
    }
}