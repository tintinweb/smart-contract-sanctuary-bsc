// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TodoListOfNhat {

    struct ToDo {
        uint256 _idTodo;
        address owner;
        string _desription;
        bool status;
    }
    mapping(address => uint256) public counterOfAddress;

    mapping( address => ToDo[]) public _listTodoOfAddress;


    event AddTodoItem (ToDo _todo);
    event RemoveTodoItem(ToDo _todo);
    event EditTodoItem(ToDo _todo);

    function addTodoItem (string memory des) external {
        ToDo memory newTodo = ToDo(counterOfAddress[msg.sender], msg.sender, des, false);
        _listTodoOfAddress[msg.sender].push(newTodo);
        counterOfAddress[msg.sender] +=1;
        emit AddTodoItem(newTodo);
    }

    function removeTodoItem( uint256 _index) external {
        require(_index < _listTodoOfAddress[msg.sender].length, "Can not delete when not todo avalable");
        require(_listTodoOfAddress[msg.sender].length > 0, "Can not delete when not todo avalable");
        require(_listTodoOfAddress[msg.sender][_index].owner == msg.sender, "You are not Owner this todolist");
        uint256 indexCorrect = _index;
        delete _listTodoOfAddress[msg.sender][indexCorrect];
        emit RemoveTodoItem(_listTodoOfAddress[msg.sender][indexCorrect]);
    }

    function editTodoItem ( uint256 _index, string memory des, bool status ) external {
        require(_listTodoOfAddress[msg.sender].length > 0, "Can not delete when not todo avalable");
        require(_listTodoOfAddress[msg.sender][_index].owner == msg.sender, "You are not Owner this todolist");
        // require(_listTodoOfAddress[msg.sender][_index] == "", "Item has been delete");

        ToDo storage itemUpdate = _listTodoOfAddress[msg.sender][_index];

        itemUpdate._desription = des;
        itemUpdate.status = status;

        emit EditTodoItem(itemUpdate);
    }

    function getTodoOfAddressById ( uint id) external view returns (ToDo memory){
        return _listTodoOfAddress[msg.sender][id];
    }

    function getListTodoOfAddress () external view returns (ToDo[] memory) {
        return _listTodoOfAddress[msg.sender];
    }

}