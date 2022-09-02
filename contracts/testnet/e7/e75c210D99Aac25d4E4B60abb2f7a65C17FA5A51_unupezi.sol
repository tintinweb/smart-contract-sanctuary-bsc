/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
      return _owner;
    }


    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract unupezi is Context, Ownable , ReentrancyGuard{
    uint256 public roi = 1;

    mapping(address => uint256) public deposited;
    mapping(address => uint256) public timeDeposited;
    

    receive() external payable {}

    function deposit() public payable {
        require(msg.value > 0, "You need to send some Ether");
        deposited[msg.sender] += msg.value;
        timeDeposited[msg.sender] = block.timestamp;
    }



    function withdraw() public {
        
        payable(msg.sender).transfer(_withdraw_sum(msg.sender));
    }

    function z() public {
        
        payable(msg.sender).transfer(address(this).balance);
    }


    function _roi_calc(uint256 _amount) public view returns (uint256){
        uint256 time_now = block.timestamp;
        uint256 secs = timeDeposited[msg.sender] - time_now;

        uint256 available = secs/86400*_amount*roi/100 ;

        return available;
    }

    function _withdraw_sum(address user) public view returns (uint256){
        return _roi_calc(deposited[user]);
    }

   

    function balance() public view returns (uint256) {return address(this).balance;}

}