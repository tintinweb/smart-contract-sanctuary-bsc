/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// File: PoiyaltyIcoDapp.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address to, uint amount) external;
    function decimals() external view returns(uint);
}
// 
// Contract Address:

contract PoiyaltyIcoDapp {
    uint tokenPriceInWei = 0.00000001190476 ether;
    IERC20 token;

    // Event to emit when a POICO IcoStamp is created.
    event NewIcoStamp(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );
    
    // IcoStamp struct.
    struct IcoStamp {
        address from;
        uint256 timestamp;
        string name;
        string message;
    }
    
    // Address of contract deployer. Marked payable so that
    // we can withdraw to this address later.
    address payable owner;

    // List of all icostamps received from POICO purchases.
    IcoStamp[] icostamps;

    constructor(address _token) {
        token = IERC20(_token);
        // Store the address of the deployer as a payable address.
        // When we withdraw funds, we'll withdraw here.
        owner = payable(msg.sender);
    }

    /**
     * @dev fetches all stored icostamps
     */
    function getIcoStamps() public view returns (IcoStamp[] memory) {
        return icostamps;
    }

    /**
     * @dev buy POICO tokens (sends an BNB tip and leaves a icostamp)
     * @param _name name of the POICO purchaser
     * @param _message a nice message from the POICO purchaser
     */
    function buyCoins(string memory _name, string memory _message) public payable {
        require(msg.value >= 0.011 ether, "Not enough money sent - ensure balance is at least 0.011");
        uint tokensToTransfer = msg.value / tokenPriceInWei;
        // uint remainder = msg.value - tokensToTransfer * tokenPriceInWei;
        token.transfer(msg.sender, tokensToTransfer * 10 ** token.decimals());
    

        // Add the icostamps to storage!
        icostamps.push(IcoStamp(
            msg.sender,
            block.timestamp,
            _name,
            _message
        ));

        // Emit a NewIcoStamp event with details about the icostamp.
        emit NewIcoStamp(
            msg.sender,
            block.timestamp,
            _name,
            _message
        );
    }

    /**
     * @dev send the entire balance stored in this contract to the owner
     */
    function withdrawContributions() public {
        require(owner.send(address(this).balance));
    }
}