/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract Token {

    mapping(address => uint) public balances;
    // hàm mapping thực hiện nhiệm vụ thay mặt cho cho sở hữu chi tiêu, hàm này trả về số lượng token được phép chi tiêu
    mapping(address => mapping(address => uint)) public allowance;

    uint public totalSupply = 1000 * 10 ** 18;
    string public name = "My Token Test";
    string public symbol = "MTT";
    uint public decimal = 18; // số lượng decimal number đứng sau

    // Event trong ERC20
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    // pass address mà bạn muốn query
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    // chuyển token

    function transfer(address to, uint amount) public returns (bool) {
        require(balanceOf(msg.sender) > amount, "balances too low");
        balances[to] += amount;
        balances[msg.sender] -= amount;

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    // cấp phép lượng token cho người khác chi tiêu từ msg.sender
    // hàm này trả về bool (được phép hay là không)

    function approve(address spender, uint amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // function cho phép chuyển giao token từ người này sang người khác

    function transferFrom(address from, address to, uint amount) public returns(bool) {
        // Đầu tiên phải require số lượng token của from > amount
        require(balanceOf(from) >= amount);

        // Tiếp theo phải require kiểm tra xem người gửi giao dịch này có phải là người chi tiêu được chấp thuận cho địa chỉ gửi
        allowance[from][msg.sender] >= amount;

        balances[to] += amount;
        balances[from] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }
}