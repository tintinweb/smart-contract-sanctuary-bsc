/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**  

    ______      __                    ____ 
   / ____/___ _/ /________  ____     / __ \
  / /_  / __ `/ / ___/ __ \/ __ \   / /_/ /
 / __/ / /_/ / / /__/ /_/ / / / /   \__, / 
/_/    \__,_/_/\___/\____/_/ /_/   /____/  

  ----------------------------------------------------   

__ __| _ \  __ __| |   | ____|   \  |  _ \   _ \   \  | 
   |  |   |    |   |   | __|    |\/ | |   | |   |   \ | 
   |  |   |    |   ___ | |      |   | |   | |   | |\  | 
  _| \___/    _|  _|  _|_____| _|  _|\___/ \___/ _| \_| 

  ----------------------------------------------------

__ __| _ \  __ __| |   | ____|   \  |  _ \   _ \   \  | 
   |  |   |    |   |   | __|    |\/ | |   | |   |   \ | 
   |  |   |    |   ___ | |      |   | |   | |   | |\  | 
  _| \___/    _|  _|  _|_____| _|  _|\___/ \___/ _| \_| 

  ----------------------------------------------------

__ __| _ \  __ __| |   | ____|   \  |  _ \   _ \   \  | 
   |  |   |    |   |   | __|    |\/ | |   | |   |   \ | 
   |  |   |    |   ___ | |      |   | |   | |   | |\  | 
  _| \___/    _|  _|  _|_____| _|  _|\___/ \___/ _| \_| 

  ----------------------------------------------------   
  https://www.falcon9.pro/

**/


interface IF9D {function _holdtotal() external view returns (uint256);function _tOwnedF9(address account) external view returns (uint256);}

contract F9WeightsView {
  string public name = "Falcon9 Dividend Weights (Only View)";
  string public symbol = "F9-Weights";
  uint8 public decimals = 11;

  address public maker;address public f9d;
  event Transfer(address indexed src, address indexed dst, uint256 wad);
  constructor (address a) {
    maker = msg.sender;
    setF9D(a);
    emit Transfer(address(0), maker, 0);
  }
  function setF9D(address a) public{
    require(maker == msg.sender);f9d = a;
  }

  function balanceOf(address account) public view returns (uint256) {
    return IF9D(f9d)._tOwnedF9(account);
  }

  function totalSupply() public view returns (uint256) {
    return IF9D(f9d)._holdtotal();
  }
}