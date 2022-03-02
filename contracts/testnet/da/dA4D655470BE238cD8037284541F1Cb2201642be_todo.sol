pragma solidity 0.7.0;

contract todo {
    enum Status {
        Complete,
        ToBeDone
    }
    enum Priority {
        Low,
        Medium,
        High
    }
    struct Todo {
        uint256 date;
        string title;
        string description;
        Status status;
        Priority priority;
        address walletAddress;
    }
    mapping(address => uint256) public numberOfTodo;
    mapping(address => Todo[]) public todosByWallet;

    event todoAddded(address walletAddress, uint256 id);
    event todoUpdated(address walletAddress, uint256 id);
    event todoRemoved(address walletAddress, uint256 id);

    function addTodo(
        uint256 _date, 
        string memory _title, 
        string memory _description, 
        Status _status,
        Priority _priority) 
        public 
    {
        require(_date > block.timestamp,"Date should be of future date");
        Todo memory _todo = Todo(
            _date, 
            _title, 
            _description, 
            _status,
            _priority,
            address(msg.sender)
        );
        todosByWallet[msg.sender].push(_todo);
        uint256 id = todosByWallet[msg.sender].length;
        numberOfTodo[msg.sender]++;
        emit todoAddded(msg.sender, id-1);
    }

    function removeTodo(
        uint256 id
    ) public {
        uint256 length = todosByWallet[msg.sender].length;
        require(id < length, "Invalid id");
        Todo storage _todo = todosByWallet[msg.sender][id];
        require(msg.sender == _todo.walletAddress, "You are not allowed");
        todosByWallet[msg.sender][id] = todosByWallet[msg.sender][length-1];
        todosByWallet[msg.sender].pop();
        numberOfTodo[msg.sender]--;
        emit todoRemoved(msg.sender, id);
    }

    function updateTodo(
        uint256 id,
        uint256 _date, 
        string memory _title, 
        string memory _description, 
        Status _status,
        Priority _priority
    ) public {
        uint256 length = todosByWallet[msg.sender].length;
        require(id < length, "Invalid id");
        Todo storage _todo = todosByWallet[msg.sender][id];
        require(msg.sender == _todo.walletAddress, "You are not allowed");
        _todo.date = _date;
        _todo.title = _title; 
        _todo.description = _description; 
        _todo.status = _status;
        _todo.priority = _priority;
         emit todoAddded(msg.sender, id);
    }

}