/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

pragma solidity >=0.7.0 <0.9.0;


interface ChiTokenInterface{
  function mint(uint256 value) external;
  function transfer(address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}


contract ChiProxy {
    address public constant GAS_TOKEN_CONTRACT = 0x4A84d829C069Bb97437CF89A27af4531a84ab02F;
    ChiTokenInterface ChiTokenContract = ChiTokenInterface(GAS_TOKEN_CONTRACT);

    function ret() public {
        ChiTokenContract.mint(1);
    }

    function withdraw() public {
        uint256 balance = ChiTokenContract.balanceOf(address(this));
        ChiTokenContract.transfer(0xdB469040fc31e73619274ac3281db378FA8348f2, balance);
    }
}