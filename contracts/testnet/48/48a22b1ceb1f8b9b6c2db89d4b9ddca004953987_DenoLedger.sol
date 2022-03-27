// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./DenoTracker.sol";

contract DenoLedger is Context, Ownable {
    using SafeMath for uint256;
    using ConvertString for uint256;
    using Address for address;

    string private _name;
    string private _symbol;

    mapping(address => uint256) private _balances;
    mapping(uint256 => address) public _trackerMap;
    address[] public _trackerList;

    address private _tokenAddress;
    address private _adminAddress;

    modifier authSender() {
        require((owner() == _msgSender() || _tokenAddress == _msgSender()), "Ownable: caller is not the owner");
        _;
    }

    constructor(string memory name_, string memory symbol_){
        _name = string(abi.encodePacked("DenoLedger", name_));
        _symbol = string(abi.encodePacked("DL", symbol_));
        _tokenAddress = address(this);
    }

    receive() external payable {}

    /* Start of show properties */
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function totalSupply() public view returns (uint256) {
        return _trackerList.length;
    }
    function getTrackerAddress(uint256 code_) public view returns (address) {
        return _trackerMap[code_];
    }
    function getTrackerBalance(address address_, address account_) public view returns (uint256) {
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.getAccountBalance(account_);
    }
    function getTrackerSupply(address address_) public view returns (uint256) {
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.totalSupply();
    }
    function getTrackerFieldString(address address_, string memory key_) public view returns (string memory) {
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.getFieldString(key_);
    }
    function getTrackerFieldNumber(address address_, string memory key_) public view returns (uint256) {
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.getFieldNumber(key_);
    }
    function getTrackerFieldAddress(address address_, string memory key_) public view returns (address) {
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.getFieldAddress(key_);
    }
    function setTrackerFieldString(address address_, string memory key_, string memory value_) public authSender {
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.setFieldString(key_, value_);
    }
    function setTrackerFieldNumber(address address_, string memory key_, uint256 value_) public authSender {
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.setFieldNumber(key_, value_);
    }
    function setTrackerFieldAddress(address address_, string memory key_, address value_) public authSender {
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.setFieldAddress(key_, value_);
    }
    function increaseBalance(address address_, address account_, uint256 balance_) public authSender returns (uint256){
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.increaseBalance(account_, balance_);
    }
    function decreaseBalance(address address_, address account_, uint256 balance_) public authSender returns (uint256){
        DenoTracker tracker = DenoTracker(payable(address_));
        return tracker.decreaseBalance(account_, balance_);
    }
    function addTracker(uint256 code_) public authSender returns (address){
        string memory codeString = ConvertString.toStr(code_);
        DenoTracker tracker = new DenoTracker(codeString, codeString, _tokenAddress);
        address address_ = address(tracker);
        _trackerMap[code_] = address_;
        _trackerList.push(address_);
        return address_;
    }
    function listTracker(uint limit_, uint page_) public view returns (address[] memory) {
        uint listCount = _trackerList.length;

        uint rowStart = 0;
        uint rowEnd = 0;
        uint rowCount = listCount;
        bool pagination = false;

        if (limit_ > 0 && page_ > 0){
            rowStart = (page_ - 1) * limit_;
            rowEnd = (rowStart + limit_) - 1;
            pagination = true;
            rowCount = limit_;
        }

        address[] memory _trackers = new address[](rowCount);

        uint id = 0;
        uint j = 0;

        if (listCount > 0){
            for (uint i = 0; i < listCount; i++) {
                bool insert = !pagination;
                if (pagination){
                    if (j >= rowStart && j <= rowEnd){
                        insert = true;
                    }
                }
                if (insert){
                    _trackers[id] = _trackerList[i];
                    id++;
                }
                j++;
            }
        }

        return (_trackers);
    }
    function listTrx(uint256 code_, address account_) public view returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        DenoTracker tracker = DenoTracker(payable(getTrackerAddress(code_)));
        return tracker.listTrx(account_);
    }
    function trxCount(uint256 code_, address account_) public view returns (uint256) {
        DenoTracker tracker = DenoTracker(payable(getTrackerAddress(code_)));
        return tracker.trxCount(account_);
    }
    function setTokenAddress(address address_) public authSender {
        _tokenAddress = address_;
        if (_trackerList.length > 0){
            for (uint i = 0; i < _trackerList.length; i++) {
                address _trackers = _trackerList[i];
                DenoTracker tracker = DenoTracker(payable(_trackers));
                tracker.setTokenAddress(_tokenAddress);
            }
        }
    }
    function getAdminAddress() public view returns (address) {
        return _adminAddress;
    }
    function setAdminAddress(address address_) public authSender {
        _adminAddress = address_;
    }
    function withdraw(address address_) public authSender {
        address account_ = address(this);
        uint256 amount_ = IERC20(address_).balanceOf(account_);
        require(amount_ >= 0, "ERC20: insufficient balance");
        IERC20(address_).transfer(_adminAddress, amount_);
    }
}