/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract arinaChainAirDrop {

    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    modifier notAddress(address _useAdd) {
        require(_useAdd != address(0), "address is error");
        _;
    }

    event Received(address, uint);

    constructor() payable {
        owner = msg.sender;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable{}

    function transferAras(address[] memory _tos, uint _value) 
        payable
        public 
        onlyOwner
        returns (bool) {

        require(_tos.length > 0, "type in to_address");
        require(_value > 0, "type in token amount");
        require(msg.value >= _tos.length * _value, "Ara is not enough");

        for(uint32 i=0;i<_tos.length;i++){
            require(_tos[i] != address(0), "to_address is error");
            payable(_tos[i]).transfer(_value);
        }

        return true;
    }

    // 銷毀合約用
    function destroy() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }

    function transferTokens(address from,address _constractAdd, address[] memory _tos, uint _value)
        payable
        public 
        onlyOwner
        notAddress(from)
        returns (bool) {

        require(from != address(0), "from_address is error");
        require(_tos.length > 0, "type in to_address");
        require(_value > 0, "type in token amount");
        require(address(_constractAdd).balance > _tos.length * _value, "Token is not enough");

        bool status;

        for(uint i=0;i<_tos.length;i++){
            require(_tos[i] != address(0), "to_address is error");

            (status) = IERC20(_constractAdd).transferFrom(from, _tos[i], _value);
            require(status == true, "transferFrom fail");
        }

        return true;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}