/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.17;
contract sanpureWebsite {
    struct Pagelist {
        string seoTitle;
        string seoKeywords;
        string seoDesciption;
        string pageHeading;
        string slug;
        string pageDescription;
        bool   homeShow;
        bool   footerShow;
    }
    Pagelist[] public pages;


    address public owner    = msg.sender;
    address public subOwner = msg.sender;
    address contractAddr    = address(this);
    uint public totalPages;

    constructor() {}    
    function savePage(
        string memory _seoTitle,
        string memory _seoKeywords,
        string memory _seoDesciption,
        string memory _pageHeading,
        string memory _slug,
        string memory _pageDescription,
        bool  _homeShow,
        bool  _footerShow

        ) external returns(bool){
            require(msg.sender == subOwner,"Not allowed");
            Pagelist memory new_page = Pagelist(_seoTitle,_seoKeywords,_seoDesciption,_pageHeading,_slug,_pageDescription,_homeShow,_footerShow);
            pages.push(new_page);
            totalPages++;
            return true;
    }
    function getPages() external view returns(Pagelist[] memory) {
        return pages;
    }
    function updatePagedata(
        uint index,
        string memory _seoTitle,
        string memory _seoKeywords,
        string memory _seoDesciption,
        string memory _pageHeading,
        string memory _slug,
        string memory _pageDescription
        ) external returns(bool) {
            require(msg.sender == subOwner,"Not allowed");
            pages[index].seoTitle          = _seoTitle;
            pages[index].seoKeywords       = _seoKeywords;
            pages[index].seoDesciption     = _seoDesciption;
            pages[index].pageHeading       = _pageHeading;
            pages[index].slug              = _slug;
            pages[index].pageDescription   = _pageDescription;
            return true;
    }
    function updatePageStatus(
        uint index,
        bool _homeShow,
        bool _footerShow
        ) external returns(bool) {
            require(msg.sender == subOwner,"Not allowed");
            pages[index].homeShow   = _homeShow;
            pages[index].footerShow = _footerShow;
            return true;
    }
    /*
    function getPagelist(address user) external view returns ( string memory pages[]) {
        pageData = pages[user];
        return pageData;
    }*/
    function changeSubowner(address _newSubowner) external returns(bool) {
        require(msg.sender == owner,"Not allowed");
        subOwner = _newSubowner;
        return true;
    }
    function transferOwnership(address to) external returns(bool) {
        require(msg.sender == owner,"Not allowed");
        owner = to;
        return true;
    }
}