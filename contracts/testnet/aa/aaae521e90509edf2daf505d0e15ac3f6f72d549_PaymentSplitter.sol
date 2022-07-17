/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//SPDX-License-Identifier: MIT

/* This contract will distribute the payment to 4 Investor's wallet equally. 2% of the main wallet*/
pragma solidity 0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PaymentSplitter is Ownable {
    event Received(address from, uint256 amount);
    event Withdraw(address to, uint256 amount);

    error PaymentFailed();
    error WrongShares();
    error WrongAddress();
    error NoBalance();
    error NotValidSender();

    struct Addresses {
        address addr1;
        address addr2;
        address addr3;
        address addr4;
    }

    Addresses public addrs;

    uint256 public share1;
    uint256 public share2;
    uint256 public share3;
    uint256 public share4;

    constructor(
        address addr1_,
        address addr2_,
        address addr3_,
        address addr4_,
        uint256 share1_,
        uint256 share2_,
        uint256 share3_,
        uint256 share4_
    ) {
        if (addr1_ == address(0) || addr2_ == address(0) || addr3_ == address(0) || addr4_ == address(0)) revert WrongAddress();
        if (share1_ + share2_ + share3_ + share4_ != 100) revert WrongShares();
        if (share1_ == 0 || share2_ == 0 || share3_ == 0 || share4_ == 0) revert WrongShares();

        addrs.addr1 = addr1_;
        addrs.addr2 = addr2_;
        addrs.addr3 = addr3_;
        addrs.addr4 = addr4_;
        share1 = share1_;
        share2 = share2_;
        share3 = share3_;
        share4 = share4_;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        if (balance == 0) revert NoBalance();

        address addr1 = addrs.addr1;
        address addr2 = addrs.addr2;
        address addr3 = addrs.addr3;
        address addr4 = addrs.addr4;

        uint256 addr1Amount = (balance * share1) / 100;
        uint256 addr2Amount = (balance * share2) / 100;
        uint256 addr3Amount = (balance * share3) / 100;
        uint256 addr4Amount = (balance * share4) / 100;

        (bool success1, ) = addr1.call{value: addr1Amount}("");
        (bool success2, ) = addr2.call{value: addr2Amount}("");
        (bool success3, ) = addr3.call{value: addr3Amount}("");
        (bool success4, ) = addr4.call{value: addr4Amount}("");

        if (!success1 || !success2 || !success3 || !success4) revert PaymentFailed();

        emit Withdraw(addr1, addr1Amount);
        emit Withdraw(addr2, addr2Amount);
        emit Withdraw(addr3, addr3Amount);
        emit Withdraw(addr4, addr4Amount);
    }

    function changeAddr1(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr1 = newAddr_;
    }

    function changeAddr2(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr2 = newAddr_;
    }

    function changeAddr3(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr3 = newAddr_;
    }

    function changeAddr4(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr4 = newAddr_;
    }

    function changeShare1(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share1 = newShare_;
    }

    function changeShare2(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share2 = newShare_;
    }

    function changeShare3(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share3 = newShare_;
    }

    function changeShare4(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share4 = newShare_;
    }
}