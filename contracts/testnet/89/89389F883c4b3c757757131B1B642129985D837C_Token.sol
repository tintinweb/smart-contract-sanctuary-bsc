pragma solidity ^0.8.4;

contract Token {

    //Launched first
    constructor(){
        balances[msg.sender] = totalSupply; //người khởi tạo sẽ có toàn bộ lượng token
    }

    //Variables
    uint public totalSupply = 10000 * 10 ** 18; //Tổng lượng coin mình sẽ phát hành
    string public name = "Test Token";
    string public symbol = "TTK";
    uint public decimals = 18; //Nhưng số sau dấu , mặc định của Ethereum là 18, chuyển sẽ có 18 dấu phẩy ở sau

    // Mappings
    mapping(address => uint) public balances; // Đưa vào 1 địa chỉ => số lượng coin đang có
    mapping(address=> mapping(address => uint)) public allowance;

    //Events
    event Transfer(address indexed from, address indexed to, uint amount); // để tương tác vs bên ngoài (Frontend)
    event Approval(address indexed owner, address indexed spender, uint amount);

    //Function
    function balanceOf(address owner) public view returns(uint){  //view sẽ cho mọi người nhìn thấy
        return balances[owner];
    }

    function transfer(address to, uint amount) public returns (bool){ //đúng thì chuyển, sai thì không chuyển
        require(balanceOf(msg.sender) >= amount, "Balance to low"); //Check số lượng coin chuyển đủ để chuyển không
        balances[to] += amount; // Cộng coin vô địa chỉ người nhận
        balances[msg.sender] -= amount; //Trừ coin ở người gửi
        emit Transfer(msg.sender, to, amount); //add cái sự kiện này
        return true;
    }

    // function transferFrom(address from, address to, uint amount) public returns(){ // khả năng uy quyền để người khác sử dụng 
    //     require(balanceOf(from) >= amount, "Balance to low");
    //     require(allowance[from][msg.sender] >= amount, "Balance to low");
    //     balances[to] += amount;
    //     balances[msg.sender] -=  amount;
    //     emit Transfer(from, to, amount);
    //     return true;
    // }

    function approve(address spender, uint amount)public returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}