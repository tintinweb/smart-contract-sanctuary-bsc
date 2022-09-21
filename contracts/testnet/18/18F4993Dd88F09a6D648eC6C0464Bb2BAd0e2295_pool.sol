/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    // function transfer(address _to, uint256 _value) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract pool {

    address OWNER = 0x075D29D70FF3d5AD1a2569bba6F581CBf2be7Cee; //Aqui va la address owner
    address payable OWNERpay;
    IERC20 usdt = IERC20(address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd));  //USDT in BSC

    struct Users {
        string nickName;
        uint amount;
        address payable addressUser;
    }

    Users[] public userArray;

    //Función para pushear datos del usuario
    function createUsers(string memory _nickName, uint _amount, address payable _addressUser) public {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        userArray.push(Users(_nickName, _amount, _addressUser));
    }

    //Eliminar a un usuario
    function removeUser(uint _index) public {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        userArray[_index] = userArray[userArray.length - 1];
        userArray.pop();
    }

    //Obtener cantidad de elementos de un Array
    function getNumberOfUsers() external view returns(uint) {
        return userArray.length;
    }
    
    //Obtener datos del usuario según su indice en el array
    function getUsers(uint _index) external view returns(string memory nickName, uint amount, address addressUser) {
        nickName = userArray[_index].nickName;
        amount = userArray[_index].amount;
        addressUser = userArray[_index].addressUser;
    }

    //Modificar datos del array
    function modifyDataUsers(uint _index, string memory _nickName, uint _amount, address _addressUser) public {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        userArray[_index].nickName = _nickName;
        userArray[_index].amount = _amount;
        userArray[_index].addressUser = payable (_addressUser);
    }

    //Obtener el balance del contrato
    function getContractBalance() public view returns (uint) {
        return usdt.balanceOf(address(this));
    }

    function approveUsdt(address _spender, uint256 _amount) public {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        usdt.approve(_spender, _amount);
    }

    //Retiro de dinero
    function withdrawAll(uint _index ,uint _withdrawalAmount) external {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        address payable to = userArray[_index].addressUser;
        uint royaltyAmount = _withdrawalAmount / 100 * 2;   //setear porcentaje de comision
        _withdrawalAmount = _withdrawalAmount - royaltyAmount;

        //royalty
        OWNERpay = payable (msg.sender);
        usdt.transferFrom(address(this), OWNERpay, royaltyAmount);

        usdt.transferFrom(address(this), to, _withdrawalAmount);
    }

}