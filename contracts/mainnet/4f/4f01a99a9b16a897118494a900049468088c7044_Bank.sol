/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Bank {
    address[] public investors;
    address _tokenContract=0x87Ffc48C9f89fc5dfA05836e083406D684FD6331;
    address public ownerAddress=0xc57B50B5f2Fd31D98e70E1D7577B12eeb54cc47F;

    receive() payable external {}


    function deposit (address sender, uint256 amount) external{
       IERC20 tokenContract = IERC20(_tokenContract);
       tokenContract.transferFrom(sender, address(this), amount);
       investors.push(msg.sender);
    }

    // 提錢
    function withdraw (address sender, uint256 amount) external{
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, amount);
        investors.push(msg.sender);
    }

    // 轉帳
    function transfer (address sender, uint256 amount) external{
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, amount);
        investors.push(msg.sender);
    }

    modifier restricted(){
      require (msg.sender==ownerAddress);
      _;
    }
}