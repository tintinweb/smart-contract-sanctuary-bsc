pragma solidity ^0.4.24;

import "./Ownable.sol";
contract Distribution is Ownable {

    Token token;

    event TransferredToken(address indexed to, uint256 value);
    event FailedTransfer(address indexed to, uint256 value);

    modifier whenDropIsActive() {
        assert(isActive());
      _;
    }

    constructor () {
        address _tokenAddr = 0xb13b42A0d299fA7bd3f79b6b1e26bC52B521FDAB; 
        token = Token(_tokenAddr);
    }

    function isActive() public view returns (bool) {
        return (tokensAvailable() > 0);
    }

    function Transfer(address[] dests, uint256[] values) external whenDropIsActive onlyOwner {
        uint i = 0;
        while (i < dests.length) {
            uint256 toSend = values[i] * 10**18;
            sendInternally(dests[i], toSend, values[i]);
            i++;
        } 
    } 

    function sendInternally(address recipient, uint256 tokensToSend, uint256 valueToPresent) internal {
        if (recipient == address(0)) return;

        if (tokensAvailable() >= tokensToSend) {
            token.transfer(recipient, tokensToSend);
            emit TransferredToken(recipient, valueToPresent);
        } else {
            emit FailedTransfer(recipient, valueToPresent); 
        }
    }   

    function tokensAvailable() public view returns (uint256) {
        return token.balanceOf(this);
    }

    function destroy() public onlyOwner {
        uint256 balance = tokensAvailable();
        require (balance > 0, "Balance is zero");
        token.transfer(owner, balance);
        selfdestruct(owner);
    }
}