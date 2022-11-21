// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;
import "./IERC20.sol";
contract testcalls  {

    address payable public owner;
    IERC20 public busd;
    IERC20 public wbnb;
    address tokenProxy = 0x1231DEB6f5749EF6cE6943a275A1D3E7486F4EaE;
constructor () {
    owner = payable(msg.sender);

    busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //for test
    wbnb = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); //for test

   
    busd.approve(tokenProxy, 100000000000000000000);

  }

    function callDexAgg(bytes memory data) external {
        //address dexAgg = 0x1231DEB6f5749EF6cE6943a275A1D3E7486F4EaE;

        //data = hex"data";

       (bool success,) = tokenProxy.call(data);
    }

    function withdrawToOwner()
    public 
    {
       // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
        busd.transfer(owner, busd.balanceOf(address(this)));
        wbnb.transfer(owner, wbnb.balanceOf(address(this)));
    }
}