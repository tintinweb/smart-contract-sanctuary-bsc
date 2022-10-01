/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract MultiSender {

    event Send(address indexed sender, bytes transactions);
    event UpdateWhitelist(address indexed sender, address indexed addr, bool indexed permit);

    address public owner;
    mapping(address => bool) public whitelist;

    constructor(address owner_) {
        owner = owner_;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Call restricted to owner only");
        _;
    }

    function updateWhitelist(address addr, bool permit) public isOwner {
        whitelist[addr] = permit;
        emit UpdateWhitelist(msg.sender, addr, permit);
    }

    /// Primary Capabilities: Transfer ETH/Token to multiple addresses
    /// @dev Sends multiple transactions and ends to execute if certain one fails. Surplus will be refunded to sender.
    /// @param transactions Encoded transactions. Each transaction is encoded as a packed bytes of
    ///                     operation as a uint8 with 1 for a call (or 2 for future use) (=> 1 byte),
    ///                     to as a address (=> 20 bytes),
    ///                     value as a uint256 (=> 32 bytes),
    ///                     data length as a uint256 (=> 32 bytes),
    ///                     data as bytes.
    ///                     see abi.encodePacked for more information on packed encoding
    function send(bytes memory transactions) external payable {
        require(whitelist[msg.sender], "Call restricted to whitelist member only");
        assembly {
            let length := mload(transactions)
            let i := 0x20
            for {} lt(i, length) {} {
                let operation := shr(0xf8, mload(add(transactions, i)))
                let to := shr(0x60, mload(add(transactions, add(i, 0x01))))
                let value := mload(add(transactions, add(i, 0x15)))
                let dataLength := mload(add(transactions, add(i, 0x35)))
                let data := add(transactions, add(i, 0x55))
                if eq(operation, 1) {
                    if eq(call(gas(), to, value, data, dataLength, 0, 0), 0) {
                        break
                    }
                }
                i := add(i, add(0x55, dataLength))
            }
        }
        emit Send(msg.sender, transactions);
    }

}