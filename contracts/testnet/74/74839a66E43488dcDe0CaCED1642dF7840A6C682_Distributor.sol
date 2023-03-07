/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Distributor is Ownable {
    IERC20 distributorToken;

    function matchTransferETH(address[] memory addressList,uint amount) public payable{
        if(addressList.length > 0 ){
            require(msg.value >=  addressList.length  * amount,"Not enough ETH!");
            uint256 value = msg.value;
            for(uint i = 0;i<addressList.length;i++){
                payable(addressList[i]).transfer(amount);
                value = value - amount;
            }
            if(value>0){
                payable(msg.sender).transfer(value);
            }
        }
    }

    function matchTransferToken(address tokenAddress,address[] memory addressList,uint[] memory amountList) public{
        if(addressList.length > 0 ){
            IERC20 token = IERC20(tokenAddress);
            uint256 needAmount;
            for(uint j=0;j<amountList.length;j++){
                needAmount = needAmount + amountList[j];
            }
            uint256 allowanceBalance = token.allowance(msg.sender,address(this));
            uint256 mainBalance = token.balanceOf(msg.sender);

            require(allowanceBalance >= needAmount,"Not enough allowanceBalance!");
            require(mainBalance >= needAmount,"Not enough mainBalance!");
            
            for(uint i = 0;i<addressList.length;i++){
                token.transferFrom(msg.sender,addressList[i],amountList[i]);
            }
        }
    }


    receive() external payable{
        payable(msg.sender).transfer(msg.value);
    }
}