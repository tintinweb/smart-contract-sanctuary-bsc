/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: GPL-3.0

// Khai báo version Solidity cần sử dụng
pragma solidity >=0.7.0 < 0.9.0;

/* 
Tạo contract có tên: firstContract
Contract Name: firstContract
public: sẽ hiển thị với người dùng ở Read Contract & Write Contract
*/
contract firstContract {
    /*
    Khởi tạo Biến: myStr
    Kiễu dữ liệu: string
    Trạng thái: public (Read Contract)
    Giá trị mặc định: myStr = ""
    */
    string public myStr;

    /*
    Khởi tạo biến: myUint
    Kiễu dữ liệu: uint
    Trạng thái: public (Read Contract)
    Giá trị mặc định: myUint = 0
    */
    uint public myUint;
    /*
    Khởi tạo hàm: setUint
    Kiểu dữ liệu: function (mặc định)
    Trạng thái: public (Write Contract)
    */
    function setUint(uint _myUint) public {
        myUint = _myUint;
    }

        /*
    Khởi tạo biến: myBool
    Kiễu dữ liệu: bool
    Trạng thái: public (Read Contract)
    Giá trị mặc định: myBool = false
    */
    bool public myBool;
    /*
    Khởi tạo hàm: setBool
    Kiểu dữ liệu: function (mặc định)
    Trạng thái: public (Write Contract)
    */
    function setBool(bool _myBool) public {
        myBool = _myBool;
    }

    // Phủ định hàm setBool
    function negativeSetBool() public {
        myBool = !myBool;
    }

    /*
    Nếu không muốn public biến myBool trực tiếp
    Khởi tạo hàm: reStore
    Trạng thái: public view returns
    Đọc kiểu dữ liệu: bool của biến myBool
    */
    function reStore() public view returns (bool) {
        return myBool;
    }
}