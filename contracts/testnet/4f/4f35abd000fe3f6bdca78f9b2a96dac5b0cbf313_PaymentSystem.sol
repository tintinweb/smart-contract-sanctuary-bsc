/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

pragma solidity ^0.4.18;
//version:4

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract PaymentSystem is Ownable {

    struct order {
        address payer;
        uint256 value;
        bool revert;
    }

    //база ордеров
    mapping(uint256 => order) public orders;

    //возврат денег при попытке отправить деньги на контракт
    function () public payable {
        revert();
    }

    event PaymentOrder(uint256 indexed id, address payer, uint256 value);

    //оплата ордера
    function paymentOrder(uint256 _id) public payable returns(bool) {
        require(orders[_id].value==0 && msg.value>0);

        orders[_id].payer=msg.sender;
        orders[_id].value=msg.value;
        orders[_id].revert=false;

        //создать евент
        PaymentOrder(_id, msg.sender, msg.value);

        return true;
    }

    event RevertOrder(uint256 indexed id, address payer, uint256 value);

    //возврат платежа администратором
    function revertOrder(uint256 _id) public onlyOwner returns(bool)  {
        require(orders[_id].value>0 && orders[_id].revert==false);

        orders[_id].revert=true;
        orders[_id].payer.transfer(orders[_id].value);

        RevertOrder(_id, orders[_id].payer, orders[_id].value);

        return true;
    }

    //вывод денег администратором
    function outputMoney(address _from, uint256 _value) public onlyOwner returns(bool) {
        require(this.balance>=_value);

        _from.transfer(_value);

        return true;
    }

}