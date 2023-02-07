/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// File: IcoBuyTokenDapp.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address to, uint amount) external;
    function decimals() external view returns(uint);
}
// Switch this to your own contract address once deployed, for bookkeeping!
// Example Contract Address on Goerli: 

contract IcoBuyTokenDapp {
    uint tokenPriceInWei = 0.00000001190476 ether;
    IERC20 token;

    // Event to emit when a Token Purchase Stamp is created.
    event NewIcoStamp(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );
    
    // Memo struct.
    struct IcoStamp {
        address from;
        uint256 timestamp;
        string name;
        string message;
    }
    
    // Address of contract deployer. Marked payable so that
    // we can withdraw to this address later.
    address payable owner;

    // List of all icostamps received from token purchases.
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
     * @dev buy a coffee for owner (sends an ETH tip and leaves a memo)
     * @param _name name of the coffee purchaser
     * @param _message a nice message from the purchaser
     */
    function buyCoins(string memory _name, string memory _message) public payable {
        require(msg.value >= 0.011 ether, "Not enough money sent - ensure balance is at least 0.011");
        uint tokensToTransfer = msg.value / tokenPriceInWei;
        // uint remainder = msg.value - tokensToTransfer * tokenPriceInWei;
        token.transfer(msg.sender, tokensToTransfer * 10 ** token.decimals());
    

        // Add the memo to storage!
        icostamps.push(IcoStamp(
            msg.sender,
            block.timestamp,
            _name,
            _message
        ));

        // Emit a NewMemo event with details about the memo.
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