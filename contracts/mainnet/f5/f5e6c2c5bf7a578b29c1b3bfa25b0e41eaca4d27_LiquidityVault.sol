/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

pragma solidity 0.5.8;

/**
 *
 * https://moonshots.farm
 * 
 * Want to own the next 1000x SHIB/DOGE/HEX token? Farm a new/trending moonshot every other day, automagically!
 *
 */

contract LiquidityVault {

    address blobby = msg.sender;
    uint256 public unlockEpoch = now + 12 weeks;    

    function removeToken(address token, address recipient, uint256 amount) external {
        require(msg.sender == blobby);

        require(now > unlockEpoch); // Cant remove until 12 weeks
        ERC20(token).transfer(recipient, amount);
    }
    
}





interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}