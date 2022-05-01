/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

pragma solidity ^0.4.25;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface ChiToken {
    function freeFromUpTo(address from, uint256 value) external;
}




contract DisperseToken {

modifier discountCHI {
  uint256 gasStart = gasleft();

  _;

  uint256 initialGas = 21000 + 16 * msg.data.length;
  uint256 gasSpent = initialGas + gasStart - gasleft();
  uint256 freeUpValue = (gasSpent + 14154) / 41947;

  chi.freeFromUpTo(msg.sender, freeUpValue);
}

    ChiToken constant public chi = ChiToken(0x35759Fd489b17225A57A4d393F22Ab04db17684c);
    
    function disperseEther(address[] recipients, uint256[] values) external payable {
        for (uint256 i = 0; i < recipients.length; i++)
            recipients[i].transfer(values[i]);
        uint256 balance = address(this).balance;
        if (balance > 0)
            msg.sender.transfer(balance);
    }

    function disperseToken(IERC20 token, address[] recipients, uint256[] values) external {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    function disperseTokenSimple(IERC20 token, address[] recipients, uint256 values) external discountCHI {
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transferFrom(msg.sender, recipients[i], values));
    }
}