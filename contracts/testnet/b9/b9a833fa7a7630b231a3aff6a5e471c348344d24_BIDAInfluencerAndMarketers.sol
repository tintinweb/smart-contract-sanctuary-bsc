/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract BIDAInfluencerAndMarketers {
    
    IERC20 public immutable BIDA;
    address public owner;
    
    mapping(address => bool) public admin;
    event distribute(address indexed addr, uint256 _amount);
    
    constructor (address bida) {
        BIDA = IERC20(bida);
        owner = msg.sender;
        admin[msg.sender] = true;
    }
    
    function addAdmin(address[] memory _admAddr) public {
        require(msg.sender == owner, "Only Owner can call this function");
        for (uint256 i; i < _admAddr.length;) {
            address _admin = _admAddr[i];
            admin[_admin] = true;
            unchecked {
                i++;
            }
        }
    }
    
    function transfer_To_Multi_Wallet(address[] memory investors, uint256[] memory amounts) public {
        require(investors.length == amounts.length, "incomplete length in value");
        require(admin[msg.sender], "Caller is not an admin");
        
        for (uint256 i; i < investors.length; ) {
            address wallet = investors[i];
            uint256 amount = amounts[i];
            BIDA.transferFrom(owner, wallet, amount);
            emit distribute(wallet, amount);
            unchecked {
                i++;
            }
        }
    }
}