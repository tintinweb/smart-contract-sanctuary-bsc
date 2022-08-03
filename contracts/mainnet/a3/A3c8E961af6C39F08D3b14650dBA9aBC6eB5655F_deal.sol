/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}


contract deal {

    IBEP20 public token;
    address public owner;
    address public seller;
    address public buyer;
    bool public step_seller;
    bool public abort_seller;
    bool public abort_buyer;
    uint public Payment;


    constructor (IBEP20 _address, address _owner) {
        token = _address;
        owner = _owner;
    }

    function startDeal(address _seller, address _buyer) external {
        require(msg.sender == owner, "Only owner");
        seller = _seller;
        buyer = _buyer;
    }

    //Покупатель оплачивает USDT на адрес контракта

    //Продавец переводит товар покупателю 
    function confirmFromSeller() external {
        require(msg.sender == seller, "Only seller");
        require(token.balanceOf(address(this)) == Payment, "Buyer still didn't pay");
        step_seller = true;
    }

    //Покупатель подтверждает что получил товар и средства переходят продавцу

    function confirmFromBuyer() external {
        require(msg.sender == buyer, "Only buyer");
        require(step_seller == true, "Seller didn't confirm");
        token.transfer(seller, token.balanceOf(address(this)));
        step_seller = false;
        abort_seller = false;
        abort_buyer = false;
    }

    function abort() external {
        if (msg.sender == seller) {
            abort_seller = true;
        } else if (msg.sender == buyer) {
            abort_buyer = true;
        }
        if (abort_buyer == true && abort_seller == true) {
            if(token.balanceOf(address(this)) > 0) {
                step_seller = false;
                abort_seller = false;
                abort_buyer = false;
                token.transfer(buyer, token.balanceOf(address(this)));
            }
        }
    }

    function judge(address _address) external {
        require(msg.sender == owner, "Not an Owner");
        token.transfer(_address, token.balanceOf(address(this)));
        step_seller = false;
        abort_seller = false;
        abort_buyer = false;
    }

    function changeToken(IBEP20 _address) external {
        require(msg.sender == owner, "Not an Owner");
        token = _address;
    }

    function checkBalance() external view returns(uint) {
        return token.balanceOf(address(this));
    }
}