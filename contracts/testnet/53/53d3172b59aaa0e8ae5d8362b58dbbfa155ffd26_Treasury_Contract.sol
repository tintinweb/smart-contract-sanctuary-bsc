/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface SToken {
    function BASE_MINT() external view returns (uint256);
    function mint(address receiver, uint256 amount) external;
    function burn(uint amount) external;
    function treasuryTransfer(address[] memory recipients, uint256[] memory amounts) external;
    function treasuryTransfer(address recipient, uint256 amount) external;
    function transferTaxRate() external view returns (uint16) ;
    function balanceOf(address account) external view returns (uint256) ;
    function transfer(address to, uint value) external returns (bool);
    function isGenesisAddress(address account) external view returns (bool);
}

contract Treasury_Contract is Ownable {
    address public stakingContract;
    SToken public token;
    uint256 public maxMintAmount = 150000000 * 10**18;
    modifier onlyCounterParty {
        require(stakingContract == msg.sender);
        _;
    }
    constructor(SToken _token) {
        token = _token;
    }
    function myBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    function mint(address recipient, uint256 amount) public onlyCounterParty {
        if(myBalance() < amount){
            token.mint(address(this), calulateMintAmount(amount));
        }
        token.treasuryTransfer(recipient, amount);
    }
    function burn(uint256 amount) public onlyOwner {
        token.burn(amount);
    }
    function seStakingContract(address _newAddress) public onlyOwner {
        stakingContract = _newAddress;
    }
    function setToken(SToken _newAddress) public onlyOwner {
        token = _newAddress;
    }
    function setMaxMintAmount(uint256 amount) public onlyOwner {
        maxMintAmount = amount;
    }
    function calulateMintAmount(uint256 amount) private view returns (uint256 amountToMint) {
        uint256 baseAmount = token.BASE_MINT();
        amountToMint = baseAmount*(amount/baseAmount+1);
        require(amountToMint < maxMintAmount, "Max exceed");
    }

}