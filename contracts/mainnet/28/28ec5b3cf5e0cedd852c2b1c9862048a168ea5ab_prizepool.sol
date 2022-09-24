/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.6;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}




contract prizepool {
    uint256 constant MAX_INT = 2**256 - 1;
   
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    mapping(address => bool) internal auth;

    address payable owner;

    constructor() {
        owner = payable(msg.sender);
        auth[owner] = true;
   
    }

    modifier authorized() {
        require(auth[msg.sender], "!AUTHORIZED");
        _;
    }

    function withdraw() authorized public {
       IERC20(BUSD).transfer(msg.sender,IERC20(BUSD).balanceOf(address(this)));
    }

    function kill() external {
        require(msg.sender == owner);
        selfdestruct(owner);
    }

    function add(address player) public{
        require(msg.sender == owner);
        auth[player] = true;
    }

    receive() external payable {}
}