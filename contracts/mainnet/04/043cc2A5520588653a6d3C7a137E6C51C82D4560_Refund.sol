/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

pragma solidity ^0.8.0;

interface IToken {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract Refund {

    struct RefundStruct {
        address recipient;
        uint256 amount;
    }


    address tokenAddr;
    address owner;

    constructor(address _tokenAddr) {
        tokenAddr = _tokenAddr;
        owner = msg.sender;
    }

    function returnTokens(RefundStruct[] calldata refundStructs) public {

        require(msg.sender == owner);

        uint256 _len = refundStructs.length;
        address _tokenAddr = tokenAddr;
        for (uint256 i = 0; i < _len;) {
            require(
                IToken(_tokenAddr).
                    transfer(refundStructs[i].recipient, refundStructs[i].amount)
            );

            unchecked { ++i; }
        }
    }

    function withdrawTokens() public {

        require(msg.sender == owner);

        uint256 bal = IToken(tokenAddr).balanceOf(address(this));
        IToken(tokenAddr).
                transfer(msg.sender, bal);
    }
}