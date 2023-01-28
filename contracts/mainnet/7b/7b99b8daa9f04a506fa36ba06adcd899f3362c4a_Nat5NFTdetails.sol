/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Nat5NFTdetails is Ownable {
    
    struct Txdetail {
        string data;
    }

    address[] public publishers;
    mapping(string => Txdetail) internal Txdetails;
    mapping(string => bool) txidExists;
    mapping(address => bool) publisher;
    event Updatetxdetails(string indexed txid, string indexed data);

    constructor(){
        publishers.push(msg.sender);
        publisher[msg.sender] = true;
    }

    function addtxdetails(string memory txid, string memory data) external virtual returns(bool){
        require(!txidExists[txid], "Error: transaction id already exists");
        require(publisher[msg.sender], "Error: only publisher can access this function");
        require(bytes(txid).length != 0, "Error: txid field is empty");
        require(bytes(data).length != 0, "Error: data field is empty");
        _updatetxdetails(txid, data);
        txidExists[txid] = true;
        return true;
    }

    function modifitxdetails(string memory txid, string memory data) external virtual returns(bool){
        require(txidExists[txid], "Error: transaction id not exists");
        require(publisher[msg.sender], "Error: only publisher can access this function");
        require(bytes(txid).length != 0, "Error: txid field is empty");
        require(bytes(data).length != 0, "Error: data field is empty");
        _updatetxdetails(txid, data);
        txidExists[txid] = true;
        return true;
    }

    function publishersList() public view returns(address[] memory){
        return publishers;
    }

    function _updatetxdetails(string memory txid, string memory data) internal virtual {
        Txdetail storage txdetail = Txdetails[txid];
        txdetail.data = data;
        emit Updatetxdetails(txid, data);
    }

    function getTransaction(string memory txid) public view returns(string memory) {
        return Txdetails[txid].data;
    }

    function setPublisher(address _publisher) external onlyOwner virtual returns(bool){
        require(!publisher[_publisher], "Error: publisher already exists");
        publishers.push(_publisher);
        publisher[_publisher] = true;
        return true;
    }

    function checkPublisher(address _publisher) external view returns(bool){
        if(publisher[_publisher]){
            return true;
        }
        return false;
    }

    function removePublisher(address _publisher) external onlyOwner virtual returns(bool){
        require(publisher[_publisher], "Error: publisher not exists");
        for(uint i = 0; i < publishers.length; i++){
            if(publishers[i] == _publisher){
                delete publishers[i];
                publisher[_publisher] = false;
                remove(i);
                return true;
            }
        }
        return false;
    }

    function remove(uint index) internal{
        publishers[index] = publishers[publishers.length - 1];
        publishers.pop();
    }

    function numberOfPublisher() external view returns(uint){
        return publishers.length;
    }
}