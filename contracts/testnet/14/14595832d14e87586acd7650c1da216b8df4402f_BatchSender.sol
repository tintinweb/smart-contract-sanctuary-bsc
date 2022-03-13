/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IBEP20Transfer {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract BatchSender {
    address public thisToken = address(0);

    address private _owner;
    bool private _isEntered;

    event Transfer(address indexed to, uint256 amount);
    event NewOwner(address indexed newOwner);

    constructor() public {
        _owner = msg.sender;
        emit NewOwner(msg.sender);
    }

    receive() external payable {
        revert("no ethers accepted");
    }

    function batchTransfer(address[] calldata receivers, uint[] calldata amounts)
    external onlyOwner returns (bool)
    {
        require(receivers.length == amounts.length, "invalid input arrays");

        for (uint i = 0; i < receivers.length; i++) {
            address to = receivers[i];
            uint amount = amounts[i];
            require(to != address(0), "receiver is zero address");
            require(amount != 0, "amount is zero");

            require(_transferToken(to, amount), "failed to transfer");
            emit Transfer(to, amount);
        }

        return true;
    }

    /// @dev Sends occasional airdrop tokens to the owner
    function collect(IBEP20Transfer token, uint amount) external {
        require(_isEntered == false, "already entered");
        _isEntered = true;
        token.transfer(_owner, amount);
        _isEntered = false;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner is zero address");
        emit NewOwner(newOwner);
        _owner = newOwner;
    }

    function token() public view returns (address) {
        return thisToken;
    }

    // Moved to a separate function for unit-tests facilitation
    function _transferToken(address to, uint amount) internal virtual returns (bool) {
        return IBEP20Transfer(thisToken).transfer(to, amount);
    }

    function changeTokenAddress(address _thisToken) public onlyOwner{
        thisToken = _thisToken;
    }
}