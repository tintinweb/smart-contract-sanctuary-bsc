/**
 *Submitted for verification at BscScan.com on 2022-09-22
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Voter is Ownable {
    modifier OnlyProponsal(){
        require(proponsal[msg.sender],"Voter:Invalid Permission");
        _;
    }
    mapping(address => bool) public voters;
    mapping(address => bool) public arbitrators;
    mapping(address => bool) public proponsal;
    mapping(address => bool) public manager;
    uint256 public votersTotal=1;
    uint256 public arbitratorsTotal=1;
    event update(address user ,uint256 userType,uint256 optype);
    constructor() {
        arbitrators[0xAf37bd93FA9407ac274A49990dBD3777b4f01dD1]=true;
        voters[0xAf37bd93FA9407ac274A49990dBD3777b4f01dD1]=true;
    }

    function updateAdmin(address _manager,bool rst)external onlyOwner{
        manager[_manager]=rst;
    }

    function updateProponsal(address proponsalAddr,bool rst) external {
        require(manager[msg.sender],"Voter:Invalid Permission");
        proponsal[proponsalAddr]=rst;
    }

    function addVoter(address user) external OnlyProponsal {
        _addVoter(user);
    }

    function _addVoter(address user) internal  {
        voters[user]=true;
        votersTotal+=1;
        emit update(user,1,1);
    }

    function removeVoter(address user) external OnlyProponsal {
        require(!arbitrators[user],"Voter:User is Arbitrators");
        delete voters[user];
        votersTotal-=1;
        emit update(user,1,2);
    }

    function addArbitrator(address user) external  OnlyProponsal {
        arbitrators[user]=true;
        if(!voters[user]){
            _addVoter(user);
        }
        
        arbitratorsTotal+=1;
        emit update(user,2,1);
    }

    function removeArbitrator(address user) external OnlyProponsal {
        delete arbitrators[user];
        arbitratorsTotal-=1;
        emit update(user,2,2);
    }
    
}