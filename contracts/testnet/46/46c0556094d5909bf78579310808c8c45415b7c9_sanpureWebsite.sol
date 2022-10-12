/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;
contract sanpureWebsite {
    struct Pagelist {
        string seoTitle;
    }
    Pagelist[] public pages;


    address public owner = msg.sender;
    address contractAddr = address(this);
    uint public totalPages;
    event UserRegistered(address user);

    constructor() {}    
    function savePage(string memory _seoTitle ) external  returns(bool){
        Pagelist memory new_page = Pagelist(_seoTitle);
        pages.push(new_page);
        totalPages++;
        return true;
    }
    
    /*
    function getPagelist(address user) external view returns ( string memory pages[]) {
        pageData = pages[user];
        return pageData;
    }*/
    function transferOwnership(address to) external {
        require(msg.sender == owner);
        owner = to;
    }
}