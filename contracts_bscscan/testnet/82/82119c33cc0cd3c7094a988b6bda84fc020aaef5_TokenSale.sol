/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
        Este contrato es para hacer una IDO. Una vez que finalice laIDO hacemos un endSold para devolver 
        los tokens sobrantes al contrato principal.
        Este contrato nos puede valer para los nft o preventa
*/
interface MyCoin {
    function decimals() external view returns(uint8);
    function balanceOf(address _address) external view returns(uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract TokenSale {
    address owner;
    uint256 price;
    MyCoin myTokenContract;
    uint256 tokenSold;

    event Sold(address _buyer, uint256 _amount);

    constructor(uint256 _price, address _addressContract) {
        owner = msg.sender;
        price = _price;
        myTokenContract = MyCoin(_addressContract);
    }

    //  Para evitar problemas de seguridad utilizamos esta funcion para multiplicar
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0) return 0;

        uint256 c = a * b;
        require(c / a == b);
        
        return c;
    }

    function buy(uint256 _numTokens) public payable {
        require(msg.value == mul(price, _numTokens));
        uint256 scaledAmount = mul(_numTokens, uint256(10) ** myTokenContract.decimals());
        require(myTokenContract.balanceOf(address(this)) >= scaledAmount);
        tokenSold += _numTokens;
        require(myTokenContract.transfer(msg.sender, scaledAmount));

        emit Sold(msg.sender, _numTokens);
    }

    function endSold() public {
        require(msg.sender == owner);
        require(myTokenContract.transfer(owner, myTokenContract.balanceOf(address(this))));
        payable(msg.sender).transfer(address(this).balance);
    }
}