//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


import "./CIRA20.sol";

contract CIRAContractFactory is Ownable {
    event TokenCreated(address indexed contractAddress, address indexed creatorAddress);

    uint private _fee;

    constructor(uint fee_) {
        _fee = fee_;
    }

    function fee() public view returns (uint) {
        return _fee;
    }

    function withdrawFees() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function createToken(string memory name_, string memory symbol_, uint supply, uint8 decimals, uint256 reflections, uint256 lpfee, uint256 teamfee, uint256 marketingfee) public payable returns (address) {
        require(msg.value == _fee, "Incorrect fee amount");

        address creatorAddress = msg.sender;
        address contractAddress = address(new CIRA20(name_, symbol_, supply, decimals, reflections, lpfee, teamfee, marketingfee, creatorAddress));

        emit TokenCreated(contractAddress, creatorAddress);

        return contractAddress;
    }
}