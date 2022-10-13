/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract savevac is Ownable {
    struct info_vac {
        string name_vac;
        string person_respo;
        string date_app;
        string dose;
        string batch;
    }

    constructor(){
        _owner = msg.sender;
    }


    mapping(address => uint256) internal info_str;

    mapping(address => info_vac[]) internal infos;


    function SaveInfo(address sender, string memory name_vac,string memory person_respo, string memory date_app, string memory dose, string memory batch ) public onlyOwner{
        infos[sender].push(info_vac(
            name_vac,
            person_respo,
            date_app,
            dose,
            batch
        ));
    }

    function getAllInfo(address sender) public view returns(info_vac[] memory){
        return infos[sender];
    }

    function getInfo(address sender, uint256 id) public view returns(info_vac memory){
        return infos[sender][id];
    }

    function deleteInfo(address sender, uint256 id) public onlyOwner {
        delete infos[sender][id];
    }

}