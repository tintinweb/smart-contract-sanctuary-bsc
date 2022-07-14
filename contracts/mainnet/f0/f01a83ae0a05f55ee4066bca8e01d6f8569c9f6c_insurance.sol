/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/*
  /$$$$$$                                  /$$                      /$$$$$$
 /$$__  $$                                | $$                     /$$__  $$
| $$  \__/  /$$$$$$  /$$   /$$  /$$$$$$  /$$$$$$    /$$$$$$       | $$  \__/  /$$$$$$   /$$$$$$   /$$$$$$$  /$$$$$$ 
| $$       /$$__  $$| $$  | $$ /$$__  $$|_  $$_/   /$$__  $$      |  $$$$$$  /$$__  $$ |____  $$ /$$_____/ /$$__  $$
| $$      | $$  \__/| $$  | $$| $$  \ $$  | $$    | $$  \ $$       \____  $$| $$  \ $$  /$$$$$$$| $$      | $$$$$$$$
| $$    $$| $$      | $$  | $$| $$  | $$  | $$ /$$| $$  | $$       /$$  \ $$| $$  | $$ /$$__  $$| $$      | $$_____/
|  $$$$$$/| $$      |  $$$$$$$| $$$$$$$/  |  $$$$/|  $$$$$$/      |  $$$$$$/| $$$$$$$/|  $$$$$$$|  $$$$$$$|  $$$$$$$
 \______/ |__/       \____  $$| $$____/    \___/   \______/        \______/ | $$____/  \_______/ \_______/ \_______/
                     /$$  | $$| $$                                          | $$
                    |  $$$$$$/| $$                                          | $$
                     \______/ |__/                                          |__/

*/

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

contract insurance {
    
    address owner;
    address cryptoSpaceAddress;
    mapping (address =>uint) insuranceDates;
    mapping (uint => address) insuranceAddresses;
    uint addressesCounter;
    uint addressesCounterSave;
    bool public insuranceWasSent;

    event addUser(uint indexed userId, address indexed userAddress, uint indexed insuranceAmount);

    constructor(address _owner){
        owner = _owner;
    }
    receive() external payable{}

    modifier onlyOwner() {
      require(owner == msg.sender, "Ownable: caller is not the owner");
      _;
    }

    modifier onlyCryptoSpace() {
      require(cryptoSpaceAddress == msg.sender, "Ownable: caller is not the owner");
      _;
    }

    function setCryptoSpaceAddress(address _cryptoSpaceAddress) external onlyOwner {
        cryptoSpaceAddress = _cryptoSpaceAddress;
    }

    function writeInsuranceDates(uint256 Ipayment, address Iaddress) external onlyCryptoSpace {
        addressesCounter++;
        addressesCounterSave++;
        insuranceAddresses[addressesCounter] = Iaddress;
        insuranceDates[Iaddress] = Ipayment;
        emit addUser(addressesCounter, Iaddress, Ipayment);
    }

    function payment() external payable onlyCryptoSpace {
        uint f;
        uint q;
        if ((addressesCounter / 200) > 0) {
            addressesCounter -= 200;
            f = addressesCounterSave - addressesCounter;
            q = 199;
        } else {
            f = addressesCounterSave;
            q = addressesCounter - 1;
            insuranceWasSent = true;
        }
        for (uint k = f - q; k <= f; k++) {
                address payable rec = payable (insuranceAddresses[k]);
                uint amount = insuranceDates[rec];
                (bool success, ) = rec.call{value: amount}("");
                require(success, "Failed to send insurance");
        }
    }

    function getBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }

    function withdraw(address _receiver) external onlyOwner {
        (bool success, ) = _receiver.call{value: address(this).balance}("");
        require(success, "Failed");
    }
}