/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.5 <0.8.11;

contract Address {
    // مقدار پیش فرض تایپ ادرس، ادرس صفر است
    // payable : ادرسی که می توان برای آن مبلغ ارسال کرد
    address public ownerAdd;
    address public contractAdd;
    address public secondAdd = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address payable public zeroAdd = payable(address(0)); // 0x0000000000000000000000000000000000000000

    // هر آدرسی در بلاکچین میتواند موجودی داشته باشد
    // wei --- 1 Eth = 10^18 wei = 1000000000000000000 wei
    // 9 Eth = 9 * 10^18 wei
    uint256 private someBalance;

    constructor() payable {  // constructor() payable {
        ownerAdd = msg.sender; // ادرس دپلوی کننده کانترکت
        contractAdd = address(this); // آدرس کانترکت
    }

    function getContractBalance() public view returns(uint256) {
        return contractAdd.balance;  // موجودی کانترکت - wei
    }

    function getOwnerBalance() public view returns(uint256) {
        return ownerAdd.balance;  // موجودی مالک - wei
    }

    function payToContract() payable public {
        someBalance += msg.value;  //  someBalance = someBalance + msg.value;
    }

    function getBalance_Eth() public view returns(uint256) {
        return someBalance / 10**18;  // 1 Eth = 10^18 wei
    }

    // برای فراخوانی یا اجرای این تابع شرط قرار دادیم
    // فقط مالک کانترکت قادر به اجرای این تابع است
    function destructContract() public {
        if(msg.sender == ownerAdd) {
            selfdestruct(payable(ownerAdd));  // کانترکت را از بین میبرد و موجودی کانترکت را به حساب داده شده ارسال میکند
        }
    }
}

/*
    -------------------
        متغیرهای عددی در سالیدیتی
    -------------------
    اعداد علامت دار - signed
    int8 - int16 - int32 - int64 - int128 - int256
    int ~ int256
    int8 : [0 , 2^8 - 1] ~ [0 , 255]

    اعداد بدون علامت - unsigned
    uint8 - uint16 - uint32 - uint64 - uint128 - uint256
    uint ~ uint256 : [0 , 2^256-1]
*/

/*
    if(شرط) {
        // اگر شرط برقرار بود
        // TODO 1
    }
    else {
        // اگر شرط برقرار نبود
        // TODO 2
    }

    شرط
    مساوی :    a == b
    نامساوی :   a != b
    بزرگتر یا مساوی  :   a >= b
    کوچکتر یا مساوی  :   a <= b

    ترکیب شرط ها
        دو شرط با هم درست باشند  :   (cond1 && cond2 ... )
        یکی از شرط های برقرار باشد : (cond1 || cond2 ... )
*/