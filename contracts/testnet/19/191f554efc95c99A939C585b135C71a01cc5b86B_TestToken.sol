/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// File: contracts/TestToken.sol


// contracts/TestToken.sol
pragma solidity >=0.8.4;

contract TestToken {
    mapping(address=>uint256) balance;
    mapping(address=>mapping(address=>uint256)) approval;
    
    function totalSupply() external view returns (uint256) {
        return (100 ether);
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        approval[msg.sender][spender] += amount;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(approval[from][to] >= amount, "Insufficient funds!");
        require(balance[from] >= amount, "Insufficient funds!");
        balance[from] -= amount;
        approval[from][to] -= amount;
        balance[to] += amount;
        return (true);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balance[msg.sender] >= amount, "Insufficient funds!");
        balance[msg.sender] -= amount;
        balance[to] += amount;
        return (true);
    }

    function allowance(address from, address to) external view returns (uint256) {
        return (approval[from][to]);
    }

    function balanceOf(address owner) external view returns (uint256) {
        return (balance[owner]);
    }

    function mint(uint256 amount) public {
        balance[msg.sender] += amount;
    }
}